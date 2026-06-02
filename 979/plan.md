# Implementation Plan — Issue #979

## Overview

Full rewrite of `local-issues` tool and associated skill cards. 21 design cards decomposed into 4 phases, 28 implementation items. Dependency chain: tool → sub-skill cards → dispatcher + integration → behavioral tests.

---

## Phase 1: Tool Rewrite (.opencode/tools/local-issues)

Rewrite the CLI tool from scratch. 14 implementation items covering the new command surface, internal worktree management, auto-commit, push-at-gates, graceful fallback, tag creation, and YAML output.

### Item 1.1: Scaffold
- Create new `local-issues` (PEP 723 script)
- Define ISSUES_DIR, ISSUES_DATA_BRANCH, ISSUES_DIR constants
- `_git()`, `_now_iso()`, `_get_author()` helpers
- `_ensure_issues_root()` — walk up from CWD to find `.issues/`
- Main dispatcher with argparse for all commands

### Item 1.2: `_ensure_worktree()` — transparent worktree management
- Detection: `.issues/.git` exists and points to valid worktree → active
- Detection: `.issues/` is regular directory → attempt upgrade to worktree
- Detection: stale worktree (`.git/worktrees/-issues/` registered but link dead) → `git worktree prune`, re-setup
- Detection: `.issues/` absent → create as regular dir, then attempt worktree
- Worktree creation: orphan branch, `.gitignore` update, directory structure
- Migration: `.issues/` → `.issues.bak` → create worktree → copy from `.bak` → commit on issues-data
- Rollback: if worktree creation fails, `.issues.bak` → `.issues`
- Returns: `{ worktree_active: bool, path: string }`

### Item 1.3: Auto-commit mechanism
- `_auto_commit(issue_number, message)` — `git add -f .issues/N/`, `git commit` inside worktree
- Skip if worktree is not active (no worktree to commit to)
- Called at end of every mutation command

### Item 1.4: `local-issues create`
- `--number NUM` (optional, for remote-first creation)
- `--title TITLE --labels L1,L2`
- Calls `_ensure_worktree()` first if not already active
- Creates `.issues/N/` with spec.md, comments.md (empty), remote.md (empty), links.yaml, state.md, cards/
- Writes initial frontmatter with YAML
- Auto-commit on issues-data (if worktree active)
- Returns: YAML with number, path

### Item 1.5: `local-issues read` (YAML output)
- Types: `full`, `comments`, `labels`, `links`, `all` (via `--type` or `--all`)
- `read --type full` (default) → number, title, status, labels, phase, body
- `read --type comments` → YAML list of comments
- `read --type labels` → YAML single-key `labels`
- `read --type links` → YAML of links.yaml content
- `read --all` → bundle everything
- All output as YAML for LLM consumption

### Item 1.6: `local-issues read-comments`
- Reads `.issues/N/comments.md`
- Outputs YAML array of `{ author, timestamp, body }`
- Pure pass-through, no transformation

### Item 1.7: `local-issues read-labels`
- Reads `spec.md` frontmatter, extracts `labels` array
- Outputs YAML: `labels: [SPEC, needs-approval]`

### Item 1.8: `local-issues read-sub-issues`
- Reads `.issues/N/links.yaml`
- Outputs as-is in YAML

### Item 1.9: `local-issues update`
- Flags: `--title`, `--status`, `--phase`, `--labels`, `--body`, `--github`, `--remote-url`
- Updates `spec.md` frontmatter for metadata changes
- Updates `spec.md` body content for `--body`
- Auto-commit on issues-data
- Returns YAML with updated fields

### Item 1.10: `local-issues comment`
- `--body TEXT --type internal|stakeholder`
- Appends to `comments.md` with timestamp + author
- If `--type stakeholder`: also appends to `remote.md`, then calls `push-body`
- Auto-commit on issues-data
- Returns YAML with entry count

### Item 1.11: `local-issues close`
- `--reason completed|not_planned|duplicate`
- Updates frontmatter: status → closed, closed_at, state_reason
- Moves `.issues/open/N/` → `.issues/closed/N/`
- Auto-commit
- Returns YAML with status

### Item 1.12: `local-issues delete`
- `--force` flag
- Safety check: refuses if `github_issue` set and not `--force`
- `rm -rf` the issue directory
- Auto-commit
- Returns YAML with deleted: true

### Item 1.13: `local-issues push-body` / `pull-body`
- `push-body N`: reads remote.md, detects platform, pushes via `gh` or `gitbucket-api`
- `pull-body N`: detects platform, fetches remote body via `gh` or `gitbucket-api`, writes remote.md + state.md
- Both update `state.md` with `last_sync`
- Returns YAML with sync_status

