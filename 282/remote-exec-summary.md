> **Full spec and artifacts: [`.issues/282/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/282/)**
>
> **Local artifacts:** `.issues/282/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

The session-init tool emits a `## Local Issue Artifacts` section with verbose YAML-like structured fields that duplicate information already present in `## Repo Information`. The section name doesn't convey the worktree nature of `.issues/` directories. This spec proposes renaming to `## Local Issue Folders`, switching to inline `git -C` commands, reordering sections, and removing the redundant `path` field.

### Cards (dependency order)
1. **Rename section and change output format** — `## Local Issue Artifacts` → `## Local Issue Folders` with inline `git -C` commands
2. **Reorder sections** — `## CLI Auth Status` first, `## Local Issue Folders` second, `## Repo Information` third
3. **Remove `path` field** — derivable from `## Repo Information` block

### Key Decisions
- **Inline `git -C` commands over structured YAML**: Makes the worktree nature explicit — agents can copy-paste the command directly
- **Reorder sections**: CLI auth status is the most actionable info for an agent (can it push?), followed by local issue folders, then repo routing info

### Risk Callouts
- **Risk A**: Downstream consumers parsing the current structured format will break. Mitigation: search for consumers before changing format.
- **Risk B**: The `setup` key for missing `.issues/` directories needs a new representation in the inline format. Mitigation: include setup instructions as a comment in the inline format.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/282/`.
After creation, `local-issues sync 282` MUST be run and the result committed to create the local `.issues/282/` entry.
The implementation plan will be created in `.issues/282/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.
