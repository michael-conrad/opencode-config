## Problem

When opencode is installed via snap (`/snap/bin/opencode`, classic confinement), the snap environment does not propagate the full user PATH to the `bun` process that runs plugins. The plugins (`session-enforcement.ts`, `env-loader.ts`) use bare `"git"` strings in `execSync()` calls, which fail because `bun` cannot find `git` in its restricted PATH.

Error pattern: `bun: command not found: git branch --show-current`

## Root Cause

The opencode snap (classic confinement, v1.18.1) runs plugins via `bun`. The snap's environment does not inherit the user's full `$PATH` (e.g., `/usr/bin`, `/usr/local/bin`), so `bun`'s `execSync("git ...")` cannot resolve the `git` binary.

Both plugins call `execSync` / `$.nothrow()` with bare `"git"` strings, relying on PATH resolution that doesn't work in the snap context.

Affected calls in `session-enforcement.ts`:
- `execSync("git config --local --list", ...)` — lines 88, 756, 976
- `execSync("git remote -v", ...)` — line 102
- `execSync("git rev-parse --git-dir", ...)` — line 300

Affected calls in `env-loader.ts`:
- `$.nothrow()\`git branch --show-current\`` — line 278
- `$.nothrow()\`git remote get-url origin\`` — line 286
- `$.nothrow()\`git config user.name\`` — line 317
- `$.nothrow()\`git config user.email\`` — line 325

## Fix

Resolve the `git` binary path at plugin startup using `which` lookup, then use the resolved path for all subsequent git calls.

### session-enforcement.ts

1. At plugin init, resolve `git` path: `const gitPath = execSync("which git", ...).trim()`
2. Replace all bare `"git"` strings in `execSync` calls with the resolved `gitPath` variable
3. Handle the case where `git` is not found (graceful degradation — skip git operations)

### env-loader.ts

1. At plugin init, resolve `git` path using `$.nothrow()\`which git\``
2. Replace all bare `"git"` strings in template literal commands with the resolved path
3. Handle the case where `git` is not found (graceful degradation)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Plugins resolve `git` binary path at startup before any git command | `string` — grep for path resolution code |
| SC-2 | All `execSync` git calls in `session-enforcement.ts` use the resolved path | `string` — grep confirms no bare `"git"` strings remain in execSync calls |
| SC-3 | All `$.nothrow()` git calls in `env-loader.ts` use the resolved path | `string` — grep confirms no bare `"git"` strings remain in template literals |
| SC-4 | Graceful fallback when `git` binary is not found (no crash) | `string` — error handling path exists |
| SC-5 | Plugin loads without errors under snap | `behavioral` — `opencode run` confirms no plugin errors |

## Affected Files

- `.opencode/plugins/session-enforcement.ts`
- `.opencode/plugins/env-loader.ts`

## Labels

`SPEC-FIX`, `plugin`, `snap`
