## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The old test framework at `.opencode/tests/` (v1, using `opencode-cli` binary) has been superseded by the new test framework at `.opencode/tests-v2/` (v2, using `opencode` snap binary). The v2 framework is now the default. The v1 framework and all its files, cross-references, and infrastructure must be removed to eliminate dead code, reduce maintenance burden, and prevent agents from accidentally using the old framework. |
| Root Cause / Motivation | Two parallel test frameworks exist side-by-side. The v2 framework (`tests-v2/`) has strict env isolation (`env -i` with allowlist), mandatory smoke tests, and a proper test project structure. The v1 framework (`tests/`) has partial env passthrough, no smoke tests, and a flat test home. Keeping both creates confusion about which framework to use, doubles maintenance, and risks stale v1 references misleading agents. |
| Approach Chosen | Remove the entire `.opencode/tests/` directory and update all 22 cross-referencing files to point to the v2 equivalents. The ~500 behavioral tests in v1 that have no v2 equivalent are removed — they are not migrated. |
| Alternatives Considered & Why Discarded | (1) Migrate all ~500 v1 behavioral tests to v2 before removal — prohibitively large scope, the tests are for rules that may no longer apply. (2) Keep both frameworks indefinitely — doubles maintenance burden and confuses agents. (3) Deprecate v1 with a warning — no mechanism for deprecation warnings in agent-facing infrastructure. |
| Key Design Decisions | The ~500 v1 behavioral tests are removed without migration. These tests validated agent behavior against rules that have evolved significantly since they were written. The 10 v2 behavioral tests represent the current enforcement surface. Any rule change requiring a behavioral test will create one in v2 format. |

## Problem

### Two parallel test frameworks

The repository has two complete test frameworks:

| Dimension | v1 (OLD) — `.opencode/tests/` | v2 (NEW) — `.opencode/tests-v2/` |
|-----------|-------------------------------|----------------------------------|
| Binary | `opencode-cli` (v1.14.33) | `opencode` snap (v1.17.18) |
| Model discovery | `opencode-cli models` | `opencode models` |
| Env isolation | Partial (passes GITHUB_TOKEN etc.) | Strict (`env -i` with allowlist) |
| Smoke tests | None | Mandatory |
| Test project | Flat test home | `{home}/project/` with git init |
| Behavioral tests | ~500 scripts | 10 scripts |
| Content-verification | 2203-line `test-enforcement.sh` | 256-line `test-enforcement.sh` |
| Default model | `ollama/ornith:35b-256k` | `ollama/gpt-oss:20b-cloud` |

### 22 cross-referencing files

The old framework is referenced by 22 non-test files across guidelines, skills, docs, and configs. Every reference must be updated to point to the v2 equivalent.

### No formal migration plan exists

The v2 framework was created without a formal migration spec. The only documentation of the migration is the "Key Differences from v1" table in `.opencode/tests-v2/AGENTS.md`. No existing GitHub Issue tracks this removal.

## Scope

**In scope:**
- Delete the entire `.opencode/tests/` directory (all files, subdirectories, and artifacts)
- Update all 22 cross-referencing files to point to `.opencode/tests-v2/` equivalents
- Update `opencode-cli` references to `opencode` where appropriate in guidelines and skill files
- Update `with-test-home` references to point to `tests-v2/with-test-home`
- Update `test-enforcement.sh` references to point to `tests-v2/test-enforcement.sh`
- Update `behaviors/` references to point to `tests-v2/behaviors/`
- Update `default-model.sh` references to point to `tests-v2/default-model.sh`
- Update `helpers.sh` references to point to `tests-v2/behaviors/helpers.sh`
- Update `AGENTS.md` build/lint/test commands to use v2 paths
- Update `README.md` test documentation to use v2 paths

