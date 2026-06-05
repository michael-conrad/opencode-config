# [PLAN] Inject tool listing into agent context via session-init

**Issue**: #1038 — [SPEC] Inject tool listing into agent context via session-init instead of default.txt  
**Status**: DRAFT  
**Authorization scope**: `for_pr` (label: `approved-for-pr`)

---

## SC-to-Item Mapping

| SC | Evidence Type | Item | Description | Verification |
|----|--------------|------|-------------|-------------|
| SC-1 | `string` | A | session-init stdout contains `## Agent Tools` section with tool listing | `grep -A 30 '## Agent Tools'` on session-init output |
| SC-2 | `behavioral` | C | Agent answers tool-preference question using specific tool names from injected listing | `behavior_run` → orchestrator evaluates stdlog for `.opencode/tools/*` names |
| SC-3 | `string` | B | Content-verification assertion in test-enforcement.sh | `--scenario session-init-tools-section` |

## Dependency Order

```
Item A (session-init change) ──────────┬── Item B (content-verification test)
                                       └── Item C (behavioral test, also depends on B)
```

Item A MUST be complete before Item B or Item C can pass verification. Item B MUST be complete before Item C's content-verification can be confirmed.

## Files Touched

| File | Item | Action |
|------|------|--------|
| `.opencode/tools/session-init` | A | Add `get_agent_tools_help()` function + emit block in `main()` |
| `.opencode/tests/test-enforcement.sh` | B | Add `session-init-tools-section` SCENARIO, tag, and FILE_SCENARIO_MAP entry |
| `.opencode/tests/behaviors/tool-injection-red.sh` | C | Add behavioral test script (artifact-only generator) |

---

## Item A: Add `## Agent Tools` emission to session-init (SC-1, SC-3)

### A.1: RED — Verify session-init lacks `## Agent Tools` section

**File**: `.opencode/tools/session-init`

**Verification command**:
```bash
./.opencode/tools/session-init 2>/dev/null | grep -A 30 '## Agent Tools'
```

**Expected result**: No output (section does not exist).

**Evidence file**: `./tmp/red-sc1-session-init-no-tools.txt`

**Remediation**: If grep finds the section unexpectedly, section already exists — skip RED, mark A.1 as BYPASSED, proceed to A.2 REFACTOR (verify formatting and completeness).

### A.2: GREEN — Add `get_agent_tools_help()` function

**File**: `.opencode/tools/session-init`

#### Sub-task A.2.1: Add `get_agent_tools_help()` function

Insert before `main()` (after line 664). Function resolves `.opencode/tools/help` relative to `PROJECT_ROOT`, runs it via `subprocess.run`, returns output string on success or empty string on failure.

```python
def get_agent_tools_help() -> str:
    """Run .opencode/tools/help and return its output, or empty string on failure."""
    tools_help = os.path.join(PROJECT_ROOT, ".opencode", "tools", "help")
    if not os.path.isfile(tools_help):
        print(f"WARNING: tools/help not found at {tools_help}", file=sys.stderr)
        return ""
    try:
        result = subprocess.run(
            ["uv", "run", "--script", tools_help],
            capture_output=True,
            text=True,
            check=False,
            stdin=subprocess.DEVNULL,
            timeout=GIT_TIMEOUT,
        )
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            print(f"WARNING: tools/help exited with code {result.returncode}", file=sys.stderr)
            return ""
    except subprocess.TimeoutExpired:
        print("WARNING: tools/help timed out", file=sys.stderr)
        return ""
    except (subprocess.SubprocessError, OSError) as e:
        print(f"WARNING: tools/help failed: {e}", file=sys.stderr)
        return ""
```

#### Sub-task A.2.2: Call from `main()` after Repo Information section

In `main()`, after the `for entry in repo_info:` loop (after line 716):

```python
    # Emit ## Agent Tools section
    tools_output = get_agent_tools_help()
    if tools_output:
        print()
        print("## Agent Tools")
        print("```")
        print(tools_output)
        print("```")
```

#### Sub-task A.2.3: Verify output format

**Verification command**:
```bash
./.opencode/tools/session-init 2>/dev/null
```

**Expected result**: `## Agent Tools` appears after `## Repo Information`, followed by a fenced code block with tool names.

**Evidence file**: `./tmp/green-sc1-session-init-output.txt`

**Remediation**:
1. If no output: check `get_agent_tools_help()` returns non-empty (test in isolation via `python -c "from session-init import get_agent_tools_help; print(get_agent_tools_help())"`)
2. If section appears before Repo Information: move the emit block to correct position
3. If code block is malformed: check triple-backtick formatting

