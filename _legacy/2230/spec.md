---
remote_issue: 2230
remote_url: https://github.com/michael-conrad/.opencode/issues/2230
promoted_at: 2026-08-02T15:39:00Z
---

> **Full spec and artifacts: [`.opencode/.issues/2230/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2230)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2230/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Rewrite pre-work trunk-tip verification and submodule workflow

## Intent and Executive Summary

- **Problem Statement:** The pre-work task file (`.opencode/skills/git-workflow-branch/tasks/pre-work.md`) is a 596-line monolithic file that mixes trunk-tip verification, submodule sync, branch creation, and pointer commit into a single inline procedure. It violates the 40-line rule, embeds the 6-step trunk-tip verification gate inline instead of dispatching it as a separate sub-agent task, and duplicates divergence-handling logic with `submodule-sync.md`. The tag-before-branch ordering is implicit rather than enforced. The yield-back contract (per #2228) is missing the `already_implemented` status.
- **Root Cause / Motivation:** The pre-work task was written before the sub-agent dispatch pattern was standardized. It was never decomposed into single-concern sub-tasks. The trunk-tip verification gate (mandated by `000-critical-rules.md`) exists as inline code rather than a dispatchable task, making it unreusable and unverifiable. The submodule divergence handling is duplicated across `pre-work.md` and `submodule-sync.md`.
- **Approach Chosen:** Decompose pre-work.md into a dispatcher that sequences sub-tasks: extract trunk-tip verification into a new task file, extract shared submodule divergence handling into a reference file, and restructure pre-work.md to dispatch these sub-tasks via canonical dispatch strings.
- **Alternatives Considered & Why Discarded:** Full rewrite from scratch (viable — all callers are within the same submodule and updated atomically in the same PR). Keeping monolithic structure (discarded — violates incremental build discipline and sub-agent dispatch pattern).
- **Key Design Decisions:** (1) Trunk-tip verification is a separate task file so it can be dispatched independently and reused. (2) Submodule divergence handling is a shared reference file (not a task) because it is logic referenced by two tasks, not a dispatchable unit. (3) Tag-before-branch ordering is enforced by the state machine: tagging happens in the sub-repo/parent-repo phases before branch creation. (4) Result contract format is redesigned for the new workflow — no backward compatibility constraint exists since all callers are within the same submodule and updated atomically.
- **User Intent / Original Prompt:** Rewrite pre-work trunk-tip verification and submodule workflow to follow the sub-agent dispatch pattern, enforce tag-before-branch ordering, and add `already_implemented` to the yield-back contract.

## Not Included

- Changes to the `git-workflow` dispatcher SKILL.md dispatch table (the `"pre-work"` → `git-workflow-branch --task pre-work` mapping is unchanged)
- Changes to behavioral test infrastructure (test helpers, harness, assertion library)
- Changes to the tag convention format itself (only the placement of tag creation changes)
- Changes to any task file outside `git-workflow-branch/tasks/` (cross-reference updates are mechanical only)
- Changes to the `operating-protocol.md` tag convention documentation (only cross-references to pre-work.md steps are updated)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Sub-repo phase follows correct order: verify trunk tip → tag at trunk tip → branch from tag. All sub-repo operations complete before any parent repo operations begin. | `behavioral` | `opencode run` with pre-work trigger; clean-room sub-agent inspects session.yaml for sub-repo-before-parent ordering and tag-before-branch sequence |
| SC-2 | Parent repo phase follows correct order: verify trunk tip → tag at trunk tip → branch from tag → commit submodule pointers. Tag is created before branch. | `behavioral` | `opencode run` with pre-work trigger; clean-room sub-agent inspects session.yaml for parent repo ordering and tag-before-branch sequence |
| SC-3a | Trunk-tip verification gate returns BLOCKED when parent repo or any sub-repo is not at remote tracking tip. | `behavioral` | `opencode run` with stale-branch trigger; clean-room sub-agent inspects session.yaml for BLOCKED result |
| SC-3b | `trunk-tip-verification.md` task file exists as a separate dispatchable task file, not inline code. | `string` | `grep` for `trunk-tip-verification.md` in pre-work.md dispatch table |
| SC-4 | All submodule names, branch names, and repo paths are resolved dynamically using `$DEFAULT_BRANCH`, `git remote show origin`, and `git submodule status`. No hardcoded values. The yield-back contract is redesigned for the new workflow (not preserved from the old format). | `string` | `grep` for hardcoded submodule names, branch names, or repo paths in pre-work.md; `grep` for redesigned contract format |
| SC-5 | Overcomplicated divergence analysis (ahead/behind counting, SHA comparison matrix, `--ff-only` gates) and the "already implemented" edge case handler are removed from pre-work.md. | `string` | `grep` for removed patterns in pre-work.md |
| SC-6 | Yield-back contract includes `already_implemented` status alongside `success` and `failure` (per #2228). | `string` | `grep` for `already_implemented` in pre-work.md result contract |

## Requirements

1. **R1 (Sub-repo before parent):** All sub-repo operations MUST complete before any parent repo operations begin.
2. **R2 (Sub-repo workflow):** Sub-repo phase MUST: verify at trunk tip, tag at trunk tip, branch from tag (if sub-repo changes needed).
3. **R3 (Parent repo workflow):** Parent repo phase MUST: verify at trunk tip, tag at trunk tip, branch from tag, commit submodule pointers.
4. **R4 (Tag before branch):** Tag MUST be created before branch in both sub-repo and parent repo phases.
5. **R5 (BLOCKED on verification failure):** Trunk-tip verification MUST return BLOCKED if parent repo or any sub-repo is not at remote tracking tip.
6. **R5a (Separate task file):** Trunk-tip verification MUST be a separate dispatchable task file, not inline code.
7. **R7 (Dynamic resolution):** All submodule names, branch names, and repo paths MUST be resolved dynamically — no hardcoded values.
8. **R8 (Remove overcomplicated divergence):** Overcomplicated divergence analysis (ahead/behind counting, SHA comparison matrix, `--ff-only` gates) MUST be removed.
9. **R9 (Remove already-implemented handler):** The "already implemented" edge case handler MUST be removed from pre-work.md (moved to yield-back contract per #2228).
10. **R10 (Tag convention):** Sub-repo tag format MUST be `<parent-repo>/<issue-number>`. Parent repo tag format MUST be `<issue-number>`.
11. **R11 (Yield-back contract):** Yield-back contract MUST include `already_implemented` status alongside `success` and `failure`.

## Items

1. **SC-1:** Create trunk-tip-verification task file and wire into pre-work dispatch
2. **SC-2:** Extract submodule divergence handling into shared reference file
3. **SC-3a, SC-3b:** Refactor pre-work.md to delegate to sub-tasks
4. **SC-4:** Update cross-references across 15+ files
5. **SC-5:** Update existing behavioral tests (trunk-tip-enforcement.sh, submodule-pointer-enforcement.sh)
6. **SC-6:** Add new behavioral test (pre-work-decomposition.sh)

## Phases

| Phase | SCs | Description | Concern |
|-------|-----|-------------|---------|
| PHASE-1 | SC-1 | Create `trunk-tip-verification.md` task file with 6-step gate (parent repo trunk tip, zero pending changes, remote tracking match, submodule trunk tip, submodule zero pending, submodule remote tracking match, submodule pointer match). Wire into pre-work dispatch as sub-agent task. | Sub-repo workflow extraction |
| PHASE-2 | SC-2 | Extract shared submodule divergence handling into a reference file (not a task). Handle ahead/behind detection, rebase resolution, and escalation path. | Parent repo workflow extraction |
| PHASE-3 | SC-3a, SC-3b | Refactor `pre-work.md` to delegate to sub-tasks via canonical dispatch strings. Redesign result contract format for the new workflow. Add `already_implemented` to yield-back contract. | Pre-work decomposition |
| PHASE-4 | SC-4 | Update cross-references across 15+ files that reference pre-work.md steps, result contracts, and dispatch strings. Mechanical updates only. | Cross-reference updates |
| PHASE-5 | SC-5 | Update existing behavioral tests (`trunk-tip-enforcement.sh`, `submodule-pointer-enforcement.sh`) to match new task structure and dispatch patterns. | Behavioral test updates |
| PHASE-6 | SC-6 | Add new behavioral test (`pre-work-decomposition.sh`) verifying the decomposed pre-work dispatches sub-tasks in correct order. | New behavioral test |

## Dependencies

- `.opencode#2228` — Yield-back contract spec (defines `already_implemented` status format)
- `000-critical-rules.md` — Contains critical-rules-XXX for trunk-tip verification and pre-commit pointer check
- `020-go-prohibitions.md` — Contains submodule-only PR prohibition
- `060-tool-usage.md` — No `--recursive` on submodule commands
- `091-incremental-build.md` — Per-item TDD cycle mandate

## Traceability

| Requirement | SC | Phase |
|-------------|----|-------|
| R1 (Sub-repo before parent) | SC-1 | PHASE-1 |
| R2 (Sub-repo workflow) | SC-1 | PHASE-1 |
| R3 (Parent repo workflow) | SC-2 | PHASE-2 |
| R4 (Tag before branch) | SC-1, SC-2 | PHASE-1, PHASE-2 |
| R5 (BLOCKED on failure) | SC-3a | PHASE-3 |
| R5a (Separate task file) | SC-3b | PHASE-3 |
| R7 (Dynamic resolution) | SC-4 | PHASE-4 |
| R8 (Remove overcomplicated divergence) | SC-5 | PHASE-5 |
| R9 (Remove already-implemented handler) | SC-5 | PHASE-5 |
| R10 (Tag convention) | SC-1, SC-2 | PHASE-1, PHASE-2 |
| R11 (Yield-back contract) | SC-6 | PHASE-6 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| pre-work.md | Task file | `.opencode/skills/git-workflow-branch/tasks/pre-work.md` | Read before modification |
| submodule-sync.md | Task file | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` | Read before modification |
| pre-commit-pointer-check.md | Task file | `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` | Read before modification |
| operating-protocol.md | Task file | `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md` | Read before modification |
| git-workflow-branch SKILL.md | Skill card | `.opencode/skills/git-workflow-branch/SKILL.md` | Read before modification |
| git-workflow SKILL.md | Skill card | `.opencode/skills/git-workflow/SKILL.md` | Read before modification |
| 000-critical-rules.md | Guideline | `.opencode/guidelines/000-critical-rules.md` | Read before modification |
| trunk-tip-enforcement.sh | Behavioral test | `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` | Read before modification |
| submodule-pointer-enforcement.sh | Behavioral test | `.opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh` | Read before modification |
| #2228 | Spec | `.opencode/.issues/2228/spec.md` | Read before implementation |

## Enforcement Gate

All 7 success criteria (SC-1, SC-2, SC-3a, SC-3b, SC-4, SC-5, SC-6) MUST pass before this spec is considered complete. No partial delivery is permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying sub-repo ordering costs one behavioral test run. Skipping means the sub-repo-before-parent invariant is violated silently and discovered during the first pre-work failure in production.
- SC-2: Verifying parent repo ordering costs one behavioral test run. Skipping means tag-after-branch ordering ships and corrupts the checkpoint rollback mechanism.
- SC-3a: Verifying the trunk-tip gate returns BLOCKED costs one behavioral test run. Skipping means the gate is a no-op and agents start work from stale base branches.
- SC-3b: Verifying the task file exists costs one grep search. Skipping means the gate remains inline code and cannot be dispatched independently.
- SC-4: Verifying no hardcoded names costs one grep search. Skipping means the next submodule rename breaks pre-work silently.
- SC-5: Verifying removed patterns costs one grep search. Skipping means dead divergence logic remains as technical debt.
- SC-6: Verifying the yield-back contract costs one grep search. Skipping means the #2228 contract is incomplete and callers cannot distinguish "already implemented" from "success."

## Edge Cases

- **No submodules present:** Pre-work skips the sub-repo phase entirely and proceeds directly to parent repo trunk-tip verification → branch creation.
- **Submodule divergence unresolvable:** When a submodule has both ahead and behind commits and rebase fails, pre-work returns BLOCKED with escalation to developer.
- **Trunk-tip verification fails on parent repo:** Pre-work returns BLOCKED immediately — no sub-repo operations are attempted.
- **Trunk-tip verification fails on sub-repo:** Pre-work returns BLOCKED with the specific submodule that failed — parent repo operations are not attempted.
- **Single submodule:** The sub-repo phase handles a single submodule identically to multiple submodules — no special-casing.
- **Already on a feature branch:** Pre-work detects existing feature branch and returns BLOCKED (pre-work is only valid from trunk tip).
- **Dirty working tree:** Trunk-tip verification fails on `git status --porcelain` check — returns BLOCKED with dirty file list.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-02 | Added Phases section with phase ID, SCs, description, and concern for each of the 6 phases referenced in Traceability table | Validation finding: Missing Phases section | spec-creation validation gate |
| 2026-08-02 | Split SC-3 into SC-3a (behavioral: trunk-tip gate returns BLOCKED) and SC-3b (structural: task file exists as separate dispatchable file). Updated evidence types, Requirements, Phases, Traceability, Items, Enforcement Gate, and Cost Frame sections. | Validation finding: SC-3 is a compound SC | spec-creation validation gate |
| 2026-08-02 | Removed all backward-compatibility framing: (1) Removed "backward compatibility" from Approach Chosen. (2) Changed Alternatives from "discarded — 15+ files reference pre-work.md" to "viable — all callers within same submodule". (3) Removed "backward compatibility" from Key Design Decisions (4); replaced with "redesigned for new workflow". (4) Updated SC-4 to cover yield-back contract redesign. (5) Updated PHASE-3 description to "redesign result contract format". | Validation finding: Remove all backward-compatibility framing — .opencode submodule has no external consumers | spec-creation validation gate |
