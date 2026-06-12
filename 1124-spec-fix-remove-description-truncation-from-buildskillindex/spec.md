## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem | `buildSkillIndex()` in `plugins/session-enforcement.ts:568` truncates all skill descriptions to the first sentence via `s.description.split(".")[0]`, silently removing routing mandates (e.g., "Routes to GitHub MCP or GitBucket API based on github.platform") from agent-visible descriptions. This causes agents to bypass mandatory skill dispatch gates. |
| Approach | Remove the truncation, use full `s.description` instead of `shortDesc`. Search and eliminate similar truncation patterns in `plugins/` and `tools/`. |
| Key Decisions | No table format changes — just use full content. No behavior changes to `buildSkillIndex()` beyond removing truncation. |
| Alternatives | Keep truncation (rejected: causes agent bypass). Show full descriptions in a separate section (rejected: unnecessary complexity). |
| Scope | `plugins/session-enforcement.ts`, any `tools/` scripts with truncation patterns |

## Problem

The `buildSkillIndex()` function at `session-enforcement.ts:568` applies:
```typescript
const shortDesc = s.description.split(".")[0].trim() + ".";
```

This silently drops everything after the first period. Critical second-sentence routing mandates are lost:

| Skill | First sentence (what shows) | Second sentence (what's lost) |
|-------|---------------------------|------------------------------|
| issue-operations | "Use when creating, commenting on, or closing GitHub Issues." | "Routes to GitHub MCP or GitBucket API based on github.platform." |
| git-workflow | "Use when creating a branch, committing, pushing, or creating a PR." | "Also for rebase/merge conflicts (invoke conflict-resolution)..." |
| using-git-worktrees | "Use when creating a feature branch or worktree for implementation." | "Always invoke before git-workflow pre-work." |
| adversarial-audit | "Use when running adversarial audits of specs, plans, or code." | "Unaudited work carries undiscovered defects..." |

The agent sees a utility description ("Use when creating issues"), not a mandatory gateway ("ALL issue operations MUST route through this dispatcher"). This is a structural cause of skill bypass behavior.

Similar truncation patterns may exist in `tools/` scripts. All must be found and eliminated.

## Requirements

### R-1: Remove truncation in buildSkillIndex()

Replace `shortDesc` usage with full `s.description` at `session-enforcement.ts:570`.

### R-2: Audit tools/ for truncation patterns

Search all scripts in `tools/` for `.split(".")[0]` or equivalent first-sentence truncation patterns. Eliminate any found.

## Out of Scope

- Changes to the table format or structure
- Changes to `extractTriggerPatterns()`
- Behavioral tests for this change (content-verification sufficient for string SCs)
- Any other changes to `session-enforcement.ts`

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | No `split(".")[0]` or equivalent first-sentence truncation exists in any `.ts` plugin file | `string` |
| SC-2 | No first-sentence truncation exists in any `tools/` script output | `string` |
| SC-3 | `buildSkillIndex()` uses full `s.description` instead of `shortDesc` | `string` |

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan are at this local path. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)