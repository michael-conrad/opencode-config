## Parent

https://github.com/michael-conrad/opencode-config/issues/212 — Audit: Skill Card "Use When" Description Compliance

## Problem

28 skills (excluding the 8 pipeline skills in Fix C1, `playwright-cli` in Fix A, and `approval-gate` in Fix B) have descriptions that lack mandatory language (D4) and/or contain narrative-only sentences (D5).

## Affected Skills

| Skill | D4 (Mandatory) | D5 (Narrative) | Narrative Sentence |
|-------|----------------|----------------|--------------------|
| `changelog-generator` | FAIL | FAIL | "Changelogs are the memory of the project — agents who skip them produce amnesiac workflows." |
| `completeness-gate` | FAIL | FAIL | "Completeness is the bridge between implementation and adversarial audit — skip this gate and defects leak through." |
| `completion-core` | FAIL | FAIL | "Clear completion signals are professional courtesy." |
| `conflict-resolution` | FAIL | FAIL | "Intent analysis before resolution separates correct merges from silent corruption." |
| `correspondence` | FAIL | FAIL | "Audience separation preserves professional credibility." |
| `engineering-approach` | FAIL | FAIL | "Agents who skip this produce fragile systems." |
| `git-workflow` | FAIL | FAIL | "Branch-and-PR discipline is not bureaucracy — it is what separates maintainable projects from chaos." |
| `issue-operations` | FAIL | FAIL | "Tracked work is the only work that matters." |
| `issue-review` | FAIL | FAIL | "Every unread comment is a defect risk." |
| `mcp-tool-usage` | FAIL | FAIL | "Tool-awareness is what separates reliable agents from guessers." |
| `multimodal-dispatch` | FAIL | FAIL | "Modality-aware dispatch is how professional systems use their tools." |
| `plan` | FAIL | FAIL | "Agents who skip planning produce unverified phase orderings — every unplanned phase is a risk." |
| `plan-creation-pipeline` | FAIL | FAIL | "Plan creation without a structured pipeline produces inconsistent plans." |
| `pr-creation-workflow` | FAIL | FAIL | "Every PR must be an authorized, intentional delivery." |
| `pre-analysis` | FAIL | FAIL | "Pre-analysis before dispatch is what reliable orchestrators do." |
| `programming-principles` | FAIL | FAIL | "Every violated principle is technical debt incurred, not saved." |
| `receiving-code-review` | FAIL | FAIL | "Every unresolved comment is a regression waiting to surface." |
| `requesting-code-review` | FAIL | FAIL | "Every review request is a quality gate, not a formality." |
| `research` | FAIL | FAIL | "Every unverified finding is a liability, not evidence." |
| `researcher` | FAIL | FAIL | "Every unverified finding is a liability, not evidence." |
| `skill-creator` | FAIL | FAIL | "Every unvalidated skill is a gap in your quality system." |
| `solve` | FAIL | FAIL | "Workflow constraints validated without Z3 are unchecked — every unverified constraint is a defect." |
| `spec-creation` | FAIL | FAIL | "Professional engineers spec first." |
| `sre-runbook` | FAIL | FAIL | "SRE discipline produces procedures that survive the next on-call." |
| `sync-guidelines` | FAIL | FAIL | "Sync is maintenance, not overhead." |
| `systematic-debugging` | FAIL | FAIL | "Systematic debugging finds root causes." |
| `test-driven-development` | FAIL | FAIL | "TDD produces testable, correct code." |
| `using-git-worktrees` | PASS ("Always invoke") | FAIL | "Worktrees are how professionals isolate work." |
| `verification` | FAIL | FAIL | "Verification turns guesses into facts." |
| `writing-plans` | FAIL | FAIL | "Plans are the map — agents who skip them get lost." |

## Requirements

For each of the 28 skills:

1. Add mandatory language to the description (MUST, REQUIRED, always, not optional, mandatory)
2. Remove or replace narrative-only sentences with dispatch-relevant content
3. Preserve consequence statements that reinforce mandatory behavior (e.g., "Every unread comment is a defect risk" — this is a consequence, not a slogan)
4. Ensure description still accurately reflects the Trigger Dispatch Table (D2)
5. Ensure description covers all dispatch conditions from the table (D3)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | All 28 descriptions contain mandatory language | `string` |
| SC-2 | All 28 descriptions have no narrative-only sentences | `semantic` |
| SC-3 | All 28 descriptions still pass D2 (correctness against dispatch table) | `semantic` |
| SC-4 | All 28 descriptions still pass D3 (completeness against dispatch table) | `semantic` |

## References

- Audit spec #212 §D4, §D5
- Individual SKILL.md files for each affected skill

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)