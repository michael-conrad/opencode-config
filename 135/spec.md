## Objective

Restructure the `git-workflow` skill so that pipeline bypass is architecturally impossible through data-flow dependency rather than prose prohibition. Each pipeline step produces YAML artifacts that the next step requires as mandatory inputs. If an artifact doesn't exist or is invalid, the next step fails with a structured BLOCKED result — not a warning.

## Problem Statement

The agent repeatedly bypasses PR creation requirements (VbC tables, audit cross-validation, verification attestation) because current enforcement is entirely reactive prose — guideline text, symbolic rules, and warning blocks injected after violations. The agent can and does ignore these.

Root causes identified:

1. **No verification gate in git-workflow.** VbC and audit are called by `divide-and-conquer/assemble-work`, not by git-workflow. There's no structural dependency. The agent skips straight from implementation → review-prep → PR creation without running verification.

2. **enforcement-gate doesn't check VbC/audit completion.** It checks submodule liveness, commit counts, existing PR state, and merge conflicts — not whether verification artifacts exist.

3. **VbC/audit check is too late.** Step 4.75 in `create-pr.md` checks `./tmp/artifacts/` after squash/push — the horse has left the barn. Changes are already on the remote.

4. **review-prep pushes before verification.** The agent pushes unverified code.

5. **pre-work.md is 3,622 words** — 21% over the atomic task limit. Too complex for reliable agent following.

6. **SKILL.md routing table has wrong word counts.** `pre-work` listed at ~480 (actual 3,622). `create-pr` sub-task listed at ~550 (actual 1,671). False signals about complexity.

7. **4 referenced submodule sub-agent tasks don't exist as files.** Listed in SKILL.md but implemented as commands elsewhere.

8. **commit-prep.md is unrouted.** 1,131 words, not in the SKILL.md task table. Invisible to the agent.

9. **pre-merge-verification.md is a 67-word stub** duplicating verify-merge.md.

10. **Task nesting is inconsistent.** Some tasks have sub-task directories (`pr-creation/`, `cleanup/`, `review-prep/`, `provenance/`), others are flat monoliths.

11. **Artifact format is JSON** — poor for LLM parsing. YAML is more natural.

## Context

- **Affected skill:** `.opencode/skills/git-workflow/`
- **Pipeline flow:** authorization → pre-work → implementation → VbC → audit → verification-gate → review-prep → pr-creation → cleanup
- **Current gap:** No structural dependency between VbC/audit and review-prep/pr-creation
- **Issue #66** (closed, not_planned) addressed dispatch standardization, not pipeline architecture
- **Submodule:** `.opencode` tracks `dev` branch

## Constraints

1. **No runtime enforcement hooks.** This restructure uses data-flow dependency (YAML artifacts), not `tool.execute.before` plugin hooks
2. **No changes to `divide-and-conquer`, `verification-before-completion`, or `adversarial-audit` skills.** Those produce the YAML artifacts; git-workflow consumes them
3. **YAML for all agent-producible/consumable artifacts.** No JSON. YAML is more natural for LLM parsing
4. **Each task file must stay under 3,000 words** per incremental-build discipline
5. **Sub-agents cannot dispatch sub-agents** — the orchestrator dispatches all sub-tasks via `task()`
6. **The verification-gate is read-only.** It checks artifacts, it doesn't produce or modify them
7. **FAIL is a hard gate.** The agent cannot proceed past verification-gate with a FAIL result
8. **Skill routing table must not contain word counts.** Purpose and invocation criteria only
9. **All existing behavioral tests must pass after restructure**
10. **Submodule sub-agent tasks must exist as task files** or the SKILL.md routing must accurately reflect their actual location

## Success Criteria

