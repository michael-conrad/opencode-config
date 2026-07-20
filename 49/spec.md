# [SPEC-FIX] Plugin export pattern: env-loader.ts fails to load

## Problem Statement

The `env-loader.ts` plugin fails to load at opencode startup with error:

```
Plugin export is not a function
```

This prevents environment variables from `.env` files from being read and injected into shell sessions, breaking the plugin's core functionality.

## Root Cause Analysis

**Working export pattern (session-enforcement.ts:834):**
```typescript
export default async function sessionEnforcementPlugin(input: PluginInput): Promise<Hooks> {
```

**Failing export pattern (env-loader.ts:216, 339):**
```typescript
export async function EnvLoaderPlugin(input: PluginInput): Promise<Hooks> {
    // ...
}
export default EnvLoaderPlugin;
```

The `env-loader.ts` plugin separates the named export from the default export reference, while the working `session-enforcement.ts` declares the async function **directly** as the default export. The opencode plugin loader expects `export default` to be the function itself, not a reference to a named function.

## Proposed Fix

### Files to Modify

| File | Lines | Change |
|------|-------|--------|
| `.opencode/plugins/env-loader.ts` | 216 | Change `export async function EnvLoaderPlugin` to `export default async function envLoaderPlugin` |
| `.opencode/plugins/env-loader.ts` | 339 | Remove `export default EnvLoaderPlugin;` (no longer needed) |
| `.opencode/plugins/env-loader.ts` | 340-341 | Keep unchanged (named exports for utilities remain accessible) |

### Implementation Details

1. **Line 216:** Convert to direct default export
   ```typescript
   // Before
   export async function EnvLoaderPlugin(input: PluginInput): Promise<Hooks> {

   // After
   export default async function envLoaderPlugin(input: PluginInput): Promise<Hooks> {
   ```

2. **Line 339:** Remove redundant default export
   ```typescript
   // DELETE this line
   export default EnvLoaderPlugin;
   ```

3. **Lines 340-341:** Preserve utility exports
   ```typescript
   // Keep these - named exports for utilities
   export { parseEnvFile, isEnvGitignored, getEnvFilePaths, getGitRemoteUrl };
   ```

## Success Criteria

- [ ] Plugin loads without error at opencode startup
- [ ] Environment variables from `.env` are read and injected into shell sessions
- [ ] Git remote parsing continues to work (`getGitRemoteUrl()` utility)
- [ ] Named exports (`parseEnvFile`, `isEnvGitignored`, etc.) remain accessible for testing
- [ ] No TypeScript compilation errors

## Verification

| Check | Command | Expected Result |
|-------|---------|-----------------|
| Plugin loads | `opencode --version` | No "Plugin export is not a function" error |
| Env vars read | Create `.env` with `TEST_VAR=value`, run opencode | `TEST_VAR` available in shell |
| Named exports | `import { parseEnvFile } from './env-loader'` (test file) | No import error |

## Files Referenced

- `.opencode/plugins/env-loader.ts` — the affected plugin
- `.opencode/plugins/session-enforcement.ts` — reference working pattern
- `.opencode/node_modules/@opencode-ai/plugin/dist/index.d.ts` — Plugin type definition (line 51: `export type Plugin = (input: PluginInput, options?: PluginOptions) => Promise<Hooks>;`)

## Priority

High — plugin fails to load entirely, blocking all env-file functionality

## Labels

- SPEC-FIX
- bug
- plugin

---

🤖 OpenCode (ollama-cloud/glm-5) created