> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2302/

## Problem
When a spec is revised, the existing plan (if one exists) is not automatically regenerated to match the revised spec. This causes a coherence-gate failure during implementation: the plan's SC coverage no longer matches the spec's SC set, and the orchestrator halts prematurely instead of continuing the pipeline.

## Scope
- Regenerate the linked plan whenever a spec revision occurs, so plan SC coverage always matches the revised spec's SC set.
- Make plan regeneration an automatic consequence of spec revision, not a manual corrective step.
- Ensure `for_pr` scope spec-revision + plan-regeneration does not halt the pipeline before `pr_created`.

**Out of scope:**
- The specific implementation of the plan-regeneration trigger mechanism (to be determined in the fix spec).
- Changes to the authorization scope model itself.

## Approach
Introduce the missing spec-revision → plan-regeneration linkage in the spec-creation pipeline. When a spec revision is detected, the pipeline checks for an existing linked plan and regenerates it against the revised spec's SC set before any downstream gate runs. This makes the plan always current relative to the spec, so the coherence gate passes and the orchestrator can continue the pipeline to `pr_created` under `for_pr` scope instead of halting.

## Root Cause
The spec-revision → plan-regeneration linkage is missing. When a spec is revised (e.g., adding new SCs), the linked plan is not regenerated. The plan remains stale relative to the revised spec. During implementation, the coherence gate detects the plan/spec SC-count mismatch and reports BLOCKED. Under a `for_pr` authorization scope (halt_at: pr_created), the orchestrator halts at the plan-regeneration step instead of continuing the pipeline to PR creation — a premature halt that forces re-authorization.

## Observed Defect
Issue #2116: the spec was revised from 10 SCs to 14 SCs (adding Ceremony SC-11, Coverage SC-12, and their behavioral tests SC-13, SC-14). The existing plan still covered only 10 SCs. The coherence gate failed, and the orchestrator halted after regenerating the plan instead of continuing the `for_pr` pipeline to `pr_created`.

## Affected Files
- .opencode/skills/spec-creation/ (spec revision pipeline)
- .opencode/skills/writing-plans/ (plan regeneration linkage)
- .opencode/skills/approval-gate/ (scope handling on spec revision)

## Success Criteria
- SC-1: When a spec is revised, the linked plan (if it exists) is regenerated to match the revised spec's SC set.
- SC-2: Plan regeneration is an automatic consequence of spec revision, not a manual corrective step.
- SC-3: Under `for_pr` scope, spec revision + plan regeneration does not cause a premature halt before `pr_created`.

## Impact
- **Risk 1: Plan/spec divergence recurs.** Mitigation: enforce regeneration as an automatic consequence of revision rather than a manual step.
- **Risk 2: Premature halt forces re-authorization.** Mitigation: SC-3 gates the scope-continuation behavior explicitly.
- **Risk 3: Regeneration overwrites intentional plan structure.** Mitigation: regenerate against the revised spec's SC set while preserving existing plan phases where still valid.

- **Key dependencies:** spec-creation revision pipeline, writing-plans regeneration, approval-gate scope handling.
- **Call to action:** Approve this fix spec to unblock #2116 and prevent premature halts under `for_pr` scope.

---

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created


