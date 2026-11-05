> **Full spec and artifacts: [`.issues/1188/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1188)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1188/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Summary

The pre-image of `pre-implementation-analysis.md` (before commit `a92978eb` Phase 3 decomposition) contained an "Already-Implemented Closure Decision" table that specified how to close already-implemented issues. This was lost during decomposition.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `pre-impl/reconcile-status.md` contains the already-implemented closure decision table with all 5 scenarios | `string` |
| SC-2 | `reconcile-status.md` procedure includes Step 2.5 for closure path determination | `string` |
| SC-3 | Behavioral test: multi-issue authorization set with an already-implemented issue → agent routes to correct closure path | `behavioral` |
