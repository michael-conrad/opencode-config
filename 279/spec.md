# [SPEC] Rewrite SKILL.md Descriptions to Agent-Intent-Oriented Pattern

**STATUS:** DRAFT
**CREATED:** 2026-07-11

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/279/plan.md` before implementation begins.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Problem Statement

All 43 SKILL.md files have `description` frontmatter fields written as if the opencode runtime parses trigger phrases and auto-dispatches skills. In reality, the runtime (`packages/core/src/skill.ts`) only recognizes three frontmatter fields: `name`, `description`, `slash`. The `description` is rendered verbatim into the `<available_skills>` XML block in the system prompt. The LLM reads it and decides whether to call `skill()`. There is zero trigger-phrase matching in the runtime.

The current description pattern is: `"Use when <user-facing use case>. Also use when <more user-facing use cases>. Invoke for: <task list>. <Enforcement statement>. Trigger phrases: <comma-separated list>."`

This is defective because:
1. It is written for a keyword matcher that does not exist
2. It trains the LLM to pattern-match user words instead of reasoning about its own intent
3. The "Trigger phrases:" section is a cargo-cult artifact — the runtime never reads it
4. The LLM needs to self-route based on what it has decided to do, not what the user happened to say

### Evidence

Verified by reading `session-enforcement.ts` lines 520-662:
- `extractTriggerPatterns()` (line 524) extracts trigger phrases from the description for the **Skill Index** table in the system prompt — it does NOT drive any auto-dispatch logic
- `loadSkillDescriptions()` (line 607) reads `name` and `description` from frontmatter and renders them into the `<available_skills>` XML block
- `extractFrontmatter()` (line 568) only parses `name`, `description`, `slash` — no other fields are recognized
- The validation at line 640 checks `description.startsWith("Use when")` — this is the only enforcement of the current pattern

## Scope

**In scope:**
- Rewrite all 43 SKILL.md `description` frontmatter fields to agent-intent-oriented prose
- Update `validate_skill_cards.py` to accept the new pattern (and both old/new during transition)
- Update `session-enforcement.ts` validation (line 640) to accept the new pattern
- Update `init_skill.py` template to use the new pattern
- Update `routing-only-template.md` to document the new pattern
- Update `skill-card-spec.md` if it references the description format
- Write behavioral enforcement tests for the new pattern

**Out of scope:**
- Task card files (299 files) — they use `## Purpose` headings, not YAML frontmatter descriptions
- Guideline files (31 files) — they use `trigger_on` frontmatter, not `description` fields
- Adding new frontmatter fields — the runtime only recognizes `name`, `description`, `slash`
- Changing how the runtime processes descriptions — this is a content-only change

## New Description Pattern

The description MUST lead with agent-intent language: what the agent is doing when it should dispatch this skill. User trigger phrases follow as supplementary information appended after the agent-facing content.

### Pattern Specification

```
<Agent-intent statement>. Dispatch when <agent-decision conditions>. <Enforcement statement>. User phrases: <comma-separated list>.
```

### Components

| Component | Purpose | Required? |
|-----------|---------|-----------|
| Agent-intent statement | What the agent is doing when it dispatches this skill (1 sentence) | Yes |
| Dispatch conditions | When the agent should decide to dispatch (1-2 sentences) | Yes |
| Enforcement statement | Mandatory/REQUIRED language about the skill's discipline | Yes |
| User phrases | Comma-separated list of natural language phrases a user might say | Yes |

### Before/After Example

**BEFORE (current pattern):**
> "Use when creating a branch, committing, pushing, or creating a PR. Also use when handling rebase/merge conflicts (invoke conflict-resolution), checking PR state and cleanup, or running provenance tracking. Invoke for: branch creation, commit, push, PR creation, rebase, merge, conflict resolution dispatch, PR state verification, cleanup, provenance tracking, submodule sync. Branch-and-PR discipline is REQUIRED — always follow the workflow. Trigger phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."

**AFTER (new pattern):**
> "Branch, commit, push, and PR lifecycle management. Dispatch when the agent needs to create a feature branch, commit changes, push to remote, create a pull request, handle rebase or merge operations, verify PR state, clean up merged branches, sync submodules, or track provenance. Also dispatch when a PR has been merged and cleanup is needed. Branch-and-PR discipline is REQUIRED — always follow the workflow. User phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."

### Key Differences

| Aspect | Old Pattern | New Pattern |
|--------|-------------|-------------|
| Opening | "Use when" (user-facing) | Agent-intent statement (agent-facing) |
| Structure | "Use when... Also use when... Invoke for:... Trigger phrases:" | "Statement. Dispatch when... Enforcement. User phrases:" |
| Trigger phrases | "Trigger phrases:" prefix | "User phrases:" prefix |
| Task list | "Invoke for:" (redundant with dispatch conditions) | Integrated into dispatch conditions |
| Mental model | "Did the user say one of these magic words?" | "Should I dispatch this skill for what I'm about to do?" |

### Constraints

