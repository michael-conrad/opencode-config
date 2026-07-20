## Problem

The SSE/HTTP session timeout auto-retry plugin introduced via PRs `.opencode#611` and `.opencode#612` is not working correctly and needs to be backed out.

**Root cause:** The plugin adjustments made to handle SSE/HTTP session timeouts in opencode-cli have behavioral defects — the retry logic does not function as intended in practice, and the auto-retry mechanism introduces race conditions and incorrect error classification.

## Scope

Single concern: Remove the `opencode-retry-timeout` plugin and its configuration file from the `.opencode` submodule. No changes to any existing files are required.

## Affected Files

| Action | Path | Reason |
|--------|------|--------|
| DELETE | `.opencode/plugins/opencode-retry-timeout.ts` | Main plugin (484 lines) added by PR #611, modified by PR #612 |
| DELETE | `.opencode/opencode-retry-timeout.json` | Plugin configuration file (21 lines) added by PR #611 |

## Success Criteria

- SC-1: File `.opencode/plugins/opencode-retry-timeout.ts` no longer exists in the `.opencode` submodule on `dev`
- SC-2: File `.opencode/opencode-retry-timeout.json` no longer exists in the `.opencode` submodule on `dev`
- SC-3: No file in `.opencode/` references `opencode-retry-timeout` or `retry-timeout` (verified via grep — zero matches expected)
- SC-4: `opencode.jsonc` and `tsconfig.json` are unmodified (they never referenced the plugin)
- SC-5: Stale work state file `.opencode/tmp/work-feature-58-sse-timeout-auto-retry.md` (if present) cleaned up

## Implementation Notes

- This is a pure file deletion — no code changes to existing files
- PR will target the `.opencode` submodule directly (changes go into `.opencode/` subtree)
- The plugin was not registered in `opencode.jsonc` (plugins are auto-discovered from `plugins/` directory), so no config changes are needed
- The revert includes both PR #611 (initial plugin) and PR #612 (fix PR) since deleting the plugin removes both
- PR #612 was a fix to #611's bugs — no reason to retain the fix if the feature itself is being removed

## Risk

Low. Zero references from any other file. Auto-discovery means runtime will simply stop discovering the plugin.
