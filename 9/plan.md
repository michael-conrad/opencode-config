# Plan — [SPEC-FIX] Infrastructure Failure Claim Proof Mandate

**Spec:** `.issues/9/spec.md`
**Issue:** opencode-config#9

## Phase 1: Core Rule Addition

| Step | Action | Files | Verification |
|------|--------|-------|-------------|
| 1.1 | Add "Infrastructure Failure Claim Proof Mandate" section to `000-critical-rules.md` with three obligations: evidence, user report, hard halt | `.opencode/guidelines/000-critical-rules.md` | `grep -c "Infrastructure Failure Claim Proof Mandate" .opencode/guidelines/000-critical-rules.md` returns ≥1 |
| 1.2 | Add yaml+symbolic rule to the rules block in `000-critical-rules.md` | `.opencode/guidelines/000-critical-rules.md` | `grep -c "infrastructure-failure-proof" .opencode/guidelines/000-critical-rules.md` returns ≥1 |
| 1.3 | Add Pattern (d) to §Anti-Evasion Rules in `065-verification-honesty.md` | `.opencode/guidelines/065-verification-honesty.md` | `grep -c "Pattern (d)" .opencode/guidelines/065-verification-honesty.md` returns ≥1 |
| 1.4 | Add cross-reference in §1 ALWAYS DO in `020-go-prohibitions.md` | `.opencode/guidelines/020-go-prohibitions.md` | `grep -c "infrastructure-failure-proof\|Infrastructure Failure Claim" .opencode/guidelines/020-go-prohibitions.md` returns ≥1 |

## Verification

All SCs are `string` evidence type — content-verification via grep is sufficient.
