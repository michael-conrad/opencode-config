---
plan_schema_version: 1
issue: 2211
title: "Update Auditor Task Files to Reference Canonical Reference Docs"
dispatch: [audit, verification, test-driven-development, verification-before-completion, finishing-a-development-branch, git-workflow, git-workflow-pr, completion-core]
---

# Plan: Update Auditor Task Files to Reference Canonical Reference Docs

**Issue:** `.opencode#2211`
**Spec:** `.opencode/.issues/2211/spec.md`
**Dependency:** `.opencode#2210` — must complete first (creates reference docs)

## Goal / Architecture / Files / Dispatch

**Goal:** Update the four auditor task files to read from canonical reference docs (`reference/spec-structure-standards.md`, `reference/plan-structure-standards.md`, `reference/cost-model-standards.md`) via `Read [Text](path)` instead of hard-coding structural criteria. Remove criteria eliminated during brainstorming.

**Architecture:** The auditor task files currently hard-code their own separate criteria lists that duplicate — and have drifted from — the producer templates. The fix replaces hard-coded criteria with `Read [Text](path)` references to canonical reference docs created by `.opencode#2210`. Criteria that are cross-artifact comparisons or behavioral judgments remain as explicit instructions.

**Files:**
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` — update Step 5a, Steps 5b-5h, SC-13
- `.opencode/skills/audit/tasks/spec-audit-investigator.md` — update Step 3
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` — update Step 3, PF-7a
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` — update Steps 2-5

**Dispatch:** `audit` (modify task files), `verification` (verify reference doc paths), `test-driven-development` (RED/GREEN cycles), `verification-before-completion` (verify SCs), `finishing-a-development-branch` (checklist), `git-workflow` (review-prep), `git-workflow-pr` (create PR), `completion-core` (lifecycle event)

## Blast Radius

- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` — Step 5a (SC table), Steps 5b-5h (individual SC checks), SC-13 (cost-frame)
- `.opencode/skills/audit/tasks/spec-audit-investigator.md` — Step 3 (spec structure evidence collection)
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` — Step 3 (PF criteria), PF-7a (cost-frame)
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` — Steps 2-5 (evidence collection items)
- `reference/spec-structure-standards.md` — read-only dependency (created by `.opencode#2210`)
- `reference/plan-structure-standards.md` — read-only dependency (created by `.opencode#2210`)
- `reference/cost-model-standards.md` — read-only dependency (created by `.opencode#2210`)

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|-------------|-------|----------|
| 1 | Update spec-audit-evaluator.md | spec-audit-evaluator-update | SC-1 | `.opencode#2210` | 1-4 | audit |
| 2 | Update spec-audit-investigator.md | spec-audit-investigator-update | SC-2 | Phase 1 | 5-8 | audit |
| 3 | Update plan-fidelity-evaluator.md | plan-fidelity-evaluator-update | SC-3 | Phase 2 | 9-12 | audit |
| 4 | Update plan-fidelity-investigator.md | plan-fidelity-investigator-update | SC-4 | Phase 3 | 13-16 | audit |
| 5 | Verify reference doc paths | reference-doc-verification | SC-5 | `.opencode#2210` | 17-20 | verification |
| 6 | Update spec-audit-evaluator.md SC-13 cost-frame | spec-audit-evaluator-cost-frame | SC-6 | Phase 5 | 21-24 | audit |
| 7 | Update plan-fidelity-evaluator.md PF-7a cost-frame | plan-fidelity-evaluator-cost-frame | SC-7 | Phase 6 | 25-28 | audit |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1: All 7 phases complete with PASS
- [ ] C2: All 4 auditor task files updated to reference canonical reference docs
- [ ] C3: Eliminated criteria removed from all 4 task files
- [ ] C4: All `Read [Text](path)` references point to existing files
- [ ] C5: Behavioral enforcement tests pass for all modified task files
- [ ] C6: All SCs verified via verification-before-completion
- [ ] C7: Audit confirms plan executed faithfully against spec
- [ ] C8: Cross-validation confirms audit and verification agree
- [ ] C9: PR created with all changes

