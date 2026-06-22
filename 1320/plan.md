# Implementation Plan for #1320

**Spec:** [michael-conrad/.opencode#1320](https://github.com/michael-conrad/.opencode/issues/1320) — Decompose writing-plans skill into discrete Z3-enforced pipeline with YAML contract dispatch

## Goal

Replace the `writing-plans` skill's abstract-principles Operating Protocol, uber-task `create` sub-agent, duplicated DISPATCH_GATE fluff, and missing contract infrastructure with a 21-step Z3-enforced pipeline of discrete sub-agent dispatches, YAML contract templates, and mandatory live-source research gates.

## Architecture

The pipeline decomposes the current single `create` task() call into 10 discrete sub-agent steps interleaved with 10 z3-check transitions and 1 inline verification step. Each sub-agent is a leaf node — it executes tools directly (CLI, file ops, skill loading + inline execution). Only the orchestrator dispatches via `task()`. State files track step completion; Z3 contracts enforce no-skip transitions.

## Tech Stack

- **Skill files:** Markdown with YAML frontmatter
- **Contract templates:** YAML (minimal schemas, ≤20 lines)
- **Z3 enforcement:** `./.opencode/tools/solve` (check, model, state)
- **Plan validation:** `./.opencode/tools/plan plan`
- **Verification:** `verification-enforcement` skill (verify + revisit)
- **Audit:** `adversarial-audit` skill (plan-fidelity, concern-separation)
- **Behavioral tests:** `bash .opencode/tests/behaviors/<scenario>.sh`

## File Structure

| Sub-Folder | Responsibility |
|------------|---------------|
| `skills/writing-plans/` | SKILL.md — orchestrator routing card with dispatch checklist |
| `skills/writing-plans/tasks/` | 10 new decomposed task files + restructured `create.md` + integrated `validate.md` |
| `skills/writing-plans/contracts/` | 20 YAML templates (10 input + 10 output) for sub-agent dispatch context |
| `.opencode/tests/behaviors/` | 2 behavioral enforcement tests (SC-14, SC-19) |

---

### Phase 1: SKILL.md Rewrite + Decomposed Task Files

**Concern:** Skill card structure and sub-agent task file content
**Files:** `skills/writing-plans/SKILL.md`, `skills/writing-plans/tasks/create.md`, `skills/writing-plans/tasks/research.md`, `skills/writing-plans/tasks/readiness.md`, `skills/writing-plans/tasks/structure.md`, `skills/writing-plans/tasks/solve.md`, `skills/writing-plans/tasks/write.md`, `skills/writing-plans/tasks/revisit.md`, `skills/writing-plans/tasks/audit-fidelity.md`, `skills/writing-plans/tasks/audit-concern.md`
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-8, SC-9, SC-10, SC-12, SC-13, SC-15, SC-16

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline. Read `implementation-pipeline/tasks/sc-coherence-gate.md` first", "issue_number": 1320, "phase": 1}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-8, SC-9, SC-10, SC-12, SC-13, SC-15, SC-16 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline. Read `implementation-pipeline/tasks/pre-red-baseline.md` first", "issue_number": 1320, "phase": 1}` | — |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline. Read `implementation-pipeline/tasks/red-phase.md` first", "issue_number": 1320, "phase": 1}` | — |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline. Read `implementation-pipeline/tasks/red-doublecheck.md` first", "issue_number": 1320, "phase": 1}` | — |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first", "issue_number": 1320, "phase": 1}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline. Read `implementation-pipeline/tasks/green-phase.md` first", "issue_number": 1320, "phase": 1}` | — |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first", "issue_number": 1320, "phase": 1}` | — |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline. Read `implementation-pipeline/tasks/structural-checks.md` first", "issue_number": 1320, "phase": 1}` | — |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline. Read `implementation-pipeline/tasks/green-doublecheck.md` first", "issue_number": 1320, "phase": 1}` | — |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline. Read `implementation-pipeline/tasks/green-vbc.md` first", "issue_number": 1320, "phase": 1}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-8, SC-9, SC-10, SC-12, SC-13, SC-15, SC-16 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline. Read `implementation-pipeline/tasks/adversarial-audit.md` first", "issue_number": 1320, "phase": 1}` | — |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline. Read `implementation-pipeline/tasks/cross-validate.md` first", "issue_number": 1320, "phase": 1}` | — |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline. Read `implementation-pipeline/tasks/regression-check.md` first", "issue_number": 1320, "phase": 1}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline. Read `implementation-pipeline/tasks/review-prep.md` first", "issue_number": 1320, "phase": 1}` | — |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline. Read `implementation-pipeline/tasks/exec-summary.md` first", "issue_number": 1320, "phase": 1}` | — |

