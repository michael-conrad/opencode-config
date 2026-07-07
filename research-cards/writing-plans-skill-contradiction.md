---
research_question: "Contradiction between writing-plans SKILL.md 'Programmatic Invocation' section and DISPATCH_GATE protocol"
confidence: 0.95
status: resolved
tags:
  - skill-structure
  - dispatch-gate
  - writing-plans
created: 2026-07-07
last_updated: 2026-07-07
---

## Summary

The writing-plans skill contains a genuine structural contradiction: its "Programmatic Invocation" section instructs the orchestrator to execute steps inline, while its "Invocation" section (with DISPATCH_GATE) instructs sub-agent dispatch. This contradicts every other skill in the repo.

## Findings

### The Contradiction

**Section A — "Programmatic Invocation" (SKILL.md lines 44-51):**
- States: "Orchestrator reads `tasks/create.md` and executes steps inline"
- Applies to all 4 tasks: create, retroactive, update, completion

**Section B — "Invocation" with DISPATCH_GATE (SKILL.md lines 75-86):**
- States: "Pipeline steps dispatch to sub-agents"
- Provides canonical dispatch strings: `task(..., prompt: "execute create task from writing-plans")`

**tasks/create.md Purpose section (line 5):**
- Also says inline: "The orchestrator reads this task file and executes the 21-step pipeline"

### Cross-Skill Comparison

| Skill | Programmatic Invocation section | DISPATCH GATE section | Consistent? |
|-------|------|------|------|
| adversarial-audit | N/A | "Inline execution is FORBIDDEN" | Consistent |
| spec-creation | N/A | "Inline execution is FORBIDDEN" | Consistent |
| playwright-cli | N/A | "Inline execution is FORBIDDEN" | Consistent |
| **writing-plans** | **"executes steps inline"** | **"Pipeline steps dispatch to sub-agents"** | **CONTRADICTORY** |

Writing-plans is the **only** skill with this contradiction.

### Root Cause

The "Programmatic Invocation" section is stale — it uses the old inline-execution pattern that was replaced by the DISPATCH_GATE protocol in other skills. The "Invocation" section (with DISPATCH_GATE) is the correct, current protocol.

### Recommended Fix

1. **SKILL.md**: Delete the "Programmatic Invocation" section; merge the correct dispatch table into "Invocation"
2. **tasks/create.md**: Update Purpose section to correctly describe sub-agent dispatch model
3. **Verify**: Run `skill-creator --task validate` on writing-plans to confirm resolution

### Classification

- **Type**: Structural compliance violation (skill card audit would flag this)
- **Severity**: Medium — contradicts critical-rules-048 and critical-rules-dispatch-gate-canonical
- **Fix scope**: 2 files in `.opencode/skills/writing-plans/`
- **Behavioral impact**: Agents following the stale "Programmatic Invocation" section would bypass DISPATCH_GATE, violating critical-rules-048

## Sources

- `.opencode/skills/writing-plans/SKILL.md` (lines 44-51, 75-86)
- `.opencode/skills/writing-plans/tasks/create.md` (line 5)
- `.opencode/skills/skill-creator/SKILL.md` (DISPATCH_GATE section)
- `000-critical-rules.md` (critical-rules-048, critical-rules-dispatch-gate-canonical)
