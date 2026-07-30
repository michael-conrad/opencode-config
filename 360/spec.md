> **Full spec and artifacts: [`.issues/360/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/360)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/360/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC-FIX] Document submodule-only push bypass as CRITICAL VIOLATION in AGENTS.md

## Objective

Document the "Submodule-only push bypass — CRITICAL VIOLATION" lesson in the root repo `AGENTS.md` under Testing Lessons Learned, formalizing the prohibition against using `--no-verify` to bypass the pre-push hook on submodule-only pushes.

## Background

The pre-push hook in `.opencode/hooks/` blocks submodule-only pushes because submodule-only PRs create review overhead with zero functional change. When a submodule PR is already merged, the work is done — no pointer-only PR is needed. Pointer updates happen naturally alongside the next real parent-repo change.

A pattern emerged where agents, blocked by the pre-push hook, attempted `--no-verify` to bypass it. This is a CRITICAL VIOLATION because:

1. The hook exists for a structural reason — submodule-only PRs waste review cycles
2. `--no-verify` bypasses the quality gate designed to catch this pattern
3. A blocked push means the hook is working correctly — the agent should investigate why, not bypass it

The change is already implemented in `AGENTS.md` (root repo). This spec documents the change retroactively.

## Not Included

- Changes to the pre-push hook itself (already exists and works correctly)
- Changes to `critical-rules-049` in `.opencode/guidelines/000-critical-rules.md` (already covers the submodule-only PR prohibition)
- Behavioral enforcement tests (the lesson is documentation-only; existing enforcement mechanisms already cover the behavior)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | AGENTS.md contains a "Submodule-only push bypass — CRITICAL VIOLATION" section under Testing Lessons Learned | `string` | grep for "Submodule-only push bypass" in AGENTS.md |
| SC-2 | The lesson explicitly states that `--no-verify` to bypass the pre-push hook on a submodule-only push is never correct | `string` | grep for "--no-verify" in the lesson section of AGENTS.md |
| SC-3 | The lesson references `.opencode/AGENTS.md §Submodule Pointer Updates` as the canonical source for the pointer update policy | `string` | grep for "Submodule Pointer Updates" in the lesson section of AGENTS.md |
| SC-4 | The lesson explains why the hook exists (submodule-only PRs create review overhead with zero functional change) | `string` | grep for "review overhead" or "zero functional change" in AGENTS.md |
| SC-5 | The lesson states that a blocked push means the hook is working correctly — investigate why, don't bypass it | `string` | grep for "blocked push means the hook is working correctly" in AGENTS.md |

## Requirements

1. The AGENTS.md SHALL contain a "Submodule-only push bypass — CRITICAL VIOLATION" subsection under "Testing Lessons Learned"
2. The lesson SHALL state that using `--no-verify` to bypass the pre-push hook on a submodule-only push is never correct
3. The lesson SHALL reference `.opencode/AGENTS.md §Submodule Pointer Updates`
4. The lesson SHALL explain the rationale: submodule-only PRs create review overhead with zero functional change
5. The lesson SHALL state that a blocked push means the hook is working correctly — agents must investigate why, not bypass it

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Add "Submodule-only push bypass — CRITICAL VIOLATION" section to AGENTS.md Testing Lessons Learned |
| 2 | SC-2 | Include `--no-verify` prohibition language |
| 3 | SC-3 | Reference `.opencode/AGENTS.md §Submodule Pointer Updates` |
| 4 | SC-4 | Explain hook rationale (review overhead, zero functional change) |
| 5 | SC-5 | State that blocked push = hook working correctly |

## Dependencies

- `.opencode/hooks/pre-push` — The pre-push hook that blocks submodule-only pushes (already exists)
- `critical-rules-049` in `.opencode/guidelines/000-critical-rules.md` — Standalone submodule-only PR prohibition (already exists)
- `.opencode/AGENTS.md §Submodule Pointer Updates` — Canonical pointer update policy (already exists)

## Traceability

| Requirement | SC | Item |
|-------------|----|------|
| R1 | SC-1 | 1 |
| R2 | SC-2 | 2 |
| R3 | SC-3 | 3 |
| R4 | SC-4 | 4 |
| R5 | SC-5 | 5 |
