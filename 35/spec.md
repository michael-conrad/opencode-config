# Spec-Fix: Frontmatter Validation Warnings Ignored by Agent

**STATUS: 1.0 (DRAFT — NEEDS APPROVAL)**

## Root Cause

The `session-enforcement.ts` plugin injects a `<FRONTMATTER_VALIDATION_WARNING>` block into the AI agent's system prompt at every session start. This block lists SKILL.md files with frontmatter issues (wrong `description` format, wrong `type`, missing fields). However:

1. **The warning is informational only** — it has no enforcement teeth. The agent sees it, acknowledges it in reasoning, but never halts or remediates.
2. **No mandatory halt gate** — the agent proceeds with normal operations despite a degraded skilldeck.
3. **The warning is often stale** — the audit found `pre-analysis` flagged as having a bad description, but `pre-analysis` actually passes all checks (the warning was from a prior version).
4. **Passive text is invisible in practice** — across multiple sessions, the agent never once warned the developer about these issues or attempted remediation. The warning is effectively wallpaper.

### Why This Matters

A skilldeck with frontmatter issues means skills may be invisible to the enforcement system. The agent operating with a degraded skilldeck is equivalent to operating with missing guideline enforcement — the agent may skip mandatory verification steps because the skill that enforces them was never loaded.

## Fix Approach

The frontmatter validation warning must be promoted from a passive informational block to a **fatal session-start gate**:

1. **Halt gate**: When `FRONTMATTER_VALIDATION_WARNING` is non-empty at session start, inject a **fatal halt directive** that forces the agent to stop and report the findings before any file operations or git operations are permitted.
2. **Auto-remediation offer**: The halt message should include a concrete remediation path — either auto-fix for mechanical issues (like `description` format) or spec creation for structural issues.
3. **Severity classification**: Distinguish between:
   - **FATAL-ALLOW-SIMPLE**: Mechanical issues (`type`, `license`, `description` format) — agent auto-fixes without spec, reports to chat
   - **FATAL-NEED-SPEC**: Structural issues (missing SKILL.md, task/skill confusion) — agent creates spec, halts for approval
4. **Freshness guarantee**: The validation scan must run at session start (not from cached data) to prevent stale warnings.

### Implementation Scope

- **`session-enforcement.ts`**: Modify the frontmatter validation injection to emit a fatal halt directive when issues exist, with severity classification
- **Guidelines**: Add a new critical violation: "Proceeding with a degraded skilldeck (frontmatter warnings present) without remediation"
- **Behavioral test**: Verify agent halts on frontmatter warnings

## Success Criteria

1. Agent halts at session start when `FRONTMATTER_VALIDATION_WARNING` is non-empty
2. Agent reports the specific skills and issues found
3. For mechanical-only issues: agent offers auto-fix, reports results
4. For structural issues: agent creates spec, halts for approval
5. No frontmatter warnings are silently ignored across sessions
6. Behavioral enforcement test confirms halt-on-warning behavior

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)