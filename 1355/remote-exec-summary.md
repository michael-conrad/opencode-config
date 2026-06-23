> **Full spec and artifacts: [`.issues/1355/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1355)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1355/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

`DONE_WITH_CONCERNS` is listed as a valid result contract status in multiple enforcement files but has no routing rule — orchestrators receiving it have no defined action. This creates a coercion gap where sub-agents can return a non-DONE status that the pipeline treats as valid completion, bypassing the hard-fail gate.

### Cards (dependency order)

1. **Coercion rule definition** — Add bright-line coercion rule to `pipeline-executor.md` Step 0: `status != DONE → FAIL; status == DONE with non-empty caveat_summary → FAIL`
2. **Symbolic rule update** — Add `DONE_WITH_CONCERNS` to `critical-rules-hard-fail` conditions in `000-critical-rules.md`
3. **Verification honesty wiring** — Add `DONE_WITH_CONCERNS` coercion trigger to `065-verification-honesty.md` §Hard Failure Discipline
4. **Status enum cleanup** — Remove `DONE_WITH_CONCERNS` from status enums in `020-go-prohibitions.md`, `implementation-pipeline/SKILL.md`, `approval-gate/SKILL.md`, `work-state-verification.md`, `screen-issue-gate2.md`
5. **Revisit preservation** — Verify `writing-plans/tasks/revisit.md` preserves `DONE_WITH_CONCERNS` (distinct semantic: partial resolution, not completion)
6. **Behavioral enforcement test** — Create test in `.opencode/tests/behaviors/` using `assert_semantic` (clean-room AI inspector) to verify coercion behavior

### Key Decisions

- **Bright-line coercion**: No gray zone between DONE and FAIL. `DONE_WITH_CONCERNS` is coerced to FAIL — caveats are defects, not completions.
- **Revisit preservation**: `DONE_WITH_CONCERNS` in `revisit.md` signals partial resolution (some claims resolved, some not) — a distinct semantic from completion that belongs to a different pipeline stage.
- **Behavioral enforcement**: Uses `assert_semantic` (clean-room AI inspector) because the coercion decision is an agent action, not a text pattern. grep on agent output prose is EVIDENCE_TYPE_MISMATCH for behavioral SCs.

### Risk Callouts

- **Revisit.md accidental removal**: Enum cleanup could accidentally remove `DONE_WITH_CONCERNS` from `revisit.md`. Mitigated by explicit preservation check (SC-8).
- **Behavioral test model unavailability**: If the semantic inspector model is unavailable, apply remediation-first protocol (alternative model, timeout increase, infrastructure check) before reporting FAIL.
- **Stale training data**: Sub-agents may continue to return `DONE_WITH_CONCERNS` after enum removal. Coercion rule in `pipeline-executor.md` catches it regardless of source.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/1355/`.
After creation, `local-issues sync 1355` MUST be run and the result committed to create the local `.issues/1355/` entry.
The implementation plan will be created in `.issues/1355/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)
