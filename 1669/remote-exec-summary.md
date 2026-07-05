> **Full spec and plan artifacts:** [`.issues/1669/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1669/) — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1669/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

Three skill cards in the opencode-config skill deck have defective or incomplete DISPATCH_GATE subsections, causing orchestrators to receive insufficient routing protocol guidance. This leads to incorrect context preloading, sub-agent re-dispatches, and broken work. Two canonical templates also lack DISPATCH_GATE documentation, propagating the defect to future skills. The validation script has no check for DISPATCH_GATE completeness.

## Scope

- Add complete DISPATCH_GATE subsections to `adversarial-audit/SKILL.md`, `playwright-cli/SKILL.md`, and `solve/SKILL.md`
- Add DISPATCH_GATE section to `routing-only-template.md` and `skill-card-spec.md`
- Add DISPATCH_GATE completeness check to `validate_skill_cards.py`
- Existing 33 working cards MUST remain unchanged

## Approach

Replace prose-only DISPATCH GATE blocks with the canonical structured subsections from `approval-gate/SKILL.md`. Add missing subsections to `solve/SKILL.md` while preserving existing content. Update both template files. Add a validation check that flags incomplete DISPATCH_GATE sections.

## Impact

- **Risk 1**: Template changes propagate to all future skills — mitigated by validation
- **Risk 2**: Validation false positives for skills with no sub-agent dispatch — mitigated by opt-out marker
- **Risk 3**: `adversarial-audit` has 15 tasks — DISPATCH_GATE MUST scale correctly
- **Risk 4**: `playwright-cli` is upstream-adapted (Apache-2.0) — only DISPATCH_GATE section modified

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/1669/`.
After creation, `local-issues sync 1669` MUST be run and the result committed to create the local `.issues/1669/` entry.
The implementation plan will be created in `.issues/1669/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 OpenCode (deepseek-v4-flash) created
