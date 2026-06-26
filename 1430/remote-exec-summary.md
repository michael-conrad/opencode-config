> **Full spec and artifacts: [`.issues/1430/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1430)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

## Exec Summary

Add a mandatory spec-provenance gate: when a spec enters the agent's working context, the agent checks whether it was written through the spec-creation pipeline. If not → 86'ed (rejected outright, no audit, no remediation, no exceptions). If yes → proceed normally.

### Cards (dependency order)
1. **Verdict path change** — Modify spec-audit task to write stable verdict to `.issues/{N}/spec-audit.yaml`
2. **Critical rule** — Add Tier 2 rule to `000-critical-rules.md` with three-condition model
3. **Trigger dispatch** — Add context-based row to `adversarial-audit/SKILL.md` trigger dispatch table
4. **Behavioral tests** — Write enforcement tests for SC-7 (reject), SC-8 (accept), SC-9 (cross-session)

### Key Decisions
- **Three-condition model**: `spec_in_working_context`, `spec_provenance != 'spec-creation-pipeline'`, `about_to_act_on_spec` — per-spec dedup prevents multi-spec collision
- **Context-based trigger**: Fires on spec encounter, not user keyword — consistent with existing `completion / workflow end` pattern
- **Verdict file at `.issues/{N}/spec-audit.yaml`**: Stable cross-session path; not ephemeral like `./tmp/`
- **Tier 2 (overridable)**: Allows developer override for legitimate edge cases (e.g., session boundary)

### Risk Callouts
- **R-4 (Session boundary)**: Previous-session specs 86'ed — mitigated by verdict file cross-session bridge
- **R-3 (Bypass)**: Agent suppresses the check — mitigated by behavioral enforcement tests (#1217 pattern)
- **R-7 (False positive)**: Non-spec content triggers gate — mitigated by [SPEC] label discriminator

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/1430/`.
After creation, `local-issues sync` MUST be run and the result committed to create the local `.issues/1430/` entry.
The implementation plan will be created in `.issues/1430/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