**Out of scope:**
- Migrating any v1 behavioral tests to v2 format — the ~500 v1 tests are removed
- Changes to the v2 framework itself (its structure, helpers, or behavior)
- Changes to the `opencode` snap binary or `opencode-cli` binary
- Changes to any test infrastructure outside `.opencode/tests/` and `.opencode/tests-v2/`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/tests/` directory no longer exists | `structural` | `ls .opencode/tests/` returns "No such file or directory" |
| SC-2 | `.opencode/AGENTS.md` build/lint/test commands reference `tests-v2/` paths, not `tests/` paths | `string` | `grep` for `.opencode/tests/` in `.opencode/AGENTS.md` returns no matches |
| SC-3 | `.opencode/guidelines/080-code-standards.md` references `tests-v2/` paths, not `tests/` paths | `string` | `grep` for `.opencode/tests/` in `080-code-standards.md` returns no matches |
| SC-4 | `.opencode/README.md` references `tests-v2/` paths, not `tests/` paths | `string` | `grep` for `.opencode/tests/` in `.opencode/README.md` returns no matches |
| SC-5 | All 22 cross-referencing files updated — no file in `.opencode/` (excluding `tests/` and `tests-v2/`) references `.opencode/tests/` | `string` | `grep -r "\.opencode/tests/" .opencode/ --include="*.md" --include="*.jsonc" --exclude-dir=tests --exclude-dir=tests-v2` returns no matches |
| SC-6 | `opencode-cli` references in guidelines and skill files updated to `opencode` where appropriate | `string` | Review of updated files confirms `opencode-cli` replaced with `opencode` in test command contexts |
| SC-7 | v2 test framework still functions correctly after removal | `behavioral` | Run `bash .opencode/tests-v2/test-enforcement.sh --list` and verify it lists scenarios |
| SC-8 | No stale references to old behavioral test scripts remain in skill files | `string` | `grep` for `tests/behaviors/` in `.opencode/skills/` returns no matches |

## Affected Files

### Files to DELETE
- `.opencode/tests/` (entire directory — all files and subdirectories)

### Files to UPDATE (22 files)

| # | File | Change |
|---|------|--------|
| 1 | `.opencode/AGENTS.md` | Update all 10 build/lint/test command references from `tests/` to `tests-v2/`; update `opencode-cli` to `opencode`; update `with-test-home` path |
| 2 | `.opencode/guidelines/080-code-standards.md` | Update 14 references: `tests/` → `tests-v2/`, `opencode-cli` → `opencode`, `helpers.sh` path, `test-enforcement.sh` path, `with-test-home` path |
| 3 | `.opencode/guidelines/000-critical-rules.md` | Update 2 references: `opencode-cli run` → `opencode run` |
| 4 | `.opencode/guidelines/020-go-prohibitions.md` | Update 3 references: `opencode-cli run` → `opencode run` |
| 5 | `.opencode/guidelines/065-verification-honesty.md` | Update 3 references: `opencode-cli models` → `opencode models` |
| 6 | `.opencode/guidelines/091-incremental-build.md` | Update 3 references: `opencode-cli run` → `opencode run`, `tests/behaviors/` → `tests-v2/behaviors/` |
| 7 | `.opencode/README.md` | Update 11 references: all `tests/` → `tests-v2/`, `opencode-cli` → `opencode` |
| 8 | `.opencode/CHANGELOG.md` | No change needed — historical entries are accurate |
| 9 | `.opencode/docs/audit-sc6959-verification.md` | Update 3 references: `tests/` → `tests-v2/` |
| 10 | `.opencode/docs/model-dependency.md` | Update 3 references: `tests/` → `tests-v2/` |
| 11 | `.opencode/plugins/AGENTS.md` | Update 2 references: `tests/` → `tests-v2/` |
| 12 | `.opencode/skills/executing-plans/tasks/start.md` | Update 3 references: `tests/` → `tests-v2/` |
| 13 | `.opencode/skills/verification-before-completion/tasks/verify.md` | Update 9 references: `tests/` → `tests-v2/` |
| 14 | `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` | Update 1 reference: `tests/` → `tests-v2/` |
| 15 | `.opencode/skills/spec-creation-validation/tasks/create.md` | Update 3 references: `tests/` → `tests-v2/`, `opencode-cli` → `opencode` |
| 16 | `.opencode/skills/spec-creation-decomposition/tasks/testability-assessment.md` | Update 2 references: `opencode-cli` → `opencode` |
| 17 | `.opencode/skills/approval-gate-scope/tasks/completion.md` | Update 2 references: `tests/` → `tests-v2/` |
| 18 | `.opencode/skills/approval-gate-scope/tasks/verify-authorization/sc-traceability-check.md` | Update 2 references: `tests/` → `tests-v2/` |
| 19 | `.opencode/skills/issue-review/tasks/analyze-and-spec.md` | Update 2 references: `tests/` → `tests-v2/` |
| 20 | `.opencode/skills/test-driven-development/tasks/red.md` | Update 1 reference: `tests/` → `tests-v2/` |
| 21 | `.opencode/skills/audit/tasks/cross-validate.md` | Update 1 reference: `opencode-cli run` → `opencode run` |
| 22 | `.opencode/skills/implementation-pipeline/enforcement/overflow-signal.md` | Update 1 reference: `opencode-cli run` → `opencode run` |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| v2 framework has incomplete coverage (only 10 behavioral tests vs v1's ~500) | High | Medium | The ~500 v1 tests validated rules that have evolved; any new rule change requiring a behavioral test will create one in v2 format. The 10 v2 tests cover the current enforcement surface. |
| `opencode` snap binary not available on all systems | Medium | High | v2 `with-test-home` already has a fallback to `opencode-cli` if snap is unavailable. The v2 `helpers.sh` also falls back. No change needed. |
| Stale references missed by grep search | Low | Medium | SC-5 verifies with comprehensive grep that no references remain. |
| CHANGELOG.md historical entries reference old paths | Low | Low | Historical entries are accurate records of what happened — they should not be rewritten. |
| Agent sessions in progress may have cached v1 paths | Medium | Low | Agents load fresh context each session; cached paths from prior sessions are not retained. |

## Edge Cases

- **`opencode-cli` references in non-test contexts**: Some `opencode-cli` references may refer to the binary in general (not test-specific). These should be updated to `opencode` only when the context is about running tests. If the reference is about the binary's general capabilities (e.g., "opencode-cli provides the skill list"), it should be updated to `opencode`.
- **`CHANGELOG.md`**: Historical entries that mention `tests/` or `opencode-cli` are accurate records of past changes. They should NOT be rewritten. Only the CHANGELOG is exempt from the path update requirement.
- **`INDEX.md`**: The guidelines INDEX file has no direct references to `.opencode/tests/` paths, so no update is needed.
- **`opencode.jsonc`**: Has no references to `.opencode/tests/`, `opencode-cli`, or any test infrastructure. No update needed.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Directory listing | `ls .opencode/tests/` and `ls .opencode/tests-v2/` | Confirm both frameworks exist and their contents |
| grep search | `grep -r "\.opencode/tests/" .opencode/ --include="*.md" --include="*.jsonc"` | Identify all cross-references to old framework |
| grep search | `grep -r "opencode-cli" .opencode/guidelines/ .opencode/skills/` | Identify all `opencode-cli` references |
| grep search | `grep -r "with-test-home" .opencode/ --include="*.md"` | Identify all `with-test-home` references |
| GitHub Issues | `github_search_issues` for test framework migration | Confirm no existing spec for this removal |
| Direct read | `.opencode/tests-v2/AGENTS.md` | Understand v2 framework structure and differences from v1 |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The implementation plan will be created in `.issues/{N}/spec-artifacts/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 OpenCode (deepseek-v4-flash)