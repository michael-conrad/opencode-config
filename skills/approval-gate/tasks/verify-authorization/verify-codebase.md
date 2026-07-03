# Task: verify-authorization — Step 5d.1: Verify Codebase

## Purpose

Thin wrapper that dispatches `tasks/verify-codebase.md` with the current issue context. Re-evaluates codebase state before implementation to detect staleness or superseding issues.

## Entry Criteria

- Authorization verified (from Step 2.0)
- Sub-issues verified (from Step 5)

## Exit Criteria

- Files mentioned in spec still exist
- Referenced code is still valid
- No superseding issues found
- No staleness detected

## Procedure

### Step 1: Dispatch verify-codebase

Task a clean-room sub-agent with:

```
task(subagent_type="general", context={
    "task": "verify-codebase",
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
| PASS (no staleness, no superseding) | Proceed to Step 5d.2 (verify-blockers) |
| Staleness detected | HALT, report staleness, wait for fresh approval |
| Superseding issue found | HALT, report superseding issue URL |
| BLOCKED | Re-task clean-room sub-agent with same context |

## Work State I/O

- **Reads from:** `## sub-issue-verification`
- **Writes to:** `## verify-codebase`

After completing this task, write results to the work state file under section `## verify-codebase` using the YAML format defined in `enforcement/work-state-schema.md`.