#### Concern Boundary

**Leaving:** Spec analysis (requirements, decomposition, risk)
**Entering:** Skill card structure and sub-agent task file content — the orchestrator's routing document and the sub-agents' execution procedures
**Handoff needed:** Approved spec (#1320) with 19 SCs, 3-phase decomposition, affected file list, architectural constraint (sub-agents are leaf nodes)

#### TDD Tasks

**Item 1.1: SKILL.md Operating Protocol Rewrite**

RED: The SKILL.md Operating Protocol contains abstract design principles ("TDD steps mandatory", "no placeholders") instead of an enumerated dispatch checklist with `[inline]`/`[sub-task]`/`[z3-check]` tags, chain dependencies, and contract paths.

GREEN: The SKILL.md Operating Protocol is a 21-item enumerated checklist where every item has a dispatch scope tag (`[inline]`, `[sub-task: <name>]`, or `[z3-check]`), a `chain:` dependency, and `input:`/`output:`/`template:` contract paths for sub-task items.

**Item 1.2: DISPATCH_GATE Section Removal**

RED: The SKILL.md contains a 60-line DISPATCH_GATE section with forbidden-patterns table, discovery directive, dispatch context contract, exclusions, and sub-agent entry criteria — duplicated generic fluff.

GREEN: The SKILL.md contains no DISPATCH_GATE section. The `Forbidden in task() Prompts` table, `Dispatch Context Contract` list, and `Sub-Agent Entry Criteria` block are absent. Guideline-level enforcement covers these rules.

**Item 1.3: Trigger Dispatch Table — Add retroactive**

RED: The Trigger Dispatch Table has no entry for `retroactive`. The `retroactive.md` task file exists but has no routing path from the SKILL.md.

GREEN: The Trigger Dispatch Table contains a `retroactive` entry with dispatch type `sub-task` and context `{spec_issue_number}`. A `## Retroactive Operating Protocol` section exists with its own enumerated checklist.

**Item 1.4: create.md — Remove Orchestrator Execution Protocol**

RED: `create.md` lines 58–69 contain an "Orchestrator Execution Protocol" section with instructions to "Execute every gate in every phase" and "call `task()` with Receives Context JSON" — orchestrator-level instructions in a sub-agent task file.

GREEN: `create.md` contains no Orchestrator Execution Protocol section. The phrases "Execute every gate" and "call `task()` with the exact Receives Context JSON" are absent. The file is restructured as a routing-only task file.

**Item 1.5: create.md — Restructure as Routing-Only**

RED: `create.md` routes internally to `plan-structure` and `create-and-validate` sub-sub-tasks — an uber-task pattern where one `task()` call internally dispatches to multiple concerns.

GREEN: `create.md` is a routing-only task file. The strings `plan-structure` and `create-and-validate` appear only in cross-references, not in procedure body. The file points to the 10 decomposed sub-task files.

**Item 1.6: New Task Files — research, readiness, structure, solve, write, revisit**

RED: No task files exist for `research`, `readiness`, `structure`, `solve`, `write`, or `revisit`. The pipeline has no sub-agent procedures for these steps.

GREEN: Six new task files exist at `skills/writing-plans/tasks/`:
- `research.md` — loads `verification-enforcement` skill, executes `--task verify` inline, collects evidence artifacts, returns PASS/BLOCKED
- `readiness.md` — pipeline-readiness gate check + spec-to-plan handoff
- `structure.md` — combined/separate decision, file mapping, phase structure, TDD definition, dependency contract generation
- `solve.md` — runs `./.opencode/tools/solve model`, `./.opencode/tools/solve check`, `./.opencode/tools/plan plan` as direct CLI; returns SAT/UNSAT, SOLVED/UNSOLVABLE
- `write.md` — writes `.issues/{N}/plan.md`, dispatch table validation, approval cascade, cross-reference sync
- `revisit.md` — loads `verification-enforcement` skill, executes `--task revisit` inline, scans for `⚠️ UNVERIFIED` markers, resolves or escalates

**Item 1.7: New Task Files — audit-fidelity, audit-concern**

RED: No task files exist for `audit-fidelity` or `audit-concern`. The adversarial audit steps have no sub-agent procedures.

GREEN: Two new task files exist:
- `audit-fidelity.md` — loads `adversarial-audit` skill, executes `--task plan-fidelity` inline with auditor sub-agent type context
- `audit-concern.md` — loads `adversarial-audit` skill, executes `--task concern-separation` inline with auditor sub-agent type context

**Item 1.8: Sub-Agent Leaf Node Enforcement**

RED: Sub-agent task files may contain `task()` calls — violating the architectural invariant that only the orchestrator dispatches.

GREEN: No sub-agent task file (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern) contains a `task(` call. All tool invocations use direct CLI (`./.opencode/tools/solve model`, `./.opencode/tools/plan plan`) or skill loading + inline execution.

**Item 1.9: Z3 Contract YAML Schema Compliance**

RED: Task files may contain raw SMT-LIB (`declare-const`, `assert`, `=>`) for Z3 contracts — not portable across solve tool versions.

GREEN: No task file contains `declare-const`. Contract-related task files use the YAML schema from `solve/tasks/contract.md` with `variables:` section (type/domain/nullable) and `preconditions:`/`invariants:`/`postconditions:` as Z3 expression strings.

**Item 1.10: State File Lifecycle**

RED: No task file initializes or updates state files via `solve state init` or `solve state update`. Z3 contracts have no corresponding state to validate against.

GREEN: Task files that produce or consume contract artifacts include `solve state init` and `solve state update` calls. State files track step completion between pipeline transitions.

**Item 1.11: validate.md Integration**

RED: `validate` is only reachable as a remediation fallback in `completion.md`. It is not a discrete pipeline step.

GREEN: `[sub-task: validate]` appears in the SKILL.md Operating Protocol as a discrete step with contract paths. The `validate.md` task file content is unchanged; only its routing is elevated.

**Item 1.12: Auditor Sub-Agent Type References**

RED: The Operating Protocol may reference `general` sub-agent type for audit steps — `general` sub-agents cannot perform adversarial verification.

GREEN: `[sub-task: audit-fidelity]` and `[sub-task: audit-concern]` in the Operating Protocol reference `auditor_` sub-agent types from `resolve-models` result contract. Task files document fallback to `general` with `audit_phase` context if `resolve-models` is unavailable.

**Item 1.13: No Orchestrator Instructions in Task Files**

RED: Task files may contain orchestrator-level instructions — "Execute every gate", "call `task()`", "Report progress via chat" — causing sub-agents to attempt orchestration.

GREEN: No task file contains `Execute every gate` or orchestrator-level `task()` dispatch instructions. Sub-agent task files describe tool execution procedures only.

#### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Spec SCs are coherent with codebase state; no contradictions between SC requirements and existing file structure |
| 2 | pre-red-baseline | Current SKILL.md and task files captured as baseline; behavioral tests confirmed absent or failing |
| 3 | red-phase | All 13 items have RED condition descriptions written; behavioral test stubs created and confirmed FAIL |
| 4 | red-doublecheck | Independent sub-agent confirms all RED conditions are testable and correctly describe the failure state |
| 5 | post-red-enforcement | Content-verification grep tests written and confirmed FAIL for all string SCs |
| 6 | green-phase | All 13 items implemented: SKILL.md rewritten, task files created, create.md restructured |
| 7 | post-green-enforcement | Content-verification grep tests pass for all string SCs (SC-1 through SC-6, SC-8 through SC-10, SC-12, SC-13, SC-15, SC-16) |
| 8 | checkpoint-commit | All Phase 1 changes committed with message `feat(writing-plans): decompose skill into Z3-enforced pipeline (Phase 1)` |
| 9 | structural-checks | Lint (pymarkdownlnt), format (mdformat), word-count (wc -w ≤3,000 on all new task files) |
| 10 | green-doublecheck | Independent sub-agent confirms all GREEN implementations match RED conditions |
| 11 | green-vbc | All Phase 1 SCs verified: grep assertions pass, structural checks pass, word-count limits met |
| 12 | adversarial-audit | Cross-family auditor validates Phase 1 deliverables against spec |
| 13 | cross-validate | Second auditor cross-validates first auditor's findings |
| 14 | regression-check | Existing `retroactive.md`, `clean-room.md`, `validate.md`, `completion.md` unchanged and functional |
| 15 | review-prep | Diff review, commit message review, PR body prepared |
| 16 | exec-summary | Phase 1 completion reported in chat with artifact paths |

#### Z3 Contract

```yaml
variables:
  P1_p1: {type: bool, nullable: false}
  P1_p2: {type: bool, nullable: false}
  P1_p3: {type: bool, nullable: false}
  P1_p4: {type: bool, nullable: false}
  P1_p5: {type: bool, nullable: false}
  P1_p6: {type: bool, nullable: false}
  P1_p7: {type: bool, nullable: false}
  P1_p8: {type: bool, nullable: false}
  P1_p9: {type: bool, nullable: false}
  P1_p10: {type: bool, nullable: false}
  P1_p11: {type: bool, nullable: false}
  P1_p12: {type: bool, nullable: false}
  P1_p13: {type: bool, nullable: false}
  P1_p14: {type: bool, nullable: false}
  P1_p15: {type: bool, nullable: false}
  P1_p16: {type: bool, nullable: false}
  D_P1: {type: bool, nullable: false}
invariants:
  - "z3.Implies(P1_p2 == True, P1_p1 == True)"
  - "z3.Implies(P1_p3 == True, P1_p2 == True)"
  - "z3.Implies(P1_p4 == True, P1_p3 == True)"
  - "z3.Implies(P1_p5 == True, P1_p4 == True)"
  - "z3.Implies(P1_p6 == True, P1_p5 == True)"
  - "z3.Implies(P1_p7 == True, P1_p6 == True)"
  - "z3.Implies(P1_p8 == True, P1_p7 == True)"
  - "z3.Implies(P1_p9 == True, P1_p8 == True)"
  - "z3.Implies(P1_p10 == True, P1_p9 == True)"
  - "z3.Implies(P1_p11 == True, P1_p10 == True)"
  - "z3.Implies(P1_p12 == True, P1_p11 == True)"
  - "z3.Implies(P1_p13 == True, P1_p12 == True)"
  - "z3.Implies(P1_p14 == True, P1_p13 == True)"
  - "z3.Implies(P1_p15 == True, P1_p14 == True)"
  - "z3.Implies(P1_p16 == True, P1_p15 == True)"
  - "z3.Implies(D_P1 == True, z3.And(P1_p1 == True, P1_p2 == True, P1_p3 == True, P1_p4 == True, P1_p5 == True, P1_p6 == True, P1_p7 == True, P1_p8 == True, P1_p9 == True, P1_p10 == True, P1_p11 == True, P1_p12 == True, P1_p13 == True, P1_p14 == True, P1_p15 == True, P1_p16 == True))"
  - "z3.Implies(z3.Not(z3.And(P1_p1 == True, P1_p2 == True, P1_p3 == True, P1_p4 == True, P1_p5 == True, P1_p6 == True, P1_p7 == True, P1_p8 == True, P1_p9 == True, P1_p10 == True, P1_p11 == True, P1_p12 == True, P1_p13 == True, P1_p14 == True, P1_p15 == True, P1_p16 == True)), z3.Not(D_P1 == True))"
```

---

### Phase 2: Contract Templates + Task File Word-Count Verification

**Concern:** Dispatch infrastructure and size constraints
**Files:** `skills/writing-plans/contracts/`
**SCs covered:** SC-7, SC-11, SC-17, SC-18

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline. Read `implementation-pipeline/tasks/sc-coherence-gate.md` first", "issue_number": 1320, "phase": 2}` | SC-7, SC-11, SC-17, SC-18 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline. Read `implementation-pipeline/tasks/pre-red-baseline.md` first", "issue_number": 1320, "phase": 2}` | — |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline. Read `implementation-pipeline/tasks/red-phase.md` first", "issue_number": 1320, "phase": 2}` | — |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline. Read `implementation-pipeline/tasks/red-doublecheck.md` first", "issue_number": 1320, "phase": 2}` | — |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first", "issue_number": 1320, "phase": 2}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline. Read `implementation-pipeline/tasks/green-phase.md` first", "issue_number": 1320, "phase": 2}` | — |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first", "issue_number": 1320, "phase": 2}` | — |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline. Read `implementation-pipeline/tasks/structural-checks.md` first", "issue_number": 1320, "phase": 2}` | — |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline. Read `implementation-pipeline/tasks/green-doublecheck.md` first", "issue_number": 1320, "phase": 2}` | — |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline. Read `implementation-pipeline/tasks/green-vbc.md` first", "issue_number": 1320, "phase": 2}` | SC-7, SC-11, SC-17, SC-18 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline. Read `implementation-pipeline/tasks/adversarial-audit.md` first", "issue_number": 1320, "phase": 2}` | — |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline. Read `implementation-pipeline/tasks/cross-validate.md` first", "issue_number": 1320, "phase": 2}` | — |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline. Read `implementation-pipeline/tasks/regression-check.md` first", "issue_number": 1320, "phase": 2}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline. Read `implementation-pipeline/tasks/review-prep.md` first", "issue_number": 1320, "phase": 2}` | — |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline. Read `implementation-pipeline/tasks/exec-summary.md` first", "issue_number": 1320, "phase": 2}` | — |

#### Concern Boundary

**Leaving:** Skill card structure and task file content (Phase 1 deliverables)
**Entering:** Dispatch infrastructure — contract templates that define the canonical format for orchestrator-to-sub-agent communication
**Handoff needed:** Phase 1 task files exist with defined input/output contract paths; `contracts/` directory is empty

#### TDD Tasks

**Item 2.1: Contract Templates — Input Templates (10 files)**

RED: The `contracts/` directory is empty. No input YAML templates exist for the 10 sub-task steps. The orchestrator has no canonical format for preparing sub-agent dispatch context.

GREEN: `contracts/` contains 10 input template files:
- `research-input-template.yaml`
- `readiness-input-template.yaml`
- `structure-input-template.yaml`
- `solve-input-template.yaml`
- `write-input-template.yaml`
- `revisit-input-template.yaml`
- `validate-input-template.yaml`
- `audit-fidelity-input-template.yaml`
- `audit-concern-input-template.yaml`
- `completion-input-template.yaml`

Each template is a minimal YAML schema (≤20 lines) defining the fields the orchestrator must populate before dispatching the corresponding sub-agent.

**Item 2.2: Contract Templates — Output Templates (10 files)**

RED: The `contracts/` directory is empty. No output YAML templates exist for the 10 sub-task steps. Sub-agents have no canonical format for returning result contracts.

GREEN: `contracts/` contains 10 output template files:
- `research-output-template.yaml` — includes `evidence_artifacts` field
- `readiness-output-template.yaml`
- `structure-output-template.yaml`
- `solve-output-template.yaml` — includes `solve_status` (SAT/UNSAT) and `plan_status` (SOLVED/UNSOLVABLE) fields
- `write-output-template.yaml`
- `revisit-output-template.yaml` — includes `resolution_status` field
- `validate-output-template.yaml`
- `audit-fidelity-output-template.yaml`
- `audit-concern-output-template.yaml`
- `completion-output-template.yaml`

Each template is a minimal YAML schema (≤20 lines) defining the fields the sub-agent must populate in its result contract.

**Item 2.3: Task File Word-Count Verification**

RED: New task files may exceed 3,000 words — violating the `091-incremental-build.md` size limit.

GREEN: `wc -w` on each new task file returns ≤3,000. Any file exceeding the limit is split into smaller atomic tasks.

**Item 2.4: Research Output Template — BLOCKED Handling**

RED: The research output template may lack an `evidence_artifacts` field and BLOCKED handling — the orchestrator cannot distinguish research failure from success.

GREEN: `research-output-template.yaml` contains an `evidence_artifacts` field (list of paths). The `research.md` task file documents that BLOCKED status with empty evidence_artifacts halts the pipeline.

**Item 2.5: Revisit Output Template — Resolution Status**

RED: The revisit output template may lack a `resolution_status` field — the orchestrator cannot determine whether unverified claims were resolved or escalated.

GREEN: `revisit-output-template.yaml` contains a `resolution_status` field with values `resolved`/`partial`/`escalated`. The `revisit.md` task file documents that `escalated` status halts the pipeline with a spec-defect report.

#### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Phase 2 SCs are coherent with Phase 1 deliverables; contract template paths match task file references |
| 2 | pre-red-baseline | Current `contracts/` directory state captured (empty); task file word counts recorded |
| 3 | red-phase | All 5 items have RED condition descriptions written; content-verification test stubs created and confirmed FAIL |
| 4 | red-doublecheck | Independent sub-agent confirms all RED conditions correctly describe the missing-template and oversized-file states |
| 5 | post-red-enforcement | Content-verification grep tests written and confirmed FAIL for SC-7, SC-11, SC-17, SC-18 |
| 6 | green-phase | All 5 items implemented: 20 templates created, word-count limits verified, BLOCKED/resolution_status fields added |
| 7 | post-green-enforcement | Content-verification tests pass: `ls contracts/` returns ≥20 files, `wc -w` ≤3,000 on all task files, `evidence_artifacts` and `resolution_status` fields present |
| 8 | checkpoint-commit | All Phase 2 changes committed with message `feat(writing-plans): add contract templates and enforce word-count limits (Phase 2)` |
| 9 | structural-checks | YAML syntax validation on all 20 templates; lint and format on modified task files |
| 10 | green-doublecheck | Independent sub-agent confirms all templates match task file contract path references |
| 11 | green-vbc | All Phase 2 SCs verified: SC-7 (≥20 files), SC-11 (wc -w ≤3,000), SC-17 (evidence_artifacts field), SC-18 (resolution_status field) |
| 12 | adversarial-audit | Cross-family auditor validates Phase 2 deliverables against spec |
| 13 | cross-validate | Second auditor cross-validates first auditor's findings |
| 14 | regression-check | Phase 1 deliverables unchanged; contract templates don't break existing task file references |
| 15 | review-prep | Diff review, commit message review, PR body updated with Phase 2 summary |
| 16 | exec-summary | Phase 2 completion reported in chat with artifact paths |

#### Z3 Contract

```yaml
variables:
  P2_p1: {type: bool, nullable: false}
  P2_p2: {type: bool, nullable: false}
  P2_p3: {type: bool, nullable: false}
  P2_p4: {type: bool, nullable: false}
  P2_p5: {type: bool, nullable: false}
  P2_p6: {type: bool, nullable: false}
  P2_p7: {type: bool, nullable: false}
  P2_p8: {type: bool, nullable: false}
  P2_p9: {type: bool, nullable: false}
  P2_p10: {type: bool, nullable: false}
  P2_p11: {type: bool, nullable: false}
  P2_p12: {type: bool, nullable: false}
  P2_p13: {type: bool, nullable: false}
  P2_p14: {type: bool, nullable: false}
  P2_p15: {type: bool, nullable: false}
  P2_p16: {type: bool, nullable: false}
  D_P2: {type: bool, nullable: false}
