---
title: Per-SC RED/GREEN Decomposition — Fix spec writer and plan writer to pair each SC with its own RED/GREEN cycle
status: draft
created: 2026-07-17
license: MIT
provenance: AI-generated
issue: 303
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-17

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The spec writer and plan writer decompose implementation work to the **file/concern level**, not the **SC level**. A phase covering one file with 3-5 SCs gets a single RED/GREEN cycle, violating the `091-incremental-build.md` mandate that each item must be a single independently verifiable claim whose PASS/FAIL cannot be split across two assertions.

The current pipeline produces this pattern:

```
Spec SC-1..5 → Phase "Fix create.md" (covers SC-1..5) → one RED → one GREEN → one COMMIT
```

Instead of the mandated pattern:

```
Spec SC-1 → RED for SC-1 → GREEN for SC-1 → COMMIT
Spec SC-2 → RED for SC-2 → GREEN for SC-2 → COMMIT (builds on SC-1)
...
```

This produces monolithic RED/GREEN cycles where multiple SCs are implemented in one pass, making per-SC verification impossible and hiding defects until the audit stage. When a single GREEN phase implements 3-5 SCs, a failure in one SC contaminates the entire phase — the pipeline cannot checkpoint per-SC, cannot roll back per-SC, and cannot verify per-SC.

## Root Cause Analysis

The root cause is a **three-layer granularity mismatch** where each layer decomposes to a different level:

| Layer | File | Current Decomposition Level | Problem |
|-------|------|----------------------------|---------|
| Spec writer | `spec-creation-decomposition/tasks/decompose.md` Step 5 | Per-file/per-concern phases (three-tier structure) | Groups multiple SCs into a single phase |
| Plan writer | `writing-plans-creation/tasks/structure.md` Step 5 | Code-path-to-item mapping | Maps code paths to items, not SCs to items |
| Plan writer | `writing-plans-creation/tasks/write.md` Tier 3 | Per-file items | Items at file/concern level, not SC level |
| Pipeline executor | `implementation-pipeline/tasks/pipeline-executor.md` Step 3 | Per-step checkpoint | Checkpoints per step, not per SC |
| TDD chaining gate | `implementation-pipeline/tasks/tdd-chaining-gate.md` | Per-item independence | Items at file/concern level, never checks SC count |
| Spec creator | `spec-creation-validation/tasks/create.md` Step 1.1 | `plan_phase` field in sc-summary.yaml | Binds SCs to phases, not individual items |

The decomposition-depth mandate in `decompose.md` (lines 99-125) correctly states: "Decompose until each unit is a single independently verifiable claim whose PASS/FAIL cannot be split across two assertions." However, the three-tier phase structure in Step 5 of the same file contradicts this by grouping SCs into per-file phases. The plan writer then inherits this per-file grouping and produces items at the wrong granularity.

## Goals

- Every SC in a spec maps to exactly one RED/GREEN/verify/commit cycle
- The plan writer produces per-SC items, not per-file or per-concern items
- The pipeline executor checkpoints per SC, not per step
- The TDD chaining gate BLOCKs any item covering multiple SCs
- The sc-summary.yaml binds SCs to individual items, not phases
- `.opencode/AGENTS.md` documents the per-SC decomposition as the standard workflow
- `guidelines/091-incremental-build.md` clarifies "item" means "one SC per item"
- `test-driven-development/tasks/red.md` and `tasks/green.md` reference per-SC targeting

## Non-Goals

- Changing the spec-creation SC table format or evidence type taxonomy
- Changing the audit, cross-validate, or review-prep pipeline stages
- Changing the approval-gate or authorization scope model
- Changing the checkpoint-tag naming convention
- Changing the global pre-phase or global post-phase structure (only per-file phases are replaced)

## Constraints and Scope

### In Scope

