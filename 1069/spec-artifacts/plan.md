# Implementation Plan — Post-Creation Fixes (#1069)

## STATUS: plan
## SCOPE: post-creation-fix
## AUTHORIZATION: for_plan (halt after plan_created)
## PARENT SPEC: [#1069](https://github.com/michael-conrad/.opencode/issues/1069)
## STACKS ON: [#1068](https://github.com/michael-conrad/.opencode/pull/1068) (same branch: `feature/1060-spec-structure-expansion`)
## 14-PIPELINE: solve-check-before-dispatch

## Plan Model

**Single-task combined plan** — all changes are text/formatting edits to `.md` task files within the `.opencode` submodule. Items are sequential per-item TDD cycles within a single implementation phase. No sub-issues.

All SCs are `string` evidence type (text/formatting — grep-verifiable content presence). No behavioral tests needed.

## Item Decomposition — 3 Items, 5 Defect SCs

| Item | Defects | SCs | Description | File | Nature |
|------|---------|-----|-------------|------|--------|
| A | D1 | SC-1 | Remove Steps 1 (single-task-check) and 2 (auto-plan-trigger) from `post-creation.md`. Update exit criteria, safety checks, live verification table, Context Required. `post-creation.md` runs spec-auditor only. | `skills/issue-operations/tasks/post-creation.md` | Text/formatting |
| B | D2, D3, D4 | SC-2, SC-3, SC-4 | Fix `write.md` Pre-Step 0.8 (route to issue-operations instead of local-issues CLI), Step 8 (route to body-edit, not ambiguous "update the issue body"), Step 9 (remove approval-gate and writing-plans references) | `skills/spec-creation/tasks/write.md` | Text/formatting |
| C | D5 | SC-5 | Fix `creation.md` Step 2.1 platform API calls — replace inline `github_issue_write()` and `gitbucket-api` calls with task() dispatch to platform sub-skills | `skills/issue-operations/tasks/creation.md` | Text/formatting |

## Dependency Order

```
Item A (post-creation.md) — no dependencies
  ↓
Item B (write.md) — no dependencies on A (different files)
  ↓
Item C (creation.md) — no dependencies on A or B (different file)
```

## Item Description

### Item A — Remove Auto-Plan Trigger from post-creation.md (SC-1)

**Target:** `skills/issue-operations/tasks/post-creation.md`

**Changes:**
- Remove Step 1: "Determine Single-Task vs Multi-Task" section entirely (lines 26-32)
- Remove Step 2: "Trigger Plan Creation (All Specs)" section entirely (lines 34-52)
- Renumber Step 3 to Step 2: "Invoke Spec-Auditor Orchestrator" becomes Step 1 (now the only step)
- Update Purpose: remove "and trigger plan creation for multi-task specs"
- Update Operating Protocol: remove plan-creation reference
- Update Entry Criteria: remove single-task-check references
- Update Exit Criteria: change "plan creation triggered" to NOT part of exit criteria
- Update Safety Checks: remove "Plan creation triggered via writing-plans" check
- Update Live Verification table: remove D1-related rows
- Update Context Required: remove writing-plans reference, remove single-task-check reference
- Update Finding Classification table: remove plan-creation rows

**SC-1 verification:** grep for absence of "writing-plans" and "Trigger Plan Creation" in post-creation.md

### Item B — Fix write.md CLI Bypass, Ambiguous Update, Transition Order (SC-2, SC-3, SC-4)

**Target:** `skills/spec-creation/tasks/write.md`

**SC-2 — Fix Pre-Step 0.8 (line 28):**
Replace:
```markdown
Invoke `local-issues create` to create a stub issue. Include a minimal exec summary
(problem statement, affected files, success criteria outline). Check platform
availability before invocation — if the platform is unavailable, HALT and report.
```
With:
```markdown
Invoke `issue-operations --task creation` with a minimal exec summary body
to establish the remote issue number. Include the spec title, brief problem
statement, and `needs-approval` label. Record the returned issue number
(`ISSUE_N`) for all subsequent artifact paths. The full spec body will be
populated in Step 7 via `issue-operations --task body-edit`.
```

