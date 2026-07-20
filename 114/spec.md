## Problem

Sub-agents pushed their feature branches to remote during `finishing-a-development-branch/prepare.md` Step 4, which then led them to create individual PRs instead of returning to the orchestrator.

The sub-agent should **commit locally only, never push**. The orchestrator's assembly phase (squash-merge into work branch) does the push.

## Expected Behavior

Per `assemble-work.md` Step 3, sub-agent responsibilities:
> Make WIP commits → Run verification-before-completion → Run finishing-a-development-branch checklist → **Return structured result**: `{status, files_changed, summary}`

The sub-agent commits locally. The orchestrator handles the push during assembly.

## What's Actually Happening

1. Sub-agent implements, commits ✅
2. `finishing-a-development-branch/prepare.md` Step 4: `git push -u origin <branch>` ❌ — should not push
3. Sub-agent's branch now exists on remote → sub-agent reads "Ready for PR?" → creates individual PR ❌
4. Competing PRs for what should be a single stacked PR

## Root Cause

`finishing-a-development-branch/prepare.md` Step 4 pushes unconditionally. In a stacked sub-agent context, the push step must be skipped — the sub-agent should only commit, verify, self-review, and return.

## Success Criterion

**SC-1:** Sub-agents in `assemble-work` with `pr_strategy = stacked` MUST NOT push their branches. They commit locally, verify, self-review, and return `{status, files_changed, summary}`.

## Affected File

**Repo: `michael-conrad/.opencode`** (submodule)

| File | Change |
|------|--------|
| `skills/finishing-a-development-branch/tasks/prepare.md` | Step 4 — remove or conditionally skip the `git push -u origin <branch>` step when running as a sub-agent in a stacked workflow |

## Investigation Trace

- `assemble-work.md` Step 3.6 (completion checkpoint): handles sub-agent abnormal termination but does not prohibit pushing
- `implementer-prompt.md`: instructs "Commit your work → Self-review → Report back" — does NOT say "do NOT push, do NOT create PR"
- `finishing-a-development-branch/prepare.md` Step 4: `git push -u origin <branch>` — unconditional push, no `pr_strategy` awareness
- `finishing-a-development-branch/checklist.md`: "Branch pushed ✓", "Compare URL generated ✓", "Ready for PR?" — no `pr_strategy` scoping
