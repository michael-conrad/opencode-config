# Implementation Plan: Playwright CLI as First-Class Browser Automation Entry Point

> **Spec:** [#1314](https://github.com/michael-conrad/.opencode/issues/1314) — Playwright CLI as First-Class Browser Automation Entry Point
> **Authorization:** `for_implementation` | **halt_at:** `verification_complete` | **pr_strategy:** `stacked`
> **Plan structure:** SEPARATE (multi-phase)

## Plan Structure Decision

**Decision:** SEPARATE
**Reason:** 5 distinct phases with different concerns (deletion, creation, reference cleanup, gitignore, verification). Each phase has independent deliverables and concern boundaries. Combined would produce a hard-to-read monolith.

---

## Phase 1: Delete `ui-design` and `ui-engineer` Skills

**Concern boundary:** Leaving no prior scope. Entering skill deletion. Handoff: empty skill directories and zero references enable Phase 2 (creation) and Phase 3 (reference cleanup).

**Files affected:** `skills/ui-design/`, `skills/ui-engineer/`, guidelines referencing these skills

**SC References:** SC-1

### Pre-RED Common

- [ ] 1. Verification gate — read approved spec, confirm `approved-for-implementation` label (**inline**)
- [ ] 2. Combined/separate decision — SEPARATE confirmed (**inline**)

### Per-Item RED+green Chains

- [ ] TDD-1: Delete `ui-design` skill directory (SC-1)
  - [ ] 1. RED: `skills/ui-design/` directory must exist before deletion (**inline**)
  - [ ] 2. GREEN: `skills/ui-design/` directory must not exist; `ls skills/ui-design/` returns error (**clean-room**)

- [ ] TDD-2: Delete `ui-engineer` skill directory (SC-1)
  - [ ] 1. RED: `skills/ui-engineer/` directory must exist before deletion (**inline**)
  - [ ] 2. GREEN: `skills/ui-engineer/` directory must not exist; `ls skills/ui-engineer/` returns error (**clean-room**)

- [ ] TDD-3: Remove skill entries from `skill-registry-v2-skills.json` (SC-1)
  - [ ] 1. RED: Registry file must contain `ui-design` and `ui-engineer` entries (**inline**)
  - [ ] 2. GREEN: Registry file must not contain `ui-design` or `ui-engineer` entries (**clean-room**)

### Post-RED/green

- [ ] 3. Phase 1 regression verification — confirm deleted directories absent, registry updated (**clean-room**)
- [ ] 4. Completeness gate — SC-1 fully satisfied (**inline**)

---

## Phase 2: Create `playwright-cli` Skill

**Concern boundary:** Leaving deletion scope. Entering skill creation. Handoff: deleted directories create space for new skill; upstream skill cards provide source material.

**Files affected:** `skills/playwright-cli/` (new directory)

**SC References:** SC-2

### Pre-RED Common

- [ ] 1. Verification gate — confirm Phase 1 complete (**inline**)
- [ ] 2. Read upstream skill cards from `microsoft/playwright-cli` `skills/playwright-cli/` (**clean-room**)

### Per-Item RED+green Chains

- [ ] TDD-4: Create `skills/playwright-cli/SKILL.md` with YAML frontmatter (SC-2)
  - [ ] 1. RED: `skills/playwright-cli/SKILL.md` must not exist (**inline**)
  - [ ] 2. GREEN: `skills/playwright-cli/SKILL.md` must exist with `name:`, `description:`, `Triggers on:`, `provenance:` frontmatter fields; content adapted from upstream (**clean-room**)

- [ ] TDD-5: Create `skills/playwright-cli/references/` with upstream reference files (SC-2)
  - [ ] 1. RED: `skills/playwright-cli/references/` must not exist (**inline**)
  - [ ] 2. GREEN: `skills/playwright-cli/references/` must contain upstream reference files with Apache-2.0 provenance preserved (**clean-room**)

- [ ] TDD-6: Verify skill card structure matches `.opencode/` format (SC-2)
  - [ ] 1. RED: Skill must lack YAML frontmatter or dispatch table (**inline**)
  - [ ] 2. GREEN: Skill must have valid YAML frontmatter, dispatch table, and provenance attribution (**clean-room**)

### Post-RED/green

- [ ] 5. Phase 2 regression verification — confirm new skill exists with correct structure (**clean-room**)
- [ ] 6. Completeness gate — SC-2 fully satisfied (**inline**)

---

## Phase 3: Update References

**Concern boundary:** Leaving skill creation. Entering reference cleanup. Handoff: new skill exists; now remove stale references from guidelines, tests, and registry.

**Files affected:** `000-critical-rules.md`, `README.md`, `tests/test-enforcement.sh`, `skill-registry-v2-skills.json`

**SC References:** SC-3

### Pre-RED Common

- [ ] 1. Verification gate — confirm Phase 1 and Phase 2 complete (**inline**)
- [ ] 2. Search for all references to `ui-design` and `ui-engineer` across repo (**clean-room**)

### Per-Item RED+green Chains

- [ ] TDD-7: Remove `ui-design`/`ui-engineer` from `000-critical-rules.md` triggers list (SC-3)
  - [ ] 1. RED: `000-critical-rules.md` must contain `ui-design` or `ui-engineer` references (**inline**)
  - [ ] 2. GREEN: `000-critical-rules.md` must not contain `ui-design` or `ui-engineer` references (**clean-room**)

- [ ] TDD-8: Remove `ui-design`/`ui-engineer` from `README.md` skill table (SC-3)
  - [ ] 1. RED: `README.md` must contain `ui-design` or `ui-engineer` in skill table (**inline**)
  - [ ] 2. GREEN: `README.md` must not contain `ui-design` or `ui-engineer` in skill table (**clean-room**)

- [ ] TDD-9: Remove `ui-engineer-red-gate` scenario from `tests/test-enforcement.sh` (SC-3)
  - [ ] 1. RED: `tests/test-enforcement.sh` must contain `ui-engineer-red-gate` scenario (**inline**)
  - [ ] 2. GREEN: `tests/test-enforcement.sh` must not contain `ui-engineer-red-gate` scenario (**clean-room**)

- [ ] TDD-10: Add `playwright-cli` to skill registry (SC-3)
  - [ ] 1. RED: `skill-registry-v2-skills.json` must not contain `playwright-cli` entry (**inline**)
  - [ ] 2. GREEN: `skill-registry-v2-skills.json` must contain `playwright-cli` entry with correct metadata (**clean-room**)

### Post-RED/green

- [ ] 7. Phase 3 regression verification — grep confirms zero deleted-skill references (**clean-room**)
- [ ] 8. Completeness gate — SC-3 fully satisfied (**inline**)

---

## Phase 4: Add `.tools/` to `.gitignore`

**Concern boundary:** Leaving reference cleanup. Entering gitignore configuration. Handoff: references clean; now add lazy install target.

**Files affected:** `.gitignore`

**SC References:** SC-4

### Pre-RED Common

- [ ] 1. Verification gate — confirm prior phases complete (**inline**)

### Per-Item RED+green Chains

- [ ] TDD-11: Add `.tools/` entry to `.gitignore` (SC-4)
  - [ ] 1. RED: `.gitignore` must not contain `.tools/` entry (**inline**)
  - [ ] 2. GREEN: `.gitignore` must contain `.tools/` entry (**clean-room**)

### Post-RED/green

- [ ] 9. Phase 4 regression verification — `.tools/` is gitignored (**clean-room**)
- [ ] 10. Completeness gate — SC-4 fully satisfied (**inline**)

---

## Phase 5: Verification

**Concern boundary:** Leaving all implementation phases. Entering final verification. Handoff: all phases complete; now confirm zero残留 references and correct new skill.

**Files affected:** All files touched by prior phases

**SC References:** SC-5

### Pre-RED Common

- [ ] 1. Verification gate — confirm all prior phases complete (**inline**)

### Per-Item RED+green Chains

- [ ] TDD-12: Verify zero Python `playwright` references (SC-5)
  - [ ] 1. RED: Repo must contain Python `playwright` import references (**inline**)
  - [ ] 2. GREEN: Repo must contain zero Python `playwright` import references (**clean-room**)

- [ ] TDD-13: Verify zero deleted-skill references (SC-5)
  - [ ] 1. RED: Repo must contain references to `ui-design` or `ui-engineer` (**inline**)
  - [ ] 2. GREEN: Repo must contain zero references to `ui-design` or `ui-engineer` (**clean-room**)

- [ ] TDD-14: Verify both directories absent (SC-5)
  - [ ] 1. RED: `skills/ui-design/` or `skills/ui-engineer/` must exist (**inline**)
  - [ ] 2. GREEN: Neither `skills/ui-design/` nor `skills/ui-engineer/` exists (**clean-room**)

- [ ] TDD-15: Verify `playwright-cli` skill exists with correct content (SC-5)
  - [ ] 1. RED: `skills/playwright-cli/SKILL.md` must not exist or must lack frontmatter (**inline**)
  - [ ] 2. GREEN: `skills/playwright-cli/SKILL.md` must exist with valid frontmatter, dispatch table, and provenance (**clean-room**)

### Post-RED/green

- [ ] 11. Final regression verification — all SCs satisfied (**clean-room**)
- [ ] 12. Completeness gate — SC-5 fully satisfied; all SCs PASS (**inline**)

---

## Post-All-Phases Sweep

- [ ] 13. FINISHING CHECKLIST — git status clean, lint/typecheck from scratch (**clean-room**)
- [ ] 14. PR CREATION — create PR via `github_create_pull_request`, extract `html_url` from response (**clean-room**)
- [ ] 15. POST-MERGE CLEANUP — delete merged branches, close issues, sync dev (**clean-room**)
