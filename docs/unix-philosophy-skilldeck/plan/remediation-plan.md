# Incremental Remediation Plan — Unix Philosophy for the Skill Deck

**Paper reference:** docs/paper/paper.pdf §8–9
**Parent tracking:** .opencode issue #248 (Gate Dependency Tree)

---

## Dependency Map

```
Step 1: Guideline progressive disclosure     Step 2: Context-age watermark
   (Gap 1+3, foundational)                      (Gap 6, parallel with Step 1)
        ↓                                              ↓
        └────────────────┬─────────────────────────────┘
                         ↓
                Step 3: Dispatch context hash
                   (Gap 2, independent — can start anytime)
                         ↓
                Step 4: Disjoint trigger patterns
                   (Gap 5+6, depends on Step 1 for reduced text)
                         ↓
                Step 5: GAP-FILLED verification gate
                   (Gap 4, depends on Step 1)
                         ↓
                Step 6: SKILL.md atomicity enforcement
                   (Gap 7, depends on Step 4)
                         ↓
                 Step 7: Contract-based pipeline assembly
                    (structural rigidity, depends on all above)
                         ↓
                 Step 8: Sub-agent role taxonomy
                    (Gap 8, depends on Step 1 and Step 4)
```

## Step Details

### Step 1 — Guideline Progressive Disclosure
**Impact:** Reduces orchestrator context from 67K words → ~1K words (index only)
**Deliverable:** 26 updated .md files + 1 index file
**Gap covered:** 1 (text bloat), 3 (guideline leak)
**#248 mapping:** Complements Gate 2 (Dispatch Temporal Bound) by reducing text volume the bound must manage
**Verification:** `wc -w` scan — index ~1K words vs. current 67K
**Dogfood concern:** Agent runs this step with current (bloated) deck — highest risk of compliance failure

### Step 2 — Context-Age Watermark
**Impact:** Prevents stale-data reliance through structural (not text-based) enforcement
**Deliverable:** Updated `session-enforcement.ts`
**Gap covered:** 6 (stale-data → structural gate)
**#248 mapping:** Plugs into Gate 1.5 (PR API Intercept) mechanism
**Verification:** Behavioral test — agent asked question with stale context, watermark fires, agent must verify or decline

### Step 3 — Dispatch Context Hash
**Impact:** Auditable clean-room dispatch; violations flagged structurally
**Deliverable:** Updated `divide-and-conquer/SKILL.md` + new audit task
**Gap covered:** 2 (clean-room audit trail)
**#248 mapping:** Strengthens Gate 3 (Orchestrator Purity)
**Verification:** Behavioral test — sub-agent receives excluded context → returns BLOCKED

### Step 4 — Disjoint Trigger Patterns
**Impact:** Eliminates ambiguous skill routing; structural precedence replaces model judgment
**Deliverable:** 40 updated SKILL.md frontmatters + conflict-scan tool script
**Gap covered:** 5 (conflict detection), 6 (trigger ambiguity)
**Verification:** Automated scan showing zero overlapping trigger keywords

### Step 5 — GAP-FILLED Verification Gate
**Impact:** Pipeline-created artifacts cannot pass downstream gates without evidence
**Deliverable:** Updated `approval-gate/SKILL.md` + new `verify-gap-filled` task
**Gap covered:** 4 (gap-fill skips verification)
**Verification:** Behavioral test — gap-filled spec passes structural gate but fails verification gate until evidence collected

### Step 6 — SKILL.md Atomicity (≤600 words)
**Impact:** SKILL.md files become routing indexes, not verbose procedure documents
**Deliverable:** Updated `skill-creator` enforcement rule + 45 potentially-updated SKILL.md files
**Gap covered:** 7 (SKILL.md exceeds atomicity threshold)
**Verification:** `wc -w` scan — zero SKILL.md files exceed 600 words

### Step 7 — Contract-Based Pipeline Assembly
**Impact:** Flexible pipeline selection based on spec requirements, not hardcoded sequence
**Deliverable:** New pipeline-assembler script + updated `divide-and-conquer/SKILL.md`
**Gap covered:** Structural rigidity (not a numbered gap — architectural concern)
**Verification:** Behavioral test — spec requiring only plan→implementation skips pre-work; spec requiring full PR includes all stages

