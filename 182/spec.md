## Intent

Fix the broken `help` tool description extraction and establish a self-describing `--description` contract for every executable in `.opencode/tools/`, then anchor that contract in the PEP 723 tool conventions documentation and enforcement tests.

## Background

### Bug: `help` shows "(no description)" for every tool

`.opencode/tools/help` uses `ast.get_docstring()` to extract descriptions from tool files. Every PEP 723 script starts with a polyglot bash guard:

```python
"exec" "uv" "run" "--script" "$0" "$@"  # MUST GO BEFORE PEP 723 HEADER
```

`ast.get_docstring()` returns the module's first bare string expression — which is the bash guard (`"execuvrun--script$0$@"`), not the actual `__doc__` assignment. Since this string doesn't contain `DESCRIPTION:`, every tool falls through to `"(no description)"`.

Many tools DO have `DESCRIPTION:` in their `__doc__` — but the help parser never reaches it.

### The fix should establish a durable contract

Fixing the parser is a patch. The right fix is to make each tool self-describe via a `--description` flag, and have `help` call `./.opencode/tools/<tool> --description` as a subprocess. This moves the description knowledge to the tool itself — the tool owns its identity, and the aggregator just asks.

This contract should then be documented as a mandatory convention for any custom tool added to `.opencode/tools/`, alongside the existing PEP 723, bash guard, and `# fmt: off`/`# fmt: on` requirements.

## Scope

Five work items, no sub-issues:

| # | Item | Description |
|---|------|-------------|
| 1 | Fix `.opencode/tools/help` | Replace AST docstring parsing with subprocess `--description` calls. |
| 2 | Add `--description` to every PEP 723 Python tool | All PEP 723 scripts in `.opencode/tools/` that already have `DESCRIPTION:` in their `__doc__`. |
| 3 | Add `--description` + `DESCRIPTION:` to tools missing it | Python scripts with no `DESCRIPTION:`, and bash scripts with no description mechanism at all. |
| 4 | Convert `session-to-timeline` to PEP 723 standard | Currently uses `#!/usr/bin/env python3` with no PEP 723 header. Must be converted to match the mandated format. |
| 5 | Update `.opencode/guidelines/070-environment.md` | Add `--description` flag requirement to the PEP 723 Self-Contained Scripts section. |
| 6 | Update `.opencode/tests/test-pep723-tools.sh` | Add a `check_description_flag` check for PEP 723 entry points. |

## Item Details

### Item 1: Fix `help` — replace AST parsing with subprocess dispatch

`get_description()` in `.opencode/tools/help` currently reads each file, parses it as Python AST, extracts docstring, searches for `DESCRIPTION:`. This is fragile and broken.

Replace with:

```python
def get_description(script: Path) -> str:
    """Get tool description by calling <tool> --description."""
    try:
        result = subprocess.run(
            [str(script.absolute()), "--description"],
            capture_output=True, text=True, check=False,
            stdin=subprocess.DEVNULL, timeout=5,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except (subprocess.SubprocessError, OSError, TimeoutError):
        pass
    return "(no description available)"
```

Changes to `help`:
- Remove `import ast`
- Replace `get_description()` with subprocess version
- The rest of `main()` stays the same

### Item 2: Add `--description` to PEP 723 tools that already have `DESCRIPTION:`

Add to each tool's `main()` or early argument check:

```python
if len(sys.argv) == 2 and sys.argv[1] == "--description":
    print("<one-line description>")
    return 0
```

Affected tools (have `DESCRIPTION:` — minimal change):

| Tool | Description |
|------|-------------|
| `help` | `List all agent tools in .opencode/tools/ with their descriptions.` |
| `file-exists` | `Check whether one or more file/directory paths exist.` |
| `guidelines` | `Guidelines tools dispatcher.` |
| `gitbucket-api` | `GitBucket API CLI client.` |
| `py` | `Python source tools dispatcher.` |
| `md` | `Markdown tools dispatcher.` |
| `jupyter` | `Jupyter server tools dispatcher.` |
| `jupyter-start` | `Start Jupyter server on port 18888.` |
| `jupyter-stop` | `Stop the Jupyter server running on port 18888.` |
| `skildeck` | `Skill deck formal analysis CLI.` |
| `schema-version` | `Print current UTC datetime as YYYYMMDDHHMMSS.` |

### Item 3: Add `--description` + `DESCRIPTION:` to tools missing it

#### Python PEP 723 tools (no `DESCRIPTION:` — add description + flag)

| Tool | Description |
|------|-------------|
| `session-init` | `Session initialization script for AI agents.` |
| `solve` | `Z3 constraint solver for workflow correctness.` |
| `plan` | `AI planning tool wrapping unified-planning.` |
| `local-issues` | `Local issue tracking CLI tool for .issues/ directory.` |

These have prose `__doc__` but no `DESCRIPTION:` prefix. The `--description` flag doesn't need the `DESCRIPTION:` convention — it just needs a string literal — but updating `__doc__` to include `DESCRIPTION:` for consistency is recommended.

