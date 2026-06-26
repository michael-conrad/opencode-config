# Implementation Plan — [#1442](https://github.com/michael-conrad/.opencode/issues/1442) — Auditor gate bypass: conditional `next_step` on FAIL + `all_criteria_pass` enforcement

- **Spec:** [#1442](https://github.com/michael-conrad/.opencode/issues/1442)
- **Goal:** Eliminate the `next_step: proceed` escape hatch on FAIL criteria in auditor task files, and enforce clean PASS via `all_criteria_pass` boolean in the orchestrator gate check.
- **Architecture:** Three changes across 8 files: (1) 7 auditor task files get conditional `next_step` on PASS/FAIL + `all_criteria_pass` field; (2) `create.md` steps 18/20 Z3 checks enforce `all_criteria_pass == true`; (3) orchestrator gate check halts on `all_criteria_pass: false`.
- **Files:**
  - `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`
  - `.opencode/skills/adversarial-audit/tasks/concern-separation.md`
  - `.opencode/skills/adversarial-audit/tasks/spec-audit.md`
  - `.opencode/skills/adversarial-audit/tasks/guideline-audit.md`
  - `.opencode/skills/adversarial-audit/tasks/verification-audit.md`
  - `.opencode/skills/adversarial-audit/tasks/closure-verification.md`
  - `.opencode/skills/adversarial-audit/tasks/cross-validate.md`
  - `.opencode/skills/writing-plans/tasks/create.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Auditor task file template fixes (7 files)

- **Concern:** Fix the per-criterion YAML template in all 7 auditor task files to reject `next_step: proceed` for FAIL criteria and add `all_criteria_pass: bool` field.
- **Files:** `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`, `concern-separation.md`, `spec-audit.md`, `guideline-audit.md`, `verification-audit.md`, `closure-verification.md`, `cross-validate.md`
- **SCs:** SC-1, SC-2, SC-5
- **Dependencies:** None (Phase 1 is independent)
- **Entry conditions:** Approved spec #1442 exists at `.issues/1442/spec.md`
- **Exit conditions:** All 7 auditor task files have conditional `next_step` on PASS/FAIL and `all_criteria_pass: bool` in per-criterion YAML template

- [ ] 1. **Pre-RED common: sc-coherence-gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` with spec #1442. Verify evidence-type uplift and substrate classification for all 6 SCs. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 2. **Pre-RED common: pre-red-baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` with spec #1442. Verify doc-source currency and SC-ID cross-ref traceability. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

- [ ] 3. **RED: plan-fidelity.md template fix (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`. Write a behavioral test that verifies the per-criterion YAML template rejects `next_step: proceed` for FAIL criteria. Test MUST FAIL (RED). **→ SC-1**
  - [ ] 3.1. **Z3 check RED (**inline**).** `solve check` against red-phase output contract.
  - [ ] 3.2. **RED doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for RED-side SC-1 evidence.
  - [ ] 3.3. **Z3 check RED doublecheck (**inline**).** `solve check` against red-doublecheck output contract.
  - [ ] 3.4. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify git diff shows only test file changes.
  - [ ] 3.5. **Z3 check post-RED (**inline**).** `solve check` against post-red-enforcement output contract.
- [ ] 4. **GREEN: plan-fidelity.md template fix (**sub-agent**).** Dispatch `test-driven-development --task green` with target: `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`. Replace unconditional `next_step: "proceed"` with conditional: `next_step: "remediate"` when `result: "FAIL"`, `next_step: "proceed"` when `result: "PASS"`. Add `all_criteria_pass: bool` field. Add yaml+symbolic validation rule. **→ SC-1, SC-2**
  - [ ] 4.1. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract.
  - [ ] 4.2. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. Verify git diff shows only target file changes.
  - [ ] 4.3. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract.
  - [ ] 4.4. **Checkpoint tag create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` for Phase 1 step 4.
  - [ ] 4.5. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep` with message: "Phase 1 step 4: plan-fidelity.md template fix — conditional next_step + all_criteria_pass".
  - [ ] 4.6. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck/format.
  - [ ] 4.7. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for GREEN-side SC-1, SC-2 evidence.
  - [ ] 4.8. **GREEN VbC (**sub-agent**).** Dispatch `verification-before-completion --task completion` for SC-1, SC-2.

- [ ] 5. **RED: concern-separation.md template fix (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/adversarial-audit/tasks/concern-separation.md`. Write behavioral test verifying `next_step: proceed` rejected for FAIL criteria. Test MUST FAIL (RED). **→ SC-1**
  - [ ] 5.1. Z3 check RED (**inline**).
  - [ ] 5.2. RED doublecheck (**sub-agent**).
  - [ ] 5.3. Z3 check RED doublecheck (**inline**).
  - [ ] 5.4. Post-RED enforcement (**sub-agent**).
  - [ ] 5.5. Z3 check post-RED (**inline**).
- [ ] 6. **GREEN: concern-separation.md template fix (**sub-agent**).** Same pattern as step 4 for `concern-separation.md`. **→ SC-1, SC-2**
  - [ ] 6.1. Z3 check GREEN (**inline**).
  - [ ] 6.2. Post-GREEN enforcement (**sub-agent**).
  - [ ] 6.3. Z3 check post-GREEN (**inline**).
  - [ ] 6.4. Checkpoint tag create (**sub-agent**).
  - [ ] 6.5. Checkpoint commit (**sub-agent**).
  - [ ] 6.6. Structural checks (**sub-agent**).
  - [ ] 6.7. GREEN doublecheck (**sub-agent**).
  - [ ] 6.8. GREEN VbC (**sub-agent**).

- [ ] 7. **RED: spec-audit.md template fix (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/adversarial-audit/tasks/spec-audit.md`. Write behavioral test. Test MUST FAIL (RED). **→ SC-1**
  - [ ] 7.1–7.5. RED chain (same pattern as step 5 sub-steps).
- [ ] 8. **GREEN: spec-audit.md template fix (**sub-agent**).** Same pattern as step 4 for `spec-audit.md`. **→ SC-1, SC-2**
  - [ ] 8.1–8.8. GREEN chain (same pattern as step 6 sub-steps).

- [ ] 9. **RED: guideline-audit.md template fix (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/adversarial-audit/tasks/guideline-audit.md`. Write behavioral test. Test MUST FAIL (RED). **→ SC-1**
  - [ ] 9.1–9.5. RED chain.
- [ ] 10. **GREEN: guideline-audit.md template fix (**sub-agent**).** Same pattern as step 4 for `guideline-audit.md`. **→ SC-1, SC-2**
  - [ ] 10.1–10.8. GREEN chain.

- [ ] 11. **RED: verification-audit.md template fix (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/adversarial-audit/tasks/verification-audit.md`. Write behavioral test. Test MUST FAIL (RED). **→ SC-1**
  - [ ] 11.1–11.5. RED chain.
- [ ] 12. **GREEN: verification-audit.md template fix (**sub-agent**).** Same pattern as step 4 for `verification-audit.md`. **→ SC-1, SC-2**
  - [ ] 12.1–12.8. GREEN chain.

- [ ] 13. **RED: closure-verification.md template fix (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/adversarial-audit/tasks/closure-verification.md`. Write behavioral test. Test MUST FAIL (RED). **→ SC-1**
  - [ ] 13.1–13.5. RED chain.
- [ ] 14. **GREEN: closure-verification.md template fix (**sub-agent**).** Same pattern as step 4 for `closure-verification.md`. **→ SC-1, SC-2**
  - [ ] 14.1–14.8. GREEN chain.

- [ ] 15. **RED: cross-validate.md template fix (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/adversarial-audit/tasks/cross-validate.md`. Write behavioral test verifying `all_criteria_pass` field present and `next_step` conditional on PASS/FAIL. Test MUST FAIL (RED). **→ SC-5**
  - [ ] 15.1–15.5. RED chain.
- [ ] 16. **GREEN: cross-validate.md template fix (**sub-agent**).** Same pattern as step 4 for `cross-validate.md`. Note: cross-validate already correctly maps FAIL → `remediate then re-audit` — only add `all_criteria_pass` field and conditional `next_step` on PASS/FAIL. **→ SC-5**
  - [ ] 16.1–16.8. GREEN chain.

#### Phase 1 VbC

- [ ] 17. **VbC (**clean-room**).** Verify all 7 auditor task files have conditional `next_step` (FAIL → `remediate`, PASS → `proceed`) and `all_criteria_pass: bool` field. Verify via `grep` for each file. **→ SC-1, SC-2, SC-5**

**Concern transition:** Leaving auditor template fixes → entering create.md Z3 enforcement. Phase 2 depends on Phase 1 having all 7 auditor files updated with conditional `next_step` and `all_criteria_pass`.

## Phase 2 — create.md Z3 enforcement + behavioral tests

- **Concern:** Fix `create.md` steps 18 and 20 Z3 checks to enforce `all_criteria_pass == true`, and add orchestrator gate check that halts on `all_criteria_pass: false`.
- **Files:** `.opencode/skills/writing-plans/tasks/create.md`
- **SCs:** SC-3, SC-4, SC-6
- **Dependencies:** Phase 1 complete (all 7 auditor files updated)
- **Entry conditions:** Phase 1 VbC PASS
- **Exit conditions:** create.md steps 18/20 enforce `all_criteria_pass == true`; orchestrator halts on `all_criteria_pass: false`

- [ ] 18. **RED: create.md step 18 Z3 check (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/writing-plans/tasks/create.md` step 18. Write behavioral test: run plan creation pipeline with audit-fidelity returning FAIL findings — verify orchestrator halts when `all_criteria_pass: false`. Test MUST FAIL (RED). **→ SC-3**
  - [ ] 18.1. Z3 check RED (**inline**).
  - [ ] 18.2. RED doublecheck (**sub-agent**).
  - [ ] 18.3. Z3 check RED doublecheck (**inline**).
  - [ ] 18.4. Post-RED enforcement (**sub-agent**).
  - [ ] 18.5. Z3 check post-RED (**inline**).
- [ ] 19. **GREEN: create.md step 18 Z3 check (**sub-agent**).** Dispatch `test-driven-development --task green` with target: `.opencode/skills/writing-plans/tasks/create.md` step 18. Modify Z3 check to verify `all_criteria_pass == true` (not just output field existence). **→ SC-3**
  - [ ] 19.1. Z3 check GREEN (**inline**).
  - [ ] 19.2. Post-GREEN enforcement (**sub-agent**).
  - [ ] 19.3. Z3 check post-GREEN (**inline**).
  - [ ] 19.4. Checkpoint tag create (**sub-agent**).
  - [ ] 19.5. Checkpoint commit (**sub-agent**).
  - [ ] 19.6. Structural checks (**sub-agent**).
  - [ ] 19.7. GREEN doublecheck (**sub-agent**).
  - [ ] 19.8. GREEN VbC (**sub-agent**).

- [ ] 20. **RED: create.md step 20 Z3 check (**sub-agent**).** Dispatch `test-driven-development --task red` with target: `.opencode/skills/writing-plans/tasks/create.md` step 20. Write behavioral test: run plan creation pipeline with concern-separation audit returning FAIL — verify orchestrator halts when `all_criteria_pass: false`. Test MUST FAIL (RED). **→ SC-4**
  - [ ] 20.1. Z3 check RED (**inline**).
  - [ ] 20.2. RED doublecheck (**sub-agent**).
  - [ ] 20.3. Z3 check RED doublecheck (**inline**).
  - [ ] 20.4. Post-RED enforcement (**sub-agent**).
  - [ ] 20.5. Z3 check post-RED (**inline**).
- [ ] 21. **GREEN: create.md step 20 Z3 check (**sub-agent**).** Dispatch `test-driven-development --task green` with target: `.opencode/skills/writing-plans/tasks/create.md` step 20. Modify Z3 check to verify `all_criteria_pass == true`. **→ SC-4**
  - [ ] 21.1. Z3 check GREEN (**inline**).
  - [ ] 21.2. Post-GREEN enforcement (**sub-agent**).
  - [ ] 21.3. Z3 check post-GREEN (**inline**).
  - [ ] 21.4. Checkpoint tag create (**sub-agent**).
  - [ ] 21.5. Checkpoint commit (**sub-agent**).
  - [ ] 21.6. Structural checks (**sub-agent**).
  - [ ] 21.7. GREEN doublecheck (**sub-agent**).
  - [ ] 21.8. GREEN VbC (**sub-agent**).

- [ ] 22. **RED: orchestrator gate check (**sub-agent**).** Dispatch `test-driven-development --task red` with target: orchestrator gate check in `create.md`. Write behavioral test: run pipeline with mixed audit results (some PASS, some FAIL) — verify orchestrator halts on `all_criteria_pass: false`. Test MUST FAIL (RED). **→ SC-6**
  - [ ] 22.1. Z3 check RED (**inline**).
  - [ ] 22.2. RED doublecheck (**sub-agent**).
  - [ ] 22.3. Z3 check RED doublecheck (**inline**).
  - [ ] 22.4. Post-RED enforcement (**sub-agent**).
  - [ ] 22.5. Z3 check post-RED (**inline**).
- [ ] 23. **GREEN: orchestrator gate check (**sub-agent**).** Dispatch `test-driven-development --task green` with target: orchestrator gate check. Add `all_criteria_pass` check before proceeding past any audit gate — halt on `all_criteria_pass: false`. **→ SC-6**
  - [ ] 23.1. Z3 check GREEN (**inline**).
  - [ ] 23.2. Post-GREEN enforcement (**sub-agent**).
  - [ ] 23.3. Z3 check post-GREEN (**inline**).
  - [ ] 23.4. Checkpoint tag create (**sub-agent**).
  - [ ] 23.5. Checkpoint commit (**sub-agent**).
  - [ ] 23.6. Structural checks (**sub-agent**).
  - [ ] 23.7. GREEN doublecheck (**sub-agent**).
  - [ ] 23.8. GREEN VbC (**sub-agent**).

#### Phase 2 VbC

- [ ] 24. **VbC (**clean-room**).** Verify create.md steps 18 and 20 enforce `all_criteria_pass == true`. Verify orchestrator gate check halts on `all_criteria_pass: false`. Run behavioral tests for SC-3, SC-4, SC-6. **→ SC-3, SC-4, SC-6**

**Concern transition:** Leaving create.md Z3 enforcement → entering global post-steps. All phases complete.

## Global Post-Steps

- [ ] 25. **Collect behavioral evidence (**sub-agent**).** Collect behavioral evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1442/artifacts/`. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 26. **Adversarial audit (**orchestrator multi-dispatch**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. Dispatch `adversarial-audit --task verification-audit` with auditor_1 (remediate + restart on non-clean-pass). Dispatch same audit with auditor_2 (remediate + restart on non-clean-pass). Both auditors clean PASS. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 27. **Cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate` with `auditor_artifact_paths` from step 26. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 28. **Regression check (**sub-agent**).** Dispatch `test-driven-development --task patterns` (regression) to verify existing plan creation with clean PASS auditors still works. **→ SC-3, SC-4**
- [ ] 29. **Review prep (**sub-agent**).** Dispatch `git-workflow --task review-prep`. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 30. **Exec summary (**sub-agent**).** Dispatch `completion-core --task completion`. Append lifecycle event to issue #1442. Produce chat exec summary. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Self-Review Evidence

| Check | Tool | Result | Classification | Action |
|-------|------|--------|----------------|--------|
| Placeholder scan | `grep -n 'TBD|TODO|FIXME' .issues/1442/plan.md` | No placeholders found | PASS | none |
| Spec reference | `grep -n 'Spec:' .issues/1442/plan.md` | `Spec: #1442` present | PASS | none |
| Dispatch indicator validation | `grep -n '(**inline**)' .issues/1442/plan.md` | No inline dispatch indicators on sub-agent steps | PASS | none |
| SC coverage | Cross-reference plan steps against sc-summary.yaml | All 6 SCs covered across 2 phases | PASS | none |
| Phase dependency | Phase 1 → Phase 2 strict ordering | Acyclic, SAT | PASS | none |

## Exit Criteria

| ID | Criterion |
|----|-----------|
| C1 | All 7 auditor task files have conditional `next_step` (FAIL → `remediate`, PASS → `proceed`) and `all_criteria_pass: bool` field |
| C2 | create.md step 18 Z3 check enforces `all_criteria_pass == true` — orchestrator halts on `all_criteria_pass: false` |
| C3 | create.md step 20 Z3 check enforces `all_criteria_pass == true` — orchestrator halts on `all_criteria_pass: false` |
| C4 | cross-validate.md has `all_criteria_pass` field and conditional `next_step` on PASS/FAIL |
| C5 | Orchestrator gate check halts on `all_criteria_pass: false` before proceeding past any audit gate |
| C6 | Behavioral tests for SC-3, SC-4, SC-6 pass (stderr-based assertions) |
| C7 | Regression: existing plan creation with clean PASS auditors continues to work |
| C8 | Adversarial audit and cross-validate both return clean PASS |
| C9 | Review prep complete |
