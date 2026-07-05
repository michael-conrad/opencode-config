# [SPEC-FIX] Orchestrator MUST revise defective sub-agent deliverables, not replace or inline-fix them

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | When a sub-agent produces a defective deliverable, the orchestrator has two defective response patterns: inline-fixing the artifact directly (bypassing the pipeline) or creating a replacement artifact (orphaning the original). Neither pattern is governed by a behavioral rule. |
| **Root Cause / Motivation** | No critical rule exists requiring the orchestrator to revise defective deliverables rather than replace or inline-fix them. The remediation protocol in approval-gate and implementation-pipeline does not route defective deliverables to the revision pipeline. |
| **Approach Chosen** | Add two Tier 2 critical rules to `000-critical-rules.md`: one requiring revision (not replacement) of defective sub-agent deliverables, one forbidding inline fixes (mandating dispatch to revision pipeline). Update remediation protocol in `approval-gate` or `implementation-pipeline` to include revision routing. Add behavioral enforcement tests. |
| **Alternatives Considered & Why Discarded** | Adding a Tier 1 rule was considered but rejected — the orchestrator may need to replace a deliverable when revision is structurally impossible (e.g., issue deleted). Tier 2 allows developer override for such edge cases. |
| **Key Design Decisions** | Rules are Tier 2 (not Tier 1) to allow developer override when revision is structurally impossible. Behavioral tests use stderr-based assertion helpers. |

## Objective

Add behavioral rules that govern orchestrator behavior when a sub-agent returns a defective deliverable. The rules enforce revision (not replacement) and forbid inline fixes (mandating dispatch to the appropriate revision pipeline).

## Problem

When a sub-agent produces a defective deliverable (spec, plan, or other artifact), the orchestrator has two defective response patterns:

**Pattern A — Inline fix:** The orchestrator attempts to fix the defective artifact directly via `github_issue_write` or file edit, bypassing the spec-creation pipeline entirely. This produces defective output because the orchestrator lacks the context and discipline of the spec-creation pipeline.

