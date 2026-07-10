# [SPEC] Remove Dead-Weight yaml+symbolic Blocks from Skill Cards, Task Cards, and Guidelines

**STATUS:** DRAFT
**CREATED:** 2026-07-10
**ISSUE:** https://github.com/michael-conrad/opencode-config/issues/278

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Problem

The `yaml+symbolic` code-fenced blocks in skill cards, task cards, and guideline files are structured decorative metadata that no runtime code evaluates. They contain ~140 unique rules with conditions and actions written in pseudo-expression syntax. The `skildeck` tool validates structure (schema compliance) but does NOT evaluate conditions or enforce rules as logic. The `session-enforcement.ts` plugin, pre-commit hooks, and all runtime code do not parse these blocks.

### Key Problems

1. **No evaluator exists** — 142 skill rules + 218 guideline rules have conditions no code evaluates
2. **Duplicates prose** — every rule in yaml+symbolic blocks is already stated in the file's prose body
3. **Boilerplate replication** — 8 audit task files have nearly identical "next_step" and "all_criteria_pass" enforcement rules (16 rules copied across files)
4. **Duplicate rule ID** — `guideline-audit-004` is used TWICE in `guideline-audit.md`
5. **Misleading labeling** — `000-critical-rules.md` claims its "symbolic rules block" contains "machine-parseable rule definitions" but no machine-parseable block actually exists
6. **Content-verification tests** — 8 "yaml-rule" scenarios in `test-enforcement.sh` are grep-based text checks, not behavioral tests
7. **Maintenance burden** — every time a skill is updated, the yaml+symbolic block must be manually kept in sync with prose, creating a stale-documentation risk

### Files with yaml+symbolic blocks (54 total)

- 35 SKILL.md files across `.opencode/skills/*/`
- 16 task files (primarily in audit sub-skill tasks)
- 3 reference files

### Affected Tooling

- `skildeck` CLI tools (lint, validate, extract, analyze) — validate structure but don't evaluate conditions
- `skill-registry-v2-guidelines.json` — 218 rules extracted from prose
- `skill-registry-v2-skills.json` — 142 rules extracted from yaml+symbolic blocks
- `test-enforcement.sh` — 8 content-verification scenarios grepping for symbolic rule text
- `skill-creator` skill — templates that generate yaml+symbolic blocks for new skills
- `000-critical-rules.md` — misleading claim about "machine-parseable rule definitions"

## Solution

Remove all `yaml+symbolic` code-fenced blocks from the 54 affected files. For any rule in a yaml+symbolic block that is NOT already stated in the file's prose body, add appropriate prose to the file. Update tooling that depends on these blocks to work from prose instead. Update documentation that references these blocks.

## Scope

### In Scope

- Remove `yaml+symbolic` blocks from all 35 SKILL.md files
- Remove `yaml+symbolic` blocks from all 16 task files
- Remove `yaml+symbolic` blocks from all 3 reference files
- Fix misleading claim in `000-critical-rules.md` line 12
- Update `skildeck` tooling to not require yaml+symbolic blocks
- Update `skill-creator` templates to not generate yaml+symbolic blocks
- Update `test-enforcement.sh` content-verification scenarios
- Update documentation referencing yaml+symbolic blocks
- Per-phase content-loss verification (no rule lost without migration to prose)

### Out of Scope

- Rewriting the prose rules themselves (the prose is already correct and enforced)
- Changing the `skildeck` schema validation logic beyond removing yaml+symbolic requirements
- Behavioral changes to how agents process rules
- Adding new rules or enforcement mechanisms

## Phases

### Phase 1: Remove yaml+symbolic blocks from all SKILL.md files (35 files)

