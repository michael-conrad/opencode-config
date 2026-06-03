# Card 014: Comment — Type Flag, Default Internal

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** Classification gate determines stakeholder vs internal routing

## Tool Interface

```
local-issues comment N --body "..." [--type stakeholder|internal]
```

- `--type internal` (default): Appends to `.issues/N/comments.md` only. No remote action.
- `--type stakeholder`: Appends to `.issues/N/comments.md`, then updates `remote.md` with the stakeholder-facing comment entry, then auto-pushes `remote.md` to remote API.

## Default Behavior

Default is `internal` — conservative. Stakeholder-visible content is additive (can be promoted later). Internal content posted publicly cannot be retracted.

## Classification Responsibility

The skill card classifies the comment and sets the `--type` flag. The tool does not classify — it executes the type it's given.

Classification rules (per existing comment.md substantiveness gate):
- Stakeholder: information a reviewer needs to act on, completion reports, approval requests
- Internal: agent reasoning, design analysis, corrections, process metadata, decision log entries

## Flow

Internal comment:
```
local-issues comment 979 --body "Design analysis complete" --type internal
→ appends to comments.md only
→ no remote push
```

Stakeholder comment:
```
local-issues comment 979 --body "Ready for review" --type stakeholder
→ appends to comments.md
→ appends to remote.md
→ pushes remote.md to remote API
```

## References

- Card-008: sync redesign (push-body)
- Card-013: update separate from push-body (remote.md as stakeholder-facing artifact)