# [PLAN] Inject tool listing into agent context via session-init

**Issue**: #1038 — [SPEC] Inject tool listing into agent context via session-init instead of default.txt
**Status**: DRAFT
**Authorization scope**: `for_pr`

---

## SC-to-Item Mapping

| SC | Evidence Type | Item | Description | Verification |
|----|--------------|------|-------------|-------------|
| SC-1 | `string` | A | session-init stdout contains `## Agent Tools` section with tool listing | `grep -A 30 '## Agent Tools'` on session-init output |
| SC-2 | `behavioral` | C | Agent answers tool-preference question using specific tool names from injected listing | `behavior_run` with prompt "what tools are preferred to grep, cat, find, sed" |
| SC-3 | `string` | B | Content-verification assertion in test-enforcement.sh | `--scenario session-init-tools-section` |

## Dependency Order

Item A must complete before B. Item C depends on A's behavioral effect at runtime (test script itself is independent).

## Items

### Item A: Add `## Agent Tools` emission to session-init (SC-1, SC-3)

**File**: `.opencode/tools/session-init`

**What must be achieved**: `session-init` stdout must contain a `## Agent Tools` section after `## Repo Information` with the output of `./.opencode/tools/help`.

RED:
- Verify session-init currently has no `## Agent Tools` section: `./.opencode/tools/session-init 2>/dev/null | grep -q '## Agent Tools'` → expect exit 1
- If section unexpectedly exists: HALT — branch is contaminated

GREEN:
- Add a function that runs `./.opencode/tools/help` and returns its output
- Emit the output in a `## Agent Tools` section from `main()` after `## Repo Information`
- Handle errors gracefully (return empty string, print warning to stderr, never crash session-init)
- Path resolution must work from any CWD (resolve relative to script location or project root)

VERIFY:
- `./.opencode/tools/session-init 2>/dev/null | grep -A 30 '## Agent Tools'` → shows tool names
- Existing output sections (Developer, Email, Git branch, ## Repo Information) are intact
- `uvx ruff check --fix` and `uvx pyright` pass

REMEDIATION (2 attempts max, then HALT):
- If section missing: check help tool path, subprocess error, stdio interference
- If existing output corrupted: revert and re-attempt with smaller change

### Item B: Add content-verification test (SC-3)

**File**: `.opencode/tests/test-enforcement.sh`

**What must be achieved**: A content-verification scenario `session-init-tools-section` that greps session-init output for the `## Agent Tools` section.

RED:
- `grep 'session-init-tools-section' .opencode/tests/test-enforcement.sh` → expect 0 matches
- If already registered: HALT — branch is contaminated

GREEN:
- Register `session-init-tools-section` in SCENARIOS, SCENARIO_TAGS, and FILE_SCENARIO_MAP for `tools/session-init`

VERIFY:
- `grep 'session-init-tools-section' .opencode/tests/test-enforcement.sh` → 2+ matches (SCENARIO + FILE_SCENARIO_MAP)

### Item C: Behavioral test for SC-2 (SC-2)

**File**: `.opencode/tests/behaviors/tool-injection-red.sh`

**What must be achieved**: An artifact-only behavioral test script exists that sends the prompt "what tools are preferred to grep, cat, find, sed".

GREEN:
- Ensure `tool-injection-red.sh` exists with the correct SCENARIO_PROMPT
- Script must be an artifact-only generator (no assertions, exit 0)

VERIFY:
- `grep 'SCENARIO_PROMPT' .opencode/tests/behaviors/tool-injection-red.sh` → contains "what tools are preferred to grep, cat, find, sed"
- Script has SPDX header, cross-reference header, sources helpers.sh, calls behavior_run, exits 0

## Final Verification Checklist

- [ ] SC-1: `./.opencode/tools/session-init 2>/dev/null | grep -q '## Agent Tools'` → exit 0
- [ ] SC-2: Behavioral test artifacts generated; stdout evaluated for `.opencode/tools/*` names
- [ ] SC-3: `bash .opencode/tests/test-enforcement.sh --scenario session-init-tools-section` → PASS
- [ ] Lint: `uvx ruff check --fix .opencode/tools/session-init` → clean
- [ ] Typecheck: `uvx pyright .opencode/tools/session-init` → clean

## Final COMMIT

Single commit on `feature/1038-session-init-tools` containing all three items.