Remove the ````yaml+symbolic` code fence and all content to the closing fence from each SKILL.md file. For any rule in a yaml+symbolic block that is NOT already stated in the file's prose body, add appropriate prose to the file. Verify no content loss — every rule that has actual enforcement value (referenced by content-verification tests, behavioral tests, or actual runtime code) must be migrated to prose.

### Phase 2: Remove yaml+symbolic blocks from all task files (16 files)

Same approach as Phase 1. The 8 audit task files with duplicate boilerplate (next_step/all_criteria_pass) need special handling — these are the same rules repeated 8 times.

### Phase 3: Remove yaml+symbolic blocks from reference files (3 files)

### Phase 4: Update 000-critical-rules.md

Remove the misleading claim on line 12: "The symbolic rules block below contains machine-parseable rule definitions for all violations." The yaml+symbolic rules block at the end of the file doesn't exist (it's a prose file with markdown headers, not a structured block).

### Phase 5: Update skildeck tooling

- Update `skildeck` lint/validate to not require yaml+symbolic blocks
- Update `skildeck extract` to handle absence of blocks gracefully
- Update `skill-registry-v2-*.json` extraction to work from prose only, or remove the registry if it's unused

### Phase 6: Update skill-creator skill

- Remove yaml+symbolic block generation from skill templates
- Update documentation about what goes into a skill card

### Phase 7: Update test-enforcement.sh

- Remove or rewrite the 8 "yaml-rule" content-verification scenarios
- Replace with behavioral tests that verify agents follow the prose rules directly

### Phase 8: Update documentation

- Update any guidelines or docs that reference yaml+symbolic blocks
- Update `skill-card-change-types.md` reference document

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Phase Binding |
|----|-----------|---------------|-------------------|--------------|
| SC-1 | No `yaml+symbolic` code-fenced blocks remain in any SKILL.md file | `string` | `grep -r '```yaml+symbolic' .opencode/skills/*/SKILL.md` returns empty | Phase 1 |
| SC-2 | No `yaml+symbolic` code-fenced blocks remain in any task file | `string` | `grep -r '```yaml+symbolic' .opencode/skills/*/tasks/*.md` returns empty | Phase 2 |
| SC-3 | No `yaml+symbolic` code-fenced blocks remain in reference files | `string` | `grep -r '```yaml+symbolic' .opencode/skills/*/reference/*.md` returns empty | Phase 3 |
| SC-4 | `000-critical-rules.md` line 12 no longer contains the misleading claim | `string` | `grep 'machine-parseable rule definitions' .opencode/guidelines/000-critical-rules.md` returns empty | Phase 4 |
| SC-5 | `skildeck lint` and `skildeck validate` do not fail on files without yaml+symbolic blocks | `behavioral` | Run `skildeck lint` and `skildeck validate` on a file with blocks removed — must return PASS | Phase 5 |
| SC-6 | `skildeck extract` produces valid output from prose-only files | `behavioral` | Run `skildeck extract` on a file with blocks removed — must produce output without error | Phase 5 |
| SC-7 | `skill-creator` templates no longer generate yaml+symbolic blocks | `string` | `grep -r 'yaml+symbolic' .opencode/skills/skill-creator/` returns empty | Phase 6 |
| SC-8 | No "yaml-rule" content-verification scenarios remain in `test-enforcement.sh` | `string` | `grep 'yaml-rule' .opencode/tests/test-enforcement.sh` returns empty | Phase 7 |
| SC-9 | No documentation references yaml+symbolic blocks as required | `string` | `grep -r 'yaml+symbolic' .opencode/guidelines/ .opencode/docs/` returns only expected references | Phase 8 |
| SC-10 | No rule from any removed yaml+symbolic block was lost — every rule with enforcement value exists in prose | `semantic` | Sub-agent reads each removed block and confirms each rule is present in the file's prose body | All phases |
| SC-11 | Agent behavior does not regress after removal — agents still follow the prose rules | `behavioral` | Run existing behavioral enforcement tests — all must PASS | All phases |
| SC-12 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | Clean-room semantic inspection of implementation verifies no SC was weakened | All phases |

## Key Considerations

- This is a removal+cleanup spec, not a behavioral change — the agent behavior is driven by prose, not by the yaml+symbolic blocks
- The blocks are "structured decorative metadata" — removing them should not change agent behavior
- Behavioral regression tests are critical: verify that agents still follow the rules after the blocks are removed (because the rules are in prose, which is what agents actually read)
- The `skildeck` tooling changes need to be validated — the blocks are the only data source for the skill registries
- `skill-registry-v2-guidelines.json` is extracted from prose, not from yaml+symbolic blocks, so it's less affected

## Dependencies

None on other open issues — this is a standalone cleanup.

## Interdependency

No interdependencies with other open issues.

## Change Control

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r 'yaml+symbolic' .opencode/` | Identify all files with yaml+symbolic blocks |
| Direct source search | `grep -r 'machine-parseable' .opencode/guidelines/000-critical-rules.md` | Verify misleading claim location |
| Direct source search | `grep -r 'yaml-rule' .opencode/tests/test-enforcement.sh` | Identify content-verification test scenarios |
| Direct source search | `grep -r 'yaml+symbolic' .opencode/skills/skill-creator/` | Identify template references |

After this spec is approved, invoke `writing-plans` to create `.issues/278/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
