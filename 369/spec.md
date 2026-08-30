> **Full spec and artifacts: [`opencode-config/.issues/369/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/.issues/369/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

## Problem

The `git-workflow-cleanup` skill's canonical dispatch string forces the orchestrator to perform inline git/gh investigation (resolving `pr_merge_status` and `branch_name`) before dispatching the cleanup sub-agent. This violates the orchestrator-context-lean principle — the orchestrator should never run inline tool calls to prepare sub-agent context. Additionally, the result contract reporting reverses the submodule-first procedural order defined in the cleanup task card.

## Root Cause

Three independent root causes combine to produce the defect:

### Root Cause 1: Canonical dispatch string requires pre-resolved values

**File:** `.opencode/skills/git-workflow-cleanup/SKILL.md:36`

```text
prompt: concat("...pr_merge_status: ", pr_merge_status, ", branch_name: ", branch_name)
```

The `concat()` function embeds `pr_merge_status` and `branch_name` as string values. The orchestrator must resolve these before calling `task()`, which forces inline git/gh commands. The task card's Step 1 already verifies PR merge status independently — the dispatch string should not duplicate this.

### Root Cause 2: Orchestrator inline investigation before dispatch

Because the dispatch string requires `pr_merge_status` and `branch_name`, the orchestrator runs git/gh commands inline to resolve them. This contaminates the orchestrator's context with conclusions about PR state, branch name, and what is "already done" before the sub-agent even starts.

### Root Cause 3: Result contract reporting reverses procedural order

The cleanup task card specifies submodule-first iteration order (Step 3 and Step 4 both iterate submodules before parent repo). However, the orchestrator reports parent-repo results before submodule results in the summary, reversing the procedural order that the task card defines.

## Scope

**In-scope:**
- Replace canonical dispatch string with a signal flag (`pr_merged_event: true`) that eliminates orchestrator pre-investigation
- Remove `pr_merge_status` and `branch_name` from the Workflows context section
- Add explicit guard note in cleanup.md Step 0: orchestrator MUST NOT pre-investigate
- Reinforce submodule-first ordering in result contract reporting
- Behavioral enforcement test verifying orchestrator does NOT run git/gh commands before dispatching cleanup sub-agent

**Out of scope:**
- Rewriting the cleanup task card's procedure or sub-tasks — only adding guard notes
- Changing the pair-cleanup workflow (separate task card, separate fix if needed)
- Changing any other skill's dispatch mechanism

## Approach

Replace the `concat()`-based canonical dispatch string with a simple signal flag `pr_merged_event: true`. The cleanup sub-agent independently discovers PR merge status, branch name, and submodule state in Step 1 of its procedure — the dispatch string should not duplicate this work. Remove the pre-resolved context from the Workflows section. Add an explicit guard note in cleanup.md at Step 0 making clear the orchestrator MUST NOT investigate before dispatch, and that submodule operations run before parent repo operations. Reinforce that result contract reporting must follow the same submodule-first order.

## Impact

| Risk | Mitigation |
|------|-----------|
| Sub-agent independently re-discovers state that orchestrator already knows | Sub-agent is designed to discover state independently — eliminating pre-resolved context makes the design consistent |
| Signal flag is too minimal for sub-agent to route correctly | `pr_merged_event: true` is unambiguous — the task card's Step 1 handles full discovery |
| Existing callers pass `pr_merge_status` / `branch_name` | No existing callers exist outside the SKILL.md dispatch — this is the sole entry point |

**Dependencies:** None. This is a self-contained fix to one SKILL.md and one task file.

**Call to action:** Review and approve this spec to eliminate orchestrator context contamination in the cleanup pipeline.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|--------------|-------------------|----------------------|
| SC-1 | SKILL.md dispatch prompt for cleanup workflow uses `pr_merged_event: true` instead of `concat()` with pre-resolved `pr_merge_status`/`branch_name` | structural | grep dispatch prompt for `pr_merged_event` in `.opencode/skills/git-workflow-cleanup/SKILL.md` | `.opencode/skills/git-workflow-cleanup/SKILL.md` |
| SC-2 | Orchestrator does NOT run any git/gh tool calls inline before dispatching cleanup sub-agent on "pr merged" trigger | behavioral | Behavioral test: send "pr merged" prompt to opencode, inspect stderr — no git/gh tool calls appear before the task() dispatch line | Behavioral test scenario |
| SC-3 | Cleanup sub-agent's result contract reports submodules before parent repo | structural | Inspect the task card or a reference result contract template — submodule entries precede parent repo entries | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |
| SC-4 | cleanup.md Step 0 has an explicit guard note: "The orchestrator MUST NOT investigate PR/issue state before dispatching this task — the sub-agent discovers everything independently" | string | grep cleanup.md for "sub-agent discovers everything independently" | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |

## Requirements

- **R-1.** The dispatch prompt in SKILL.md SHALL use `pr_merged_event: true` instead of pre-resolved `pr_merge_status` and `branch_name` values.
- **R-2.** The Workflows section SHALL NOT include `{pr_merge_status, branch_name}` in the context-passed section.
- **R-3.** The cleanup task card SHALL include an explicit guard note at Step 0 stating the orchestrator MUST NOT pre-investigate PR/issue state.
- **R-4.** The cleanup task card SHALL reinforce that submodules are processed before the parent repo in both iteration order and result contract reporting.
- **R-5.** A behavioral enforcement test SHALL verify that on "pr merged" trigger, no git/gh tool calls appear in stderr before the cleanup sub-agent's task() dispatch line.

## Items

### Item 1 (SC-1, SC-4): Replace dispatch string and add guard note

- RED: Structural test: grep for `concat()` or `pr_merge_status` in SKILL.md — must exist before change
- GREEN: Replace `concat()` dispatch with `pr_merged_event: true` in SKILL.md; add guard note in cleanup.md Step 0
- verify: grep confirms no `concat()` or `pr_merge_status` remains in prompt; grep confirms guard note text
- commit: SKILL.md + cleanup.md changes

### Item 2 (SC-3): Reinforce submodule-first in result contract

- RED: Structural test: check cleanup.md does not have submodule-first language in result contract section
- GREEN: Add note in cleanup.md that result contract summary MUST use submodule-first order, matching Step 3 and Step 4
- verify: grep confirms submodule-first language in result contract section
- commit: cleanup.md changes only

### Item 3 (SC-2): Behavioral enforcement test

- RED: Behavioral test fails — orchestrator runs git/gh commands before dispatch
- GREEN: Apply changes from Items 1-2; behavioral test now passes
- verify: Behavioral test passes with stderr inspection confirming no git/gh commands before task() dispatch
- commit: Test scenario file only

## Dependencies

| Reference | Relationship | Status |
|-----------|-------------|--------|
| `git-workflow-cleanup/SKILL.md` | File to be modified | Satisfied |
| `git-workflow-cleanup/tasks/cleanup.md` | File to be modified | Satisfied |

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-1 | Item 1 |
| R-3 | SC-4 | Item 1 |
| R-4 | SC-3 | Item 2 |
| R-5 | SC-2 | Item 3 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| git-workflow-cleanup SKILL.md | skill | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Read file |
| git-workflow-cleanup cleanup.md | task | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | Read file |

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

- **SC-1:** Structural grep on the dispatch prompt costs < 5 seconds — a single grep command. Skipping costs the orchestrator-contamination defect remaining undetected through every future cleanup cycle.
- **SC-2:** Behavioral `opencode run` costs one sub-agent dispatch + model inference — roughly 30-120 seconds. Skipping costs the contamination defect pattern recurring across the entire skill deck surface area.
- **SC-3:** Structural inspection of the result contract template costs < 5 seconds — a single read. Skipping costs the sub-agent following correct procedural order while the orchestrator reverses it in every summary.
- **SC-4:** String grep for the guard note costs < 3 seconds — trivial. Skipping costs every future editor or agent removing the guard during refactoring, silently reintroducing the contamination defect.

## Edge Cases

| Condition | Expected Behavior | Resolution |
|-----------|------------------|------------|
| No submodules in repo | Sub-agent detects empty `SUBMODULE_PATHS` and proceeds without submodule routing context | Normal operation — guard note already covers "if no submodules, proceed normally" |
| Multiple submodules | Sub-agent processes each submodule before parent repo in iteration order and result contract | Normal operation — the fix reinforces existing correct behavior |
| Orchestrator already has branch_name from session-init | Orchestrator MUST still not pre-investigate; sub-agent independently discovers branch name | The signal flag eliminates the need for the orchestrator to know branch_name at dispatch time — the sub-agent discovers it |
