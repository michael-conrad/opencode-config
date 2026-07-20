## Problem

Every adversarial audit task file declares required entry criteria (`spec_local_dir`, `artifact_evidence_dir`, `clean_room_plan`, etc.) but validates them lazily during step execution — globbing, reading, and searching for items that were supposed to be provided. When inputs are missing, the task wastes context trying to "find" them, produces confusing output, and never tells the orchestrator what remediation is needed.

The orchestrator receives a garbled BLOCKED or a partial result instead of a clear signal: "you didn't provide the required input, here's what to do."

## Root Cause

Each task file's Entry Criteria section says "X is REQUIRED" but the Procedure section doesn't validate X before starting work. The validation is scattered across steps, inconsistent across tasks, and lacks remediation guidance.

## Fix: Pre-Flight Validation Gate (Step 0)

Insert a **Step 0: Pre-Flight Validation Gate** at the top of every audit task file's Procedure section, before any existing step. This gate:

1. Validates ALL required entry criteria before any glob, read, or analysis
2. Returns BLOCKED immediately if any criterion is missing
3. Includes context-specific remediation guidance in the BLOCKED message

### Standardized BLOCKED Format

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "<field_name>"
remediation: "<context-specific message explaining what the orchestrator must do>"
```

### Per-Task Required Inputs

| Task | Required Inputs | VbC Needed? | Plan Needed? |
|------|----------------|-------------|-------------|
| `verification-audit` | `spec_local_dir`, `artifact_evidence_dir` (≥2 YAML verdicts) | Yes — evidence artifacts | No |
| `cross-validate` | `spec_local_dir`, `artifact_evidence_dir` (≥2 YAML verdicts) | No — reads auditor YAMLs | No |
| `spec-audit` | `spec_local_dir` | No | No |
| `plan-fidelity` | `clean_room_plan`, `spec_local_dir` | No | Yes — clean-room plan |
| `concern-separation` | `spec_local_dir` | No | No |
| `drift-detection` | `spec_local_dir` | No | No |
| `closure-verification` | PR number, spec issue number | No | No |
| `spec-summary` | PR number, spec issue number | No | No |
| `guideline-audit` | target file paths | No | No |
| `test-quality-audit` | VbC artifact path, `file_paths_changed`, `spec_success_criteria` | Yes — VbC artifact | No |

### Context-Specific Remediation Messages

| Missing Input | Remediation Message |
|---------------|-------------------|
| `spec_local_dir` | "Spec was not mirrored to local filesystem before dispatch. Run issue-operations to mirror the spec as .md files in spec_local_dir/ first." |
| `artifact_evidence_dir` | "VbC has not been run or evidence artifacts were not saved. Ensure VbC has been run correctly and the full adversarial audit cycle has been performed sub-step by sub-step." |
| `clean_room_plan` | "Plan was not generated via writing-plans sub-agent before dispatch. Run writing-plans to generate a clean-room plan first." |
| `artifact_evidence_dir` with <2 YAML files | "Expected at least 2 auditor YAML verdict files in artifact_evidence_dir but found N. Ensure both auditors completed and wrote their verdicts to disk." |
| target file paths | "Target file paths were not provided. Specify which guideline files to audit." |
| VbC artifact path | "VbC artifact path was not provided. Run verification-before-completion first." |
| `file_paths_changed` | "Changed file paths were not provided. The orchestrator must pass file_paths_changed from the implementation diff." |

### Standardized Step 0 Template

```
### Step 0: Pre-Flight Validation Gate

Before any glob, read, or analysis, validate ALL required entry criteria:

- [ ] 1. Check `<required_input_1>` — if missing or empty, return BLOCKED immediately:
      ```yaml
      status: BLOCKED
      error: MISSING_REQUIRED_INPUT
      missing: "<required_input_1>"
      remediation: "<context-specific message>"
      ```
- [ ] 2. Check `<required_input_2>` — if missing or empty, return BLOCKED immediately (same format)
- [ ] 3. For artifact directories: glob the directory and count files — if fewer than 2 YAML files found, return BLOCKED:
      ```yaml
      status: BLOCKED
      error: INSUFFICIENT_ARTIFACTS
      missing: "<artifact_evidence_dir>"
      files_found: <N>
      remediation: "Expected at least 2 auditor YAML verdict files in '<artifact_evidence_dir>' but found <N>. Ensure both auditors completed and wrote their verdicts to disk."
      ```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately — no globbing, no reading, no analysis. The orchestrator receives the BLOCKED message with remediation guidance and can act on it.
```

### Files to Modify

All 10 task files in `.opencode/skills/adversarial-audit/tasks/`:

1. `verification-audit.md` — Add Step 0, renumber existing steps
2. `cross-validate.md` — Add Step 0, renumber existing steps
3. `spec-audit.md` — Add Step 0, renumber existing steps
4. `plan-fidelity.md` — Add Step 0, renumber existing steps
5. `concern-separation.md` — Add Step 0, renumber existing steps
6. `drift-detection.md` — Add Step 0, renumber existing steps
7. `closure-verification.md` — Add Step 0, renumber existing steps
8. `spec-summary.md` — Add Step 0, renumber existing steps
9. `guideline-audit.md` — Add Step 0, renumber existing steps
10. `test-quality-audit.md` — Add Step 0, renumber existing steps

### Completion Dependency Chains

Every task file's Completion Dependency Chain section must be updated to include Step 0 as the first mandatory dependency.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Every audit task file has a Step 0 Pre-Flight Validation Gate before any other step | `string` — grep for `### Step 0: Pre-Flight Validation Gate` in each of the 10 task files |
| SC-2 | Pre-flight gate validates only the task's own required inputs (per per-task table above) — no task validates inputs it doesn't need | `semantic` — sub-agent reads each file, confirms Step 0 checks match the task's Entry Criteria section |
| SC-3 | BLOCKED responses include context-specific remediation message (not a generic string) | `string` — grep for `remediation:` in each file's Step 0 section |
| SC-4 | Cross-validate and verification-audit check for ≥2 YAML files in artifact_evidence_dir | `string` — grep for `INSUFFICIENT_ARTIFACTS` in both files |
| SC-5 | Completion dependency chains updated to include Step 0 as first mandatory dependency | `string` — grep for "Step 0" in each file's dependency chain section |
| SC-6 | Existing BLOCKED error codes preserved (MISSING_EVIDENCE_DIR, SPEC_NOT_FOUND, etc.) | `semantic` — sub-agent reads each file, confirms existing error codes still present alongside new Step 0 codes |

## Design Decisions

1. **Step 0 is universal** — every task file gets the same pre-flight gate structure, with task-specific required inputs
2. **No work before validation** — the gate fires before any glob, read, or analysis. If the orchestrator didn't provide the inputs, the task doesn't try to find them
3. **Existing BLOCKED codes preserved** — MISSING_EVIDENCE_DIR, INSUFFICIENT_ARTIFACTS, etc. remain valid; the pre-flight gate adds MISSING_REQUIRED_INPUT as a catch-all for missing entry criteria
4. **VbC is only required for verification-audit and test-quality-audit** — other tasks don't need it. The per-task table makes this explicit
5. **Plan is only required for plan-fidelity** — other tasks don't need it. The per-task table makes this explicit
6. **Renumbering is mechanical** — existing Step 1 becomes Step 2, Step 2 becomes Step 3, etc. The dependency chain and cross-references are updated accordingly

## Status

```
STATUS: DRAFT
```

## Changelog

- 2026-06-22: Initial draft