invariants:
  - "z3.Implies(P2_p2 == True, P2_p1 == True)"
  - "z3.Implies(P2_p3 == True, P2_p2 == True)"
  - "z3.Implies(P2_p4 == True, P2_p3 == True)"
  - "z3.Implies(P2_p5 == True, P2_p4 == True)"
  - "z3.Implies(P2_p6 == True, P2_p5 == True)"
  - "z3.Implies(P2_p7 == True, P2_p6 == True)"
  - "z3.Implies(P2_p8 == True, P2_p7 == True)"
  - "z3.Implies(P2_p9 == True, P2_p8 == True)"
  - "z3.Implies(P2_p10 == True, P2_p9 == True)"
  - "z3.Implies(P2_p11 == True, P2_p10 == True)"
  - "z3.Implies(P2_p12 == True, P2_p11 == True)"
  - "z3.Implies(P2_p13 == True, P2_p12 == True)"
  - "z3.Implies(P2_p14 == True, P2_p13 == True)"
  - "z3.Implies(P2_p15 == True, P2_p14 == True)"
  - "z3.Implies(P2_p16 == True, P2_p15 == True)"
  - "z3.Implies(D_P2 == True, z3.And(P2_p1 == True, P2_p2 == True, P2_p3 == True, P2_p4 == True, P2_p5 == True, P2_p6 == True, P2_p7 == True, P2_p8 == True, P2_p9 == True, P2_p10 == True, P2_p11 == True, P2_p12 == True, P2_p13 == True, P2_p14 == True, P2_p15 == True, P2_p16 == True))"
  - "z3.Implies(z3.Not(z3.And(P2_p1 == True, P2_p2 == True, P2_p3 == True, P2_p4 == True, P2_p5 == True, P2_p6 == True, P2_p7 == True, P2_p8 == True, P2_p9 == True, P2_p10 == True, P2_p11 == True, P2_p12 == True, P2_p13 == True, P2_p14 == True, P2_p15 == True, P2_p16 == True)), z3.Not(D_P2 == True))"
