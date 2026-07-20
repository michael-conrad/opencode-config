STATUS: 0.1 (DRAFT — awaiting brainstorming)

## Problem

The `divide-and-conquer` skill's `assemble-work` task is dispatched as a **single sub-agent** that executes the entire implementation pipeline internally. This violates the core principle that the main orchestrator must dispatch each pipeline step as a clean-room sub-agent serially, collecting result contracts at each gate.

**Root cause:** `skill({name: "divide-and-conquer"})` → `task(subagent_type="general", prompt: "execute assemble-work task from divide-and-conquer")` hands the entire pipeline to one sub-agent. That sub-agent then makes all routing decisions, performs all verification checks, and owns all gate evaluations — the main agent becomes a pass-through with no oversight.

**Related issues:** #107 (Universal Clean-Room Dispatch) established the clean-room mandate but did not restructure the dispatch architecture to enforce per-step isolation. The `assemble-work` task currently runs RED → completeness gate → VbC → audit → GREEN (repeat) as internal steps within a single sub-agent context window — no orchestrator gate between them.

## Scope

**Covers:**
- Redefining the orchestration skill (new name: `serial-orchestrator` or `pipeline-orchestrator` — naming to be resolved) as a pure orchestrator routing table
- The 11-step serial pipeline with explicit per-step gate checkpoints
- Cross-validation step (VbC evidence vs audit findings)
- SC coherence gate before RED dispatch
- Checkpoint commit after green doublecheck passes
- Structural lint/typecheck between green and VbC
- Remediation scope decision protocol at each gate FAIL (implementation-only, plan+implementation, or spec+plan+implementation)
- Renaming the skill away from "divide-and-conquer" to accurately reflect serial orchestration

