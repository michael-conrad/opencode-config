---
number: 1
title: "Submodule-Aware Session Identity + Local Issue Tracking"
status: "closed"
labels: [SPEC, needs-approval]
created: "2026-04-25T00:00:00Z"
updated: "2026-04-25T17:15:42Z"
github_issue: 57
author: "michael-conrad"
---

## Objective

Enable the opencode-config agent system to function in two scenarios where it currently hard-fails:

1. **Submodule context**: When `.opencode` is a submodule inside a parent repo that has no git remote, `session-init`, `session_context_identity.py`, and `session_context_triggers.py` all `exit 1`, producing FATAL diagnostics that block all agent operations.

2. **No remote at all**: When a repo (parent or standalone) has no git remote, there is no way to create, track, or manage issues — the entire issue-operations pipeline requires GitHub or GitBucket API access.

The fix introduces degraded-mode session identity and a local `.issues/` system so that repos without remotes can still function as first-class agent workspaces.

## Problem

### Root Cause: Hard-Fail on Missing Remote

Three scripts unconditionally call `git remote get-url origin` and `exit 1` when it returns nothing:

- `session-init` line 651-654: `if not remote_url: return 1`
- `session_context_identity.py` line 255-258: same pattern
- `session_context_triggers.py` line 410-413: same pattern

The `session-enforcement.ts` plugin treats these exit codes as FATAL errors, injecting `<PLUGIN_DIAGNOSTICS>` blocks that halt all operations.

### Current Impact

- Parent repo `/home/muksihs/git/opencode-config` has no `origin` remote
- `.opencode` submodule has remote `git@github.com:michael-conrad/opencode-config.git`
- Every agent session starts with FATAL diagnostics — no identity, no triggers, no platform routing
- Issue operations are impossible without `github.owner` and `github.repo` from session init

## Constraints and Scope

**In Scope:**
- Submodule-aware remote detection with degraded mode in `session-init`, `session_context_identity.py`, `session_context_triggers.py`
- `session-enforcement.ts` handling of degraded identity (no FATAL on missing remote)
- Local `.issues/` directory structure, YAML frontmatter schema, and number-slug naming
- Python CRUD tool (`.opencode/tools/local-issues`) for local issue operations
- `local` platform route in `issue-operations` skill
- Automatic promotion from local `.issues/` to GitHub Issues on authorization events
- Two-way linking: local issues reference GitHub issue number; GitHub issue comments reference local path
- Worktree exemption for `.issues/` files (non-behavioral metadata, tracked in git)
- Branching requirement preserved (no direct commits to `dev`/`main`)

**Out of Scope:**
- Offline-first sync engine (promotion is one-way: local → GitHub)
- Conflict resolution for parallel edits to same local issue
- Web UI for local issues
- Migration of existing GitHub Issues to local format
- Authentication/authorization for local issues (filesystem permissions suffice)
- Node.js dependencies (Python-only implementation, stdlib only)

**Key Constraints:**
- `.issues/` MUST be tracked in git (devs resume work on other machines)
- `.issues/` at the repo root of the repo they belong to — submodule issues live inside the submodule (e.g., `.opencode/.issues/`), parent repo issues live at the parent root (e.g., `.issues/`). Per-repo routing: each repo gets its own `.issues/`
- No new Python dependencies beyond stdlib
- Must not break existing GitHub/GitBucket workflows for repos with remotes
- Primary identity comes from root repo remote only — no promotion from submodule remotes
- Degraded mode = reduced capability (no root-level GitHub ops), not fatal HALT

## Affected Files

| File | Change Type | Anchor |
|------|-------------|--------|
| `.opencode/tools/session-init` | Modify | `get_remote_url()`, `main()` |
| `.opencode/scripts/session_context_identity.py` | Modify | `get_remote_url()`, `main()` |
| `.opencode/scripts/session_context_triggers.py` | Modify | `get_remote_url()`, `main()` |
| `.opencode/plugins/session-enforcement.ts` | Modify | `runSessionInit()`, `runSessionContextIdentity()`, `runSessionContextTriggers()` |
| `.opencode/tools/local-issues` | New | CRUD tool for `.issues/` |
| `.opencode/skills/issue-operations/SKILL.md` | Modify | Platform routing table |
| `.opencode/skills/issue-operations/platforms/local/SKILL.md` | New | Local platform sub-skill |
| `.opencode/skills/issue-operations/platforms/local/tools/` | New | Thin wrappers around `local-issues` CLI |
| `.opencode/.issues/` | New | Directory structure tracked in submodule (per-repo location) |
| `.opencode/guidelines/060-tool-usage.md` | Modify | Worktree exemption for `.issues/` |
| `.opencode/guidelines/000-critical-rules.md` | Modify | Worktree exemption reference |

