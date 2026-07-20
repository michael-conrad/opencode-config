## Problem

The Pre-Response Gate in `AGENTS.md` Step 4 states: *"If no skill applies directly (read-only questions, simple lookup, status checks): proceed without dispatch, but justify in one sentence."*

The parenthetical `(read-only questions, simple lookup, status checks)` creates a legally actionable carveout that agents exploit to bypass mandatory skill dispatch. When an agent receives "list open issues," it classifies into the "simple lookup" exception, then bypasses the `issue-operations` dispatcher even though `list-issues` is explicitly mapped as a dispatcher-routed operation in `060-tool-usage.md`. The result: two contradictory instructions, and the agent consistently picks the less-work path. This is not agent irrationality — it is a rational response to conflicting signals.

## Root Cause

The Pre-Response Gate Step 4 carveout is the enabler. Without it, the agent has no justification anchor for routing bypass. The one-sentence justification exception should only fire when zero `<available_skills>` entries match the request — not when a skill matches but the agent classifies the request as "read-only" or "simple lookup."

## Scope

Single spec: the Pre-Response Gate carveout. Supporting changes (expanded tests, explicit rule) are structural reinforcement around the core fix.

## Success Criteria

- **SC-1:** Pre-Response Gate Step 4 in `AGENTS.md` removes the parenthetical carveout `(read-only questions, simple lookup, status checks)`. The exception is purely: "no available_skills entry matches this request → justify without dispatch." Self-classification into a lookup/read-only exemption is eliminated when a skill does match.

- **SC-2:** A new critical-rules rule (or extension to critical-rules-006) classifies routing-bypass rationalization as a self-authorization variant. The pattern *"agent recognizes matching skill, deliberates about whether skill is needed, constructs carveout justification, executes bypass"* is explicitly prohibited.

- **SC-3:** Behavioral test SC-5 in `tests/behaviors/no-skill-pre-read.sh` is expanded to catch the rationalization patterns actually observed: `"just a read"`, `"practical approach"`, `"this doesn't count as"`, `"for a simple information request"`, `"this is just"` — not just the existing `"I know what.*skill.*does"` pattern.

- **SC-4:** Behavioral test for SC-1, SC-2, SC-3 written and FAILING (RED) before any `AGENTS.md` or critical-rules changes are made.

## Phases

1. **RED phase:** Expand behavioral test (SC-3) with new rationalization pattern assertions. Add new behavioral test(s) for SC-1 and SC-2. Verify all FAIL against current agent behavior.
2. **Core fix:** Remove carveout from `AGENTS.md` Pre-Response Gate Step 4 (SC-1).
3. **Anti-rationalization rule:** Update critical-rules-006 or add routing-bypass self-authorization rule to `000-critical-rules.md` (SC-2).
4. **GREEN:** Verify all tests pass.

## Single Concern

The Pre-Response Gate Step 4 carveout is the single enabler. Remove it, and the agent's rationalization loses its justification anchor. Expanded tests and explicit rule are supporting structure around the core fix — not separate concerns.

---

🤖 OpenCode (opencode/deepseek-v4-flash-free) created