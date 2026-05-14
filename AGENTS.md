# AGENTS.md — opencode-config Repository

## Repository Purpose

This repository exists so that `.opencode` can be pulled in as a **proper git submodule** and developed + tested with a realistic folder structure. It is NOT the source of truth for `.opencode` content — the submodule IS.

**What this repo provides:**

- A parent repo that holds `.opencode/` as a git submodule (tracking `michael-conrad/.opencode`)
- The realistic directory layout that `opencode` CLI expects at runtime
- The `opencode.jsonc` configuration that instructs the CLI to load instructions from `.opencode/` paths
- A place to run behavioral and enforcement tests against a properly-structured project

**What this repo does NOT contain:**

- No application source code (`src/`)
- No guideline, skill, tool, plugin, or hook files at the top level — all of these live inside `.opencode/`
- No duplicate copies of submodule content (top-level copies of `.opencode/` directories were removed — do not re-create them)

## Authority Hierarchy

```
.opencode/ ← ALL agent configuration lives here (submodule)
  ├── guidelines/, skills/, tools/, plugins/, hooks/, scripts/, tests/, docs/
  └── commands/

opencode-config/ ← Parent repo (this file)
  ├── .opencode/       ← git submodule (tracks michael-conrad/.opencode dev branch)
  ├── .gitignore
  ├── README.md
  └── AGENTS.md        ← THIS FILE (repo purpose only — all agent rules are in .opencode/AGENTS.md)
```

**If you need to edit guidelines, skills, tools, plugins, tests, or hooks — edit files inside `.opencode/`, NOT at the top level.** The top level does not and should not contain copies of `.opencode/` directories.

## Submodule Discipline

### Git Operations Inside `.opencode/`

All git operations on `.opencode/` content must be performed from **inside** the submodule directory:

```bash
cd .opencode
git checkout -b feature/my-branch
git add ...
git commit -m "..."
git push origin feature/my-branch
```

The parent repo does NOT push `.opencode/` content — it only records the submodule SHA:

```bash
# From opencode-config root
git add .opencode
git commit -m "chore: update .opencode submodule pointer"
```

- **Remote**: `git@github.com:michael-conrad/.opencode.git`
- **tracked branch**: `dev` (never detached HEAD, never `main`)
- **API routing**: Files inside `.opencode/` belong to `michael-conrad/.opencode`, NOT `michael-conrad/opencode-config`

**Tag-Based Hash Permanence:** Submodule SHAs are preserved via parent-repo-prefixed tags — no separate submodule dev → main PRs are needed. At every transition point, submodule SHAs are verified reachable via tags. If unreachable, they are tagged idempotently (tag-if-untagged) before proceeding.

**Tag Layers:**

| Tag | When Created | Example |
|-----|-------------|---------|
| `<parent-repo>/<issue-number>` | Pre-work (feature dev start) | `opencode-config/221` |
| `<parent-repo>/<issue-number>-<sub>` | Feature-branch push | `opencode-config/221-opencode` |
| `<parent-repo>/v<N.N.N>` | Release promotion | `opencode-config/v0.1.1` |

**Idempotent tag-if-untagged rule:** At any transition point, for each submodule SHA, check if it is reachable via a tag. If not, tag it with the appropriate context tag and push. Skip if already tagged.

**Release promotion:** Tag submodule SHAs with release tags, NOT separate dev → main PRs. The parent release PR can be created and merged independently once submodule SHAs are verified reachable.

**Sub-agent dispatch requirement:** All submodule git operations (checkout, add, commit, push, tag, status checks) MUST be dispatched to clean-room sub-agents — never performed inline by the orchestrator.

**Dev parking:** `git checkout dev && git pull && git submodule init && git submodule update`

**Release:** Lock submodule SHAs to current checkout state (NOT a fresh pull). Tag with release tags. No submodule PRs needed.

### Worktree Considerations

When creating a worktree of the parent repo, `.opencode/` will be absent or empty until initialized:

```bash
git worktree add ../my-worktree feature/my-branch
cd ../my-worktree
git submodule init
git submodule update
```

## API Routing

| Target Files | Route API Calls To |
|---|---|
| `.opencode/guidelines/*`, `.opencode/skills/*`, `.opencode/plugins/*`, `.opencode/tools/*`, `.opencode/hooks/*`, `.opencode/tests/*`, `.opencode/scripts/*` | `michael-conrad/.opencode` |
| `.gitignore`, this AGENTS.md | `michael-conrad/opencode-config` |

When `github.identity_source` is `root`, the agent routes to `michael-conrad/opencode-config` by default. When operating on files inside `.opencode/`, switch the API target to `michael-conrad/.opencode`.