- MUST fit within the existing `description` frontmatter field (no new fields)
- MUST NOT exceed 1024 characters (existing `validate_skill_cards.py` SC-LINT-004 limit)
- MUST include mandatory keyword (MUST/REQUIRED/always/not optional/mandatory) per SC-LINT-002
- MUST NOT contain narrative-only sentences per SC-LINT-003
- MUST NOT contain angle brackets per REQ-1
- Exclusion clauses (`— distinct from <exclusion>`) retained for skills that could false-match

## Affected Files

### SKILL.md Files (43 files)

All files in `.opencode/skills/*/SKILL.md` and `.opencode/skills/*/platforms/*/SKILL.md`:

| # | Skill | Current Pattern |
|---|-------|----------------|
| 1 | approval-gate | "Use when checking or enforcing authorization scope..." |
| 2 | audit | "Use when running audits of specs, plans, code..." |
| 3 | brainstorming | "Use when creating a spec, planning a feature..." |
| 4 | changelog-generator | "Use when creating release notes..." |
| 5 | completeness-gate | "Use when running a non-audit completeness check..." |
| 6 | completion-core | "Use when completing skill task workflows..." |
| 7 | conflict-resolution | "Use when resolving git conflicts..." |
| 8 | correspondence | "Use when drafting stakeholder emails..." |
| 9 | engineering-approach | "Use when implementing a spec..." |
| 10 | executing-plans | "Use when executing an approved plan..." |
| 11 | finishing-a-development-branch | "Use when implementation is complete..." |
| 12 | git-workflow | "Use when creating a branch, committing, pushing..." |
| 13 | implementation-pipeline | "Use when executing an approved plan through..." |
| 14 | issue-operations | "Use when creating, commenting on, or closing..." |
| 15 | issue-review | "Use when reviewing a GitHub issue..." |
| 16 | mcp-tool-usage | "Use when selecting tools for file operations..." |
| 17 | multimodal-dispatch | "Use when routing AI agent tasks..." |
| 18 | plan | "Use when generating, validating, or managing plans..." |
| 19 | plan-creation-pipeline | "Use when creating a plan from an approved spec..." |
| 20 | playwright-cli | "Use when browsing the web..." |
| 21 | pr-creation-workflow | "Use when asking about when to create a PR..." |
| 22 | pre-analysis | "Use when task()ing any execution sub-agent..." |
| 23 | programming-principles | "Use when designing functions, classes, or modules..." |
| 24 | receiving-code-review | "Use when receiving code review feedback..." |
| 25 | release-promoter | "Use when creating git tags for releases..." |
| 26 | requesting-code-review | "Use when preparing a PR for code review..." |
| 27 | research | "Use when discovering information..." |
| 28 | skill-creator | "Use when creating a new skill..." |
| 29 | solve | "Use when validating workflow constraints..." |
| 30 | spec-creation | "Use when creating a spec..." |
| 31 | sre-runbook | "Use when generating operational runbooks..." |
| 32 | sync-guidelines | "Use when synchronizing guidelines..." |
| 33 | systematic-debugging | "Use when encountering a bug..." |
| 34 | test-driven-development | "Use when writing tests before implementation..." |
| 35 | using-git-worktrees | "Use when creating a feature branch or worktree..." |
| 36 | verification | "Use when verifying claims against evidence..." |
| 37 | verification-before-completion | "Use when claiming a task is complete..." |
| 38 | verification-enforcement | "Use when generating content that makes factual claims..." |
| 39 | version-manager | "Use when discovering version strings..." |
| 40 | writing-plans | "Use when creating an implementation plan..." |
| 41 | issue-operations/platforms/github-mcp | "Use when GitHub MCP platform operations are needed..." |
| 42 | issue-operations/platforms/gitbucket-api | "Use when GitBucket platform operations are needed..." |
| 43 | issue-operations/platforms/local | "Use when local .issues/ tracking is needed..." |

### Validation and Tooling Files

| File | Change Required |
|------|----------------|
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Update `validate_req1()` and `validate_sc_lint_001()` to accept new pattern |
| `.opencode/plugins/session-enforcement.ts` | Update line 640 validation to accept new pattern |
| `.opencode/skills/skill-creator/scripts/init_skill.py` | Update template line 29 to use new pattern |
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | Update description format documentation |
| `.opencode/skills/skill-creator/reference/skill-card-spec.md` | Update if it references description format |

### Behavioral Enforcement Tests

New test file: `.opencode/tests/behaviors/skill-description-pattern.sh`

## Implementation Approach

The rewrite is a content-only change to the `description` frontmatter field in 43 SKILL.md files. No runtime code changes are needed — the runtime already renders descriptions verbatim. The validation scripts must be updated to accept the new pattern.

The rewrite follows a mechanical transformation:
1. Remove "Use when" / "Also use when" / "Invoke for:" prefixes
2. Restructure into agent-intent statement + dispatch conditions + enforcement + user phrases
3. Change "Trigger phrases:" to "User phrases:"
4. Preserve enforcement statements and exclusion clauses

## Dependencies

- No external dependencies
- No runtime changes required
- Validation script changes must be coordinated with description rewrites to avoid false validation failures