| File | Change |
|------|--------|
| `spec-creation-decomposition/tasks/decompose.md` | Replace three-tier per-file phase structure with per-SC item list. Remove "one phase per file or concern" language. Add per-SC item enumeration requirement. |
| `writing-plans-creation/tasks/structure.md` | Change Step 5 from "use code path inventory artifact to ensure every code path has a RED/GREEN item" to "use SC list from sc-summary.yaml to ensure every SC has its own RED/GREEN item." |
| `writing-plans-creation/tasks/write.md` | Change Tier 3 from "per-item" (file level) to "per-SC" with explicit SC-ID binding on each RED/GREEN chain. Add validation rule: each item MUST reference exactly one SC ID. |
| `implementation-pipeline/tasks/pipeline-executor.md` | Add per-SC checkpoint verification: after each RED/GREEN cycle, verify the specific SC's evidence before advancing. Add SC-ID to checkpoint tag naming. |
| `implementation-pipeline/tasks/tdd-chaining-gate.md` | Add SC-level check: verify each item covers exactly one SC. BLOCK with `MULTI_SC_ITEM` if any item covers multiple SCs. |
| `spec-creation-validation/tasks/create.md` | Change `plan_phase` field in sc-summary.yaml to `plan_item`. Each SC gets its own item number. |
| `.opencode/AGENTS.md` | Add a "Per-SC Decomposition" section documenting the standard: each SC maps to exactly one RED/GREEN/verify/commit cycle. Reference `091-incremental-build.md` and the research card. |
| `guidelines/091-incremental-build.md` | Clarify that "item" in the Per-Item TDD Cycle table means "one SC per item." Add a note: "An item is a single success criterion (SC) from the spec. Each SC gets its own RED/GREEN/REFACTOR/COMMIT cycle." |
| `test-driven-development/tasks/red.md` | Add a note in the Required RED Structure section: "The RED phase targets exactly one SC from the spec. Reference the SC-ID in the test file path or test name." |
| `test-driven-development/tasks/green.md` | Add a note in the Exit Criteria section: "The GREEN phase implements exactly one SC. Verify the SC's evidence type before declaring PASS." |

### Out of Scope

- Changes to the audit skill or auditor task files
- Changes to the approval-gate skill or authorization scope model
- Changes to the checkpoint-tag naming convention in git-workflow
- Changes to the verification-before-completion skill
- Changes to the finishing-a-development-branch skill

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Add a new pipeline stage that splits phases into per-SC items after plan creation | Adds complexity without fixing the root cause — the spec and plan writers produce the wrong structure; splitting after the fact is patching the symptom |
| Keep per-file phases but add per-SC sub-steps within each phase | Sub-steps within a phase still share a single checkpoint and rollback boundary — does not achieve per-SC independence |
| Change only the plan writer, leave spec writer unchanged | The spec writer's `plan_phase` field in sc-summary.yaml drives the plan writer's phase structure — both must change together |
| Add a validation gate that catches multi-SC items and rejects the plan | Detection without prevention still produces defective plans that must be reworked — fix the producer, not the validator |

## Safety Considerations

- **Rollback plan**: If the per-SC decomposition produces plans that are too granular (excessive step count), the item grouping can be relaxed to allow 2-3 related SCs per item with explicit justification. The default is 1 SC per item.
- **Data loss risk**: None — this changes only task file procedures, not data schemas or production code.
- **Destructive operations**: None — all changes are additive or modify existing procedure text.

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `decompose.md` Step 5 defines three-tier per-file phase structure | `read(spec-creation-decomposition/tasks/decompose.md)` lines 60-87 | ✅ |
| `decompose.md` lines 99-125 define decomposition-depth mandate (per-SC) | `read(spec-creation-decomposition/tasks/decompose.md)` lines 99-125 | ✅ |
| `structure.md` Step 5 maps code paths to items | `read(writing-plans-creation/tasks/structure.md)` lines 25-31 | ✅ |
| `write.md` Tier 3 defines per-file items | `read(writing-plans-creation/tasks/write.md)` lines 108-122 | ✅ |
| `pipeline-executor.md` checkpoints per step | `read(implementation-pipeline/tasks/pipeline-executor.md)` lines 41-44 | ✅ |
| `tdd-chaining-gate.md` checks per-item independence at file level | `read(implementation-pipeline/tasks/tdd-chaining-gate.md)` lines 27-32 | ✅ |
| `create.md` Step 1.1 uses `plan_phase` field | `read(spec-creation-validation/tasks/create.md)` lines 225-252 | ✅ |

## SC-to-Root-Cause Traceability Table