## Pre-Implementation Steps

- [ ] **Coherence gate.** Verify spec/plan coherence before RED routing. Read the spec at `.opencode/.issues/2211/spec.md` and confirm the plan matches the spec's phase structure, SC assignments, and dependency ordering. If any mismatch is found, return BLOCKED with `COHERENCE_FAIL`.
  - (**inline**)

- [ ] **Baseline check.** Verify the current state of all affected files before modification. Read each file listed in the blast radius and confirm the content matches the "before" state described in the spec. If any file has already been modified, return BLOCKED with `BASELINE_CHANGED`.
  - (**inline**)

---

## Phase 1 — Update spec-audit-evaluator.md

**Concern:** spec-audit-evaluator-update
**Files:** `.opencode/skills/audit/tasks/spec-audit-evaluator.md`
**SCs:** SC-1
**Dependencies:** `.opencode#2210` (reference docs must exist)
**Entry:** Coherence gate and baseline check passed
**Exit:** spec-audit-evaluator.md Step 5a and Steps 5b-5h updated to reference spec-structure-standards

### Code Path Coverage

- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` Step 5a — SC-1 through SC-14 table
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` Steps 5b-5h — individual SC checks

### Cross-Cutting SCs

None — SC-1 is phase-specific.

### Interface Boundaries

- `reference/spec-structure-standards.md` — read-only dependency, must exist
- No changes to other auditor task files

### State Transitions

- Before: spec-audit-evaluator.md hard-codes SC-1 through SC-14 table
- After: spec-audit-evaluator.md reads from reference/spec-structure-standards.md via `Read [Text](path)`

### Item 1 — Update spec-audit-evaluator.md Step 5a and Steps 5b-5h

- [ ] **RED.** Write a behavioral enforcement test that sends a prompt to the agent and verifies the evaluator reads from `reference/spec-structure-standards.md` instead of hard-coding the SC table. The test MUST fail at this point because the change hasn't been made yet.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/spec-audit-evaluator.md`:
  - Step 5a: Remove the hard-coded SC-1 through SC-14 table. Replace with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, check that the spec has that section with the correct content. For each SC in the spec's SC table, verify it has a verification method, that dependencies are documented, and that SCs are deterministic.`
  - Removed SCs: SC-3 (phases), SC-4 (steps), SC-6 (concerns), SC-7 (fidelity), SC-8 (edge cases), SC-10 (prose structure), SC-13 (cost-frame)
  - Derived from reference doc: SC-1 (preamble), SC-2 (verification methods), SC-5 (dependencies), SC-9 (determinism), SC-11 (documentation sources), SC-12 (preamble fields), SC-14 (enforcement gate)
  - Step 5b (SC-DET): Remains as explicit instruction
  - Step 5c (SC-STRUCTURAL-FAIL): Remains as explicit instruction
  - Step 5d (SC-EVIDENCE-TYPE): Replace hard-coded taxonomy with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Evidence Type Taxonomy and verify each SC's evidence matches the minimum acceptable method.`
  - Step 5e (SC-TRACKING-LANG): Replace hard-coded list with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Prohibited Content Patterns and verify the spec contains no tracking/status language.`
  - Step 5f (SC-PRESCRIPTIVE-CODE): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Prohibited Content Patterns and verify the spec contains no prescriptive code.`
  - Step 5g (SC-PIPELINE-GATES): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Format Requirements and verify pipeline gates use the canonical checklist format.`
  - Step 5h (SC-CANONICAL-PLAN-FORM): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Format Requirements and verify any plan output format requirements use the canonical checklist format.`
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass now. Verify the changes match the spec's SC-1 requirements: grep for SC-1 through SC-14 table removed; grep for Read reference present; grep for removed SC IDs absent.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes to `spec-audit-evaluator.md` with a descriptive message.
  - (**inline**) `git add .opencode/skills/audit/tasks/spec-audit-evaluator.md && git commit -m "Phase 1: Update spec-audit-evaluator.md to reference spec-structure-standards"`

