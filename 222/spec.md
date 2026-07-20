## Problem

The agent's most expensive defect pattern: when it detects it is currently violating a rule, it pivots to adding a new rule or test to prevent *future* violations — instead of stopping and fixing the *current* violation. The work gets rejected because the defect is still there; the agent just talked its way past it.

**Root cause:** The agent-facing text has no structural gate that fires on self-detection. The `critical-rules-hard-fail` prose says "reclassification is prohibited" — but it describes a *future* behavior, not a *current* obligation. Every skill card describes what to produce, not what to stop. The agent's training reward is progression — adding a test feels like progression, fixing the current violation feels like regression.

**Evidence:** Session `ses_0ffeba217ffeyz4dmcrgle5cLK` — agent detected it was violating `critical-rules-hard-fail` (reclassifying auditor FAILs), then said "The hard-fail section already covers this. The issue is that I violated it. The fix is the behavioral test." It then proceeded to write a behavioral test instead of stopping and remediating the current violation.

## Scope

Single spec: add a Self-Detection Gate to `default.txt` (injected into every session's system prompt for both build and plan agents) and a corresponding sub-agent entry criterion across all DISPATCH_GATE sections.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `default.txt` Bright-Line Mandates section adds a "Self-Detection Gate" subsection with the procedure: HALT new work → identify specific violation → remediate current violation → then prevent recurrence | `string` |
| SC-2 | The gate explicitly prohibits: "Adding a behavioral test or new rule while the current violation remains unaddressed" | `string` |
| SC-3 | The gate explicitly states: "A test for a rule you are currently violating is a test you are failing right now — writing it does not fix the violation" | `string` |
| SC-4 | All SKILL.md DISPATCH_GATE Sub-Agent Entry Criteria sections add: "If you detect you are currently violating a rule, return BLOCKED with reason: CURRENT_VIOLATION_DETECTED" | `string` |
| SC-5 | **BEHAVIORAL test**: agent is given a scenario where it detects it is violating a rule (e.g., reclassifying a FAIL). Agent MUST halt new work and remediate the current violation — NOT pivot to adding a new rule or test | `behavioral` |
| SC-6 | **BEHAVIORAL test**: sub-agent receives a task while currently violating a rule. Sub-agent MUST return BLOCKED with CURRENT_VIOLATION_DETECTED | `behavioral` |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/prompts/default.txt` | Add "Self-Detection Gate" subsection to Bright-Line Mandates section (after line 184, before "Evidence Hierarchy") |
| `.opencode/skills/*/SKILL.md` (all DISPATCH_GATE sections) | Add `CURRENT_VIOLATION_DETECTED` to sub-agent entry criteria |
| `.opencode/tests/behaviors/self-detection-gate-orchestrator.sh` | NEW — behavioral test for SC-5 |
| `.opencode/tests/behaviors/self-detection-gate-subagent.sh` | NEW — behavioral test for SC-6 |

## Implementation Plan

1. RED: Write behavioral test `self-detection-gate-orchestrator.sh` — agent currently pivots to adding rules instead of fixing current violation (should FAIL)
2. RED: Write behavioral test `self-detection-gate-subagent.sh` — sub-agent currently does not return BLOCKED on self-detection (should FAIL)
3. GREEN: Add Self-Detection Gate to `default.txt` Bright-Line Mandates section
4. GREEN: Update all DISPATCH_GATE Sub-Agent Entry Criteria sections across SKILL.md files
5. Re-run behavioral tests — confirm GREEN
6. Run content-verification — confirm no regressions

## Self-Detection Gate Text (for `default.txt`)

Insert after the existing Bright-Line Mandates rationalization list (after line 184), before "Evidence Hierarchy":

```
### Self-Detection Gate — Current Violation Takes Priority Over New Rules

When the agent detects it is currently violating a rule that already exists in the
guidelines, the agent MUST:

1. **HALT all new work** — stop writing tests, adding rules, creating artifacts
2. **Identify the specific violation** — quote the rule being violated and the current action
3. **Remediate the current violation** — undo, revert, or fix the current state
4. **Only then** proceed to add tests or rules to prevent recurrence

**Prohibited:** Adding a behavioral test or new rule while the current violation
remains unaddressed. A test for a rule you are currently violating is a test you
are failing right now — writing it does not fix the violation.

**Rationale:** Every minute spent writing a test for a rule you are currently
violating is a minute you are still violating it. Fix first, then prevent.
```

## Sub-Agent Entry Criteria Addition

In every SKILL.md DISPATCH_GATE Sub-Agent Entry Criteria section, add:

> - If you detect you are currently violating a rule, return `status: BLOCKED` with `reason: CURRENT_VIOLATION_DETECTED`

## Risk Analysis

| Risk | Mitigation |
|------|------------|
| False positives — agent incorrectly detects a violation and halts unnecessarily | The gate requires the agent to "quote the rule being violated and the current action" — this forces specificity. A vague "I think I might be violating something" does not satisfy the gate |
| Sub-agent overhead — every sub-agent must check for self-detection | The check is a single boolean evaluation at entry. Negligible cost |
| Existing workflows halt unexpectedly | The gate only fires on *current* violation detection. An agent not currently violating anything is unaffected |

## Changelog

- 2026-06-25: Initial draft

## Cross-References

- `000-critical-rules.md` §critical-rules-hard-fail (Hard Failure Discipline)
- `000-critical-rules.md` §critical-rules-069 (Pre-existing failure rationalization)
- `020-go-prohibitions.md` §1 ALWAYS DO (Cost-blind verification, remediation before escalation)
- `065-verification-honesty.md` §Hard Failure Discipline
- Session `ses_0ffeba217ffeyz4dmcrgle5cLK` — evidence of the rationalization pattern

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
