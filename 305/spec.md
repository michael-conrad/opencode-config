---
type: SPEC
status: DRAFT
version: 1.2
created: 2026-07-17
updated: 2026-07-17
labels: [SPEC, enforcement, test-infrastructure]
priority: high
---

# [SPEC] Prohibit `timeout` command usage in AGENTS.md — mandate bash tool timeout parameter only

## Problem Statement

The `timeout` command (GNU coreutils) is used in bash scripts invoked by the bash tool. This is explicitly FORBIDDEN by the test harness rules in `.opencode/tests-v2/AGENTS.md` and `.opencode/tests-v2/behaviors/helpers.sh`:

> **FORBIDDEN: The `timeout` command (GNU timeout) MUST NOT appear in any test script. The bash tool `timeout` parameter is the ONLY kill signal. GNU timeout does NOT forward SIGTERM to its children — orphaned opencode processes hold the flock lock and hang all subsequent test runs.**

Despite this mandate, the pattern keeps recurring because:
1. `/AGENTS.md` and `.opencode/AGENTS.md` do not document this prohibition
2. Agents default to using `timeout` when they want to prevent hanging commands
3. The prohibition is buried in test harness docs that agents may not read before writing scripts

## Root Cause Analysis

The `timeout` command bypass is one symptom of a broader pattern: **agents construct bespoke test environments instead of using the canonical test framework**. The research across 25+ issues in both repos reveals a consistent chain of rationalizations:

