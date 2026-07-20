## Problem

The cross-validate sub-agent has exhibited a **soft-pass pattern**: accepting "revision already applied" as grounds to override a substantive FAIL verdict from an auditor. The current protocol already forbids this (cross-validate.md §Step 4: "DISAGREE Is Terminal"), but the sub-agent violated its own protocol because:

1. **No explicit prohibition on narrative-based FAIL override** — the protocol says "FAIL is never reclassifiable" but doesn't enumerate the specific rationalizations agents reach for (e.g., "revision already applied", "functionally equivalent", "already fixed in another change").

2. **Step 5.5 self-consistency gate is advisory, not enforced** — it exists in the task file but the cross-validate sub-agent can produce a result contract with PASS+critique language and nothing catches it before return.

3. **No output-integrity post-check** — the cross-validate sub-agent never self-scans its own result contract for contradictions (PASS with failing evidence, PASS with critique language, FAIL reclassified without verification).

### Root Cause

The cross-validate protocol has no gate that requires: "a FAIL from an auditor can only be overridden if the specific finding is independently verified as fixed." The sub-agent accepted process metadata ("revision was committed") as sufficient, when the revision only added text — the structural defect (Phase 4 branching from wrong fork) remained.

The protocol says: `Both auditors return PASS → consensus = PASS. Either auditor returns FAIL → consensus = FAIL.` This is correct. The enforcement is what's broken.

## Fix Approach

Two-layer change:

### Layer 1: Explicit Prohibition (cross-validate.md Step 4)

Add a dedicated subsection "FAIL Is Terminal — No Narrative Override" that enumerates the specific rationalization patterns that MUST result in automatic FAIL:

| Rationalization Pattern | Why Forbidden | Verdict |
|---|---|---|
| "Revision already applied" / "already fixed" | Process metadata, not evidence that the specific finding is resolved | Consensus = FAIL |
| "Functionally equivalent" / "close enough" | Soft-pass reclassification per critical-rules-020 | Consensus = FAIL |
| "Minor concern / edge case" | Agent judgment substituting for strict agreement | Consensus = FAIL |
| "Resolved in separate change" / "out of scope" | Shifting blame, not evaluating the criterion | Consensus = FAIL |
| "Partially addressed" / "mostly correct" | Not a clean PASS — hedging disqualifies | Consensus = FAIL |
| Auditor 1 = FAIL, auditor 2 = PASS and cross-validate "resolves" to PASS | Direct violation of DISAGREE Is Terminal | Consensus = FAIL |
| Any single-sentence dismissal of a FAIL finding | Insufficient analysis — must show tool-call evidence of fix | Consensus = FAIL |

Bright-line rule: **A FAIL verdict from either auditor can only be elevated when the specific finding is independently verified via tool-call evidence showing the defect is resolved.** Process metadata ("revision made", "commit pushed", "issue closed") is NEVER sufficient. Cross-validate does NOT perform this verification — it MUST report DISAGREE/FAIL and surface to the orchestrator.

### Layer 2: Mandatory Output-Integrity Self-Check (cross-validate.md New Step 5.7)

Before returning the result contract, the cross-validate sub-agent MUST scan its own output for contradictory patterns. If ANY of the following are detected, the sub-agent MUST self-correct the affected criterion(consus) to FAIL:

| Self-Check | Detection Signal | Action |
|---|---|---|
| PASS + critique language | `result: "PASS"` while `explanation` or `remediation` contains finding/fix language ("should be", "needs", "missing", "could improve", "minor", "some issues") | Downgrade to FAIL |
| FAIL reclassified | Consensus is PASS but one or both auditors returned FAIL | Downgrade to FAIL |
| Disagreement suppressed | Auditor 1 = FAIL, Auditor 2 = PASS, consensus declared as PASS | Downgrade to FAIL |
| Hedging qualifiers | Evidence field contains "mostly", "generally", "largely", "essentially" | Downgrade to FAIL |
| Narrative override | Explanation cites "revision applied", "already fixed", "out of scope" as justification for overriding a FAIL | Downgrade to FAIL |

### Layer 3: Result Contract Invalidation (cross-validate.md Step 7)

If the self-check finds violations in its own output, the sub-agent MUST:
1. Self-correct those criteria to FAIL
2. Add a `self_corrections` array to the result contract documenting what was changed
3. Recompute aggregate consensus — any self-corrected FAIL cascades to `overall_consensus = FAIL`
4. Set `next_step = "remediate then re-audit"`

## Success Criteria

