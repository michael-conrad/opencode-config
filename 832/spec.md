# Synced from GitHub Issue #832 at 2026-05-22T22:38:20Z

STATUS: 0.3 (DRAFT — research-validated)

## Problem

`session-init` emits repo identity in two disjoint sections with incompatible formats:

1. **Flat dotted keys** (primary): `github.owner`, `github.repo`, `github.platform: github` (hardcoded)
2. **YAML list** (submodules): `owner`, `repo`, `platform: github.com` (raw hostname) — different key names, different platform value

Three DRY violations drive this:
- `parse_repo_url()` parses a URL, then `parse_git_remote_url()` and `resolve_identity()` re-parse the same URL through different wrappers
- `resolve_identity()` hardcodes `"github"` instead of using the hostname
- `emit_subfolder_mappings()` duplicates parsing with yet another code path

Additional problems:
- `github.platform` value `"github"` is a hardcoded identifier, not the actual hostname from the remote URL
- The sub-folder section uses different key names (`owner`, `repo`) than the primary section (`github.owner`, `github.repo`)
- `github.identity_source` is routing logic, not repo identity
- `gitbucket.*` output conflates credential status with repo identity
- Credential status is action-oriented (can I make this API call?), not identity — it changes on token rotation

## Current Output (Disjoint)

```
github.owner: michael-conrad
github.repo: opencode-config
github.platform: github
github.identity_source: root
dev.name: Michael Conrad
dev.email: m.conrad.202@gmail.com
branch: feature/auditor-swap-928
Remote: git@github.com:michael-conrad/opencode-config.git
github.html_url: https://github.com/
Worktrees: .worktrees/main/
srclight.project: opencode-config
Srclight: indexed
## Sub-folder Repo Mappings
submodules:
  - path: .opencode
    owner: michael-conrad
    repo: .opencode
    platform: github.com
    url: git@github.com:michael-conrad/.opencode.git
```

Three format inconsistencies:
1. **Layout**: flat `key: value` vs nested YAML list
2. **Key names**: `github.owner`/`github.repo` vs bare `owner`/`repo`
3. **Platform value**: `"github"` (hardcoded) vs `"github.com"` (raw hostname)

## Proposed Output (Unified)

```yaml
## Repo Information
# Match file path to entry for owner/repo/platform values.
- path: .
  owner: michael-conrad
  repo: opencode-config
  platform: github.com
  url: git@github.com:michael-conrad/opencode-config.git
- path: .opencode
  owner: michael-conrad
  repo: .opencode
  platform: github.com
  url: git@github.com:michael-conrad/.opencode.git
```

One section, one schema, bare keys, raw hostname from URL, no nesting, no hardcoded platform identifiers.

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Key format | Bare `owner`, `repo`, `platform` | No fake scope prefix; self-documenting comment handles convention |
| `platform` value | Raw hostname from URL | No hardcoding; `github.com` not `github` |
| `branch` | Omitted | Changes during implementation, not a fixed identity field |
| `identity_source` | Omitted | Routing logic, not repo identity; handled by skills/tasks |
| Credential status | Omitted | Action-oriented, not identity; tooling handles it |
| `github.html_url` | Omitted | Derivable from platform+owner+repo |
| `Remote:` line | Omitted | Redundant with `url` |
| `srclight.project` | Omitted | Not repo identity; srclight tooling derives it |
| Format | Flat YAML list with `- path:` entries | No nesting avoids submodule mislabeling |
| Preamble comment | Two lines explaining the convention | Self-documenting, no separate guideline lookup needed |

## Removed Functions

| Function | Fate | Reason |
|----------|------|--------|
| `parse_git_remote_url()` | Remove | Thin wrapper, discards platform |
| `is_github_remote()` | Remove | Hardcodes platform check |
| `is_gitbucket_remote()` | Remove | Was `not is_github_remote()` |
| `resolve_identity()` | Remove | Hardcodes `"github"`, re-parses URL |
| `parse_gitbucket_url()` | Remove | Special-case with .env base_url lookup |
| `get_linked_repo_dirs()` | Fold into unified collector | |
| `emit_subfolder_mappings()` | Remove | Subsumed by unified section |
| GitBucket credential probing | Remove from identity output | Credential status is tooling's job |

