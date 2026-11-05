## Problem

The git-workflow skill card family (6 skills: git-workflow, git-workflow-branch, git-workflow-cleanup, git-workflow-commit, git-workflow-conflict, git-workflow-pr) uses the deprecated Trigger Dispatch Table + DISPATCH_GATE + Tasks table format. This format lacks a canonical dispatch string column, forcing the orchestrator to read task card files to construct `task()` prompts — which violates the progressive disclosure architecture (Level 3 content leaks into Level 2).

Per `reference/skill-card-description-standards.md` §7, the Workflows section format replaces the old three-section structure with numbered steps containing sub-bullet dispatch contracts (Prompt, Context, Returns). The orchestrator never needs to read task cards because the exact prompt string is in the SKILL.md.

## Success Criteria

- [ ] **SC1 (behavioral):** After remediation, when an agent loads any git-workflow skill card and dispatches a task, the orchestrator uses the canonical dispatch string from the Workflows section — no task card file reads by the orchestrator
- [ ] **SC2 (structural):** All 6 git-workflow SKILL.md files use the Workflows section format per reference §7
- [ ] **SC3 (structural):** All 6 git-workflow SKILL.md files have descriptions in the canonical agent-task format (no "Load via skill() when...", "User phrases:..." deprecated patterns)
- [ ] **SC4 (structural):** No git-workflow SKILL.md contains a Trigger Dispatch Table, DISPATCH_GATE section, or Tasks table
- [ ] **SC5 (structural):** Each Workflows step has sub-bullets: Prompt (with discovery directive), Context, Returns
- [ ] **SC6 (behavioral):** After remediation, dispatching "cleanup from git-workflow-cleanup" produces a sub-agent result contract without the orchestrator having read any task card file

## Approach

1. Convert each SKILL.md from TDT + DISPATCH_GATE + Tasks table to Workflows section format
2. Update descriptions to canonical agent-task format
3. Verify no orchestrator task card reads occur during dispatch
4. Run behavioral enforcement tests to confirm

## Affected Files

- `skills/git-workflow/SKILL.md`
- `skills/git-workflow-branch/SKILL.md`
- `skills/git-workflow-cleanup/SKILL.md`
- `skills/git-workflow-commit/SKILL.md`
- `skills/git-workflow-conflict/SKILL.md`
- `skills/git-workflow-pr/SKILL.md`
- `reference/skill-card-description-standards.md` (reference — no changes needed)
- `reference/task-card-structure-standards.md` (reference — no changes needed)