| SC ID | Root Cause Element | What It Tests |
|-------|-------------------|---------------|
| SC-1 | `decompose.md` Step 5 groups SCs into per-file phases | decompose.md produces per-SC items, not per-file phases |
| SC-2 | `structure.md` Step 5 maps code paths to items | structure.md maps SCs to items, not code paths |
| SC-3 | `write.md` Tier 3 defines per-file items | write.md produces per-SC items with SC-ID binding |
| SC-4 | `pipeline-executor.md` checkpoints per step | pipeline-executor.md checkpoints per SC with SC-ID in tag |
| SC-5 | `tdd-chaining-gate.md` checks per-item at file level | tdd-chaining-gate.md BLOCKs on multi-SC items |
| SC-6 | `create.md` Step 1.1 uses `plan_phase` field | sc-summary.yaml uses `plan_item` not `plan_phase` |
| SC-7 | No documentation of per-SC standard in AGENTS.md | AGENTS.md documents per-SC decomposition as standard workflow |
| SC-8 | `091-incremental-build.md` does not define "item" as SC | 091-incremental-build.md clarifies "item" = "one SC per item" |
| SC-9 | RED/GREEN task files lack per-SC targeting guidance | red.md and green.md reference per-SC targeting |
| SC-10 | Behavioral test: plan writer produces per-SC items | Behavioral test verifies per-SC item generation |
| SC-11 | Behavioral test: TDD chaining gate BLOCKs on multi-SC items | Behavioral test verifies MULTI_SC_ITEM rejection |
| SC-12 | Anti-lobotomization | No SC may be weakened, deferred, or reclassified |

## Feasibility Assessment

