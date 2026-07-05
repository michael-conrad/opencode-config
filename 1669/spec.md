> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

Three skill cards in the opencode-config skill deck have defective or incomplete DISPATCH_GATE subsections, causing orchestrators to receive insufficient routing protocol guidance. This leads to incorrect context preloading, sub-agent re-dispatches, and broken work. Two canonical templates also lack DISPATCH_GATE documentation, propagating the defect to future skills. The validation script has no check for DISPATCH_GATE completeness.

## Scope

- Add complete DISPATCH_GATE subsections (Dispatch Context Contract, Sub-Agent Entry Criteria, Orchestrator Entry Criteria) to `adversarial-audit/SKILL.md`, `playwright-cli/SKILL.md`, and `solve/SKILL.md`
- Add DISPATCH_GATE section to `routing-only-template.md` and `skill-card-spec.md`
- Add DISPATCH_GATE completeness check to `validate_skill_cards.py`
- Existing 33 working cards with complete DISPATCH_GATE MUST remain unchanged

## Non-Goals

- **Behavioral enforcement tests** — Not in scope. Behavioral tests for DISPATCH_GATE compliance will be addressed in a follow-up spec.
- **Refactoring existing 33 working cards** — Only the 3 defective cards and 2 templates are modified.
- **Adding new skills** — This spec only fixes existing cards and templates.

## Affected Files

| File | Defect |
|------|--------|
| `.opencode/skills/adversarial-audit/SKILL.md` | Prose-only DISPATCH GATE block, no structured subsections |
| `.opencode/skills/playwright-cli/SKILL.md` | Prose-only DISPATCH GATE block, no structured subsections |
| `.opencode/skills/solve/SKILL.md` | Has DISPATCH_GATE heading + Orchestrator Entry Criteria, missing Dispatch Context Contract and Sub-Agent Entry Criteria |
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | No DISPATCH_GATE section in template |
| `.opencode/skills/skill-creator/reference/skill-card-spec.md` | No DISPATCH_GATE structure mentioned |
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | No check for DISPATCH_GATE completeness |

## Canonical DISPATCH_GATE Structure

From 33 working skills (e.g., `approval-gate/SKILL.md`, `spec-creation/SKILL.md`), the canonical structure has these subsections:

1. **Context cost frame disclaimer** — blockquote noting these are operational bookkeeping notes, not implementation complexity measures
2. **Core rule** — orchestrator MUST NOT preload execution context into `task()` prompts; sub-agents independently discover scope
3. **`#### Forbidden in task() Prompts`** — table with Violation, Forbidden Pattern, Correct Pattern columns
4. **`## Required: Sub-agent Task File Discovery Directive`** — format: `execute <task> from <skill>. Read \`<skill>/tasks/<task>.md\` first`
5. **`#### Dispatch Context Contract`** — allowed fields + exclusions table
6. **`#### Sub-Agent Entry Criteria`** — what sub-agent MUST reject + `PRELOADED_CONTEXT_REJECTED` protocol
7. **`#### Orchestrator Entry Criteria`** — canonical dispatch string mandate

## Evidence Type Classification

This spec changes skill card structure and validation logic. The classification question: "Does this change affect runtime behavior?"

- **SC-1 through SC-5** (file content changes): NO — these are structural changes to markdown files. Evidence type: `string`.
- **SC-6** (validation script change): YES — the validation script executes at runtime and produces exit codes. Evidence type: `behavioral`.
- **SC-7** (regression check): YES — the validation script runs against all cards. Evidence type: `behavioral`.

## Determinism Gate

Each SC has been evaluated for determinism: "If two different auditors read this SC, will they independently produce the same PASS/FAIL result against the same implementation?"

- SC-1 through SC-5: YES — grep for subsection headings is deterministic. Same file, same grep command, same result.
- SC-6: YES — run validation script against a test card, check exit code and stderr. Same test card, same command, same result.
- SC-7: YES — run validation against all cards, check no new violations. Same card set, same command, same result.

## Regression Invariants

