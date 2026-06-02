# Card 010: Creation Skill Card — Three-Scenario Dispatch

**Date:** 2026-06-01
**Status:** DESIGNED (Phase 2)
**Origin:** Brainstorming session — designing the creation skill card from scratch

## Architecture

The `creation.md` dispatcher routes to three scenarios based on platform type and issue state. It never makes API or git calls directly — it dispatches to task sub-agents.

```
creation.md (dispatcher)
  │
  ├─ Scenario A (local-only draft)
  │   → task: create-local
  │     parameters: title, labels
  │
  ├─ Scenario B (promote draft → remote)
  │   → task: promote-to-remote
  │     parameters: local_number, exec_summary_body, platform_type
  │
  └─ Scenario C (remote-first import)
      → Step 1: task: pre-creation (dual dedup)
      → Step 2: task: import-remote (on CLEAN)
        parameters: remote_number, platform_type
```

## Dispatch Table

| Condition | Route | Parameters |
|---|---|---|
| Platform is `local` OR user explicitly requested local-only draft | Scenario A → `create-local` | title, labels |
| Local draft exists with phase `draft`, user says "promote" / "create the spec" | Scenario B → `promote-to-remote` | local_number, exec_summary_body, platform_type |
| Platform is `github` or `gitbucket` and remote issue R already exists | Scenario C → `pre-creation` then `import-remote` | remote_number, platform_type |

## Task: create-local (Scenario A)

*Local-only draft creation. No API calls. No remote.*

| Step | Operation | Details |
|---|---|---|
| 1 | Dedup check | `local-issues search --query "<keywords>"` → non-empty = DUPLICATE → HALT |
| 2 | Create issue | `local-issues create --title "..." --labels "..."` → captures local number N |
| 3 | Write spec.md | Full fidelity spec body |
| 4 | Write state.md | `phase: draft` |
| 5 | Verify | `local-issues read N` → exit 0 = PASS |

**Result:** Local issue N in draft phase. No remote exists.

## Task: promote-to-remote (Scenario B)

*Promote a local draft to remote. Renumbers locally to match remote number.*

| Step | Operation | Details |
|---|---|---|
| 1 | Verify promotable | Phase is `draft` or `ready-to-promote`, no TBD/TODO |
| 2 | Create remote issue | API call per platform, body = exec summary, label = `needs-approval` |
| 3 | Renumber local | `local-issues renumber N --to R` — renames dir, updates frontmatter |
| 4 | Update metadata | Set `github_issue`, `remote_url`, `phase: promoted` |
| 5 | Push exec summary | Write `remote.md`, `local-issues push-body R` |
| 6 | Tag gate | `<parent-repo>/R/spec-promoted` tag + push |
| 7 | Verify | `local-issues read R` confirms all metadata |

**Result:** Local `.issues/R/` linked to remote issue R. Phase is `promoted`.

## Task: pre-creation (cross-context dedup)

*Dual dedup search — local `.issues/` + remote API. Called as separate sub-agent when cross-context search is needed.*

| Step | Operation | Details |
|---|---|---|
| 1 | Search local | `local-issues search --status open --query "<keywords>"` |
| 2a | Search GitHub (if applicable) | `issue-operations → search-issues` |
| 2b | Search GitBucket (if applicable) | `gitbucket-api issues --state open`, client-side filter |
| 3 | Classify all candidates | EXACT-DUPLICATE / NEAR-DUPLICATE / CLOSED-IN-ERROR / RELATED-BUT-DISTINCT / FALSE-POSITIVE / NO_CANDIDATES |
| 4 | Return | CLEAN (proceed) or CONFLICT (HALT with candidates) |

**Result:** CLEAN → dispatcher proceeds. CONFLICT → dispatcher halts with findings.

## Task: import-remote (Scenario C)

*Mirror an existing remote issue into local `.issues/`.*

| Step | Operation | Details |
|---|---|---|
| 1 | Fetch remote issue | API call per platform → extract title, body, html_url, state, labels |
| 2 | Fetch remote comments | API call per platform → collect all comments |
| 3 | Create local with remote number | `local-issues create --number R --title "..."` — uses remote number |
| 4 | Write spec.md mirror | Remote body as full fidelity mirror |
| 5 | Write comments.md | All comments in chronological order |
| 6 | Write remote.md | Exec summary from remote body |
| 7 | Write state.md | `phase: promoted`, `promotion_type: retroactive_import` |
| 8 | Update frontmatter | Set `github_issue`, `remote_url` |
| 9 | Verify | Body matches, comments match |

**Result:** Local `.issues/R/` mirrors full remote issue. No data loss.

## Gate Pattern

| Gate Type | Handled By | Example |
|---|---|---|
| Internal pre-condition (single source) | Task sub-agent | "Verify phase is draft before promoting" |
| Cross-context gate (multiple sources) | Separate sub-agent | "Search local AND remote for duplicates" |
| Between-task transition | Orchestrator dispatcher | "After creation → route to approval" |