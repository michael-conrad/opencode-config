## Parent

https://github.com/michael-conrad/opencode-config/issues/212 — Audit: Skill Card "Use When" Description Compliance

## Problem

8 pipeline/workflow skills have descriptions that lack mandatory language (D4) and/or contain narrative-only sentences (D5). These skills are invoked at critical pipeline gates where skipping steps produces downstream defects.

## Affected Skills

| Skill | Current Description | D4 (Mandatory) | D5 (Narrative) |
|-------|-------------------|----------------|----------------|
| `adversarial-audit` | Use when running adversarial audits of specs, plans, or code. Audits are not optional — they are how trustworthy work is verified. | PASS ("not optional") | FAIL — "they are how trustworthy work is verified" |
| `approval-gate` | Use when checking or enforcing authorization scope, approval cascade, and pipeline halt boundaries. Implementing without authorization produces unreviewed, unapproved code — the fastest path to rework. | FAIL | PASS (consequence supports dispatch) |
| `brainstorming` | Use when creating a spec, planning a feature, or exploring requirements before implementation. Agents who implement without brainstorming build solutions to problems they do not understand. | FAIL | FAIL — metaphor sentence |
| `implementation-pipeline` | Use when executing an approved plan through the implementation pipeline. MUST dispatch here after plan approval, before any file modification. Professional engineers route each step through clean-room sub-agents. | PASS ("MUST") | FAIL — "Professional engineers route each step" |
| `executing-plans` | Use when executing an approved plan step-by-step or moving through implementation gates sequentially. Every skipped step is a defect waiting for CI to find. | FAIL | PASS (consequence supports dispatch) |
| `finishing-a-development-branch` | Use when implementation is complete and branch needs final checks before PR. A finished branch is a clean branch. | FAIL | FAIL — slogan sentence |
| `verification-before-completion` | Use when claiming a task is complete, marking a step done, or closing an issue. A completion claim without verification is not a completion — it is a placeholder for undiscovered defects. | FAIL | PASS (consequence supports dispatch) |
| `verification-enforcement` | Use when generating content that makes factual claims — specs, plans, runbooks, docs, or correspondence — to enforce live-source verification before generation. Every unverified claim in generated content is a trust deficit. | FAIL | PASS (consequence supports dispatch) |

## Requirements

For each of the 8 skills:

1. Add mandatory language to the description (MUST, REQUIRED, always, not optional, mandatory)
2. Remove or replace narrative-only sentences with dispatch-relevant content
3. Preserve consequence statements that reinforce mandatory behavior
4. Ensure description still accurately reflects the Trigger Dispatch Table (D2)
5. Ensure description covers all dispatch conditions from the table (D3)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | All 8 descriptions contain mandatory language | `string` |
| SC-2 | All 8 descriptions have no narrative-only sentences | `semantic` |
| SC-3 | All 8 descriptions still pass D2 (correctness against dispatch table) | `semantic` |
| SC-4 | All 8 descriptions still pass D3 (completeness against dispatch table) | `semantic` |

## References

- Audit spec #212 §D4, §D5
- Individual SKILL.md files for each affected skill

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)