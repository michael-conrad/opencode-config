# [SPEC] Fix implementation pipeline workflow model

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The implementation pipeline has a defective workflow model. Two task files (`assemble-work.md`, `pipeline-executor.md`) are written as if the reader can dispatch sub-agents via `task()`. Sub-agents cannot call `task()` — this is a platform constraint, not a rule. The current design has the orchestrator reading these `.md` files and executing steps inline, which violates clean-room dispatch principles, contains dead code, and creates ambiguity about who executes what. |
| Root Cause / Motivation | The `assemble-work.md` file instructs the orchestrator to read it and execute steps inline (violating clean-room dispatch). Step 3 ("Dispatch Sub-Agents") is structurally impossible — sub-agents cannot call `task()`. The `pipeline-executor.md` file duplicates the dispatch table already in SKILL.md. Both files create ambiguity about who executes what. |
| Approach Chosen | Delete both task files, make the SKILL.md Trigger Dispatch Table the single source of truth, remove the dead "sub-agents must not dispatch sub-agents" rule from all files, and update all cross-references. |
| Alternatives Considered & Why Discarded | Rewrite the task files to be orchestrator-only — rejected because the content is either orchestrator-inline work (belongs in orchestrator context, not a task file) or dead code (sub-agent dispatch steps that can't execute). No salvageable content worth preserving in a task file. |
| Key Design Decisions | Delete over rewrite; preserve coercion rule, checkpoint/rollback, pre-flight handoff, and remediation routing in SKILL.md before deletion. |

## Problem

The implementation pipeline (`implementation-pipeline` skill) has a defective workflow model. Two task files — `assemble-work.md` and `pipeline-executor.md` — are written as if the reader can dispatch sub-agents via `task()`. In reality, sub-agents cannot call `task()` (the tool is not available to them). This is a platform constraint, not a rule.

The current design has the orchestrator reading these `.md` files and executing steps inline, which:
1. Violates clean-room dispatch principles (orchestrator does inline work)
2. Contains dead code (Step 3 in `assemble-work.md` says "dispatch sub-agents" — impossible from a sub-agent context)
3. Creates ambiguity about who executes what

## Scope

**In scope:**
- Delete `tasks/assemble-work.md` — its content is either orchestrator-inline work (plan reading, branch creation) that the orchestrator does directly, or dead code (sub-agent dispatch steps that can't execute from a sub-agent)
- Delete `tasks/pipeline-executor.md` — the dispatch loop lives in the SKILL.md Trigger Dispatch Table, which is routing metadata the orchestrator reads. No task file needed.
- Move the dispatch table to be the single source of truth in `implementation-pipeline/SKILL.md`
- Remove the "Sub-agents must not dispatch sub-agents" rule from all 44 files (41 SKILL.md + 3 reference files) — it's structurally impossible, making it noise
- Update all cross-references across skills, tests, and guidelines that reference these files

**Out of scope:**
- Changes to the pipeline step sequence or Z3 state machine
- Changes to how individual pipeline steps work (red-phase, green-phase, etc.)
- Changes to the adversarial-audit dispatch model
- Changes to plan format or plan writing workflow
- Changes to pre-flight handoff task
- Changes to checkpoint tag creation or rollback logic
- Changes to remediation routing protocol
- Changes to auto-revision routing for non-substantive spec defects
- Changes to the bright-line coercion rule (DONE_WITH_CONCERNS → FAIL)

## Approach

1. **Phase 1 — Behavioral test creation**: Write behavioral enforcement test verifying orchestrator dispatches from SKILL.md dispatch table (RED state before implementation)
2. **Phase 2 — Update implementation-pipeline/SKILL.md**: Make Trigger Dispatch Table the single source of truth; preserve coercion rule, checkpoint/rollback, pre-flight handoff, and remediation routing
3. **Phase 3 — Remove sub-agent rule from 41 SKILL.md files**: Remove "Sub-agents must not dispatch sub-agents" from all SKILL.md files except implementation-pipeline
4. **Phase 4 — Remove sub-agent rule from 3 reference files**: Remove from init_skill.py, routing-only-template.md, skill-card-spec.md
5. **Phase 5 — Update cross-references in skills**: ~23 files referencing assemble-work.md or pipeline-executor.md
6. **Phase 6 — Update cross-references in tests**: 5 test files
7. **Phase 7 — Update cross-references in guidelines**: 3 guideline files
8. **Phase 8 — Delete assemble-work.md**: After all cross-references are updated
9. **Phase 9 — Delete pipeline-executor.md**: After all cross-references are updated
10. **Phase 10 — Global post-phase**: Adversarial audit, cross-validate, regression, review prep

## Affected Files

See `.opencode/skills/` for SKILL.md files (41 total), `.opencode/skills/skill-creator/scripts/init_skill.py`, `.opencode/skills/skill-creator/reference/routing-only-template.md`, `.opencode/skills/skill-creator/reference/skill-card-spec.md`, and cross-reference files in skills (~23), tests (5), and guidelines (3).

## Success Criteria

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Phase Binding | Verification Gate | Integration Mode |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|--------------|-------------------|-----------------|
| SC-1a | `implementation-pipeline/SKILL.md` Trigger Dispatch Table is the single source of truth for dispatch routing — no task file contains dispatch instructions | `string` | `grep -r "dispatch.*sub-agent\|task()" .opencode/skills/implementation-pipeline/tasks/ --include="*.md"` returns empty for dispatch instructions | Add missing dispatch entries to SKILL.md table | Phase 2 | `.opencode/skills/implementation-pipeline/SKILL.md` | Phase 2 | pre-commit | standalone |
| SC-1b | No task file in `.opencode/skills/` contains instructions to dispatch sub-agents via `task()` | `semantic` | Sub-agent reads all task files in `.opencode/skills/implementation-pipeline/tasks/` and judges whether any contain dispatch instructions | Remove dispatch instructions from task files | Phase 2 | `.opencode/skills/implementation-pipeline/tasks/` | Phase 2 | pre-commit | standalone |
| SC-2 | `assemble-work.md` is deleted from the filesystem | `structural` | `ls .opencode/skills/implementation-pipeline/tasks/assemble-work.md` returns "No such file" | Restore from git if accidentally recreated | Phase 8 | `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` | Phase 8 | pre-commit | standalone |
| SC-3 | `pipeline-executor.md` is deleted from the filesystem | `structural` | `ls .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` returns "No such file" | Restore from git if accidentally recreated | Phase 8 | `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` | Phase 8 | pre-commit | standalone |
| SC-4 | "Sub-agents must not dispatch sub-agents" rule is removed from all 41 other SKILL.md files | `string` | `grep -r "Sub-agents must not dispatch sub-agents" .opencode/skills/ --include="SKILL.md"` returns empty | Remove the rule from any remaining SKILL.md | Phase 3 | `.opencode/skills/*/SKILL.md` | Phase 3 | pre-commit | cross-cutting |
| SC-5 | "Sub-agents must not dispatch sub-agents" rule is removed from 3 reference files (init_skill.py, routing-only-template.md, skill-card-spec.md) | `string` | `grep -r "Sub-agents must not dispatch sub-agents" .opencode/skills/skill-creator/` returns empty | Remove the rule from any remaining reference file | Phase 4 | `.opencode/skills/skill-creator/` | Phase 4 | pre-commit | cross-cutting |
| SC-6 | All cross-references to `assemble-work.md` and `pipeline-executor.md` in skills are updated or removed | `string` | `grep -r "assemble-work.md\|pipeline-executor.md" .opencode/skills/ --include="*.md"` returns empty (excluding deleted files) | Update each reference to point to SKILL.md dispatch table | Phase 5 | `.opencode/skills/` | Phase 5 | pre-commit | cross-cutting |
| SC-7 | All cross-references to `assemble-work.md` and `pipeline-executor.md` in tests are updated or removed | `string` | `grep -r "assemble-work.md\|pipeline-executor.md" .opencode/tests/` returns empty | Update or remove test assertions referencing deleted files | Phase 6 | `.opencode/tests/` | Phase 6 | pre-commit | cross-cutting |
| SC-8 | All cross-references to `assemble-work.md` and `pipeline-executor.md` in guidelines are updated or removed | `string` | `grep -r "assemble-work.md\|pipeline-executor.md" .opencode/guidelines/` returns empty | Update guideline references to point to SKILL.md | Phase 7 | `.opencode/guidelines/` | Phase 7 | pre-commit | cross-cutting |
| SC-9 | Orchestrator entry point is changed from "read assemble-work.md inline" to "read SKILL.md dispatch table and dispatch directly" | `behavioral` | `opencode-cli run` with prompt "execute plan" — stderr shows orchestrator routing from SKILL.md dispatch table, not from assemble-work.md | Fix SKILL.md dispatch table if routing is incorrect | Phase 2 | `.opencode/skills/implementation-pipeline/SKILL.md` | Phase 2 | pre-commit | standalone |
| SC-10 | Behavioral enforcement test verifies the orchestrator dispatches pipeline steps directly from the SKILL.md dispatch table without reading task files | `behavioral` | `bash .opencode/tests/behaviors/<scenario>.sh` returns PASS — test sends prompt and verifies stderr shows direct dispatch from SKILL.md | Fix behavioral test assertions if they don't match actual agent behavior | Phase 1 | `.opencode/tests/behaviors/` | Phase 1 | pre-commit | standalone |
| SC-11 | Pre-flight handoff and checkpoint/rollback logic are preserved (moved to SKILL.md or step task files) | `semantic` | Sub-agent reads implementation-pipeline/SKILL.md and verifies pre-flight handoff, checkpoint creation, and rollback procedures are present | Add missing preservation content to SKILL.md | Phase 2 | `.opencode/skills/implementation-pipeline/SKILL.md` | Phase 2 | pre-commit | standalone |
| SC-12 | Coercion rule (DONE_WITH_CONCERNS → FAIL) is preserved in SKILL.md | `string` | `grep "DONE_WITH_CONCERNS" .opencode/skills/implementation-pipeline/SKILL.md` returns non-empty | Add coercion rule to SKILL.md | Phase 2 | `.opencode/skills/implementation-pipeline/SKILL.md` | Phase 2 | pre-commit | standalone |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Delete task files instead of rewriting them | The content is either orchestrator-inline work (belongs in orchestrator context, not a task file) or dead code (sub-agent dispatch steps that can't execute). No salvageable content. | MUST | SC-2, SC-3 |
| DEC-2 | Remove "Sub-agents must not dispatch sub-agents" from all 44 files | This is a platform constraint, not a rule. Sub-agents physically cannot call `task()`. Keeping the rule is noise. | MUST | SC-4, SC-5 |
| DEC-3 | Consolidate dispatch table in SKILL.md only | The pipeline-executor.md dispatch table is a duplicate of the SKILL.md Dispatch Routing Table. Single source of truth reduces drift. | MUST | SC-1a, SC-1b |
| DEC-4 | Preserve coercion rule, checkpoint/rollback, pre-flight handoff in SKILL.md | These are critical infrastructure that must survive file deletion. | MUST | SC-11, SC-12 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| R1 | Missing cross-reference — orphaned link to deleted file | Medium | High | Exhaustive grep across ALL files before Phase 8 deletion | SC-6, SC-7, SC-8 |
| R2 | Coercion rule (DONE_WITH_CONCERNS → FAIL) lost during deletion | Low | Critical | SC-12 explicitly requires preservation in SKILL.md | SC-12 |
| R3 | Checkpoint/rollback logic lost during deletion | Low | High | SC-11 explicitly requires preservation in SKILL.md | SC-11 |
| R4 | Behavioral test breaks — tests reference assemble-work.md content | Medium | High | Phase 6 dependency ordering — tests updated before Phase 8 deletion | SC-7 |
| R5 | Pre-flight handoff broken — approval-gate and executing-plans dispatch assemble-work | High | Critical | Phase 3 updates dispatch targets before Phase 8 deletion | SC-6 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Cross-reference updates | MUST | Re-scan for any missed references |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

**Multi-phase** — 10 phases, sequential with dependency ordering. Sub-issues required per phase.

## Regression Invariants

1. The pipeline step sequence MUST remain unchanged — deleting task files does not change what steps execute or in what order.
2. The Z3 state machine (`pipeline-state-machine.yaml`) MUST remain unchanged.
3. All individual pipeline step implementations (red-phase, green-phase, etc.) MUST remain unchanged.
4. The pre-flight handoff task MUST remain unchanged.
5. The checkpoint tag creation and rollback logic MUST remain unchanged.
6. The remediation routing protocol MUST remain unchanged.
7. The auto-revision routing for non-substantive spec defects MUST remain unchanged.
8. The bright-line coercion rule (DONE_WITH_CONCERNS → FAIL) MUST remain unchanged.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "assemble-work" .opencode/skills/` | Count cross-references in skills |
| Direct source search | `grep -r "pipeline-executor" .opencode/skills/` | Count cross-references in skills |
| Direct source search | `grep -r "assemble-work" .opencode/tests/` | Count cross-references in tests |
| Direct source search | `grep -r "pipeline-executor" .opencode/tests/` | Count cross-references in tests |
| Direct source search | `grep -r "assemble-work\|pipeline-executor" .opencode/guidelines/` | Count cross-references in guidelines |
| Direct source search | `grep -r "Sub-agents must not dispatch sub-agents" .opencode/skills/ --include="SKILL.md" \| wc -l` | Count SKILL.md files with the rule |
| Direct source search | `find .opencode -name "SKILL.md" \| wc -l` | Count total SKILL.md files |
| Direct source search | `ls .opencode/skills/implementation-pipeline/tasks/assemble-work.md` | Verify file exists |
| Direct source search | `ls .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` | Verify file exists |
| Direct source search | `find .opencode -name "init_skill.py"` | Find actual path of init_skill.py |
| Direct source search | `find .opencode -name "routing-only-template.md"` | Find actual path of routing-only-template.md |
| Direct source search | `find .opencode -name "skill-card-spec.md"` | Find actual path of skill-card-spec.md |

## AI Agent Instructions

After this spec is approved, invoke `writing-plans` to create `.issues/1674/plan.md` before implementation begins.

The authoritative spec and plan artifacts are at `.issues/1674/`.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