## Fix Approach

### Phase 1: Submodule-Aware Session Identity

The three scripts currently treat "no remote" as a fatal error. The fix adds a degraded mode where:

1. `session-init` detects if CWD is inside a git repo that has submodules. For each submodule, it checks if the submodule has a remote. If the root has no remote but a submodule does, it emits degraded-mode output: `github.owner`, `github.repo` from the submodule, plus a `github.identity_source: submodule` field. If NO remote exists anywhere, it emits `github.owner: (none)`, `github.repo: (none)`, `github.platform: local`, `github.identity_source: none` and exits 0.

2. `session_context_identity.py` follows the same degraded-mode logic. When no remote exists, it emits identity with `platform=local` and `credential_status=unavailable`.

3. `session_context_triggers.py` does NOT need identity to function — it only needs the current branch and working tree state. Remove the `get_remote_url()` guard from `main()`. Branch/stash/conflict checks work without a remote.

4. `session-enforcement.ts` handles `github.platform: local` gracefully — no FATAL diagnostic. When identity source is `none`, it emits a WARNING (not ERROR) indicating local-only mode.

**Key design decision**: Primary identity = root repo remote only. Submodule remote is used for degraded-mode capability (GitHub ops are possible but scoped to the submodule repo). When identity source is `none`, GitHub ops are impossible but all other agent functions (file editing, local issues, worktrees, triggers) work normally.

### Phase 2: Local Issue Infrastructure

Each repo (parent or submodule) gets its own `.issues/` at its repo root. The location depends on which repo the issue belongs to:

- **Parent repo issues** (no remote, local-only): `.issues/` at parent root
- **Submodule issues** (has remote, promotion to GitHub): `.issues/` inside the submodule (e.g., `.opencode/.issues/`)

```
.issues/                      # At the repo root of whichever repo owns the issue
  .counter                  # Next issue number (auto-incremented)
  open/
    001-fix-session-identity/
      spec.md               # Issue body (markdown + YAML frontmatter)
      comments.md           # Comments/updates (append-only)
    002-local-issue-tracking/
      spec.md
      comments.md
  closed/
    003-typos-in-changelog/
      spec.md
      comments.md
```

**YAML frontmatter schema** for `spec.md`:

```yaml
---
number: 1
title: "Fix session identity for submodule context"
status: open
labels: [SPEC, needs-approval]
created: "2026-04-25T12:00:00Z"
updated: "2026-04-25T12:00:00Z"
github_issue: null
author: dev.name
---
```

**Number-slug naming**: `{NNN}-{slug}/` where NNN is zero-padded from `.counter`, slug is 3-5 word kebab-case summary.

**Python CLI tool** (`.opencode/tools/local-issues`): Uses stdlib only. Commands:
- `create --title "TITLE" --labels LABEL1,LABEL2` — Create numbered issue directory + spec.md
- `read NNN` — Print spec.md to stdout
- `update NNN [--title TITLE] [--status STATUS] [--labels L1,L2] [FIELD=VALUE...]` — Update frontmatter
- `comment NNN --body "TEXT"` — Append to comments.md
- `close NNN` — Move from `open/` to `closed/`, update status
- `link NNN --github ISSUE_NUMBER` — Set `github_issue` frontmatter field
- `search [--status STATUS] [--labels L1,L2] [--query TEXT]` — Search issues
- `list [--status STATUS]` — List issues

### Phase 3: Issue-Operations Local Platform

Extend the `issue-operations` skill routing to include `local` as a third platform:

| `github.platform` | Platform Sub-Skill |
|---|---|
| `github` | `platforms/github-mcp/` |
| `gitbucket` | `platforms/gitbucket-api/` |
| `local` | `platforms/local/` |
| (unset) | `platforms/local/` (changed from github-mcp default) |

The local platform sub-skill provides capability manifests and thin wrappers around the `local-issues` CLI tool.

### Phase 4: Promotion and Two-Way Linking

When a local issue receives authorization:

