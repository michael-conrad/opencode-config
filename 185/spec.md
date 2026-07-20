> Full spec and plan artifacts: https://github.com/michael-conrad/opencode-config/tree/issues-data/{N}

## Exec Summary

Replace the `.issues/` git worktree (orphan `issues-data` branch) and wiki submodule with standalone sibling peer repos at the workspace root level, eliminating all AI agent confusion caused by nested worktree path resolution, orphan branch visibility in the main repo's ref namespace, and submodule pointer corruption.

### Cards (dependency order)

1. **Rewrite local-issues tool** — Replace all worktree management (`git worktree add`, `git worktree prune`, orphan branch creation) with sibling repo clone/management (`git clone`, `git push`). Remove all worktree detection functions. Add sibling repo validation on every command call.
2. **Create target sibling repos** — `opencode-config.issues-data/`, `opencode-config.wiki/`, `.opencode.issues-data/` on their respective remotes with appropriate orphan branches.
3. **Update Repo Information entries** — Add sibling repo paths to session-init/AGENTS.md with owner/repo/platform for routing.
4. **Update skill task card paths** — ~194 references to `.issues/{N}` across writing-plans, spec-creation, issue-operations (local platform), implementation-pipeline, and guidelines. Convert to `{PROJECT_ROOT}/../{REPO}.issues-data/{N}/`.
5. **Update guidelines** — Delete `.issues/` Worktree Exemption in `060-tool-usage.md`. Remove `.issues/` carveouts in `000-critical-rules.md`.
6. **Update tests** — ~30 behavioral test files referencing `.issues/` paths. Fixture infrastructure, harness helpers, content-verification checks.
7. **Remove wiki submodule** — Delete from `.gitmodules`. `git-workflow cleanup` tasks branch for "no wiki submodule."
8. **Remove `.issues/` worktree** — Final cleanup: prune stale worktree entries, delete `.issues/` directory, verify zero `.issues/` directories remain.

### Key Decisions

- **Branch name `issues-data` is used in the sibling directory name**: `{REPO}.issues-data/` — the sibling folder IS the branch name. No mapping, no translation, no conflation with "issues."
- **Session-init does NOT report siblings**: Session-init reports only what's under the project root. Sibling discovery is handled by `local-issues` tool via `{PROJECT_ROOT}/../{sibling-name}/`.
- **`.opencode/` submodule stays nested**: OpenCode requires it at project root. Its issue data sibling lives at workspace root as `.opencode.issues-data/` — peer to `opencode-config/`, not nested inside it.
- **Zero `.issues/` directories remain**: The `.opencode/.issues/` worktree is also eliminated. Its sibling is `.opencode.issues-data/` at workspace root.

### Risk Callouts

- **Risk A**: Path resolution in task files — ~194 hardcoded `.issues/{N}` references must change. Error-prone if done manually. Mitigation: systematic search-and-replace with per-file verification pass.
- **Risk B**: Test infrastructure — 30 behavioral tests reference `.issues/` paths. Harness helper `behavior_run` seeds fixtures. Must update test repo setup and tear-down logic.
- **Risk C**: `.opencode.issues-data/` naming convention — repo name starts with dot, may confuse some tooling. Mitigation: `local-issues` tool handles full path resolution internally.

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan artifacts are at {N}. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.