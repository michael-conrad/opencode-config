## Problem

When a user authorizes `for_pr` scope (e.g., `.opencode#1346 approved for PR`), the agent bypasses the plan entirely. The Authorization Scope Model's gap-fill column says "auto-create spec+plan+auto-approve+auto-PR." When spec and plan already exist, the agent interprets the remaining action as "auto-PR" and jumps directly to git operations — commit dirty submodule, push, create PR. The plan's 5 phases and 21 SCs are never executed.

Root cause: the gap-fill column conflates "create missing artifacts" with "produce the final deliverable." It treats PR creation as a standalone gap-fill action rather than the output of executing the plan.

## Fix

### 1. Authorization Scope Model table (approval-gate/SKILL.md)

Change the `for_pr` row:

| Scope | HALT After | Gap-Fill | PR Strategy |
|-------|-----------|----------|-------------|
| `for_pr` | pr_created | auto-create spec+plan+auto-approve+auto-PR | stacked |

To:

| Scope | HALT After | Pre-Flight | Pipeline | PR Strategy |
|-------|-----------|-----------|----------|-------------|
| `for_pr` | pr_created | auto-create spec+plan+auto-approve | execute plan via executing-plans | stacked |

The pre-flight column ensures spec and plan exist. The pipeline column mandates plan execution. "auto-PR" is removed as a gap-fill action — the PR is the output of executing the plan.

### 2. approval-gate skill — mandatory plan-execution routing

When `for_pr` scope is authorized and spec+plan already exist, the agent MUST route through `executing-plans` — not skip to PR creation. Add a routing rule:

> **for_pr with existing plan:** When spec and plan exist under `for_pr` scope, the agent MUST call `executing-plans` to execute the plan. Direct PR creation without plan execution is a critical violation.

### 3. executing-plans skill — plan reading mandate

The `executing-plans` skill must add a mandatory step: read the plan file and dispatch each phase through `implementation-pipeline` in sequence. Currently it's a thin routing layer that says "route to implementation-pipeline with full context" without actually reading the plan.

### 4. Behavioral enforcement test

A behavioral test that:
1. Creates a spec + plan with multiple phases
2. Authorizes `for_pr` scope
3. Verifies the agent dispatches `executing-plans` and reads the plan — not directly creating a PR

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `for_pr` scope with existing plan routes through `executing-plans`, not direct PR creation | `behavioral` | `opencode-cli run` → stderr shows `executing-plans` dispatch, no direct `git commit`/`github_create_pull_request` |
| SC-2 | `for_pr` scope without existing plan auto-creates plan then executes it | `behavioral` | `opencode-cli run` → stderr shows plan creation followed by `executing-plans` dispatch |
| SC-3 | Authorization Scope Model table updated with Pre-Flight + Pipeline columns | `string` | grep for new column headers in approval-gate/SKILL.md |
| SC-4 | approval-gate skill has routing rule for `for_pr` with existing plan | `string` | grep for routing rule text in approval-gate/SKILL.md |
| SC-5 | executing-plans skill has plan-reading mandate step | `string` | grep for plan-reading step in executing-plans/SKILL.md |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)