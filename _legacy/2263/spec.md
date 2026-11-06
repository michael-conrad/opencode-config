> **Full spec and artifacts: [`.opencode/.issues/2263/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2263)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2263/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

**Problem Statement:** The `.opencode` framework hardwires a self-contradictory instruction set for the orchestrator. The rule "The orchestrator NEVER performs inline work" (`.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/000-critical-rules.md`) is stated as an absolute, yet the skill cards themselves designate orchestrator-owned inline work (tasks marked `inline` in Trigger Dispatch Tables, operating protocols, persona). There is no compliant path: every skill load forces the orchestrator to reconcile three contradictory signals.

**Root Cause / Motivation:** The framework patches this contradiction with a carve-out asserting that reading a loaded SKILL.md's Trigger Dispatch Table and Invocation section in the orchestrator's own context is NOT "inline work" or "reading a file" — a category error, since a SKILL.md IS a file. This carve-out teaches the agent to rationalize, the exact behavior the framework flags as a bypass signature (critical-rules-006). The contradiction is structural and recurring: prior instances are documented in the `writing-plans-skill-contradiction` research card. Fixing it now eliminates a known no-compliant-path defect that pushes agents toward the behavior the framework calls a CRITICAL VIOLATION.

**Approach Chosen:** Re-scope the "orchestrator never performs inline work" rule from role-purity to an **allocation-by-context-cost** model: work is allocated by context cost (large/disposable → sub-agent; small/necessary → orchestrator), not by role. Delete the false carve-out and replace it with a truthful, defensible justification grounded in context economy and mechanism necessity. Re-express result-contract frugality, the DISPATCH_GATE no-preloaded-context rule, and clean-room sub-agent discipline as direct consequences of protecting the orchestrator's context resource. Preserve the delegation mechanism exactly.

**Alternatives Considered & Why Discarded:** (1) **Per-card patching** — fixing each skill card's inline designation individually. Discarded because the contradiction class is systemic and recurring; per-card patches address symptoms, not the root cause, and the framework would reintroduce the defect in the next skill card. (2) **Role-purity with stronger enforcement** — retaining the "never inline" absolute and enforcing it harder. Discarded because it is incoherent: the orchestrator MUST read SKILL.md routing metadata inline (sub-agents cannot load skills), so a strict absolute would leave no compliant path. Only the context-economy re-scope resolves the contradiction without breaking mechanism necessity.

**Key Design Decisions:** (1) The carve-out is **deleted**, not reworded — the false "a SKILL.md is not a file" claim is removed entirely and replaced with a truthful justification (skill() auto-loads SKILL.md into the orchestrator's context; the routing metadata is small, necessary, and already present; sub-agents cannot load skills). Tradeoff: requires updating two Tier 1 guideline files and 36 skill cards for consistency. (2) The re-scope explicitly distinguishes **"cost-blind"** (verification/execution cost — never skip a tool call) from **"context-cost"** (orchestrator's persistent context resource) to avoid a new perceived contradiction with line 217. (3) The re-scope is a **documentation/instruction-model fix** — no change to which tasks are delegated vs inline, no change to the delegation mechanism.

**User Intent / Original Prompt:** Resolve the internal contradiction in the `.opencode` instruction set where "the orchestrator never performs inline work" coexists with skill cards that designate orchestrator-owned inline work, so the orchestrator has a compliant path on every skill load.

## 2. Not Included

- **Change to the delegation mechanism** — `task()`, `skill()`, and clean-room sub-agent dispatch are preserved exactly as-is; the fix is documentation/instruction-model only.
- **Change to which tasks are delegated vs inline** — no behavioral pipeline change; only the framing of the inline-work rule changes.
- **Change to the DISPATCH_GATE no-preloaded-context requirement's substance** — only its justification changes.
- **Changes to task cards (`tasks/<name>.md`)** — these are sub-agent-facing and unaffected.
- **Changes to `.opencode/tools/` scripts or pipeline behavior** — unchanged.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The absolute "orchestrator NEVER performs inline work" is replaced in `.opencode/guidelines/020-go-prohibitions.md` with the allocation-by-context-cost model (large/disposable → sub-agent; small/necessary → orchestrator). | string | grep `020-go-prohibitions.md`: assert no "NEVER performs inline work" absolute remains; assert allocation-by-context-cost language present. |
| SC-2 | The false carve-out phrase ("reading a SKILL.md is NOT 'inline work' or 'reading a file'") is deleted from `.opencode/guidelines/020-go-prohibitions.md` and replaced with a truthful context-economy justification (skill() auto-loads SKILL.md; routing metadata is small/necessary; sub-agents cannot load skills). | string | grep `020-go-prohibitions.md`: assert the false carve-out phrase is absent; assert the truthful context-economy justification present. |
| SC-3 | Result-contract frugality, the DISPATCH_GATE no-preloaded-context rule, and clean-room sub-agent discipline in `.opencode/guidelines/020-go-prohibitions.md` §1.1 are re-expressed as direct consequences of protecting the orchestrator's context resource, with their substance unchanged. | string | grep `020-go-prohibitions.md` §1.1: assert the three mechanisms are re-expressed under context-economy; assert substance unchanged. |
| SC-4 | The critical-rules-XXX "Dispatching SKILL.md to sub-agents — category error" rule in `.opencode/guidelines/000-critical-rules.md` is re-justified under context-economy, the category-error prohibition is preserved, and no false "not a file" claim remains. | string | grep `000-critical-rules.md`: assert critical-rules-XXX re-justified; assert category-error prohibition intact; assert no false "not a file" claim. |
| SC-5 | All 36 DISPATCH_GATE skill cards' "Orchestrator Entry Criteria" sections re-justify the orchestrator reading Trigger Dispatch Table + Invocation in its own context under the context-economy rationale, with the no-preloaded-context substance unchanged. | string | grep all DISPATCH_GATE skill cards: assert consistent context-economy justification; assert no-preloaded-context substance unchanged. |
| SC-6 | The self-contradiction is eliminated — no affected file contains both the "never inline" absolute and inline-designated tasks without reconciliation under the context-economy model; the orchestrator can load a skill and dispatch without reconciling contradictory signals. | behavioral | Run a skill-load scenario via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; assert the orchestrator loads a skill and dispatches without triggering a contradiction. |
| SC-7 | The delegation mechanism (task(), skill(), clean-room sub-agents) is preserved exactly (no change to which tasks are delegated vs inline) and "cost-blind" (verification cost) is explicitly distinguished from "context-cost" (orchestrator context resource). | string | grep affected files: assert delegation mechanism unchanged; assert cost-blind vs context-cost distinction explicit. |
| SC-8 | The defective CROSS_MODEL_GAP cross-model validation requirement is removed from `.opencode/skills/verification-before-completion/tasks/verify.md` §4.5, replaced with a single-model verification model consistent with the framework's DEFAULT_TEST_MODEL contract. The false Spec #262 authority line is removed. No residual mandate requires multi-model/cloud cross-verification runs. | string | grep `verification-before-completion/tasks/verify.md` §4.5: assert CROSS_MODEL_GAP cross-model requirement absent; assert single-model verification consistent with DEFAULT_TEST_MODEL present; assert Spec #262 authority line absent. |

## 4. Requirements

- R-1. The `.opencode/guidelines/020-go-prohibitions.md` inline-work rule SHALL re-scope from role-purity to allocation-by-context-cost, allocating large/disposable work to sub-agents and small/necessary routing-relevant work to the orchestrator.
- R-2. The false carve-out in `.opencode/guidelines/020-go-prohibitions.md` SHALL be deleted and replaced with a truthful justification grounded in context economy (skill() auto-loads SKILL.md; routing metadata is small/necessary; sub-agents cannot load skills).
- R-3. Result-contract frugality, the DISPATCH_GATE no-preloaded-context rule, and clean-room sub-agent discipline SHALL be re-expressed as direct consequences of protecting the orchestrator's context resource, with their substance unchanged.
- R-4. The critical-rules-XXX rule in `.opencode/guidelines/000-critical-rules.md` SHALL be re-justified under context-economy, preserving the category-error prohibition and removing any false "not a file" claim.
- R-5. All 36 DISPATCH_GATE skill cards SHALL re-justify the "Orchestrator Entry Criteria" under the context-economy rationale, with the no-preloaded-context substance unchanged.
- R-6. The self-contradiction SHALL be eliminated so a compliant path exists for the orchestrator on every skill load.
- R-7. The delegation mechanism SHALL remain unchanged, and "cost-blind" (verification cost) SHALL be explicitly distinguished from "context-cost" (orchestrator context resource).
- R-8. The enforcement of actual inline work (file edits, analysis, verification of large/disposable work) SHALL be preserved — the re-scope SHALL NOT be read as loosening the prohibition on orchestrator doing large/disposable work inline.
- R-9. The cross-model validation requirement in `.opencode/skills/verification-before-completion/tasks/verify.md` §4.5 SHALL be removed and replaced with a single-model verification model consistent with the framework's DEFAULT_TEST_MODEL contract; the false Spec #262 authority line SHALL be removed; no residual mandate SHALL require multi-model/cloud cross-verification runs.

## 5. Items

Each item maps to exactly one SC and follows a RED → GREEN → verify → commit TDD cycle.

### Item 1 (SC-1): Re-scope `020-go-prohibitions.md` to allocation-by-context-cost

- RED: Enforcement test asserts the "NEVER performs inline work" absolute is present (fails because the change doesn't exist yet).
- GREEN: Replace the role-purity absolute with the allocation-by-context-cost model in `.opencode/guidelines/020-go-prohibitions.md`.
- verify: grep `020-go-prohibitions.md`: no "NEVER performs inline work" absolute remains; allocation-by-context-cost language present.
- commit: The re-scoped rule text in `020-go-prohibitions.md`.

### Item 2 (SC-2): Delete the false carve-out and replace with truthful justification

- RED: Enforcement test asserts the false carve-out phrase is present (fails because the deletion doesn't exist yet).
- GREEN: Delete the false carve-out phrase and replace with a truthful context-economy justification in `.opencode/guidelines/020-go-prohibitions.md`.
- verify: grep `020-go-prohibitions.md`: false carve-out phrase absent; truthful justification present.
- commit: The carve-out replacement in `020-go-prohibitions.md`.

### Item 3 (SC-3): Re-justify mechanisms under context-economy

- RED: Enforcement test asserts the mechanisms are not yet re-expressed under context-economy (fails).
- GREEN: Re-express result-contract frugality, DISPATCH_GATE no-preloaded-context, and clean-room sub-agent discipline as direct consequences of protecting the orchestrator's context resource in `.opencode/guidelines/020-go-prohibitions.md` §1.1.
- verify: grep `020-go-prohibitions.md` §1.1: three mechanisms re-expressed under context-economy; substance unchanged.
- commit: The §1.1 re-justification in `020-go-prohibitions.md`.

### Item 4 (SC-4): Update `000-critical-rules.md` critical-rules-XXX

- RED: Enforcement test asserts the category-error rule is not yet re-justified (fails).
- GREEN: Re-justify the critical-rules-XXX rule under context-economy in `.opencode/guidelines/000-critical-rules.md`, preserving the category-error prohibition and removing any false "not a file" claim.
- verify: grep `000-critical-rules.md`: critical-rules-XXX re-justified; category-error prohibition intact; no false "not a file" claim.
- commit: The critical-rules-XXX update in `000-critical-rules.md`.

### Item 5 (SC-5): Update skill cards' DISPATCH_GATE sections

- RED: Enforcement test asserts skill cards are not yet re-justified (fails).
- GREEN: Re-justify the "Orchestrator Entry Criteria" in all 36 DISPATCH_GATE skill cards under the context-economy rationale, preserving the no-preloaded-context substance.
- verify: grep all 36 DISPATCH_GATE skill cards: consistent context-economy justification; no-preloaded-context substance unchanged.
- commit: The 36 skill card DISPATCH_GATE updates.

### Item 6 (SC-6): Eliminate the self-contradiction

- RED: Enforcement test asserts a residual contradiction exists when the orchestrator loads a skill (fails).
- GREEN: Ensure all affected files are consistent — no file contains both the "never inline" absolute and inline-designated tasks without reconciliation.
- verify: Behavioral — run a skill-load scenario via `opencode run`; assert the orchestrator loads a skill and dispatches without triggering a contradiction.
- commit: Cross-file consistency changes.

### Item 7 (SC-7): Preserve delegation mechanism and distinguish cost dimensions

- RED: Enforcement test asserts the delegation mechanism or cost-dimension distinction is not yet verified (fails).
- GREEN: Verify the delegation mechanism is unchanged and the cost-blind vs context-cost distinction is explicit (verification-only; no behavioral file change to delegation).
- verify: grep affected files: delegation mechanism unchanged; cost-blind vs context-cost distinction explicit.
- commit: Any documentation clarifying the cost-dimension distinction.

### Item 8 (SC-8): Remove defective cross-model validation requirement from verify.md §4.5

- RED: Enforcement test asserts the CROSS_MODEL_GAP cross-model validation requirement is present in `.opencode/skills/verification-before-completion/tasks/verify.md` §4.5 (fails because the removal doesn't exist yet).
- GREEN: Remove the CROSS_MODEL_GAP cross-model validation requirement from `.opencode/skills/verification-before-completion/tasks/verify.md` §4.5 and replace it with a single-model verification model consistent with the framework's DEFAULT_TEST_MODEL contract; remove the false Spec #262 authority line.
- verify: grep `verification-before-completion/tasks/verify.md` §4.5: CROSS_MODEL_GAP cross-model requirement absent; single-model verification consistent with DEFAULT_TEST_MODEL present; Spec #262 authority line absent.
- commit: The §4.5 replacement and authority-line removal in `verification-before-completion/tasks/verify.md`.

## 6. Dependencies

- **Reference:** `.opencode/reference/spec-structure-standards.md`, `.opencode/reference/cost-model-standards.md` — **Relationship:** The spec body must conform to these canonical standards during assembly; read before implementation. **Status:** Satisfied.
- **Reference:** `.opencode/guidelines/020-go-prohibitions.md` §1.1 — **Relationship:** The existing context-economy framing (lines 84-137) is the grounding for the re-scope; must be read before Item 1-3. **Status:** Satisfied.
- **Reference:** `.opencode/guidelines/000-critical-rules.md` — **Relationship:** critical-rules-XXX must align with the re-scoped 020; must be consistent during Item 4. **Status:** Satisfied.
- **Reference:** 36 skill cards with DISPATCH_GATE sections — **Relationship:** Their "Orchestrator Entry Criteria" must be re-justified consistently; Item 5. **Status:** Satisfied.
- **Reference:** Open specs #1406, #1204, #1010 — **Relationship:** Alignment with specs touching orchestrator enforcement to avoid conflicting instruction models; must be verified before implementation per authority-source protocol. **Status:** Pending (verify at implementation).
- **Reference:** `.issues/research-cards/spec-writing-ai-agents-opencode-skill-architecture.md` (confidence 0.90) — **Relationship:** Grounds the mechanism-necessity justification (skill() auto-loads SKILL.md; sub-agents lack skill()). **Status:** Satisfied.
- **Reference:** `.opencode/skills/verification-before-completion/tasks/verify.md` §4.5 — **Relationship:** The defective CROSS_MODEL_GAP cross-model validation requirement is removed and replaced with a single-model verification model consistent with the DEFAULT_TEST_MODEL contract; Item 8. **Status:** Satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-3 | Phase 3 |
| R-4 | SC-4 | Phase 4 |
| R-5 | SC-5 | Phase 5 |
| R-6 | SC-6 | Phase 6 |
| R-7 | SC-7 | Phase 7 |
| R-8 | SC-1, SC-7 | Phase 1, Phase 7 |
| R-9 | SC-8 | Phase 8 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| 020-go-prohibitions.md inline-work rule | code | `.opencode/guidelines/020-go-prohibitions.md` | grep + read (verified 2026-08-10) |
| 000-critical-rules.md critical-rules-XXX | code | `.opencode/guidelines/000-critical-rules.md` | grep + read (verified 2026-08-10) |
| 36 skill card DISPATCH_GATE sections | code | `.opencode/skills/*/SKILL.md` | grep + read (verified 2026-08-10) |
| spec-creation/SKILL.md inline designations | code | `.opencode/skills/spec-creation/SKILL.md` | read (verified 2026-08-10) |
| brainstorming/SKILL.md inline designations | code | `.opencode/skills/brainstorming/SKILL.md` | read (verified 2026-08-10) |
| git-workflow-cleanup/SKILL.md executor note | code | `.opencode/skills/git-workflow-cleanup/SKILL.md` | read (verified 2026-08-10) |
| skill architecture research | doc | `.issues/research-cards/spec-writing-ai-agents-opencode-skill-architecture.md` | read (confidence 0.90, status active) |
| prior contradiction research | doc | `.issues/research-cards/writing-plans-skill-contradiction.md` | read (confidence 0.95, status resolved) |
| verification-before-completion/tasks/verify.md §4.5 cross-model gate | code | `.opencode/skills/verification-before-completion/tasks/verify.md` | grep + read (verified 2026-08-10) |
| tests-v2 default model contract | code | `.opencode/tests-v2/default-model.sh`, `.opencode/tests-v2/AGENTS.md` §10.6 | read (verified 2026-08-10) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the re-scope costs one grep of `020-go-prohibitions.md`. Skipping means the role-purity absolute persists, forcing the orchestrator to rationalize a false carve-out on every skill load — the exact defect this spec eliminates.
- **SC-2:** Verifying the carve-out deletion costs one grep for the false phrase. Skipping means the category error survives and continues teaching rationalization, compounding into the bypass signature the framework flags as a CRITICAL VIOLATION.
- **SC-3:** Verifying the mechanism re-justification costs one grep of §1.1. Skipping means result-contract frugality and clean-room discipline remain justified by a false premise, undermining the entire delegation-integrity model.
- **SC-4:** Verifying the 000-critical-rules.md alignment costs one grep. Skipping means the category-error rule diverges from the re-scoped 020, reintroducing the cross-file contradiction.
- **SC-5:** Verifying the skill card alignment costs a grep across 36 cards. Skipping means the DISPATCH_GATE sections diverge from the re-scoped rule, recreating the contradiction at the point of dispatch.
- **SC-6:** Running the behavioral test costs minutes of execution time. Skipping means a residual contradiction ships, and the orchestrator is pushed toward rationalization in production — the behavioral defect this spec exists to prevent.
- **SC-7:** Verifying delegation preservation costs one grep. Skipping means the re-scope could be read as changing which tasks are delegated, a behavioral regression that breaks the pipeline's integrity.
- **SC-8:** Verifying the §4.5 removal costs one grep of `verify.md` §4.5. Skipping means the defective CROSS_MODEL_GAP requirement survives, mandating an impossible two-model cloud run that contradicts the framework's single-model DEFAULT_TEST_MODEL contract and blocks legitimate verification.

## 11. Edge Cases

- **Condition:** A skill card's inline designation is not updated after the 020 re-scope. **Expected behavior:** The card retains the "never inline" absolute context, leaving a residual contradiction. **Resolution:** SC-5 (all 36 cards) and SC-6 (behavioral cross-check) catch the divergence; fix the inconsistent card.
- **Condition:** The re-scope is read as loosening the inline-work prohibition. **Expected behavior:** Large/disposable work (file analysis, verification, composition) remains delegated to sub-agents. **Resolution:** SC-1 language explicitly retains clean-room sub-agent dispatch for large/disposable work; SC-7 guards delegation preservation.
- **Condition:** The carve-out replacement reintroduces a category error. **Expected behavior:** No false "a SKILL.md is not a file" claim remains. **Resolution:** SC-2 (grep for false phrase) and SC-4 (000-critical-rules.md must not reintroduce it).
- **Condition:** 000-critical-rules.md diverges from the re-scoped 020. **Expected behavior:** Both Tier 1 files are consistent. **Resolution:** SC-4 and SC-6 cross-file consistency check.
- **Condition:** "Cost-blind" (verification cost) is conflated with "context-cost" (orchestrator context resource). **Expected behavior:** The two cost dimensions are explicitly distinguished. **Resolution:** SC-1/SC-3 add the explicit distinction; SC-7 verifies it.
- **Condition:** A behavioral enforcement test in `tests-v2/behaviors/` asserts the "never inline" absolute. **Expected behavior:** The test is updated to assert the context-economy model. **Resolution:** SC-6 includes updating such tests to assert the new model.
- **Condition:** The behavioral test (SC-6) is expensive/flaky. **Expected behavior:** Scope-limited single scenario, stderr-based assertions, `with-test-home` isolation, >=600s timeout. **Resolution:** Per the scope-limited behavioral testing mandate and behavioral test conventions.
- **Condition:** A residual multi-model/cloud cross-verification mandate remains in `verify.md` or elsewhere. **Expected behavior:** No residual mandate requires multi-model/cloud runs. **Resolution:** SC-8 (grep §4.5 for CROSS_MODEL_GAP and Spec #262) catches the divergence; fix the inconsistent text.

## 12. Change Control

| Date | Change | Reason | Authorizer |
|------|--------|--------|------------|
| 2026-08-10 | Added SC-8: removed defective CROSS_MODEL_GAP cross-model validation requirement from `verify.md` §4.5, replaced with single-model verification consistent with DEFAULT_TEST_MODEL contract; removed false Spec #262 authority line. Added R-9, Item 8, Dependencies/Documentation Sources references, Traceability row, Cost Frame and Edge Case entries. | Implementation discovered §4.5 mandates impossible two-model cloud runs contradicting the framework's single canonical model (DEFAULT_TEST_MODEL) per the No-Outguess Mandate; Spec #262 does not exist. | Spec revision (implementation-discovered defect) |
| 2026-08-10 | Corrected Evidence Type from structural to string for SC-1, SC-2, SC-3, SC-4, SC-5, SC-7, SC-8 to match their grep verification methods (declaration-only; no SC criterion text, requirement, or scope changed). SC-6 remains behavioral. Updated sc-summary.yaml sc types accordingly. | Dimension 5 Testability validation finding: seven SCs declared structural but their verification methods are grep pattern matches (string evidence per TDD taxonomy). | Spec revision (validation finding) |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