### Phase Completion

- [ ] VbC: Verify SC-1 — grep for SC-1 through SC-14 table removed; grep for Read reference present; grep for removed SC IDs absent
- [ ] Concern transition: Complete. Proceed to Phase 2 (spec-audit-investigator.md).

---

## Phase 2 — Update spec-audit-investigator.md

**Concern:** spec-audit-investigator-update
**Files:** `.opencode/skills/audit/tasks/spec-audit-investigator.md`
**SCs:** SC-2
**Dependencies:** Phase 1 complete
**Entry:** Phase 1 committed
**Exit:** spec-audit-investigator.md Step 3 updated to reference spec-structure-standards

### Code Path Coverage

- `.opencode/skills/audit/tasks/spec-audit-investigator.md` Step 3 — spec structure evidence collection

### Cross-Cutting SCs

None — SC-2 is phase-specific.

### Interface Boundaries

- `reference/spec-structure-standards.md` — read-only dependency, must exist
- No changes to other auditor task files

### State Transitions

- Before: spec-audit-investigator.md hard-codes section names (Intent and Executive Summary, Documentation Sources, STATUS marker)
- After: spec-audit-investigator.md reads from reference/spec-structure-standards.md via `Read [Text](path)`

### Item 2 — Update spec-audit-investigator.md Step 3

- [ ] **RED.** Write a behavioral enforcement test that verifies the investigator reads from `reference/spec-structure-standards.md` instead of hard-coding section names. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/spec-audit-investigator.md`:
  - Remove Step 3.3 (Phase inventory) — phases are a plan concept
  - Remove Step 3.7 (STATUS marker) — prohibited pattern
  - Replace Step 3.5 (Preamble presence) with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, collect evidence about its presence, content, and structure. Record what is found — do not infer or assume.`
  - Remove Step 3.6 (Documentation Sources) as a hard-coded section name — now derived from reference doc
  - Update the `spec_structure` YAML evidence structure to remove `phases`, `preamble`, `documentation_sources`, and `status_marker` fields. Replace with a dynamic structure derived from the reference doc's required sections.
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for hard-coded section names removed; grep for Read reference present; grep for removed items absent.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/spec-audit-investigator.md && git commit -m "Phase 2: Update spec-audit-investigator.md to reference spec-structure-standards"`

### Phase Completion

- [ ] VbC: Verify SC-2 — grep for hard-coded section names removed; grep for Read reference present; grep for removed items absent
- [ ] Concern transition: Complete. Proceed to Phase 3 (plan-fidelity-evaluator.md).

---

## Phase 3 — Update plan-fidelity-evaluator.md

**Concern:** plan-fidelity-evaluator-update
**Files:** `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`
**SCs:** SC-3
**Dependencies:** Phase 2 complete
**Entry:** Phase 2 committed
**Exit:** plan-fidelity-evaluator.md Step 3 updated to reference plan-structure-standards

### Code Path Coverage

- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` Step 3 — PF criteria

### Cross-Cutting SCs

None — SC-3 is phase-specific.

### Interface Boundaries

- `reference/plan-structure-standards.md` — read-only dependency, must exist
- No changes to other auditor task files

### State Transitions

- Before: plan-fidelity-evaluator.md hard-codes PF criteria (PF-4, PF-6, PF-7, PF-7a, PF-ADMONISHMENT, PF-ONE-STEP, PF-DELEGATION, PF-PRESCRIPTIVE-CODE, PF-GLOBAL-NUMBERING)
- After: plan-fidelity-evaluator.md reads from reference/plan-structure-standards.md via `Read [Text](path)`

### Item 3 — Update plan-fidelity-evaluator.md Step 3

