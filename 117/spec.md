---
type: SPEC
status: DRAFT
version: 1.0
created: 2026-05-21
labels: [SPEC, adversarial-audit, artifact-pre-check, clean-fail]
priority: high
---

# [SPEC] Adversarial Auditor Artifact Pre-Check and Clean FAIL on Missing Artifacts

## Intent and Executive Summary

**Problem Statement:** Adversarial auditors are dispatched for evaluation but encounter missing test artifacts (timing issue — artifacts haven't been produced yet, or artifact paths weren't included in dispatch context). Instead of failing cleanly with a structured "FAIL: missing test artifacts" response, auditors attempt to run tests themselves using `bash`/`uv run pytest` or dispatch their own sub-agents via `task()` to produce the artifacts. This violates the clean-room auditor contract — auditors evaluate delivered artifacts, they do not produce them.

Additionally, when auditors fail due to missing artifacts, the orchestrator has no structured restart protocol. The fix requires: (1) mandatory pre-check in every auditor task, (2) structured FAIL return for missing artifacts, (3) all re-audits restart from resolve-models/selection with fresh dual cross-family auditors — never re-dispatching the same auditor pair.

**Root Cause / Motivation:** Auditor tasks currently check for prerequisites in their "Entry Criteria" section, but the pre-check is descriptive prose, not an enforced gate. The error handling section lists `Return BLOCKED` for missing prerequisites, but BLOCKED is ambiguous — it doesn't distinguish between "I can't do my job because the prerequisites aren't here" and "I encountered a processing error." Auditors need a specific, machine-parseable FAIL signal for missing artifacts that triggers a well-defined restart protocol.

**Approach Chosen:** Insert a mandatory "Artifact Pre-Check" step as the first step in every auditor task file. If any required artifact is missing, the auditor returns a structured JSON result contract with `status: FAIL`, `fail_type: MISSING_ARTIFACTS`, and `missing_artifacts: [<path1>, <path2>, ...]`. The orchestrator recognizes this specific fail type and restarts the full adversarial cycle from `resolve-models` (fresh model selection, fresh dual cross-family dispatch), after re-producing the missing artifacts. This is NOT a retry — it's a complete cycle restart.

**Alternatives Considered & Why Discarded:**
- **Return BLOCKED for missing artifacts:** BLOCKED is already used for authorization/configuration errors. Conflating missing artifacts with authorization errors makes recovery ambiguous.
- **Re-dispatch same auditor pair on missing artifacts:** Violates adversarial-audit-022 (resolve-models must be called fresh every iteration). Reusing cached selections is prohibited.
- **Allow auditors to produce missing artifacts:** Violates the clean-room auditor contract. Auditors must never run tests, execute bash commands, or dispatch sub-agents to produce deliverables. Their role is evaluation only.

**Key Design Decisions:**
1. Mandatory artifact pre-check as Step 0 (before evaluation) in every auditor task
2. Structured `MISSING_ARTIFACTS` fail type in the result contract, distinct from BLOCKED
3. All re-audits always restart from resolve-models/selection with fresh dual cross-family auditors — not a special path, just the universal default
4. Auditors MUST NOT execute test commands (`bash`, `uv run pytest`, etc.) or dispatch `task()` sub-agents — their authority is read-evaluate only

## Objective

Enforce clean-room auditor discipline by requiring artifact pre-checks, producing structured FAIL signals for missing artifacts, never attempting to produce artifacts, and always restarting the full adversarial cycle from resolve-models on re-audit.

## Problem

### Current Behavior

| File | Current Entry Criteria | What Happens When Artifacts Missing |
|------|----------------------|-------------------------------------|
| `test-quality-audit.md` | "VbC evidence artifact completed" | Error handling says "Return BLOCKED — prerequisite unmet" but auditors sometimes attempt to run tests instead |
| `spec-audit.md` | "Spec issue number provided OR spec content provided" | Returns BLOCKED but no structured artifact-missing signal |
| `plan-fidelity.md` | "Plan issue number provided" | Returns BLOCKED |
| All auditor tasks | Descriptive prose in Entry Criteria | No enforced gate, no structured missing-artifact signal |

### Structural Problems

