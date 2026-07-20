## Problem Statement

`Read [§1](guidelines/020-go-prohibitions.md)` — bare section numbers as link text provide zero semantic signal to an AI agent about what the link points to. The agent sees "§1" and must follow the link to discover the content, wasting context and routing bandwidth.

The `Read-Link Cross-Reference Rule` in `AGENTS.md` mandates that cross-references use descriptive text so the agent knows what it's linking to. 22 instances across 13 files violate this by using bare `§N` as link text.

## Scope

All files under `.opencode/` and `AGENTS.md` in the root.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Every `Read [§N](...)` link is replaced with `Read [<descriptive text>](...)` where descriptive text names the target section | `string` | `grep` for `Read \[§` — zero matches |
| SC-2 | Links that already use descriptive text (e.g., `Read [§Cost Model](...)`, `Read [§Monolithic Implementation](...)`) are left unchanged | `string` | `grep` for `Read \[§[A-Z]` — existing matches preserved |
| SC-3 | Link text accurately describes the target section's content | `semantic` | Sub-agent spot-check of 5 random replacements |
| SC-4 | No functional changes to any file — only link text modified | `structural` | `git diff --stat` shows only link text changes |

## Affected Files

### Bare `§N` (no description) — 13 instances

| File | Current Link | Replace With |
|------|-------------|--------------|
| `guidelines/000-critical-rules.md:38` | `Read [§1](guidelines/020-go-prohibitions.md)` | `Read [the GO Prohibitions section](guidelines/020-go-prohibitions.md)` |
| `guidelines/000-critical-rules.md:42` | `Read [§1](guidelines/020-go-prohibitions.md)` | `Read [the GO Prohibitions section](guidelines/020-go-prohibitions.md)` |
| `guidelines/000-critical-rules.md:155` | `Read [§2](guidelines/060-tool-usage.md)` | `Read [the Path Rules section](guidelines/060-tool-usage.md)` |
| `guidelines/000-critical-rules.md:504` | `Read [§1](guidelines/020-go-prohibitions.md)` | `Read [the GO Prohibitions section](guidelines/020-go-prohibitions.md)` |
| `guidelines/000-critical-rules.md:813` | `Read [§1.1](guidelines/020-go-prohibitions.md)` | `Read [the Orchestrator Context Discipline section](guidelines/020-go-prohibitions.md)` |
| `guidelines/000-critical-rules.md:818` | `Read [§1.1](guidelines/020-go-prohibitions.md)` | `Read [the Orchestrator Context Discipline section](guidelines/020-go-prohibitions.md)` |
| `guidelines/210-scripting.md:119` | `Read [§1](060-tool-usage.md)` | `Read [the Tool Usage section](060-tool-usage.md)` |
| `guidelines/INDEX.md:15` | `Read [§1.6](020-go-prohibitions.md)` | `Read [the Discussion Mode Mandates section](020-go-prohibitions.md)` |
| `guidelines/250-dark-prose-reference.md:114` | `(Read [§1.1](020-go-prohibitions.md))` | `(Read [the Orchestrator Context Discipline section](020-go-prohibitions.md))` |
| `guidelines/257-procedural-discipline-reference.md:88` | `(Read [§1.1](020-go-prohibitions.md))` | `(Read [the Orchestrator Context Discipline section](020-go-prohibitions.md))` |
| `skills/approval-gate-scope/tasks/reconcile-issue-graph.md:3` | `Read [§5.5](skills/approval-gate-scope/tasks/verify-authorization.md)` | `Read [the Issue Graph Traversal section](skills/approval-gate-scope/tasks/verify-authorization.md)` |
| `skills/approval-gate-scope/tasks/reconcile-issue-graph.md:7` | `Read [§5.5](skills/approval-gate-scope/tasks/verify-authorization.md)` | `Read [the Issue Graph Traversal section](skills/approval-gate-scope/tasks/verify-authorization.md)` |
| `skills/approval-gate-scope/tasks/verify-qa-mode.md:429` | `Read [§10](guidelines/141-planning-status-tracking.md)` | `Read [the Label State Transitions section](guidelines/141-planning-status-tracking.md)` |
| `skills/approval-gate-scope/tasks/completion.md:28` | `Read [§10](guidelines/141-planning-status-tracking.md)` | `Read [the Label State Transitions section](guidelines/141-planning-status-tracking.md)` |

### `§N` with trailing description — 9 instances

| File | Current Link | Replace With |
|------|-------------|--------------|
| `guidelines/085-project-local-tools.md:50` | `Read [§4](020-go-prohibitions.md) — Node.js Prohibition` | `Read [the Node.js Prohibition section](020-go-prohibitions.md)` |
| `guidelines/085-project-local-tools.md:51` | `Read [§2](060-tool-usage.md) — Path Rules` | `Read [the Path Rules section](060-tool-usage.md)` |
| `guidelines/085-project-local-tools.md:52` | `Read [§4](060-tool-usage.md) — Command Restrictions` | `Read [the Command Restrictions section](060-tool-usage.md)` |
| `skills/git-workflow-commit/SKILL.md:56` | `Read [§1](guidelines/020-go-prohibitions.md) for --no-verify restrictions` | `Read [the GO Prohibitions section](guidelines/020-go-prohibitions.md) for --no-verify restrictions` |
| `skills/git-workflow-cleanup/SKILL.md:59` | `Read [§3](guidelines/060-tool-usage.md) for behavioral evidence artifact preservation rules` | `Read [the Temp Files & Cleanliness section](guidelines/060-tool-usage.md) for behavioral evidence artifact preservation rules` |
| `skills/git-workflow-branch/SKILL.md:64` | `Read [§1](guidelines/020-go-prohibitions.md) for for_analysis branch restrictions` | `Read [the GO Prohibitions section](guidelines/020-go-prohibitions.md) for for_analysis branch restrictions` |
| `skills/mcp-tool-usage/SKILL.md:166` | `Read [§2 for worktree path resolution rules](guidelines/060-tool-usage.md)` | `Read [the Path Rules section for worktree path resolution rules](guidelines/060-tool-usage.md)` |
| `skills/mcp-tool-usage/SKILL.md:166` | `Read [§1 for notebook MCP mandate](guidelines/060-tool-usage.md)` | `Read [the Tool Usage section for notebook MCP mandate](guidelines/060-tool-usage.md)` |
| `guidelines/065-verification-honesty.md:340` | `Read [§1 ALWAYS DO](020-go-prohibitions.md)` | `Read [the GO Prohibitions section](020-go-prohibitions.md)` |
| `guidelines/091-incremental-build.md:35` | `Read [§9 Prompt Construction Mandate](.opencode/tests-v2/AGENTS.md)` | Already descriptive — no change needed |

## Implementation

One-shot find-and-replace across 13 files. Each replacement is a simple link text change — no structural or semantic changes to content.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)