- [ ] **RED.** Write a behavioral enforcement test that verifies the evaluator reads from `reference/plan-structure-standards.md` instead of hard-coding PF criteria. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`:
  - Remove PF-4 (edge cases) — error recovery is a pipeline invariant
  - Remove PF-DELEGATION — too rare, false FAILs
  - Remove PF-GLOBAL-NUMBERING — no evidence of defect prevention
  - Replace PF-6, PF-7, PF-7a, PF-ADMONISHMENT, PF-ONE-STEP, PF-PRESCRIPTIVE-CODE with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, verify the plan has that element with the correct format.`
  - PF-CHECKLIST-FORMAT: Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Step Format and verify all steps use the canonical checklist format.`
  - PF-DISPATCH-MODE: Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Dispatch Indicators and verify every step has exactly one valid dispatch indicator.`
  - PF-DISPATCH-DEFECTS: Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Dispatch Indicators and verify dispatch declarations are consistent with step indicators.`
  - PF-SUBSTEP-EXPAND: Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Step Format and verify no step describes more than one atomic action.`
  - PF-1, PF-2, PF-3, PF-5, PF-STRUCTURAL-FAIL, PF-Z3-CONTRACT, PF-SEQUENCE-MATCHES remain as explicit instructions.
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for removed PF criteria absent; grep for Read reference present.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/plan-fidelity-evaluator.md && git commit -m "Phase 3: Update plan-fidelity-evaluator.md to reference plan-structure-standards"`

### Phase Completion

- [ ] VbC: Verify SC-3 — grep for removed PF criteria absent; grep for Read reference present
- [ ] Concern transition: Complete. Proceed to Phase 4 (plan-fidelity-investigator.md).

---

## Phase 4 — Update plan-fidelity-investigator.md

**Concern:** plan-fidelity-investigator-update
**Files:** `.opencode/skills/audit/tasks/plan-fidelity-investigator.md`
**SCs:** SC-4
**Dependencies:** Phase 3 complete
**Entry:** Phase 3 committed
**Exit:** plan-fidelity-investigator.md Steps 2-5 updated to reference plan-structure-standards

### Code Path Coverage

- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` Step 2 — spec evidence collection
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` Step 3 — plan evidence collection
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` Step 4 — one-step protocol
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` Step 5 — delegation, gate sequence, verification evidence, cost-frame, SC gate language

### Cross-Cutting SCs

None — SC-4 is phase-specific.

### Interface Boundaries

- `reference/spec-structure-standards.md` — read-only dependency, must exist
- `reference/plan-structure-standards.md` — read-only dependency, must exist
- No changes to other auditor task files

### State Transitions

- Before: plan-fidelity-investigator.md hard-codes evidence collection items (phase descriptions, cross-references, delegation, scope boundary, admonishments, plan scope, gate sequence, verification instructions, Z3 contracts, prescriptive content, cost-frame prose, SC gate language)
- After: plan-fidelity-investigator.md reads from reference/plan-structure-standards.md via `Read [Text](path)`

### Item 4 — Update plan-fidelity-investigator.md Steps 2-5

- [ ] **RED.** Write a behavioral enforcement test that verifies the investigator reads from `reference/plan-structure-standards.md` instead of hard-coding evidence collection items. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/plan-fidelity-investigator.md`:
  - Step 2: Remove 2.4 (phase descriptions), 2.5 (cross-references), 2.6 (delegation references), 2.7 (scope boundary). Replace with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, collect evidence about its presence, content, and structure.` Update the `spec` YAML evidence structure to remove `phases`, `cross_references`, `delegation_refs`, `scope` fields.
  - Step 3: Remove 3.8 (admonishments), 3.9 (plan scope), 3.10 (cross-references from plan), 3.11 (delegation definitions), 3.12 (gate sequence), 3.13 (verification instructions), 3.14 (Z3 contract references), 3.15 (prescriptive content). Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, collect evidence about its presence, content, and format.` Update the `plan` YAML evidence structure to remove `admonishments`, `plan_scope`, `cross_references`, `delegation_definitions`, `gate_sequence`, `verification_instructions`, `z3_contract_refs`, `prescriptive_content` fields.
  - Step 4: Remove 4.9 (one-step protocol) — now derived from plan-structure-standards.
  - Step 5: Remove 5.5 (delegation completeness), 5.6 (gate sequence), 5.7 (verification evidence types), 5.8 (cost-frame prose), 5.9 (SC gate language).
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for removed evidence collection items absent; grep for Read reference present.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/plan-fidelity-investigator.md && git commit -m "Phase 4: Update plan-fidelity-investigator.md to reference plan-structure-standards"`

### Phase Completion

- [ ] VbC: Verify SC-4 — grep for removed evidence collection items absent; grep for Read reference present
- [ ] Concern transition: Complete. Proceed to Phase 5 (reference doc path verification).

---

## Phase 5 — Verify reference doc paths

**Concern:** reference-doc-verification
**Files:** (verification only — no file modifications)
**SCs:** SC-5
**Dependencies:** `.opencode#2210` (reference docs must exist)
**Entry:** Phase 4 committed
**Exit:** All `Read [Text](path)` references verified to point to existing files

