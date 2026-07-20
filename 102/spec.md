## Problem

When an AI agent invokes a PEP 723 Python script via `bash <script>` instead of `uv run --script <script>`, bash interprets the Python code as shell commands. For scripts using Playwright (e.g., `render_html_screenshot.py`), this accidentally triggers screenshot capture. ~70 PEP 723 scripts across `.opencode/tools/`, `.opencode/skills/*/scripts/`, and `.opencode/tests/` are affected.

Git history confirms the polyglot bash guard pattern (`"exit" "1"`) has never existed in any committed version — 1501 commits searched across both repos.

## Fix Approach

### Phase 1: Mandate

Add the bash guard to `.opencode/guidelines/070-environment.md` (or equivalent) requiring all PEP 723 scripts in `.opencode/` to include the polyglot header.

### Phase 2: Remediation

Add the following header to every PEP 723 script in `.opencode/`:

```
""":" 
"echo" "Not a bash script. Use ./$0"
"exit" "1"
"""
```

Insert between the shebang line (`#!/usr/bin/env -S uv run --script`) and the `# /// script` metadata block. For scripts with no shebang (6 in `skills/ui-design/scripts/`), prepend the guard before the existing `# /// script` block.

### Success Criteria

| SC | Description |
|----|------------|
| SC-1 | Guideline mandates bash guard for all PEP 723 scripts |
| SC-2 | All `.opencode/tools/` PEP 723 scripts have the guard |
| SC-3 | All `.opencode/skills/*/scripts/*.py` PEP 723 scripts have the guard |
| SC-4 | All `.opencode/tests/` PEP 723 scripts have the guard |
| SC-5 | Scripts with `#!/usr/bin/env -S uv run --script` shebang retain it — guard sits between shebang and `# /// script` |
| SC-6 | Scripts with no shebang have guard prepended before `# /// script` |
| SC-7 | `bash <script>` on any guarded script prints error and exits 1 |
| SC-8 | `uv run --script <script>` on any guarded script works normally |

### Affected Files

~70+ PEP 723 scripts in `.opencode/` (submodule `michael-conrad/.opencode`):

- `.opencode/tools/*` — ~20 extensionless entry points
- `.opencode/tools/impl/*` — ~20 extensionless dispatchers
- `.opencode/skills/*/scripts/*.py` — ~20 scripts (6 with no shebang)
- `.opencode/tests/regressions/*.py` — ~10 regression tests

### Non-Goals

- Native bash scripts (`.sh`, `detect-secrets-wrapper.sh`, `ensure-node`, `ollama-probe`, `resolve-models`, `ollama-model-resolve`) are NOT changed
- No shebang replacement — guard is additive
- No changes to Python logic inside scripts

## Guard Pattern

```
#!/usr/bin/env -S uv run --script
""":" 
"echo" "Not a bash script. Use ./$0"
"exit" "1"
"""
# /// script
```

The two-string form (`"echo" "..."`, `"exit" "1"`) is valid as shell commands AND as adjacent Python string concatenation inside the `""":"`...`"""` docstring block. `$0` resolves to the script path under bash. The shebang is preserved for `./script` invocation.

---

Co-authored with AI: OpenCode (deepseek-v4-flash)