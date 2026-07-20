## Summary

Update the viewport-editor MCP server version pin from `v0.3.4` to `v0.4.2` in `.opencode/opencode.jsonc`.

## Current State

Line 133 of `.opencode/opencode.jsonc`:
```jsonc
"command": ["uvx", "--from", "git+https://github.com/michael-conrad/viewport-editor@v0.3.4", "viewport-editor"],
```

## Target State

```jsonc
"command": ["uvx", "--from", "git+https://github.com/michael-conrad/viewport-editor@v0.4.2", "viewport-editor"],
```

## Changes Between v0.3.4 and v0.4.2

### v0.4.1 (2026-07-18)
- **Added**: Auto-reload viewport buffer on external file change (#96)
- **Changed**: Default autosave to `True`
- **Removed**: `VIEWPORT_PROJECT_ROOT` environment variable (#100) — use `--project-root` CLI flag instead
- **Fixed**: Test pollution from shared fixture opens

### v0.4.2 (2026-07-18)
- **Fixed**: Stale buffer auto-reload (#85) — staleness checks with auto-reload added to 7 handler paths (read, diff apply, clipboard copy/cut/paste, find in viewport, find in session)

## Affected Files

| File | Change |
|------|--------|
| `.opencode/opencode.jsonc` | Update version string `v0.3.4` → `v0.4.2` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|---------------------|
| SC-1 | `.opencode/opencode.jsonc` references `viewport-editor@v0.4.2` | `string` | `grep` for `viewport-editor@v0.4.2` in `opencode.jsonc` |
| SC-2 | No remaining references to `viewport-editor@v0.3.4` in the repo | `string` | `grep` for `v0.3.4` returns no matches outside changelog/history |
| SC-3 | `uvx` can resolve the new version (no syntax error in command) | `structural` | `uvx --from git+https://github.com/michael-conrad/viewport-editor@v0.4.2 --help` exits successfully |

## Risk Assessment

**Low risk.** Single-line version string change. The `uvx` command format is unchanged. The `editor` MCP plugin key and all tool names are identical between versions. The `VIEWPORT_PROJECT_ROOT` env var removal in v0.4.1 has no impact — this repo does not use that env var (confirmed by grep).

## Root Cause

The version pin was set to `v0.3.4` and has not been updated through two subsequent releases (v0.4.1, v0.4.2) that include bug fixes and improvements relevant to the editor MCP server used by this repo.

---

**Closed — wrong repo. Moved to michael-conrad/.opencode.**
