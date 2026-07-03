# Task: verify-authorization — Step 5d.4: Verify Already Implemented

## Purpose

Thin wrapper that dispatches `tasks/verify-already-implemented.md` with the current issue context. Terminal gate: auto-close if already done, or proceed to implementation.

## Entry Criteria

- Authorization verified (from Step 2.0)
- Codebase checked (from Step 5d.1)
- No blockers (from Step 5d.2)
- Main issue closure verified (from Step 5d.3)

## Exit Criteria

- If already implemented: Issue auto-closed with evidence comment, HALT
- If not already implemented: Proceed to Step 6 (auto-dispatch)

## Procedure

### Step 1: Dispatch verify-already-implemented

Task a clean-room sub-agent with:

```
task(subagent_type="general", context={
    "task": "verify-already-implemented",
    "issue_number": <current_issue_number>,
    "github.owner": <github.owner>,
    "github.repo": <github.repo>,
    "dispatch_context": {
        "must_receive": ["issue_number", "github.owner", "github.repo"],
        "must_not_receive": ["orchestrator_reasoning", "expected_findings", "file_paths", "line_numbers"]
    }
})
```

### Step 2: Evaluate Result

| Result | Action |
|--------|--------|
| Already implemented (all SCs PASS) | Auto-close issue, check parent plan, HALT |
| NOT already implemented (some SCs FAIL) | Proceed to Step 6 (auto-dispatch) |
| BLOCKED | Re-task clean-room sub-agent with same context |

## Work State I/O

- **Reads from:** `## verify-closed-issue-main`
- **Writes to:** `## verify-already-implemented`

After completing this task, write results to the work state file under section `## verify-already-implemented` using the YAML format defined in `enforcement/work-state-schema.md`.
