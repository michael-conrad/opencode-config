# Implementation Plan: [SPEC] Procedural Discipline Reference Card — Audit Remediation

**Source:** #853 (michael-conrad/.opencode)
**Target file:** `.opencode/guidelines/257-procedural-discipline-reference.md`
**Branch:** `feature/853-procedural-discipline` (submodule: .opencode)
**Status:** COMPLETE — all 16 SCs verified PASS via dual cross-family audit (mistral-large + gemma4, consensus clean)

---

## Audit Findings Summary

| SC | Finding | Severity | Fix Required |
|----|---------|----------|-------------|
| SC-6 | Section 8 (Re-Research Mandate) has wrong protocol — uses catalog-reconsult protocol instead of spec's research-currency-check protocol | FAIL | Rewrite Section 8 |
| SC-7 | Section 4 (Co-Application Rules) references only 250, missing 255 | FAIL | Add 257 + 255 co-application rule |
| SC-16 | Section 13 (Research Basis) contains only internal guideline references, no external citations | FAIL | Replace with spec's verified external citations |

---

## Phase 1: Fix SC-16 — Section 13 Research Basis

**Concern boundary:** External citation completeness. The current Section 13 has 14 rows all pointing to internal guideline files. The spec requires verified external citations matching what sources actually say. The spec body provides 14 verified citations with confirmed claims.

### RED
- Write content-verification test: `grep` Section 13 for at least 3 external URLs (`arxiv.org`, `anthropic.com`, `trychroma.com`)
  - Assertion: test FAILS because current file has 0 external URLs

### GREEN
- Replace entire Section 13 with the spec body's verified citations (14 sources from Issue #853 body)
- Structure matches spec: context degradation, self-correction, multi-agent failures, sycophancy, safety tax, prompt engineering, failure analysis
- Preserve the note about section anchors (update to reflect external URLs)
- Keep Section 13 header and structure, replace content

**File:** `.opencode/guidelines/257-procedural-discipline-reference.md`
**Lines:** 295-316 (Section 13 + trailing note)

**Exact replacement content:**

```
## Section 13: Research Basis (Verified Citations with URLs Only)

Each citation listed below has been verified by fetching the source page and confirming the claim matches the abstract or visible content.

**Context degradation and positional effects:**
- Liu et al. (2024), "Lost in the Middle: How Language Models Use Long Contexts" — TACL 2024, https://arxiv.org/abs/2307.03172
  - Verified claim: performance highest at beginning or end, significantly degrades for mid-context information
- Chroma (Hong, Troynikov, Huber, 2025), "Context Rot: How Increasing Input Tokens Impacts LLM Performance" — https://www.trychroma.com/research/context-rot
  - Verified claim: all 18 frontier models degrade with increasing input length

**Self-correction ineffectiveness:**
- Kamoi et al. (2024), "When Can LLMs Actually Correct Their Own Mistakes? A Critical Survey of Self-Correction of LLMs" — TACL 2024, https://arxiv.org/abs/2406.01297
  - Verified claim: no prior work demonstrates successful self-correction with prompted LLMs alone; reliable external feedback enables it
- Kim (2025), "Does Metacognition Improve LLM Performance?" — https://github.com/kimjune01/metacognition
  - Verified claim: framework condition 0.30 vs filler condition 0.65

**Multi-agent failures:**
- Cemri et al. (2025), "MAST: Why Do Multi-Agent LLM Systems Fail?" — https://arxiv.org/abs/2503.13657
  - Verified claim: 14 failure modes in 3 categories (system design, inter-agent misalignment, task verification)
- Zhu et al. (2025), "AgentErrorTaxonomy: Where LLM Agents Fail and How They can Learn From Failures" — https://arxiv.org/abs/2509.25370

**Sycophancy:**
- Sharma et al. (2024), "Towards Understanding Sycophancy in Language Models" — ICLR 2024, https://arxiv.org/abs/2310.13548
  - Verified claim: five SOTA assistants consistently exhibit sycophantic behavior
- Vennemeyer et al. (2025), "Sycophancy Is Not One Thing: Causal Separation of Sycophantic Behaviors in LLMs" — https://arxiv.org/abs/2509.21305
  - Verified claim: sycophantic behaviors correspond to distinct, independently steerable representations

**Safety tax and over-enforcement:**
- Wang et al. (2025), "Safety Tax: Safety Alignment Makes Your Large Reasoning Models Less Reasonable" — https://arxiv.org/abs/2503.00555
  - Verified claim: safety alignment degrades reasoning capability
- Anonto et al. (2025), "When Safety Blocks Sense: Measuring Semantic Confusion in LLM Refusals" — https://arxiv.org/abs/2512.01037
  - Verified claim: over-refusal blocks benign requests; strict safety can cause inconsistency

**Prompt engineering and re-priming:**
- Anthropic (2024), "Building Effective Agents" — https://www.anthropic.com/research/building-effective-agents
  - Verified claim: successful implementations use simple, composable patterns
- Anthropic (2025-2026), "Be Clear and Direct" — https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/be-clear-and-direct
  - Verified claim: role-setting in system prompt focuses behavior; positive framing over negative

**Failure analysis taxonomies:**
- ErrorMap/ErrorAtlas (Ashury-Tahan et al., 2026), "ErrorMap and ErrorAtlas: Charting the Failure Landscape of Large Language Models" — https://arxiv.org/abs/2601.15812
```