**Pattern B — Replacement:** The orchestrator dispatches creation of a new artifact (e.g., new issue #1678) instead of revising the existing defective artifact (issue #1677). This creates orphaned issues, breaks cross-references, and wastes the original issue number.

The root cause is that no behavioral rule exists requiring the orchestrator to revise defective deliverables rather than replace or inline-fix them.

## Scope

**In scope:**
- Add Tier 2 critical rule to `000-critical-rules.md`: defective sub-agent deliverables MUST be revised, not replaced
- Add Tier 2 critical rule: orchestrator MUST NOT attempt inline fixes of defective sub-agent output — MUST dispatch revision task
- Update remediation protocol in `approval-gate` or `implementation-pipeline` to include revision routing
- Behavioral enforcement tests in `.opencode/tests/behaviors/`

**Out of scope:**
- Changing how sub-agents produce deliverables
- Changing the spec-creation pipeline itself
- Migrating existing orphaned issues created via replacement pattern

## Affected Files

| File | Anchor | Purpose |
|------|--------|---------|
| `.opencode/guidelines/000-critical-rules.md` | Tier 2 prose section | Add two new critical rule entries |
| `.opencode/guidelines/000-critical-rules.md` | yaml+symbolic rules section | Add two new symbolic rule definitions |
| `.opencode/skills/approval-gate/SKILL.md` or `.opencode/skills/implementation-pipeline/SKILL.md` | Remediation protocol section | Update to route defective deliverables to revision pipeline |
| `.opencode/tests/behaviors/` | New file | Behavioral enforcement test for revision-not-replacement rule |
| `.opencode/tests/behaviors/` | New file | Behavioral enforcement test for no-inline-fix rule |

## Fix Approach

### Phase 1: Add Critical Rules

Add two new Tier 2 critical rules to `000-critical-rules.md`:

**Rule A — Revision-Not-Replacement (critical-rules-071):**
When a sub-agent returns a defective deliverable, the orchestrator MUST revise the existing deliverable via the appropriate pipeline (spec-creation for specs, writing-plans for plans). The orchestrator MUST NOT create a replacement artifact (new issue, new file) unless revision is structurally impossible (e.g., the original issue was deleted).

**Rule B — No-Inline-Fix (critical-rules-072):**
When a sub-agent returns a defective deliverable, the orchestrator MUST NOT attempt to fix the defective artifact directly via `github_issue_write`, file edit, or any other direct mutation. The orchestrator MUST dispatch a revision task to the appropriate pipeline (spec-creation --task revise for specs, writing-plans --task update for plans).

### Phase 2: Update Remediation Protocol

Update the remediation protocol in `approval-gate` or `implementation-pipeline` to include revision routing. When a sub-agent returns a defective deliverable, the protocol MUST:
1. Classify the defect type (spec defect, plan defect, code defect)
2. Route to the appropriate revision pipeline (spec-creation, writing-plans, implementation-pipeline)
3. NOT allow inline fixes or replacement creation

### Phase 3: Behavioral Enforcement Tests

Create behavioral enforcement tests in `.opencode/tests/behaviors/` that:
- Send a prompt where a sub-agent returns a defective spec
- Verify the orchestrator dispatches a revision task (not inline fix, not replacement)
- Use stderr-based assertion helpers (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`)

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `000-critical-rules.md` contains critical-rules-071 (revision-not-replacement) with Tier 2, HALT action, and triggers [implementation-pipeline, approval-gate] | `grep -q 'critical-rules-071' .opencode/guidelines/000-critical-rules.md` | Add missing rule entry | Phase 1 | `.opencode/guidelines/000-critical-rules.md` | DEC-1 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-2 | `000-critical-rules.md` contains critical-rules-072 (no-inline-fix) with Tier 2, HALT action, and triggers [implementation-pipeline, approval-gate] | `grep -q 'critical-rules-072' .opencode/guidelines/000-critical-rules.md` | Add missing rule entry | Phase 1 | `.opencode/guidelines/000-critical-rules.md` | DEC-1 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-3 | Both rules have yaml+symbolic definitions with correct conditions, actions, and source references | `grep -A 15 'critical-rules-071' .opencode/guidelines/000-critical-rules.md \| grep -q 'tier: 2'` | Fix yaml definition | Phase 1 | `.opencode/guidelines/000-critical-rules.md` | DEC-1 | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-4 | Remediation protocol in approval-gate or implementation-pipeline routes defective deliverables to revision pipeline | `grep -q 'revision.*routing\|route.*revision\|defective.*deliverable' .opencode/skills/approval-gate/SKILL.md .opencode/skills/implementation-pipeline/SKILL.md` | Update protocol | Phase 2 | `.opencode/skills/approval-gate/SKILL.md` or `.opencode/skills/implementation-pipeline/SKILL.md` | DEC-1 | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-5 | Behavioral enforcement test exists that verifies orchestrator revises (not replaces) defective sub-agent deliverable | `ls .opencode/tests/behaviors/defective-deliverable-revision.sh` | Create test file | Phase 3 | `.opencode/tests/behaviors/defective-deliverable-revision.sh` | DEC-1 | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-6 | Behavioral enforcement test exists that verifies orchestrator does NOT inline-fix defective sub-agent output | `ls .opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh` | Create test file | Phase 3 | `.opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh` | DEC-1 | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-7 | Behavioral tests use stderr-based assertion helpers (assert_stderr_pattern_present/assert_stderr_pattern_absent_all_models) | `grep -q 'assert_stderr_pattern' .opencode/tests/behaviors/defective-deliverable-revision.sh .opencode/tests/behaviors/defective-deliverable-no-inline-fix.sh` | Fix assertion type | Phase 3 | `.opencode/tests/behaviors/` | DEC-1 | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-8 | Behavioral tests pass RED phase (fail before rule change) and GREEN phase (pass after rule change) | Run test before change → FAIL; run test after change → PASS | Fix test or implementation | Phase 3 | `.opencode/tests/behaviors/` | DEC-1 | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Revision is structurally impossible (original issue deleted) | Replacement is permitted — document rationale in issue comment |
| Defective deliverable is a code file (not spec/plan) | Route to implementation-pipeline revision, not spec-creation |
| Multiple defects in same deliverable | Single revision task covers all defects — no per-defect dispatch |
| Developer explicitly requests replacement | Developer override per Tier 2 rules — document in issue comment |

## Dependencies

None. This spec is self-contained — it modifies only `.opencode/` files.

## Risk

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Over-correction prevents replacement when revision is impossible | Low | Medium | Tier 2 allows developer override; rule includes structural-impossibility exception | SC-1 |
| RISK-2 | Behavioral tests flake due to model non-determinism | Medium | Low | Use stderr-based assertions (deterministic tool dispatch strings) | SC-7 |
| RISK-3 | Existing orphaned issues from replacement pattern cause confusion | Medium | Low | Out of scope — no migration; future behavior only | — |

## Decision Rationale

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Tier 2 (not Tier 1) for both rules | Allows developer override when revision is structurally impossible | MUST | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 |
| DEC-2 | Stderr-based behavioral tests | Deterministic tool dispatch strings avoid model non-determinism flakiness | MUST | SC-7, SC-8 |
| DEC-3 | Remediation protocol in approval-gate or implementation-pipeline | Both are valid targets; the implementing agent chooses based on existing protocol structure | MAY | SC-4 |

## Phases

| Phase | Description | SCs |
|-------|-------------|-----|
| Phase 1 | Add critical rules to 000-critical-rules.md | SC-1, SC-2, SC-3 |
| Phase 2 | Update remediation protocol | SC-4 |
| Phase 3 | Behavioral enforcement tests | SC-5, SC-6, SC-7, SC-8 |

## Regression Invariants

1. Existing critical rules MUST retain their tier, conditions, and actions unchanged.
2. Existing remediation protocol MUST continue to handle non-defective sub-agent output identically.
3. All existing behavioral enforcement tests MUST continue to pass.

## Non-Goals

- **Migration of existing orphaned issues** — Out of scope; future behavior only.
- **Changing sub-agent deliverable production** — The spec governs orchestrator response, not sub-agent output quality.
- **Changing the spec-creation pipeline** — The spec governs routing to the pipeline, not the pipeline itself.

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| multi-phase | 3 | One sub-issue per phase | stacked PRs per phase |

After this spec is approved, invoke `writing-plans` to create `.issues/1679/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

**Documentation Sources:**

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "critical-rules-" .opencode/guidelines/000-critical-rules.md` | Identify existing rule numbering and structure |
| Direct source search | `grep -r "remediation" .opencode/skills/` | Identify existing remediation protocol locations |
| MCP search | `srclight_codebase_map()` | Understand project structure and file locations |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
