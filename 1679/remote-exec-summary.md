> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/1679/

## Exec Summary

When a sub-agent produces a defective deliverable, the orchestrator currently has two defective response patterns: inline-fixing the artifact directly (bypassing the pipeline) or creating a replacement artifact (orphaning the original). Neither pattern is governed by a behavioral rule. This spec adds two Tier 2 critical rules requiring revision (not replacement) and forbidding inline fixes, plus behavioral enforcement tests.

### Cards (dependency order)
1. **Add critical rules** — Add critical-rules-071 (revision-not-replacement) and critical-rules-072 (no-inline-fix) to `000-critical-rules.md`
2. **Update remediation protocol** — Route defective deliverables to revision pipeline in approval-gate or implementation-pipeline
3. **Behavioral tests** — Create stderr-based behavioral enforcement tests

### Key Decisions
- **Tier 2 (not Tier 1)**: Allows developer override when revision is structurally impossible (e.g., original issue deleted)
- **Stderr-based assertions**: Deterministic tool dispatch strings avoid model non-determinism flakiness

### Risk Callouts
- **Over-correction risk**: Rule includes structural-impossibility exception to prevent blocking legitimate replacements
- **Test flakiness**: Mitigated by stderr-based assertions on deterministic tool dispatch strings

## Scope

**In scope:**
- Add Tier 2 critical rule to `000-critical-rules.md`: defective sub-agent deliverables MUST be revised, not replaced
- Add Tier 2 critical rule: orchestrator MUST NOT attempt inline fixes of defective sub-agent output — MUST dispatch revision task
- Update remediation protocol in approval-gate or implementation-pipeline to include revision routing
- Behavioral enforcement tests

**Out of scope:**
- Changing how sub-agents produce deliverables
- Changing the spec-creation pipeline itself

## Approach

Add two new Tier 2 critical rules to `000-critical-rules.md` that govern orchestrator behavior when a sub-agent returns a defective deliverable. The rules enforce revision (not replacement) and forbid inline fixes (mandating dispatch to the appropriate revision pipeline). Update the remediation protocol to route defective deliverables to the revision pipeline. Add behavioral enforcement tests using stderr-based assertion helpers.

## Impact

- **Risk 1:** Over-correction prevents replacement when revision is impossible — mitigated by Tier 2 developer override and structural-impossibility exception
- **Risk 2:** Behavioral tests flake due to model non-determinism — mitigated by stderr-based assertions on deterministic tool dispatch strings
- **Risk 3:** Existing orphaned issues cause confusion — mitigated by scoping to future behavior only

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/1679/`.
After creation, `local-issues sync` MUST be run and the result committed to create the local `.issues/1679/` entry.
The implementation plan will be created in `.issues/1679/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
