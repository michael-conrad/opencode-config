# Implementation Plan — [#1442](https://github.com/michael-conrad/.opencode/issues/1442) — Auditor gate bypass: `next_step: proceed` on FAIL criteria

- **Goal:** Eliminate the `next_step: proceed` escape hatch on FAIL auditor findings by making `next_step` conditional on PASS/FAIL, adding `all_criteria_pass: bool` to result contracts, and enforcing clean PASS in `create.md` Z3 checks.
- **Architecture:** Three changes across two file groups: (1) 7 auditor task files get conditional `next_step` + `all_criteria_pass` field; (2) `create.md` Z3 checks enforce `all_criteria_pass == true` before proceeding past audit gates.
- **Files:** `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`, `concern-separation.md`, `spec-audit.md`, `guideline-audit.md`, `verification-audit.md`, `closure-verification.md`, `cross-validate.md`; `.opencode/skills/writing-plans/tasks/create.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Fix Auditor Task File Templates (7 files)

| Field | Value |
|-------|-------|
| **Concern** | Per-criterion YAML template fix across all 7 auditor task files |
| **Files** | `plan-fidelity.md`, `concern-separation.md`, `spec-audit.md`, `guideline-audit.md`, `verification-audit.md`, `closure-verification.md`, `cross-validate.md` (all under `.opencode/skills/adversarial-audit/tasks/`) |
| **SCs** | SC-1, SC-2, SC-5 |
| **Dependencies** | None |
| **Entry** | Spec approved, feature branch created |
| **Exit** | All 7 auditor task files have conditional `next_step` and `all_criteria_pass` field; grep verification passes |

- [ ] 1. **Pre-RED baseline (**clean-room**).** Read all 7 auditor task files and record current `next_step: "proceed"` occurrences. **→ SC-1, SC-2**
- [ ] 2. **Coherence gate (**clean-room**).** Verify the spec's affected-files list matches actual file paths. Verify the per-criterion template pattern is identical across all 7 files. **→ SC-1, SC-2, SC-5**
- [ ] 3. **RED — plan-fidelity.md (**sub-agent**).** Write a grep-based assertion that verifies `next_step: "proceed"` does NOT appear in any FAIL template in `plan-fidelity.md`. Assertion MUST fail before the fix. **→ SC-1**
- [ ] 4. **GREEN — plan-fidelity.md (**sub-agent**).** Replace the unconditional `next_step: "proceed"` default in the per-criterion YAML template with a conditional: `next_step: "remediate"` when `result: "FAIL"`, `next_step: "proceed"` when `result: "PASS"`. Add `all_criteria_pass: bool` field. Add yaml+symbolic validation rule. **→ SC-1, SC-2**
- [ ] 5. **GREEN doublecheck — plan-fidelity.md (**clean-room**).** Re-run the RED assertion from step 3 — MUST now pass. Verify `all_criteria_pass` appears in the template. **→ SC-1, SC-2**
- [ ] 6. **Checkpoint commit — plan-fidelity.md (**inline**).** `git add` and `git commit` with message `fix(plan-fidelity): conditional next_step on PASS/FAIL, add all_criteria_pass field`. **→ SC-1, SC-2**
- [ ] 7. **RED — concern-separation.md (**sub-agent**).** Same grep assertion as step 3, targeting `concern-separation.md`. MUST fail before fix. **→ SC-1**
- [ ] 8. **GREEN — concern-separation.md (**sub-agent**).** Same template fix as step 4, applied to `concern-separation.md`. **→ SC-1, SC-2**
- [ ] 9. **GREEN doublecheck — concern-separation.md (**clean-room**).** Re-run RED assertion — MUST pass. Verify `all_criteria_pass` present. **→ SC-1, SC-2**
- [ ] 10. **Checkpoint commit — concern-separation.md (**inline**).** `git commit` with message `fix(concern-separation): conditional next_step on PASS/FAIL, add all_criteria_pass field`. **→ SC-1, SC-2**
- [ ] 11. **RED — spec-audit.md (**sub-agent**).** Same grep assertion targeting `spec-audit.md`. MUST fail before fix. **→ SC-1**
- [ ] 12. **GREEN — spec-audit.md (**sub-agent**).** Same template fix applied to `spec-audit.md`. **→ SC-1, SC-2**
- [ ] 13. **GREEN doublecheck — spec-audit.md (**clean-room**).** Re-run RED assertion — MUST pass. Verify `all_criteria_pass` present. **→ SC-1, SC-2**
- [ ] 14. **Checkpoint commit — spec-audit.md (**inline**).** `git commit` with message `fix(spec-audit): conditional next_step on PASS/FAIL, add all_criteria_pass field`. **→ SC-1, SC-2**
- [ ] 15. **RED — guideline-audit.md (**sub-agent**).** Same grep assertion targeting `guideline-audit.md`. MUST fail before fix. **→ SC-1**
- [ ] 16. **GREEN — guideline-audit.md (**sub-agent**).** Same template fix applied to `guideline-audit.md`. **→ SC-1, SC-2**
- [ ] 17. **GREEN doublecheck — guideline-audit.md (**clean-room**).** Re-run RED assertion — MUST pass. Verify `all_criteria_pass` present. **→ SC-1, SC-2**
- [ ] 18. **Checkpoint commit — guideline-audit.md (**inline**).** `git commit` with message `fix(guideline-audit): conditional next_step on PASS/FAIL, add all_criteria_pass field`. **→ SC-1, SC-2**
- [ ] 19. **RED — verification-audit.md (**sub-agent**).** Same grep assertion targeting `verification-audit.md`. MUST fail before fix. **→ SC-1**
- [ ] 20. **GREEN — verification-audit.md (**sub-agent**).** Same template fix applied to `verification-audit.md`. **→ SC-1, SC-2**
- [ ] 21. **GREEN doublecheck — verification-audit.md (**clean-room**).** Re-run RED assertion — MUST pass. Verify `all_criteria_pass` present. **→ SC-1, SC-2**
- [ ] 22. **Checkpoint commit — verification-audit.md (**inline**).** `git commit` with message `fix(verification-audit): conditional next_step on PASS/FAIL, add all_criteria_pass field`. **→ SC-1, SC-2**
- [ ] 23. **RED — closure-verification.md (**sub-agent**).** Same grep assertion targeting `closure-verification.md`. MUST fail before fix. **→ SC-1**
- [ ] 24. **GREEN — closure-verification.md (**sub-agent**).** Same template fix applied to `closure-verification.md`. **→ SC-1, SC-2**
- [ ] 25. **GREEN doublecheck — closure-verification.md (**clean-room**).** Re-run RED assertion — MUST pass. Verify `all_criteria_pass` present. **→ SC-1, SC-2**
- [ ] 26. **Checkpoint commit — closure-verification.md (**inline**).** `git commit` with message `fix(closure-verification): conditional next_step on PASS/FAIL, add all_criteria_pass field`. **→ SC-1, SC-2**
- [ ] 27. **RED — cross-validate.md (**sub-agent**).** Same grep assertion targeting `cross-validate.md`. MUST fail before fix. **→ SC-1, SC-5**
- [ ] 28. **GREEN — cross-validate.md (**sub-agent**).** Same template fix applied to `cross-validate.md`. Note: cross-validate already correctly maps FAIL → `remediate then re-audit` at the consensus level; this fix applies to the per-criterion template only. **→ SC-1, SC-5**
- [ ] 29. **GREEN doublecheck — cross-validate.md (**clean-room**).** Re-run RED assertion — MUST pass. Verify `all_criteria_pass` present. **→ SC-1, SC-5**
- [ ] 30. **Checkpoint commit — cross-validate.md (**inline**).** `git commit` with message `fix(cross-validate): conditional next_step on PASS/FAIL, add all_criteria_pass field`. **→ SC-1, SC-5**
- [ ] 31. **Structural checks — all 7 files (**clean-room**).** Run `grep 'next_step: "proceed"' .opencode/skills/adversarial-audit/tasks/*.md` — verify zero occurrences in FAIL templates. Run `grep 'all_criteria_pass' .opencode/skills/adversarial-audit/tasks/*.md` — verify present in all 7 files. **→ SC-1, SC-2, SC-5**
- [ ] 32. **Checkpoint tag — Phase 1 (**inline**).** Create checkpoint tag: `opencode-config/checkpoint/1442/phase-1-opencode`. **→ SC-1, SC-2, SC-5**

#### Phase 1 VbC

- [ ] 33. **VbC (**clean-room**).** Verify all 7 files have conditional `next_step` and `all_criteria_pass`. Verify zero `next_step: "proceed"` in FAIL templates. **→ SC-1, SC-2, SC-5**

**Concern transition:** Leaving auditor task file template fixes → entering Z3 check enforcement in `create.md`. Phase 2 depends on Phase 1's `all_criteria_pass` field existing in auditor result contracts.

## Phase 2 — Fix create.md Z3 Checks

| Field | Value |
|-------|-------|
| **Concern** | Z3 check enforcement of `all_criteria_pass` in `create.md` Steps 18 and 20 |
| **Files** | `.opencode/skills/writing-plans/tasks/create.md` |
| **SCs** | SC-3, SC-4, SC-6 |
| **Dependencies** | Phase 1 (auditor files must have `all_criteria_pass` field) |
| **Entry** | Phase 1 complete and verified |
| **Exit** | `create.md` Z3 checks enforce `all_criteria_pass == true`; behavioral tests pass |

- [ ] 34. **Pre-RED baseline (**clean-room**).** Read `create.md` Steps 17-20. Record current Z3 check behavior — verify it only checks output field existence, not `all_criteria_pass`. **→ SC-3, SC-4**
- [ ] 35. **Coherence gate (**clean-room**).** Verify the spec's description of the Z3 check gap matches actual code. Verify the fix target (Steps 18 and 20) is correct. **→ SC-3, SC-4**
- [ ] 36. **RED — behavioral test for step 18 (**sub-agent**).** Write a behavioral enforcement test that runs the plan creation pipeline with an audit-fidelity auditor returning FAIL findings. Assert that the orchestrator halts when `all_criteria_pass: false`. Test MUST fail before the fix (orchestrator currently proceeds past FAIL). **→ SC-3**
- [ ] 37. **GREEN — fix create.md step 18 Z3 check (**sub-agent**).** Modify `create.md` Step 18 Z3 check to verify `all_criteria_pass == true`, not just output field existence. Add orchestrator gate check: MUST NOT proceed past audit gate unless `all_criteria_pass: true`. **→ SC-3**
- [ ] 38. **GREEN doublecheck — step 18 (**clean-room**).** Re-run the behavioral test from step 36 — MUST now pass (orchestrator halts on `all_criteria_pass: false`). **→ SC-3**
- [ ] 39. **Checkpoint commit — step 18 fix (**inline**).** `git commit` with message `fix(create.md): enforce all_criteria_pass in step 18 Z3 check`. **→ SC-3**
- [ ] 40. **RED — behavioral test for step 20 (**sub-agent**).** Write a behavioral enforcement test that runs the plan creation pipeline with a concern-separation auditor returning FAIL findings. Assert that the orchestrator halts when `all_criteria_pass: false`. Test MUST fail before the fix. **→ SC-4**
- [ ] 41. **GREEN — fix create.md step 20 Z3 check (**sub-agent**).** Modify `create.md` Step 20 Z3 check identically to step 18: verify `all_criteria_pass == true`. **→ SC-4**
- [ ] 42. **GREEN doublecheck — step 20 (**clean-room**).** Re-run the behavioral test from step 40 — MUST now pass. **→ SC-4**
- [ ] 43. **Checkpoint commit — step 20 fix (**inline**).** `git commit` with message `fix(create.md): enforce all_criteria_pass in step 20 Z3 check`. **→ SC-4**
- [ ] 44. **RED — behavioral test for mixed audit results (**sub-agent**).** Write a behavioral test that runs the pipeline with mixed audit results (some PASS, some FAIL). Assert orchestrator halts on `all_criteria_pass: false`. Test MUST fail before fix. **→ SC-6**
- [ ] 45. **GREEN — orchestrator gate check (**sub-agent**).** Add a general orchestrator gate check that inspects `all_criteria_pass` before proceeding past ANY audit gate. This is the safety net beyond the per-step Z3 checks. **→ SC-6**
- [ ] 46. **GREEN doublecheck — mixed results (**clean-room**).** Re-run the behavioral test from step 44 — MUST now pass. **→ SC-6**
- [ ] 47. **Checkpoint commit — orchestrator gate (**inline**).** `git commit` with message `fix(create.md): add orchestrator gate check for all_criteria_pass`. **→ SC-6**
- [ ] 48. **Regression check (**clean-room**).** Run existing plan creation tests with clean PASS auditors — verify no regression. **→ SC-3, SC-4**
- [ ] 49. **Checkpoint tag — Phase 2 (**inline**).** Create checkpoint tag: `opencode-config/checkpoint/1442/phase-2-opencode`. **→ SC-3, SC-4, SC-6**

#### Phase 2 VbC

- [ ] 50. **VbC (**clean-room**).** Verify all 3 behavioral tests pass. Verify `create.md` Steps 18 and 20 enforce `all_criteria_pass == true`. Verify orchestrator gate check exists. **→ SC-3, SC-4, SC-6**

**Concern transition:** Leaving Z3 check enforcement → entering global post-steps (adversarial audit, cross-validate, review-prep, exec-summary).

## Global Post-Steps

- [ ] 51. **Collect behavioral evidence (**clean-room**).** Gather all behavioral test artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1442/artifacts/`. **→ SC-3, SC-4, SC-6**
- [ ] 52. **Adversarial audit — spec-audit (**sub-agent**).** Dispatch spec-audit on the spec. Verify all SCs are addressed by the plan. **→ All SCs**
- [ ] 53. **Adversarial audit — plan-fidelity (**sub-agent**).** Dispatch plan-fidelity audit on this plan. Verify plan faithfully implements the spec. **→ All SCs**
- [ ] 54. **Adversarial audit — concern-separation (**sub-agent**).** Dispatch concern-separation audit. Verify phases are properly separated. **→ All SCs**
- [ ] 55. **Cross-validate (**sub-agent**).** Dispatch cross-validate across all audit verdicts. Verify consensus. **→ All SCs**
- [ ] 56. **Remediation loop (**sub-agent**).** If any audit returns FAIL, remediate and re-audit per the remediation-first protocol. **→ All SCs**
- [ ] 57. **Review-prep (**sub-agent**).** Run finishing-a-development-branch review-prep. Verify PR body, compare URL, commit hygiene. **→ All SCs**
- [ ] 58. **Executive summary (**inline**).** Report completion: summary, outcome, artifact paths, byline. **→ All SCs**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

| ID | Criterion |
|----|-----------|
| C1 | All 7 auditor task files have conditional `next_step` (remediate on FAIL, proceed on PASS) |
| C2 | All 7 auditor task files include `all_criteria_pass: bool` in per-criterion YAML template |
| C3 | `create.md` Step 18 Z3 check enforces `all_criteria_pass == true` — orchestrator halts on false |
| C4 | `create.md` Step 20 Z3 check enforces `all_criteria_pass == true` — orchestrator halts on false |
| C5 | `cross-validate.md` per-criterion template has conditional `next_step` and `all_criteria_pass` |
| C6 | Orchestrator checks `all_criteria_pass` before proceeding past any audit gate — halts on false |
| C7 | All behavioral tests pass (SC-3, SC-4, SC-6) |
| C8 | All structural/grep tests pass (SC-1, SC-2, SC-5) |
| C9 | No regression in existing plan creation with clean PASS auditors |
| C10 | All adversarial audits pass with consensus |