| SC | Description | Evidence Type | Verification Method |
|----|-------------|---------------|---------------------|
| SC-1 | `verification-gate` task file exists at `tasks/verification-gate.md` with entry/exit criteria, YAML artifact parsing, and BLOCKED result contract | structural | `ls tasks/verification-gate.md` |
| SC-2 | `verification-gate` reads `./tmp/artifacts/verification-<issue>.yaml` and checks all SC rows report PASS | behavioral | `opencode-cli run` with mock YAML artifact — agent correctly parses and reports PASS |
| SC-3 | `verification-gate` reads `./tmp/artifacts/audit-cross-validate-<issue>.yaml` and checks consensus is PASS with both auditors present | behavioral | `opencode-cli run` with mock YAML artifact — agent correctly validates audit result |
| SC-4 | `verification-gate` returns BLOCKED with structured remediation when artifacts are missing | behavioral | `opencode-cli run` without mock artifacts — agent HALTs with BLOCKED result and remediation instructions |
| SC-5 | `verification-gate` returns BLOCKED when SC rows report FAIL or MISSING_EVIDENCE | behavioral | `opencode-cli run` with failing mock artifact — agent HALTs with specific SC failures |
| SC-6 | `verification-gate` returns BLOCKED when audit consensus is DISAGREE or FAIL | behavioral | `opencode-cli run` with disagreeing mock artifact — agent HALTs with auditor disagreement details |
| SC-7 | `pre-work.md` decomposed from 3,622-word monolith into atomic sub-tasks each under 3,000 words | structural | `wc -w tasks/pre-work/verify-auth.md tasks/pre-work/sync-dev.md tasks/pre-work/create-branch.md tasks/pre-work/init-env.md tasks/pre-work/report-ready.md` — each ≤ 3000 |
| SC-8 | SKILL.md routing table contains no word counts — only task name, purpose, and when to invoke | string | `grep -c "≈" .opencode/skills/git-workflow/SKILL.md` returns 0 for the task table |
| SC-9 | `commit-prep.md` is present in SKILL.md routing table | string | `grep "commit-prep" .opencode/skills/git-workflow/SKILL.md` finds the entry |
| SC-10 | Submodule sub-agent task files exist at correct paths or SKILL.md routing accurately reflects their actual location | string | `grep "submodule-" .opencode/skills/git-workflow/SKILL.md` — each entry references a file that exists or accurately describes the command location |
| SC-11 | `enforcement-gate.md` updated to re-verify VbC/audit YAML artifacts in addition to existing checks | structural | `grep "verification-.*\.yaml\|audit-cross-validate-.*\.yaml" .opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md` finds artifact references |
| SC-12 | `create-pr.md` Step 4.5 (dispatch log check) removed as redundant — verification-gate already checked artifacts | structural | `grep -c "dispatch log" .opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` returns 0 |
| SC-13 | Review-prep routing table includes verification-gate as prerequisite — review-prep won't proceed without verification-gate PASS | structural | `grep "verification-gate" .opencode/skills/git-workflow/tasks/review-prep.md` finds prerequisite reference |
| SC-14 | All YAML artifact formats documented in task files with required fields | structural | `grep "issue:\|phase:\|success_criteria:\|consensus:" .opencode/skills/git-workflow/tasks/verification-gate.md` finds format documentation |
| SC-15 | `pre-merge-verification.md` stub absorbed into `verify-merge.md` or expanded to useful content | structural | `test ! -f .opencode/skills/git-workflow/tasks/cleanup/pre-merge-verification.md -o $(wc -w < .opencode/skills/git-workflow/tasks/cleanup/pre-merge-verification.md) -gt 200` |

## Phases

### Phase 1: Verification-Gate Task (SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-14)

**Concern:** Create the new verification-gate task that reads YAML artifacts and gates the pipeline

**Steps:**

1.1 Create `tasks/verification-gate.md` with:
- Purpose: Read VbC and audit YAML artifacts, validate PASS status, return BLOCKED if missing/invalid
- Entry criteria: Implementation complete, divide-and-conquer has run VbC and audit
- Exit criteria: All artifacts exist, all SC rows PASS, all auditors PASS, consensus PASS
- Procedure: Parse YAML files, validate required fields, check PASS status, construct result contract
- YAML format documentation for both artifact types (verification report and cross-validation result)
- BLOCKED result contract with remediation instructions
- DONE result contract with verified artifact summary

1.2 Update `SKILL.md` routing table to include `verification-gate` in task list and invocation table

1.3 Create behavioral enforcement test for verification-gate:
- Test that agent reads YAML artifacts and reports PASS when all valid
- Test that agent HALTs with BLOCKED when artifacts missing
- Test that agent HALTs with BLOCKED when SC rows have FAIL
- Test that agent HALTs with BLOCKED when audit consensus is DISAGREE
- Test that agent HALTs with BLOCKED when audit consensus is FAIL

### Phase 2: Pre-Work Decomposition (SC-7, SC-10)

**Concern:** Break the 3,622-word monolith into atomic sub-tasks

**Steps:**

2.1 Create `tasks/pre-work/` directory with sub-tasks:
- `verify-auth.md` — Step 1: verify authorization context (from current steps 1, 1.5)
- `sync-dev.md` — Step 2: sync dev branch, proactive repo state verification (from current steps 2, 2.5, 2.7)
- `create-branch.md` — Step 3: create feature branch, direct-branch and worktree modes (from current step 3, 3.7)
- `init-env.md` — Step 3.5: submodule init/sync, tag submodule dev tips (from current step 3.5)
- `report-ready.md` — Step 5: report branch name and status (from current step 5)

2.2 Rewrite `tasks/pre-work.md` as a routing file (like `pr-creation.md`) that dispatches sub-tasks via `task()` in sequence

