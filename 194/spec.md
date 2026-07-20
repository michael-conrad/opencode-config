## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The `writing-plans` skill embeds a verbatim copy of the 14-step implementation pipeline dispatch routing table, creating two sources of truth for the same pipeline structure. Additionally, the spec writer generates specs that do not mandate the use of `writing-plans` for plan creation, so the plan step can be skipped entirely. |
| Root Cause / Motivation | `writing-plans/tasks/create/create-and-validate.md` lines 34-59 hardcode the full 14-item checklist with dispatch routing annotations that exactly mirror the `implementation-pipeline/SKILL.md` dispatch routing table. Separately, `spec-creation/tasks/write.md` does not instruct the spec to mandate `writing-plans` in its generated spec content, so nothing in the spec document requires the orchestrator to create a plan. |
| Approach Chosen | Replace the embedded template with a reference to `implementation-pipeline` as the single source of truth; add a mandate in the spec writer's generated spec content requiring `writing-plans` for plan creation after approval. |
| Alternatives Considered & Why Discarded | (1) Auto-generate from pipeline state machine — overengineered for current scope. (2) Leave as-is — drift will accumulate silently and plans will continue to be optional. |
| Key Design Decisions | The plan's per-phase checklist should contain pipeline step *labels* and *dispatch mode* only (routing metadata) — all execution targets live solely in `implementation-pipeline`. The spec writer's task file must inject a prose mandate into the generated spec body, not just add a step in its own procedure. |

## Problem

### Duplicate routing table

The plan writer (`writing-plans/tasks/create/create-and-validate.md`) mandates a 14-item checklist template at lines 34-59 with the header: *"Each phase MUST use the following template. No prose alternative. No deviations."*

```markdown
- [ ] 1. SC-COHERENCE-GATE — orchestrator routes to pre-analysis: ...
- [ ] 2. PRE-RED-BASELINE — orchestrator routes to exploration: ...
...
- [ ] 14. EXEC-SUMMARY — orchestrator inline: ...
```

This is a **verbatim duplicate** of the dispatch routing table in `implementation-pipeline/SKILL.md`. Two sources of truth for the same 14-step pipeline.

The lone cross-reference (`plan-structure.md:297` — "Emit key constraints section referencing implementation-pipeline-* rules") only references the *rules*, not the *routing table structure*.

**Drift risk:** If anyone adds/removes/renames a step in `implementation-pipeline`, only one of the two sources will get updated.

### Missing plan-creation mandate in specs

The spec writer (`spec-creation/tasks/write.md`) does not include any language in the generated spec document that requires the orchestrator to create a plan using `writing-plans` after spec approval. This means:

1. A spec can be approved without any plan ever being created
2. The orchestrator has no contractual obligation visible in the spec itself to follow `writing-plans → executing-plans → implementation-pipeline`
3. There is nothing in `.issues/{N}/spec.md` that says "After approval, invoke `writing-plans` to generate `.issues/{N}/spec-artifacts/plan.md`"

## Scope

**In scope:**
- Replace the embedded 14-item checklist in `writing-plans/tasks/create/create-and-validate.md` lines 34-59 with a reference to `implementation-pipeline`'s dispatch routing table as single source of truth
- The per-phase checklist in plans should contain only: step labels, dispatch mode indicators (inline vs sub-agent), and a reference to `implementation-pipeline/SKILL.md` for the canonical routing table
- Add step to `writing-plans/tasks/create/create-and-validate.md` validation (Step 9) to verify the canonical pipeline step labels exist in `implementation-pipeline/SKILL.md`
- Add mandate to `spec-creation/tasks/write.md` such that the **generated spec body** includes a prose section or checklist item requiring that `writing-plans` be used to create an implementation plan after spec approval
- The generated spec body MUST contain the full local relative path from project root to the plan: `.issues/{N}/spec-artifacts/plan.md`

