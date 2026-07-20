> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> Full spec and artifacts: [`.issues/{N}/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/{N}/)

## Problem

The behavioral test harness (`behavior_run()` in `.opencode/tests/behaviors/helpers.sh`) creates an isolated git repo, clones `.opencode` from remote as a submodule, and runs `opencode-cli run` inside it. When testing changes to `.opencode/` skills/guidelines, the test needs the `.opencode` submodule checked out to the feature branch commit that contains those changes. However:

1. `behavior_run()` clones `.opencode` from remote — it gets whatever is on the remote's default branch
2. `BEHAVIOR_SUBMODULE_COMMIT` exists to pin the checkout to a specific SHA, but this is undocumented
3. The feature branch commit must be pushed to the remote before the test runs, otherwise the SHA doesn't exist on the remote
4. None of this is documented in `.opencode/tests/AGENTS.md` or `helpers.sh`

The agent writing behavioral tests consistently discovers this at runtime (test fails because `.opencode` is on the wrong commit), then self-remediates. This wastes test time and produces confusing failure modes.

## Scope

Documentation-only fix. No changes to `helpers.sh` or `behavior_run()` — the mechanism already exists (`BEHAVIOR_SUBMODULE_COMMIT`). The fix is documenting the precondition.

### In Scope

- Documenting `BEHAVIOR_SUBMODULE_COMMIT` in `.opencode/tests/AGENTS.md`
- Documenting the push-before-test workflow in `.opencode/tests/AGENTS.md`
- Adding function-level comments in `.opencode/tests/behaviors/helpers.sh` (if any exist)

### Out of Scope

- Any changes to `helpers.sh` or `behavior_run()` logic
- Any changes to the test harness infrastructure
- Any changes to how `.opencode` is cloned or checked out

## Affected Files

| File | Change Type | Anchor |
|------|-------------|--------|
| `.opencode/tests/AGENTS.md` | Add documentation section | `"Behavioral Test Harness"` section |
| `.opencode/tests/behaviors/helpers.sh` | Add function-level comments (if any) | `behavior_run()` function |

## Approach

Add a new section to `.opencode/tests/AGENTS.md` titled "Behavioral Test Harness — Submodule Commit Precondition" that documents:

1. The `BEHAVIOR_SUBMODULE_COMMIT` environment variable and its purpose
2. The precondition: the `.opencode` feature branch MUST be pushed to remote before the test runs
3. The workflow: push `.opencode` feature branch → get SHA → set `BEHAVIOR_SUBMODULE_COMMIT` → run test
4. What happens if the precondition is not met (test fails with `.opencode` on wrong commit)

Optionally add a comment block above `behavior_run()` in `helpers.sh` referencing the AGENTS.md documentation.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | AGENTS.md documents that behavioral tests testing `.opencode/` changes require the `.opencode` feature branch to be pushed to remote before running | `string` | `grep` for "push" or "remote" in the documented section of AGENTS.md |
| SC-2 | AGENTS.md documents that `BEHAVIOR_SUBMODULE_COMMIT` must be set to the pushed SHA | `string` | `grep` for "BEHAVIOR_SUBMODULE_COMMIT" in AGENTS.md |
| SC-3 | AGENTS.md documents the workflow: push `.opencode` feature branch → get SHA → set env var → run test | `string` | `grep` for the workflow sequence in AGENTS.md |
| SC-4 | Evidence type: `string` (grep for the documented text in AGENTS.md) | `string` | `grep` for documented text in AGENTS.md |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `https://github.com/michael-conrad/opencode-config/tree/issues-data/{N}/`.
After creation, `local-issues sync {N}` MUST be run and the result committed to create the local `.issues/{N}/` entry.
The implementation plan will be created in `.issues/{N}/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)