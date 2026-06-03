# Card 013: Update — Separate from Push-Body

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** spec.md and remote.md serve different audiences — full detail vs exec summary. Update and push-body are distinct operations touching different files.

## Separation of Concerns

| Operation | File Modified | Audience | Purpose |
|---|---|---|---|
| `local-issues update N --body "..."` | spec.md | Agent / local workspace | Full fidelity — spec, plans, models, cards, edge cases |
| `local-issues update N --title "..."` | spec.md frontmatter | Both | Title is shared |
| `local-issues update N --status closed` | spec.md frontmatter | Both | Status is shared |
| `local-issues update N --phase draft` | spec.md frontmatter | Local only | Workflow phase never goes to remote |
| `local-issues update N --labels "..."` | spec.md frontmatter | Both | Labels are shared |
| `local-issues push-body N` | remote.md | Stakeholders on remote API | Exec summary version of spec |
| `local-issues extract-exec-summary N` | reads spec.md, writes remote.md | Intermediate step | Converts full spec → stakeholder version |

## Flow for Body Changes

```
1. task: update (--body "...")          # modifies spec.md
2. task: extract-exec-summary           # reads spec.md, writes remote.md
3. task: push-body                      # pushes remote.md to remote API
```

## Flow for Metadata Changes (title, labels, status)

```
1. task: update (--title "...")         # modifies spec.md frontmatter + remote frontmatter
2. task: push-metadata                  # pushes title/labels/status to remote API
```

## Flow for Local-Only Changes (phase)

```
1. task: update (--phase draft)         # modifies spec.md frontmatter only
2. (no remote sync needed)
```

## References

- Card-008: sync redesign (push-body / pull-body naming)
- Card-010: creation skill card (three-scenario dispatch — promote-to-remote also uses push-body in Step 5)