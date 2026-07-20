## Summary

Replace session-init's routed-issue-operations prose with submodule-disambiguation prose, rename `## Local Issue Artifacts` to `## Local Spec Artifacts` with `repo#:`/`spec artifacts:` column keys, reorder the section output to place Local Spec Artifacts before Repo Information (local-first encounter order), add a `local-issues locate` subcommand that resolves `repo#N` to a tree skeleton, and update the `local-issues` tool description to trigger agent retrieval.

## Background

The session-init tool injects `## Repo Information` and `## Local Issue Artifacts` sections into the agent's system prompt. The agent currently ignores local `.issues/` directories and goes straight to the GitHub API when resolving issue references like `.opencode#1107`. Root cause analysis identified three interacting causes:

1. **Repo Information prose drives network-first behavior.** The instruction "Professional engineers route issue operations by matching affected file paths to the `path` prefix below, then using that entry's `owner` and `repo`" actively directs the agent to use owner/repo pairs as GitHub API routing parameters.
2. **Local Issue Artifacts section has mismatched vocabulary.** The `path:`/`issues:` keys don't match the agent's retrieval vocabulary, and the section appears after Repo Information — the agent encounters the network-first table first.
3. **local-issues tool lacks a `locate` command.** The tool has no subcommand for resolving `repo#N` to a filesystem tree, and its description ("Local issue tracking CLI tool for .issues/ directory.") doesn't trigger agent retrieval behavior.

Five changes in Phase 1 address all three causes.

## Changes

### Change 1: Repo Information prose replacement

**File:** `.opencode/tools/session-init` (stdout emission section, lines 756-763)

Replace the routing-verb prose with submodule-disambiguation prose:

| Current | New |
|---|---|
| `## Repo Information` — "Professional engineers route issue operations by matching affected file paths to the `path` prefix below, then using that entry's `owner` and `repo`. Amateurs default to root and route to the wrong repo." | `## Repo Information` — "Maps each filesystem path to its remote owner/repo — prevents cross-repo confusion when calling APIs or referencing repos." |

The new text preserves the submodule disambiguation function while removing the "route issue operations" verb that drives network-first behavior.

### Change 2: Local Issue Artifacts → Local Spec Artifacts

**File:** `.opencode/tools/session-init`

**Section header:** `## Local Issue Artifacts` → `## Local Spec Artifacts`

**Column format change in `collect_issue_artifact_paths()`:**

| Current | New |
|---|---|
| `path: .opencode` | `repo#: .opencode` |
| `issues: .opencode/.issues/` | `spec artifacts: .opencode/.issues/` |

**Output block:**

```
## Local Spec Artifacts
- repo#: (root)
  spec artifacts: .issues/
- repo#: .opencode
  spec artifacts: .opencode/.issues/
```

The root repo uses `(root)` as the qualifier since it has no subdirectory name.

### Change 3: Section ordering in session-init output

**File:** `.opencode/tools/session-init` (`main()`, line 755+)

| Current order | New order |
|---|---|
| 1. `## Repo Information` | 1. `## Local Spec Artifacts` |
| 2. `## Local Issue Artifacts` | 2. `## Repo Information` |
| 3. `## Agent Tools` | 3. `## Agent Tools` |

Local-first encounter order means the agent reads the local path table before the remote API table.

### Change 4: `local-issues locate` subcommand

**File:** `.opencode/tools/local-issues`

Add a `locate` subcommand that resolves a `repo#N` or bare `N` to a tree skeleton of the issue's spec artifact directory.

**Interface:**

```
local-issues locate --number .opencode#1107
```

**Semantics:**

- Bare number (e.g., `42`) → search all repos, return all matching trees
- Qualified form (e.g., `.opencode#42`) → target one repo, return single tree

**Output format (tree skeleton with filenames only, no content):**

```
.opencode/.issues/1107-describe-issue/
├── issue.yaml
├── spec.md
├── plan.yaml
└── comments.yaml
```

Files that don't exist are omitted from the skeleton. Directory name slug uses existing slug resolution.

**Implementation approach:** Use `_resolve_qualified()` to get target repo(s), `_find_issue_dir_in_repo()` to locate the directory, and `pathlib` to list which known artifact filenames exist. Known artifact filenames: `issue.yaml`, `spec.md`, `plan.yaml`, `comments.yaml`, `links.yaml`.

### Change 5: `local-issues` tool description

**File:** `.opencode/tools/local-issues` (main CLI description and `--description` output)

| Current | New |
|---|---|
| `Local issue tracking CLI tool for .issues/ directory.` | `Locate repo#N spec and plan artifacts. Create, read, and manage them.` |

## Success Criteria

| ID | Criterion | Evidence Type |
|---|---|---|
| SC-1 | session-init emits `## Local Spec Artifacts` section before `## Repo Information` | `string` |
| SC-2 | Local Spec Artifacts uses `repo#:` and `spec artifacts:` keys | `string` |
| SC-3 | Repo Information prose is the short replacement text, not the routing instruction | `string` |
| SC-4 | `local-issues locate --number N` returns tree skeleton of issue directory | `behavioral` |
| SC-5 | `local-issues locate --number repo#N` returns single tree from target repo | `behavioral` |
| SC-6 | `local-issues` tool description reports new text | `string` |
| SC-7 | Agent uses `local-issues locate` before `github_issue_read` when resolving `repo#N` | `behavioral` |

## Evidence Type Column Reference

- `string`: grep output or file-read evidence showing the expected text/format
- `behavioral`: clean-room `opencode-cli run` with stderr assertion showing actual agent behavior