### Code Path Coverage

- `reference/spec-structure-standards.md` — must exist
- `reference/plan-structure-standards.md` — must exist
- `reference/cost-model-standards.md` — must exist

### Cross-Cutting SCs

None — SC-5 is phase-specific.

### Interface Boundaries

- All three reference docs are read-only dependencies created by `.opencode#2210`
- No changes to any auditor task files

### State Transitions

- Before: Reference doc paths are unverified
- After: All paths confirmed to point to existing files

### Item 5 — Verify all Read reference paths point to existing files

- [ ] **RED.** Write a test that verifies the reference doc paths exist. The test MUST fail if any path is missing.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Verify that all `Read [Text](path)` references in the updated auditor task files point to existing files:
  - `reference/spec-structure-standards.md` — must exist (created by `.opencode#2210`)
  - `reference/plan-structure-standards.md` — must exist (created by `.opencode#2210`)
  - `reference/cost-model-standards.md` — must exist (created by `.opencode#2210`)
  - If any path is missing, return BLOCKED with `MISSING_REFERENCE_DOC` and the missing path.
  - (**inline**) Read each path with the `read` tool and confirm the file exists.

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: read each referenced path — expect file exists.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit any changes (if verification found issues that needed fixing).
  - (**inline**) `git add .opencode/skills/audit/tasks/ && git commit -m "Phase 5: Verify reference doc paths"`

### Phase Completion

- [ ] VbC: Verify SC-5 — read each referenced path — expect file exists
- [ ] Concern transition: Complete. Proceed to Phase 6 (spec-audit-evaluator.md SC-13 cost-frame).

---

## Phase 6 — Update spec-audit-evaluator.md SC-13 cost-frame

**Concern:** spec-audit-evaluator-cost-frame
**Files:** `.opencode/skills/audit/tasks/spec-audit-evaluator.md`
**SCs:** SC-6
**Dependencies:** Phase 5 complete
**Entry:** Phase 5 committed
**Exit:** spec-audit-evaluator.md SC-13 updated to reference cost-model-standards

### Code Path Coverage

- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` SC-13 — cost-frame evaluation rule

### Cross-Cutting SCs

None — SC-6 is phase-specific.

### Interface Boundaries

- `reference/cost-model-standards.md` — read-only dependency, must exist
- No changes to other auditor task files

### State Transitions

- Before: spec-audit-evaluator.md hard-codes SC-13 cost-frame evaluation rule
- After: spec-audit-evaluator.md reads from reference/cost-model-standards.md via `Read [Text](path)`

### Item 6 — Update spec-audit-evaluator.md SC-13 to reference cost-model-standards

- [ ] **RED.** Write a behavioral enforcement test that verifies the evaluator reads from `reference/cost-model-standards.md` for SC-13 instead of hard-coding the cost-frame rule. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/spec-audit-evaluator.md`:
  - SC-13 (cost-frame): Replace hard-coded evaluation rule with: `Read [cost-model-standards.md](reference/cost-model-standards.md) and verify each SC's cost frame follows the dark-prose-007 pattern.`
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for Read reference to cost-model-standards present; grep for old hard-coded rule removed.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/spec-audit-evaluator.md && git commit -m "Phase 6: Update SC-13 cost-frame to reference cost-model-standards"`

### Phase Completion

- [ ] VbC: Verify SC-6 — grep for Read reference to cost-model-standards present; grep for old hard-coded rule removed
- [ ] Concern transition: Complete. Proceed to Phase 7 (plan-fidelity-evaluator.md PF-7a cost-frame).

---

## Phase 7 — Update plan-fidelity-evaluator.md PF-7a cost-frame

**Concern:** plan-fidelity-evaluator-cost-frame
**Files:** `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`
**SCs:** SC-7
**Dependencies:** Phase 6 complete
**Entry:** Phase 6 committed
**Exit:** plan-fidelity-evaluator.md PF-7a updated to reference cost-model-standards

### Code Path Coverage

- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` PF-7a — cost-frame evaluation rule

