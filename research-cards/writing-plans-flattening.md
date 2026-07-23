---
research_question: "What do live docs and research say about writing robust plans for AI agents, and how does it inform the writing-plans flattening?"
confidence: 0.9
status: active
tags:
  - writing-plans
  - plan-architecture
  - flat-architecture
  - plan-validation
  - task-decomposition
  - cross-reference-inventory
  - contract-consolidation
created: 2026-07-23
last_updated: 2026-07-23
sources:
  - url: "https://docs.bswen.com/blog/2026-03-18-writing-plans/"
    title: "How to Write Implementation Plans That AI Agents Can Execute Reliably"
    accessed: 2026-07-23
  - url: "https://www.xbstack.com/en/ai/ai-agent-planning/"
    title: "AI Agent Planning in Practice: Task Decomposition, Plan Validation, Replanning"
    accessed: 2026-07-23
  - url: "https://arxiv.org/html/2503.09572v2"
    title: "Plan-and-Act: Improving Planning of Agents for Long-Horizon Tasks"
    accessed: 2026-07-23
  - url: "https://github.com/microsoft/ai-agents-for-beginners/blob/main/07-planning-design/README.md"
    title: "Microsoft AI Agents for Beginners - Planning Design"
    accessed: 2026-07-23
  - url: "https://arxiv.org/abs/2402.02716"
    title: "Understanding the planning of LLM agents: A survey"
    accessed: 2026-07-23
  - url: "https://arxiv.org/abs/2603.22455"
    title: "SkillRouter: Skill Routing for LLM Agents at Scale"
    accessed: 2026-07-23
  - url: "https://github.com/PatrickRuddiman/Dispatch/blob/main/docs/planning-and-dispatch/executor.md"
    title: "Dispatch Executor Agent — plan passthrough pattern"
    accessed: 2026-07-23
  - url: "https://byaiteam.com/blog/2025/12/09/ai-agent-planning-react-vs-plan-and-execute-for-reliability/"
    title: "AI Agent Planning: ReAct vs Plan and Execute for Reliability"
    accessed: 2026-07-23
---

## Summary

Research from 5 live sources on AI agent planning reveals consistent patterns for plan structure, validation, and execution. Cross-reference inventory found ~200+ references to writing-plans across ~60+ files. 22 contract templates and 18 task files analyzed for consolidation. The flat architecture replaces 3 SKILL.md + 19 task files + 22 contracts with 1 SKILL.md + 6 task files + ~12 contracts.

## Findings

### 1. Plans Must Be Structured, Not Prose

The survey (arXiv 2402.02716) taxonomizes LLM agent planning into Task Decomposition, Plan Selection, External Module, Reflection, and Memory. The XBSTACK article shows strongly typed steps with Pydantic models — every field has a consumer, every field is machine-readable.

**Implication for flattening:** The 22 separate YAML contract templates serve a valid purpose (context isolation for sub-agents) but can be consolidated from per-task-file pairs to per-pipeline-stage pairs. The flat architecture should define typed step structures within the create task file for the *plan artifact*, while keeping contract templates as separate files for *pipeline stage contracts*.

### 2. Zero-Context Assumption

BSWEN article (directly references Superpowers writing-plans skill): "Write comprehensive implementation plans assuming the engineer has ZERO CONTEXT for your codebase and QUESTIONABLE TASTE."

Each step = ONE ACTION (2-5 minutes), exact file paths, complete code, specific commands with expected output.

**Implication for flattening:** The current 18 task files encode granularity in the *task structure* but don't enforce it in the *plan artifact*. The create task file should enforce step granularity as a structural constraint, not leave it to agent judgment.

### 3. Validation Before Execution

XBSTACK: three mandatory pre-execution checks:
- Parameter completeness — every step has all required inputs
- Permission/risk blocking — high-risk steps require HITL
- Tool availability — referenced tool actually exists

**Implication for flattening:** The current audit-fidelity and audit-concern are separate files requiring explicit dispatch. A flat architecture makes validation an inherent pipeline stage (validate.md) that runs automatically after create.

