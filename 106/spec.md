## Problem

The skill card validation infrastructure (`validate_skill_cards.py` + `skill-creator validate` task) has four intersecting defects:

**Defect A — Invalid top-level YAML fields.** opencode.ai/docs/skills/ recognizes only `name`, `description`, `license`, `compatibility`, and `metadata` (string-to-string map) at the YAML frontmatter level. Unknown fields are silently ignored. The validator enforces `type` and `provenance` as top-level fields — which opencode ignores. Additionally, git-workflow has `provenance: AI-generated (feature-branch push + tip tag context...)` which is an invalid enum value and should live in `metadata` where arbitrary string values are accepted.

**Defect B — No online schema verification.** The validator and validate task never fetch opencode.ai/docs/skills/ to verify what opencode recognizes. The opencode team could add, remove, or rename frontmatter fields and the validator would drift silently. Every validation run should compare against the live schema.

**Defect C — No semantic validation.** Phase 1 of the validate task runs the mechanical script; Phases 3-5 describe agent-driven semantic analysis (cross-skill conflict detection, within-skill consistency, ambiguity detection). Semantic checks exist only as described in the validate.md task file — the script and task do not actually dispatch AI agent auditors to perform semantic analysis of skill cards. Descriptions with wrong intent, conflicting triggers, or misclassified types go undetected until a human reviews.

**Defect D — Descriptions lack identity-framing prose.** Skill descriptions are flat trigger-condition lists. Per 250-dark-prose-reference.md Section 2, routing-layer descriptions should carry goal-hijacking (consequence-assertion) prose to entice the AI agent into using the skill instead of doing work inline. Current descriptions describe *what* the skill does but don't anchor *why* skipping the skill produces defects.

## Scope

| Concern | Affected | Change |
|---------|----------|--------|
| `type` → `metadata.type` | 35 skills + validator + all task cards | Field move |
| `provenance` → `metadata.provenance` | 35 skills + validator + all task cards | Field move |
| `worktree_mode` → `metadata.worktree_mode` | ~47 skills + validator + all task cards | Field addition |
| Online schema fetch in validator | `validate_skill_cards.py` + `validate.md` | New validation step |
| Semantic audit phase | `validate.md` (Phases 3-5) + script | New sub-agent dispatch |
| Description dark prose | All 35 `description` fields | Rewrite |
| `metadata` field addition | All 35 SKILL.md + `080-code-standards.md` refs | Add `metadata:` block |

## Changes Required

### 1. Validator script (`validate_skill_cards.py`)

- REQ-1: Remove `type`, `license`, `compatibility` as top-level required fields. opencode docs say `license` and `compatibility` are optional — keep as optional checks for known fields but do not flag missing.
- REQ-1: Add check for `metadata:` block — if skill has extra fields, they MUST be under `metadata:` not top-level. Flag top-level unknown fields.
- REQ-1: Validate `metadata.type` against the existing taxonomy if present.
- REQ-1: Validate `metadata.provenance` against existing enum if present.
- REQ-1: Validate `metadata.worktree_mode` against `required|optional|not_applicable|unknown` if present.
- REQ-3: Remove body section check. Replace with `metadata.worktree_mode` check.
- REQ-4: Remove. Folded into REQ-1 metadata check.
- REQ-5 (NEW): Fetch opencode.ai/docs/skills/ via HTTP. Compare frontmatter field set against what opencode documents. Flag drift if fields opencode no longer recognizes are being used, or if new documented fields are absent.
- REQ-6 (NEW): Validate description follows dark prose identity-framing pattern per 250-dark-prose-reference.md §3 (dark-prose-003 consequence-assertion variant for routing layer descriptions).

### 2. Validate task (`skill-creator/tasks/validate.md`)

- Add Phase X: AI-agent semantic audit. After script pass, dispatch sub-agents to read each SKILL.md and verify:
  - Description correctly entices agent to use skill (dark prose compliance)
  - `metadata.type` correctly classifies the skill
  - Trigger keywords are accurate
  - No cross-skill trigger overlap that causes ambiguity
- Semantic audit produces structured JSON (PASS/FAIL per skill per SC).
- Semantic audit findings are NOT auto-fixes — they are presented for developer decision.

### 3. SKILL.md frontmatter migration (all ~35 skills)

Current pattern:
```yaml
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
```

New pattern:
```yaml
name: <name>
description: "<dark prose description>"
license: MIT
compatibility: opencode
metadata:
  type: discipline-enforcing
  provenance: AI-generated
  worktree_mode: required|optional|not_applicable
```
<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

**Critical:** The YAML frontmatter is YAML, not markdown. `metadata` is a map — the YAML must be syntactically valid. The opencode docs say `metadata` is `string-to-string map`, so the values MUST be quoted strings, not YAML sub-objects (e.g., `metadata.type: discipline-enforcing`). Let me check this...

Actually, re-reading the opencode docs: "metadata (optional, string-to-string map)". This means the schema type is `object` with `string` values only. In YAML, this is:

