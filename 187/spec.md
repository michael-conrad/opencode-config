## Summary

`session-init` outputs `## Repo Information` and `## Agent Tools` sections to the LLM system prompt. Add a new `## Local Issue Artifacts` section that maps each discovered repo to its local `.issues/` directory, with a `setup` key for `.issues/` paths that do not yet exist.

## Background

AI agents get confused about the `.issues/` folder vs the orphaned `issues-data` branch. The `.issues/` directory is supposed to be a git worktree pointing to the orphaned `issues-data` branch of the submodule, not the parent repo. Explicitly declaring the expected location and setup instructions per repo eliminates the ambiguity.

## Design

**New section:** `## Local Issue Artifacts` — emitted between `## Repo Information` and `## Agent Tools`.

**Source data:** Iterates the same entries returned by `collect_repo_info()` (root + immediate subdirs with `.git` + one-level-deep nested `.git` repos).

**Per-entry logic:**
- Check whether `<path>/.issues/` exists as a directory
- If present: emit `path` and `issues` keys only
- If absent: emit `path`, `issues`, and `setup` keys

**Format:**

```
## Local Issue Artifacts

- path: .
  issues: .issues/

- path: .opencode
  issues: .opencode/.issues/
  setup: create worktree .opencode/.issues/ from orphaned branch issues-data in repo .opencode
```

**Detection rules:**
- `.git` file or `.git/` directory presence → repo detected (existing `collect_repo_info()` logic)
- `.issues/` check is directory-only — no gitfile detection needed
- No `.gitmodules` involvement

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `session-init` output includes `## Local Issue Artifacts` section between `## Repo Information` and `## Agent Tools` | behavioral |
| SC-2 | Section contains one entry per repo from `collect_repo_info()` | behavioral |
| SC-3 | Entries with existing `.issues/` directory show only `path` + `issues` keys | behavioral |
| SC-4 | Entries with absent `.issues/` directory show `path` + `issues` + `setup` keys | behavioral |
| SC-5 | `setup` value disambiguates submodule orphan branch vs parent repo orphan branch | behavioral |
| SC-6 | No `.gitmodules` reads or `.git/config` submodule parsing involved | string |

## Concern Separation

Single concern: add a new output section to `session-init`. No changes to existing output sections, no changes to repo detection logic, no changes to hook installation or worktree bootstrap.

## Change Location

Single file: `.opencode/tools/session-init` — around lines 720-735 in `main()`, plus a helper function analogous to `collect_repo_info()`.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)