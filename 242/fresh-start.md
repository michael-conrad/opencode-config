# Fresh-Start Info — Issue #242 Rollback Recovery

## Essential Session Context

### Repository Identity
- github.owner: michael-conrad
- github.repo: opencode-config (parent), .opencode (submodule)
- github.platform: github
- github.identity_source: root

### Submodule
- Path: .opencode/
- Remote: git@github.com:michael-conrad/.opencode.git
- Branch track: dev (never detached HEAD, never main)
- Current dev HEAD: 43dd266 (post Gate 1 merge)

### Key Issues
- #242: [Rollback] Master tracking — 35 reopened issues, phases, SCs
- #244: [SPEC] Gate 1 ✅ — closed (PR #247 merged)
- #248: [TRACKING] Gate dependency tree — authoritative ordering

### Gate Dependency Chain
1. Gate 1: Dispatch-Entry Pre-Commit Hook ✅ DONE
2. Gate 1.5: PR API Intercept (session-enforcement.ts) ← NEXT
3. Gate 2: Dispatch Temporal Bound (Implementation-First)
4. Gate 3: Orchestrator Purity (Inline Work Detector)
5. Gate 4: Dispatch-Completion + Evidence Gate

### Workflow Per Gate
brainstorm → spec → plan → implement → PR → release PR
One gate at a time, dependency-ordered. No cherry-picking.

### Key Decisions
- One gate, one invariant, one mechanism (Unix principle)
- No uber-gates — Gate 4 was disabled due to regex false positives
- Simple Work Dispatch Path removed — single unified dispatch chain
- dispatch-<safe-branch>.marker file in .opencode/tmp/ (gitignored)
- .issues/ is per-issue tracking (test results, state, restart context)
- .issues/ exempt from worktree, exempt from dispatch marker gate
- .issues/ requires feature branch (cannot commit to main/dev)
- GitHub sub_issue_write API returned 404 — formal sub-issue linking unavailable; use body text cross-references instead

### Rollback State
- Restored to 1860c0d
- 35 issues reopened
- Tag: pre-rollback-2026-04-29 at 5edc1c6
- No cherry-picking from rolled-back commits

### Conventions
- .issues/<issue-number>/ per issue with test-results.md + state.md
- Gate marker: .opencode/tmp/dispatch-<safe-branch>.marker
- Branch names: spec/<N>-<description> for specs
- Always use uv run python (never bare python)
- No echo/printf/sed -i/heredocs
