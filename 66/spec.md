## Objective

Standardize all sub-agent and sub-task dispatch points across `.opencode/skills/` to eliminate nested spawning, inconsistent context schemas, pre-analysis gating gaps, inline fallback anti-patterns, and missing dispatch audit tables in individual task files.

## Problem Statement

The Sub-Agent Dispatch Audit tables in SKILL.md files declare a clean-room discipline, but the actual dispatch patterns in task files deviate systematically:

### Finding 1: Nested Sub-Agent Spawning (Deep Dispatch Trees)

The rule "sub-agents never self-spawn" (`dispatch.md` line 5) is violated transitively:

**`cross-validate.md` dispatches 3 sub-agents:**
```
orchestrator → task(general) running cross-validate
                ├── task(general) running resolve-models
                ├── task(auditor-1) clean-room evaluation
                └── task(auditor-2) clean-room evaluation
```
Depth: **4 levels** (orchestrator → general → auditor). The `general` sub-agent for `cross-validate` spawns sub-agents of its own.

**`plan-fidelity.md` dispatches 2 sub-agents:**
```
orchestrator → task(general) running plan-fidelity
                ├── task(general) running clean-room generation
                └── task(general) running cross-validate
```

**`audit.md` doubles the nesting further — it dispatches type-specific tasks which then dispatch cross-validate which dispatches auditors.** The `audit.md` meta-orchestrator layer is redundant (every caller already specifies the type directly).

### Finding 2: Inconsistent `pre-analysis` Contracts

`pre-analysis` is referenced in 30+ SKILL.md dispatch tables, but with conflicting contracts:

| Source | pre-analysis Contract | Violation |
|--------|----------------------|-----------|
| `git-workflow/SKILL.md` | `{ task_description }` | Missing `issue_number`, `github.owner`, `github.repo` |
| All other skills | `{ issue_number, task_description }` | Standard, but most omit `github.owner`, `github.repo` |
| `pre-analysis/SKILL.md` | `{ issue_number, task_description, github.owner, github.repo }` | Canonical |

**Skills MISSING pre-analysis references entirely (13):**
`research`, `programming-principles`, `multimodal-dispatch`, `ui-engineer`, `ui-design`, `requesting-code-review`, `receiving-code-review`, `sync-guidelines`, `verification`, `notebook-operations`, `conflict-resolution`, `code-size-enforcement`, `fragment-manager`

### Finding 3: Inconsistent Dispatch Context Schemas

| Field | Included In | Missing From |
|-------|-------------|-------------|
| `worktree.path` | divide-conquer, git-workflow, VbC, finishing, using-git-worktrees, engineering-approach | issue-operations, spec-creation, issue-review, writing-plans, brainstorming, verification, research, 12 others |
| `github.platform` | issue-operations only | All 45+ other skills |
| `audit_phase` | adversarial-audit (all sub-tasks) | VbC, finishing, approval-gate, executing-plans, writing-plans — all dispatch auditors but don't declare `audit_phase` in tables |

### Finding 4: Inline Fallback Anti-Pattern in `verify-authorization.md`

Step 0 declares:
> "If sub-agent returns empty, execute Steps 1-6 inline"

This directly violates `000-critical-rules.md` §Universal Re-Dispatch Mandate (line 2540-2549). The correct behavior is re-dispatch with original scoped context only.

### Finding 5: Missing Dispatch Audit Tables in Task Files

47 SKILL.md files have Dispatch Audit tables, but ZERO individual task files (`tasks/*.md`) have them — yet 39+ task files contain explicit `task(subagent_type=...)` calls.

## Context

- Issue type: Infrastructure / Standards remediation
- Affected: All 47 skills with dispatch capabilities
- Pipeline: Already deployed — changes must preserve backward compatibility
- Dependencies: None (self-contained spec — only modifies `.opencode/skills/*/` metadata)

## Constraints

1. **Do NOT change runtime behavior of any dispatch mechanism** — only standardize documentation, contracts, and structure
2. **Do NOT change the `task()` tool or sub-agent infrastructure** — this is a documentation/discipline fix
3. **Do NOT touch `000-critical-rules.md`** — the rules are correct; the skills must align to them
4. **Every change must maintain valid markdown** — no broken frontmatter, no missing YAML
5. **Sub-agent never self-spawn rule is absolute** — flatten dispatch trees, don't deepen them

## Success Criteria

