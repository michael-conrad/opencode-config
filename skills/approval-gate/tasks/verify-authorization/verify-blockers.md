# Task: verify-authorization — Step 5d.2: Verify Blockers

## Purpose

Thin wrapper that dispatches `tasks/verify-blockers.md` with the current issue context. Checks for blocking issues or dependencies that prevent implementation.

## Entry Criteria

- Authorization verified (from Step 2.0)
- Sub-issues verified (from Step 5)
- Codebase verified (from Step 5d.1)

## Exit Criteria

- No `needs-approval` label present (or explicit authorization received)
- No blocking issues superseding spec
- No unresolved dependencies

## Procedure

### Step 1: Dispatch verify-blockers

Task a clean-room sub-agent with:

```
task(subagent_type="general", context={
    "task": "verify-blockers",
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
| PASS (no blockers) | Proceed to Step 5d.3 (verify-closed-issue-main) |
| Blocking issue found | HALT, report blocker with issue URL |
| Unresolved dependency | HALT, report dependency details |
| BLOCKED | Re-task clean-room sub-agent with same context |

## Work State I/O

- **Reads from:** `## verify-codebase`
- **Writes to:** `## verify-blockers`

After completing this task, write results to the work state file under section `## verify-blockers` using the YAML format defined in `enforcement/work-state-schema.md`.
