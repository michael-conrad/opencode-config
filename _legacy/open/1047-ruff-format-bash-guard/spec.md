---
remote_issue: 1047
remote_url: https://github.com/michael-conrad/.opencode/issues/1047
promoted_at: "2026-06-06T18:27:08Z"
title: "[BUG] ruff format mangles bash guard in PEP 723 scripts — 49/51 scripts unprotected"
labels: [bug, P0-critical]
status: open
---

## Problem

ruff's formatter (`ruff format`) destroys the bash guard line in PEP 723 inline-script metadata scripts. The bash guard — `"exec" "uv" "run" "--script" "$0" "$@"` — is shell syntax where each quoted token must remain separately quoted for `sh` to process as argv elements. ruff treats these as Python string literals and collapses them to `"execuvrun--script$0$@"`, destroying script execution.

## Scope

- 51 PEP 723 scripts exist under `.opencode/` (tools/, tools/impl/, tests/, scripts/, skills/*/scripts/)
- Only 2 have `# fmt: off` / `# fmt: on` guards: `.opencode/tools/plan` and `.opencode/tools/solve`
- 49 scripts are unprotected and WILL lose their bash guard on the next `ruff format` run
- Confirmed via `ruff format --diff` on `.opencode/tools/help` — the diff shows the collapse

## Impact

Without the bash guard, the scripts become non-functional. `uv run --script` never executes because the shell guard is broken. Every unfixed script is one `ruff format` invocation away from being broken.

## Repair needed

Every PEP 723 script with a bash guard needs:
1. `# fmt: off` inserted before the bash guard line
2. `# fmt: on` inserted after the PEP 723 `# ///` closing line

🤖 OpenCode (deepseek-v4-flash) created