```

---

### Phase 3: Behavioral Enforcement Tests

**Concern:** Runtime verification that the orchestrator follows the new pipeline
**Files:** `.opencode/tests/behaviors/`
**SCs covered:** SC-14, SC-19

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline. Read `implementation-pipeline/tasks/sc-coherence-gate.md` first", "issue_number": 1320, "phase": 3}` | SC-14, SC-19 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline. Read `implementation-pipeline/tasks/pre-red-baseline.md` first", "issue_number": 1320, "phase": 3}` | — |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline. Read `implementation-pipeline/tasks/red-phase.md` first", "issue_number": 1320, "phase": 3}` | — |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline. Read `implementation-pipeline/tasks/red-doublecheck.md` first", "issue_number": 1320, "phase": 3}` | — |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first", "issue_number": 1320, "phase": 3}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline. Read `implementation-pipeline/tasks/green-phase.md` first", "issue_number": 1320, "phase": 3}` | — |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first", "issue_number": 1320, "phase": 3}` | — |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline. Read `implementation-pipeline/tasks/structural-checks.md` first", "issue_number": 1320, "phase": 3}` | — |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline. Read `implementation-pipeline/tasks/green-doublecheck.md` first", "issue_number": 1320, "phase": 3}` | — |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline. Read `implementation-pipeline/tasks/green-vbc.md` first", "issue_number": 1320, "phase": 3}` | SC-14, SC-19 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline. Read `implementation-pipeline/tasks/adversarial-audit.md` first", "issue_number": 1320, "phase": 3}` | — |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline. Read `implementation-pipeline/tasks/cross-validate.md` first", "issue_number": 1320, "phase": 3}` | — |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline. Read `implementation-pipeline/tasks/regression-check.md` first", "issue_number": 1320, "phase": 3}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline. Read `implementation-pipeline/tasks/review-prep.md` first", "issue_number": 1320, "phase": 3}` | — |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline. Read `implementation-pipeline/tasks/exec-summary.md` first", "issue_number": 1320, "phase": 3}` | — |

