# [PLAN] Inject tool listing into agent context via session-init

**Issue**: #1038 — [SPEC] Inject tool listing into agent context via session-init instead of default.txt
**Status**: DRAFT
**Authorization scope**: `for_pr`

---

## SC-to-Item Mapping

| SC | Evidence Type | Item | Description | Verification |
|----|--------------|------|-------------|-------------|
| SC-1 | `string` | A | session-init stdout contains `## Agent Tools` section with tool listing | `grep -A 30 '## Agent Tools'` on session-init output |
| SC-2 | `behavioral` | C | Agent answers tool-preference question using specific tool names from injected listing | `behavior_run` → evaluator reads stdout for `.opencode/tools/*` names |
| SC-3 | `string` | B | Content-verification assertion in test-enforcement.sh | `--scenario session-init-tools-section` |

## Dependency Order

Item A first (create the section). Item B second (test that the section exists). Item C last (verify agent uses the section).

## Items

### Item A: Add `## Agent Tools` emission to session-init (SC-1, SC-3)

**File**: `.opencode/tools/session-init`

**What must be achieved**: session-init stdout emits `## Agent Tools` section after `## Repo Information` with `./.opencode/tools/help` output.

RED:
- Verify session-init lacks section: `./.opencode/tools/session-init 2>/dev/null | grep -q '## Agent Tools'` → exit 1
- If section exists: HALT — branch contaminated

GREEN:
- Add function to run `./.opencode/tools/help` and return output
- Emit `## Agent Tools` section from `main()` after `## Repo Information`
- On failure: emit section with error message, never silently omit
- Path: resolve relative to `__file__` (existing sentinel pattern)

VERIFY:
- `grep -A 30 '## Agent Tools'` shows tool names
- Developer/Email/Git branch/Repo Information sections intact
- `ruff check --fix` and `pyright` pass

REMEDIATION (2 attempts max, then HALT):
- Missing section: check path resolution, subprocess error
- Existing sections corrupted: revert and re-attempt

### Item B: Add content-verification test (SC-3)

**File**: `.opencode/tests/test-enforcement.sh`

**What must be achieved**: SCENARIOS entry `session-init-tools-section` and FILE_SCENARIO_MAP registration.

RED:
- `grep -c 'session-init-tools-section' .opencode/tests/test-enforcement.sh` → 0
- If already registered: HALT — branch contaminated

GREEN:
- Add SCENARIO entry for `session-init-tools-section`
- Add FILE_SCENARIO_MAP entry for `tools/session-init`

VERIFY:
- `grep -c 'session-init-tools-section' .opencode/tests/test-enforcement.sh` → 2 (SCENARIOS + FILE_SCENARIO_MAP)

### Item C: Behavioral test for SC-2 (SC-2)

**File**: `.opencode/tests/behaviors/tool-injection-red.sh`

**What must be achieved**: Artifact-only behavioral test with prompt "what tools are preferred to grep, cat, find, sed".

RED:
- Verify file exists with current prompt
- If prompt is wrong or file missing: HALT

GREEN:
- File already exists with correct prompt — no changes needed to test script
- The behavioral difference comes from session-init injection (Item A), not test script changes

VERIFY:
- `grep 'SCENARIO_PROMPT' .opencode/tests/behaviors/tool-injection-red.sh` → contains correct prompt
- SPDX header, cross-reference header, helpers.sh sourced, behavior_run called

## Execution Order

1. Item A: RED → GREEN → VERIFY (no commit)
2. Item B: RED → GREEN → VERIFY (no commit)
3. Item C: RED → GREEN → VERIFY (no commit)
4. Single commit containing all changed files

## Final Verification Checklist

- [ ] SC-1: `grep -q '## Agent Tools' <(./.opencode/tools/session-init 2>/dev/null)` → exit 0
- [ ] SC-2: Behavioral artifact stdout shows `.opencode/tools/*` names
- [ ] SC-3: `bash .opencode/tests/test-enforcement.sh --scenario session-init-tools-section` → PASS
- [ ] Lint: `ruff check --fix .opencode/tools/session-init` → clean
- [ ] Typecheck: `pyright .opencode/tools/session-init` → clean