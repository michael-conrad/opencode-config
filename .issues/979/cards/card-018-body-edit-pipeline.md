# Card 018: Body-Edit Pipeline — Remote.md Only, Four Sub-Agent Sequence

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** Edits to the exec summary (remote.md) go through a structured four-step pipeline. Edits to the full spec (spec.md) go through the update task.

## Separation

| File | Edit Path | Audience |
|---|---|---|
| spec.md | `local-issues update N --body "..."` | Local workspace — full detail |
| remote.md | `body-edit` pipeline → `push-body` | Stakeholders — exec summary |

## Pipeline

One skill task: `body-edit`. Internally manages four phases via sub-agents. The orchestrator dispatches once and receives one result contract.

```
orchestrator
  │
  └─ task: body-edit (issue_number=N, edit_script="...")
       │
       ├─ phase 1: fetch sub-agent
       │    → reads .issues/N/remote.md
       │    → returns { current_body, remote_md_path, issue_number }
       │
       ├─ phase 2: transform sub-agent
       │    → applies edit_script to remote.md
       │    → returns { success, summary_of_changes }
       │
       ├─ phase 3: verify sub-agent
       │    → structural integrity check:
       │      - no null bytes / binary corruption
       │      - no YAML frontmatter (remote.md is pure markdown)
       │      - body content non-empty
       │    → returns { pass, issues }
       │
       └─ phase 4: post sub-agent
            → local-issues push-body N
            → returns { sync_status: pushed|failed, url }
       │
       └─ returns: { sync_status, url }  (single result contract to orchestrator)
```

## Rule

Body-edit never touches spec.md. Edits to spec.md go through `local-issues update N --body "..."`, then `extract-exec-summary` regenerates remote.md from the updated spec, then `push-body` sends it to the remote.

## References

- Card-013: update separate from push-body
- Card-008: sync redesign (push-body)