1. If the repo has GitHub access, the agent promotes the local issue content to a GitHub Issue via the standard `issue-operations --task creation` workflow.
2. The local issue's `github_issue` frontmatter field is updated with the GitHub issue number.
3. A comment is added to the GitHub issue referencing the local issue path.
4. Subsequent operations sync to BOTH layers — local and GitHub.

Promotion is automatic on authorization events, not manual.

## Success Criteria

| ID | Criterion | Semantic Intent | Verification |
|----|-----------|-----------------|--------------|
| SC-1 | `session-init` exits 0 when root repo has no remote but a submodule has one | Degraded mode is functional, not fatal | `git -C /test/repo remote remove origin; ./.opencode/tools/session-init; echo $?` — must be 0, stdout contains `github.identity_source: submodule` |
| SC-2 | `session-init` exits 0 when no remote exists anywhere | Full degraded mode works | Same but with no remotes at all; exit 0, `github.platform: local`, `github.identity_source: none` |
| SC-3 | `session_context_identity.py` exits 0 in both degraded scenarios | Identity available in reduced form | Same test; output contains `github.platform=local` |
| SC-4 | `session_context_triggers.py` exits 0 regardless of remote | Triggers are independent of hosting identity | Run without remote; exit 0, trigger sections still emit |
| SC-5 | `session-enforcement.ts` does NOT inject FATAL when `github.platform: local` | Local mode is valid, not an error | No `[ERROR]` diagnostic in plugin-diagnostics.jsonl |
| SC-6 | `local-issues create --title "Test" --labels SPEC` creates `.issues/open/001-test/spec.md` with correct frontmatter | Local issue creation end-to-end | File exists, frontmatter has `number: 1`, `status: open`, `labels: [SPEC]`, `.counter` = 2 |
| SC-7 | `local-issues read 1` outputs spec.md to stdout | Read works | Create then read; stdout matches file content |
| SC-8 | `local-issues update 1 --status closed` moves `open/` to `closed/` and updates frontmatter | Close restructures directory tree | Verify move and frontmatter change |
| SC-9 | `local-issues comment 1 --body "Update"` appends to `comments.md` with timestamp | Comments are append-only with timestamps | Verify comments.md grows |
| SC-10 | `local-issues link 1 --github 42` sets `github_issue: 42` in frontmatter | Two-way linking from local side | Read frontmatter; `github_issue: 42` |
| SC-11 | `local-issues search --labels SPEC` returns matching issues | Label search works | Create SPEC issue; search returns it |
| SC-12 | `issue-operations` routes to `platforms/local/` when `github.platform` is `local` or unset | Platform routing includes local | Verify routing and dispatch behavior |
| SC-13 | `.issues/` is tracked in git (not in `.gitignore`) | Devs can clone and resume on another machine | `git check-ignore .issues/` returns non-zero |
| SC-14 | `.issues/` files are exempt from worktree requirement | Non-behavioral metadata does not need worktree isolation | Agent edits `.issues/` without worktree; 060 updated |
| SC-15 | Promotion on authorization: GitHub issue auto-created and two-way link established | Authorization triggers promotion | Approve local issue; GitHub issue exists, local frontmatter has `github_issue` |
| SC-16 | Before implementation, behavioral enforcement tests exist in `.opencode/tests/behaviors/` verifying degraded-mode identity rule; RED state confirmed | Behavioral tests before code changes | Test file exists and fails before change |

## Risk and Edge Cases

| Risk | Impact | Mitigation |
|------|--------|------------|
| Counter file race condition | Duplicate numbering | File locking via `fcntl.flock()` on `.counter` |
| Promotion fails (API down / no credentials) | Local-to-GitHub link missing | Non-fatal; local issue remains functional; retry on next auth event |
| `.issues/` inside submodule owned by parent | Confusion about which repo tracks the issue | `.issues/` ALWAYS at CWD repo root via `git rev-parse --show-toplevel` |
| Large number of closed issues | Directory bloat | Git-tracked; `git gc` handles; archive after threshold |
| Frontmatter schema evolution | Breaking existing issues | `schema_version` field; backward-compatible tooling |

## Dependencies

- Phase 1 MUST complete before Phase 3 (platform routing depends on `github.platform: local`)
- Phase 2 MUST complete before Phase 3 (local platform wraps `local-issues` tool)
- Phase 4 depends on Phase 1 and Phase 3
- Phases 1 and 2 are independent — MAY develop in parallel