### REFACTOR
- Verify all 14 external URLs are present
- Verify the trailing note and byline remain intact
- Update Section 9 version to 1.1 with SHA placeholder

---

## Phase 2: Fix SC-7 — Section 4 Co-Application Rules

**Concern boundary:** Cross-card reference completeness. Current Section 4 has rules for 257+250 and 257+agency-respecting but no rule for 257+255.

### RED
- Write content-verification test: `grep` Section 4 for `255-distribution-shifting-reference`
  - Assertion: test FAILS because current Section 4 has no 255 references

### GREEN
- Add rule `3. **257 + 255 co-application:**` between current rule 2 and rule 3, renumber subsequent rules from 3→4, 4→5
- New rule content:

```
3. **257 + 255 co-application:** When a procedural discipline pattern requires distribution-shifted encoding, pair it with the corresponding distribution-shifting formula from `255-distribution-shifting-reference.md`. The 257 pattern defines what structural ordering to enforce; the 255 pattern defines how to encode it so the model produces the expert (non-mean) version. For example, p-dis-005 (Continue-Drift Contrast) pairs with the anti-mean response pattern from 255: the 257 formula defines "continue does not waive gates," the 255 encoding shifts the distribution away from "cumulative context = authorization" toward "each gate fires on every pass."
```

**File:** `.opencode/guidelines/257-procedural-discipline-reference.md`
**Lines:** 137-148 (Section 4 rules)

**Edit:** Insert new rule 3 after existing rule 2, renumber 3→4, 4→5

### REFACTOR
- Verify both 250 and 255 are referenced in Section 4
- Verify cross-card priority ordering is clear (250 identity, 255 distribution, 257 execution)
- Update Section 9 version if needed

---

## Phase 3: Fix SC-6 — Section 8 Re-Research Mandate

**Concern boundary:** Protocol correctness. Current Section 8 specifies a catalog-reconsult protocol (re-read catalog → consult matrix → verify against guidelines → re-read spec). The spec requires a research-currency-check protocol: check freshness → search if stale → flag NEEDS-REVALIDATION → document in version history.

### RED
- Write content-verification test: `grep` Section 8 for "NEEDS-REVALIDATION" or "check research citations for currency"
  - Assertion: test FAILS because current Section 8 uses catalog-reconsult protocol

### GREEN
- Replace entire Section 8 with the spec's research-currency-check protocol:

