## Problem

The TS plugins (`session-enforcement.ts`, `env-loader.ts`) and `session-init` emit diagnostic output to stderr and to a file-based diagnostic pipeline (`writeDiagnostic` → `.opencode/tmp/plugin-diagnostics.jsonl`). This output is:

1. **Invisible** — stderr is not surfaced in the chat UI, so the information is lost
2. **Noise** — hook installation counts, submodule context detection, srclight index status, git timeouts, `.env` gitignore warnings — all conditions the code already handles gracefully
3. **Redundant** — `writeDiagnostic` writes to a file nobody reads, then `collectDiagnostics` reads it back and injects it into the system prompt as a "Plugin Diagnostics" block that the agent must process every session

The `ENV_LOADER_SECURITY_WARNING` env var pollutes every shell session with a 120-character warning string.

## Solution

Remove all diagnostic output that is not actionable. The code handles every edge case gracefully — there is no need to log them.

### Removals

#### `plugins/session-enforcement.ts`

| What | Why |
|------|-----|
| 5 `console.error`/`console.warn` calls | Invisible to user, conditions handled gracefully |
| `writeDiagnostic()` function + `PluginDiagnostic` interface + `DIAGNOSTICS_PATH` constant | File-based diagnostic pipeline — nobody reads the file |
| `collectDiagnostics()` function | Reads back the file nobody writes to anymore |
| `buildDiagnosticBlock()` function | Injects diagnostic block into system prompt — noise |
| 8 `writeDiagnostic()` call sites | All conditions handled gracefully by the code |
| Diagnostic injection block in first-turn message | Injects noise into every session |

#### `plugins/env-loader.ts`

| What | Why |
|------|-----|
| 2 `console.error` calls | Invisible, conditions handled gracefully |
| `writeDiagnostic()` function + `PluginDiagnostic` interface + `DIAGNOSTICS_PATH` constant | File-based diagnostic pipeline |
| 2 `writeDiagnostic()` call sites | `.env` gitignore warning + parse warnings — handled by env var or silently |
| `isEnvGitignored()` function | Dead code — only caller was the removed `writeDiagnostic` |
| `ENV_LOADER_SECURITY_WARNING` env var injection | Pollutes every shell session with warning string |

#### `tools/session-init`

| What | Why |
|------|-----|
| `print(file=sys.stderr)` for hook install counts | Informational, not actionable |
| `print(file=sys.stderr)` for hook failure per-repo | Handled gracefully — hooks are best-effort |
| `print(file=sys.stderr)` for submodule context | Code handles both paths |
| `print(file=sys.stderr)` for srclight status | Agent can check srclight itself if needed |
| `print(file=sys.stderr)` for git timeout | `run_git_command` returns `None` — caller handles it |
| `print(file=sys.stderr)` for legacy hooksPath removal | One-time migration message, no longer relevant |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `session-enforcement.ts` has zero `console.error`/`console.warn`/`console.log` calls | `string` | `grep` for `console\.(error\|warn\|log)` in file |
| SC-2 | `session-enforcement.ts` has zero `writeDiagnostic` calls | `string` | `grep` for `writeDiagnostic` in file |
| SC-3 | `session-enforcement.ts` has no `collectDiagnostics` or `buildDiagnosticBlock` functions | `string` | `grep` for function names in file |
| SC-4 | `session-enforcement.ts` has no diagnostic injection block in first-turn message | `string` | `grep` for `diagnostic` in file (only comment remains) |
| SC-5 | `env-loader.ts` has zero `console.error`/`console.warn`/`console.log` calls | `string` | `grep` for `console\.(error\|warn\|log)` in file |
| SC-6 | `env-loader.ts` has zero `writeDiagnostic` calls | `string` | `grep` for `writeDiagnostic` in file |
| SC-7 | `env-loader.ts` has no `isEnvGitignored` function | `string` | `grep` for `isEnvGitignored` in file |
| SC-8 | `env-loader.ts` has no `ENV_LOADER_SECURITY_WARNING` string | `string` | `grep` for `ENV_LOADER_SECURITY_WARNING` in file |
| SC-9 | `session-init` has zero `print(file=sys.stderr)` calls | `string` | `grep` for `file=sys.stderr` in file |
| SC-10 | All 15 behavioral enforcement tests still PASS | `behavioral` | Run `test-enforcement.sh` for all scenarios |
| SC-11 | TypeScript compiles without errors | `structural` | `tsc --noEmit` (if tsc available) |

## Affected Files

- `.opencode/plugins/session-enforcement.ts`
- `.opencode/plugins/env-loader.ts`
- `.opencode/tools/session-init`

## Risks

- **None.** All removed output was informational/diagnostic. The code handles every edge case gracefully without it. The `writeDiagnostic` file was never read by any consumer — it was written, then read back by `collectDiagnostics` in the same plugin, then injected into the system prompt. No external consumer depends on it.

## Change Control

2026-07-16: Initial spec.