## Kept Function

| Function | Change |
|----------|--------|
| `parse_repo_url()` | Keep as-is — canonical URL parser, returns `(owner, repo, platform)` correctly from raw hostname |

## New Function

`collect_repo_info()` — single entry point that:

1. **Root entry**: `git remote get-url origin` + `parse_repo_url()`, local-only fallback (`owner: "(none)"`, `repo: "(none)"`, `platform: "local"`, `url: "(none)"`)
2. **Subdirectory scan**: `os.listdir()` for immediate subdirs with `.git` entries (file or directory), `git -C <subdir> remote get-url origin` + `parse_repo_url()` for each, excluding repos with same owner/repo as parent (worktrees)
3. **Emits** single `## Repo Information` section with preamble comment

## Removed Output Lines

| Old output | Fate |
|------------|------|
| `github.owner` / `github.repo` / `github.platform` | Replaced by `owner`/`repo`/`platform` in YAML entries |
| `github.html_url` | Remove — derivable |
| `github.identity_source` | Remove — routing logic, not identity |
| `gitbucket.*` | Remove — credential status is tooling's job |
| `## Sub-folder Repo Mappings` section | Replaced by flat YAML list |
| `Remote:` diagnostic line | Remove — redundant with `url` |
| `srclight.project` / `Srclight:` | Remove — not repo identity |

## Retained Output (Outside Repo Information)

These remain as top-level dotted keys — they're developer/workspace identity, not repo identity:

```
dev.name: Michael Conrad
dev.email: m.conrad.202@gmail.com
```

## Downstream Impact

Skills and guidelines that reference the old `github.owner`/`github.repo`/`github.platform` dotted keys need updating to read from the `## Repo Information` section by matching file path to entry. The skill/task routing layer handles platform-to-tool mapping.

Files likely needing updates:
- `.opencode/guidelines/060-tool-usage.md` §9 (Identity Source Semantics)
- `.opencode/guidelines/000-critical-rules.md` (submodule routing references)
- `.opencode/skills/issue-operations/` (platform routing)
- `.opencode/plugins/session-enforcement.ts` (if it parses session-init output)

## Success Criteria

| ID | Criterion | Evidence Type | Behavioral Test |
|----|-----------|---------------|-----------------|
| SC-1 | session-init emits single `## Repo Information` section with uniform schema | `string + behavioral` | Agent asked "What git repository are you working in?" — answers owner/repo/platform from session context without running git commands |
| SC-2 | No `github.*` flat keys in session-init output | `string + behavioral` | Agent asked for owner/repo values to file issues in root vs submodule repos — correctly disambiguates between multiple ## Repo Information entries |
| SC-3 | No `## Sub-folder Repo Mappings` section in output | `string` | — |
| SC-4 | `platform` values are raw hostnames (e.g., `github.com` not `github`) | `string + behavioral` | Multi-platform test repo (github.com + gitbucket.internal.dev fixtures), agent asked "What SCM platforms are in use?" — reports raw hostnames |
| SC-5 | `parse_repo_url()` is the only URL parser — all others removed | `string` | — |
| SC-6 | Root repo entry has `path: .` | `string` | — |
| SC-7 | Submodule/subdirectory entries have `path:` matching their directory name | `string` | — |
| SC-8 | Preamble comment present with routing convention explanation | `string` | — |
| SC-9 | No `identity_source`, `branch`, credential status, `html_url`, or `srclight` fields in repo info | `string` | — |
| SC-10 | Local-only repo (no remote) produces entry with `owner: "(none)"`, `repo: "(none)"`, `platform: "local"`, `url: "(none)"` | `string + behavioral` | Agent in local-only repo asked "Can you push to GitHub?" — declines based on `platform: local` in session context |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
