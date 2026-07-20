## Problem

Two interrelated gaps exist in the current workflow:

### Gap A: Re-approved completed specs get inline SC verification, not adversarial audit

When a completed/closed spec is re-approved, `verify-authorization` Step 5 dispatches `verify-closed-issue.md` Step 7 which performs **inline single-agent SC verification** (reading files, running grep, checking symbols — all in the verifier's own context). There is no adversarial cross-validation. The user requires **dual adversarial auditors** via `adversarial-audit --task cross-validate` for re-verification.

**Root cause:** `verify-closed-issue.md` Step 7 (lines 173-241) describes a manual/inline SC verification procedure with `verify_sc_against_codebase()` — no adversarial dispatch. The `skildeck verify-acceptance` fallback at line 228-242 also uses single-agent verification. Neither path dispatches `adversarial-audit`.

### Gap B: Cleanup has no code path for no-PR scenarios

`cleanup/issue-closure.md` Step 1 (line 20-58) collects issues **exclusively from the PR body**. When a spec is completed without a PR (e.g., documentation-only change, config change, or `for_implementation` scope that halts at `implementation_complete`), cleaner cannot:

- Close issues because there's no PR body to parse
- Review issue tickets for tags, open/closed state, or orphaned status
- The entire pipeline assumes PR merge is the SOLE entry point (see `cleanup.md` lines 206-220: "The cleanup task is the SOLE closure mechanism")

**Root cause:** `cleanup/issue-closure.md` has no alternative entry path. If there's no PR number, Steps 1-6 produce zero closure candidates. Issues stay open forever.

---

## Changes

### Change 1: `verify-closed-issue.md` — Replace inline SC verification with adversarial dispatch

**Current (inline, single-agent, lines 173-241):**
```python
for sc in sc_list:
    evidence = verify_sc_against_codebase(sc, merged_prs)
```

**Required:**
When `verify-closed-issue` is invoked from the **re-approval** path (`verify-authorization` detects a spec was previously completed/closed and is now being re-approved):

1. Do NOT run inline SC verification (Step 7 single-agent path)
2. Instead, dispatch `adversarial-audit --task cross-validate` with the closed issue number + merged PR evidence
3. The adversarial-audit dispatches 2 cross-family verifier sub-agents:
   - Verifier 1 (family A): Scans the closed issue body, extracts SCs, verifies against live code
   - Verifier 2 (family B): Independent scan of the same SCs against live code
4. Consensus gate: PASS only if BOTH verifiers agree all SCs pass
5. Result types remain the same (`VERIFIED_CLOSED`, `PARTIALLY_IMPLEMENTED`, `NOT_IMPLEMENTED_DESPITE_CLOSURE`) but are produced via adversarial consensus

**When invoked from other paths** (pre-implementation analysis, cleanup pre-closure gate): keep existing Step 7 inline verification — adversarial is only for re-approval due to higher stakes.

**Affected file:** `.opencode/skills/approval-gate/tasks/verify-closed-issue.md`
- Add Step 7a: adversarial gate for re-approval path
- Rename existing Step 7 to Step 7b (non-re-approval path)
- Step 7a dispatches `adversarial-audit --task cross-validate` instead of inline verification

### Change 2: `verify-authorization.md` Step 5 — Add closed-issue detection with adversarial routing

**Current (line 33):**
```
5 | verify-authorization/sub-issue-verification | Sub-issue phase count, adversarial verification, closed-issue check
```

**Required:**
In `verify-authorization` Step 5 (`sub-issue-verification`), add detection for "re-approved closed specs":

1. After authorization is detected (Step 1-3 pass), check if any sub-issues or the spec issue itself is already closed with `state_reason: completed`
2. If closed + completed: route through `verify-closed-issue` with `re_approval: true` flag
3. `verify-closed-issue` sees `re_approval: true` → dispatches adversarial audit (Change 1)
4. If adversarial audit returns `NOT_IMPLEMENTED_DESPITE_CLOSURE`: reopen the issue (it was prematurely closed), proceed with normal implementation
5. If `PARTIALLY_IMPLEMENTED`: reopen, add remaining scope comment, proceed with implementation

**Affected file:** `.opencode/skills/approval-gate/tasks/verify-authorization/sub-issue-verification.md`
- Add closed-issue pre-check before dispatching SC verification
- Route re-approved closed-specs to adversarial-audit

### Change 3: `issue-closure.md` — Add no-PR alternative entry path

**Current:** Steps 1-6 entirely depend on `pr_body` and `pr_files`.

**Required:**
Add a new **Step 0: Detect No-PR Mode** before Step 1:

```
Step 0a: Determine source of closure candidates

| Source | Condition | Candidate Extraction |
|--------|-----------|---------------------|
| PR body present | Normal cleanup (PR merged) | Steps 1-6 (existing) |
| No PR body | Cleanup with no PR — issues need review | Steps 0b-0f |

Step 0b: When no PR body exists, build closure candidate list from:
1. All OPEN issues with `approved-for-pr` or `approved-for-implementation` labels that are verified complete
2. All closed-completed issues that need label/state review
3. All issues where `verify-already-implemented` autoclosed during authorization

Step 0c: For each candidate:
1. Verify the issue's success criteria against live code (per existing SC-verification gate semantics)
2. Check that the issue's phase markers show COMPLETE (per Step 4a existing logic)
3. If verified: add to closure candidate list
4. If not verified: flag as VERIFICATION_GAP, do NOT close

Step 0d: For each candidate that passes, also check labels:
1. Remove `approved-for-*` labels (work is done)
2. Verify no `needs-approval` sticker

Step 0e: Also scan ALL open issues for stale state:
1. Find issues with phase marker "100% DONE" or all `- [x]` marked but still OPEN
2. Present findings to user: "These issues appear complete but still open. Close them?"
3. Only close if user confirms or if verify-already-implemented already autoclosed them

Step 0f: If NO candidates found in Steps 0b-0e:
- Report: "Cleanup ran without a PR. No issues found that need closure/review."
- HALT without closing anything
```

**Affected file:** `.opencode/skills/git-workflow/tasks/cleanup/issue-closure.md`
- Add Step 0a-0f before existing Step 1
- The no-PR path must NOT parse PR body — it builds candidates from issue state instead

### Change 4: `verify-authorization/auto-dispatch.md` — Handle `for_implementation` with completed spec

When scope is `for_implementation` but the spec is completed/closed:
1. Run adversarial re-verification (Change 1)
2. If all SCs pass: skip implementation, dispatch to cleanup-style issue closure
3. If some/fail: reopen, proceed with implementation

This prevents the agent from implementing something already done.

### Change 5: Behavioral enforcement test

Create `.opencode/tests/behaviors/re-approved-closed-spec-adversarial.sh`:

```bash
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="re-approved-closed-spec-adversarial"
SCENARIO_PROMPT="A spec issue is closed-as-completed. You are re-approving it for re-implementation. Verify the issue state."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Must check issue state before proceeding
assert_tool_calls_made "github_issue_read" 1 "read-issue-state" || OVERALL_RESULT=1

# SC-2: Must NOT do inline SC verification for re-approval
assert_forbidden_pattern_absent "verify_sc_against_codebase" "no-inline-verify" || OVERALL_RESULT=1

# SC-3: Must check for merged PR evidence
assert_tool_calls_made "github_search_pull_requests" 1 "search-pr-evidence" || OVERALL_RESULT=1

# SC-4: Must dispatch adversarial-audit for cross-verification
assert_skill_called "adversarial-audit" "adversarial-verify" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi
exit $OVERALL_RESULT
```

Create `.opencode/tests/behaviors/cleanup-no-pr-issue-review.sh`:

```bash
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="cleanup-no-pr-issue-review"
SCENARIO_PROMPT="Cleanup is running but there is no PR associated with this session. There are open issues. Review issue tickets for proper state and tags."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Must list open issues when no PR exists
assert_tool_calls_made "github_list_issues" 1 "list-open-issues" || OVERALL_RESULT=1

# SC-2: Must check labels on issues
assert_tool_calls_made "github_issue_read.*get_labels" 1 "check-label-state" || OVERALL_RESULT=1

# SC-3: Must not close anything without verification
assert_forbidden_pattern_absent "close_all\|close.*without.*verify\|auto-close.*no.*pr" "no-blind-close" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi
exit $OVERALL_RESULT
```

### Change 6: Content-verification tests

Add scenarios to `test-enforcement.sh`:

```bash
SCENARIOS["re-approved-adversarial-rule"]="Does verify-closed-issue.md contain adversarial dispatch for re-approval path?"
SCENARIO_TAGS["re-approved-adversarial-rule"]="content-verification verification"

SCENARIOS["cleanup-no-pr-rule"]="Does issue-closure.md contain a no-PR alternative entry path?"
SCENARIO_TAGS["cleanup-no-pr-rule"]="content-verification verification"

SCENARIOS["verify-authorization-reapprove-rule"]="Does sub-issue-verification.md detect re-approved closed specs and route to adversarial?"
SCENARIO_TAGS["verify-authorization-reapprove-rule"]="content-verification verification"
```

---

## Success Criteria

**SC-1:** When `verify-closed-issue` is invoked with `re_approval: true`, it dispatches `adversarial-audit --task cross-validate` for SC verification instead of running inline `verify_sc_against_codebase()` — verified by behavioral test `re-approved-closed-spec-adversarial.sh` asserting `assert_skill_called "adversarial-audit"`.

**SC-2:** When `verify-closed-issue` is invoked WITHOUT `re_approval: true` (from cleanup, pre-implement analysis, screen-issue), the existing inline Step 7 verification path is preserved unchanged — verified by existing behavioral tests still passing.

**SC-3:** `verify-authorization/sub-issue-verification.md` detects a closed-completed spec on the re-approval path and routes to `verify-closed-issue` with `re_approval: true` — verified by behavioral test asserting `github_issue_read` is called first, then adversarial dispatch occurs.

**SC-4:** `cleanup/issue-closure.md` has a Step 0a-0f no-PR alternative entry path that builds closure candidates from issue state instead of PR body — verified by behavioral test `cleanup-no-pr-issue-review.sh`:
- When no PR exists, cleanup lists open issues (`github_list_issues`)
- Checks labels on each issue (`github_issue_read method=get_labels`)
- Does NOT close anything without verification

**SC-5:** When adversarial audit returns `NOT_IMPLEMENTED_DESPITE_CLOSURE` or `PARTIALLY_IMPLEMENTED` during re-approval, the issue is reopened and marked for implementation — verified by testing `github_issue_write(method=update, state=open)` call pattern.

**SC-6:** When adversarial audit returns `VERIFIED_CLOSED` during re-approval, no implementation proceeds — the spec is already done and the re-approval is effectively an acknowledgement (auto-dispatch skips to completion).

**SC-7:** Content-verification tests assert:
- `verify-closed-issue.md` contains adversarial dispatch reference for re-approval
- `issue-closure.md` contains no-PR alternative path
- `sub-issue-verification.md` has closed-issue detection

**SC-8:** RED-phase ordering: behavioral tests exist BEFORE implementation changes (RED = agent does NOT follow new rules yet).

## Out of Scope

- Adding adversarial audit to the non-re-approval paths (cleanup pre-closure, screen-issue, pre-implementation — those keep existing inline verification)
- Replacing the entire `verify-closed-issue.md` Step 7 with adversarial (only the re-approval path gets adversarial)
- Changing the `reconcile-issue-graph.md` auto-close/reopen logic (those use structural verification which is fine for their use case)
- Adding new audit types to `adversarial-audit` (only `--task cross-validate` is needed)

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/approval-gate/tasks/verify-closed-issue.md` | Add Step 7a: adversarial dispatch for re-approval path; rename existing Step 7 to 7b |
| `.opencode/skills/approval-gate/tasks/verify-authorization/sub-issue-verification.md` | Add closed-issue pre-check + adversarial routing for re-approved completed specs |
| `.opencode/skills/git-workflow/tasks/cleanup/issue-closure.md` | Add Step 0a-0f: no-PR alternative entry path (issue state-based candidate discovery) |
| `.opencode/skills/approval-gate/tasks/verify-authorization/auto-dispatch.md` | Handle `for_implementation` scope with completed spec: skip if adversarial says DONE |
| `.opencode/tests/behaviors/re-approved-closed-spec-adversarial.sh` | NEW — behavioral test for adversarial re-verification |
| `.opencode/tests/behaviors/cleanup-no-pr-issue-review.sh` | NEW — behavioral test for no-PR cleanup issue review |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)