# Phase 1 — Specs-are-not-tracking-docs

## Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | Documentation clarification — add "NOT tracking" sections to both AGENTS.md files and gut 141-planning-status-tracking.md |
| **Files** | `/AGENTS.md`, `.opencode/AGENTS.md`, `.opencode/guidelines/141-planning-status-tracking.md` |
| **SCs** | SC-1, SC-2, SC-3, SC-4 |
| **Dependencies** | None |
| **Entry Conditions** | Spec approved (`authorization_scope: for_pr`), all target files exist |
| **Exit Conditions** | All 4 SCs verified PASS via grep |

## Code Path Coverage

N/A — documentation-only change, no code paths.

## Cross-Cutting SCs

None — all SCs are phase-specific.

## Interface Boundaries

N/A — no code interfaces affected.

## State Transitions

N/A — no state transitions.

---

- [ ] 1. **Add "NOT tracking" section to `/AGENTS.md` (**sub-agent**).** Insert a new section after the `## Test Framework Discipline — MANDATORY` section (or at end of file) stating: "Specs and plans are NOT tracking documents. A spec defines what is required — implemented or not. A plan defines how to implement it — implemented or not. Any STATUS field, completion marker, pending indicator, or progress tracker in a spec or plan is a defect." **→ SC-1, SC-4**

- [ ] 2. **VbC Step 1 (**clean-room**).** Verify `/AGENTS.md` contains the "NOT tracking" section and the word "defect". Run: `grep -c "NOT tracking" /AGENTS.md` must output `1` AND `grep -c "defect" /AGENTS.md` must output `1`. **→ SC-1, SC-4**

- [ ] 3. **Add "NOT tracking" section to `.opencode/AGENTS.md` (**sub-agent**).** Insert a new section (e.g., after the `## editor MCP Plugin` section or at end of file) with the same text: "Specs and plans are NOT tracking documents. A spec defines what is required — implemented or not. A plan defines how to implement it — implemented or not. Any STATUS field, completion marker, pending indicator, or progress tracker in a spec or plan is a defect." **→ SC-2, SC-4**

- [ ] 4. **VbC Step 3 (**clean-room**).** Verify `.opencode/AGENTS.md` contains the "NOT tracking" section and the word "defect". Run: `grep -c "NOT tracking" .opencode/AGENTS.md` must output `1` AND `grep -c "defect" .opencode/AGENTS.md` must output `1`. **→ SC-2, SC-4**

- [ ] 5. **Gut `.opencode/guidelines/141-planning-status-tracking.md` (**sub-agent**).** Remove all status-tracking content: STATUS field format/values, status markers (`☐`/`↻`/`☑`/`☒`), label state transitions, approval commands, auto-progression rules, and the full label transition matrix. The file may be deleted entirely or reduced to a stub stating the guideline is removed. **→ SC-3**

- [ ] 6. **VbC Step 5 (**clean-room**).** Verify no STATUS content remains. Run: `grep -c "STATUS" .opencode/guidelines/141-planning-status-tracking.md` must output `0` (or file does not exist). **→ SC-3**

- [ ] 7. **SC count gate (**clean-room**).** Verify all 4 SCs have PASS verdicts. **→ All SCs**

- [ ] 8. **Pre-PR gate (**clean-room**).** Verify all SCs PASS. **→ All SCs**

- [ ] 9. **Audit (**clean-room**).** Adversarial audit of all three files for correctness and completeness. **→ All SCs**

- [ ] 10. **Cross-validate (**clean-room**).** Consensus check on audit findings. **→ All SCs**

#### Phase 1 VbC

- [ ] 11. **VbC (**clean-room**).** Verify all 4 SCs PASS via grep commands. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** N/A — single-phase plan, no transition needed.