### 4. Dynamic Replanning & Checkpoints

Plan-and-Act (arXiv 2503.09572): separates Planner from Executor. Planner generates structured plans; Executor translates to actions. On failure, Planner replans from last checkpoint.

**Implication for flattening:** The current revisit.md and update.md are ad-hoc. The flat architecture defines a structured revise → solve → validate loop.

### 5. Scope Boundaries

BSWEN: if a spec covers multiple independent subsystems, break it into separate plans. The current writing-plans doesn't enforce this.

**Implication for flattening:** The analyze task should include a scope boundary check as an entry criterion.

### 6. Plan Representation Formats

HTN (Hierarchical Task Networks) and STRIPS are the dominant plan representation formats. HTN decomposes tasks into subtask hierarchies; STRIPS uses state-based action models.

**Implication for flattening:** The current writing-plans uses neither — plans are unstructured markdown. The create task should define a structured plan format (phases with dependency DAG, steps with typed fields).

### 7. Execution Strategy Selection

BSWEN: two execution options — subagent-driven (recommended, fresh subagent per task, better isolation) vs inline execution (batch with checkpoints, faster for simple plans).

**Implication for flattening:** The completion task should include execution strategy selection as an output, not leave it implicit.

### 8. Skill Routing at Scale (SkillRouter, arXiv 2603.22455)

Skills are modular building blocks packaging task-specific procedures, tool affordances, and execution guidance. The skill-routing problem: given a user task, identify relevant skills before downstream planning or execution. At scale (80K+ candidate skills), hiding the skill body causes 37-44 point drop in routing accuracy.

**Implication for flattening:** The routing-table plan artifact pre-resolves the skill routing problem. By the time the plan reaches the executor, the skill+task mapping is already determined. The executor doesn't need to route — it just dispatches what the plan specifies. This is the key validation for the routing-table approach: the plan writer does the routing once, the executor dispatches without routing overhead.

### 9. Plan Passthrough Pattern (Dispatch Executor)

The executor receives a plan as a string and passes it directly to the dispatcher. The executor does NOT generate or validate plans — it only executes them. A non-null plan triggers the planned prompt path; a null plan triggers the simple prompt path.

**Implication for flattening:** This validates the clean separation between plan writer and executor. The plan writer produces the plan artifact. The executor consumes it without modification. The plan is a passive data structure — it doesn't contain execution logic, only routing references.

### 10. Plan-and-Execute Architecture (ReAct vs Plan-and-Execute)

Plan-and-Execute separates "what to do" from "how to do it." Plans can be reviewed, approved by a human, cached for reuse, or audited for compliance. The execution engine monitors progress, manages state, and handles contingencies. If a step fails, the executor can trigger retry, fallback, or replanning.

**Implication for flattening:** The routing-table plan artifact is a pure Plan-and-Execute pattern. The plan says "what" (skill+task references, phase DAG, SC mappings). The implementation pipeline determines "how" (RED/GREEN cycle, clean-room dispatch, verification gates). Changes to the "how" don't require plan regeneration — the plan is resilient to pipeline evolution.

---

## Cross-Reference Inventory

### Pattern: `writing-plans` (bare)

~200+ matches across ~60+ files. Key categories:

