## Problem

The `session-enforcement.ts` plugin leaks diagnostic output to the terminal display. The `session-init` tool uses `print()` to stdout, which is supposed to be captured by the plugin via `execSync` and injected into the system prompt. However, this output is appearing on the terminal, destroying the display with "Developer:", "Email:", "Git branch:", "project_root:", and "## Repo Information" sections.

This is a regression — the code did not do this before. The plugin has accumulated 968 lines of mixed concerns (hook installation, git config watchdog, secret redaction, skill indexing, frontmatter validation, sub-agent detection, trigger injection, mode-switch stripping) with no clear separation of concerns. The `session-init` tool's stdout-based output mechanism is fundamentally wrong — it should write to a file, not print to stdout.

## Solution

Replace `session-enforcement.ts` with a fresh plugin written from scratch. The new plugin must:

1. **Emit zero output to stdout/stderr** — no `console.log`, `console.error`, `console.warn`, or any other terminal output
2. **Read session-init output from a file** — `session-init` writes to `{project_root}/tmp/session-context.yaml` instead of printing to stdout
3. **Use only the `experimental.chat.system.transform` hook** — inject session context, guidelines index, and skill index into the system prompt
4. **Use only the `experimental.chat.messages.transform` hook** — inject trigger warnings (first-turn only), redact secrets (per-turn)
5. **Use the `event` hook** — detect sub-agent sessions via `session.created`
6. **Do NOT install git hooks** — hook installation is a separate concern, not a plugin responsibility
7. **Do NOT run git config mutation watchdog** — this is a per-turn concern that produces noise, not actionable enforcement
8. **Do NOT load/validate skill frontmatter** — this is a build-time concern, not a runtime plugin concern
9. **Do NOT build skill index** — the skill index is already provided by the opencode runtime via `<available_skills>`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Plugin produces zero output to stdout/stderr during normal operation | `behavioral` | Run `opencode run "hello"` with the plugin loaded; verify no "Developer:", "Email:", "Git branch:", "project_root:", or "## Repo Information" lines appear in terminal output |
| SC-2 | Session context (repo info, project_root, dev name/email) is injected into the system prompt | `behavioral` | Verify system prompt contains `## Repo Information`, `project_root:`, `Developer:`, `Email:` sections |
| SC-3 | Guidelines index is injected into the system prompt | `string` | Verify system prompt contains `### Guidelines Index (Progressive Disclosure)` |
| SC-4 | Trigger warnings are injected into the first user message of primary sessions only | `behavioral` | Verify first user message of primary session contains `### Session Triggers`; verify sub-agent sessions do NOT contain it |
| SC-5 | Secrets are redacted from all assistant messages | `behavioral` | Send a message containing a secret pattern; verify the assistant response has it redacted |
| SC-6 | Sub-agent sessions are detected and first-turn injections are skipped | `behavioral` | Verify sub-agent sessions do not receive first-turn trigger injections |
| SC-7 | `session-init` writes to a temp file, not stdout | `string` | Verify `session-init` has no `print()` calls for context output; verify it writes to `{project_root}/tmp/session-context.yaml` |
| SC-8 | Plugin does NOT install git hooks | `string` | Verify no hook installation code exists in the plugin |
| SC-9 | Plugin does NOT run git config mutation watchdog | `string` | Verify no git config comparison code exists in the plugin |
| SC-10 | Plugin does NOT load/validate skill frontmatter | `string` | Verify no `loadSkillDescriptions` or `extractFrontmatter` code exists in the plugin |
| SC-11 | Plugin does NOT build skill index | `string` | Verify no `buildSkillIndex` or `extractTriggerPatterns` code exists in the plugin |

## Affected Files

- `.opencode/plugins/session-enforcement.ts` — replace entirely
- `.opencode/tools/session-init` — change output mechanism from `print()` to file write

## Non-Goals

- Do NOT modify `env-loader.ts` — that plugin is a separate concern
- Do NOT modify any skill files, guideline files, or test files
- Do NOT modify hook scripts in `.opencode/hooks/`

## Implementation Notes

The new plugin should be a single file under 300 lines. The `session-init` tool should write its output to `{project_root}/tmp/session-context.yaml` (or similar), and the plugin should read that file in the `system.transform` hook. If the file doesn't exist (first run), the plugin should run `session-init` once to generate it.

The `session-init` tool's `print()` calls should be replaced with YAML file writes. The plugin reads the YAML file and injects it into the system prompt. This eliminates all terminal output from the session-init pipeline.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
