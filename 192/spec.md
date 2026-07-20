## Problem

The spec creation template in `.opencode/skills/spec-creation/tasks/write.md` (Step 6.8) generates this blockquote for embedding in issue bodies:

```
> **Full spec and artifacts: [`.issues/{N}/`](https://github.com/{owner}/{repo}/tree/issues-data/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
```

The phrase **"the authoritative spec lives in the `issues-data` branch"** confuses AI agents. When an agent reads that text, it interprets "lives in the `issues-data` branch" as an instruction to perform git operations (checkout, sync, push) on the issues-data branch — instead of simply using the `issue-operations` skill for issue management.

Additionally, the `.issues/{N}/` path prefix doesn't resolve for submodule-context issues (where spec content lives under `.opencode/.issues/{N}/`). The blockquote shouldn't try to specify a filesystem path — the `issue-operations` skill handles path resolution.

## Fix

Replace the problematic text with guidance directing agents to use the correct skill. The URL is kept for human readers browsing the web:

```
> **Full spec and artifacts: [`.issues/{N}/`](https://github.com/{owner}/{repo}/tree/issues-data/{N})** — use `issue-operations` skill to access spec content; no direct git operations on the spec branch are needed.
```

The `.issues/{N}/` path in the link label is a display name for the URL, not a filesystem instruction for the agent.

## Affected File

- `.opencode/skills/spec-creation/tasks/write.md` — line 274, the blockquote template in Step 6.8

## Scope

Single-file, single-line text change. No behavioral or structural impact on enforcement gates.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)