| Category | File Count | Examples |
|---|---|---|
| SKILL.md (self) | 3 | writing-plans, writing-plans-creation, writing-plans-holistic |
| Caller SKILL.md | 5 | approval-gate, approval-gate-scope, brainstorming, completeness-gate, verification-enforcement |
| Caller task files | ~20 | approval-gate-scope/tasks/*, audit/tasks/*, brainstorming/tasks/*, executing-plans/tasks/*, implementation-pipeline/tasks/*, issue-operations-*/tasks/* |
| Guidelines | 3 | 000-critical-rules.md, 010-approval-gate.md, 060-tool-usage.md |
| Reference | 2 | holistic-dimensions.yaml, registry.yaml |
| Tests | 2 | dispatch-boundary-writing-plans.sh, verify-auth-step5d.sh |
| Dispatch table | 1 | dispatch-table.yaml |
| .issues/ specs/plans | ~50+ | Various issue files referencing writing-plans as downstream dispatch |
| CHANGELOG | 3 | Historical entries |

### Pattern: `writing-plans-creation`

~20 matches across ~8 files. All in sub-skill SKILL.md files and their task files. No external callers reference `writing-plans-creation` directly — they all go through the `writing-plans` dispatcher.

### Pattern: `writing-plans-holistic`

~7 matches across ~3 files. Same pattern — only referenced through the `writing-plans` dispatcher.

### Pattern: Dispatch Strings (13 total)

**Critical finding:** All 13 dispatch strings exist ONLY in `writing-plans/SKILL.md` Invocation table (lines 40-52). No other file in the entire repository uses any of these strings. They are defined but never consumed.

This means the new flat dispatch strings (`"execute analyze from writing-plans"`, `"execute create from writing-plans"`, etc.) only need to be updated in the single `writing-plans/SKILL.md` file. No external callers reference the old dispatch strings.

### External Callers That Reference `writing-plans` by Name

These callers use `skill({name: "writing-plans"})` or `writing-plans --task <name>` patterns and will need dispatch string updates:

| Caller | File | Current Pattern | New Pattern |
|---|---|---|---|
| approval-gate-scope | auto-dispatch-table.md | `writing-plans --task create` | `skill({name: "writing-plans"})` → `task("execute create from writing-plans")` |
| approval-gate-scope | auto-dispatch.md | `writing-plans --task create` | same |
| approval-gate-scope | spec-to-plan-cascade.md | `writing-plans --task create`, `writing-plans --task update` | same |
| approval-gate-scope | verify-plan-pipeline.md | `writing-plans 22-step pipeline` | `writing-plans pipeline` (reference only) |
| brainstorming | completion.md | `writing-plans` (Path B) | same |
| issue-operations-comments | comment.md | `writing-plans --task update` | `skill({name: "writing-plans"})` → `task("execute revise from writing-plans")` |
| plan-creation-pipeline | SKILL.md | `writing-plans --task create` | same |
| audit | plan-fidelity-*.md | `writing-plans` skill reference | same (reference only) |
| spec-creation | SKILL.md | `writing-plans` (downstream consumer) | same (reference only) |
| 000-critical-rules.md | guideline | `writing-plans/tasks/create.md` | `writing-plans/tasks/create.md` (reference only) |
| 010-approval-gate.md | guideline | `writing-plans`, `writing-plans --task update` | same |
| holistic-dimensions.yaml | reference | `writing-plans/tasks/create.md`, `writing-plans/tasks/update.md`, `writing-plans/tasks/completion.md` | `writing-plans/tasks/create.md`, `writing-plans/tasks/revise.md`, `writing-plans/tasks/completion.md` |
| dispatch-table.yaml | dispatch | `skill: "writing-plans"` | same |
| dispatch-boundary-writing-plans.sh | test | `skill("writing-plans")` | same (test verifies dispatch boundary, not specific task) |

**Total external files requiring dispatch string updates:** ~10 files (auto-dispatch-table.md, auto-dispatch.md, spec-to-plan-cascade.md, verify-plan-pipeline.md, completion.md, comment.md, plan-creation-pipeline/SKILL.md, holistic-dimensions.yaml, 010-approval-gate.md, 000-critical-rules.md).

---

## Contract Template Consolidation

### Current: 22 contracts (11 input/output pairs)

| Current Contract | Task | New Contract | New Task |
|---|---|---|---|
| create-input-template.yaml | create.md | analyze-input-template.yaml | analyze.md |
| create-output-template.yaml | create.md | analyze-output-template.yaml | analyze.md |
| write-input-template.yaml | write.md | create-input-template.yaml | create.md |
| write-output-template.yaml | write.md | create-output-template.yaml | create.md |
| solve-input-template.yaml | solve.md | solve-input-template.yaml | solve.md |
| solve-output-template.yaml | solve.md | solve-output-template.yaml | solve.md |
| structure-input-template.yaml | structure.md | — | (merged into create) |
| structure-output-template.yaml | structure.md | — | (merged into create) |
| validate-input-template.yaml | validate.md | validate-input-template.yaml | validate.md |
| validate-output-template.yaml | validate.md | validate-output-template.yaml | validate.md |
| audit-fidelity-input-template.yaml | audit-fidelity.md | — | (merged into validate) |
| audit-fidelity-output-template.yaml | audit-fidelity.md | — | (merged into validate) |
| audit-concern-input-template.yaml | audit-concern.md | — | (merged into validate) |
| audit-concern-output-template.yaml | audit-concern.md | — | (merged into validate) |
| research-input-template.yaml | research.md | — | (merged into analyze) |
| research-output-template.yaml | research.md | — | (merged into analyze) |
| readiness-input-template.yaml | readiness.md | — | (merged into analyze) |
| readiness-output-template.yaml | readiness.md | — | (merged into analyze) |
| revisit-input-template.yaml | revisit.md | revise-input-template.yaml | revise.md |
| revisit-output-template.yaml | revisit.md | revise-output-template.yaml | revise.md |
| completion-input-template.yaml | completion.md | completion-input-template.yaml | completion.md |
| completion-output-template.yaml | completion.md | completion-output-template.yaml | completion.md |

### Proposed: 12 contracts (6 input/output pairs)

| Contract | Task | Consolidates |
|---|---|---|
| analyze-input-template.yaml | analyze.md | analyze-input, research-input, readiness-input |
| analyze-output-template.yaml | analyze.md | analyze-output, research-output, readiness-output |
| create-input-template.yaml | create.md | create-input, write-input, structure-input |
| create-output-template.yaml | create.md | create-output, write-output, structure-output |
| solve-input-template.yaml | solve.md | solve-input (unchanged) |
| solve-output-template.yaml | solve.md | solve-output (unchanged) |
| validate-input-template.yaml | validate.md | validate-input, audit-fidelity-input, audit-concern-input |
| validate-output-template.yaml | validate.md | validate-output, audit-fidelity-output, audit-concern-output |
| revise-input-template.yaml | revise.md | revisit-input (renamed) |
| revise-output-template.yaml | revise.md | revisit-output (renamed) |
| completion-input-template.yaml | completion.md | completion-input (unchanged) |
| completion-output-template.yaml | completion.md | completion-output (unchanged) |

---

## Task File Scope Boundaries

### Current: 18 task files + 1 holistic check

| Current Task | Current Purpose | New Task | Rationale |
|---|---|---|---|
| operating-protocol.md | 22-step pipeline overview | reference/operating-protocol.md | Reference material, not executable task |
| plan-creation-pipeline.md | Pipeline execution from solve artifact | create.md | Core plan generation |
| revisit.md | Verification-enforcement revisit | revise.md | Revision loop |
| audit-fidelity.md | Plan fidelity audit | validate.md | Validation check |
| audit-concern.md | Concern separation audit | validate.md | Validation check |
| solve.md | Z3 constraint solving | solve.md | Standalone task (context isolation) |
| readiness.md | Pipeline-readiness gate | analyze.md | Entry gate check |
| completion.md | Idempotent completion | completion.md | Terminal gate |
| verify-spec-approved.md | Spec approval check | analyze.md | Entry gate check |
| update.md | Non-substantive plan update | revise.md | Revision (same pipeline stage) |
| research.md | Verification-enforcement verify | analyze.md | Artifact validation |
| structure.md | Phase structure definition | create.md | Plan generation sub-step |
| retroactive.md | Retroactive plan creation | create.md | Same pipeline, different entry criteria |
| clean-room.md | Clean-room plan generation | (removed) | Used only by audit, not by writing-plans pipeline |
| write.md | Plan document writing | create.md | Plan generation sub-step |
| validate.md | 28 validation checks | validate.md | Core validation |
| pre-plan-readiness.md | Prerequisite verification | analyze.md | Entry gate check |
| artifact-validation.md | Analytical artifact validation | analyze.md | Artifact validation |
| holistic-self-check.md | 11-dimension quality check | validate.md | Validation check |

### Proposed: 6 task files

| Task | Scope | Entry Gate | Excludes |
|---|---|---|---|
| analyze.md | Verify spec.md exists locally, validate 7 analytical artifacts, detect scope boundaries, backfill missing artifacts from spec body, check spec approval status from local frontmatter | `{issues_prefix}/{N}/spec.md` must exist → BLOCKED with SPEC_NOT_FOUND | Plan generation, Z3 solving, quality checks |
| create.md | Generate structured plan with typed steps, phase DAG, file paths, commands. Write plan index + phase files. Define phase structure from analytical artifacts | analyze must have returned PASS | Z3 solving, quality checks, artifact validation |
| solve.md | Run `tools/solve` on dependency contract, return SAT/UNSAT. Run `tools/plan` for ordering, return SOLVED/UNSOLVABLE | create must have produced dependency contract | Plan generation, prose writing, quality checks |
| validate.md | Structural validation (28 checks), SC→plan fidelity, concern coverage, holistic 11-dimension gate | solve must have returned SAT | Plan generation, Z3 solving, artifact backfill |
| revise.md | Revise plan from validation findings or direct revision request. Re-run solve after revision | `{issues_prefix}/{N}/plan.md` must exist → BLOCKED with PLAN_NOT_FOUND | Artifact validation, scope boundary analysis |
| completion.md | Report plan_path, execution strategy recommendation, lifecycle event append | validate must have returned PASS | Any validation, any generation |

---

## Pipeline

```
analyze → create → solve → validate → (revise → solve → validate)* → completion
```

### Remediate + Restart Logic

| Failure Point | Action | Max Iterations |
|---|---|---|
| analyze BLOCKED (SPEC_NOT_FOUND) | HALT — spec missing | 0 |
| analyze BLOCKED (MISSING_SPEC_ARTIFACT) | Backfill from spec body or HALT | 1 backfill attempt |
| create BLOCKED (UNSAT) | Return to analyze with scope-narrowing directive | 1 |
| solve returns UNSAT | Return to create with UNSAT findings | 2 |
| solve returns UNSOLVABLE | Return to create with ordering findings | 2 |
| validate returns FAIL | Dispatch revise → re-run solve → re-run validate | 3 revise iterations |
| revise BLOCKED | HALT with escalation | 3 total |

---

## Workflows

### Workflow 1: Create a new plan

```
1. analyze
   Entry gate: {issues_prefix}/{N}/spec.md must exist → BLOCKED with SPEC_NOT_FOUND
   Checks: 7 analytical artifacts present, scope boundaries, spec approval status
   Dispatch: task(..., prompt: "execute analyze from writing-plans")
   Context: {issue_number, project_root, issues_prefix}
   Returns: {status, analysis_artifact_path, finding_summary}
   On BLOCKED: report blocker, HALT

2. create
   Generate plan structure, write plan index + phase files
   Dispatch: task(..., prompt: "execute create from writing-plans")
   Context: {issue_number, analysis_artifact_path}
   Returns: {status, plan_path, dependency_contract_path, finding_summary}
   On BLOCKED (UNSAT): return to step 1 with scope-narrowing directive
   On BLOCKED (other): report blocker, HALT

3. solve
   Run tools/solve on dependency contract, tools/plan for ordering
   Dispatch: task(..., prompt: "execute solve from writing-plans")
   Context: {dependency_contract_path}
   Returns: {status, solve_status: SAT|UNSAT, plan_status: SOLVED|UNSOLVABLE, finding_summary}
   On UNSAT: return to step 2 with UNSAT findings
   On UNSOLVABLE: return to step 2 with ordering findings

4. validate
   Structural validation, SC→plan fidelity, concern coverage, holistic 11-dimension
   Dispatch: task(..., prompt: "execute validate from writing-plans")
   Context: {issue_number, plan_path}
   Returns: {status, verdicts: [{check_name, result}], finding_summary}

5. If validate returns FAIL:
   Dispatch: task(..., prompt: "execute revise from writing-plans")
   Context: {issue_number, plan_path, validation_findings}
   Returns: {status, plan_path, finding_summary}
   Then return to step 3 (re-run solve, then re-run validate)
   Max 3 iterations. If exhausted: BLOCKED with escalation

6. If validate returns PASS:
   Dispatch: task(..., prompt: "execute completion from writing-plans")
   Context: {issue_number, plan_path}
   Returns: {status, finding_summary}
```

### Workflow 2: Revise an existing plan

```
1. revise
   Entry gate: {issues_prefix}/{N}/plan.md must exist → BLOCKED with PLAN_NOT_FOUND
   Dispatch: task(..., prompt: "execute revise from writing-plans")
   Context: {issue_number, plan_path, revision_reason}
   Returns: {status, plan_path, dependency_contract_path, finding_summary}

2. solve
   Re-run tools/solve and tools/plan on revised dependency contract
   Dispatch: task(..., prompt: "execute solve from writing-plans")
   Context: {dependency_contract_path}
   Returns: {status, solve_status, plan_status, finding_summary}

3. validate
   Re-run all validation checks on revised plan
   Dispatch: task(..., prompt: "execute validate from writing-plans")
   Context: {issue_number, plan_path}
   Returns: {status, verdicts, finding_summary}

4. If validate returns FAIL, return to step 1 (max 3 iterations).
   If PASS, dispatch completion.
```

### Workflow 3: Retroactive plan (spec exists, no plan)

```
1. analyze (backfill mode)
   Entry gate: {issues_prefix}/{N}/spec.md must exist → BLOCKED with SPEC_NOT_FOUND
   If artifacts exist at {issues_prefix}/{N}/artifacts/: skip to step 2
   If artifacts missing: backfill from spec body (no remote lookup)
   Dispatch: task(..., prompt: "execute analyze from writing-plans")
   Context: {issue_number, project_root, issues_prefix, mode: "retroactive"}

2-6. Same as Workflow 1 steps 2-6
```

---

## Design Decisions

| Question | Decision | Rationale |
|---|---|---|
| Z3 solve placement | **Standalone `tasks/solve.md`** | Conserves orchestrator context — dispatches as clean `task()` call. Prevents backwash contamination between SAT-solving output and prose generation in create/revise sub-agents. |
| Handoffs directory | **Removed entirely** | The spec folder IS the handoff. spec-creation writes to `{issues_prefix}/{N}/`, writing-plans reads from it. No separate document needed. |
| Operating protocol | `reference/operating-protocol.md` | Reference material, not an executable task. Summary inline in SKILL.md. |
| Clean-room task | **Removed** | Used only by audit plan-fidelity, not by writing-plans pipeline. Audit loads its own clean-room logic. |
| Contract count | **22 → 12** | Consolidate per pipeline stage (6 stages × 2 contracts). Merge research/readiness into analyze, audit-* into validate, write/structure into create. |
| Dispatch strings | **13 → 6** | One per task file. Old strings were defined but never consumed by external callers. |
| Spec approval check | **Local frontmatter only** | No GitHub API calls. Check `{issues_prefix}/{N}/spec.md` frontmatter for approval markers. |

---

## External Caller Migration

### Dispatch String Changes

| Caller | File | Old Pattern | New Pattern |
|---|---|---|---|
| approval-gate-scope | auto-dispatch-table.md | `writing-plans --task create` | `skill({name: "writing-plans"})` → `task("execute create from writing-plans")` |
| approval-gate-scope | auto-dispatch.md | `writing-plans --task create` | same |
| approval-gate-scope | spec-to-plan-cascade.md | `writing-plans --task create`, `writing-plans --task update` | `task("execute create from writing-plans")`, `task("execute revise from writing-plans")` |
| approval-gate-scope | verify-plan-pipeline.md | `writing-plans 22-step pipeline` | `writing-plans pipeline` (cosmetic) |
| brainstorming | completion.md | `writing-plans` (Path B) | `skill({name: "writing-plans"})` → `task("execute create from writing-plans")` |
| issue-operations-comments | comment.md | `writing-plans --task update` | `task("execute revise from writing-plans")` |
| plan-creation-pipeline | SKILL.md | `writing-plans --task create` | `task("execute create from writing-plans")` |
| holistic-dimensions.yaml | reference | `writing-plans/tasks/update.md` | `writing-plans/tasks/revise.md` |
| 010-approval-gate.md | guideline | `writing-plans --task update` | `task("execute revise from writing-plans")` |
| 000-critical-rules.md | guideline | `writing-plans/tasks/create.md` | `writing-plans/tasks/create.md` (unchanged — path reference only) |

### Files Requiring No Change

| File | Reason |
|---|---|
| dispatch-table.yaml | References `skill: "writing-plans"` — unchanged |
| dispatch-boundary-writing-plans.sh | Tests `skill("writing-plans")` dispatch boundary — unchanged |
| audit/tasks/plan-fidelity-*.md | References `writing-plans` as concept — unchanged |
| spec-creation/SKILL.md | References `writing-plans` as downstream consumer — unchanged |
| executing-plans/tasks/start.md | References `writing-plans` as concept — unchanged |
| implementation-pipeline/tasks/pre-flight-handoff.md | References `writing-plans` as concept — unchanged |
| issue-operations-core/tasks/single-task-check.md | References `writing-plans` as concept — unchanged |
| issue-operations-core/tasks/pre-creation.md | References `writing-plans/tasks/create.md` as concept — unchanged |
| completeness-gate/SKILL.md | References `writing-plans` as routing target — unchanged |
| verification-before-completion/tasks/verify.md | References `writing-plans` as concept — unchanged |
| verification-enforcement/SKILL.md | References `writing-plans` as concept — unchanged |
| .issues/ spec/plan files | Reference `writing-plans` as downstream dispatch — unchanged (conceptual reference) |

---

## File Structure

```
writing-plans/
  SKILL.md
  tasks/
    analyze.md
    create.md
    solve.md
    validate.md
    revise.md
    completion.md
  contracts/
    analyze-input-template.yaml
    analyze-output-template.yaml
    create-input-template.yaml
    create-output-template.yaml
    solve-input-template.yaml
    solve-output-template.yaml
    validate-input-template.yaml
    validate-output-template.yaml
    revise-input-template.yaml
    revise-output-template.yaml
    completion-input-template.yaml
    completion-output-template.yaml
  reference/
    operating-protocol.md
```

### What Gets Removed

- `writing-plans-creation/` directory (18 task files, 22 contracts, handoffs/)
- `writing-plans-holistic/` directory (1 task file)
- `writing-plans/SKILL.md` dispatcher (replaced with flat SKILL.md)

### Total File Count

| Before | After |
|---|---|
| 3 SKILL.md files | 1 SKILL.md |
| 19 task files | 6 task files |
| 22 contract templates | 12 contract templates |
| 1 handoffs directory | 0 (removed) |
| 0 reference directory | 1 reference directory |

---

## Description (Semantic Router Format)

```
Generate and validate implementation plans from approved specs with phase decomposition, dependency DAG verification via Z3 constraint solving, fidelity checks against spec success criteria, and holistic quality validation. Plans are REQUIRED before implementation.
```

---

## Research Validation of Routing-Table Plan Artifact

The routing-table plan artifact design (skill+task references, not hardcoded steps) is validated by three independent research sources:

### SkillRouter (arXiv 2603.22455)
Skills are modular building blocks. The skill-routing problem is: given a task, identify relevant skills before execution. The routing-table plan artifact pre-resolves this — by the time the plan reaches the executor, the skill+task mapping is already determined. The executor doesn't need to route, it just dispatches what the plan specifies. This is the key validation: the plan writer does the routing once, the executor dispatches without routing overhead.

### Dispatch Executor Pattern
The executor receives a plan as a passive string and passes it through without modification. It does NOT generate or validate plans. This validates the clean separation: the plan writer produces the plan artifact, the executor consumes it. The plan is a passive data structure containing only routing references, not execution logic.

### Plan-and-Execute Architecture
Plan-and-Execute separates "what to do" from "how to do it." The routing-table plan artifact is a pure Plan-and-Execute pattern. The plan says "what" (skill+task references, phase DAG, SC mappings). The implementation pipeline determines "how" (RED/GREEN cycle, clean-room dispatch, verification gates). Changes to the "how" don't require plan regeneration — the plan is resilient to pipeline evolution.

### Impact on Spec
The spec draft is well-aligned with all three research sources. No significant changes needed:
- Routing-table format with skill+task references → validated by SkillRouter
- create.md discovers current pipeline → validated by Dispatch Executor pattern
- validate.md checks skill+task references are real → validated by SkillRouter
- Plan writer and pipeline remediation as separate specs → validated by Plan-and-Execute separation of concerns
- Plan artifact as passive data structure → validated by Dispatch Executor pattern

## Open Questions for Spec

1. **Spec approval frontmatter field:** What YAML frontmatter field indicates approval? Options: `status: approved`, `approved: true`, `approved-for: implementation`. The analyze task checks this field.

2. **Backfill depth:** When artifacts are missing in retroactive mode, how much codebase inspection is acceptable? Full artifact generation (expensive) or minimal backfill from spec body (may produce lower-quality plans)?

3. **Plan artifact format versioning:** Should the plan artifact include a `schema_version` field to allow format evolution?

## Classification

- **Type**: Architecture research for skill flattening
- **Confidence**: 0.95 (high — cross-reference inventory complete, contract analysis complete, task scope boundaries mapped, routing-table approach validated by 3 independent research sources)
- **Fix scope**: Replace 3 SKILL.md + 19 task files + 22 contracts + handoffs with 1 SKILL.md + 6 task files + 12 contracts + 1 reference
- **External migration scope**: ~10 files requiring dispatch string updates

### 11. Plan Step Format: Checkbox Mandate, Sub-Bullet Rules

Three independent sources converge on the same format rules:

**Source 1: `create-plan` skill (eliteai.tools)**
- "ALWAYS use checkbox format (`- [ ]`) for ALL implementation tasks"
- "NEVER use numbered lists or plain bullet points in Implementation Plan section"

**Source 2: Paul Brodner — "Writing AI Agent Specs: Less Art, more checklists"**
- Definition of Done must be checkboxes, not prose
- "A checklist does two things: it prevents the agent from stopping too early, and it makes the completion criteria unambiguous"
- The "curse of instructions": too many rules in one prompt degrades performance — separation of concerns is critical

**Source 3: Markdown in AI Agent Workflows (allmarkdowntools.com)**
- Agents use markdown as primary communication format
- "Specify a maximum nesting depth in agent instructions" — excessive nesting causes parsing failures
- "Separate instructions from content using a clear delimiter"
- Inconsistent heading hierarchy causes downstream parsing failures

**Implication for plan format:**
- Checkbox format is MANDATORY for all implementation steps — not optional, not negotiable
- Sub-bullets for informational context (file paths, parameters, expected outcomes) are permitted but MUST be indented and MUST NOT contain checkboxes
- Maximum nesting depth: 2 levels (step → sub-bullet)
- Non-step sections (Entry Conditions, Exit Conditions, metadata) MUST use plain lists — checkboxes in non-step sections confuse agents about what is actionable vs. informational
- These rules are now codified in `plan-artifact-format.md` §4.2 Step Format Rules