1. The 33 skill cards with complete DISPATCH_GATE sections MUST continue to pass validation after the change.
2. The `solve/SKILL.md` existing Orchestrator Entry Criteria content MUST be preserved unchanged.
3. The `playwright-cli/SKILL.md` upstream content (Apache-2.0 licensed) outside the DISPATCH_GATE section MUST NOT be modified.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Success Criteria

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `adversarial-audit/SKILL.md` prose-only DISPATCH GATE block replaced with full structured section containing all 7 subsections | `grep -c "#### Forbidden in task() Prompts" .opencode/skills/adversarial-audit/SKILL.md && grep -c "#### Dispatch Context Contract" .opencode/skills/adversarial-audit/SKILL.md && grep -c "#### Sub-Agent Entry Criteria" .opencode/skills/adversarial-audit/SKILL.md && grep -c "#### Orchestrator Entry Criteria" .opencode/skills/adversarial-audit/SKILL.md` — all MUST return ≥ 1 | If any subsection missing, add the missing subsection from the canonical template | pre-commit | `.opencode/skills/adversarial-audit/SKILL.md` | Problem §Affected Files | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | `playwright-cli/SKILL.md` prose-only DISPATCH GATE block replaced with full structured section; only DISPATCH_GATE section modified | `grep -c "#### Forbidden in task() Prompts" .opencode/skills/playwright-cli/SKILL.md && grep -c "#### Dispatch Context Contract" .opencode/skills/playwright-cli/SKILL.md && grep -c "#### Sub-Agent Entry Criteria" .opencode/skills/playwright-cli/SKILL.md && grep -c "#### Orchestrator Entry Criteria" .opencode/skills/playwright-cli/SKILL.md` — all MUST return ≥ 1; `git diff .opencode/skills/playwright-cli/SKILL.md` shows changes only within DISPATCH_GATE section | If subsection missing, add from canonical template. If changes outside DISPATCH_GATE, revert them | pre-commit | `.opencode/skills/playwright-cli/SKILL.md` | Problem §Affected Files | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | `solve/SKILL.md` gains missing `#### Dispatch Context Contract` and `#### Sub-Agent Entry Criteria` subsections; existing Orchestrator Entry Criteria preserved unchanged | `grep -c "#### Dispatch Context Contract" .opencode/skills/solve/SKILL.md && grep -c "#### Sub-Agent Entry Criteria" .opencode/skills/solve/SKILL.md` — both MUST return ≥ 1; existing Orchestrator Entry Criteria text unchanged | If subsection missing, add from canonical template. If existing content modified, revert | pre-commit | `.opencode/skills/solve/SKILL.md` | Problem §Affected Files | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | `routing-only-template.md` gains DISPATCH_GATE section with all 7 subsections | `grep -c "DISPATCH_GATE" .opencode/skills/skill-creator/reference/routing-only-template.md` — MUST return ≥ 1 | If missing, add DISPATCH_GATE section from canonical template | pre-commit | `.opencode/skills/skill-creator/reference/routing-only-template.md` | Problem §Affected Files | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | `skill-card-spec.md` documents DISPATCH_GATE structure requirements | `grep -c "DISPATCH_GATE" .opencode/skills/skill-creator/reference/skill-card-spec.md` — MUST return ≥ 1 | If missing, add DISPATCH_GATE documentation section | pre-commit | `.opencode/skills/skill-creator/reference/skill-card-spec.md` | Problem §Affected Files | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-6 | `validate_skill_cards.py` gains REQ check validating complete DISPATCH_GATE subsections | Create test SKILL.md with missing DISPATCH_GATE subsection → run `uv run python .opencode/skills/skill-creator/scripts/validate_skill_cards.py` against it → assert exit code non-zero and stderr contains "DISPATCH_GATE" | If check missing, add REQ-6 with subsection detection pattern matching existing REQ checks | pre-commit | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Problem §Affected Files | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-7 | Existing 33 working cards not broken by validation change | Run `uv run python .opencode/skills/skill-creator/scripts/validate_skill_cards.py` against all cards → assert no new violations on previously working cards | If violations appear on working cards, fix validation regex to exclude them | pre-commit | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Problem §Regression Invariants | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Template changes propagate — updating templates means all future skills inherit the DISPATCH_GATE requirement | High | Medium | Validation script catches incomplete cards | SC-6 |
| RISK-2 | Validation false positives — skills that legitimately have no sub-agent dispatch get flagged | Medium | Medium | Allow opt-out marker in frontmatter | SC-6 |
| RISK-3 | `adversarial-audit` has 15 tasks — DISPATCH_GATE section MUST scale correctly | Low | High | Follow canonical pattern that handles multi-task cards | SC-1 |
| RISK-4 | `playwright-cli` is upstream-adapted (Apache-2.0) — structural changes MUST not conflict with upstream provenance | Low | Medium | Only modify DISPATCH_GATE section; preserve upstream content | SC-2 |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Use canonical DISPATCH_GATE structure from approval-gate/SKILL.md | Consistent pattern across all skills reduces cognitive load | MUST | SC-1, SC-2, SC-3 |
| DEC-2 | Replace prose blocks entirely, don't supplement | Prose-only blocks are structurally incompatible with structured subsections | MUST | SC-1, SC-2 |
| DEC-3 | Validation check uses same pattern as existing REQ checks | Consistency with existing validation infrastructure | MUST | SC-6 |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| single-task | 1 | None | single PR |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Validation script | MUST | Update if subsection structure changes |

## Constraints

1. Prose-only blocks in `adversarial-audit` and `playwright-cli` MUST be **replaced**, not supplemented
2. `solve` card MUST only add missing subsections — existing Orchestrator Entry Criteria MUST be preserved
3. `playwright-cli` is upstream-adapted (Apache-2.0) — only the DISPATCH_GATE section MUST be modified
4. Validation MUST use same pattern as existing REQ checks (REQ-1 through REQ-5)
5. Existing 33 working cards MUST remain unchanged

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "DISPATCH_GATE" .opencode/skills/*/SKILL.md` | Identify which skills have complete vs incomplete DISPATCH_GATE |
| Direct source search | `grep -r "Dispatch Context Contract" .opencode/skills/*/SKILL.md` | Verify canonical subsection structure across 33 working skills |
| Direct source search | `grep -r "Sub-Agent Entry Criteria" .opencode/skills/*/SKILL.md` | Verify PRELOADED_CONTEXT_REJECTED protocol presence |
| Direct source search | `grep -r "Orchestrator Entry Criteria" .opencode/skills/*/SKILL.md` | Verify canonical dispatch string mandate presence |
| MCP search | `srclight_search_symbols("validate_skill_cards")` | Locate validation script and understand existing REQ structure |

After this spec is approved, invoke `writing-plans` to create `.issues/1669/plan.md` before implementation begins.

🤖 OpenCode (deepseek-v4-flash) created
