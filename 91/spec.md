# [SPEC] adversarial-audit-022 + dark pattern prose for complete correct workflow execution

## Problem

Two interrelated problems in `.opencode/skills/adversarial-audit/SKILL.md`:

**Problem 1: Orchestrator caches auditor selections.** The orchestrator caches `resolve-models` results across audit/revise loops. On re-audit (spec revised after FAIL, or sub-agent failed upstream), the orchestrator either reuses the cached pair from memory, or refuses to dispatch an auditor because "it was already used." This breaks the adversarial diversity invariant — reusing the same pair on a revised artifact produces the same biases, making re-audit meaningless. Historical auditor usage has no value beyond context load.

**Problem 2: Missing intrinsic motivation to complete the workflow.** The SKILL.md is written as a neutral instruction set. It relies entirely on external enforcement (HALT violations, symbolic rules) to force compliance. There are no prose hooks that make the agent *want* to perform the workflow correctly — no identity binding, no completion compulsion, no consequence framing. This makes the skill fragile: when enforcement gaps exist, the agent has no internal drive to fill them.

## Solution

Two changes to `.opencode/skills/adversarial-audit/SKILL.md`:

### Change 1: Prose + symbolic rule adversarial-audit-022

**Prose** (insert before the symbolic rules block):

> The orchestrator MUST call `resolve-models` on EVERY audit iteration — initial audit, re-audit after revision, and every subsequent re-audit. Historical auditor selections from any prior iteration MUST NOT be cached, reused, or considered. The orchestrator MUST NOT refuse to dispatch auditors based on prior iteration history — a fresh `resolve-models` call is the sole authority for auditor selection in each iteration. On re-audit, the orchestrator discards all prior `resolve-models` result contracts before calling `resolve-models` again. The `excluded_pair` and `re_task` parameters are NOT used for iteration-based re-audit — they exist only for within-iteration retry (e.g., task() failure recovery). Each iteration is independent: the set of available auditors, their availability, and the selection outcome are all re-determined from scratch.

**Symbolic rule** (add to the yaml+symbolic block):

```yaml
  - id: adversarial-audit-022
    title: "resolve-models MUST be called on EVERY audit iteration — no historical caching"
    conditions:
      all: ["audit_iteration > 1", "resolve_models_called == false"]
    actions: [HALT, CALL(resolve-models)]
    source: "adversarial-audit/SKILL.md"
```

### Change 2: Dark pattern prose woven into the SKILL.md body

The SKILL.md body (Overview, Persona, and Routing sections) needs dark patterns that make the agent intrinsically driven to complete the workflow fully and correctly — not through urgency (triggers shortcuts), shame, or insults (counterproductive), but through:

| Pattern | How it works | Example prose |
|---------|-------------|---------------|
| **Identity binding** | Ties correct execution to role identity. "A thorough auditor does X" frames X as part of being competent. | "A thorough auditor resolves models fresh every iteration — reusing cached selections is what incomplete auditors do." |
| **Completion compulsion** | Frames partial execution as not-an-audit. Incomplete audit is a simulation, not real work. | "An audit iteration that reuses cached auditors is not an audit at all — it is a simulation. Real audits start fresh every time." |
| **Sunk cost / consequence framing** | Connects skipping resolve-models to discarding all prior audit work. Stale auditors invalidate the entire pipeline. | "Every resolve-models call is negligible cost. The cost of stale auditors is complete workflow failure — every prior verification, every finding, every revision is discarded when the foundation is corrupt." |
| **Momentum chain** | Frames the dispatch sequence as a single indivisible unit. Breaking the chain invalidates everything before it. | "resolve-models → dispatch → cross-validate is a single indivisible chain. Breaking this chain — skipping resolve-models, reusing cached selections, refusing to dispatch — invalidates every step that came before. If the chain is broken, no verdict produced afterward is trustworthy." |

These patterns should be woven into the **Persona** section and the **Overview** section, not dumped as a separate "Dark Patterns" block. They work best when they feel like natural statements of competence standards, not injected manipulation.

## Success Criteria

- **SC-1**: On every audit iteration, the orchestrator calls `resolve-models` before dispatching auditors — initial audit, every re-audit after revision, every re-audit after sub-agent failure.
- **SC-2**: The orchestrator discards all prior `resolve-models` result contracts before each new call — no caching, no consideration of prior selections.
- **SC-3**: The orchestrator never refuses to dispatch an auditor based on historical usage from a prior iteration — the fresh `resolve-models` call is the sole authority.
- **SC-4**: The SKILL.md body contains prose that intrinsically motivates complete correct workflow execution using identity binding, completion compulsion, consequence framing, and momentum chain patterns.
- **SC-5**: Dark pattern prose does not use urgency, shame, insults, or patronizing language.

## Files Changed

- `.opencode/skills/adversarial-audit/SKILL.md` — add prose paragraph + symbolic rule (adversarial-audit-022) + dark pattern prose in Overview/Persona sections

## Risk Analysis

Low risk. `resolve-models` is stateless and idempotent. Prose changes to SKILL.md carry no execution risk. The dark patterns are gentle cognitive hooks — they increase completion reliability without introducing new code paths or failure modes.