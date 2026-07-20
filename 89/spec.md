## Problem Statement

The adversarial audit skill evaluates specs and tests against success criteria (SCs), but the current SC evaluation criteria focus on structural quality (problem statement presence, measurability, phase structure) and never ask: **does this SC actually test the right dimensions?** Specifically, the current criteria don't check whether SCs cover functional testing, blast radius testing, LLM behavioral testing, sequential workflow correctness, or error path coverage.

Additionally, the `test-quality-audit` task uses a tri-state result system (PASS/FAIL/INCONCLUSIVE) that allows AI auditors to rationalize marginal cases as INCONCLUSIVE instead of making a hard PASS-or-FAIL judgment. This is a compliance loophole — INCONCLUSIVE lets auditors avoid failing specs that should fail.

## Success Criteria

### SC-1: spec-audit includes five new test dimension criteria

The `spec-audit` task's Step 2 evaluation criteria table includes SC-12 through SC-16:

| ID | Dimension | What the auditor evaluates per applicable SC |
|----|-----------|---------------------------------------------|
| SC-12 | Functional testing coverage | Does this SC specify what functional behavior to test and verification method? |
| SC-13 | Blast radius testing | Does this SC identify downstream dependents and specify verification they aren't broken? |
| SC-14 | LLM behavioral testing | Does this SC specify behavioral test criteria (prompt → expected agent action) for agent behavior changes? |
| SC-15 | Sequential workflow correctness | For multi-step workflows, does this SC verify step-output-to-step-input correctness? |
| SC-16 | Error path coverage | Does this SC specify verification for failure paths, not just happy path? |

**Verification:** Read `spec-audit.md` Step 2 criteria table — SC-12 through SC-16 must be present with descriptions matching the table above.

### SC-2: spec-audit includes per-SC dimension applicability step

The `spec-audit` task includes a new Step 2.5 that instructs the auditor to determine which of the five test dimensions apply to each SC, evaluating only applicable (dimension, SC) pairs. Non-applicable pairs are omitted from the result — no NOT_APPLICABLE, no SKIPPED, no tri-state.

**Verification:** Read `spec-audit.md` — Step 2.5 must exist describing per-SC dimension applicability evaluation with non-applicable dimensions omitted from results.

### SC-3: spec-audit result contract includes sc_dimensions field

The `spec-audit` result contract (Step 6) includes an `sc_dimensions` sub-field on each SC entry where at least one test dimension applies. The field maps dimension IDs (SC-12 through SC-16) to their evaluation results. SCs with no applicable dimensions have no `sc_dimensions` entry.

**Verification:** Read `spec-audit.md` Step 6 result contract — it must include `sc_dimensions` field with per-dimension entries containing `applicable`, `auditor_1_result`, `auditor_2_result`, `consensus`, and `evidence` fields.

### SC-4: spec-audit result contract uses YAML format

The `spec-audit` result contract (Step 6) is expressed in YAML, not JSON.

**Verification:** Read `spec-audit.md` Step 6 — result contract must be YAML-formatted.

### SC-5: spec-audit includes symbolic rule for dimension omission

The `spec-audit.md` yaml+symbolic block includes rule `spec-audit-005` that enforces: when a dimension is not applicable to an SC, that dimension must be omitted from the result (not included as NOT_APPLICABLE or SKIPPED).

**Verification:** Read `spec-audit.md` yaml+symbolic block — rule `spec-audit-005` must be present with conditions detecting non-applicable dimensions included in results and action to omit them.

### SC-6: SC-DET prerequisite linkage — dimension evaluation requires SC-DET result first

The `spec-audit` Step 2.5 template enforces form ordering: the auditor must record the SC-DET result for an SC before filling in any dimension fields (SC-12 through SC-16) for that SC. This channels the auditor into evaluating determinism before coverage, making dimension evaluation more rigorous because the auditor has already committed to a quality assessment of the SC.