### Item 1.14: `local-issues search` / `list` / `link` / `renumber` / `promote`
- `search`: `--status`, `--labels`, `--query`, YAML output array
- `list`: `--status`, delegates to search
- `link N --github NUM`: sets `github_issue` in frontmatter
- `link N --child NUM`: adds to `children` in `links.yaml`
- `link N --related NUM`: adds to `related` in `links.yaml`
- `link N --blocked-by NUM`: adds to `blocked_by` in `links.yaml`
- `renumber N --to R`: renames `.issues/N/` → `.issues/R/`, updates frontmatter number
- `promote N`: checks readiness, prints exec summary, does NOT create remote

---

## Phase 2: Platform Sub-Skill Cards

Rewrite local platform task files. 5 items covering the full operation surface.

### Item 2.1: `platforms/local/SKILL.md`
- Rewrite capability contract per Card-020
- List all task files, parameters, return types
- Support matrix table

### Item 2.2: `platforms/local/tasks/creation.md`
- Three scenarios per Card-010: draft → `create-local`, promote → `promote-to-remote`, remote-first → `pre-creation` + `import-remote`
- Entry/exit criteria per scenario
- Result contracts

### Item 2.3: `platforms/local/tasks/read.md`
- Type dispatch per Card-012
- YAML output pass-through
- Entry/exit criteria

### Item 2.4: `platforms/local/tasks/update.md` + `close.md` + `comment.md` + `delete.md`
- update: separate from push-body per Card-013
- comment: type flag per Card-014
- close: local mutation, separate remote sync per Card-015
- delete: safety guard per Card-016

### Item 2.5: `platforms/local/tasks/search.md` + `list.md` + `link.md` + `promote.md` + `body-edit.md` + `tag-gate.md`
- search/list: YAML output per Card-017
- body-edit: four-phase pipeline per Card-018
- tag-gate: reusable task per Card-021

---

## Phase 3: Dispatcher + Workflow Integration

Clean up the integration points. 4 items.

### Item 3.1: Update `issue-operations` dispatcher
- Verify dispatcher routes `platform=local` to `platforms/local/`
- No logic changes — routing only

### Item 3.2: Remove infrastructure from `git-workflow/tasks/pre-work.md`
- Delete `local-issues setup` substep (Step 3.7.1)
- Delete `local-issues push` substep (Step 3.7.6)
- Delete stale worktree exit code 2 remediation
- Delete migration substeps

### Item 3.3: Remove infrastructure from `git-workflow/tasks/review-prep.md`
- Delete `local-issues push` step (line 46-50)
- Delete `push-and-cleanup.md` enforcement checklist row "issues-data branch pushed" (line 149)

### Item 3.4: Normalize directory naming references
- Fix `creation.md:154-155` — `<remote_number>-<slug>` → `<remote_number:03d>-<slug>`
- Fix `import-remote.md:16-17,120` — match line 96 `:03d`
- Fix `sync-pull-to-local.md:15` — `<number>-<slug>` → `<NNN>-<slug>`
- Fix `body-edit.md:68` — `N-slug` → `NNN-slug`
- Fix fixture directories `932/`, `956/`, `972/` → add slug

---

## Phase 4: Behavioral Tests

Add behavioral RED-GREEN tests for the full command surface. 5 items.

### Item 4.1: test scaffold
- `./tmp/` fixture repo setup helper
- `with-test-home` integration for opencode-cli runs
- Common test environment: isolated git repo, issues-data worktree, known state

### Item 4.2: CLI command tests
- SC-1: create works without worktree (plain files on feature branch) — behavioral
- SC-2: create transparently creates worktree if possible — behavioral
- SC-3: read/full, read/comments, read/labels, read/links, read/all — behavioral
- SC-5: close moves open → closed — behavioral
- SC-8: delete refuses without --force for linked issues — behavioral

### Item 4.3: Sync tests
- SC-6: push-body pushes remote.md to remote (mocked gh/gitbucket-api) — behavioral
- SC-7: pull-body pulls remote body to local remote.md — behavioral

### Item 4.4: Worktree integrity tests
- SC-12: orphan issues-data worktree survives re-setup (idempotent) — behavioral
- SC-13: stale worktree detected and auto-remediated — behavioral
- SC-14: plain-file fallback migrates into worktree when available — behavioral

### Item 4.5: Content-verification tests
- SC-9: grep for auto-commit in tool source — string
- SC-10: grep for tag creation in tool source — string
- SC-15: grep skill cards for absence of `local-issues setup`/`local-issues push` — string
- SC-17: grep task files for `:03d` or `NNN` naming — string

---

## Dependency Graph

Phase 1 → Phase 2 → Phase 3
  ↓                     ↓
Phase 4 ←━━━━━━━━━━━━━━━┛
(Phase 4 depends on Phase 1 and Phase 2 tool/CLI changes.
 Phase 3 is independent of Phase 4.)