2.3 Create or reference submodule sub-agent task files at their actual locations
- Either create `tasks/submodule-tag-prework.md`, `tasks/submodule-feature-push.md`, `tasks/submodule-liveness-check.md`, `tasks/submodule-dev-restore.md` as task files
- Or update SKILL.md to accurately reference `.opencode/commands/submodule-tag-prework.md` etc. as the actual location

2.4 Move the `investigate/` scratch branch section from pre-work into a separate task or into SKILL.md Operating Protocol

### Phase 3: SKILL.md Routing Table Rewrite (SC-8, SC-9, SC-10)

**Concern:** Make the routing table accurate and useful

**Steps:**

3.1 Rewrite SKILL.md task table to contain: task name, purpose (one line), when to invoke — NO word counts

3.2 Add `commit-prep` to the routing table with purpose and invocation

3.3 Add `verification-gate` to the routing table with purpose ("check VbC/audit artifacts before push") and invocation

3.4 Update sub-task table format to list sub-task files with purpose only (no word counts)

3.5 Remove all `≈<number>` word count entries from both task and sub-task tables

### Phase 4: Verification Integration (SC-11, SC-12, SC-13)

**Concern:** Wire verification-gate into the pipeline so it's a mandatory step

**Steps:**

4.1 Update `tasks/pr-creation/enforcement-gate.md`:
- Add Step 1.7: Re-verify VbC/audit YAML artifacts exist and report PASS
- Reference `./tmp/artifacts/verification-<issue>.yaml` and `./tmp/artifacts/audit-cross-validate-<issue>.yaml`
- HALT if artifacts missing or invalid (belt-and-suspenders check)

4.2 Update `tasks/pr-creation/create-pr.md`:
- Remove Step 4.5 (dispatch log check — redundant after verification-gate)
- Keep Step 4.75 as final content validation (belt and suspenders)
- Update any references to verification artifact format from JSON to YAML

4.3 Update `tasks/review-prep.md`:
- Add verification-gate as prerequisite in Entry Criteria
- `review-prep` should NOT proceed unless verification-gate returned DONE

### Phase 5: Cleanup (SC-15)

**Concern:** Clean up structural issues

**Steps:**

5.1 Absorb `tasks/cleanup/pre-merge-verification.md` (67-word stub) into `tasks/cleanup/verify-merge.md` or expand it to useful content

5.2 Verify all task files are under 3,000 words (re-check after decomposition)

5.3 Update all task cross-references that reference pre-work step numbers (they changed during decomposition)

5.4 Verify `tasks/implementation.md` references to pre-work align with new sub-task structure

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Decomposition breaks pre-work flow (steps out of order, missing context) | Medium | High | Each sub-task has explicit entry/exit criteria; integration test covers full pre-work sequence |
| YAML artifact format doesn't match what VbC/audit actually produce | Medium | High | Coordinate with `verification-before-completion` skill maintainers; verify artifact format against actual VbC output |
| verification-gate false-negative blocks legitimate pipeline | Low | High | BLOCKED result includes specific remediation instructions; agent can re-run VbC/audit and re-gate |
| Task cross-references break after decomposition | Medium | Medium | Grep for step number references in all task files after changes |
| review-prep prerequisite not enforced (agent skips verification-gate) | Medium | High | review-prep Entry Criteria explicitly requires verification-gate DONE; enforcement-gate re-checks as belt-and-suspenders |
| Submodule sub-agent task file location mismatch | Low | Low | Phase 2 step 2.3 explicitly reconciles SKILL.md references with actual file locations |

## Edge Cases

- **No `.gitmodules` file**: verification-gate skips submodule checks; VbC/audit artifacts are the only check
- **Pair mode branches**: verification-gate runs in pair mode too; pair-pre-work already has reduced submodule handling
- **`investigate/` scratch branches**: No VbC/audit artifacts expected; review-prep and pr-creation don't apply to investigate branches
- **Multi-issue work branches**: Multiple verification artifacts may exist; verification-gate checks ALL matching `verification-*.yaml` and `audit-cross-validate-*.yaml`
- **YAML parsing errors in artifacts**: verification-gate reports BLOCKED with "malformed artifact" and points to the specific file and field
- **Artifacts from previous issues left in `./tmp/artifacts/`**: verification-gate matches artifacts to the current issue number

## Change Control

- This spec supersedes any conflicting routing, structure, or word count information in the current git-workflow SKILL.md and task files
- YAML artifact format for verification reports and cross-validation results is new — this spec introduces it
- The `verification-before-completion` and `adversarial-audit` skills produce the YAML artifacts; this spec only defines how git-workflow consumes them
- No changes to `divide-and-conquer`, `verification-before-completion`, or `adversarial-audit` skills — those are out of scope
- Post-implementation: run `adversarial-audit --task spec-audit` to verify spec fidelity

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)