The SC-DET result is a prerequisite field in the per-SC dimension evaluation form — not a rule that blocks evaluation, but a form structure that records it first. An SC that FAILs SC-DET can still have dimensions evaluated (a non-deterministic SC with missing test coverage is worse than a non-deterministic SC alone — the double-FAIL is useful signal).

**Verification:** Read `spec-audit.md` Step 2.5 — the per-SC dimension evaluation template must include SC-DET result as a prerequisite field before dimension fields.

### SC-7: Applicability mismatches count against the spec

When cross-validation (Step 4) reveals that one auditor evaluated a dimension for an SC and the other did not, the mismatch is flagged as a spec quality finding — not an auditor failure. The spec was ambiguous enough that two reasonable auditors disagreed about whether a dimension applies. The resolution targets the spec ("tighten language so applicability is determinable for this dimension"), not the auditors.

Applies to all five dimensions equally: functional, blast radius, LLM behavioral, workflow sequence, error path.

The result contract must include an `applicability_mismatches` field listing each (SC, dimension) pair where auditors disagreed on applicability, with a one-line explanation of why the spec language was ambiguous.

**Verification:** Read `spec-audit.md` Step 4 — cross-validation procedure must treat applicability mismatches as spec quality findings with spec-targeted resolution, and Step 6 result contract must include `applicability_mismatches` field.

### SC-8: test-quality-audit includes five new structural criteria

The `test-quality-audit` task's Step 2 includes TQ-6 through TQ-10:

| ID | Dimension | PASS condition | FAIL condition |
|----|-----------|---------------|----------------|
| TQ-6 | Functional test coverage | Tests exercise specified functional behavior, not just structural checks | Tests are purely structural for behavioral SCs |
| TQ-7 | Blast radius test coverage | Tests cover downstream dependents affected by the change | Change affects shared interface with no dependent tests |
| TQ-8 | LLM behavioral test coverage | Behavioral enforcement tests verify agent behavior matches the rule | Agent behavior change has only content-verification, no behavioral test |
| TQ-9 | Workflow integration test coverage | Tests verify multi-step sequences produce correct end-to-end results | Only unit tests exist for a multi-step workflow |
| TQ-10 | Error path test coverage | Tests include negative tests for failure scenarios | Only happy-path tests exist for failure-prone operations |

**Verification:** Read `test-quality-audit.md` Step 2 — TQ-6 through TQ-10 must be present with binary PASS/FAIL conditions.

### SC-9: test-quality-audit uses binary results exclusively

All criteria in `test-quality-audit` (original TQ-1 through TQ-5 and new TQ-6 through TQ-10) use binary PASS/FAIL results. The INCONCLUSIVE state is removed entirely — no tri-state, no middle ground.

**Verification:** Read `test-quality-audit.md` — Step 2 criteria, Step 3 verdict format, and Step 4 result contract must all use only PASS or FAIL. No INCONCLUSIVE state anywhere in the file.

### SC-10: test-quality-audit verdict format uses YAML

The `test-quality-audit` Step 3 verdict format and Step 4 result contract are expressed in YAML, not JSON.

**Verification:** Read `test-quality-audit.md` Steps 3 and 4 — both must be YAML-formatted.

### SC-11: test-quality-audit result contract includes TQ-6 through TQ-10 with dimension-scoped remediation

The `test-quality-audit` Step 4 result contract includes all ten criteria (TQ-1 through TQ-10) with binary PASS/FAIL results. For TQ-6 through TQ-10, the `remediation` field must include the specific dimension that failed — e.g., `FIX_TEST(error_path)` instead of just `FIX_TEST`. This forces the auditor to identify exactly which dimension failed rather than issuing a vague remediation.

Remediation values for TQ-6 through TQ-10:
- TQ-6: `FIX_TEST(functional)` or `SPEC_GAP(functional)`
- TQ-7: `FIX_TEST(blast_radius)` or `FIX_CODE(blast_radius)`
- TQ-8: `FIX_TEST(llm_behavior)` or `SPEC_GAP(llm_behavior)`
- TQ-9: `FIX_TEST(workflow)` or `SPEC_GAP(workflow)`
- TQ-10: `FIX_TEST(error_path)` or `SPEC_GAP(error_path)`