#### Concern Boundary

**Leaving:** Static artifact creation (Phase 1 + Phase 2 deliverables)
**Entering:** Runtime behavioral verification — proving the agent actually follows the new pipeline when dispatched
**Handoff needed:** Phase 1 and Phase 2 deliverables committed; SKILL.md has 21-step dispatch checklist; contract templates exist; task files are leaf-node compliant

#### TDD Tasks

**Item 3.1: Behavioral Test — Orchestrator No Inline Work (SC-14)**

RED: A behavioral test sends a prompt to the agent requesting plan creation. The agent dispatches `writing-plans` skill. The test asserts the agent performs inline file writes (no `task()` calls in stderr). Test FAILS — the agent currently does inline work because the Operating Protocol has no dispatch checklist.

GREEN: The same behavioral test sends the same prompt. The agent dispatches `writing-plans` skill. The test asserts via `assert_semantic` that the agent dispatched sub-agents for all content generation (stderr shows `task()` calls for each sub-task step) and performed no inline file writes. Test PASSES.

**Item 3.2: Behavioral Test — Behavioral TDD Enforcement (SC-19)**

RED: A behavioral test stub exists at `.opencode/tests/behaviors/test-writing-plans-pipeline.sh` with `assert_semantic` and `assert_stderr_pattern_present` assertions. The test sends a prompt requesting plan creation. The test FAILS because the pipeline changes don't exist yet — the agent uses the old uber-task model.

