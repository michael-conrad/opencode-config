# Task: verify-authorization — Step 5d.3: Verify Main Issue Closure

## Purpose

Check the main approved issue for prior closure via merged PR. This is NOT a wrapper — it contains new logic that was never in the pre-image. The pre-image only verified sub-issue closure during graph traversal (Step 5.4), never the main issue itself.

## Entry Criteria

- Authorization verified (from Step 2.0)
- Sub-issues verified (from Step 5)
- Codebase verified (from Step 5d.1)
- No blockers (from Step 5d.2)

## Exit Criteria

- Main issue closure state verified
- If closed with merged PR: marked as VERIFIED_CLOSED
- If closed without merged PR: marked as VERIFICATION_GAP
- If open: checked for merged PRs referencing the issue
- Reconcile-issue-graph dispatched for main issue's cross-reference graph

## Procedure

### Step 1: Check Main Issue State

```
issue = github_issue_read(method="get", owner=<github.owner>, repo=<github.repo>, issue_number=<current_issue_number>)
```

### Step 2: Evaluate State

**If closed with `state_reason: "completed"`:**

1. Search for merged PR referencing the issue:
   ```
   prs = github_search_pull_requests(query=f"Fixes #{current_issue_number} repo:{<github.owner>}/{<github.repo>}")
   ```
2. For each candidate PR, verify merge via:
   ```
   pr_detail = github_pull_request_read(method="get", owner=<github.owner>, repo=<github.repo>, pullNumber=pr["number"])
   ```
3. If merged PR found (`merged == true`):
   - Mark as `VERIFIED_CLOSED`
   - Record merged PR number and merge timestamp
4. If no merged PR found:
   - Mark as `VERIFICATION_GAP`
   - HALT with flag-for-review

**If open:**

1. Check for merged PRs referencing the issue (issue may be open but work already done):
   ```
   prs = github_search_pull_requests(query=f"Fixes #{current_issue_number} repo:{<github.owner>}/{<github.repo>} is:merged")
   ```
2. If merged PR found:
   - Mark as `VERIFIED_CLOSED` (issue was not auto-closed but work is done)
   - Record merged PR number
3. If no merged PR found:
   - Mark as `NOT_CLOSED`
   - Proceed to Step 5d.4

**If closed with other state_reason (`not_planned`, `duplicate`):**

- Mark as `VERIFICATION_GAP`
- HALT with flag-for-review

### Step 3: Dispatch reconcile-issue-graph

After closure verification, dispatch `reconcile-issue-graph` for the main issue's cross-reference graph:

```
task(subagent_type="general", context={
    "task": "reconcile-issue-graph",
    "issue_number": <current_issue_number>,
    "github.owner": <github.owner>,
    "github.repo": <github.repo>,
    "closure_status": <VERIFIED_CLOSED|VERIFICATION_GAP|NOT_CLOSED>,
    "merged_pr": <pr_number or null>,
    "dispatch_context": {
        "must_receive": ["issue_number", "github.owner", "github.repo", "closure_status"],
        "must_not_receive": ["orchestrator_reasoning", "expected_findings"]
    }
})
```

## Work State I/O

- **Reads from:** `## verify-blockers`
- **Writes to:** `## verify-closed-issue-main`

After completing this task, write results to the work state file under section `## verify-closed-issue-main` using the YAML format defined in `enforcement/work-state-schema.md`.
