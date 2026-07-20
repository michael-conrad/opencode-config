## Problem

PR #1855 rewrote all 43 SKILL.md descriptions from the old "Use when... Trigger phrases:" pattern to the new "Dispatch when... User phrases:" pattern. This changed the LLM's trigger-response behavior: "Dispatch when" reads as an imperative/action-oriented command, making the agent more likely to dispatch `issue-operations` for comment posting without properly evaluating the substantiveness gate in `comment.md` Step 0-1.

The result: the agent started posting non-substantive "trash comments" (status updates, "phase complete", "implemented X") to GitHub Issues again — the exact pattern that issue #1106 was filed to fix.

## Affected Skills

| Skill | Old Description (conditional) | New Description (imperative) |
|-------|------------------------------|------------------------------|
| `issue-operations` | `"Use when creating, commenting on, or closing GitHub Issues..."` | `"Issue operations dispatcher... Dispatch when creating, commenting on, or closing GitHub Issues..."` |
| `correspondence` | `"Use when drafting stakeholder emails, status updates, or external communications..."` | `"Stakeholder communication drafter... Dispatch when drafting stakeholder emails, status updates, or external communications..."` |

## Root Cause

The `comment.md` task file still has the substantiveness gate (Step 0-1), but the LLM is now more likely to skip evaluating it because the skill description reads as an imperative rather than a conditional. The "Dispatch when" framing triggers action before the gate evaluation.

## Fix

Add substantiveness gate reinforcement directly into the `issue-operations` and `correspondence` SKILL.md descriptions. The fix must:

1. **`issue-operations/SKILL.md`**: Add a clause that explicitly gates comment posting behind the substantiveness check
2. **`correspondence/SKILL.md`**: Add a clause that reinforces audience separation (internal vs stakeholder)
3. **Behavioral test**: Add a test that verifies the agent does NOT post non-substantive comments to GitHub Issues

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `issue-operations` description includes a substantiveness gate clause for comment posting | `string` |
| SC-2 | `correspondence` description reinforces audience separation (internal vs stakeholder) | `string` |
| SC-3 | Agent does NOT post non-substantive progress updates to GitHub Issues (behavioral test) | `behavioral` |
| SC-4 | Agent still posts substantive comments (spec revisions, blockers, completions) to GitHub Issues | `behavioral` |

## Files to Modify

- `.opencode/skills/issue-operations/SKILL.md` — add substantiveness gate clause to description
- `.opencode/skills/correspondence/SKILL.md` — add audience separation reinforcement to description
- `.opencode/tests/behaviors/` — new behavioral test for comment-churn regression

## Related

- #1106 — Original issue: comment-churn regression (restored substantiveness gate)
- #1855 — SKILL.md description rewrite (introduced this regression)
- PR #1855 — The commit that changed all descriptions

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)