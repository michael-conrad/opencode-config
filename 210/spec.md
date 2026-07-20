## Problem

`env-loader.ts` fails to load at startup with:

```
ERROR service=plugin path=file:///.../env-loader.ts error=Plugin export is not a function failed to load plugin
```

The plugin uses `export default async function envLoaderPlugin(input: PluginInput)` but the opencode plugin system (per https://opencode.ai/docs/plugins/) expects a **named export** — a `const` or `function` with a specific name, not a `default` export. The loader iterates over module exports looking for named function exports; `export default` is a `default` key on the module, not a named export, so the loader doesn't find it.

## Root Cause

Official docs show the correct pattern:

```typescript
export const MyPlugin = async ({ project, client, $, directory, worktree }) => {
```

Current code uses:

```typescript
export default async function envLoaderPlugin(input: PluginInput): Promise<Hooks> {
```

## Fix

1. Change export from `export default async function envLoaderPlugin(input: PluginInput): Promise<Hooks>` to a named export `export const EnvLoaderPlugin: Plugin = async ({ project, client, $, directory, worktree }) => { ... }`
2. Update the import to include `Plugin` type and remove `PluginInput`:
   - `import type { Hooks, PluginInput } from "@opencode-ai/plugin"` → `import type { Hooks, Plugin } from "@opencode-ai/plugin"`
3. Map context object properties:
   - `input?.directory` → `directory`
   - `input?.worktree` → `worktree`
   - `input.$.nothrow` → `$.nothrow`
4. Preserve all named exports at bottom of file (`parseEnvFile`, `isEnvGitignored`, `writeDiagnostic`, `DIAGNOSTICS_PATH`, `PluginDiagnostic`)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Plugin loads without "Plugin export is not a function" error | behavioral |
| SC-2 | `shell.env` hook injects all env vars (BRANCH_NAME, GIT_OWNER, GIT_REPO, etc.) | behavioral |
| SC-3 | Named exports (`parseEnvFile`, `isEnvGitignored`, `writeDiagnostic`, `DIAGNOSTICS_PATH`, `PluginDiagnostic`) preserved | structural |
| SC-4 | No TypeScript compilation errors | behavioral |

## Labels

`[SPEC-FIX]`, `plugin`