| SC | Description | Verification Method |
|----|-------------|-------------------|
| SC-1 | All 47 Sub-Agent Dispatch Audit tables use a uniform schema: `{ scope_of_context, exclusions, pre-analysis_contract, includes_inline_work }` | grep for inconsistent schema patterns |
| SC-2 | `pre-analysis` contract is identical across all 35+ references: `{ issue_number, task_description, github.owner, github.repo }` | grep for non-standard contracts |
| SC-3 | All 13 skills missing pre-analysis have been added | grep across all SKILL.md |
| SC-4 | `audit_phase` present in dispatch tables of all auditor-dispatching skills | grep for `audit_phase` |
| SC-5 | `cross-validate.md` dispatches auditors directly (not via `task(general)`) — orchestrator calls `resolve-models` + dispatches both auditors | File read inspection |
| SC-6 | `plan-fidelity.md` no longer dispatches `writing-plans clean-room` as a sub-agent — orchestrator handles both clean-room + cross-validate | File read inspection |
| SC-7 | `audit.md` meta-orchestrator removed — callers invoke type-specific tasks directly | File existence and reference audit |
| SC-8 | `verify-authorization.md` Step 0 inline fallback replaced with re-dispatch protocol | File read inspection |
| SC-9 | Every `tasks/*.md` file with `task(subagent_type=...)` has its own Dispatch Audit Table | grep for audit tables in task files |
| SC-10 | `worktree.path`, `github.owner`, `github.repo` present in all dispatch context declarations | grep across all SKILL.md audit tables |
| SC-11 | All existing behavioral tests pass after changes | `bash .opencode/tests/behaviors/run-all.sh` |
| SC-12 | Content enforcement tests pass after changes | `bash .opencode/tests/test-enforcement.sh` |

## Phases

### Phase 1: Standardize Dispatch Audit Tables (SC-1, SC-2, SC-3, SC-4, SC-10)

**Concern:** Metadata documentation — all skills get uniform dispatch tables

**Steps:**

1.1 Define the canonical Dispatch Audit Table schema in a reference document
1.2 Update all 47 SKILL.md Sub-Agent Dispatch Audit tables to the uniform schema
1.3 Add `pre-analysis` gating to all 13 skills that lack it
1.4 Add `audit_phase` to all auditor-dispatching skills' tables
1.5 Normalize `pre-analysis` contract to `{ issue_number, task_description, github.owner, github.repo }` everywhere
1.6 Ensure `worktree.path` is present where relevant

### Phase 2: Flatten Dispatch Trees (SC-5, SC-6, SC-7)

**Concern:** Structural — eliminate nested sub-agent spawning

**Steps:**

2.1 **`cross-validate.md`**: Move `resolve-models` dispatch to the orchestrator level. The orchestrator calls `resolve-models` before invoking `cross-validate`, passing the resolved auditor types as context. `cross-validate.md` dispatches both auditors directly (via `task(auditor-*)`) without a wrapping `task(general)`.

2.2 **`plan-fidelity.md`**: Move `writing-plans --task clean-room` to the orchestrator level. The orchestrator generates the clean-room plan and passes it as context. `plan-fidelity.md` then dispatches `cross-validate` with both plans as evidence.

2.3 **`audit.md`**: Remove the meta-orchestrator layer. All callers already specify the type directly (`adversarial-audit --task spec-audit`). The `audit.md` file becomes deprecated — callers invoke type-specific tasks directly.

2.4 Update all skill-to-skill invocation tables in SKILL.md and INDEX.md to reflect the flattening.

### Phase 3: Fix Inline Fallback (SC-8)

**Concern:** Behavioral — eliminate the only remaining inline fallback path

**Steps:**

3.1 In `verify-authorization.md`, replace Step 0 inline fallback with re-dispatch protocol.
3.2 The re-dispatch uses the same original context — no expanded context, no orchestrator reasoning.
3.3 Document the result guard as a re-dispatch with an increased retry counter (max 2 attempts before HALT).
3.4 Update the `approval-gate` skill rules if needed.

### Phase 4: Add Dispatch Audit Tables to Task Files (SC-9)

**Concern:** Completeness — individual task files declare their own dispatch discipline

**Steps:**

4.1 Identify all `tasks/*.md` files containing `task(subagent_type=...)` calls (39+ found).
4.2 For each, add a `## Dispatch Audit` section with the standardized schema.
4.3 Verify every task-level table is consistent with its parent SKILL.md table.

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Phase 2 flattening breaks adversarial-audit callers | Medium | High | Update all skill-to-skill invocation tables; run behavioral tests |
| Phase 1 schema changes create merge conflicts with in-flight skill additions | Low | Medium | Self-contained — only touches existing files |
| Phase 3 re-dispatch loops indefinitely | Low | Medium | Max 2 retry counter; HALT on exhaustion |
| Phase 4 task files miss some dispatch calls | Medium | Low | grep for all `task(subagent_type=` patterns |

## Edge Cases

- **`completion-core` SKILL.md has frontmatter issue** (description doesn't start with "Use when") — already flagged; exclude from Phase 1 changes to avoid conflating fixes
- **Some task files might perform inline work without any sub-agent dispatch** — mark as no-dispatch-needed in audit table
- **`verify-authorization.md` has a "double-failure" protocol** (Step 60-69) — preserve this; it's an exhaustion handler, not an inline fallback

## Change Control

- This spec supersedes any implied dispatch rules in individual task files that conflict with the standardized schema
- Phase 2 restructuring is the only behavioral change; Phases 1, 3, 4 are documentation/discipline-only
- Post-implementation: `adversarial-audit --task spec-audit` to verify spec fidelity

---
🤖 OpenCode (ollama-cloud/deepseek-v4-flash) 🔄 working