**Does NOT cover:**
- Changes to individual skill contents (verification-before-completion, adversarial-audit, git-workflow, completion-core) — those are pipeline stage consumers, not the pipeline itself
- The gate dependency tree (addressed by michael-conrad/.opencode#248)
- Shell composition / Unix pipeline model (addressed by #37)
- Agent card changes (addressed by michael-conrad/.opencode#397)

## The 11-Step Pipeline

```
ORCHESTRATOR (main agent — pure router)
  │
  ├─ [0] SC coherence gate
  │     Task: Verify SCs are testable, evidence types correct, no conflicts
  │     Skill: pre-analysis + coherence-maintenance
  │     Output: coherence PASS/FAIL
  │     Gate: FAIL → spec revision required (spec+plan+implementation scope)
  │
  ├─ [1] pre-red regression baseline
  │     Task: Run behavioral test suite --changed, capture before state
  │     Skill: general sub-agent
  │     Output: baseline.{log,json}
  │     Gate: HALT — baseline broken before changes
  │
  ├─ [2] RED
  │     Task: Write behavioral enforcement test that MUST FAIL
  │     Skill: general sub-agent (1)
  │     Output: RED test script, failure evidence
  │
  ├─ [3] RED doublecheck
  │     Task: Verify RED failure is legitimate (not broken harness)
  │     Skill: general sub-agent (2) — clean-room, different from RED
  │     Output: PASS/FAIL with tool-call evidence
  │     Gate FAIL → re-task [2] RED (implementation scope)
  │
  ├─ [4] GREEN
  │     Task: Implement change to make RED test pass
  │     Skill: general sub-agent (3)
  │     Output: implementation files, GREEN pass evidence
  │
  ├─ [4a] checkpoint commit
  │     Task: Commit RED test + GREEN implementation together
  │     Skill: git-workflow --task implementation
  │     Output: commit SHA
  │
  ├─ [4b] structural checks
  │     Task: Run lint + typecheck on GREEN output
  │     Skill: bash (project-local tools)
  │     Output: lint/typecheck PASS/FAIL
  │     Gate FAIL → re-task [4] GREEN (implementation scope)
  │
  ├─ [5] GREEN doublecheck
  │     Task: Verify RED test now passes after GREEN
  │     Skill: general sub-agent (4) — clean-room, different from GREEN
  │     Output: PASS/FAIL with evidence
  │     Gate FAIL → re-task [4] GREEN (implementation scope)
  │
  ├─ [6] GREEN VbC
  │     Task: Verify ALL success criteria, not just RED test
  │     Skill: verification-before-completion (clean-room)
  │     Output: VbC evidence per SC, overall PASS/FAIL
  │     Gate FAIL → orchestrator determines scope (impl/plan+impl/spec+plan+impl)
  │
  ├─ [7] cross-validate
  │     Task: Cross-check VbC evidence against audit findings for coverage gaps
  │     Skill: general sub-agent — receives VbC output + audit findings
  │     Output: cross-validation PASS/FAIL with gap report
  │     Gate FAIL → orchestrator determines scope
  │
  ├─ [8] adversarial audit
  │     Task: Dual cross-family adversarial audit of implementation
  │     Skill: adversarial-audit (2 auditor sub-agents, cross-family)
  │     Output: auditor consensus PASS/FAIL with findings
  │     Gate FAIL → orchestrator determines scope
  │
  ├─ [9] regression check
  │     Task: Re-run baseline suite, compare against step [1]
  │     Skill: general sub-agent
  │     Output: regression PASS/FAIL with diff
  │     Gate FAIL → remediate regression, restart from [4] (implementation scope)
  │
  ├─ [10] review prep
  │     Task: Squash, push, generate compare URL
  │     Skill: git-workflow --task review-prep
  │     Output: pushed branch, compare URL
  │
  └─ [11] exec summary + URL + byline
        Task: Post executive summary, PR URL, AI byline
        Skill: completion-core
        Output: completion artifact
        HALT with structured output
```

### Remediation Scope Decision

When a gate at steps [3], [5], [6], [7], or [8] produces FAIL, the orchestrator tasks a `remediation-scope` sub-agent that receives the failure evidence and determines:

| Scope | When | Action |
|-------|------|--------|
| **implementation only** | Failure is in GREEN output (wrong code, missing feature) | Re-task step [4] with failure evidence |
| **plan + implementation** | Failure reveals plan gap (SCs incomplete, wrong phases) | Revise plan, re-task from step [2] or [4] |
| **spec + plan + implementation** | Failure reveals spec gap (requirement missed, scope wrong) | Revise spec + plan, re-task from step [0] |

The orchestrator never makes this determination inline — it tasks a clean-room sub-agent that receives only the failure evidence and returns a scope recommendation.

### Verification Layers

| Layer | Step | What | Agent | Clean-room from Producer? |
|-------|------|------|-------|--------------------------|
| SC coherence | 0 | SC testability + evidence types | pre-analysis | N/A (pre-implementation) |
| RED doublecheck | 3 | Is RED failure legitimate? | general (B) | Yes — different from RED writer |
| Structural | 4b | Lint/typecheck | bash | N/A (deterministic) |
| GREEN doublecheck | 5 | Does RED test pass now? | general (D) | Yes — different from GREEN writer |
| VbC | 6 | All SCs met? | verification-before-completion | Yes — different from RED+GREEN |
| Cross-validate | 7 | VbC vs audit alignment | general | Yes — receives only outputs |
| Adversarial audit | 8 | Dual cross-family quality audit | adversarial-audit | Yes — 2 auditors, no producer context |
| Regression | 9 | Baseline unchanged | general | Yes — clean-room |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/divide-and-conquer/SKILL.md` | **Renamed** to new skill name; SKILL.md rewritten as pure orchestrator routing table with 11-step dispatch table |
| `.opencode/skills/divide-and-conquer/tasks/assemble-work.md` | **Renamed** to new task name; rewritten as the 11-step pipeline specification with per-step gate conditions, remediation scope decision protocol, and result contract formats |
| `.opencode/skills/divide-and-conquer/enforcement/*` | Moved/copied to new skill directory |
| `.opencode/tests/behaviors/*` | Cross-reference updates for renamed skill |
| `.opencode/tests/test-enforcement.sh` | Cross-reference updates for renamed skill |
| `.opencode/guidelines/000-critical-rules.md` | Update divide-and-conquer references; add orchestrator-serial violation rule |
| `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md` | Update divide-and-conquer reference to new skill name |
| `.opencode/skills/adversarial-audit/SKILL.md` | Update divide-and-conquer reference |
| `.opencode/skills/approval-gate/SKILL.md` | Update divide-and-conquer reference |

## Implementation Plan

### Phase 1: Structural rename + new SKILL.md
- Rename skill directory from `divide-and-conquer` to new name
- Rewrite SKILL.md as orchestrator routing table (no more "dispatch assemble-work as one sub-agent")
- Rewrite the task file as the 11-step pipeline specification

### Phase 2: Cross-reference update
- Update all cross-references across guidelines, skills, and enforcement tests

### Phase 3: Remediation scope protocol
- Add remediation-scope sub-agent task to the new skill
- Wire remediation scope decision into each gate FAIL handler

### Phase 4: Behavioral tests
- RED test: main agent dispatches 11 steps serially (not one sub-agent for everything)
- RED test: orchestrator tasks remediation-scope on gate FAIL
- GREEN: behavioral plus content-verification tests

## Success Criteria

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | New skill SKILL.md contains 11-step dispatch table as its primary routing structure | structural | File exists, contains `pipeline:` with 11 named steps |
| SC-2 | Main agent dispatches each of the 11 steps as separate `task()` calls — no single sub-agent owns the pipeline | behavioral | `opencode-cli run` → stderr shows 11+ task() dispatches in sequence |
| SC-3 | RED and GREEN use different clean-room sub-agents (steps 3 and 5) | behavioral | `opencode-cli run` → stderr shows different sub-agent_type or task_id for RED vs RED-doublecheck |
| SC-4 | VbC is performed by verification-before-completion skill, not by the GREEN implementer (step 6) | behavioral | `opencode-cli run` → stderr shows verification-before-completion skill invocation |
| SC-5 | Cross-validation step checks VbC evidence against audit findings (step 7) | behavioral | `opencode-cli run` → stderr shows cross-validate dispatch after audit |
| SC-6 | Remediation scope sub-agent determines impl/plan+impl/spec+plan+impl on gate FAIL | behavioral | `opencode-cli run` → stderr shows remediation-scope dispatch + scope classification output |
| SC-7 | Checkpoint commit after GREEN doublecheck passes (step 4a) | behavioral | `opencode-cli run` → stderr shows git-workflow commit after green-doublecheck PASS |
| SC-8 | Structural lint/typecheck runs between GREEN and VbC (step 4b) | behavioral | `opencode-cli run` → stderr shows ruff/pyright invocation between green-doublecheck and VbC |
| SC-9 | Regression check compares against baseline from step 1 | behavioral | `opencode-cli run` → stderr shows baseline comparison after audit PASS |
| SC-10 | SC coherence gate runs before RED dispatch (step 0) | behavioral | `opencode-cli run` → stderr shows coherence check before RED task() |
| SC-11 | All cross-references updated from divide-and-conquer to new skill name | string | `grep -r "divide-and-conquer"` returns 0 matches in non-legacy files |
| SC-12 | Behavioral tests exist for serial dispatch (SC-2), remediation scope (SC-6), and cross-validate (SC-5) | structural | Test files exist in `.opencode/tests/behaviors/` |

## Related Issues

| Issue | Repo | Relevance |
|-------|------|-----------|
| #107 | michael-conrad/.opencode | Universal Clean-Room Dispatch — foundation for clean-room isolation |
| #694 | michael-conrad/.opencode | Pipeline Gate Restructuring — added coherence and test-quality gates to assemble-work |
| #37 | michael-conrad/opencode-config | Shell Composition investigation — 5 orchestration models compared |
| #397 | michael-conrad/.opencode | Intelligent Audit Dispatch — audit phase identity, clean room protocol |

## Open Questions (to be resolved in brainstorming)

1. **Skill name:** What replaces "divide-and-conquer"? Candidates: `serial-orchestrator`, `pipeline-orchestrator`, `orchestration-engine`, `execution-pipeline`
2. **Step order finalization:** Is cross-validate (step 7) before or after adversarial audit (step 8)? Current ordering has cross-validate after VbC and before audit, but cross-validate checks VbC against *existing* audit findings — which requires audit to have run first. The ordering may need to be: VbC → audit → cross-validate.
3. **Checkpoint commit granularity:** One commit per item (RED+GREEN together) or one batch commit after all items complete?

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)