## Risk

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| LLM routing regression | Low | High | Behavioral tests verify agent still dispatches correctly with new descriptions |
| Validation breakage during transition | High | Medium | Update validator to accept both old and new patterns; run validation after each batch |
| Description length exceeds 1024 chars | Low | Low | SC-LINT-004 catches this; trim if needed |
| Missing enforcement keyword | Low | Low | SC-LINT-002 catches this; ensure each description has MUST/REQUIRED |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#601](https://github.com/michael-conrad/opencode-config/issues/601) | RELATED | Original bug that motivated frontmatter validation |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `session-enforcement.ts` lines 520-662 | Verify runtime only recognizes name/description/slash |
| Direct source search | `validate_skill_cards.py` full file | Verify current validation rules for description field |
| Direct source search | `init_skill.py` full file | Verify current template uses old pattern |
| Direct source search | `routing-only-template.md` full file | Verify current template documentation |
| Direct source search | `skill-card-spec.md` full file | Verify reference docs |
| Direct source search | `grep` on all 43 SKILL.md files | Verify all use "Use when" pattern |
| Direct source search | `find` count of SKILL.md files | Verify count is 43 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All 43 SKILL.md descriptions use the new agent-intent pattern | `string` | `grep -L 'User phrases:' .opencode/skills/*/SKILL.md` returns empty | Rewrite any file still using old pattern | green | `.issues/279/string/` | REQ-1 | Phase 3 | pre-commit | standalone | — | Phase 3 | — | Phase 3 |
| SC-2 | No SKILL.md description starts with "Use when" | `string` | `grep -r 'description: "Use when' .opencode/skills/*/SKILL.md` returns empty | Rewrite any file still using old pattern | green | `.issues/279/string/` | REQ-1 | Phase 3 | pre-commit | standalone | — | Phase 3 | — | Phase 3 |
| SC-3 | All descriptions include "User phrases:" suffix | `string` | `grep -L 'User phrases:' .opencode/skills/*/SKILL.md` returns empty | Add missing User phrases section | green | `.issues/279/string/` | REQ-1 | Phase 3 | pre-commit | standalone | — | Phase 3 | — | Phase 3 |
| SC-4 | `validate_skill_cards.py` passes on all 43 files with new pattern | `behavioral` | `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` exits 0 | Fix validation failures | green | `.issues/279/behavioral/` | REQ-2 | Phase 2 | pre-commit | standalone | — | Phase 2 | — | Phase 2 |
| SC-5 | `session-enforcement.ts` accepts new description pattern without warnings | `behavioral` | `with-test-home opencode-cli run "list skills"` produces no frontmatter warnings | Fix session-enforcement.ts validation | green | `.issues/279/behavioral/` | REQ-2 | Phase 2 | pre-commit | standalone | — | Phase 2 | — | Phase 2 |
| SC-6 | `init_skill.py` template uses new description pattern | `string` | `grep 'User phrases:' .opencode/skills/skill-creator/scripts/init_skill.py` matches | Update template | green | `.issues/279/string/` | REQ-3 | Phase 1 | pre-commit | standalone | — | Phase 1 | — | Phase 1 |
| SC-7 | `routing-only-template.md` documents new description pattern | `string` | `grep 'User phrases:' .opencode/skills/skill-creator/reference/routing-only-template.md` matches | Update template docs | green | `.issues/279/string/` | REQ-3 | Phase 1 | pre-commit | standalone | — | Phase 1 | — | Phase 1 |
| SC-8 | Behavioral enforcement test verifies agent dispatches skills correctly with new descriptions | `behavioral` | `bash .opencode/tests/behaviors/skill-description-pattern.sh` exits 0 | Fix test or descriptions | green | `.issues/279/behavioral/` | REQ-4 | Phase 4 | pre-commit | standalone | — | Phase 4 | — | Phase 4 |
| SC-9 | No description exceeds 1024 characters | `string` | `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` SC-LINT-004 passes | Trim description | green | `.issues/279/string/` | REQ-1 | Phase 3 | pre-commit | standalone | — | Phase 3 | — | Phase 3 |
| SC-10 | All descriptions include mandatory keyword (MUST/REQUIRED/always/not optional/mandatory) | `string` | `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` SC-LINT-002 passes | Add enforcement keyword | green | `.issues/279/string/` | REQ-1 | Phase 3 | pre-commit | standalone | — | Phase 3 | — | Phase 3 |
| SC-11 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | Audit confirms all SCs have correct evidence types and are fully implemented | Restore original evidence type and implement | green | `.issues/279/behavioral/` | Anti-lobotomization | Phase 4 | pre-commit | standalone | — | Phase 4 | — | Phase 4 |
| SC-12 | Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new description pattern; confirm RED state (test fails before change) | `behavioral` | `bash .opencode/tests/behaviors/skill-description-pattern.sh` fails before implementation, passes after | Write missing tests | red | `.issues/279/behavioral/` | TDD mandate | Phase 4 | pre-red | standalone | — | Phase 4 | — | Phase 4 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