#### Bash scripts (no `--description` mechanism at all)

| Tool | Description (from top comment) |
|------|-------------------------------|
| `ollama-probe` | `Probe Ollama server capabilities.` |
| `resolve-models` | `Select 2 auditors from different families for adversarial audit.` |
| `ensure-node` | `Ensure Node.js toolchain is available in .opencode/.node/.` |
| `detect-secrets-wrapper.sh` | `Wrapper for detect-secrets pre-commit hook.` |

Each needs a `--description` case block near the top, before `set -euo pipefail` or immediately after it, before substantive logic:

```bash
if [[ "${1:-}" == "--description" ]]; then
    echo "Probe Ollama server capabilities."
    exit 0
fi
```

### Item 4: Convert `session-to-timeline` to PEP 723 standard

`session-to-timeline` currently has:

```python
#!/usr/bin/env python3
"""
session-to-timeline — Extract structured tool call timeline...
"""
```

This violates the `.opencode/guidelines/070-environment.md` mandate that all tools in `.opencode/tools/` be self-contained PEP 723 scripts. It must be converted to:

```python
#!/usr/bin/env -S uv run --script
# fmt: off
"exec" "uv" "run" "--script" "$0" "$@"  # MUST GO BEFORE PEP 723 HEADER

# PEP 723 HEADER MUST BE AFTER BASH GUARD
# /// script
# requires-python = "~=3.12"
# dependencies = []
# ///

# fmt: on
__doc__ = """DESCRIPTION: Extract structured tool call timeline from behavioral test session.yaml.
...
"""
```

Changes needed:
- Replace `#!/usr/bin/env python3` with PEP 723 shebang
- Add bash guard
- Add `# fmt: off` / `# fmt: on` blocks
- Add PEP 723 metadata block (`requires-python`, `dependencies`)
- Add `DESCRIPTION:` prefix to `__doc__`
- Add `--description` flag check in `main()`
- Rest of code stays unchanged

### Item 5: Update guideline documentation

Modify `.opencode/guidelines/070-environment.md` section "PEP 723 Self-Contained Scripts (MANDATORY)" to add a new subsection after the existing `# fmt: off`/`# fmt: on` rules:

```
### --description Flag (MANDATORY)

Every tool in `.opencode/tools/` MUST implement a `--description` flag that prints a one-line description of the tool's purpose to stdout and exits 0. This allows the `help` tool and other aggregators to discover tool descriptions without parsing source code.

For PEP 723 Python scripts (top of `main()`):

```python
if len(sys.argv) == 2 and sys.argv[1] == "--description":
    print("One-line description of the tool's purpose.")
    return 0
```

For bash scripts (top of script, before substantive logic):

```bash
if [[ "${1:-}" == "--description" ]]; then
    echo "One-line description of the tool's purpose."
    exit 0
fi
```

The description should be a single sentence stating what the tool does from the caller's perspective ("does X") rather than describing its implementation ("uses Y to do X").
```

### Item 6: Add enforcement test

Modify `.opencode/tests/test-pep723-tools.sh` to add a `check_description_flag` function that runs each entry point with `--description` and verifies exit code 0 and non-empty stdout. Add this to the main check loop over `ENTRY_POINTS`.

## Success Criteria

### SC-1: `help` tool descriptions are populated

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | Run `./.opencode/tools/help` — every tool line shows a description, none show "(no description)" or "(no description available)". |

### SC-2: `help` fallback on subprocess failure

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | Point `help` at a non-existent tool path or one that fails `--description` — output shows "(no description available)" for that tool. |

### SC-3: Every tool responds to `--description`

| | |
|---|---|
| **Evidence Type** | string |
| **Verification** | For each file in `.opencode/tools/` (excluding `impl/`, `__pycache__`, directories): `<tool> --description` exits 0 with non-empty stdout. |

### SC-4: `session-to-timeline` is PEP 723

| | |
|---|---|
| **Evidence Type** | string |
| **Verification** | `head -1 .opencode/tools/session-to-timeline` shows PEP 723 shebang. `grep '^# /// script$' .opencode/tools/session-to-timeline` exists. `./.opencode/tools/session-to-timeline --description` exits 0. |

### SC-5: Guideline updated

| | |
|---|---|
| **Evidence Type** | string |
| **Verification** | grep for `--description` in `.opencode/guidelines/070-environment.md` — the `--description` Flag (MANDATORY) section exists. |

### SC-6: Enforcement test passes

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | Run `bash .opencode/tests/test-pep723-tools.sh` — includes `check_description_flag` check that runs each entry point with `--description` and validates exit code + non-empty output. Test passes. |

### SC-7: No regression — existing checks still pass

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | Run `bash .opencode/tests/test-pep723-tools.sh` — same count of PASS results as before the change (structure preserved, only `check_description_flag` added). |

## Status

DRAFT

## Labels

- `spec`