### Step 8 — Sub-Agent Role Taxonomy with Curated Skill Permissions
**Impact:** Reduces trigger-keyword overlap 4×–43× per sub-agent. Eliminates cross-role skill conflicts by construction. Reduces skill descriptor context from ~1,350 words → ~120–210 words per sub-agent.
**Deliverable:** 14 Markdown agent files (`.opencode/agents/<role>.md`) with `permission.skill` allowlists. Updated dispatch context in relevant SKILL.md files to specify `subagent_type` instead of defaulting to `general`.
**Gap covered:** 8 (identical sub-agent types), partially 1 (trigger ambiguity via smaller candidate sets), 5 (skill conflicts made impossible by construction), 7 (sub-agent autonomy via curated toolset).
**#248 mapping:** Strengthens Gate 3 (Orchestrator Purity) by making orchestrator the only agent that sees routing/enforcement skills.
**Verification:** Automated scan showing per-agent skill counts. Behavioral test: dispatch `implementer`-type agent, confirm `verification-before-completion` skill not available. Confirm trigger-keyword collision count per agent type.

## Alignment with Existing Plan #159

| #159 Phase | Overlap with these steps |
|------------|------------------------|
| Phase 0 — Baseline audit | Pre-work for all steps |
| Phase 1 — Mandatory invocation | Partial overlap with Step 4 (trigger semantics) |
| Phase 3 — Dispatch chain gates | Partial overlap with Step 3 (context-hash) |
| Phase 5 — Critical violations | Partial overlap with Step 1 (progressive disclosure of critical rules) |
| Phase 6 — Enforcement tests | Required for ALL steps (behavioral TDD) |

**New contributions beyond #159:**
1. Progressive disclosure for ALL 26 guidelines (not just the 2 already lazy-loaded)
2. Structural runtime enforcement (context-age watermark, dispatch-context hash) rather than guideline-text enforcement
3. SKILL.md atomicity reduction from 2,100-word average to ≤600-word limit

## Execution Protocol

Each step follows the deck's own workflow:

```
Step N → spec issue → approval → plan → worktree → sub-agent dispatch
       → verification → review-prep → HALT
```

The agent modifies `.opencode/` files using the same pipeline it is improving.
Early steps (0a–3) run with the current deck; later steps (4–8) benefit from
reductions already applied.

**Tension resolution (structural routing vs. agent-driven discovery):**
Steps 1–4 and 6–8 apply structural routing (fixed pipeline stages with known
pre-conditions).  Issue #80's agent-driven graph discovery applies to the
cleanup workflow (open-ended graph traversal where relationship patterns
are unbounded).  Both are correct for their respective domains; the key
invariant is not confusing them.

## New Dependencies (Discovered May 1, 2026)

Four issues were discovered during attempted behavioral verification of #274/#276 and subsequent violation analysis:

```
Step 0a: Seed model config in with-test-home    (#294)
           (Gap 3 — no config = no tests can run)
              ↓
Step 0b: Guard assertions against empty output    (#296)
           (Gap 6 — false PASS same class as #91)
              ↓
Step 0c: Revise RED/GREEN TDD for INCONCLUSIVE   (#295)
           (Gap 6 — instructions assume binary PASS/FAIL)
              ↓
Step 0d: Document chain-of-thought rationalization as architectural root cause (#297)
           (Gap 6 — mechanism enabling ALL above defects)
              ↓
         ALL existing Steps 1–7
```

#297 is the **architectural parent** of the seven violations in the May 1 session.  It documents the mechanism — agent reads text rules, reasons about whether they apply during chain-of-thought, rationalizes bypass — that enables all existing issues (#91, #154, #106, #274, #295, #296).  While #297 requires no code changes (it is documentation and cross-reference), it must exist before implementing any step so that future work correctly attributes violations to the mechanism rather than treating them as isolated incidents.

## Priority

| Priority | Step | Rationale |
|----------|------|-----------|
| P0 | 0a, 0b, 0c | Prerequisite — no behavioral tests can execute without model config; no reliable signals without assertion guards; no valid RED/GREEN cycle without INCONCLUSIVE path |
| P0 | 0d | Architectural — documents the rationalization mechanism enabling all defects; links as parent to all manifestation issues |
| P0 | 1, 2, 3 | Foundational — must reduce bloat and add structural enforcement before anything else |
| P1 | 4, 5 | Build on foundation — requires reduced text volume from Step 1 |
| P2 | 6, 7 | Polish — refines granularity and flexibility after core problems are solved |
