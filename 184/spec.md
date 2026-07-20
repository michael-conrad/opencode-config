## Executive Summary

Commit `ab2350fa` ("Context window pollution reduction") removed 9,179 lines across 84 files and introduced three regressions:

### Regression 1: Issue Comment Churn (PRIMARY)
The #608 channel-routing table (Action → Channel mapping: "Progress executive summaries go to chat ONLY") was deleted. The `github-comments` skill was also deleted. What remains is 16 affirmative "post to issue" instructions vs. 1 substantive gate (`issue-operations/tasks/comment.md` Step 1). The `completion-core/tasks/completion.md` Step 3 mandates "post a progress comment" with an explicit Phase/Implemented/Verified/Remaining template — exactly the kind of status noise that should go to chat only.

### Regression 2: Verification Enforcement Diluted
All structured `### 🚫 FORBIDDEN` / `### ✅ REQUIRED` sections and "Why This Matters" consequence tables were removed from `000-critical-rules.md` (66% reduction, 6,687 → 2,264 words). The "Manual Execution vs Formal Skill Invocation" comparison table was removed. This reduces the behavioral friction that prevents agents from skipping verification gates.

### Regression 3: Spec-Audit Findings Leak Risk
The explicit prohibition "Posting spec-audit findings as GitHub comments is FORBIDDEN" was deleted, along with the rule classifying audit findings as "internal agent guidance — equivalent to linter output."

## Root Cause

Commit `ab2350fa` (author: Michael Conrad, date: 2026-04-12). The "context window pollution reduction" was too aggressive — removing enforcement structure, consequence framing, and channel routing in pursuit of word count targets.

## Scope of Work

**Phase 1**: Restore channel-routing table (concise form) in `000-critical-rules.md` — add yaml+symbolic rule for machine enforcement
**Phase 2**: Fix `completion-core/tasks/completion.md` Step 3 — change "post a progress comment" to "route through issue-operations -> comment task (substantive gate)"
**Phase 3**: Audit all 9 mandatory "post to issue" instructions across skills to add substantive gate routing
**Phase 4**: Restore FORBIDDEN/REQUIRED structure and "Why This Matters" tables to `000-critical-rules.md`
**Phase 5**: Restore spec-audit findings leak prohibition
**Phase 6**: Add behavioral enforcement test verifying agent does NOT post non-substantive status updates to issues