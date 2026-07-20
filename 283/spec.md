Create a new audit and remediation spec for identifying skill cards with excessively long descriptions (due to encompassing too many task cards and workflows) as candidates for splitting into multiple skill cards with semantic separation of concerns.

## Problem Statement

Analysis of the 37 skill cards in `.opencode/skills/` reveals several skills with excessive task counts that violate the Single Concern Principle and Separation of Concerns:

| Skill | Task Count | Description Length | Primary Concerns |
|-------|------------|-------------------|------------------|
| issue-operations | 44 | 591 chars | Platform dispatch (GitHub/GitBucket/local), issue CRUD, sub-issue management, comment gating, sync operations, artifact push |
| approval-gate | 40 | 625 chars | Authorization scope, cascade, halt boundaries, label application, spec-to-plan cascade, revision revocation, bug discovery protocol, multi-task plan auth |
| git-workflow | 30 | 530 chars | Branch creation, commit/push, PR creation, rebase/merge, conflict resolution, cleanup, provenance tracking, submodule sync |
| writing-plans | 19 | 795 chars | Plan creation from spec, Z3-enforced pipeline, holistic checks, retroactive plans, backfill |
| spec-creation | 17 | 898 chars | Requirements extraction, analytical discovery (7 tasks), decomposition, risk analysis, traceability, holistic checks |

## Audit Criteria (Success Criteria for Identification)

- **SC-1**: Skill has >15 task files (indicating multiple workflows)
- **SC-2**: Skill description exceeds 800 characters (farmage pattern limit: 1024 chars)
- **SC-3**: Skill's Trigger Dispatch Table maps >10 distinct user phrases to different tasks
- **SC-4**: Skill's Sub-Agent Routing section documents >5 distinct context profiles
- **SC-5**: Skill encompasses >3 semantically distinct concerns (per concern analysis)

## Remediation Patterns

For each identified skill, the remediation MUST:
- Split along semantic boundaries (separation of concerns)
- Each resulting skill has a single, coherent purpose
- Each resulting skill has <15 task files
- Each resulting skill follows farmage description pattern (≤1024 chars)
- Preserve all existing functionality through composition/dispatch
- Maintain backward compatibility for trigger phrases via dispatcher skill

## Proposed Splits

### issue-operations (44 tasks) → Split into:
1. **issue-operations-core** - Core CRUD + platform dispatch
2. **issue-operations-sub-issues** - Sub-issue management (link, read, create)
3. **issue-operations-sync** - Sync operations (sync-from-remote, sync-pull-to-local, import-remote, push-artifacts)
4. **issue-operations-comments** - Comment gating and substantive checks

### approval-gate (40 tasks) → Split into:
1. **approval-gate-scope** - Authorization scope, cascade, halt boundaries
2. **approval-gate-labels** - Label application, approved-for-* management
3. **approval-gate-revision** - Spec-to-plan cascade, revision revocation
4. **approval-gate-bug-discovery** - Bug discovery protocol

### git-workflow (30 tasks) → Split into:
1. **git-workflow-branch** - Branch creation, worktree setup
2. **git-workflow-commit** - Commit, push, provenance
3. **git-workflow-pr** - PR creation, strategy, readiness
4. **git-workflow-cleanup** - Cleanup, merge verification, submodule sync
5. **git-workflow-conflict** - Rebase/merge conflict resolution (delegates to conflict-resolution)

### writing-plans (19 tasks) → Split into:
1. **writing-plans-creation** - Plan creation from spec, Z3 pipeline
2. **writing-plans-holistic** - Holistic checks, quality verification
3. **writing-plans-retroactive** - Retroactive plans, backfill

### spec-creation (17 tasks) → Split into:
1. **spec-creation-requirements** - Requirements extraction, analytical discovery
2. **spec-creation-decomposition** - Problem decomposition, blast radius, cross-cutting
3. **spec-creation-validation** - Traceability, risk analysis, holistic checks
4. **spec-creation-change-control** - Change control, revision management

## Deliverables

- Audit report documenting all skills exceeding thresholds
- Remediation plan with specific split boundaries for each skill
- New skill card templates for each split skill
- Migration guide for updating trigger phrases and dispatch tables

## Acceptance Criteria

- All 5 target skills split into semantically coherent sub-skills
- Each sub-skill passes farmage pattern validation (<1024 chars, proper format)
- Each sub-skill has <15 task files
- All existing trigger phrases still route correctly via dispatcher
- No functionality lost in the split

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)