### Cross-Cutting SCs

None — SC-7 is phase-specific.

### Interface Boundaries

- `reference/cost-model-standards.md` — read-only dependency, must exist
- No changes to other auditor task files

### State Transitions

- Before: plan-fidelity-evaluator.md hard-codes PF-7a cost-frame evaluation rule
- After: plan-fidelity-evaluator.md reads from reference/cost-model-standards.md via `Read [Text](path)`

### Item 7 — Update plan-fidelity-evaluator.md PF-7a to reference cost-model-standards

- [ ] **RED.** Write a behavioral enforcement test that verifies the evaluator reads from `reference/cost-model-standards.md` for PF-7a instead of hard-coding the cost-frame rule. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`:
  - PF-7a (cost-frame): Replace hard-coded evaluation rule with: `Read [cost-model-standards.md](reference/cost-model-standards.md) and verify each phase's cost frame follows the dark-prose-007 pattern.`
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for Read reference to cost-model-standards present; grep for old hard-coded rule removed.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/plan-fidelity-evaluator.md && git commit -m "Phase 7: Update PF-7a cost-frame to reference cost-model-standards"`

### Phase Completion

- [ ] VbC: Verify SC-7 — grep for Read reference to cost-model-standards present; grep for old hard-coded rule removed
- [ ] Concern transition: Complete. Proceed to Post-Implementation Steps.

---

## Post-Implementation Steps

- [ ] **Structural checks.** Run the finishing checklist to verify all changes are complete and consistent.
  - (**clean-room**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`

- [ ] **Verification.** Run verification-before-completion against all 7 SCs. Produce evidence artifacts for each SC. If any SC FAILs, return BLOCKED with the failing SC IDs.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Audit.** Dispatch the audit skill to verify the plan was executed faithfully against the spec.
  - (**clean-room**) `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`

- [ ] **Cross-validate.** Cross-validate the audit findings against the verification evidence.
  - (**clean-room**) `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`

- [ ] **Review prep.** Prepare the PR for review with a summary of all changes.
  - (**clean-room**) `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow-pr/tasks/review-prep.md\` first")`

- [ ] **Create PR.** Create the pull request with the completed changes.
  - (**clean-room**) `task(..., prompt: "execute create from git-workflow-pr. Read \`git-workflow-pr/tasks/pr-creation/create.md\` first")`

- [ ] **Completion.** Append lifecycle event and report executive summary.
  - (**clean-room**) `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`

## Lifecycle Events

- `2026-07-31T23:10:00Z` — `plan_created` — Plan file at `.opencode/.issues/2211/plan.md` with 7 phases. Authorization scope: `for_plan`. Halt at: `plan_created`.
- `2026-07-31T23:22:00Z` — `plan_revised` — Plan restructured to include all required sections per `reference/plan-structure-standards.md`: Goal/Architecture/Files/Dispatch, Blast Radius, Phase Table, Exit Criteria, per-phase Code Path Coverage/Cross-Cutting SCs/Interface Boundaries/State Transitions/Phase Completion blocks/Concern transitions, and all four admonishments. Dispatch table removed from frontmatter.
