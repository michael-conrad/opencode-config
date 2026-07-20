## Problem

The writing-plans 21-step pipeline (both `create.md` and `retroactive.md`) contains Z3 check steps after every sub-agent dispatch. These steps are structurally unexecutable:

1. **No Z3 contracts exist** — the `contracts/create-output-template.yaml` files are Mustache/Jinja2 templates (`{{status}}`, `{{plan_path}}`), not Z3 contracts. They lack `variables:`, `preconditions:`, `invariants:`, `postconditions:` sections that `solve check` requires.

2. **No state management** — the writing-plans pipeline never creates or updates a Z3 state file. The `solve check` tool requires `--state-path` pointing to a state YAML with variable assignments. Only the `implementation-pipeline` pipeline has state management.

3. **Agent cannot execute them** — since both prerequisites are missing, the agent silently narrates "Step 18: Z3 check — Audit-fidelity output has PASS. Proceeding." without ever calling `solve check`. No bash tool call is made because the call would fail.

These steps produce no actual verification signal — they are phantom operations that waste pipeline steps and create false confidence.

## Scope

Three files in the `writing-plans` skill:

| File | Steps to Remove |
|------|----------------|
| `tasks/create.md` | Steps 3, 5, 7, 9, 12, 14, 16, 18, 20, 22 |
| `tasks/retroactive.md` | Steps 3, 5, 7, 9, 11, 13, 15, 17, 19, 21 |
| `SKILL.md` | Steps 3, 5, 7, 9, 12, 14, 16, 18, 20, 22 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `tasks/create.md` has no Z3 check steps — all `(**inline**) Z3 check —` lines removed, step numbering re-sequenced | `string` | grep for `Z3 check` in `tasks/create.md` returns 0 matches |
| SC-2 | `tasks/retroactive.md` has no Z3 check steps — all `(**inline**) Z3 check —` lines removed, step numbering re-sequenced | `string` | grep for `Z3 check` in `tasks/retroactive.md` returns 0 matches |
| SC-3 | `SKILL.md` has no Z3 check steps — all `(**inline**) Z3 check —` lines removed, step numbering re-sequenced | `string` | grep for `Z3 check` in `SKILL.md` returns 0 matches |
| SC-4 | Step numbering is sequential (1, 2, 3, ...) with no gaps in all three files | `string` | Visual inspection confirms sequential numbering |
| SC-5 | Chain dependencies updated — each remaining step's chain references the correct previous step number | `string` | Visual inspection confirms chain references match new step numbers |

## Files Affected

- `.opencode/skills/writing-plans/tasks/create.md`
- `.opencode/skills/writing-plans/tasks/retroactive.md`
- `.opencode/skills/writing-plans/SKILL.md`

## Risks

- Low: Removing steps that were never executed has no behavioral impact
- The sub-agent dispatches (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern, completion) remain intact — only the Z3 check interleaves are removed
- Chain dependencies must be updated to skip the removed steps

## Dependencies

None.

## Revisions

- v1 — Initial spec

---
🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)