**Out of scope:**
- No structural changes to `implementation-pipeline/SKILL.md` itself
- No changes to `plan` or `solve` skill flows
- No changes to behavioral enforcement tests for either skill
- No retroactive modification of existing specs

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `writing-plans/tasks/create/create-and-validate.md` no longer contains an embedded 14-item checklist template. The template is replaced with a reference to `implementation-pipeline/SKILL.md` §Dispatch Routing Table as the canonical source. | `string` | `grep` for "Each phase MUST use the following template" — must return no matches in the file |
| SC-2 | The per-phase checklist in plan.md references pipeline steps by label only, with dispatch mode annotation, referencing `implementation-pipeline` for execution targets. | `string` | `grep` for "implementation-pipeline" in the phase checklist section of `create-and-validate.md` |
| SC-3 | Step 9 validation in `create-and-validate.md` includes a check that all referenced pipeline step labels exist in `implementation-pipeline/SKILL.md`'s routing table. | `string` | `grep` for "implementation-pipeline/SKILL.md" in Step 9 section of `create-and-validate.md` |
| SC-4 | `spec-creation/tasks/write.md` includes a step that instructs the generated spec body to contain a mandate that `writing-plans` MUST be invoked to create `.issues/{N}/spec-artifacts/plan.md` (the full local relative path from project root) after spec approval. This is in the spec content (i.e., what the spec writer outputs), not just the task procedure. | `string` | `grep` for "writing-plans" in `spec-creation/tasks/write.md` |
| SC-5 | A spec generated by the updated spec writer, when examined, contains language requiring plan creation via `writing-plans` with the path `.issues/{N}/spec-artifacts/plan.md` before implementation begins. | `behavioral` | Generate a minimal spec using the updated spec writer; `grep` the output for `writing-plans` and `spec-artifacts/plan.md` |
| SC-6 | The `plan plan` and `solve check` Steps 9 validation remains intact — only the embedded checklist content is replaced, not the validation procedure. | `structural` | `ls` confirms Step 9 still contains `solve check` and `plan plan` references |

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` | Replace lines 34-59 template with reference-based format; add Step 9 validation for canonical pipeline labels |
| `.opencode/skills/spec-creation/tasks/write.md` | Add step instructing the generated spec body to mandate `writing-plans` for plan creation after approval, with path `.issues/{N}/spec-artifacts/plan.md` |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Reference-based template is too abstract for plan readers | Low | Medium | Include example of what a filled-out phase checklist looks like (as a comment or secondary example) |
| Existing plans with the old embedded checklist become inconsistent | Medium | Low | No change to existing plan artifacts — only the template is modified; future plans use new format |
| `implementation-pipeline` routing table is referenced by relative path | Low | Low | Use `implementation-pipeline/SKILL.md` relative path, verified by Step 9 cross-reference check |
| Spec writer plan-creation mandate is too early (before approval-gate) | Medium | Low | The mandate says "after spec is approved" — the spec document cannot mandate execution order from the orchestrator, only that `writing-plans` MUST be used when the plan phase begins |

## Edge Cases

- **Single-task no-phase plan**: If a plan has no phases, the checklist template does not apply. The reference-format change only affects phases that use the 14-step pipeline.
- **Non-pipeline plans**: Plans that don't use the implementation pipeline (e.g., simple ad-hoc tasks) are unaffected.
- **Backward compatibility**: Existing plans in `.issues/*/spec-artifacts/plan.md` are not retroactively modified. The reference is for future plan generation only.
- **Existing specs**: Existing spec bodies without the `writing-plans` mandate are not retroactively updated. Only new specs generated by the updated `write.md` will contain the mandate.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep` for "implementation-pipeline" in `writing-plans/` | Identify existing cross-references |
| MCP search | `srclight_search_symbols` for template patterns | Verify checklist structure origins |
| Direct source search | Read `implementation-pipeline/SKILL.md` dispatch routing table | Confirm canonical source structure |
| Direct source search | Read `writing-plans/tasks/create/create-and-validate.md` lines 34-59 | Confirm embedded duplicate exists |
| Direct source search | Read `spec-creation/tasks/write.md` | Confirm spec body does not mandate `writing-plans` |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The implementation plan will be created in `.issues/{N}/spec-artifacts/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 OpenCode (deepseek-v4-flash)