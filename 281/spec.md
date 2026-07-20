## Problem

The `session-init` script (`/.opencode/tools/session-init`) currently injects developer identity, repo info, and agent tools listing into the system prompt. It does NOT report whether the `gh` (GitHub CLI) or `gb` (GitBucket CLI) tools are installed and authenticated. Agents working in multi-platform environments (GitHub + GitBucket) have no visibility into CLI auth status at session start.

## Scope

**In scope:**
- Add `check_cli_auth_status()` function to session-init that checks `gh` and `gb` installation + auth status
- Inject `[CLI]` section into session-init output after `## Repo Information`
- Both CLIs checked in a single function call (atomic section)
- Short timeouts (5s) to avoid hanging on credential prompts
- Parse and redact sensitive values — only emit status (logged in / not logged in / not installed)

**Out of scope:**
- Adding new CLI tools beyond `gh` and `gb`
- Modifying `session-enforcement.ts` (it passes stdout verbatim)
- Adding auth prompts, credential management, or token refresh logic
- Adding `gh`/`gb` to agent tools listing
- Supporting other Git platforms (Bitbucket, Gitea, etc.)

## Approach

1. Add `check_cli_auth_status()` function to `.opencode/tools/session-init` following the existing `check_srclight()` pattern
2. For each CLI (`gh`, `gb`):
   - Check if binary exists via `shutil.which()`
   - If installed, run `auth status` with short timeout (5s) and non-interactive flags
   - Parse output for logged-in/not-logged-in status
   - Redact any sensitive values (tokens, emails, tokens)
   - Return structured status string
3. Call from `main()` and print `[CLI]` section after `## Repo Information`
4. Update `.opencode/AGENTS.md` to document the new section
5. Add behavioral enforcement tests

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `check_cli_auth_status()` exists in session-init | `structural` | grep for function definition |
| SC-2 | `gh` auth status is checked with short timeout | `string` | grep for `gh auth status` in function |
| SC-3 | `gb` auth status is checked with short timeout | `string` | grep for `gb auth status` in function |
| SC-4 | Output section `[CLI]` is emitted after `## Repo Information` | `string` | grep for section in output |
| SC-5 | Sensitive values (tokens, emails) are redacted — only status emitted | `behavioral` | `opencode-cli run` with mock CLI that emits token |
| SC-6 | Uninstalled CLI reported as `not_installed` — no error | `behavioral` | `opencode-cli run` with `gh`/`gb` absent from PATH |
| SC-7 | Not-logged-in CLI reported as `not_logged_in` — no error | `behavioral` | `opencode-cli run` with mock CLI that exits non-zero |
| SC-8 | Logged-in CLI reported as `logged_in` | `behavioral` | `opencode-cli run` with mock CLI that exits 0 |
| SC-9 | AGENTS.md documents the new `[CLI]` section | `string` | grep for section in AGENTS.md |
| SC-10 | Behavioral test added to `.opencode/tests/` | `structural` | ls for test file |

## Implementation Approach

1. Read `.opencode/tools/session-init` — locate `check_srclight()` as pattern reference
2. Add `check_cli_auth_status()` function after `check_srclight()`
3. Add function call in `main()` after `check_srclight()` call
4. Add `[CLI]` section print after `## Repo Information` section
5. Update `.opencode/AGENTS.md` with new section documentation
6. Add behavioral test in `.opencode/tests/behaviors/`
7. Run `uv run pytest test/` to verify no regressions

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `gh auth status` hangs on credential prompt | Session start hangs | 5s timeout, `--no-interactive` flag |
| `gb auth status` hangs on credential prompt | Session start hangs | 5s timeout, `--no-interactive` flag |
| Token leaked in session-init output | Secret exfiltration | Parse output, redact tokens/emails, only emit status |
| session-init runs on every session start | Performance impact | Both CLIs checked in <1s with timeouts; negligible overhead |
| `gh`/`gb` not installed | Unnecessary noise | Detect via `shutil.which()`, skip silently if absent |

## Test Plan

**Behavioral tests (`.opencode/tests/behaviors/`):**
1. `cli-auth-status-check.sh`: Mock `gh` and `gb` with controlled outputs, verify session-init emits correct status strings
2. `cli-auth-status-redaction.sh`: Mock CLI that emits token in output, verify redaction
3. `cli-auth-status-not-installed.sh`: Remove `gh`/`gb` from PATH, verify graceful handling

**Content-verification tests:**
- Add to `test-enforcement.sh` scenario: verify `[CLI]` section present in session-init output

**Manual verification:**
- Run `./.opencode/tools/session-init` and confirm `[CLI]` section appears after `## Repo Information`
- Verify no sensitive data leaked in output