## Problem

The parent repo (`opencode-config`) accumulated duplicate copies of `.opencode/` content at the top level (`guidelines/`, `skills/`, `tests/`, `tools/`, `plugins/`, `hooks/`, `scripts/`, `docs/`, `.guidelines/`) plus stale build artifacts (`dispatch-table.yaml`, `tsconfig.json`, `package.json`, `bun.lock`, `node_modules/`, `opencode.jsonc`, `CHANGELOG.md`). These copies were introduced by a recursive cross-up from an AI agent that insisted on having a remote for a local-only repo.

These duplicates created a silent divergence risk: agents could edit top-level copies that never affected runtime behavior (since `opencode.jsonc` references `.opencode/` paths). The `AGENTS.md` and `README.md` also described the repo as if it were the source of truth for guidelines/skills/tools, when in fact the submodule is the authoritative source.

## Fix Approach

1. Remove all duplicate top-level directories and stale artifacts
2. Rewrite `AGENTS.md` to clarify: repo is a test harness for the `.opencode/` submodule, all agent config lives in the submodule, top level must never contain copies
3. Rewrite `README.md` to match the cleaned-up structure
4. Update `.gitignore` to remove stale entries
5. Remove duplicate `opencode.jsonc` (the CLI sources from `.opencode/opencode.jsonc`)

## Success Criteria

- [ ] `ls -1` at repo root shows only: `AGENTS.md`, `LICENSE`, `README.md`, `.gitignore`, `.opencode/`, tmp/`, `.issues/`, `.github/`, `.worktrees/`, `.ruff_cache/`
- [ ] No top-level directories that mirror `.opencode/` subdirectories
- [ ] `AGENTS.md` clearly states repo purpose and submodule discipline
- [ ] `README.md` accurately reflects the repo structure
- [ ] `.opencode/opencode.jsonc` is the only `opencode.jsonc`