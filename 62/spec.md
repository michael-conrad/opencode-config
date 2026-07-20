## Summary

Update the `.opencode` submodule from `c8f90d9` to `ef8e92e`, incorporating the merged PRs that implement the local-first issue creation architecture.

## Submodule Update

| Property | Value |
|----------|-------|
| Previous SHA | `c8f90d9` |
| New SHA | `ef8e92e` |
| Remote | `michael-conrad/.opencode` |

## Merged PRs

| PR | Title | Issue |
|---|---|---|
| #463 | Gap-fill cascade path selection fix | #460 |
| #464 | Identity model simplification | #86 |
| #465 | Local-first issue creation architecture | #86 |
| #467 | Bidirectional sync foundation | #86 |

## Underlying Issues

All underlying issues are closed:
- #86 — Local-first issue creation architecture
- #460 — Gap-fill cascade path selection
- #462 — Related fixes

## Changes Summary

This update brings the local-first issue creation architecture implementation to `opencode-config`, enabling:

1. **Gap-fill cascade path selection** (#463, fixes #460) — Correct path selection in cascade lookups
2. **Identity model simplification** (#464, from #86) — Streamlined identity resolution
3. **Local-first issue creation** (#465, from #86) — Core local-first issue tracking
4. **Bidirectional sync foundation** (#467, from #86) — Sync infrastructure for local/remote coordination