| Reference | Verified? | Evidence |
|-----------|-----------|----------|
| `spec-creation-decomposition/tasks/decompose.md` | ✅ | `read()` confirmed file exists at expected path |
| `writing-plans-creation/tasks/structure.md` | ✅ | `read()` confirmed file exists at expected path |
| `writing-plans-creation/tasks/write.md` | ✅ | `read()` confirmed file exists at expected path |
| `implementation-pipeline/tasks/pipeline-executor.md` | ✅ | `read()` confirmed file exists at expected path |
| `implementation-pipeline/tasks/tdd-chaining-gate.md` | ✅ | `read()` confirmed file exists at expected path |
| `spec-creation-validation/tasks/create.md` | ✅ | `read()` confirmed file exists at expected path |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| None | — | This is a self-contained spec with no external dependencies |

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `decompose.md` Step 5 replaces three-tier per-file phase structure with per-SC item list. The "one phase per file or concern" language is removed. A new step enumerates SCs as individual items with their own RED/GREEN/verify/commit cycles. | `grep -n "per-file\|per-concern\|one phase per" .opencode/skills/spec-creation-decomposition/tasks/decompose.md` returns no matches. `grep -c "per-SC item\|SC-.*RED/GREEN" .opencode/skills/spec-creation-decomposition/tasks/decompose.md` returns ≥ 1. | If per-file language remains, replace with per-SC item language. If per-SC item enumeration is missing, add it. | RED | `.issues/303/artifacts/sc-1-verify.log` | decompose.md Step 5 | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-2 | `structure.md` Step 5 changes from "use code path inventory artifact to ensure every code path has a RED/GREEN item" to "use SC list from sc-summary.yaml to ensure every SC has its own RED/GREEN item." | `grep "code path inventory.*RED/GREEN" .opencode/skills/writing-plans-creation/tasks/structure.md` returns no matches. `grep "SC list.*sc-summary.yaml.*RED/GREEN" .opencode/skills/writing-plans-creation/tasks/structure.md` returns ≥ 1. | If code-path mapping remains, replace with SC-list mapping. | RED | `.issues/303/artifacts/sc-2-verify.log` | structure.md Step 5 | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-3 | `write.md` Tier 3 changes from "per-item" (file level) to "per-SC" with explicit SC-ID binding on each RED/GREEN chain. A validation rule is added: each item MUST reference exactly one SC ID. | `grep "per-item\|per-file" .opencode/skills/writing-plans-creation/tasks/write.md` returns no matches for file-level items. `grep "per-SC\|SC-ID binding\|exactly one SC" .opencode/skills/writing-plans-creation/tasks/write.md` returns ≥ 1. | If per-file item language remains, replace with per-SC item language. If SC-ID binding rule is missing, add it. | RED | `.issues/303/artifacts/sc-3-verify.log` | write.md Tier 3 | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-4 | `pipeline-executor.md` adds per-SC checkpoint verification: after each RED/GREEN cycle, verify the specific SC's evidence before advancing. Checkpoint tags include SC-ID. | `grep "per-SC checkpoint\|SC-ID.*checkpoint\|verify.*SC.*evidence" .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` returns ≥ 1. | If per-SC checkpoint is missing, add it. If SC-ID in checkpoint tag is missing, add it. | RED | `.issues/303/artifacts/sc-4-verify.log` | pipeline-executor.md Step 3 | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-5 | `tdd-chaining-gate.md` adds SC-level check: verify each item covers exactly one SC. BLOCK with `MULTI_SC_ITEM` if any item covers multiple SCs. | `grep "MULTI_SC_ITEM\|exactly one SC\|covers multiple SCs" .opencode/skills/implementation-pipeline/tasks/tdd-chaining-gate.md` returns ≥ 1. | If SC-level check is missing, add it. If `MULTI_SC_ITEM` is missing, add it. | RED | `.issues/303/artifacts/sc-5-verify.log` | tdd-chaining-gate.md | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-6 | `create.md` Step 1.1 changes `plan_phase` field in sc-summary.yaml to `plan_item`. Each SC gets its own item number instead of a phase group. | `grep "plan_phase" .opencode/skills/spec-creation-validation/tasks/create.md` returns no matches. `grep "plan_item" .opencode/skills/spec-creation-validation/tasks/create.md` returns ≥ 1. | If `plan_phase` remains, replace with `plan_item`. | RED | `.issues/303/artifacts/sc-6-verify.log` | create.md Step 1.1 | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-7 | `.opencode/AGENTS.md` includes a "Per-SC Decomposition" section documenting the standard: each SC maps to exactly one RED/GREEN/verify/commit cycle. References `091-incremental-build.md` and the research card at `.issues/research-cards/per-sc-decomposition-industry-standards.md`. | `grep "Per-SC Decomposition" .opencode/AGENTS.md` returns ≥ 1. `grep "per-sc-decomposition-industry-standards" .opencode/AGENTS.md` returns ≥ 1. | If section is missing, add it. If research card reference is missing, add it. | RED | `.issues/303/artifacts/sc-7-verify.log` | AGENTS.md | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-8 | `guidelines/091-incremental-build.md` clarifies that "item" in the Per-Item TDD Cycle table means "one SC per item." A note is added: "An item is a single success criterion (SC) from the spec. Each SC gets its own RED/GREEN/REFACTOR/COMMIT cycle." | `grep "one SC per item\|single success criterion" .opencode/guidelines/091-incremental-build.md` returns ≥ 1. | If clarification is missing, add it. | RED | `.issues/303/artifacts/sc-8-verify.log` | 091-incremental-build.md | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-9 | `test-driven-development/tasks/red.md` includes a note in the Required RED Structure section: "The RED phase targets exactly one SC from the spec. Reference the SC-ID in the test file path or test name." | `grep "targets exactly one SC\|SC-ID in the test" .opencode/skills/test-driven-development/tasks/red.md` returns ≥ 1. | If per-SC targeting note is missing, add it. | RED | `.issues/303/artifacts/sc-9-verify.log` | red.md | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-10 | `test-driven-development/tasks/green.md` includes a note in the Exit Criteria section: "The GREEN phase implements exactly one SC. Verify the SC's evidence type before declaring PASS." | `grep "implements exactly one SC\|SC.*evidence type.*PASS" .opencode/skills/test-driven-development/tasks/green.md` returns ≥ 1. | If per-SC implementation note is missing, add it. | RED | `.issues/303/artifacts/sc-10-verify.log` | green.md | 1 | pre-commit | sequential | — | — | — | 1 |
| SC-11 | Behavioral enforcement test exists that verifies the plan writer produces per-SC items. The test sends a prompt to create a plan from a spec with 3 SCs and verifies the plan has 3 items (not 1 phase). | `ls .opencode/tests-v2/behaviors/per-sc-decomposition.sh` exists. `bash .opencode/tests-v2/behaviors/per-sc-decomposition.sh` returns exit code 0. | If test does not exist, create it. If test fails, fix the implementation. | GREEN | `.issues/303/artifacts/sc-11-verify.log` | Behavioral enforcement | 2 | pre-commit | sequential | — | — | `per-sc-decomposition.sh` | 2 |
| SC-12 | Behavioral enforcement test exists that verifies the TDD chaining gate BLOCKs on multi-SC items. The test sends a plan with a single item covering 2 SCs and verifies the gate returns `MULTI_SC_ITEM`. | `ls .opencode/tests-v2/behaviors/tdd-chaining-multi-sc-block.sh` exists. `bash .opencode/tests-v2/behaviors/tdd-chaining-multi-sc-block.sh` returns exit code 0. | If test does not exist, create it. If test fails, fix the implementation. | GREEN | `.issues/303/artifacts/sc-12-verify.log` | Behavioral enforcement | 2 | pre-commit | sequential | — | — | `tdd-chaining-multi-sc-block.sh` | 2 |
| SC-13 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. | Audit of all SCs in this spec confirms no evidence type downgrade. | If any SC is weakened, restore to original evidence type. | audit | `.issues/303/artifacts/sc-13-verify.log` | Anti-lobotomization | 3 | post-implementation | sequential | — | — | — | 3 |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation | Verifying SC |
|------|-----------|--------|------------|--------------|
| Per-SC items produce excessive plan step count | Medium | Low — more steps but each is simpler | Split-file format already handles many items; checkpoint tags scale linearly | SC-3 |
| Existing plans that use per-file phases break | Low | Medium — only affects plans created before this change | No existing plans are modified; only new plans use per-SC items | SC-1 |
| Plan writer ignores SC-ID binding rule | Low | Medium — produces invalid plans | TDD chaining gate catches multi-SC items and BLOCKs | SC-5 |
| AGENTS.md or guideline changes missed during implementation | Low | Low — documentation-only changes, no behavioral impact | All 3 doc files are in Phase 1 with string-evidence SCs | SC-7, SC-8, SC-9, SC-10 |

