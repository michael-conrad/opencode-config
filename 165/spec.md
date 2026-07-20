## Problem

All four auditor agent cards (`auditor-deepseek-flash`, `auditor-gemma4`, `auditor-qwen3.5`, `auditor-mistral-large`) permit `github_issue_read`, `github_search_issues`, and `github_list_issues`. This is a platform routing violation — auditors must work from local spec copies and artifacts only, independent of any remote platform.

Additionally, the `closure-verification` task in `adversarial-audit` has hardcoded `github_pull_request_read` and `github_issue_read` calls. This task is inherently platform-dependent and should not live in the adversarial-audit skill at all.

## Scope

Remove GitHub MCP permissions from auditor agent cards and unload closure-verification to git-workflow cleanup.

## Files Affected

| File | Change |
|------|--------|
| `.opencode/agents/auditor-deepseek-flash.md` | Remove `github_issue_read`, `github_search_issues`, `github_list_issues` from permission block |
| `.opencode/agents/auditor-gemma4.md` | Same |
| `.opencode/agents/auditor-qwen3.5.md` | Same |
| `.opencode/agents/auditor-mistral-large.md` | Same |
| `.opencode/skills/adversarial-audit/tasks/closure-verification.md` | Delete — closure verification becomes part of git-workflow cleanup |
| `.opencode/skills/adversarial-audit/tasks/spec-summary.md` | Replace `github_pull_request_read` direct calls with references to issue-operations dispatcher (orchestrator context only) |
| `.opencode/skills/adversarial-audit/SKILL.md` | Remove `closure-verification` from task list; update cross-references |
| `.opencode/skills/git-workflow/tasks/cleanup.md` | Add post-merge verification step (verify PR merged, issue closed, blockers resolved, follow-ups exist) using issue-operations dispatcher |

## Detailed Changes

### 1. Auditor Agent Cards — Permission Removal

In each of the 4 `auditor-*.md` files:

```
  github_*: deny
- github_issue_read: allow
- github_search_issues: allow
- github_list_issues: allow
  srclight_*: allow
```

Remove lines 21-23 from all cards. The `github_*: deny` broad rule on line 20 already covers all github tools; the per-tool allow overrides are what need removing.

### 2. SC_CONFLICT Protocol Update

The SC_CONFLICT step in each auditor card references fetching specs from GitHub. Since auditors no longer have GitHub access, SC_CONFLICT detection MUST use `spec_local_dir` content instead. The protocol becomes:

- Fetch spec from `spec_local_dir` (local filesystem, provided by orchestrator)
- Compare caller-provided SCs against spec-declared SCs
- Same conflict/superset/subset/absent classification

No live GitHub fetch. (Note: `spec_local_dir` is orchestrator-provided, but the auditor independently reads and parses the files — it does not receive the spec body inline.)

### 3. Closure Verification — Removed from adversarial-audit

Delete the entire `closure-verification.md` task file. The adversarial-audit skill no longer owns post-merge verification. This task was never a proper adversarial audit (it's a single-path deterministic check, not dual cross-family).

Add post-merge verification to `git-workflow` cleanup task. Cleanup already handles:
- Delete merged branches
- Close completed issues
- Sync dev

Add a step that verifies:
- PR is actually merged (not just closed)
- Spec issue is closed
- No blocking comments remain open
- Follow-up issues exist and are open (if referenced)

These use `issue-operations` dispatcher for platform-agnostic calls.

### 4. spec-summary.md — Platform Call Routing

`spec-summary.md` has three direct `github_pull_request_read(method="get"/"get_files"/"get_commits")` calls. This task runs in the orchestrator's context (it's a spec-summary generator, not an auditor), so it has access to platform APIs. Replace direct calls with `issue-operations` dispatcher invocations:

```
- pr = github_pull_request_read(method="get", ...)
+ pr = issue-operations --task read-pr (owner, repo, pullNumber)
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No auditor agent card permits any `github_*` tool | `string` | `grep` on each agent card for `github_*` permission lines — only `github_*: deny` may exist |
| SC-2 | No `closure-verification.md` task file exists in adversarial-audit | `structural` | `ls` on tasks directory |
| SC-3 | `closure-verification` removed from adversarial-audit SKILL.md task list | `string` | `grep` for `closure-verification` in SKILL.md returns no match |
| SC-4 | `spec-summary.md` no longer contains direct `github_pull_request_read` calls | `string` | `grep` for `github_pull_request` in spec-summary.md returns no match |
| SC-5 | git-workflow cleanup task includes post-merge verification step | `string` | `grep` for `verify merge` or `post-merge` in cleanup task file |
| SC-6 | SC_CONFLICT protocol in auditor cards does not reference `github_issue_read` or live GitHub fetch | `string` | `grep` for `github_issue_read` in all auditor cards — no matches |

## Dependencies

- `git-workflow` cleanup task needs updating to include the new post-merge verification step (spec for that change is scoped separately once this audit permission fix lands)

## Risk Analysis

| Risk | Severity | Mitigation |
|------|----------|------------|
| Auditor can't verify SCs from live spec | Medium | `spec_local_dir` + `artifact_evidence_dir` are the canonical input contract; remove GitHub fallback entirely |
| Closure-verification gap while git-workflow cleanup is being updated | Low | closure-verification was likely not running in practice — removing it before adding to cleanup is acceptable |
| Spec summary generation blocks on issue-operations dispatcher | Low | issue-operations dispatcher routes correctly for both GitHub and GitBucket; PR reads are supported |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
