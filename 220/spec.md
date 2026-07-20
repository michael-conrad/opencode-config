## Problem

The `implementation-pipeline` skill has two structural defects in its dispatch model:

### Defect 1: `pipeline-executor` — Nested Sub-Agent Dispatch

`pipeline-executor.md` is classified as `sub-task` in the SKILL.md Trigger Dispatch Table, meaning it is dispatched via `task()` as a sub-agent. However, its procedure (lines 41-59 of `pipeline-executor.md`) dispatches further sub-agents for each of the 17 pipeline steps (e.g., `test-driven-development --task red`, `verification-before-completion --task verify`, etc.).

This violates SKILL.md §Mandatory Task Discipline rule 4: **"Sub-agents must not dispatch sub-agents."**

### Defect 2: `assemble-work` — Contradictory Dispatch Classification

`assemble-work.md` has a contradictory dispatch model:

- **Trigger Dispatch Table** classifies it as `orchestrator` — meaning the orchestrator reads and executes the task file directly, no `task()` call.
- **Invocation section** says to call it via `task(..., prompt: "execute assemble-work from implementation-pipeline")` — which makes it a sub-agent.

If the Invocation wins (sub-agent), then Step 3 of `assemble-work.md` ("Dispatch Sub-Agents") is also nested sub-agent dispatch.

If the Trigger Dispatch Table wins (orchestrator), the Invocation section is wrong.

## Root Cause

The `pipeline-executor` task was designed as the internal step dispatch loop but was given `sub-task` classification. The orchestrator should run the dispatch loop directly — not delegate it to a sub-agent that then delegates further.

The `assemble-work` contradiction is a spec-editing error where the Invocation section was written without cross-checking against the Trigger Dispatch Table.

## Fix

### Fix 1: `pipeline-executor` — Change dispatch from `sub-task` to `orchestrator`

- In `implementation-pipeline/SKILL.md` Trigger Dispatch Table: change `pipeline-executor` dispatch from `sub-task` to `orchestrator`
- In `implementation-pipeline/SKILL.md` Invocation section: remove the `task()` entry for `pipeline-executor`; add instruction that the orchestrator reads `pipeline-executor.md` directly and executes its dispatch loop
- `pipeline-executor.md` content stays the same — it is the orchestrator's dispatch reference document

### Fix 2: `assemble-work` — Resolve contradiction in favor of `orchestrator`

- In `implementation-pipeline/SKILL.md` Invocation section: change `assemble-work` from `task()` to orchestrator-level execution (the orchestrator reads `assemble-work.md` directly)
- `assemble-work.md` content stays the same — it is the orchestrator's entry point reference document

### Fix 3: Verify no other tasks in the skill have the same contradiction

- Audit all entries in the Trigger Dispatch Table against the Invocation section for consistency

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `pipeline-executor` dispatch changed from `sub-task` to `orchestrator` in SKILL.md Trigger Dispatch Table | `string` | grep for `pipeline-executor` in SKILL.md — dispatch column must be `orchestrator` |
| SC-2 | `pipeline-executor` removed from Invocation `task()` table | `string` | grep for `pipeline-executor` in Invocation section — must not appear |
| SC-3 | `assemble-work` Invocation changed from `task()` to orchestrator-level execution | `string` | grep for `assemble-work` in Invocation section — must not appear in `task()` table |
| SC-4 | No remaining tasks in Trigger Dispatch Table have contradictory dispatch classification | `string` | For each task in Trigger Dispatch Table: if dispatch is `orchestrator`, verify no `task()` entry in Invocation; if dispatch is `sub-task`, verify `task()` entry exists in Invocation |
| SC-5 | Behavioral: orchestrator dispatches pipeline steps directly without nesting sub-agents | `behavioral` | `opencode-cli run` with pipeline execution prompt; verify stderr shows orchestrator dispatching steps directly, not via a pipeline-executor sub-agent |

## Affected Files

- `skills/implementation-pipeline/SKILL.md` — Trigger Dispatch Table and Invocation section

## Related

- `000-critical-rules.md` §critical-rules-034 (Inline Work — orchestrator performing file modifications without sub-agent task())
- `000-critical-rules.md` §critical-rules-035 (DISPATCH_GATE Checkpoint)
- `000-critical-rules.md` §critical-rules-048 (Skill Pre-Read + Inline Execution)

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

---

**Moved to https://github.com/michael-conrad/.opencode/issues/1403** — this issue was filed in the wrong repo.