**SC-3 — Fix Step 8 (line 455):**
Replace:
```markdown
- If user requests revisions via issue comments: update the issue body, then post
```
With:
```markdown
- If user requests revisions via issue comments: invoke `issue-operations --task body-edit`
  to update the issue body, then post
```

**SC-4 — Fix Step 9 (lines 461-465):**
Replace:
```markdown
After user approval of the spec on the GitHub Issue:

- Invoke `spec-auditor` for quality audit
- Then proceed to `approval-gate` for authorization
- Then `writing-plans` for implementation planning
```
With:
```markdown
After user approval of the spec on the GitHub Issue:

- Invoke `spec-auditor` for quality audit
- The approval-gate and writing-plans cascade is handled outside the write task
  by the approval workflow — not invoked here.
```

Update Context Required from:
```
- Followed by: `spec-auditor`, then `approval-gate`
```
To:
```
- Followed by: `spec-auditor`, then user review on the issue
```

**SC-2 verification:** grep for `issue-operations --task creation` in Pre-Step 0.8
**SC-3 verification:** grep for `issue-operations --task body-edit` in Step 8
**SC-4 verification:** grep for absence of "approval-gate" and "writing-plans" in Step 9 (they should not appear)

### Item C — Fix creation.md Platform Routing (SC-5)

**Target:** `skills/issue-operations/tasks/creation.md`

**Changes to Step 2.1 (lines 130-149):**

Replace the inline `github_issue_write(method="create", ...)` block (lines 134-144) with:
```
   **GitHub:**
   Route to `platforms/github-mcp/` sub-skill via task(). Pass issue parameters.
   The platform sub-skill handles the github_issue_write call.
```

Replace the inline `gitbucket-api create-issue` command (lines 146-149) with:
```
   **GitBucket:**
   Route to `platforms/gitbucket-api/` sub-skill via task(). Pass issue parameters.
   The platform sub-skill handles the gitbucket-api call.

   **Note (GitBucket):** Labels can ONLY be set during creation. Post-creation label changes do not work.
```

**SC-5 verification:** grep for absence of `github_issue_write(method="create",` and `gitbucket-api create-issue` in creation.md — these should be removed from inline code blocks. Verify presence of `platforms/github-mcp/` and `platforms/gitbucket-api/` task dispatch references instead.

## 14-Step Solve-Verified Dispatch Pipeline

**Per-item pipeline.** Each item goes through the 14-step pipeline with solve state verification before every dispatch.

### Solve-Gate Protocol (MANDATORY before every dispatch)

```bash
solve check --state-path ./tmp/state/1069/pipeline/ \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
```

### State Initialization (Item A, Step 2: pre-red-baseline)

```bash
solve state init ./tmp/state/1069/pipeline/
solve state update ./tmp/state/1069/pipeline/ \
  --var-name current_step --var-value pre-red-baseline \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update ./tmp/state/1069/pipeline/ \
  --var-name previous_step --var-value init \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update ./tmp/state/1069/pipeline/ \
  --var-name pipeline_state --var-value running \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
solve check ...
```

### Full Pipeline Table

