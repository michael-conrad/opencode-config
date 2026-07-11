---
remote_issue: 284
remote_url: https://github.com/michael-conrad/opencode-config/issues/284
promoted_at: 2026-07-11T20:49:10Z
---

# [SPEC-FIX] Resolve Conflicting Skill Description Format Mandates (Unified Agent-Intent + Farmage)

## Problem Statement

The skill-creator skill currently enforces two conflicting description format mandates in its validation logic:

1. **Unified Agent-Intent Description Pattern** (from `080-code-standards.md` and skill-card templates): Requires a single unified description field that combines agent intent + farmage in one string
2. **Farmage Description Pattern** (from skill-creator validation): Requires a separate `farmage` field with specific format requirements

These two mandates conflict, causing validation failures when creating or updating skills that follow either pattern. The validation logic in `skill-creator` rejects skills that conform to one pattern but not the other, creating a catch-22 for skill authors.

## Root Cause

The conflict stems from two separate specification sources that were never reconciled:

- **Source A** (Unified pattern): Skill cards should have a single `description` field following the pattern: `<agent-intent> — <farmage>`
- **Source B** (Separate pattern): Skill cards should have separate `description` and `farmage` fields with distinct validation rules

The `skill-creator` validation code implements checks for both patterns simultaneously, rejecting any skill that doesn't satisfy both — which is impossible since the patterns are mutually exclusive.

## Affected Files

- `.opencode/skills/skill-creator/SKILL.md` — validation rules
- `.opencode/skills/skill-creator/tasks/validate.md` — validation logic
- `.opencode/skills/skill-creator/tasks/create.md` — creation template
- `.opencode/skills/skill-creator/tasks/update.md` — update validation

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Skill validation accepts EITHER unified description pattern OR separate farmage pattern (not both required) | behavioral |
| SC-2 | Skill validation REJECTS skills with NEITHER pattern (must have at least one) | behavioral |
| SC-3 | Skill creation template generates skills conforming to unified pattern by default | structural |
| SC-4 | Skill update preserves existing pattern when only one is present | behavioral |
| SC-5 | Documentation in SKILL.md clearly states the accepted format(s) | string |

## Proposed Resolution

Unify on the **Unified Agent-Intent + Farmage Description Pattern** as the single canonical format:

```
description: "<agent-intent> — <farmage>"
```

Where:
- `<agent-intent>`: What the skill does for the agent (e.g., "Validates skill cards against format standards")
- `<farmage>`: What the skill produces for the farm (e.g., "emits validated skill card with compliance report")

The separate `farmage` field is DEPRECATED and should be removed from validation. Skills with only a `farmage` field (no `description`) should be auto-migrated or rejected with a clear migration message.

## Verification Method

Run `skill-creator --task validate` against:
1. A skill with unified description only → PASS
2. A skill with separate farmage only → FAIL with migration guidance
3. A skill with both → PASS (backward compat)
4. A skill with neither → FAIL with clear error

---

🤖 Co-authored with AI: <AgentName> (<ModelId>)