# Issue Restructuring Plan — Paper Alignment

The 46 open `.opencode` issues need restructuring to follow the paper's
incremental model. Below is a triage: which issues align, which need
restructuring, and what the low-hanging fruit is.

---

## Low-Hanging Fruit (zero runtime infrastructure changes)

These issues require only guideline text, SKILL.md frontmatter, or task file
edits. No TypeScript plugin changes, no CLI-harness modifications. All can
be dispatched as clean-room sub-agents with the current infrastructure.

| Issue | What | Paper Gap | Why Low-Hanging |
|-------|------|-----------|-----------------|
| #152 | Universal SCP rule | Gap 5 (skill conflict) | Replace fragmented concern-separation rules with one consolidated rule. Text-only. One guideline file edit. |
| #210 | Remove skill discovery bypass | Gap 6 (trigger ambiguity) | Delete one bypass path in session-enforcement.ts. The bypass *exists* in the plugin but the removal is surgical. |
| #207 | SKILL.md frontmatter validation | Gap 7 (SKILL.md atomicity) | Fix missing frontmatter fields. Mechanical validation → mechanical fix. Script-assisted. |
| #211 | Rename completion-core.md to SKILL.md | Gap 7 (atomicity) | One file rename. No content change. |
| #154 | Remove VERIFICATION-GAP markers | Gap 6 (text-based → structural) | Text replacement in guideline files. Remove the escape hatch that lets agents publish unverified claims. |
| #219 | Mandatory checkbox sections in issue bodies | Gap 3 (guideline leak) | Add structural markers to spec/plan templates. The agent reads these, not reason about them. |
| #158 | Architectural regression restoration | All gaps | Partially implemented (#159 sub-issues). Remaining work: restore mandatory invocation language, verify against baseline. |

### Recommended restructure for #158/#159

The #159 plan has 12 phases spread across 9 sub-issues. The paper's model
says: one concern per step, independently verifiable. The 12 phases should
be **independent issues**, not sub-issues of a monolithic plan. Each phase
gets its own spec, its own plan, and its own verification cycle.

**Current:** #159 → 9 sub-issues covering 12 phases  
**Proposed:** 12 independent issues, each a single concern, linked via body
reference ("Phase N of #158 restoration"), not via sub-issue linkage

---

## Medium-Hanging Fruit (small plugin changes)

These require modest session-enforcement.ts changes. The plugin already has
a hook system; these add one check per gate.

| Issue | What | Paper Gap | Effort |
|-------|------|-----------|--------|
| #248 Gate 1.5 | PR API intercept checking dispatch marker | Gap 2 (clean-room audit) | ~20 lines in session-enforcement.ts |
| #248 Gate 2 | Dispatch temporal bound | Gap 1 (text bloat) | ~30 lines in session-enforcement.ts. Tool-call counter, reset on dispatch. |
| #153 | Auth errors must HALT, not downgrade | Gap 4 (gap-fill skips verification) | ~10 lines. If/else → early return on auth failure. |

---

## Structural (need new infrastructure)

These require new mechanisms that don't exist yet. They're the paper's
endgame but not the starting point.

| Issue | What | Paper Gap | Prerequisites |
|-------|------|-----------|----------------|
| #106 | Universal clean-room dispatch | Gap 2 (audit trail) | Context-hash mechanism (Step 3) |
| #91 | Proxy evidence regression | Gap 6 (stale data) | Context-age watermark (Step 2) |
| #80 | Agent-driven graph discovery | Separate domain | Not structural routing — this is agent-driven discovery for open graph traversal |
| #248 Gate 3+4 | Orchestrator purity + evidence gate | Gaps 2+6 | All prior gates complete |

---

## Issues That Don't Need Restructuring (already aligned)

| Issue | Why aligned |
|-------|-------------|
| #179 | Prose over templates — the paper's "structural ≠ template-rigid" distinction resolves this tension |
| #248 | Gate dependency tree — exactly the incremental model the paper recommends |
| #242 | Production evidence — the paper already cites it |
| #86 | Local-first issue architecture — orthogonal; not blocked by paper recommendations |
| #60 | Track branch model — orthogonal |
| #203 | Copyright headers — orthogonal |

---

## New Issues (Discovered May 1, 2026)

| Issue | What | Paper Gap | Classification |
|-------|------|-----------|----------------|
| #294 | Seed model config in with-test-home | Gap 3 (infrastructure leak) | Low-hanging — one file, bash logic, schema-validated template |
| #296 | Guard assertions against empty dispatch output | Gap 6 (false PASS = proxy evidence) | Medium — two files, dispatch-failure gate + assertion guards + exit code convention |
| #295 | Revise RED/GREEN TDD for INCONCLUSIVE path | Gap 6 (instructions assume success) | Low-hanging — three guideline text edits, no infrastructure changes |
| #297 | Document chain-of-thought rationalization as architectural root cause | Gap 6 (mechanism enabling all defects) | Documentation — zero code changes, cross-reference linking only |

**Priority ordering:** #294 → #296 → #295 → #297.  #294 unblocks all tests.  #296 makes signals reliable.  #295 aligns instructions with reliable signals.  #297 documents the rationalization mechanism as the architectural parent of all four.  #297 can proceed in parallel with 294/296/295 since it requires no code changes.

## Recommended First Action

**Replaced by May 1 findings.**  New first priority — dispatch a clean-room sub-agent to fix #294 (seed model config in with-test-home).  Until this is done, no test in the repository can execute.  Then #296, then #295, then resume original plan:

**Original plan — deferred:**

**Immediate:** Dispatch a clean-room sub-agent to fix #211 (rename file).
This is one operation, one concern, zero risk, measurable. Use the existing
dispatch chain. Record the experiment in `experiment-log.md`.

**Then:** In sequence, each as an independent sub-agent dispatch:
1. #207 (validate + fix frontmatter)
2. #154 (remove VERIFICATION-GAP markers)
3. #210 (remove skill discovery bypass)
4. #152 (consolidate SCP rule)

Each step produces a commit, a verification pass, and an experiment entry.

**Parallel track:** Restructure #159's 12 phases into independent issues
so they can be dispatched individually rather than as a monolithic plan.
