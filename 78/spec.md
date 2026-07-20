## Problem

The `git-workflow cleanup/branch-cleanup` task file and the clean-room sub-agents it dispatches treat force push (`git push --force`) and remote branch deletion (`git push origin --delete`) as operations requiring explicit developer authorization, even when operating on feature/test/xxx branches during the cleanup pipeline.

Per the user's feedback, this is wrong: non-protected branches (anything except `main`, `master`, `dev`) are ephemeral implementation branches. Destructive git operations on them within the cleanup pipeline should be auto-authorized.

## Current State

`branch-cleanup.md` Step 3.5 shows:
```bash
git branch -d <merged-branch-name>
git push origin --delete <merged-branch-name>
```

Line 211 has a note saying `git push origin --delete` is "authorized as part of the cleanup pipeline scope — no separate authorization required." However, this is not explicit enough — the sub-agent asked anyway.

Additionally, `git push --force` (needed when squashing) is not addressed at all in the cleanup context.

## Success Criteria

- [ ] **SC-1**: `branch-cleanup.md` explicitly states that ALL destructive git operations on non-protected branches (feature/*, chore/*, test/*, investigate/*, spec/*, pair-*, dep-sync/*) are auto-authorized during cleanup pipeline execution
- [ ] **SC-2**: Force push (`git push --force`) on non-protected branches during cleanup is listed as auto-authorized
- [ ] **SC-3**: Remote branch deletion (`git push origin --delete`) on non-protected branches is listed as auto-authorized
- [ ] **SC-4**: Protected branch list is explicitly defined: `main`, `master`, `dev` — these still require authorization per critical-rules-026
- [ ] **SC-5**: Behavioral enforcement test: send prompt simulating cleanup of a feature branch needing force push — verify agent does NOT ask for permission

## Labels

- `opencode-config/opencode` repo: `guidelines`, `skills`, `git-workflow`
- No label needed in `opencode-config` parent repo — this is purely a submodule change
