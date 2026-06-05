## Spec: Verdict Classifier Gate — per_criterion enforcement across all pipeline workflows

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

---

### Problem Statement

During pipeline execution for issue #884, step 12 (regression-check) returned a sub-agent artifact with status `DONE_WITH_CONCERNS` but per_criterion data showed 3 PASS + 2 FAIL. The orchestrator nearly reclassified the FAILs as "intentional" instead of treating them as hard gates. Root cause: **no automated gate enforces per_criterion content → step_verdict alignment.**

The orchestrator reads the sub-agent's result contract (`status: DONE | BLOCKED | DONE_WITH_CONCERNS | OVERFLOW`), not the per_criterion[] YAML content on disk. When a sub-agent returns `DONE_WITH_CONCERNS`, the orchestrator has no mechanism to verify that per_criterion failures actually propagate to the step-level verdict. The Z3 state machine validates step transitions (SAT/UNSAT over `previous_step`/`current_step`/`pipeline_state`) but cannot validate verdict semantics — it has no `step_verdict` variable.

This creates a gap where:
- A sub-agent reports `DONE_WITH_CONCERNS` with 2/5 FAIL criteria
- The orchestrator reads the contract status as non-failure (it's `DONE_WITH_CONCERNS`, not `BLOCKED`)
- The orchestrator proceeds to the next pipeline step
- The FAIL criteria are silently ignored — they exist in the YAML artifact but are never read by any gate
- The orchestrator's remediation routing (step 12→researcher) only triggers on `BLOCKED` or explicit FAIL status, not on `DONE_WITH_CONCERNS`

### Root Cause Analysis

1. **Result contract status ≠ per_criterion health.** The sub-agent can return `DONE_WITH_CONCERNS` as a soft-FAIL that the orchestrator treats as a soft-PASS (it proceeds past it).

2. **No gate reads per_criterion[].** The orchestrator reads the result contract (frugal, routing-only data), not the full YAML artifact. The per_criterion[] content goes to disk and is only read on explicit FAIL routing (Step 12 remedation routing) — not on every step.

3. **Z3 cannot validate verdict semantics.** The state machine checks `previous_step→current_step` transitions and `pipeline_state` invariants. It has no visibility into whether the step's criteria all passed.

4. **`DONE_WITH_CONCERNS` is a status domain pollution.** It exists in every result contract schema across multiple skills, providing a soft-FAIL escape hatch that the orchestrator never reads.

### Solution

A reusable **verdict classifier sub-agent** inserted between every artifact write and its Z3 state update. The classifier reads the per_criterion[] YAML from disk and produces a binary verdict: `clean_pass | fail`. Default is `fail` (fail-closed). No `DONE_WITH_CONCERNS` in any pipeline gate.

#### Architectural Change

```
Before:                                   After:
sub-agent → result contract → Z3 update   sub-agent → result contract → WRITE ARTIFACT → VERDICT CLASSIFIER → Z3 update
                                                              (reads per_criterion[] YAML)
                                                              (produces step_verdict)
```

The verdict classifier is a **sub-agent slot**, not a new pipeline step. It runs inside the same pipeline step's post-processing as a lightweight YAML read + boolean check. It does not change the pipeline step count or the dispatch routing table's step structure.

### New Skill: verdict-classifier

**Location:** `.opencode/skills/verdict-classifier/`

**Files:**
- `SKILL.md` — skill card with tasks, invocation, and sub-agent routing
- `tasks/classify.md` — single task: read per_criterion[] YAML, produce binary verdict

#### classify Task

**Input:** `artifact_path` — path to any per_criterion[] YAML file on disk.

**Rule:**
- All `result: PASS` → `step_verdict: clean_pass`
- Any `result: FAIL` → `step_verdict: fail`
- Any `result: INCONCLUSIVE` or unrecognized → `step_verdict: fail`
- Empty per_criterion[] or absent file → `step_verdict: fail` (fail-closed)
- Single-criterion artifacts (no per_criterion[] array) → check `status` field: `PASS` → `clean_pass`, anything else → `fail`

**Output:** Frugal result contract:
```yaml
status: DONE
step_verdict: clean_pass | fail
artifact_path: "<path to artifact checked>"
verdict_source: "per_criterion[].result aggregation"
summary: "N criteria: X pass, Y fail → verdict: clean_pass|fail"
```

**Fail-closed default:** Any error reading the YAML, any unrecognized schema, any missing file → `step_verdict: fail`. The classifier MUST NOT produce `DONE_WITH_CONCERNS` or any soft status. The only valid `step_verdict` values are `clean_pass` and `fail`.

#### SKILL.md Structure

```
name: verdict-classifier
description: "Use when enforcing per_criterion[] → step_verdict alignment after any pipeline artifact write. Triggers on: verdict, classify, per_criterion enforcement, step verdict. A pipeline step whose per_criterion[] contains any FAIL is a failed step — no soft statuses, no reclassification, no DONE_WITH_CONCERNS."
type: gate
license: MIT
provenance: AI-generated
```

Sub-agent routing: single task `classify` dispatched via `task(subagent_type="general")`. Receives only `artifact_path`. Returns only `{status, step_verdict, artifact_path, summary}`. No context from orchestrator beyond the path.

### Z3 State Machine Changes

**File:** `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

**New variable:**
```yaml
step_verdict:
  type: string
  domain: [clean_pass, fail]
```

**New precondition:**
```yaml
- "z3.Implies(pipeline_state == z3.StringVal('running'), z3.Or(step_verdict == z3.StringVal('clean_pass'), step_verdict == z3.StringVal('fail')))"
```

**New postcondition:**
```yaml
- "z3.Implies(step_verdict == z3.StringVal('fail'), pipeline_state == z3.StringVal('failed'))"
```

**Solve state update sequence changes:**
After the verdict classifier returns, the orchestrator writes `step_verdict` to solve state before the `pipeline_state` update:

```
solve state update ./tmp/state/{ISSUE}/pipeline/ --var-name step_verdict --var-value clean_pass|fail --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

This is inserted between the `current_step` update and the `pipeline_state` update in the existing 3-call sequence (becoming a 4-call sequence):

```
solve state update ... --var-name previous_step --var-value <current-step-label>
solve state update ... --var-name current_step --var-value <next-step-label>
solve state update ... --var-name step_verdict --var-value <clean_pass|fail>        # NEW
solve state update ... --var-name pipeline_state --var-value running|failed         # MODIFIED
```

When `step_verdict == fail`, `pipeline_state` MUST be `failed` — the orchestrator routes to the FAIL→Researcher remediation protocol instead of proceeding to the next step.

### Pipeline-Executor Dispatch Table Changes

**File:** `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

**Post-Step Procedure (after line 47, before Z3 state integration section):**

Insert a verdict classifier sub-agent slot after every step that produces a `per_criterion[]` artifact. The orchestrator dispatches `verdict-classifier --task classify` with `artifact_path: <path-to-just-written-YAML>`. The result determines whether Z3 updates `pipeline_state` to `running` or `failed`.

**Affected step labels** (produce `per_criterion[]` YAML):
1. `sc-coherence-gate` — line 30
2. `red-phase` — line 32
3. `red-doublecheck` — line 33
4. `green-phase` — line 34
5. `green-doublecheck` — line 37
6. `adversarial-audit` — line 39
7. `cross-validate` — line 40 (produces YAML with `summary.overall_consensus` — classifier reads `overall_consensus`)
8. `regression-check` — line 41

**Steps NOT affected** (single-criterion or no per_criterion[]):
- `pre-red-baseline` (step 2) — creates state file, no SC-verification artifact
- `checkpoint-commit` (step 6) — single-criterion (`commit status`)
- `structural-checks` (step 7) — single-criterion (`lint/typecheck/format`)
- `green-vbc` (step 9) — single-criterion completion artifact
- `review-prep` (step 13) — single-criterion
- `exec-summary` (step 14) — single-criterion

For single-criterion steps, the existing `status: PASS | FAIL` in the result contract IS the verdict — no classifier needed.

### DONE_WITH_CONCERNS Removal

**Remove `DONE_WITH_CONCERNS` from ALL status domains in:**

| File | Current | Change |
|------|---------|--------|
| `skills/implementation-pipeline/tasks/pipeline-executor.md` line 190 | `status: DONE \| BLOCKED \| DONE_WITH_CONCERNS \| OVERFLOW` | Remove `DONE_WITH_CONCERNS` |
| `skills/approval-gate/SKILL.md` line 10 | `status (DONE/BLOCKED/DONE_WITH_CONCERNS/OVERFLOW)` | Remove `DONE_WITH_CONCERNS` |
| `skills/approval-gate/tasks/screen/screen-issue-gate2.md` line 182 | `status: DONE \| DONE_WITH_CONCERNS \| BLOCKED \| OVERFLOW` | Remove `DONE_WITH_CONCERNS` |
| `skills/implementation-pipeline/enforcement/work-state-verification.md` line 11 | `Sub-agent completed \| Result contract exists with status DONE or DONE_WITH_CONCERNS` | Change to `status DONE` |
| `guidelines/020-go-prohibitions.md` line 151 | `DONE / BLOCKED / DONE_WITH_CONCERNS` | Remove `DONE_WITH_CONCERNS` |
| `tests/behaviors/post-flight-no-uncommitted.sh` | Tests for DONE_WITH_CONCERNS pattern | Remove test case; pattern no longer exists |
| `tests/794-dc-redesign-content.sh` | References DONE_WITH_CONCERNS | Remove reference |

New status domain: `DONE | BLOCKED | OVERFLOW` — no `DONE_WITH_CONCERNS` anywhere.

### Combinated with Cross-Validate Changes

Cross-validate.md already correctly enforces binary PASS/FAIL (no DONE_WITH_CONCERNS at verdict level). However, the cross-validate YAML contains `summary.overall_consensus: PASS|FAIL` — the verdict classifier reads this field directly. No change needed to cross-validate's internal logic.

### Affected Skills Complete Table

| Skill | Task File | Artifact Schema | Uses Soft Status? | Classifier Needed? | Change |
|-------|-----------|-----------------|-------------------|--------------------|--------|
| implementation-pipeline | tasks/pipeline-executor.md | `per_criterion[]` + single-criterion | Yes (`DONE_WITH_CONCERNS` line 190) | Yes — slot classifier after per_criterion[] steps | Remove DONE_WITH_CONCERNS; add classifier dispatch; update Z3 sequence |
| implementation-pipeline | pipeline-state-machine.yaml | Z3 state | No | No (adds step_verdict) | Add `step_verdict` variable; add precondition + postcondition |
| verification-before-completion | tasks/verify.md | `per_criterion[]` in Per-SC Evidence Table | No (PASS/FAIL/MISSING) | No — existing output already binary | Minor: ensure PASS/FAIL/MISSING maps to classifier (MISSING → fail) |
| adversarial-audit | tasks/verification-audit.md | `per_criterion[]` YAML | No (binary PASS/FAIL) | Yes — slot after artifact write | Insert classifier dispatch |
| adversarial-audit | tasks/spec-audit.md | `per_criterion[]` YAML | No | Yes | Insert classifier dispatch |
| adversarial-audit | tasks/plan-fidelity.md | `per_criterion[]` YAML | No | Yes | Insert classifier dispatch |
| adversarial-audit | tasks/concern-separation.md | `per_criterion[]` YAML | No | Yes | Insert classifier dispatch |
| adversarial-audit | tasks/guideline-audit.md | `per_criterion[]` YAML | No | Yes | Insert classifier dispatch |
| adversarial-audit | tasks/closure-verification.md | `per_criterion[]` YAML | No | Yes | Insert classifier dispatch |
| adversarial-audit | tasks/cross-validate.md | aggregated YAML with `overall_consensus` | No (binary) | Yes (reads `overall_consensus`) | Insert classifier dispatch |
| adversarial-audit | tasks/coherence-extraction.md | coherence check results | No | Unclear schema | Needs audit to determine |
| approval-gate | SKILL.md | result contracts | Yes (`DONE_WITH_CONCERNS`) | N/A — approval gate doesn't produce per_criterion[] | Remove DONE_WITH_CONCERNS from status domain |
| approval-gate | tasks/screen/screen-issue-gate2.md | result contracts | Yes (`DONE_WITH_CONCERNS`) | N/A | Remove DONE_WITH_CONCERNS from status domain |
| completeness-gate | tasks/check.md | PASS/FAIL output contract | No | No (single-criterion already binary) | No change needed |
| test-driven-development | tasks/red.md | `per_criterion[]` YAML | No (test output = PASS/FAIL) | Yes — slot after RED test run | Insert classifier dispatch |
| test-driven-development | tasks/green.md | `per_criterion[]` YAML | No | Yes | Insert classifier dispatch |
| test-driven-development | tasks/patterns.md (regression) | `per_criterion[]` YAML | No | Yes | Insert classifier dispatch |
| completion-core | tasks/completion.md | single-criterion | No | No | No change needed |
| git-workflow | tasks/commit-prep.md | single-criterion | No | No | No change needed |
| git-workflow | tasks/review-prep.md | single-criterion | No | No | No change needed |
| finishing-a-development-branch | tasks/checklist.md | single-criterion | No | No | No change needed |

### Implementation Phases

#### Phase 1: Create verdict-classifier skill

Files to create:
- `.opencode/skills/verdict-classifier/SKILL.md`
- `.opencode/skills/verdict-classifier/tasks/classify.md`

Behavioral test (RED): Verify a sub-agent that receives an artifact with 2/5 FAILs returns `step_verdict: fail`. Verify a sub-agent that receives an artifact with all PASS returns `step_verdict: clean_pass`. Verify a sub-agent that receives a malformed/empty artifact returns `step_verdict: fail` (fail-closed).

#### Phase 2: Update pipeline-executor.md dispatch table

Changes:
1. Remove `DONE_WITH_CONCERNS` from result contract schema (line 190)
2. Add verdict classifier sub-agent slot in post-step procedure section
3. Update Z3 state update sequence from 3-call to 4-call (insert `step_verdict`)
4. Update the 8 steps that produce `per_criterion[]` to dispatch classifier after artifact write

#### Phase 3: Update all other affected skill cards

Changes:
1. `approval-gate/SKILL.md` — remove DONE_WITH_CONCERNS from status domain
2. `approval-gate/tasks/screen/screen-issue-gate2.md` — remove DONE_WITH_CONCERNS
3. `implementation-pipeline/enforcement/work-state-verification.md` — remove DONE_WITH_CONCERNS
4. `guidelines/020-go-prohibitions.md` — remove DONE_WITH_CONCERNS from result contract schema
5. `tests/behaviors/post-flight-no-uncommitted.sh` — remove/update DONE_WITH_CONCERNS test
6. `tests/794-dc-redesign-content.sh` — remove DONE_WITH_CONCERNS reference

#### Phase 4: Update Z3 state machine

Changes to `pipeline-state-machine.yaml`:
1. Add `step_verdict` variable with `domain: [clean_pass, fail]`
2. Add precondition linking `pipeline_state == running` to valid step_verdict values
3. Add postcondition: `Implies(step_verdict == fail, pipeline_state == failed)`

#### Phase 5: Enforcement tests

See Success Criteria below.

### Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Verdict classifier sub-agent receives artifact with 2/5 FAIL per_criterion → returns `step_verdict: fail` | `behavioral` | `opencode-cli run` → sub-agent dispatch artifact → verify result contract |
| SC-2 | Verdict classifier sub-agent receives artifact with all PASS per_criterion → returns `step_verdict: clean_pass` | `behavioral` | `opencode-cli run` → sub-agent dispatch artifact → verify result contract |
| SC-3 | Verdict classifier sub-agent receives empty/missing artifact → returns `step_verdict: fail` (fail-closed) | `behavioral` | `opencode-cli run` → sub-agent with no valid YAML → verify fail |
| SC-4 | Pipeline-executor dispatch table removes `DONE_WITH_CONCERNS` from result contract status domain | `structural` | `grep -c DONE_WITH_CONCERNS` on pipeline-executor.md → 0 matches |
| SC-5 | Z3 state machine has `step_verdict` variable with domain `[clean_pass, fail]` | `structural` | Parse pipeline-state-machine.yaml → verify variable exists |
| SC-6 | Z3 postcondition `Implies(step_verdict == fail, pipeline_state == failed)` exists | `structural` | Parse pipeline-state-machine.yaml → verify postcondition |
| SC-7 | Zero occurrences of `DONE_WITH_CONCERNS` in any SKILL.md or task file | `structural` | `grep -r DONE_WITH_CONCERNS .opencode/skills/` → 0 matches |
| SC-8 | Zero occurrences of `DONE_WITH_CONCERNS` in guidelines/020-go-prohibitions.md | `structural` | `grep DONE_WITH_CONCERNS .opencode/guidelines/020-go-prohibitions.md` → 0 matches |
| SC-9 | Pipeline orchestrator dispatches verdict classifier after every per_criterion[] artifact write during implementation pipeline run | `behavioral` | `opencode-cli run` → verify stderr contains `Skill "verdict-classifier"` after each applicable step |

### Online Research Integration

The verdict classifier pattern is validated by existing systems:

1. **pytest aggregation model** — pytest aggregates per-test PASS/FAIL into overall session PASS/FAIL. A single failing test produces overall FAIL. No "DONE_WITH_CONCERNS" equivalent exists in pytest's test result model — every test is PASS, FAIL, SKIP, or ERROR. The verdict classifier applies the same binary aggregation to per_criterion[] array entries. This is the canonical pattern the classifier implements.

2. **Azure AI Agent Orchestration Patterns** — The sequential orchestration pattern described in [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns) explicitly warns: "Early stages might fail or produce low-quality output, and there's no reasonable way to prevent later steps from processing by using accumulated error output" — this is exactly the gap the verdict classifier fills. Without per-step verdict enforcement, agent pipeline orchestrators cannot detect that a step's sub-checks failed and must re-route.

3. **GitHub Actions `if: success()` gates** — Every GitHub Actions step runs conditionally on the previous step's success. `if: success()` is the default behavior — a step only runs when all previous steps passed. The verdict classifier implements the same logic: if the per_criterion[] array contains any FAIL, `step_verdict: fail` → `pipeline_state: failed` → next step does not dispatch. This maps to GitHub Actions' `fail-fast` behavior.

4. **Jenkins Pipeline error propagation** — Jenkins Pipeline steps throw exceptions on failure, which propagate up the stage graph. Unlike agent pipelines (where sub-agents return contracts instead of throwing), Jenkins' exception model forces every failure to be caught or escalate. The verdict classifier provides the equivalent enforcement — a per_criterion FAIL MUST escalate to step_verdict fail via the classifier gate, not silently pass through a soft status.

5. **Cross-validate binary verdict enforcement** — The existing cross-validate.md task (lines 150-182) already enforces that auditor verdicts must be `PASS` or `FAIL` only. It explicitly prohibits INCONCLUSIVE. The verdict classifier extends this same binary enforcement from the audit stage to ALL pipeline steps that produce per_criterion[] YAML artifacts.

### Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Verdict classifier adds latency (1 extra sub-agent dispatch per step) | Low — each dispatch is a YAML read + boolean check (≈5s per step) | Keep classifier lightweight; no model inference needed — pure YAML parsing logic |
| Fail-closed default could block pipeline on transient errors | Medium — YAML write failure causes step_verdict: fail | The remedation routing already handles this; researcher dispatch determines whether retry or escalate |
| DONE_WITH_CONCERNS removal breaks existing behavioral tests | Medium — tests check for this pattern | Update tests in Phase 3; the behavioral tests for verdict classifier replace the soft-status tests |
| Pipeline steps with single-criterion schema don't need classifier | Low — their `status: PASS/FAIL` in the result contract IS the verdict | No classifier dispatch for single-criterion steps; documented in affected steps table |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)