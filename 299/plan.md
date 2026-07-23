# Implementation Plan — [opencode-config#299](https://github.com/michael-conrad/opencode-config/issues/299) — Specs and plans are NOT tracking documents

**Goal:** Add sections to both AGENTS.md files stating specs/plans are NOT tracking documents, and gut `.opencode/guidelines/141-planning-status-tracking.md` of all status-tracking content.

**Architecture:** Three independent file edits — no cross-file dependencies, no new files, no structural changes.

**Files:**
- `/AGENTS.md` — root repo AGENTS.md
- `.opencode/AGENTS.md` — submodule AGENTS.md
- `.opencode/guidelines/141-planning-status-tracking.md` — guideline to gut

**Dispatch:** `writing-plans-creation` (this skill)

## Blast Radius

- `/AGENTS.md`: Adding a new section — no existing content removed, no structural changes
- `.opencode/AGENTS.md`: Adding a new section — no existing content removed, no structural changes
- `.opencode/guidelines/141-planning-status-tracking.md`: Removing all STATUS/status-marker/label-transition content — file may be deleted entirely or reduced to a stub

## Concern Map Reference

| Concern | Phase | Description |
|---------|-------|-------------|
| Documentation clarification | Phase 1 | Add "NOT tracking" sections to both AGENTS.md files and gut 141-planning-status-tracking.md |

> **⚠️ COMPLIANCE REQUIREMENT:** This plan MUST be executed exactly as written — one step at a time, in order. No step may be skipped, combined, or reordered. Each step produces a discrete, verifiable artifact. The orchestrator MUST dispatch each step to a clean-room sub-agent via `task()` and MUST NOT perform any step inline. Verification IS completion — no step is complete until its verification criteria are met.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute exactly one step at a time. After each step completes, report the result before proceeding to the next. Do NOT batch steps. Do NOT combine edits. Do NOT skip verification.

### Step Status

Each step below has a status indicator. The orchestrator updates the status as work progresses:
- `☐` Not started
- `↻` In progress
- `☑` Complete
- `☒` Blocked

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Specs-are-not-tracking-docs | Documentation clarification | SC-1, SC-2, SC-3, SC-4 | None | 1–10 | `writing-plans-creation` |

## Phase 1 — Specs-are-not-tracking-docs

### Concern

Add "NOT tracking" sections to both AGENTS.md files and gut 141-planning-status-tracking.md of all status-tracking content.

### Files

- `/AGENTS.md`
- `.opencode/AGENTS.md`
- `.opencode/guidelines/141-planning-status-tracking.md`

### SCs

- **SC-1:** `/AGENTS.md` contains a section stating specs and plans are NOT tracking documents
- **SC-2:** `.opencode/AGENTS.md` contains a section stating specs and plans are NOT tracking documents
- **SC-3:** `.opencode/guidelines/141-planning-status-tracking.md` has all status-tracking content removed (STATUS fields, status markers, label state transitions)
- **SC-4:** The section in both AGENTS.md files explicitly states that STATUS fields, completion markers, pending indicators, and progress trackers in specs/plans are defects

### Dependencies

None — all three files are independent edits.

### Entry Conditions

- Spec is approved (`authorization_scope: for_pr`)
- All three target files exist and have been read

### Exit Conditions

- All 4 SCs verified PASS via grep

### Code Path Coverage

N/A — documentation-only change, no code paths.

### Cross-Cutting SCs

None — all SCs are phase-specific.

### Interface Boundaries

N/A — no code interfaces affected.

### State Transitions

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

---

> **⚠️ COMPLIANCE REQUIREMENT:** This plan MUST be executed exactly as written — one step at a time, in order. No step may be skipped, combined, or reordered. Each step produces a discrete, verifiable artifact. The orchestrator MUST dispatch each step to a clean-room sub-agent via `task()` and MUST NOT perform any step inline. Verification IS completion — no step is complete until its verification criteria are met.

### Self-Remediation Protocol

If a step fails verification:
1. Report the failure with diagnostics
2. Re-dispatch the failed step with the same parameters
3. If re-dispatch also fails, report double-failure and HALT

## Exit Criteria

- [ ] C1: `/AGENTS.md` contains a section stating specs and plans are NOT tracking documents
- [ ] C2: `.opencode/AGENTS.md` contains a section stating specs and plans are NOT tracking documents
- [ ] C3: `.opencode/guidelines/141-planning-status-tracking.md` has all status-tracking content removed
- [ ] C4: Both AGENTS.md sections explicitly state that STATUS fields, completion markers, pending indicators, and progress trackers in specs/plans are defects
