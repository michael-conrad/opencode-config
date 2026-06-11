# [SPEC] Pipeline-readiness gate in spec-creation + mandatory checklist generation in writing-plans

## Summary

Two upstream skills lack structural awareness of the implementation pipeline: `spec-creation` does not verify SC fitness for pipeline execution (atomicity, dependency ordering, single concern, phase dependencies), and `writing-plans` does not generate mandatory implementation checklists. This spec adds a pipeline-readiness gate task to `spec-creation` and a hard-gate + checklist generation step to `writing-plans`.

## All-or-Nothing Gate

All SC-1 through SC-13 must PASS for this spec to be complete.

## Phase Dependencies

| Phase | Name | Depends On |
|-------|------|------------|
| 1 | Create pipeline-readiness gate in spec-creation | — |
| 2 | Add hard-gate check in writing-plans | Phase 1 |
| 3 | Mandatory implementation checklist generation | Phase 1 |
| 4 | Update skill SKILL.md files | Phase 1, Phase 2, Phase 3 |

## Success Criteria

| ID | Criterion | Evidence Type | Depends On | Verification Method |
|----|-----------|---------------|------------|---------------------|
| SC-1 | Pipeline-readiness gate task file exists with PR-1 through PR-4 | `structural` | — | File existence |
| SC-2 | Gate produces `sc-pipeline-readiness.yaml` with PASS/FAIL | `behavioral` | — | Run gate on spec, verify artifact |
| SC-3 | PR-1 correctly flags bundled SCs | `behavioral` | SC-1 | Test with atomic/non-atomic SCs |
| SC-4 | PR-2 verified by `solve prove` | `behavioral` | SC-1 | Run gate, verify solve prove artifacts |
| SC-5 | PR-4 verified by `solve prove` | `behavioral` | SC-1 | Run gate, verify phase ordering |
| SC-6 | SKILL.md updated with pipeline-readiness-gate task entry | `string` | SC-1 | grep for task |
| SC-7 | Plan-structure Step 0.5 checks readiness artifact | `string` | SC-1 | grep for step |
| SC-8 | Missing/FAIL readiness artifact halts plan creation | `behavioral` | SC-1 | `opencode-cli run` prompt |
| SC-9 | Plan-structure Step 6 generates implementation-checklist.md | `string` | SC-1 | grep for generation step |
| SC-10 | Checklist includes lifecycle, tag verification, re-validation | `string` | SC-9 | grep for patterns |
| SC-11 | Checklist covers all SCs from traceability table | `behavioral` | SC-9 | Generate from known plan, verify |
| SC-12 | Both SKILL.md files have symbolic rules | `string` | SC-1, SC-7, SC-9 | grep for rule IDs |
| SC-13 | Spec finalization without gate triggers HALT | `behavioral` | SC-12 | `opencode-cli run` |

## Files Changed

- `.opencode/skills/spec-creation/tasks/pipeline-readiness-gate.md` — created
- `.opencode/skills/spec-creation/SKILL.md` — modified
- `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — modified
- `.opencode/skills/writing-plans/SKILL.md` — modified

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)