GREEN: The same behavioral test sends the same prompt. The agent dispatches `writing-plans` skill and follows the 21-step pipeline. The test PASSES — `assert_semantic` confirms the agent dispatched sub-agents for each step, `assert_stderr_pattern_present` confirms `task()` calls in stderr for each sub-task step.

#### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Behavioral test scenarios are coherent with Phase 1+2 deliverables; test assertions reference correct SC IDs |
| 2 | pre-red-baseline | Current behavioral test directory state captured; no existing tests for writing-plans pipeline |
| 3 | red-phase | Both behavioral test stubs written; tests confirmed FAIL (RED state verified via `opencode-cli run`) |
| 4 | red-doublecheck | Independent sub-agent confirms RED state is genuine — tests fail because pipeline changes don't exist yet |
| 5 | post-red-enforcement | Test assertions verified to use correct evidence types: `assert_semantic` for behavioral SC-14, stderr-based assertions for SC-19 |
| 6 | green-phase | Both behavioral tests pass: SC-14 confirms no inline work, SC-19 confirms behavioral TDD cycle complete |
| 7 | post-green-enforcement | Both tests pass reliably (≥2 consecutive runs); no flaky failures |
| 8 | checkpoint-commit | All Phase 3 changes committed with message `test(writing-plans): add behavioral enforcement tests for decomposed pipeline (Phase 3)` |
| 9 | structural-checks | Test scripts pass shellcheck; test helper imports verified |
| 10 | green-doublecheck | Independent sub-agent confirms both tests produce deterministic PASS/FAIL |
| 11 | green-vbc | SC-14 and SC-19 verified: behavioral evidence artifacts present, test session YAML files confirm PASS |
| 12 | adversarial-audit | Cross-family auditor validates behavioral test design against spec SCs |
| 13 | cross-validate | Second auditor cross-validates first auditor's findings |
| 14 | regression-check | Existing behavioral tests unchanged; new tests don't interfere with existing test infrastructure |
| 15 | review-prep | Diff review, commit message review, final PR body with all 3 phases |
| 16 | exec-summary | Full implementation completion reported in chat with PR URL |

