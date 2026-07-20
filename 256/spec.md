## Problem

The `viewport-editor` MCP server plugin in this repo is pinned at `v0.3.3` via the git URL in `opencode.jsonc`. The upstream repository has released `v0.3.4`, which includes a breaking change: the MCP plugin key was renamed from `"viewport-editor"` to `"editor"`.

Additionally, v0.3.4 adds support for absolute paths (previously only relative paths were supported), and the README documents updated configuration recommendations.

## Root Cause

The config block in `opencode.jsonc` pins version `@v0.3.3` with the old plugin key `"viewport-editor"`. Both need updating to align with v0.3.4's requirements.

## Scope

| File | Change |
|------|--------|
| `.opencode/opencode.jsonc` (line ~131-133) | Rename MCP server key from `"viewport-editor"` → `"editor"`, bump version pin `@v0.3.3` → `@v0.3.4`. Binary name in command array stays as `"viewport-editor"`. |
| `.opencode/AGENTS.md` (line ~278, 280) | Update section heading and link text to reference new plugin key `"editor"` instead of `"viewport-editor"`. GitHub repo URL unchanged. |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `opencode.jsonc` MCP server key renamed from `"viewport-editor"` to `"editor"` | `string` | grep for `"editor": {` in opencode.jsonc; verify no stale `"viewport-editor": {` block remains (except inside command array) |
| SC-2 | Version pin updated to `@v0.3.4` in git URL | `string` | grep for `@v0.3.4` in opencode.jsonc |
| SC-3 | AGENTS.md section heading reflects new plugin key | `string` | grep for `## editor MCP Plugin` in AGENTS.md |
| SC-4 | AGENTS.md link text references new plugin key | `string` | grep for `[editor](https://github.com/michael-conrad/viewport-editor)` in AGENTS.md |
| SC-5 | No stale `"viewport-editor"` references remain as MCP server keys (only binary name in command array is allowed) | `string` | Search opencode.jsonc — only one occurrence of literal `"viewport-editor"` should be the last element of the command array |

## Cross-References

None. Self-contained fix.