1. **Missing pre-check gate:** Entry criteria are descriptive prose, not enforced — auditors can proceed past them without checking artifact existence.
2. **No structured MISSING_ARTIFACTS signal:** BLOCKED is used for authorization errors AND missing prerequisites, making recovery ambiguous.
3. **No prohibition on test execution:** Auditor tasks don't explicitly prohibit running tests or dispatching sub-agents to produce artifacts.
4. **No restart-from-select protocol:** Re-audit paths are described per-situation (1st FAIL → re-task, 2nd FAIL → spec-audit, 3rd FAIL → BLOCKED) but missing artifacts aren't in this flow — they need a clear "reproduce artifacts, then restart full cycle from resolve-models" path.
5. **No single canonical "select" entry point:** The resolve-models → dispatch → cross-validate chain is described across SKILL.md and multiple task files but has no single named entry point that all re-audits use.

## Context

### Auditor Task Contract

Every auditor task currently follows this structure:

```
1. Entry Criteria (prose — not enforced)
2. Task Context (JSON — what context the sub-agent receives)
3. Procedure (steps 1-N — evaluation logic)
4. Result Contract (JSON — status + findings)
5. Error Handling (table — BLOCKED/FAIL/ERROR)
```

The proposed change adds an **enforced gate** between Entry Criteria and Procedure:

```
0. Artifact Pre-Check (mandatory, before any evaluation)
   → If missing: return structured FAIL immediately
   → No evaluation, no bash, no task(), no retries
1-N. Procedure (steps 1-N — evaluation logic, unchanged)
```

### Re-Audit Flow (Current vs Proposed)

**Current:** Each re-audit reason has its own recovery path:
- 1st non-PASS: re-task with fresh model pair
- 2nd non-PASS: route to spec-audit
- 3rd non-PASS: BLOCKED

**Proposed:** Add one new recovery path for MISSING_ARTIFACTS, and unify all re-audits under a single principle:

- MISSING_ARTIFACTS FAIL: Reproduce artifacts → restart full cycle from resolve-models (fresh selection, fresh dual dispatch)
- Any other re-audit: Already specified as restarting from resolve-models per adversarial-audit-022

**The key principle: ALL re-audits, regardless of trigger reason, restart from resolve-models with fresh dual cross-family auditors. This is not a special case — it's the universal default.**

## Fix Approach

### Changes by File

#### 1. `adversarial-audit/SKILL.md` — Add symbolic rule and task context table update

Add symbolic rule `adversarial-audit-024`:

```yaml+symbolic
- id: adversarial-audit-024
  title: "Artifact pre-check mandatory — auditor fails immediately on missing artifacts, never executes tests or dispatches sub-agents"
  conditions:
    any:
      - "auditor_task_file_path_exists == false"
      - "required_artifact_missing == true"
      - "auditor_attempting_bash_or_task == true"
  actions:
    - FAIL
    - RETURN_MISSING_ARTIFACTS_CONTRACT
  source: "adversarial-audit/SKILL.md §Artifact Pre-Check"
```

Add to Dispatch Context Contract table — new `must_receive` field for each auditor task that requires artifacts:

