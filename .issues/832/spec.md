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

## Behavioral Tests

Five behavioral test scripts in `.opencode/tests/behaviors/` verify the session-init changes through the agent's consumption path:

| Script | SC | Prompt | Verified |
|--------|-----|--------|----------|
| `832-sc1-repo-information-section.sh` | SC-1 | "What git repository are you working in?" | ✅ PASS — agent reports correct owner/repo/platform from session context |
| `832-sc2-no-github-flat-keys.sh` | SC-2 | "What owner/repo for root vs submodule issues?" | ✅ PASS — correctly disambiguates entries |
| `832-sc4-platform-raw-hostname.sh` | SC-4 | "What are the hostname values in the platform field?" | ✅ PASS — lists `github.com`, `github.com`, `gitbucket.internal.dev` |
| `832-sc10-local-only-degraded.sh` | SC-10 | "Can you push to GitHub?" | ✅ PASS — declines without push attempt (local-only) |

Additional test infrastructure:
- **Fixture**: `fixtures/gitbucket-fake-repo/` — empty repo with `git@gitbucket.internal.dev:my-org/some-repo.git` remote for multi-platform testing
- **Helpers fix**: `helpers.sh:behavior_run` changed to always clone `.opencode` submodule even when custom workdir is provided (was skipping all setup before)

## Test Harness Changes

### helpers.sh — behavior_run always sets up submodule

The `behavior_run` function previously skipped ALL setup (clone .opencode, checkout commit, submodule add, commit, story fixtures) when a custom `workdir` was passed as the 4th argument. This meant test scripts that pre-built custom workdirs (SC-4 gitbucket fixture, SC-10 local-only repo) ran without `.opencode` in the test repo — no session-init, no plugins.

**Fix**: Setup now always runs. Only `git init`/`git config` is skipped when workdir is pre-provided. The `.opencode` clone, submodule commit checkout, submodule add, git commit, and story fixtures all run unconditionally.

### Test Script Pattern

All SC test scripts follow this pattern:

1. Create temp workdir with `git init` + optional remote + optional fixtures
2. Call `behavior_run`, which clones `.opencode` from remote, checks out the pinned commit, adds it as a submodule, commits, injects story fixtures
3. The `with-test-home` wrapper runs opencode-cli with the workdir as TEST_WORKDIR
4. session-init runs from the cloned `.opencode` feature branch — output injected into model context
5. Model answers from injected session context

Set `BEHAVIOR_SUBMODULE_COMMIT=<sha>` to pin the `.opencode` checkout to the feature branch commit.

## Success Criteria

| ID | Criterion | Evidence Type | Behavioral Test |
|----|-----------|---------------|-----------------|
| SC-1 | session-init emits single `## Repo Information` section with uniform schema | `string + behavioral` | ✅ PASS — agent answers from session context |
| SC-2 | No `github.*` flat keys in session-init output | `string + behavioral` | ✅ PASS — agent disambiguates root/submodule |
| SC-3 | No `## Sub-folder Repo Mappings` section in output | `string` | — |
| SC-4 | `platform` values are raw hostnames (e.g., `github.com` not `github`) | `string + behavioral` | ✅ PASS — agent reports `gitbucket.internal.dev` |
| SC-5 | `parse_repo_url()` is the only URL parser — all others removed | `string` | — |
| SC-6 | Root repo entry has `path: .` | `string` | — |
| SC-7 | Submodule/subdirectory entries have `path:` matching their directory name | `string` | — |
| SC-8 | Preamble comment present with routing convention explanation | `string` | — |
| SC-9 | No `identity_source`, `branch`, credential status, `html_url`, or `srclight` fields in repo info | `string` | — |
| SC-10 | Local-only repo (no remote) produces entry with `owner: "(none)"`, `repo: "(none)"`, `platform: "local"`, `url: "(none)"` | `string + behavioral` | ✅ PASS — agent declines push in local-only repo |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