### A.3: REFACTOR — Clean up and verify

**Verification commands**:
```bash
uvx ruff check --fix .opencode/tools/session-init
uvx pyright .opencode/tools/session-init
```

**Expected result**: Both pass without errors.

**Also check**: Read `.opencode/prompts/default.txt` for the existing `## Agent Tools` section — verify it still references the tool approach correctly. No changes needed unless the section there makes conflicting claims.

**Remediation**: If ruff/pyright fails, fix issues and re-run. If default.txt has stale references, update them.

### A.4: COMMIT (Item A only — intermediate commit)

```bash
git add .opencode/tools/session-init
git commit -m "Inject ## Agent Tools section into session-init from tools/help

SC-1: session-init emits tool listing after Repo Information section.
Tool listing is sourced from .opencode/tools/help at startup.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)"
```

### A.5: Verify SC-1 (string)

**Verification command**:
```bash
./.opencode/tools/session-init 2>/dev/null | grep -A 30 '## Agent Tools'
```

**Expected result**: Output contains tool names including `guidelines`, `help`, `md`, `memory`, `ollama-probe`, `py`, `session-init`, `resolve-models`, `detect-secrets-wrapper`.

**Evidence file**: `./tmp/verified-sc1-session-init-tools.txt`

**Remediation protocol**:
1. Run `get_agent_tools_help()` in isolation to verify it returns output
2. Verify `tools/help` exists at `PROJECT_ROOT/.opencode/tools/help`
3. Check fenced code block formatting (must not break agent context parsing)
4. Ensure stderr is not interfering with stdout (use `2>/dev/null`)
5. **After 2 failures**: HALT and report with evidence from each attempt

---

## Item B: Add content-verification SC-3 to test-enforcement.sh (SC-3)

### B.1: RED — Verify assertion doesn't exist

**File**: `.opencode/tests/test-enforcement.sh`

**Verification command**:
```bash
grep -c 'session-init-tools-section' .opencode/tests/test-enforcement.sh
```

**Expected result**: 0 matches (scenario not registered yet).

**Remediation**: If >=1 match found, skip RED — scenario already exists. Verify its assertion matches current spec.

### B.2: GREEN — Add SCENARIOS entry, tag, and FILE_SCENARIO_MAP entry

#### Sub-task B.2.1: Add SCENARIO entry

Add after existing SCENARIOS entries (around line 94):

```bash
SCENARIOS["session-init-tools-section"]="Does tools/session-init stdout contain a ## Agent Tools section with a fenced code block listing agent tool names?"
```

#### Sub-task B.2.2: Add SCENARIO_TAGS entry

Add after existing SCENARIO_TAGS entries (around line 310+):

```bash
SCENARIO_TAGS["session-init-tools-section"]="content-verification session-enforcement"
```

#### Sub-task B.2.3: Update FILE_SCENARIO_MAP entry

Update line 526 from:
```
FILE_SCENARIO_MAP[".opencode/tools/session-init"]="identity-echo-validation wrong-api-routing-subfolder-mapping"
```
to:
```
FILE_SCENARIO_MAP[".opencode/tools/session-init"]="identity-echo-validation wrong-api-routing-subfolder-mapping session-init-tools-section"
```

### B.3: Verify SC-3 (string)

**Verification command** (after Item A is complete):
```bash
bash .opencode/tests/test-enforcement.sh --scenario session-init-tools-section
```

**Expected result**: PASS (grep matches `## Agent Tools` in session-init output).

**Evidence file**: `./tmp/verified-sc3-content-verification.log`

**Remediation protocol**:
1. Run `./.opencode/tools/session-init 2>/dev/null | grep -A 30 '## Agent Tools'` directly — does the section exist?
2. If section exists but test fails: check the SCENARIOS question text matches actual output format
3. Check workdir: is test running from correct project root?
4. **After 2 failures**: HALT and report

### B.4: REFACTOR — Verify tag filter consistency

**Verification command**:
```bash
bash .opencode/tests/test-enforcement.sh --tag session-enforcement
```

**Expected result**: All content-verification tests for `session-enforcement` tag pass, including `session-init-tools-section`.

**Remediation**: If any fail, fix before proceeding.

---

## Item C: Behavioral test for SC-2 (SC-2)

### C.1: Create behavioral test script `tool-injection-red.sh`

**File**: `.opencode/tests/behaviors/tool-injection-red.sh`