## Implementation Approach

### Phase 1 — Spec Writer Changes

**Files:** `spec-creation-decomposition/tasks/decompose.md`, `spec-creation-validation/tasks/create.md`

1. In `decompose.md`, replace Step 5 (three-tier per-file phase structure) with a per-SC item enumeration step. Remove "one phase per file or concern" language. Add: "For each SC in the spec's success criteria table, create one implementation item with its own RED/GREEN/verify/commit cycle. Items are numbered sequentially. Each item references exactly one SC-ID."

2. In `create.md` Step 1.1, change `plan_phase` field to `plan_item` in the sc-summary.yaml template. Each SC gets an item number instead of a phase group.

### Phase 2 — Documentation Standards

**Files:** `.opencode/AGENTS.md`, `guidelines/091-incremental-build.md`, `test-driven-development/tasks/red.md`, `test-driven-development/tasks/green.md`

1. In `.opencode/AGENTS.md`, add a "Per-SC Decomposition" section documenting the standard: each SC maps to exactly one RED/GREEN/verify/commit cycle. Reference `091-incremental-build.md` and the research card at `.issues/research-cards/per-sc-decomposition-industry-standards.md`.

2. In `guidelines/091-incremental-build.md`, clarify that "item" in the Per-Item TDD Cycle table means "one SC per item." Add a note: "An item is a single success criterion (SC) from the spec. Each SC gets its own RED/GREEN/REFACTOR/COMMIT cycle."

3. In `test-driven-development/tasks/red.md`, add a note in the Required RED Structure section: "The RED phase targets exactly one SC from the spec. Reference the SC-ID in the test file path or test name."

4. In `test-driven-development/tasks/green.md`, add a note in the Exit Criteria section: "The GREEN phase implements exactly one SC. Verify the SC's evidence type before declaring PASS."

### Phase 3 — Plan Writer Changes

**Files:** `writing-plans-creation/tasks/structure.md`, `writing-plans-creation/tasks/write.md`

1. In `structure.md` Step 5, change the mapping directive from code-path-to-item to SC-to-item. The step reads `sc-summary.yaml` and creates one item per SC.

2. In `write.md`, change Tier 3 from "per-item" (file level) to "per-SC" with explicit SC-ID binding. Add validation rule: each item MUST reference exactly one SC ID. Add validation rule 16: "Each item references exactly one SC-ID."

### Phase 4 — Pipeline Changes

**Files:** `implementation-pipeline/tasks/pipeline-executor.md`, `implementation-pipeline/tasks/tdd-chaining-gate.md`

1. In `pipeline-executor.md`, add per-SC checkpoint verification after each RED/GREEN cycle. Include SC-ID in checkpoint tag naming: `{parent}/checkpoint/{issue}/sc-{SC-ID}`.

2. In `tdd-chaining-gate.md`, add SC-level check: verify each item covers exactly one SC. BLOCK with `MULTI_SC_ITEM` if any item covers multiple SCs.

### Phase 5 — Behavioral Tests

**Files:** `.opencode/tests-v2/behaviors/per-sc-decomposition.sh`, `.opencode/tests-v2/behaviors/tdd-chaining-multi-sc-block.sh`

1. Create behavioral test that verifies the plan writer produces per-SC items.
2. Create behavioral test that verifies the TDD chaining gate BLOCKs on multi-SC items.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read()` on all 6 affected task files | Verify current decomposition logic and granularity |
| Local docs | `guidelines/091-incremental-build.md` | Verify per-item TDD cycle mandate |
| Local docs | `guidelines/000-critical-rules.md` §Monolithic Implementation | Verify decomposition-depth mandate |
| Local docs | `guidelines/080-code-standards.md` §Decomposition-Depth Mandate | Verify per-SC atomicity requirement |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
