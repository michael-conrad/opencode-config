## Summary

Three categories of local-only changes exist in the parent repo with no spec/issue tracking their lifecycle. All must be committed and their state properly reconciled before they drift too far from `dev`.

## Existing State

### Category A: `.issues/` Cleanup (housekeeping)

**Problem:** The local `.issues/` directory has stale archives, duplicates, and promoted-but-not-moved issues.

| Issue | Problem | Action |
|-------|---------|--------|
| `open/001` | Promoted to GH #57, frontmatter says `closed`, still in `open/` | Move to `closed/` |
| `open/002` | Promoted to GH #60, frontmatter says `closed`, still in `open/` | Move to `closed/` |
| `open/005` | Promoted to GH #62, frontmatter says `closed`, still in `open/` | Move to `closed/` |
| `legacy/001-005` | Duplicates of `open/001-005` with identical content | Remove (archive is stale) |
| `legacy/006/` | Empty directory | Remove |
| `open/004` | Not promoted to GitHub, `needs-approval` | Promote to GitHub issue or close |
| `open/038` | DRAFT 0.1, `needs-approval` | Investigate read-only agent mode or close |
| `open/027` | Synced from GH #27, awaiting approval | Sync status or close |
| `open/028` | Synced from GH #28, awaiting approval | Sync status or close |
| `open/040` | DRAFT, no GitHub issue | Investigate capability-aware auditor selection or close |
| `242/` | Rollback tracking, Gate 1 done | Archive or close |
| `243/` | Piskala reference, already implemented | Archive or close |
| `244/` | Phase-checkpoint tags, revised-needs-approval | Sync with .opencode#391 or close |

### Category B: `docs/auditor-model-qualification/` (deliverable)

Complete adversarial auditor model qualification analysis:
- LaTeX paper (207 lines) with methodology, results, recommendations
- Per-model probe logs and evaluator verdicts (13 model directories)
- `summary.csv` with model qualification status
- PDF output

This is a substantial completed deliverable with no tracking issue. Needs:
1. Committing to the repo with proper attribution
2. Linking to the adversarial-audit skill or spec that motivated it
3. .gitignore for LaTeX build artifacts (`.aux`, `.log`, `.out`, `.synctex.gz`)

### Category C: `tests/behaviors/` (enforcement tests)

5 behavioral enforcement test scripts (RED-phase tests):
- `no-tool-recipe-dispatch.sh`
- `orchestrator-inline-work-poisoned.sh`
- `cost-blind-verification.sh`
- `no-inline-fallback-universal.sh`
- `progressive-iterative-gates.sh`

These test concepts from Spec #386 (correctness-over-economy mandate). Need:
1. Verification they correspond to existing specs/work (cross-reference check)
2. Committing to the repo
3. Integration into enforcement test suite (run-all.sh or test-enforcement.sh)

## Success Criteria

1. `.issues/` directory cleaned: stale archives removed, promoted issues moved to `closed/`, dangling issues resolved (promote, close, or document rationale for keeping)
2. `docs/auditor-model-qualification/` committed with LaTeX build artifacts gitignored and proper attribution/byline
3. `tests/behaviors/` behavioral tests committed and cross-referenced against their source specs
4. All changes made on a feature branch from `dev`, not pushed as submodule-bump-only

## Non-Goals

- This spec does NOT authorize implementing the work items in the .issues/ files themselves (e.g., #244 phase-checkpoint tags). It only tracks the filesystem hygiene of `.issues/` as a directory.
- This spec does NOT modify `.opencode/` submodule content.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)