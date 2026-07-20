## Problem

Auditor sub-agents return per-criterion verdicts with `result: "PASS"` while the `explanation`, `evidence`, or `remediation` field contains findings, caveats, concerns, or recommendations. This produces a contradictory "PASS with findings" pattern that invalidates the audit pipeline — a PASS that requires action is a FAIL.

The contradiction manifests in three locations:

1. **Per-criterion verdict format** (`.opencode/agents/auditor-*.md`, 7 files): The `result` field allows `"PASS"` independently of whether `explanation` contains concerns. There is no self-consistency constraint linking result to explanation content.

2. **Clean Room block** (same 7 auditor files): `clean_room.verified: true` is allowed even when `violations_detected` is non-empty. `verified: true` with violations is a contradiction.

3. **cross-validate.md** (`.opencode/skills/adversarial-audit/tasks/cross-validate.md`): The consensus engine only checks the `result` enum value — it never validates that a `PASS` result is actually clean (no findings in supporting fields). This lets contradictory verdicts propagate through the pipeline as PASS.

## Root Cause

The auditor verdict format defines `result` and `explanation` as independent fields with no cross-field constraint. The `clean_room` block has the same independence problem between `verified` and `violations_detected`. The cross-validate pipeline trusts the binary `result` field without semantic validation.

## Success Criteria

| ID | Criterion | Verification |
| -- | --------- | ------------ |
| SC-1 | Per-criterion `result: "PASS"` is FORBIDDEN when `explanation`, `evidence`, or `remediation` contains any finding, caveat, concern, suggestion, recommendation, or non-confirmatory language | Behavioral test: auditor returns PASS with finding language in explanation → cross-validate downgrades to FAIL |
| SC-2 | Per-criterion `result: "FAIL"` is REQUIRED when any finding, caveat, concern, suggestion, recommendation, or non-confirmatory language appears in `explanation`, `evidence`, or `remediation` | Behavioral test: auditor returns PASS with "could be improved" → cross-validate downgrades to FAIL |
| SC-3 | `clean_room.verified` must be `false` when `violations_detected` is non-empty. `verified: true` with non-empty `violations_detected` is an invalid verdict | Behavioral test: auditor returns clean_room with verified=true and violations_detected=["x"] → cross-validate flags as FAIL |
| SC-4 | `cross-validate.md` must validate per-criterion verdict self-consistency before computing consensus. Must scan `explanation`, `evidence`, and `remediation` for finding language when `result == "PASS"` | Behavioral test: any PASS with finding content → consensus FAIL for that criterion |
| SC-5 | PASS explanation must be strictly confirmatory — only describes what was verified and confirms correctness. Zero qualification, zero suggestions, zero "minor issues" | Content-verification test: auditor agent format explicitly states this constraint |
| SC-6 | Finding language detection must use the same signal set as the Dark Pattern Enforcement (Step 6 in cross-validate.md) — keyword/pathtern-based detection, not subjective | Audit test output lists the detection patterns |
| SC-7 | `next_step` enum in `cross-validate.md` is consistent — `proceed` vs `remediate then re-audit` match the enum at line 82 without orphan values | Content-verification test |

## Affected Files

| # | File | Change |
| -- | ---- | ------ |
| 1 | `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Add verdict self-consistency validation gate (Step between current Step 5 and Step 6); fix `next_step` enum inconsistency (line 82 values vs lines 134/169-170 values) |
| 2 | `.opencode/agents/auditor-deepseek-flash.md` | Add self-consistent verdict constraint to output format |
| 3 | `.opencode/agents/auditor-deepseek-v3.md` | Same |
| 4 | `.opencode/agents/auditor-glm-5.md` | Same (YAML format variant) |
| 5 | `.opencode/agents/auditor-glm-5.1.md` | Same |
| 6 | `.opencode/agents/auditor-kimi-k2.md` | Same |
| 7 | `.opencode/agents/auditor-mistral-large.md` | Same |
| 8 | `.opencode/agents/auditor-qwen3.5.md` | Same |
| 9 | `.opencode/.issues/...` | Behavioral enforcement test |

## Finding Language Detection Signals

For the self-consistency gate in cross-validate, the following signals indicate a finding when `result == "PASS"`:

| Signal Pattern | Example |
| -------------- | ------- |
| "could be" + qualifier | "could be improved", "could be clearer" |
| "minor" + issue/suggestion | "minor issue", "minor concern" |
| "consider" + suggestion | "consider adding", "consider documenting" |
| "might" / "may" + problem | "might be unclear", "may need attention" |
| "suggest" / "recommend" | "suggest documenting", "recommend adding" |
| "overall" + qualifier + PASS | "overall it passes but..." |
| "mostly" / "generally" + PASS | "mostly correct", "generally adequate" |
| "with the caveat that" | "PASS with the caveat that..." |
| "except for" / "aside from" | "PASS except for..." |
| "should" / "needs" / "requires" | "should be documented", "needs clarification" |

These match the Dark Pattern Enforcement approach (keyword-based detection in Step 6).

## Phases

**Phase 1 — cross-validate gate:** Add self-consistency validation to `cross-validate.md` (new Step 5.5 between current Step 5 and Step 6). Fix `next_step` enum inconsistency. This is the central enforcement point — if cross-validate catches contradictory verdicts, the pipeline is protected regardless of what auditors produce.

**Phase 2 — auditor agent definitions:** Update all 7 auditor `.md` files to document the self-consistent verdict constraint. PASS must mean clean PASS. FAIL when any finding exists. `verified: true` only when `violations_detected` is empty.

**Phase 3 — Behavioral enforcement test:** Add behavioral test that sends an auditor a scenario where the explanation has a finding but result is PASS, and verifies cross-validate downgrades to FAIL.

## Risk Analysis

| Risk | Mitigation |
| ---- | ---------- |
| False positives in finding language detection | Detection signals are keywords against `explanation` only — `evidence` field is structured URLs/file paths, not prose |
| Auditor can't express nuance | Nuance belongs in `evidence` (what was checked) and `failure_description` for FAIL results. PASS must be unequivocal |
| Existing auditors may produce PASS with findings after this change | Cross-validate catches it at the gate — the pipeline blocks it before reaching downstream tasks |

## Dependencies

- SC-4 (cross-validate gate) is prerequisite for all other SCs — without the gate, auditor changes are unenforceable
- SC-1 through SC-3 (auditor agent changes) depend on SC-4 gate being in place
- SC-6 (detection signals) must be consistent between SC-4 implementation and what auditors expect