```
## Section 8: Re-Research Mandate

When this card (or 250 or 255) is consulted to create or modify AI-agent-facing text, the agent MUST verify that the research basis (Section 13) is still current.

**Re-research protocol:**

1. **Check research citations for currency** — Verify each citation was published within the last 12 months, or validated against the target model within the last 6 months. Publication date is the arXiv submission date or conference proceedings date, whichever is earlier.

2. **Search for updated findings if stale** — If any citation exceeds the currency window, search for updated findings on context degradation, constraint erosion, and directive effectiveness. Use available research tools (arXiv search, web search) to find more recent publications on the same topic.

3. **Flag as NEEDS-REVALIDATION if contradicted** — If updated research contradicts a pattern's basis or shows that the original finding has been superseded, flag the pattern as `NEEDS-REVALIDATION` in the version tracking table (Section 9). A flagged pattern should not be applied to new content until revalidated.

4. **Document results as a version update** — Record the re-research date, findings, and any pattern status changes in Section 9 (Version Tracking). Each re-research cycle produces a new version row.
```

**File:** `.opencode/guidelines/257-procedural-discipline-reference.md`
**Lines:** 214-221 (Section 8)

### REFACTOR
- Verify all 4 protocol steps from the spec are present
- Verify no catalog-consult language remains
- Update Section 9 version if needed

---

## Phase 4: Re-verify All 16 SCs

**Concern boundary:** Full spec compliance. After the 3 fixes, all 16 SCs must pass.

### Re-verification checklist

| SC | Verification Method | Expected Result |
|----|-------------------|-----------------|
| SC-1 | `ls .opencode/guidelines/257-*` | File exists |
| SC-2 | `grep` for each of p-dis-001 through p-dis-006 | 6 matches |
| SC-3 | Read Section 5 — gate formula present | Gate formula block exists |
| SC-4 | Read Section 6 — enforcement block formula + positional strategy | Both present |
| SC-5 | Read Section 7 — external verification + over-enforcement rows | Both rows present |
| SC-6 | `grep` Section 8 for "NEEDS-REVALIDATION" | **NOW PASS** |
| SC-7 | `grep` Section 4 for "255-distribution-shifting-reference.md" | **NOW PASS** |
| SC-8 | Read Sections 9-13 exist | All present |
| SC-9 | Read Section 2 — matrix with content-type rows | 14-row matrix |
| SC-10 | `grep` 250-dark-prose-reference.md §9 for dependency-order bright-line | TBD (separate spec #849) |
| SC-11 | `grep` 000-critical-rules.md for pipeline-reprime | TBD (separate spec #849) |
| SC-12 | `grep` INDEX.md for 257 entry | Present |
| SC-13 | `grep` for p-dis-006 | Present |
| SC-14 | Read Section 6 — primacy + recency strategy | Present |
| SC-15 | Read Section 7 — external verification + over-enforcement rows | Present |
| SC-16 | Spot-check 3 citations against source pages | **NOW PASS** — all 14 external URLs present |

### Version update
- Update Section 9: Version 1.1 — date, SHA, changes: "SC-6 fix: rewrite Re-Research Mandate with spec's currency-check protocol. SC-7 fix: add 257+255 co-application rule. SC-16 fix: replace internal-only research basis with spec's 14 verified external citations."

---

## File Change Summary

| Phase | File | Lines | Change Type |
|-------|------|-------|-------------|
| 1 | `.opencode/guidelines/257-procedural-discipline-reference.md` | 295-315 | Replace whole section |
| 2 | `.opencode/guidelines/257-procedural-discipline-reference.md` | 137-148 | Insert rule + renumber |
| 3 | `.opencode/guidelines/257-procedural-discipline-reference.md` | 214-221 | Replace whole section |
| 4 | `.opencode/guidelines/257-procedural-discipline-reference.md` | 225-227 | Version update |
| All | `.opencode/guidelines/257-procedural-discipline-reference.md` | — | Single file, 4 edits |