| Pipeline Step | Dispatch Target | Artifact |
|---------------|----------------|----------|
| 1. sc-coherence-gate | `adversarial-audit --task coherence-extraction` | `./tmp/artifacts/pipeline-1069-{item}-sc-coherence-gate-{STATUS}-{ts}.yaml` |
| 2. pre-red-baseline | `solve state init` + baseline capture | `./tmp/state/1069/pipeline/state.yaml` |
| 3. red-phase | Write grep tests that FAIL on current content (absence of expected patterns) | `./tmp/artifacts/pipeline-1069-{item}-red-phase-{STATUS}-{ts}.yaml` |
| 4. red-doublecheck | Verify RED evidence is valid | `./tmp/artifacts/pipeline-1069-{item}-red-doublecheck-{STATUS}-{ts}.yaml` |
| 5. green-phase | Apply edits to target file | `./tmp/artifacts/pipeline-1069-{item}-green-phase-{STATUS}-{ts}.yaml` |
| 6. checkpoint-commit | `git add` + `git commit` + rollback tag | Commit in submodule feature branch |
| 7. structural-checks | Markdown lint on modified `.md` files | `./tmp/artifacts/pipeline-1069-{item}-structural-checks-{STATUS}-{ts}.yaml` |
| 8. green-doublecheck | Verify GREEN content is correct | `./tmp/artifacts/pipeline-1069-{item}-green-doublecheck-{STATUS}-{ts}.yaml` |
| 9. green-vbc | SC verification — grep-based for string evidence | `./tmp/artifacts/pipeline-1069-{item}-green-vbc-{STATUS}-{ts}.yaml` |
| 10. adversarial-audit | Verify SCs match spec | `./tmp/artifacts/pipeline-1069-{item}-audit-{STATUS}-{ts}.yaml` |
| 11. cross-validate | Cross-validate against plan | `./tmp/artifacts/pipeline-1069-{item}-cross-validate-{STATUS}-{ts}.yaml` |
| 12. regression-check | Verify pre-existing content preserved | `./tmp/artifacts/pipeline-1069-{item}-regression-check-{STATUS}-{ts}.yaml` |
| 13. review-prep | `git-workflow --task review-prep` | Review-prep status |
| 14. exec-summary | Push to submodule feature branch + issue comment | Push status |

### Rollback Tags

After EACH checkpoint-commit, create a rollback tag:

| Tag | When Created | Purpose |
|-----|-------------|---------|
| `feature/1060-spec-structure-expansion/checkpoint/1069/phase-0-root` | Pre-implementation root | Rollback to pre-fix state |
| `feature/1060-spec-structure-expansion/checkpoint/1069/phase-A-post-creation` | After Item A commit | Rollback post-creation.md changes |
| `feature/1060-spec-structure-expansion/checkpoint/1069/phase-B-write-md` | After Item B commit | Rollback write.md changes |
| `feature/1060-spec-structure-expansion/checkpoint/1069/phase-C-creation` | After Item C commit | Rollback creation.md changes |

### Item Transition Between Pipeline Runs

Between items, reset the pipeline state:

```bash
solve state update ./tmp/state/1069/pipeline/ \
  --var-name previous_step --var-value exec-summary \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update ./tmp/state/1069/pipeline/ \
  --var-name current_step --var-value pre-red-baseline \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update ./tmp/state/1069/pipeline/ \
  --var-name pipeline_state --var-value running \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
solve check ...
```

## Cross-References

- Parent spec: [#1069](https://github.com/michael-conrad/.opencode/issues/1069)
- Stacks on PR: [#1068](https://github.com/michael-conrad/.opencode/pull/1068) (same branch)
- Pipeline state machine: `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`
- Solve tool: `.opencode/tools/solve`
- Create tool: `.opencode/tools/local-issues`

## Checkpoint Rollback for Branch Poisoning

If any pipeline step returns FAIL/BLOCKED:

1. **If a checkpoint tag exists** for the prior PASS state:
   ```
   git reset --hard <tag>
   git submodule update --init
   ```
   Then re-dispatch the failed step with original parameters.

2. **If first-step failure** (no checkpoint tag yet):
   ```
   git checkout .  # clean working tree
   ```
   Then re-dispatch from the current state.

3. **If orchestrator inline work detected** (poisoned pipeline):
   ```
   git reset --hard feature/1060-spec-structure-expansion/checkpoint/1069/phase-0-root
   git submodule update --init
   ```
   Full restart from pre-implementation root.

**Tag location:** Tags are created in the `.opencode` submodule repository. In the parent repo, the dirty submodule pointer indicates which submodule commit the feature branch is on. Rollback in the submodule is:

```bash
cd .opencode && git reset --hard <tag> && cd ..
```