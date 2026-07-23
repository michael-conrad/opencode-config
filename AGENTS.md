# AGENTS.md — opencode-config Repository

This repository holds the agent configuration submodule. All agent rules, guidelines, and skills are in the submodule — not here.

## Trunk-Based Development

Main is the single trunk. Dev branch has been removed.

## Reference Files

| File | Purpose |
|------|---------|
| `.opencode/AGENTS.md` | Canonical agent rules: build/lint/test commands, workflow, boundaries, pair mode, submodule discipline |
| `.opencode/.issues/AGENTS.md` | `.issues/` workspace guide: tool, workflow, directory layout, GitHub URL convention |
| `.issues/AGENTS.md` | Local `.issues/` workspace guide for the parent repo (mirrors `.opencode/.issues/AGENTS.md` pattern)
| `.opencode/reference/skill-card-description-standards.md` | Description field as semantic router, persona framing, skill()/task() pipeline, Workflows section format |
| `.opencode/reference/task-card-structure-standards.md` | Canonical task card structure, result contract format, task card vs SKILL.md division |
| `.opencode/reference/skill-card-schema.md` | SKILL.md frontmatter binary constraints (name, description, license) |
| `.opencode/skills/version-manager/` | Version string discovery and semver bumping: discover, bump tasks |
| `.opencode/skills/release-promoter/` | Git tag creation and GitHub Release promotion: tag, create-release tasks |

## Trunk-Based Development
Main is the single trunk. Dev branch has been removed.

## `.issues/` Is a Worktree — NOT a Regular Directory

**`.issues/` is a git worktree (orphan branch worktree), NOT a regular directory.** It lives at `.git/worktrees/-issues/` and is a completely separate git repository with its own `issues-data` branch. It is gitignored in the parent repo (`.gitignore` line 40: `.issues/`).

**Any agent that tracks `.issues/` files in the parent repo's git is corrupting git state and breaking branches.**

| ✅ CORRECT | 🚫 FORBIDDEN |
|------------|---------------|
| `.opencode/tools/local-issues <command>` | `read(filePath='.issues/46/spec.md')` |
| `git -C <tree>/.issues/ <command>` | `write(filePath='.issues/46/spec.md')` |
| | `git add .issues/` in parent repo |
| | `edit(filePath='.issues/46/spec.md')` |
| | `glob(pattern='.issues/**/*.md')` in parent repo |

**The CLI tool handles git operations internally.** File operation tools (`read`, `write`, `edit`, `glob`, `grep`) target the parent repo — they do NOT reach into the worktree. Using them on `.issues/` paths silently operates on the wrong repository.

**Read [the canonical `.issues/` workspace guide](.opencode/AGENTS.md). Read [the local `.issues/` workspace guide](.issues/AGENTS.md).

---

## Test Framework Discipline — MANDATORY

All test execution MUST use the canonical test framework. The following rules are non-waivable.

### `timeout` Command Prohibition

The `timeout` command (GNU coreutils) is FORBIDDEN in all bash scripts. The bash tool's `timeout` parameter (in milliseconds) is the ONLY permitted kill signal. GNU timeout does NOT forward SIGTERM to its child processes — orphaned opencode processes hold the `flock` lock and hang all subsequent test runs.

### `with-test-home` Mandate

`opencode run` MUST NOT be called directly. ALL opencode test execution MUST go through:
```bash
bash .opencode/tests-v2/with-test-home opencode run '<message>'
```

### Standalone Binary Setup

The snap binary at `/snap/bin/opencode` hardcodes `SNAP_USER_DATA=~/snap/opencode/` and cannot be redirected. The correct pattern is:
1. Cache the standalone binary at `.tools/opencode/opencode`
2. Copy it into the test home at `$TEST_HOME/bin/opencode` during test setup
3. Prepend `$TEST_HOME/bin` to PATH so the harness resolves the standalone binary

### Prohibited Bypass Patterns

| Pattern | Why Forbidden |
|---------|---------------|
| Manual test home construction (`mktemp -d`, manual `opencode.jsonc`, manual `git init`, manual `.opencode` clone) | Bypasses isolation, leaks production state |
| Direct `opencode run` without `with-test-home` | Causes SQLite session conflicts with desktop app |
| Standalone binary download/copy outside `with-test-home` | Creates unmanaged test environments |
| Manual `opencode.jsonc` seeding | Bypasses `seed_model_config()` model discovery and isolation verification |
| Manual `git init` + `.opencode` clone | Bypasses test project creation with proper isolation |
| "This is simple/quick/small" rationalization | NOT a valid justification — framework is MANDATORY for ALL test execution |**

---

## Specs and Plans Are NOT Tracking Documents

**Specs and plans are NOT tracking documents.** A spec defines what is required — implemented or not. A plan defines how to implement it — implemented or not. Any STATUS field, completion marker, pending indicator, or progress tracker in a spec or plan is a defect.

Implementation status is tracked through the pipeline state (work state files, lifecycle manifests, PR status) — never through STATUS fields in the spec or plan body.