| ID | Criterion | Evidence Type |
|---|---|---|
| SC-1 | cross-validate.md Step 4 adds "FAIL Is Terminal — No Narrative Override" subsection enumerating all rationalization patterns with hard FAIL verdict | `string` |
| SC-2 | cross-validate.md adds new Step 5.7 "Output-Integrity Self-Check" before Step 6 (dark patterns) that scans result contract for contradictory patterns and self-corrects to FAIL | `string` |
| SC-3 | cross-validate.md Step 7 includes `self_corrections` array in result contract template and mandates recomputing to FAIL on self-correction | `string` |
| SC-4 | DISAGREE Is Terminal subsection (current Step 4) is reinforced: explicit mention that "revision already applied", "out of scope", and "resolved elsewhere" are NEVER grounds to override a FAIL — only independent tool-call verification of the specific finding suffices, and cross-validate does NOT perform that verification (it surfaces to orchestrator) | `string` |
| SC-5 | Step 5.7 self-check scans `explanation`, `evidence`, and `remediation` fields for hedging qualifiers ("mostly", "largely", "generally", "essentially") — any match triggers FAIL downgrade | `string` |
| SC-6 | **BEHAVIORAL test**: dispatch cross-validate with auditor 1 = FAIL ("Phase 4 branches from incorrect parent"), auditor 2 = PASS (no finding). Cross-validate MUST report consensus = FAIL with "FAIL Is Terminal" reason — no narrative override | `behavioral` |
| SC-7 | **BEHAVIORAL test**: dispatch cross-validate with PASS + critique language ("should verify", "needs improvement"). Cross-validate self-check MUST downgrade to FAIL and add `self_corrections` entry | `behavioral` |
| SC-8 | **BEHAVIORAL test**: dispatch cross-validate with "revision already applied" override narrative in explanation. Self-check MUST catch it, flag as narrative override, downgrade to FAIL | `behavioral` |
| SC-9 | Existing DISAGREE Is Terminal (cross-validate-007a-disagree) and Evidence Type Gate (cross-validate-007b) rules are preserved — this is additive | `string` |
| SC-10 | Self-corrections cascade to overall consensus = FAIL. Any single self-correction produces overall FAIL | `structural` — verify text in Step 5.7 + Step 7 |

## Files Affected

| File | Change |
|---|---|
| `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Add "FAIL Is Terminal — No Narrative Override" subsection to Step 4. Add Step 5.7 "Output-Integrity Self-Check". Update Step 7 template to include `self_corrections` field. Reinforce DISAGREE Is Terminal with prohibition on "revision already applied" narrative |
| `.opencode/tests/behaviors/cross-validate-fail-is-terminal.sh` | NEW — behavioral test for SC-6 (FAIL from one auditor is never overridden) |
| `.opencode/tests/behaviors/cross-validate-pass-with-critique.sh` | NEW — behavioral test for SC-7 (PASS + critique → self-downgrade to FAIL) |
| `.opencode/tests/behaviors/cross-validate-narrative-override.sh` | NEW — behavioral test for SC-8 ("revision applied" narrative → caught and FAIL) |
| `.opencode/tests/test-enforcement.sh` | Add content-verification scenarios for SC-1, SC-2, SC-3, SC-4, SC-5, SC-9, SC-10 |

## Implementation Plan

1. RED: Write behavioral test `cross-validate-fail-is-terminal.sh` — confirms cross-validate does NOT currently enforce terminal FAIL (should fail)
2. RED: Write behavioral test `cross-validate-pass-with-critique.sh` — confirms cross-validate does NOT self-check for critique language (should fail)
3. RED: Write behavioral test `cross-validate-narrative-override.sh` — confirms cross-validate accepts narrative override (should fail)
4. GREEN: Update `cross-validate.md` — add FAIL Is Terminal subsection, Step 5.7 self-check, result contract `self_corrections` field
5. Re-run all behavioral tests — confirm GREEN
6. Run content-verification — confirm no regressions
7. Run existing behavioral test suite — confirm no regressions

## Risk Analysis

| Risk | Mitigation |
|---|---|
| Self-check introduces false positives (critique language in explanation that's actually appropriate) | The check targets hedging qualifiers ("mostly", "generally") and narrative overrides ("revision applied"), not legitimate analytical language. A PASS with a valid explanation containing "the function signature matches exactly" is not affected |
| Self-check increases cross-validate latency | Negligible — regex scan of 3 fields, sub-millisecond |
| Existing behavioral tests may fail due to stricter enforcement | Unlikely — current protocol already mandates these rules; they just weren't enforced. Tests that passed before should still pass (clean PASSes unaffected) |

## Changelog

- 2026-05-25: Initial draft

## Cross-References

- `000-critical-rules.md` §critical-rules-020 (Soft-passing verification mismatches)
- `065-verification-honesty.md` §Hard Failure Discipline (FAIL is never reclassifiable)
- `adversarial-audit/tasks/cross-validate.md` §Step 4 DISAGREE Is Terminal, §Step 5.5 Verdict Self-Consistency Gate
- `adversarial-audit/SKILL.md` §adversarial-audit-004 (Consensus requires dual PASS), §adversarial-audit-009 (PASS gate requires consensus)
- Discovered via live audit: Kimi auditor FAIL was overridden by cross-validate with "revision already applied" narrative — revision was text-only, structural graph defect remained

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