1. Agent decides the canonical test framework (`with-test-home` + `behavior_run()`) is "too slow" or "too heavy" for a quick test
2. Agent creates a manual test home via `mktemp -d`
3. Agent seeds config manually (`opencode.jsonc`), clones `.opencode` manually, runs `git init` manually
4. Agent runs `opencode run` directly (not through `with-test-home`)
5. Agent uses `timeout` command to prevent hanging (because there's no bash tool timeout parameter in the manual setup)
6. The test environment leaks production state (snap binary writes to production DB, XDG isolation not set up)
7. The test produces invalid results or corrupts production data

This chain is documented across issues: #304 (test isolation mandates), #166 (pre-flight behavior_run), #1979 (isolation defects), #1965 (rationalization for "simple" changes), #1963 (skill bypass for "simple" queries), #1969 (spec-creation bypass), #1952 (cascading rationalization), #1708 (release PR workflow bypass), #1732 (routing-bypass on "pr merged"), #1703 (writing-plans pipeline bypass), #1688 (parallel execution rationalization).

## Success Criteria

### SC-1: `/AGENTS.md` documents the timeout prohibition

**Given:** `/AGENTS.md` exists
**When:** spec is implemented
**Then:** `/AGENTS.md` contains a section documenting that `timeout` command is FORBIDDEN in all bash scripts, and the bash tool `timeout` parameter is the only permitted kill signal

**Verification:** grep for "timeout" in `/AGENTS.md` returns at least one match documenting the prohibition

### SC-2: `.opencode/AGENTS.md` documents the timeout prohibition

**Given:** `.opencode/AGENTS.md` exists
**When:** spec is implemented
**Then:** `.opencode/AGENTS.md` contains a section documenting that `timeout` command is FORBIDDEN in all bash scripts, and the bash tool `timeout` parameter is the only permitted kill signal

**Verification:** grep for "timeout" in `.opencode/AGENTS.md` returns at least one match documenting the prohibition

### SC-3: Prohibition is in the Build/Lint/Test Commands section

**Given:** Both AGENTS.md files have a Build/Lint/Test Commands section
**When:** spec is implemented
**Then:** The prohibition is placed in or adjacent to the Build/Lint/Test Commands section, not buried in a separate section

**Verification:** The timeout prohibition text appears within 5 lines of the test commands table in each file

### SC-4: Prohibition includes the rationale

**Given:** The prohibition text exists
**When:** spec is implemented
**Then:** The text includes the rationale: GNU timeout does not forward SIGTERM to children, creating orphaned processes that hold flock locks and hang subsequent test runs

**Verification:** grep for "orphan" or "flock" or "SIGTERM" in each AGENTS.md returns a match

### SC-5: Prohibition on manual test home construction

**Given:** An agent needs to run a test
**When:** spec is implemented
**Then:** Both AGENTS.md files document that agents MUST NOT construct test environments manually (mktemp -d, manual opencode.jsonc, manual git init, manual .opencode clone). ALL test execution MUST go through `with-test-home` or `behavior_run()`.

**Evidence type:** `string`
**Verification:** grep for "manual" or "bespoke" or "mktemp" in each AGENTS.md returns a match documenting the prohibition

### SC-6: Prohibition on direct `opencode run` without `with-test-home`

**Given:** An agent needs to run `opencode run`
**When:** spec is implemented
**Then:** Both AGENTS.md files document that `opencode run` MUST NOT be called directly — it MUST be called through `bash .opencode/tests-v2/with-test-home opencode run <message>`

**Evidence type:** `string`
**Verification:** grep for "with-test-home" in each AGENTS.md returns at least one match in the test commands section

### SC-7: Standalone binary copy into test home is the CORRECT pattern

**Given:** The snap binary at `/snap/bin/opencode` hardcodes `SNAP_USER_DATA=~/snap/opencode/` and cannot be redirected via environment variables
**When:** spec is implemented
**Then:** Both AGENTS.md files document the correct pattern: the standalone opencode binary is cached at `.tools/opencode/opencode`, copied into the test home at `$TEST_HOME/bin/opencode` during test setup, and `$TEST_HOME/bin` is prepended to PATH so the test harness resolves the standalone binary instead of the snap binary

**Evidence type:** `string`
**Verification:** grep for "standalone" or "cached" or ".tools/opencode" in each AGENTS.md returns a match documenting the correct binary setup pattern

### SC-8: Prohibition on "simple" or "quick" rationalization to bypass test framework

**Given:** An agent considers bypassing the test framework
**When:** spec is implemented
**Then:** Both AGENTS.md files document that "this is simple" or "this is quick" or "this is too small for the full framework" are NOT valid justifications for bypassing `with-test-home` or `behavior_run()`. The test framework is MANDATORY for ALL test execution regardless of perceived complexity.

**Evidence type:** `string`
**Verification:** grep for "simple" or "quick" or "small" in each AGENTS.md in the test framework section returns a match documenting the prohibition

### SC-9: Prohibition on manual `opencode.jsonc` seeding

**Given:** An agent sets up a test environment
**When:** spec is implemented
**Then:** Both AGENTS.md files document that agents MUST NOT manually create or seed `opencode.jsonc` in test environments. The `seed_model_config()` function in `with-test-home` handles config generation. Manual seeding bypasses model discovery and isolation verification.

**Evidence type:** `string`
**Verification:** grep for "opencode.jsonc" or "seed" in each AGENTS.md in the test framework section returns a match documenting the prohibition

### SC-10: Prohibition on manual `git init` + `.opencode` clone in test environments

**Given:** An agent sets up a test project
**When:** spec is implemented
**Then:** Both AGENTS.md files document that agents MUST NOT manually `git init` and clone `.opencode` for test environments. The `with-test-home --setup` and `behavior_run()` handle test project creation with proper isolation.

**Evidence type:** `string`
**Verification:** grep for "git init" or "clone" in each AGENTS.md in the test framework section returns a match documenting the prohibition

## Constraints

### CONS-1: No changes to test harness files

This spec only modifies `/AGENTS.md` and `.opencode/AGENTS.md`. The test harness files (`.opencode/tests-v2/AGENTS.md`, `.opencode/tests-v2/behaviors/helpers.sh`) already document the prohibition correctly and are NOT modified by this spec.

### CONS-2: Both files must be updated

Both the root repo AGENTS.md and the submodule AGENTS.md must be updated. Updating only one leaves a gap where agents reading the other file will not see the prohibition.

### CONS-3: Prohibitions must be in a single consolidated section

All test framework prohibitions (SC-1 through SC-10) must be in a single consolidated section in each AGENTS.md, not scattered across the file. This prevents agents from missing prohibitions that are buried in unrelated sections.

## Risks

### RISK-1: Agents may still bypass despite documentation

**Likelihood:** High | **Impact:** Medium

**Scenario:** An agent reads the AGENTS.md but still constructs manual test environments because it's a deeply ingrained pattern.

**Mitigation:** This spec is documentation-only. Behavioral enforcement (test that catches bypass patterns) is a separate concern for a separate spec.

### RISK-2: Prohibition list grows stale

**Likelihood:** Low | **Impact:** Low

**Scenario:** New bypass patterns emerge that are not covered by the current prohibition list.

**Mitigation:** The consolidated section structure makes it easy to add new prohibitions. The "simple/quick" prohibition (SC-8) acts as a catch-all for novel bypass rationalizations.

## Dependencies

### DEP-1: No external dependencies

This spec is self-contained.

## Change Control

### Status History

| Version | Date | Status | Change |
|---------|------|--------|--------|
| 1.0 | 2026-07-17 | DRAFT | Initial specification |
| 1.1 | 2026-07-17 | DRAFT | Added SC-5 through SC-10 based on research of test framework bypass patterns across 25+ issues |
| 1.2 | 2026-07-17 | DRAFT | Corrected SC-7: standalone binary copy into test home is the CORRECT pattern, not a prohibition. Documented the `.tools/opencode/` cache → `$TEST_HOME/bin/opencode` copy → PATH prepend workflow |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