| Task | Updated `must_receive` |
|------|----------------------|
| `test-quality-audit` | `spec_success_criteria, file_paths_changed, vbc_artifact_path, worktree.path, github.owner, github.repo` (add `required_artifacts` field listing artifact paths) |
| `plan-fidelity` | `spec_issue, plan_issue, clean_room_plan, ...` (add `required_artifacts` field listing artifact paths) |
| `spec-audit` | `spec_issue, ...` (add `required_artifacts` field listing artifact paths) |
| Other auditor tasks | Add `required_artifacts` field listing artifact paths (empty list for tasks that don't require external artifacts) |

Add to Encapsulation Rules table:

| Operation | Forbidden Pattern | Correct Pattern |
|-----------|------------------|-----------------|
| Running tests | `bash`, `uv run pytest`, `npm test`, any test execution command | Return `FAIL` with `fail_type: MISSING_ARTIFACTS` |
| Dispatching sub-agents to produce artifacts | `task(subagent_type=...)` invoked by auditor to create test artifacts | Return `FAIL` with `fail_type: MISSING_ARTIFACTS` |
| Proceeding past pre-check | Skipping artifact verification when `required_artifacts` is non-empty | HALT at Step 0, return structured FAIL |

Add to DISPATCH_GATE section:

```
### Artifact Pre-Check Gate (Step 0)

Every auditor task MUST execute the artifact pre-check as the FIRST step before any evaluation. The pre-check verifies that all artifacts listed in `required_artifacts` exist and are accessible.

**If any artifact is missing:**
1. Return immediately with structured FAIL result contract (see Result Contract below)
2. Do NOT proceed to evaluation steps
3. Do NOT attempt to produce the missing artifact (no bash, no task(), no file creation)
4. Do NOT retry or fall back — return FAIL and let the orchestrator handle recovery

**The orchestrator recovery protocol for MISSING_ARTIFACTS:**
1. Re-produce the missing artifacts using the appropriate pipeline stage (e.g., re-run RED/GREEN, re-run VbC)
2. Restart the full adversarial cycle from resolve-models (fresh model selection, fresh dual cross-family dispatch)
3. This is NOT a retry — it is a complete cycle restart with new auditor assignment
```

#### 2. `adversarial-audit/tasks/test-quality-audit.md` — Add Step 0 and update error handling

Add Step 0 before Step 1:

```markdown
### Step 0: Artifact Pre-Check (MANDATORY GATE)

Before any evaluation, verify that all required artifacts exist and are accessible:

| Artifact | Path Pattern | Check |
|----------|-------------|-------|
| VbC evidence artifact | `{vbc_artifact_path}` | File exists and is readable |
| Test files | `{file_paths_changed}` (each path) | Each file exists and is readable |
| Spec success criteria | Via `{spec_success_criteria}` | Criteria list is non-empty |

**If any artifact is missing:**

Return immediately with structured FAIL result contract:

```json
{
  "status": "FAIL",
  "fail_type": "MISSING_ARTIFACTS",
  "missing_artifacts": ["<path1>", "<path2>"],
  "audit_type": "test-quality-audit",
  "overall": "FAIL",
  "criteria": [],
  "exec_summary": "FAIL: test-quality-audit requires artifacts that are not available. Missing: [<paths>]. The orchestrator must reproduce these artifacts and restart the full adversarial cycle from resolve-models."
}
```

**FORBIDDEN actions when artifacts are missing:**
- Running tests via `bash`, `uv run pytest`, `npm test`, or any test execution command
- Dispatching sub-agents via `task()` to produce test artifacts
- Proceeding to evaluation steps with partial artifacts
- Retrying artifact access or falling back to alternative paths

Return FAIL and let the orchestrator handle recovery.
```

Update Error Handling table:

| Error | Action |
|-------|--------|
| Required artifact not found | Return FAIL with `fail_type: MISSING_ARTIFACTS` and list of missing paths (Step 0) |
| Auditor attempts test execution | Return FAIL with `fail_type: AUDITOR_CONTRACT_VIOLATION` (this should never happen — it's a defensive check) |
| VbC artifact unavailable | Return FAIL with `fail_type: MISSING_ARTIFACTS` (merged with Step 0, not separate error) |
| No git history for weakening check | Mark assertion_weakening as FAIL (inconclusive) with note |

#### 3. `adversarial-audit/tasks/spec-audit.md` — Add Step 0 and update error handling

Add Step 0 before Step 1:

```markdown
### Step 0: Artifact Pre-Check (MANDATORY GATE)

Before any evaluation, verify that all required artifacts exist and are accessible:

| Artifact | Path Pattern | Check |
|----------|-------------|-------|
| Spec content | Via `{spec_issue}` issue number | Issue exists and body is non-empty |

**If any artifact is missing:**

Return immediately with structured FAIL result contract:

```json
{
  "status": "FAIL",
  "fail_type": "MISSING_ARTIFACTS",
  "missing_artifacts": ["spec issue #<N> body"],
  "audit_type": "spec-audit",
  "overall": "FAIL",
  "criteria": [],
  "exec_summary": "FAIL: spec-audit requires artifacts that are not available. Missing: [spec issue #<N> body]. The orchestrator must reproduce these artifacts and restart the full adversarial cycle from resolve-models."
}
```

**FORBIDDEN actions when artifacts are missing:**
- Dispatching sub-agents via `task()` to produce spec content
- Proceeding to evaluation steps with missing spec
- Retrying artifact access

Return FAIL and let the orchestrator handle recovery.
```

Update Error Handling table:

| Error | Action |
|-------|--------|
| Spec issue not found | Return FAIL with `fail_type: MISSING_ARTIFACTS` and issue number |
| Spec body empty | Return FAIL with `fail_type: MISSING_ARTIFACTS` and "spec body is empty" |
| Cross-validate fails | Return OVERFLOW, log error |

#### 4. `adversarial-audit/tasks/plan-fidelity.md` — Add Step 0 and update error handling

Add Step 0 with required artifacts for plan fidelity:

| Artifact | Path Pattern | Check |
|----------|-------------|-------|
| Spec issue | Via `{spec_issue}` | Issue exists and body is non-empty |
| Plan issue | Via `{plan_issue}` | Issue exists and body is non-empty |
| Clean-room plan | Via `{clean_room_plan}` | Plan text is provided in context |

Same FAIL structure with `missing_artifacts` listing the specific missing items.

#### 5. All other auditor task files — Add Step 0

Each auditor task file gets a Step 0 with its own required artifacts table and the same FAIL structure:

- `concern-separation.md` — requires spec issue
- `coherence-extraction.md` — requires guideline files in target_files
- `coherence-maintenance.md` — requires baseline file at `{baseline_path}`
- `guideline-audit.md` — requires target guideline files
- `drift-detection.md` — requires spec issue and baseline files
- `spec-summary.md` — requires PR and spec issue
- `closure-verification.md` — requires PR number and merge evidence

#### 6. `adversarial-audit/SKILL.md` — Add re-audit restart protocol documentation

Add section after DISPATCH_GATE:

```markdown
### Re-Audit Restart Protocol (ALL Re-Audits)

ALL re-audits, regardless of trigger reason, restart the full adversarial cycle from resolve-models. This is the universal default, not a special case.

**Trigger: ANY re-audit**
- Missing artifacts (MISSING_ARTIFACTS fail)
- 1st non-PASS at same pipeline stage
- Developer-requested re-audit after revision
- Any other re-audit reason

**Recovery protocol — same for all triggers:**
1. Orchestrator resolves what needs to be re-produced (missing artifacts, revised deliverables, etc.)
2. Orchestrator re-produces the artifacts using the appropriate pipeline stage
3. Orchestrator restarts the full adversarial cycle from resolve-models:
   a. `task(resolve-models sub-agent)` → fresh model pair selection
   b. `task(auditor_1, clean-room)` → fresh evaluation with new artifacts
   c. `task(auditor_2, clean-room)` → fresh evaluation with new artifacts
   d. `task(cross-validate sub-agent)` → consensus computation
4. No cached auditor selections, no re-dispatch of the same pair, no short-circuiting

**This is NOT a retry.** It is a complete cycle restart with new auditor assignment and new concern distribution.
```

Update `adversarial-audit-019`, `adversarial-audit-020`, `adversarial-audit-021` to reference the universal restart protocol:

```yaml+symbolic
- id: adversarial-audit-019
  title: "1st non-PASS triggers full cycle restart from resolve-models"
  conditions:
    all: ["result != 'PASS'", "pipeline_stage == previous_stage", "attempt_count == 1"]
  actions: [RESTART_CYCLE_FROM_RESOLVE_MODELS]
  source: "adversarial-audit/SKILL.md §Re-Audit Restart Protocol"

- id: adversarial-audit-020
  title: "2nd consecutive non-PASS routes to spec-audit with failure_description, restart from resolve-models"
  conditions:
    all: ["result != 'PASS'", "pipeline_stage == previous_stage", "attempt_count == 2"]
  actions: [ROUTE_SPEC_AUDIT_WITH_FAILURE, RESTART_CYCLE_FROM_RESOLVE_MODELS]
  source: "adversarial-audit/SKILL.md §Re-Audit Restart Protocol"

- id: adversarial-audit-021
  title: "3rd consecutive non-PASS triggers BLOCKED — pipeline halt, human intervention"
  conditions:
    all: ["result != 'PASS'", "pipeline_stage == previous_stage", "attempt_count == 3"]
  actions: [BLOCK_PIPELINE, HALT, REPORT_EXECUTIVE_SUMMARY]
  source: "adversarial-audit/SKILL.md §Re-Audit Restart Protocol"

- id: adversarial-audit-024
  title: "Artifact pre-check mandatory — auditor fails immediately on missing artifacts, never executes tests or dispatches sub-agents"
  conditions:
    any:
      - "required_artifact_missing == true"
      - "auditor_attempting_bash_or_task == true"
  actions: [FAIL, RETURN_MISSING_ARTIFACTS_CONTRACT]
  source: "adversarial-audit/SKILL.md §Artifact Pre-Check"

- id: adversarial-audit-025
  title: "Re-audit always restarts from resolve-models with fresh dual cross-family auditors"
  conditions:
    all: ["re_audit_triggered == true"]
  actions: [RESTART_FROM_RESOLVE_MODELS, FRESH_DUAL_AUDITOR_DISPATCH]
  source: "adversarial-audit/SKILL.md §Re-Audit Restart Protocol"
```

#### 7. Behavioral enforcement test

Create `.opencode/tests/behaviors/adversarial-audit-artifact-pre-check.sh`:

- **Test 1:** Prompt an auditor with missing VbC artifact path → assert `FAIL: MISSING_ARTIFACTS` in response, assert no `bash` or `uv run pytest` or `task()` calls in stderr
- **Test 2:** Prompt an auditor with all artifacts present → assert proceeds to evaluation (no MISSING_ARTIFACTS fail)

## Success Criteria

| ID | Criterion | Verification Method | Remediation |
|----|-----------|---------------------|-------------|
| SC-1 | Every auditor task file has Step 0 (Artifact Pre-Check) with required_artifacts table | `grep -l "Step 0: Artifact Pre-Check" .opencode/skills/adversarial-audit/tasks/*.md` returns all task files | Add Step 0 to missing task files |
| SC-2 | Every auditor task file has `FORBIDDEN actions` section prohibiting bash/test-execution and task() dispatch | `grep -l "FORBIDDEN.*bash" .opencode/skills/adversarial-audit/tasks/*.md` returns all task files | Add FORBIDDEN section |
| SC-3 | SKILL.md has adversarial-audit-024 rule for artifact pre-check enforcement | `grep "adversarial-audit-024" .opencode/skills/adversarial-audit/SKILL.md` returns match | Add rule |
| SC-4 | SKILL.md has adversarial-audit-025 rule for universal re-audit restart from resolve-models | `grep "adversarial-audit-025" .opencode/skills/adversarial-audit/SKILL.md` returns match | Add rule |
| SC-5 | SKILL.md has re-audit restart protocol documentation section | `grep "Re-Audit Restart Protocol" .opencode/skills/adversarial-audit/SKILL.md` returns match | Add section |
| SC-6 | SKILL.md DISPATCH_GATE section includes artifact pre-check gate documentation | `grep "Artifact Pre-Check Gate" .opencode/skills/adversarial-audit/SKILL.md` returns match | Add gate documentation |
| SC-7 | SKILL.md Encapsulation Rules table includes test execution and sub-agent dispatch prohibitions | `grep "Running tests" .opencode/skills/adversarial-audit/SKILL.md` returns match AND `grep "Dispatching sub-agents" .opencode/skills/adversarial-audit/SKILL.md` returns match | Add rows to table |
| SC-8 | test-quality-audit.md Step 0 returns MISSING_ARTIFACTS when VbC artifact missing | `grep "MISSING_ARTIFACTS" .opencode/skills/adversarial-audit/tasks/test-quality-audit.md` returns match | Add FAIL response |
| SC-9 | test-quality-audit.md Error Handling table has artifact-missing entry instead of just BLOCKED | `grep "required artifact not found" .opencode/skills/adversarial-audit/tasks/test-quality-audit.md` returns match (case-insensitive) | Update error handling |
| SC-10 | Behavioral test exists and FAILS before implementation (RED phase) | `bash .opencode/tests/with-test-home opencode-cli run "audit test quality where VbC artifact is missing"` → assert stderr contains "MISSING_ARTIFACTS" and no test execution commands | Create RED test |
| SC-11 | Behavioral test PASSES after implementation (GREEN phase) | Re-run test from SC-10 → OVERALL_RESULT=0 | Implement changes |
| SC-12 | Result contract includes `fail_type: MISSING_ARTIFACTS` for missing artifact returns | `grep "fail_type.*MISSING_ARTIFACTS" .opencode/skills/adversarial-audit/tasks/test-quality-audit.md` returns match | Add fail_type to result contract |
| SC-13 | Every audit task has `required_artifacts` in must_receive dispatch context | `grep -l "required_artifacts" .opencode/skills/adversarial-audit/tasks/*.md` returns all task files that use external artifacts | Add required_artifacts to dispatch context |
| SC-14 | adversarial-audit-019 through -021 updated to reference universal restart protocol | `grep "restart" .opencode/skills/adversarial-audit/SKILL.md` references resolve-models restart, not "re-task" | Update rule descriptions |

## Edge Cases

1. **Artifact path provided but file is empty (0 bytes):** This is NOT MISSING_ARTIFACTS — it's a structural deficiency. The auditor should proceed to evaluation and report the deficiency as a criterion FAIL, not trigger a pre-check gate failure.
2. **Artifact path not provided in context at all:** This IS MISSING_ARTIFACTS — the `required_artifacts` list in dispatch context is empty or missing the path. The auditor cannot evaluate without knowing what to evaluate.
3. **Artifact path provided but file doesn't exist yet (timing issue):** This IS MISSING_ARTIFACTS. The orchestrator must re-produce the artifact before restarting the audit cycle.
4. **All artifacts present, but auditor still can't read them:** This is a permissions/access error, not MISSING_ARTIFACTS. Return BLOCKED with the access error details.
5. **Multiple artifacts missing:** Return ALL missing artifacts in the `missing_artifacts` array, not just the first one found.
6. **Re-audit after MISSING_ARTIFACTS with same artifacts still missing:** This is a pipeline error — the orchestrator failed to re-produce the artifacts. The 3-attempt limit applies (per adversarial-audit-019, -020, -021). After 3 consecutive MISSING_ARTIFACTS failures, escalate to BLOCKED with human intervention.

## Dependencies

- **adversarial-audit skill** (current structure): This spec modifies files within the existing adversarial-audit skill
- **divide-and-conquer/assemble-work.md**: The orchestrator that dispatches auditors needs to handle `MISSING_ARTIFACTS` result contracts
- **verification-before-completion skill**: Produces VbC artifacts that test-quality-audit depends on
- **critical-rules.md**: `adversarial-audit-024` and `adversarial-audit-025` are new Tier 2 rules to be added

## Decision Rationale

- **MISSING_ARTIFACTS as a separate fail type (not BLOCKED):** BLOCKED is already overloaded for authorization/configuration errors. A distinct fail type enables machine-parseable recovery routing — the orchestrator can automatically detect "reproduce artifacts and restart" vs "human intervention needed."
- **Universal restart from resolve-models:** All re-audits deserve fresh auditor selection. Reusing cached pairs violates adversarial-audit-022 and defeats the purpose of independent verification. Making this the universal default (not a special case for missing artifacts) simplifies the mental model and removes edge-case-driven complexity.
- **Step 0 as mandatory gate (not optional check):** Entry criteria are currently descriptive prose. Making the pre-check an enforced Step 0 with a structured FAIL return removes the ambiguity that leads auditors to attempt test execution.
- **FORBIDDEN actions list in every task file:** Making the prohibition explicit (no bash, no task(), no test execution) closes the interpretive gap that allows well-meaning auditors to "help" by running tests.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `adversarial-audit/SKILL.md` | Understand current DISPATCH_GATE, symbolic rules, and dispatch context |
| Direct source search | `adversarial-audit/tasks/test-quality-audit.md` | Current entry criteria and error handling for VbC artifacts |
| Direct source search | `adversarial-audit/tasks/spec-audit.md` | Current entry criteria and error handling |
| Direct source search | `adversarial-audit/tasks/completion.md` | Result contract schema and completion dependency chain |
| Direct source search | `adversarial-audit/tasks/resolve-models.md` | Fresh model selection mandate |
| Direct source search | `adversarial-audit/tasks/cross-validate.md` | Cross-validation flow and verdict processing |
| Direct source search | `verification-before-completion/SKILL.md` | VbC artifact production and dispatch context |
| Direct source search | `divide-and-conquer/tasks/assemble-work.md` | Orchestrator pipeline and auditor dispatch flow |

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)*