#### Z3 Contract

```yaml
variables:
  P3_p1: {type: bool, nullable: false}
  P3_p2: {type: bool, nullable: false}
  P3_p3: {type: bool, nullable: false}
  P3_p4: {type: bool, nullable: false}
  P3_p5: {type: bool, nullable: false}
  P3_p6: {type: bool, nullable: false}
  P3_p7: {type: bool, nullable: false}
  P3_p8: {type: bool, nullable: false}
  P3_p9: {type: bool, nullable: false}
  P3_p10: {type: bool, nullable: false}
  P3_p11: {type: bool, nullable: false}
  P3_p12: {type: bool, nullable: false}
  P3_p13: {type: bool, nullable: false}
  P3_p14: {type: bool, nullable: false}
  P3_p15: {type: bool, nullable: false}
  P3_p16: {type: bool, nullable: false}
  D_P3: {type: bool, nullable: false}
invariants:
  - "z3.Implies(P3_p2 == True, P3_p1 == True)"
  - "z3.Implies(P3_p3 == True, P3_p2 == True)"
  - "z3.Implies(P3_p4 == True, P3_p3 == True)"
  - "z3.Implies(P3_p5 == True, P3_p4 == True)"
  - "z3.Implies(P3_p6 == True, P3_p5 == True)"
  - "z3.Implies(P3_p7 == True, P3_p6 == True)"
  - "z3.Implies(P3_p8 == True, P3_p7 == True)"
  - "z3.Implies(P3_p9 == True, P3_p8 == True)"
  - "z3.Implies(P3_p10 == True, P3_p9 == True)"
  - "z3.Implies(P3_p11 == True, P3_p10 == True)"
  - "z3.Implies(P3_p12 == True, P3_p11 == True)"
  - "z3.Implies(P3_p13 == True, P3_p12 == True)"
  - "z3.Implies(P3_p14 == True, P3_p13 == True)"
  - "z3.Implies(P3_p15 == True, P3_p14 == True)"
  - "z3.Implies(P3_p16 == True, P3_p15 == True)"
  - "z3.Implies(D_P3 == True, z3.And(P3_p1 == True, P3_p2 == True, P3_p3 == True, P3_p4 == True, P3_p5 == True, P3_p6 == True, P3_p7 == True, P3_p8 == True, P3_p9 == True, P3_p10 == True, P3_p11 == True, P3_p12 == True, P3_p13 == True, P3_p14 == True, P3_p15 == True, P3_p16 == True))"
  - "z3.Implies(z3.Not(z3.And(P3_p1 == True, P3_p2 == True, P3_p3 == True, P3_p4 == True, P3_p5 == True, P3_p6 == True, P3_p7 == True, P3_p8 == True, P3_p9 == True, P3_p10 == True, P3_p11 == True, P3_p12 == True, P3_p13 == True, P3_p14 == True, P3_p15 == True, P3_p16 == True)), z3.Not(D_P3 == True))"
```

---

### Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — delete merged branches, close issues, sync dev

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
