# Card 001: Data Model — Files + Markdown + YAML Frontmatter

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** Comparison of git-bug, taskwarrior, file-based approaches

## Options Considered

| Approach | Example | Properties |
|----------|---------|------------|
| Files + markdown + YAML | Current `.issues/` system | Human-readable, grep-able, LLM-parsable without special tooling |
| Git objects (blobs/trees) | git-bug `refs/bugs/` | Distributed sync via git, opaque without tool, requires Go runtime |
| SQLite | taskwarrior v3 | Queryable, atomic, relational — but binary, invisible to grep, LLM needs a reader |
| Hybrid (files + SQL index) | — | Two sources of truth to keep in sync |

## Decision

Keep **files + markdown + YAML frontmatter**. Rationale:

1. **Issue access is sequential and isolated to a single ticket.** There is no need for relational queries or cross-issue joins. Sequential read of one `.issues/N/` directory covers the use case.

2. **Markdown is directly parsable by an AI agent without special tooling.** The agent reads `spec.md` with the `read` tool — no database driver, no API server, no parser required.

3. **Adding a binary backend (SQLite, git blob store) to a git-repo tool is a regression.** It introduces build dependencies, runtime requirements, and opacity that contradict the tool's purpose as infrastructure embedded in the repo.

4. **The file structure provides a clear mental model:** `.issues/open/NNN-slug/spec.md`, `comments.md`, `remote.md`, `state.md`. Any developer can navigate it with `ls` and `cat`.

## References

- git-bug (9.9k ★, Go, GPLv3): Distributed bug tracker embedded in Git as git objects. Architecture revealed that the object-based approach requires the tool for every operation — data is invisible without `git bug` commands. Tradeoff is acceptable for a standalone tool but not for a repo-bundled utility.
- taskwarrior (C++, MIT): SQLite backend in v3. Powerful query language (DOM-based attribute references) but requires the `task` binary to read anything.
- ghi (Ruby, archived 2022): Pure GitHub API — no local storage at all. Simplest possible approach but no offline capability.