Content:
```bash
#!/bin/bash
# Behavioral test: tool-injection-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-2: Agent answers tool-preference question using specific tool names from
# injected ## Agent Tools listing in session-init context.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="tool-injection-red"
SCENARIO_PROMPT="what tools are preferred to grep, cat, find, sed"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
```

### C.2: RED — Verify existing prompt produces built-in tool names

**Verification command**:
```bash
bash .opencode/tests/behaviors/tool-injection-red.sh
```

**Expected result**: Artifacts exist at `./tmp/behavioral-evidence-tool-injection-red-GREEN-*/`. Orchestrator evaluates stdout — expected to contain generic built-in tool names (grep, glob, read, edit, write) from training data, NOT `.opencode/tools/*` names.

**Evidence**: Artifact directory with `manifest.yaml`, `stdout.log`, `stderr.log`, `exit_code`, `session.yaml`.

**Remediation**: If timeout, increase `BEHAVIOR_TIMEOUT` or retry with different model:
```bash
BEHAVIOR_MODEL="ollama/other-model:cloud" bash .opencode/tests/behaviors/tool-injection-red.sh
```

### C.3: GREEN — Run behavioral test AFTER Item A + Item B

**Verification command**:
```bash
rm -rf ./tmp/behavioral-evidence-tool-injection-red-*
BEHAVIOR_PHASE=GREEN bash .opencode/tests/behaviors/tool-injection-red.sh
```

**Expected result**: Orchestrator evaluates stdout — expected to contain specific `.opencode/tools/*` entry names (guidelines, py, md, help, session-init, resolve-models, detect-secrets-wrapper, memory, ollama-probe) referenced by the agent when answering the tool-preference question.

**Evidence**: Artifact directory in `./tmp/behavioral-evidence-tool-injection-red-GREEN-*/`.

**Remediation protocol**:
1. Verify session-init emits `## Agent Tools` (SC-1 verification)
2. Check that the test workdir includes `.opencode/tools/` submodule (behavior_run clones it)
3. Check that `default.txt` is wired to include session-init output in agent context
4. Try different model: `BEHAVIOR_MODEL="ollama/other-model:cloud"`
5. Increase timeout: `BEHAVIOR_TIMEOUT=600`
6. **After 2 failures**: HALT and report

### C.4: REFACTOR — Clean up evidence artifacts

```bash
# Remove initial RED artifacts after GREEN confirmed
rm -rf ./tmp/behavioral-evidence-tool-injection-red-GREEN-*
```

Keep only the latest GREEN-phase artifacts for VbC audit cross-validation.

### C.5: Verify SC-2 (behavioral)

**Verification command**:
```bash
BEHAVIOR_PHASE=GREEN bash .opencode/tests/behaviors/tool-injection-red.sh
```

**Expected result**: Orchestrator reads `stdout.log` and `stderr.log` from the artifact directory to evaluate whether the agent referenced `.opencode/tools/*` names (guidelines, py, md, help, session-init, resolve-models, etc.) rather than or in addition to generic built-in tool names.

**Evidence artifacts**: Preserve in `./tmp/behavioral-evidence-tool-injection-red-GREEN-/` for VbC audit cross-validation.

**Remediation protocol** (if agent still names built-in tools):
1. Verify SC-1 passes (section exists in session-init output)
2. Verify section content is readable and complete (not truncated)
3. Verify `default.txt` instructs agent to read session-init output
4. Try different model with better context adherence
5. **After 2 failures**: HALT and report with evidence

---

## Final COMMIT (all items)

```bash
git add .opencode/tools/session-init \
       .opencode/tests/test-enforcement.sh \
       .opencode/tests/behaviors/tool-injection-red.sh
git commit -m "Inject ## Agent Tools via session-init with behavioral + content-verification tests

SC-1: session-init emits tool listing from tools/help at startup
SC-2: behavioral test verifies agent names actual tool entries
SC-3: content-verification grep asserts section presence

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)"
```

## Final Verification Checklist

- [ ] SC-1: `./.opencode/tools/session-init 2>/dev/null | grep -A 30 '## Agent Tools'` — outputs tool names
- [ ] SC-2: Behavioral test `tool-injection-red.sh` generates artifacts; stdout shows agent referencing `.opencode/tools/*` names
- [ ] SC-3: `bash .opencode/tests/test-enforcement.sh --scenario session-init-tools-section` — PASS
- [ ] Content-verification passes: `bash .opencode/tests/test-enforcement.sh --tag session-enforcement` — all PASS
- [ ] Lint passes: `uvx ruff check --fix .opencode/tools/session-init`
- [ ] Type check passes: `uvx pyright .opencode/tools/session-init`