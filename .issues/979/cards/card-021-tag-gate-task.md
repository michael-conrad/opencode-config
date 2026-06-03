# Card 021: Tag-Gate — Reusable Task for Gate Checkpoints

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** Every gate site (promotion, audit, VbC, review-prep) needs to create a tag and push. One shared task prevents format drift.

## Design

A reusable `tag-gate` task that any other task calls at its gate point. Single source of truth for tag format, creation, and push.

## Interface

```
task: tag-gate
parameters: { issue_number: int, phase: string, platform_type: string }
```

Where `phase` maps to:
- `spec-promoted`  — after promote-to-remote
- `vbc-green`      — after VbC passes
- `audit-passed`   — after dual audit
- `review-ready`   — after review-prep

## Procedure

```
1. Construct tag name: <parent-repo>/<issue>/<phase>
   (parent-repo from github.repo, issue from issue_number, phase from parameter)

2. Create lightweight tag on issues-data HEAD:
   cd .issues/ && git tag <tag-name>

3. Push tag + issues-data branch:
   cd .issues/ && git push origin <tag-name>
   cd .issues/ && git push origin issues-data

4. Return: { tag: <tag-name>, pushed: true }
```

## Callers

| Calling Task | Phase Parameter | When |
|---|---|---|
| creation → promote-to-remote | `spec-promoted` | After remote issue created and local renumbered |
| VbC completion    | `vbc-green` | After all success criteria verified PASS |
| audit completion  | `audit-passed` | After dual auditor consensus PASS |
| review-prep       | `review-ready` | After compare URL generated |
| promote (standalone) | `spec-promoted` | After standalone promotion completes |

## Rules

1. Tags are created on `issues-data` commits only — never on feature branches.
2. Tags are lightweight (no annotations). Annotated tags reserved for future audit verdict metadata if needed.
3. Tags are permanent — never moved, deleted, or overwritten.
4. If `git push` fails (no remote, network error, permissions): warn but do not fail the calling task. The tag is committed locally; push can be retried later.
5. Every gate push includes both the tag AND the issues-data branch reference.

## References

- Card-005: tag convention (format: `<parent-repo>/<issue>/<phase>-<stage>`)
- Card-004: commit vs push model (push-at-gates only)