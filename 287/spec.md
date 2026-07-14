---
title: Remove outdated GitBucket API deficiency documentation
status: draft
created: 2026-07-13
license: MIT
provenance: AI-generated
issue: 287
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-13

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The `gb` CLI tool (v0.6.1) has replaced the old Python-based `gitbucket_api.py` client. The following files document API deficiencies discovered against the raw GitBucket REST API — these are now irrelevant because `gb` handles all operations with its own auth and capability model. If `gb` isn't authorized, the agent escalates to the user — no separate deficiency doc is needed.

## Goals

- Remove all obsolete files that document deficiencies of the deprecated raw-API approach
- Remove the `tests/` directory (empty after deletions)
- Remove the `API-DEFICIENCIES.md` row from SKILL.md Cross-References table
- Ensure no stale references remain anywhere in the codebase

## Non-Goals

- No changes to the `gb` CLI tool or its capability manifest
- No changes to the SKILL.md Operating Protocol, task files, or capability table
- No changes to any other skill or guideline outside the gitbucket-api directory

## Constraints and Scope

- All changes are confined to `.opencode/skills/issue-operations/platforms/gitbucket-api/`
- No references to `API-DEFICIENCIES` or `test_api_deficiencies` exist outside this directory (verified by grep)
- After deletion, the `tests/` directory will be empty and MUST be removed

## Root Cause Analysis

The root cause is architectural: the old `gitbucket_api.py` Python client made direct `requests` calls to the GitBucket REST API, which had known deficiencies (PATCH 404, label ops returning empty arrays). The `gb` CLI tool replaced this client entirely, but the deficiency documentation and test files were never cleaned up. These files now constitute dead documentation that could mislead future agents into thinking the raw-API deficiencies are still relevant.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Keep files as historical reference | Dead documentation misleads agents; git history preserves the original content |
| Move files to an archive directory | Unnecessary indirection — git history is the archive |
| Update files to reference `gb` instead | Files document raw-API deficiencies, not `gb` behavior — rewriting changes their purpose |

## Safety Considerations

- All files to delete are self-contained within the gitbucket-api skill directory
- No functional impact — `gb` CLI is the sole API interface
- Rollback: `git restore` on any deleted file

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Interdependency

No interdependencies with other open issues.

## Evidence/Provenance

| Claim | Evidence |
|-------|----------|
| Files exist at specified paths | `ls` confirmed all 4 files exist |
| No references outside gitbucket-api directory | `grep` across entire repo found no references outside the skill directory |
| `tests/` contains only the 3 files to delete | `ls` confirmed exactly 3 files in `tests/` |
| SKILL.md has `API-DEFICIENCIES.md` row at line 249 | `read` confirmed the cross-reference row |

## SC-to-Root-Cause Traceability Table

| SC-ID | Root Cause Element | What It Tests |
|-------|-------------------|---------------|
| SC-1 | Dead deficiency doc | File deletion |
| SC-2 | Dead test file | File deletion |
| SC-3 | Dead test file | File deletion |
| SC-4 | Dead test file | File deletion |
| SC-5 | Empty directory after deletions | Directory removal |
| SC-6 | Stale cross-reference | Row removal from SKILL.md |
| SC-7 | Stale references anywhere | grep confirms no remaining references |

## Feasibility Assessment

All file paths verified as existing. All references confirmed as confined to the gitbucket-api directory. No external dependencies.

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `API-DEFICIENCIES.md` is deleted | `ls .opencode/skills/issue-operations/platforms/gitbucket-api/API-DEFICIENCIES.md` returns non-zero exit code | Restore from git if accidentally removed | file-deletion | `.opencode/skills/issue-operations/platforms/gitbucket-api/` | Root cause: dead deficiency doc | common | pre-commit | sequential | A | null | null | phase-1 |
| SC-2 | `test_api_deficiencies.py` is deleted | `ls .opencode/skills/issue-operations/platforms/gitbucket-api/tests/test_api_deficiencies.py` returns non-zero exit code | Restore from git if accidentally removed | file-deletion | `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/` | Root cause: dead test file | common | pre-commit | sequential | A | null | null | phase-1 |
| SC-3 | `verify_api.py` is deleted | `ls .opencode/skills/issue-operations/platforms/gitbucket-api/tests/verify_api.py` returns non-zero exit code | Restore from git if accidentally removed | file-deletion | `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/` | Root cause: dead test file | common | pre-commit | sequential | A | null | null | phase-1 |
| SC-4 | `test_pr_idempotency.py` is deleted | `ls .opencode/skills/issue-operations/platforms/gitbucket-api/tests/test_pr_idempotency.py` returns non-zero exit code | Restore from git if accidentally removed | file-deletion | `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/` | Root cause: dead test file | common | pre-commit | sequential | A | null | null | phase-1 |
| SC-5 | The `tests/` directory is removed (empty after deletions) | `ls .opencode/skills/issue-operations/platforms/gitbucket-api/tests/` returns non-zero exit code | Re-create directory if needed | directory-removal | `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/` | Root cause: empty directory | common | pre-commit | sequential | A | null | null | phase-1 |
| SC-6 | The `API-DEFICIENCIES.md` row is removed from SKILL.md Cross-References table | `grep "API-DEFICIENCIES" .opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` returns non-zero exit code | Revert SKILL.md edit if incorrect | file-edit | `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` | Root cause: stale cross-reference | common | pre-commit | sequential | A | null | null | phase-1 |
| SC-7 | No stale references remain anywhere in the codebase | `grep -r "API-DEFICIENCIES\|test_api_deficiencies\|verify_api\.py\|test_pr_idempotency" .opencode/` returns zero matches | Investigate and remove any remaining references | verification | `.opencode/` | Root cause: stale references | common | pre-commit | sequential | A | null | null | phase-1 |
| SC-8 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | Behavioral test verifies agent does not weaken any SC | Revert any SC weakening | behavioral-test | `.opencode/tests/behaviors/` | Anti-lobotomization | common | pre-commit | sequential | A | null | null | phase-1 |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Accidental deletion of wrong file | Low | Medium | Verify file paths before deletion; git restore as rollback |
| Stale reference missed in grep | Low | Low | grep covers entire `.opencode/` tree |
| SKILL.md edit introduces formatting error | Low | Low | Review diff before commit |

## Implementation Approach

1. Delete 4 obsolete files via `git rm`
2. Remove empty `tests/` directory (git tracks directories implicitly via files; removing all files removes the directory)
3. Edit SKILL.md to remove the `API-DEFICIENCIES.md` row from the Cross-References table
4. Verify with grep that no stale references remain

After this spec is approved, invoke `writing-plans` to create `.issues/287/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `ls` on file paths | Verify files exist |
| Direct source search | `grep -r` across repo | Verify no external references |
| Direct source search | `read` on SKILL.md | Verify cross-reference row content |
