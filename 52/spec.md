## Summary

The `needs-approval` label is currently described as "deprecated" in three platform files and one guideline. This is incorrect — `needs-approval` is the **default** label for unapproved issues, replaced by `approved-for-*` at time of authorization. The deprecation language causes agents to stop applying it.

## Requirements

- Spec created from user request: "needs-approval needs to be put back, it wasn't supposed to be deprecated, the label is supposed to be replaced by approved-for-* AT TIME OF APPROVAL on a per ticket basis"

## Acceptance Criteria

1. **`guidelines/010-approval-gate.md`**: Line 240 changes `"(replaces the deprecated needs-approval label)"` → `"(needs-approval is the default for unapproved issues; approved-for-* replaces it at time of authorization)"`
2. **`platforms/github-mcp/SKILL.md`**: Line 63 removes deprecation language, clarifies `needs-approval` is the default label applied on creation
3. **`platforms/gitbucket-api/SKILL.md`**: Line 90 — same fix as github-mcp
4. **`platforms/local/SKILL.md`**: Line 113 — same fix as github-mcp

## Non-Goals

- No changes to task files (`creation.md`, `verify-authorization.md`, etc.) — they already correctly apply `needs-approval` on creation and swap for `approved-for-*` at approval
- No behavior changes, documentation only
- No removal of the `approved-for-*` label system — both labels coexist (one for unapproved state, the other for approved state)

## Fix Approach

For each of the 4 files, replace the "deprecated" language with a lifecycle description:

| Current (wrong) | Replacement (correct) |
|-----------------|----------------------|
| `"(replaces the deprecated needs-approval label)"` | `"(needs-approval is the default for unapproved issues; approved-for-* replaces it at time of authorization)"` |
| `"**Deprecated:** The \`needs-approval\` label is deprecated and MUST NOT be applied to new issues."` | `"\`needs-approval\` is the default label for unapproved issues. It is applied on creation and replaced by the corresponding \`approved-for-*\` label at time of authorization."` |

## Success Criteria

- `bash .opencode/tests/test-enforcement.sh --tag labels` passes (content-verification test for label-related rules)
- `grep -r "deprecated.*needs-approval" .opencode/` returns zero matches across all platform and guideline files

## Investigation Completed

- [x] Confirmed `needs-approval` label exists in repo (fetched via GitHub API)
- [x] Confirmed `approved-for-*` labels partially exist (`approved-for-pr` exists; `approved-for-standard`, `approved-for-implementation`, `approved-for-plan`, `approved-for-spec`, `approved-for-review` do NOT exist in this repo)
- [x] All task files (creation, verify-authorization, etc.) correctly apply `needs-approval` on creation and swap at approval
- [x] Only 4 files have incorrect "deprecated" language: 1 guideline + 3 platform skills
- [x] User clarification obtained: "the label is supposed to be replaced by approved-for-* AT TIME OF APPROVAL on a per ticket basis"

---

**STATUS:** DRAFT

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)