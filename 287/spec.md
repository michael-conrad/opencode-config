---
title: "[SPEC-FIX] Missing task cards in spec-creation pipeline: research-card-consultation and interdependency-check"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 287
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The `spec-creation` pipeline (defined in `spec-creation/SKILL.md`) references two sub-tasks in its 25-step pipeline that have no corresponding task card files. When the orchestrator dispatches these steps, the sub-agent has no task file to execute — the pipeline is structurally broken at these points.

### Missing Task 1: `research-card-consultation` (Pipeline Step 4)

Referenced in:
- `spec-creation/SKILL.md` pipeline step 4: `[sub-task] research-card-consultation`
- `spec-creation/SKILL.md` Step-by-Step Contract Table: `research-card-consultation` entry with reads/writes/result contract defined

But no task file exists at `spec-creation-validation/tasks/research-card-consultation.md` or anywhere else in the skills tree.

### Missing Task 2: `interdependency-check` (Pipeline Step 20)

Referenced in:
- `spec-creation/SKILL.md` pipeline step 20: `[sub-task] interdependency-check`
- `spec-creation/SKILL.md` Step-by-Step Contract Table: `interdependency-check` entry with reads/writes/result contract defined

But no task file exists at `spec-creation-validation/tasks/interdependency-check.md` or anywhere else in the skills tree.

### Minor: Task Count Discrepancy

`spec-creation/SKILL.md` sub-skills table reports `spec-creation-validation` as having `6 task files` but the directory actually contains 9 task files. This count should be updated to 9.

## Root Cause

When the `spec-creation` pipeline was expanded from the original sub-skill structure, the pipeline steps and contract table entries were added to `spec-creation/SKILL.md` but the corresponding task card files were never created in `spec-creation-validation/tasks/`. The SKILL.md was updated with routing metadata (pipeline steps, contract table entries) but the task cards that sub-agents execute were never written.

## Affected Files

| File | Issue |
|------|-------|
| `spec-creation-validation/tasks/research-card-consultation.md` | MISSING — does not exist |
| `spec-creation-validation/tasks/interdependency-check.md` | MISSING — does not exist |
| `spec-creation/SKILL.md` | Task count for spec-creation-validation says 6, should be 9 |

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Remove the pipeline steps from SKILL.md | The steps serve valid purposes (research card caching, interdependency detection). Removing them loses functionality. |
| Inline the steps in the orchestrator | Violates orchestrator context discipline — orchestrator MUST NOT perform inline work. Sub-agent dispatch is required. |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation-validation/tasks/research-card-consultation.md` exists with Purpose, Entry Criteria, Procedure, and Result Contract sections | structural | `ls .opencode/skills/spec-creation-validation/tasks/research-card-consultation.md` |
| SC-2 | `spec-creation-validation/tasks/interdependency-check.md` exists with Purpose, Entry Criteria, Procedure, and Result Contract sections | structural | `ls .opencode/skills/spec-creation-validation/tasks/interdependency-check.md` |
| SC-3 | `spec-creation/SKILL.md` sub-skills table reports `spec-creation-validation` task count as 9 (not 6) | string | `grep 'spec-creation-validation' .opencode/skills/spec-creation/SKILL.md` shows `9 task files` |
| SC-4 | Both new task files are referenced in the `spec-creation-validation/SKILL.md` Tasks list | string | `grep 'research-card-consultation' .opencode/skills/spec-creation-validation/SKILL.md` and `grep 'interdependency-check' .opencode/skills/spec-creation-validation/SKILL.md` both match |

## Implementation Approach

1. Create `spec-creation-validation/tasks/research-card-consultation.md` with:
   - Purpose: Consult existing research cards for cached findings before spec creation
   - Entry Criteria: Research cards directory exists at `.opencode/.issues/research-cards/`
   - Procedure: glob `*.md` in research cards, grep frontmatter for matching topic, return cached findings or report no match
   - Result Contract: `{status: DONE, finding_summary: "...", artifact_path: ".issues/{N}/artifacts/research-cards-consulted.yaml"}`

2. Create `spec-creation-validation/tasks/interdependency-check.md` with:
   - Purpose: Check for conflicting open specs that may overlap with the current spec
   - Entry Criteria: Spec number N is known, GitHub API access available
   - Procedure: Query open [SPEC] issues, compare file paths and concern boundaries, classify overlap
   - Result Contract: `{status: DONE | BLOCKED, finding_summary: "...", artifact_path: ".issues/{N}/artifacts/interdependency-check.yaml"}`

3. Update `spec-creation/SKILL.md` task count from 6 to 9

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
