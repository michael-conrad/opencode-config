## Parent

https://github.com/michael-conrad/opencode-config/issues/212 — Audit: Skill Card "Use When" Description Compliance

## Problem

`approval-gate` is the only skill among 39 that lacks a formal Trigger Dispatch Table. It uses prose "Routing Rules" instead of a structured table. This means the dispatch conditions are not machine-parseable and the description cannot be verified for completeness against a table.

## Requirements

1. Create a formal Trigger Dispatch Table in `approval-gate/SKILL.md` following the standard format used by all other skills
2. The table must cover all routing conditions: authorization scope checking, approval cascade, pipeline halt boundaries, label application, spec-to-plan cascade, revision revocation, bug discovery protocol
3. Update the description to reflect the new table's conditions
4. Add mandatory language to the description
5. Remove narrative-only content from the description

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `approval-gate/SKILL.md` contains a formal Trigger Dispatch Table | `structural` |
| SC-2 | Table follows the standard format (User says / Context, Task, Dispatch, Context passed) | `structural` |
| SC-3 | Table covers all routing conditions from the existing Routing Rules prose | `semantic` |
| SC-4 | Description reflects all table conditions | `semantic` |
| SC-5 | Description contains mandatory language | `string` |
| SC-6 | Description contains no narrative-only sentences | `semantic` |

## References

- `approval-gate/SKILL.md`
- Audit spec #212 §D3, §D4, §D5
- All other 38 SKILL.md files (reference format)

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)