TQ-1 through TQ-5 retain their existing remediation format (FIX_TEST, FIX_CODE, SPEC_GAP without dimension scoping).

**Verification:** Read `test-quality-audit.md` Step 4 result contract — criteria entries for TQ-6 through TQ-10 must include dimension-scoped remediation values. TQ-1 through TQ-5 must retain their original remediation format.

### SC-12: concern enumeration — single concern

This spec addresses one concern: enhancing adversarial audit criteria with test dimension coverage and enforcing binary results. No other concerns are mixed in.

**Verification:** Read spec body — all success criteria address this single concern.

## Phases

### Phase 1: Update spec-audit evaluation criteria

**Steps:**
1. Add SC-12 through SC-16 to Step 2 evaluation criteria table in `spec-audit.md`
2. Add Step 2.5 (per-SC dimension applicability evaluation) to `spec-audit.md`, including SC-DET prerequisite as a form-ordering field in the per-SC template
3. Update Step 4 cross-validation to treat applicability mismatches as spec quality findings
4. Update Step 6 result contract in `spec-audit.md` to YAML format with `sc_dimensions` field and `applicability_mismatches` field
5. Add `spec-audit-005` symbolic rule to `spec-audit.md` yaml+symbolic block

**Files:** `spec-audit.md`

### Phase 2: Update test-quality-audit criteria and results

**Steps:**
1. Add TQ-6 through TQ-10 evaluation subsections to Step 2 in `test-quality-audit.md`
2. Convert all existing criteria (TQ-1 through TQ-5) from PASS/FAIL/INCONCLUSIVE to binary PASS/FAIL
3. Update Step 3 verdict format to YAML with binary results only
4. Update Step 4 result contract to YAML with all ten criteria (TQ-1 through TQ-10), including dimension-scoped remediation for TQ-6 through TQ-10

**Files:** `test-quality-audit.md`

## Dependencies

None — this spec modifies two independent task files.

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Per-SC dimension evaluation bloats auditor context | Medium | Medium | Non-applicable dimensions omitted from result; auditor only evaluates applicable pairs |
| Binary enforcement causes false FAIL on ambiguous specs | Low | Medium | Auditor determines applicability before evaluation; if dimension doesn't apply, it's omitted entirely |
| TQ-8 (LLM behavioral) frequently omitted for non-agent specs | Expected | Low | Omission is correct behavior — not every spec affects agent behavior |
| SC-DET prerequisite adds form overhead | Low | Low | Single field per SC; not a blocking rule, just form ordering |
| Dimension-scoped remediation forces specificity | Expected | Low | Intended behavior — prevents vague remediation |
| Applicability mismatches flagged against spec | Low | Low | Correct target — spec ambiguity causes the mismatch, not auditor error |

## Documentation Sources

- `adversarial-audit/tasks/spec-audit.md` — current evaluation criteria
- `adversarial-audit/tasks/test-quality-audit.md` — current structural criteria
- `adversarial-audit/SKILL.md` — skill routing and context audit table
- `080-code-standards.md` — behavioral enforcement test mandate (SC-to-test traceability)
- `065-verification-honesty.md` — verification evidence requirements
- `091-incremental-build.md` — TDD RED/GREEN cycle for rule changes

## Change Control

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-05-15 | Initial spec | 🤖 opencode (ollama-cloud/glm-5.1) |
| 1.1 | 2026-05-15 | Added SC-6: SC-DET prerequisite linkage (dark pattern #1) | 🤖 opencode (ollama-cloud/glm-5.1) |
| 1.2 | 2026-05-15 | Added SC-10: dimension-scoped remediation for TQ-6 through TQ-10 (dark pattern #3) | 🤖 opencode (ollama-cloud/glm-5.1) |
| 1.3 | 2026-05-15 | Added SC-7: applicability mismatches count against the spec (dark pattern #4) | 🤖 opencode (ollama-cloud/glm-5.1) |

Co-authored with AI: opencode (ollama-cloud/glm-5.1)