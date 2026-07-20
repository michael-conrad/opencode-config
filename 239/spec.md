> **Migrated to `michael-conrad/.opencode#1601`/`#1602`** — this issue was filed in the wrong repo. The SKILL.md files live in the `.opencode` submodule repo. The farmage pattern work was already recreated and completed in `.opencode#1602`.

---

> **Full spec and artifacts: [`.issues/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

## Problem

42 SKILL.md files in the opencode-config repository use inconsistent description formats. Only 6 of 42 follow the farmage YAML description pattern (`"Use when <primary>. Also use when <secondary>. Invoke for: <tasks>. <Enforcement>. Trigger phrases: <phrases>."`). The remaining ~36 skills use ad-hoc prose that produces unreliable skill dispatch — agents cannot reliably match trigger phrases to skills when descriptions lack structured trigger sections. Additionally, 7 skills are missing the `type` frontmatter field, 37 are missing `provenance`, 2 are missing `compatibility`, and 30+ are missing Worktree Mode sections. Cross-skill conflicts (research↔researcher, plan↔writing-plans↔plan-creation-pipeline, verification↔verification-before-completion↔verification-enforcement) cause ambiguous dispatch routing. SC-LINT-004's 300-char limit conflicts with the farmage 1024-char limit.

## Scope

**In scope:**
- Apply farmage YAML description pattern to all 42 SKILL.md `description` fields
- Add exclusion clauses (`— distinct from <exclusion>`) for skills that could false-match
- Fix missing frontmatter fields: `type`, `provenance`, `compatibility`
- Add Worktree Mode sections where missing
- Remove or update SC-LINT-004 (300-char limit) to align with farmage 1024-char limit
- Fix invalid type values: plan (domain→utility), solve (tool→utility), researcher (problem-solving→utility)
- Resolve cross-skill conflicts: research↔researcher dedup, plan skills differentiation, verification skills differentiation

**Out of scope:**
- Changes to skill task files, operating procedures, or routing logic
- Changes to guideline files or enforcement rules
- Adding or removing skills from the repository
- Changes to the skill dispatch engine or agent configuration

## Approach

Apply the farmage YAML description pattern across all 42 SKILL.md files in phases: (1) frontmatter field fixes (type, provenance, compatibility), (2) farmage description expansion for ~32 skills needing full pattern, (3) platform sub-skill farmage + enforcement keywords, (4) Worktree Mode sections, (5) SC-LINT-004 resolution, (6) cross-skill conflict resolution. Each phase follows RED/GREEN TDD with behavioral enforcement tests verifying agent dispatch behavior before and after each change.

## Impact

**Top 3 risks:**
1. **Cross-skill conflict resolution may change dispatch behavior** — behavioral tests required before and after each change to verify no regression
2. **SC-LINT-004 removal may affect other linting** — verify SC-LINT-004 is only used for the 300-char limit before removing
3. **42-file scope requires careful phase ordering** — dependency-ordered phases prevent cascading failures

**Key dependencies:** None — all changes are to SKILL.md files only.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at the spec folder URL.
After creation, `local-issues sync` MUST be run and the result committed to create the local `.issues/` entry.
The implementation plan will be created in `.issues/{N}/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All 42 SKILL.md `description` fields follow the farmage pattern: `"Use when <primary>. Also use when <secondary>. Invoke for: <tasks>. <Enforcement>. Trigger phrases: <phrases>."` | behavioral | `opencode-cli run "list skills"` → verify stderr shows structured descriptions with all 5 farmage components for each skill | On FAIL: identify which skills lack farmage pattern, apply pattern, re-run verification | Phase 1 | `.opencode/skills/*/SKILL.md` | DEC-1 | Phase 1 | pre-commit | sequential | farmage-pattern | null | `behaviors/farmage-pattern.sh` | Phase 1 |
| SC-2 | SC-LINT-004 (300-char limit) removed or updated to align with farmage 1024-char limit | behavioral | `grep -r "SC-LINT-004" .opencode/guidelines/` → verify no 300-char limit rule exists, or limit is updated to 1024 | On FAIL: update SC-LINT-004 threshold to 1024 or remove the rule entirely | Phase 5 | `.opencode/guidelines/` | DEC-2 | Phase 5 | pre-commit | sequential | sc-lint | null | `behaviors/sc-lint-004.sh` | Phase 5 |
| SC-3 | All 42 SKILL.md files have `type`, `provenance`, and `compatibility` frontmatter fields populated | structural | `for f in $(find .opencode/skills -name SKILL.md); do head -20 "$f" | grep -q "^type:" || echo "MISSING type: $f"; done` | On FAIL: add missing frontmatter fields with correct values | Phase 1 | `.opencode/skills/*/SKILL.md` | DEC-3 | Phase 1 | pre-commit | sequential | frontmatter | null | `behaviors/frontmatter-check.sh` | Phase 1 |
| SC-4 | Worktree Mode sections added to all SKILL.md files that lack them (30+ skills) | structural | `grep -rl "Worktree Mode" .opencode/skills/*/SKILL.md | wc -l` → verify count >= 39 (all top-level skills) | On FAIL: add Worktree Mode section to each missing skill | Phase 4 | `.opencode/skills/*/SKILL.md` | DEC-4 | Phase 4 | pre-commit | sequential | worktree-mode | null | `behaviors/worktree-section.sh` | Phase 4 |
| SC-5 | Cross-skill conflicts resolved: research↔researcher deduplicated, plan↔writing-plans↔plan-creation-pipeline differentiated, verification↔verification-before-completion↔verification-enforcement differentiated | semantic | Sub-agent reads all 3 conflicting skill descriptions and judges whether each pair has distinct, non-overlapping trigger phrases and primary use cases | On FAIL: revise descriptions to add exclusion clauses and distinct trigger sets | Phase 6 | `.opencode/skills/{research,researcher,plan,writing-plans,plan-creation-pipeline,verification,verification-before-completion,verification-enforcement}/SKILL.md` | DEC-5 | Phase 6 | pre-approval-gate | sequential | cross-skill | null | `behaviors/cross-skill-conflicts.sh` | Phase 6 |
| SC-6 | Invalid type values corrected: plan (domain→utility), solve (tool→utility), researcher (problem-solving→utility) | structural | `grep "^type:" .opencode/skills/{plan,solve,researcher}/SKILL.md` → verify values are `utility` | On FAIL: update type field to `utility` | Phase 1 | `.opencode/skills/{plan,solve,researcher}/SKILL.md` | DEC-3 | Phase 1 | pre-commit | sequential | frontmatter | null | `behaviors/frontmatter-check.sh` | Phase 1 |
| SC-7 | Platform sub-skills (gitbucket-api, github-mcp, local) have full farmage pattern + enforcement keywords | behavioral | `opencode-cli run "show platform skills"` → verify stderr shows farmage pattern for all 3 platform sub-skills | On FAIL: apply farmage pattern to platform sub-skills | Phase 3 | `.opencode/skills/issue-operations/platforms/*/SKILL.md` | DEC-1 | Phase 3 | pre-commit | sequential | farmage-pattern | null | `behaviors/farmage-pattern.sh` | Phase 3 |
| SC-8 | Exclusion clauses present on all skills that could false-match with other skills | semantic | Sub-agent reads all 42 descriptions and judges whether skills with overlapping domains have `— distinct from ` clauses | On FAIL: add exclusion clauses to overlapping skills | Phase 2 | `.opencode/skills/*/SKILL.md` | DEC-1 | Phase 2 | pre-approval-gate | sequential | farmage-pattern | null | `behaviors/exclusion-clauses.sh` | Phase 2 |
| SC-9 | Behavioral enforcement tests exist in RED state before any implementation changes | behavioral | `bash .opencode/tests/behaviors/farmage-pattern.sh` → FAILS (RED) before changes, PASSES (GREEN) after | On FAIL: create behavioral test scripts first, confirm RED state | Phase 0 | `.opencode/tests/behaviors/` | DEC-6 | Phase 0 | pre-commit | sequential | behavioral-tests | null | `behaviors/farmage-pattern.sh` | Phase 0 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Constraints

| Constraint | Value |
|------------|-------|
| Description length | Farmage pattern: 1024-char limit (not 300-char SC-LINT-004 limit) |
| File scope | SKILL.md files only — no task files, guidelines, or enforcement rules |
| Phase ordering | Must follow dependency order: frontmatter → farmage → platform → worktree → SC-LINT → cross-skill |
| TDD discipline | Each phase requires RED behavioral test before GREEN implementation |
| Evidence type | Behavioral for dispatch-affecting changes; structural for frontmatter; semantic for conflict resolution |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Farmage pattern includes all 5 components (Use when, Also use when, Invoke for, Enforcement, Trigger phrases) | Ensures complete structured descriptions for reliable skill dispatch | MUST | SC-1, SC-7, SC-8 |
| DEC-2 | SC-LINT-004 300-char limit removed in favor of farmage 1024-char limit | 300-char limit conflicts with farmage pattern which requires 1024 chars | MUST | SC-2 |
| DEC-3 | Frontmatter fields (type, provenance, compatibility) populated with correct values per skill-card-change-types.md | Missing fields cause agent config loading failures | MUST | SC-3, SC-6 |
| DEC-4 | Worktree Mode sections follow standard template from existing skills | Consistency across all skills for worktree-aware agents | SHOULD | SC-4 |
| DEC-5 | Cross-skill conflicts resolved by adding exclusion clauses and distinct trigger sets | Prevents ambiguous dispatch routing | MUST | SC-5 |
| DEC-6 | Behavioral tests written in RED state before any implementation changes | Per 091-incremental-build.md TDD discipline | MUST | SC-9 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Cross-skill conflict resolution changes dispatch behavior unexpectedly | Medium | High | Behavioral tests before and after each change | SC-5 |
| RISK-2 | SC-LINT-004 removal affects other linting rules | Low | Medium | Verify SC-LINT-004 is only used for 300-char limit | SC-2 |
| RISK-3 | 42-file scope causes merge conflicts with concurrent work | Medium | Medium | Phase ordering with stacked PR strategy | SC-9 |
| RISK-4 | Farmage pattern applied inconsistently across skills | Low | High | Automated verification script per SC-1 | SC-1 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | MUST | Update assertions to match revised SCs |
| SC-LINT-004 change | SHOULD | Review for continued validity |

## Decomposition Classification

| Classification | Value |
|----------------|-------|
| Type | multi-phase |
| Phase count | 6 (Phase 0: behavioral tests, Phase 1: frontmatter, Phase 2: farmage expansion, Phase 3: platform sub-skills, Phase 4: worktree mode, Phase 5: SC-LINT, Phase 6: cross-skill conflicts) |
| Sub-issue requirement | One sub-issue per phase |
| PR strategy | stacked |

## Non-Goals

- **Task file changes** — No modifications to `.md` task files within skills
- **Guideline changes** — No modifications to `.opencode/guidelines/` files (except SC-LINT-004)
- **Skill addition/removal** — No new skills created or existing skills deleted
- **Dispatch engine changes** — No changes to agent configuration or skill loading logic

## Regression Invariants

1. All existing skill dispatch behavior MUST continue to work for skills that already have farmage pattern
2. All existing frontmatter fields MUST be preserved (only missing fields added)
3. No SKILL.md file MAY be deleted or renamed
4. All existing task files and operating procedures MUST remain unchanged

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `find .opencode/skills -name SKILL.md | wc -l` | Count total SKILL.md files |
| Direct source search | `grep "^type:" .opencode/skills/*/SKILL.md` | Identify missing type fields |
| Direct source search | `grep "Worktree Mode" .opencode/skills/*/SKILL.md` | Identify missing Worktree Mode sections |
| Direct source search | `grep "SC-LINT-004" .opencode/guidelines/` | Identify SC-LINT-004 usage |
| MCP search | `srclight_search_symbols("farmage")` | Verify farmage pattern definition |
| Local docs | `skill-card-change-types.md` | Verify valid type values |

---

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

🤖 OpenCode (deepseek-v4-flash) created