```yaml
metadata:
  type: "discipline-enforcing"
  provenance: "AI-generated"
```

Opencode's schema might or might not read nested values from YAML frontmatter. Since it says "string-to-string map", we should keep `metadata` as a simple key-value block. If opencode only reads `metadata` as a string-to-string map at the top level, it may not parse YAML sub-objects at all. In that case:

Actually, looking at the opencode docs more carefully: they show `metadata:` as an example:
```yaml
metadata:
  audience: maintainers
  workflow: github
```

The values are unquoted YAML strings. But the schema says `string-to-string map`. This suggests opencode reads YAML nested keys from the `metadata:` block as a flat kv map. This should work for our purposes.

### 4. Description dark prose rewrite (all ~35 skills)

Descriptions must follow `dark-prose-003` (goal hijacking, consequence-assertion) from 250-dark-prose-reference.md §3:

```
[Action without gate] produces [defect type].
[Defect type] means [impact on consumer].
Every [artifact] without [gate] carries [defect characterization].
```

**Example** (current → target for `test-driven-development`):

Current: `Use when writing tests before implementation, or when adopting a test-first development approach. Triggers on: TDD, test first, red green refactor, write test, test-driven, unit test, regression. Writing code before tests is the oldest shortcut in engineering. TDD produces testable, correct code.`

Target (dark prose variant): The current description already partially contains dark prose ("Writing code before tests is the oldest shortcut in engineering"). The goal is to front-load the consequence assertion so the agent's routing decision is weighted toward calling the skill. Each description must:
1. State the gate condition ("Use when <trigger>")
2. Assert consequence of bypassing ("[bypass] produces [defect]")
3. Anchor professional identity ("[standards] are what [good outcome] looks like")

The implementing agent derives the exact formulation from 250-dark-prose-reference.md §3 dark-prose-003 formula and §2 routing-layer pattern selection, not from copy-paste templates.

### 5. Semantic audit (NEW — validate task Phase X)

The semantic audit is NOT mechanical. It dispatches an AI agent sub-agent to read each skill card and classify:

| Criterion | PASS Condition |
|-----------|---------------|
| SC-DESC | Description uses dark prose identity-anchoring per 250 §3 |
| SC-TRIGGER | Trigger keywords accurately reflect skill's purpose |
| SC-TYPE | metadata.type matches the skill's actual concern |
| SC-WORKTREE | metadata.worktree_mode correctly reflects skill's operations |
| SC-UNIQUE | No other skill has overlapping triggers without differentiation |
| SC-CONSISTENT | Overview, tasks, and protocol don't contradict each other |

Semantic audit runs AFTER mechanical REQ pass. Findings are structured JSON. Auto-fixable findings (wrong metadata type, missing worktree_mode) are fixed immediately. Conflicts and ambiguities are presented to developer per existing Phases 5-6 protocol.

### 6. Online schema reference

Add to the validate task: before any mechanical checks, fetch `https://opencode.ai/docs/skills/` and read the **Write Frontmatter** section to determine what opencode recognizes as valid frontmatter fields.

- If the live docs say only `name`, `description`, `license`, `compatibility`, `metadata` → skip unknown fields
- If the live docs add new recognized fields → accept them (don't flag)
- If the live docs remove previously recognized fields → flag as drift

This is a proactive drift detection step. The validator must NOT assume its hardcoded field set is authoritative — the schema at opencode.ai is the source of truth.

The fetch is cached per validation run so it's not repeated per-skill.

## Success Criteria

| SC | Criterion | Verification |
|----|-----------|-------------|
| SC-1 | Validator no longer flags top-level `type`/`provenance` as required | Run on current cards → 0 REQ-1 violations for missing type |
| SC-2 | Validator accepts `metadata.type`/`metadata.provenance`/`metadata.worktree_mode` | Run on migrated card → PASS |
| SC-3 | Validator fetches opencode.ai/docs/skills/ and compares field set | Run with network → logs field set; run without → graceful skip |
| SC-4 | Validator outputs semantic audit findings for descriptions | Run semantic audit → structured FAIL for any non-dark-prose description |
| SC-5 | All 35 SKILL.md files have `metadata:` block with at least `type` and `worktree_mode` | Run `grep -l '^metadata:' .opencode/skills/*/SKILL.md` = 35 hits |

## Risk Analysis

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| opencode schema changes mid-work | Low | Online fetch catches drift immediately |
| YAML `metadata:` values not parsed by opencode | Medium | Test with single skill first; fall back to HTML comment if broken (same data in different location) |
| ~82 frontmatter edits across 35 skills creates merge conflicts | High | Batch into atomic items: one per skill, stacked in a single PR. Do NOT parallelize across branches. |
| Semantic audit produces too many false positives | Medium | Initial pass is informational only — no auto-fix on semantic findings |

## Exclusions (not in scope)

- Task card (`tasks/*.md`) frontmatter formatting — separate concern
- `080-code-standards.md` references to `type`/`provenance` — update as admin sync per authority-source-003 (code wins, update docs)
- Non-SKILL.md validation (guidelines, config files)
