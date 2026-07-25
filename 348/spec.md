> **Full spec and artifacts: [`.issues/348/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/348)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/348/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Compact `.opencode/guidelines/000-critical-rules.md` from ~1211 lines / 88KB to ~200-300 lines / ~15-20KB by removing preloaded-guideline stubs, skill-card-specific rules, dark prose framing, Why This Matters tables, and redundant subsections. Preserve the tier classification table, interaction rule table, ~15-20 self-contained universal/orchestrator-level rules, and the channel-routing table.

## Background

The file has grown to 1211 lines / 88KB with ~80+ rules across 3 tiers. Analysis found:
- 74 dark prose occurrences ("Professional engineers... amateurs...")
- 10 "Why This Matters" tables that restate the rule
- 36 FORBIDDEN/REQUIRED subsections
- 20+ stubs pointing to preloaded guidelines (loaded in the same instructions array)
- 20+ skill-card cross-references (rules that belong in skill/task cards, not in 000-critical-rules.md)
- 2 intro cross-references (lines 9-10)

All preloaded guidelines (010, 020, 060, 065, 067, 075, 080, 090, 091, 117, 130) are loaded in the same `opencode.jsonc` instructions array. Stubs pointing to them are redundant. Skill-card-specific rules should live in the skill/task cards and fire on dispatch, not at session start.

## Not Included

- No changes to the three-tier model or enforcement mechanism
- No changes to other guideline files
- No changes to code, tests, or configuration
- No semantic changes to preserved rules
- No changes to skill/task cards (rules moved there are removed from this file only)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|---------------------|
| SC-1 | Lines 9-10 (intro cross-references) are removed | `string` | grep for "Read [the authoritative list" and "Read [detailed rules" — both absent |
| SC-2 | All stubs referencing preloaded guidelines (010, 020, 060, 065, 067, 075, 080, 090, 091, 117, 130) are removed | `string` | grep for each guideline filename pattern — none found outside preserved rules |
| SC-3 | All rules referencing `skills/` paths are removed | `string` | grep for "skills/" — none found |
| SC-4 | All dark prose framing ("Professional engineers... amateurs...") is removed | `string` | grep for "Professional engineers" and "amateurs" — both absent |
| SC-5 | All "Why This Matters" tables are removed | `string` | grep for "Why This Matters" — absent |
| SC-6 | Redundant FORBIDDEN/REQUIRED subsections are removed; only essential ones remain for self-contained rules | `string` | grep for "FORBIDDEN" and "REQUIRED" — count reduced to ≤10 |
| SC-7 | Tier classification table is preserved | `string` | grep for "| Tier | Name | Enforcement | Prose Style | Overridable |" — present |
| SC-8 | Interaction rule table is preserved | `string` | grep for "| Scenario | Resolution | Rule |" — present |
| SC-9 | Channel-routing table is preserved | `string` | grep for "| Action | Channel |" — present |
| SC-10 | File is 200-300 lines and 15-20KB | `structural` | `wc -l` returns 200-300; `du -sh` returns 15-20K |

## Requirements

1. The file SHALL retain its YAML frontmatter with `trigger_on`, `tier`, and `load_when` fields.
2. The file SHALL retain the three-tier structure (Tier 1 Safety-Critical, Tier 2 Process-Integrity, Tier 3 Workflow-Standard) with section headers and descriptions.
3. The file SHALL retain the tier classification table and interaction rule table.
4. The file SHALL retain the channel-routing table.
5. The file SHALL retain ~15-20 self-contained universal/orchestrator-level rules with their bracketed IDs.
6. The file SHALL NOT contain stubs pointing to preloaded guidelines (010, 020, 060, 065, 067, 075, 080, 090, 091, 117, 130).
7. The file SHALL NOT contain rules that reference `skills/` paths.
8. The file SHALL NOT contain dark prose framing ("Professional engineers... amateurs...").
9. The file SHALL NOT contain "Why This Matters" tables.
10. The file SHALL be 200-300 lines and 15-20KB in size.

## Items

| Item | SC | Description |
|------|-----|-------------|
| 1 | SC-1 | Remove intro cross-references (lines 9-10) |
| 2 | SC-2 | Remove preloaded-guideline stubs |
| 3 | SC-3 | Remove skill-card-specific rules |
| 4 | SC-4 | Remove dark prose framing |
| 5 | SC-5 | Remove Why This Matters tables |
| 6 | SC-6 | Remove redundant FORBIDDEN/REQUIRED subsections |
| 7 | SC-7 | Verify tier classification table preserved |
| 8 | SC-8 | Verify interaction rule table preserved |
| 9 | SC-9 | Verify channel-routing table preserved |
| 10 | SC-10 | Verify final size 200-300 lines / 15-20KB |

## Dependencies

- None. Single-file modification with no external dependencies.

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1 (frontmatter preserved) | SC-7 | 5 |
| R2 (tier structure preserved) | SC-7, SC-8 | 5 |
| R3 (tier/interaction tables) | SC-7, SC-8 | 5 |
| R4 (channel-routing table) | SC-9 | 5 |
| R5 (self-contained rules) | SC-10 | 5 |
| R6 (no preloaded stubs) | SC-2 | 1 |
| R7 (no skill-card rules) | SC-3 | 2 |
| R8 (no dark prose) | SC-4 | 3 |
| R9 (no Why This Matters) | SC-5 | 3 |
| R10 (size target) | SC-10 | 6 |
