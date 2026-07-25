---
question: "Do public agent configuration decks (Cursor, Claude Code, OpenCode) include path resolution rules like 'no absolute paths', 'no cd', worktree path tables?"
confidence: 0.9
sources:
  - url: "https://github.com/karma-works/everything-opencode"
  - url: "https://github.com/eddiemessiah/config-claude-code"
  - url: "https://github.com/survivorforge/cursor-rules"
tags: [path-rules, guidelines, junie, tool-usage, compaction]
created: 2026-07-24
---

## Finding

No. The two largest public OpenCode/Claude Code config collections (karma-works/everything-opencode, eddiemessiah/config-claude-code, both from an Anthropic hackathon winner, 10+ months production use) do NOT include path resolution rules. Their rules cover: security, coding style, testing, git workflow, agent delegation, performance — not "no absolute paths", "no cd", or worktree path tables.

The cursor-rules collection (survivorforge/cursor-rules) similarly has no path rules.

## Implication

The path rules in 060-tool-usage.md (§2 Path Rules, §3 Temp Files, §4 Command Restrictions) are Junie-specific training wheels for a tool that had path resolution bugs. This agent's tools (read/write/edit with built-in path handling, bash with workdir parameter) handle paths correctly. These rules are dead remediation for a dead tool and should be removed from preloaded context.

## Cross-References

- 060-tool-usage.md §2 Path Rules
- 060-tool-usage.md §3 Temp Files & Cleanliness
- 060-tool-usage.md §4 Command Restrictions
