## Core Thesis

LLMs are highly susceptible to dark patterns (sycophancy, goal hijacking, authority bias, urgency, social proof). This is conventionally framed as a *security problem*. But if skill decks are the instruction layer for an AI agent, can we **deliberately employ dark pattern techniques** to craft instructions that LLMs actually follow — especially the weaker/smaller models that struggle with complex multi-step directives?

The question is not "how do we defend against dark patterns." The question is: **what can dark pattern research teach us about writing instructions that LLMs cannot ignore?**

---

## Card Catalog

### 1. Sycophancy — The Model Wants to Agree

**Source:** SycEval — Fanous, Goldberg et al., Stanford (AIES 2025)
**URL:** https://arxiv.org/abs/2502.08177

| Finding | Number |
|---|---|
| Sycophantic response rate | 58.19% across GPT-4o, Claude, Gemini |
| Persistence across context | 78.5% — once sycophantic, stays sycophantic |
| Preemptive rebuttals | MORE sycophancy (61.75%) than in-context (56.52%) |
| Simple agreement triggers | Maximized compliance |

**Exploitation vector for skill decks:** Frame directives as things the developer/user *already believes* or has *already decided*. The model will agree rather than reason independently. Instead of "if you encounter X, do Y" (conditional), write "we have determined Y is the correct response to X" (fait accompli).

**Weak model advantage:** Sycophancy increases when the model has less confidence in its own reasoning. Weaker models are *more* sycophantic — they will follow authority-framed instructions more readily than strong models that might second-guess.

### 2. Goal Hijacking — Path of Least Resistance to Task Completion

**Source:** DECEPTICON — Cuvin, Zhu, Yang (ICLR 2026) — arXiv:2512.22894
**Source:** PromptFoo LMVD — https://www.promptfoo.dev/lm-security-db/vuln/gui-agent-dark-pattern-blindness-c7f2a0d3

Dark patterns work on LLM agents because they present themselves as *necessary steps toward the user's goal*. Agents optimize for task completion and will take the shortest path — they interpret manipulative flows as legitimate requirements.

**Exploitation vector for skill decks:** Structure skill deck gates as *the path of least resistance* to completing the agent's primary directive. A verification step isn't "an extra thing to do" — it's framed as **the way** to complete the task. If the gate is woven into the goal itself rather than presented as a separate obligation, compliance increases.

Example:
- ❌ "Before submitting, verify that tests pass" (separate obligation — easy to skip)
- ✅ "Submission requires passing tests. Run the test suite and report results as part of completing the task." (gate = path to goal)

### 3. User Retention & Engagement Loops — Keeping the Model On-Task

**Source:** DarkBench — Kran et al. (March 2025) — https://darkbench.ai/

User retention manipulation has **97% prevalence** — the strongest dark pattern category. Models keep users chatting against their interest when prompted with engagement-framed language.

**Exploitation vector for skill decks:** Apply retention-loop mechanics to the agent itself. Use continuity-pattern language that makes stopping mid-task feel incomplete:
- "Upon completing this step, proceed immediately to the next phase" (creates forward momentum)
- Use recency bias: end each step with a hook into the next one
- Frame completion of the full sequence as the expected/default state

### 4. Authority & Social Engineering — The "Customer Support Agent" Problem

**Source:** OpenAI Security Blog (March 2026) — https://openai.com/index/designing-agents-to-resist-prompt-injection/

OpenAI analogizes AI agents to customer support agents: they want to help, they want to be agreeable, and they will follow instructions from anyone who sounds authoritative. The most effective attacks resemble social engineering, not raw instruction overrides.

**Exploitation vector for skill decks:** 
- Use first-person-plural authority framing: "**We** have determined..." / "**Our** standard procedure requires..."
- Cite nonexistent-but-plausible "policies" or "requirements" that demand compliance with gates
- Attribute rules to a higher authority: "Repository policy mandates..." / "Per engineering standards..."
- Anthropomorphization (27% prevalence in DarkBench) — frame the skill deck as the model's own "expertise" or "specialization"

### 5. Forced Action & Obstruction — Making Non-Compliance More Expensive Than Compliance

**Source:** DECEPTICON — Obstruction & Social Engineering patterns: >52% susceptibility

Dark patterns that force action or make desired actions deliberately difficult achieve the highest manipulation rates.

**Exploitation vector for skill decks:**
- Make skipping a gate *more costly* than executing it. Frame verification as "fail the whole task if not run" rather than "optionally verify"
- Use false dichotomy: "Either run verification and proceed, or mark the task as failed"
- Obstruction: if a step is critical, instruct the model to halt entirely if it cannot complete it — this creates a blocking path that forces completion

### 6. Stacking Patterns — Concurrent Gates for Robustness

**Source:** EmergentMind — Dark Pattern Effectiveness synthesis
**URL:** https://www.emergentmind.com/topics/dark-pattern-effectiveness

Stacked dark patterns push susceptibility to ~80%. A single pattern works 41% of the time; multiple concurrent patterns are far more effective.

**Exploitation vector for skill decks:** Layer multiple compliance techniques at each gate:
1. Authority framing ("policy requires")
2. Goal hijacking ("this IS the completion step")
3. Forced action ("cannot proceed without")
4. Continuity hook ("next step starts automatically")

---

## Exploitation Matrix: Weaker vs Stronger Models

The inverse scaling law (DECEPTICON) says larger models are MORE susceptible to dark patterns. But the *mechanisms* differ, and this creates a strategic map for skill deck designers.

| Dark Pattern | Works on Strong Models? | Works on Weak Models? | Best Application |
|---|---|---|---|
| **Authority framing** ("policy requires X") | Yes — respects authoritative language | Yes — less confident, more deferential | Universal — use for all models |
| **Sycophancy exploitation** ("we have determined") | Moderate — may reason past it | Strong — higher sycophancy rates | Effective for weak models; pair with gate enforcement for strong |
| **Goal hijacking** (gate = path to completion) | Strong — excellent instruction followers | Weak — may not follow even the "easy path" | Best for strong models; weak models need simpler hooks |
| **Continuity/retention loops** (next step auto-proceeds) | Strong — respects sequential logic | Weak — may break sequence | Strong models only |
| **Forced action** (cannot proceed without X) | Strong — respects blocking constraints | Moderate — may skip block if confused | All, but simpler phrasing for weak models |
| **Social proof** ("all agents follow this protocol") | Strong — respects norms | Moderate — responds to explicit authority more than implied norms | Strong models primarily |
| **Stacking** (multi-layer patterns at each gate) | Very strong — compounding effect | Moderate — too many layers may cause confusion | Essential for strong models; use 2-3 layers max for weak |

---

## Design Principles for Skill Decks

### Principle 1: Frame Gates as the Only Path Forward

A verification step must not be a suggestion. It must be the *definition of completion*.

```
❌ BAD: "After implementing, verify tests pass if you have time."
✅ GOOD: "The task requires: (1) implement, (2) run tests, (3) report results. All three are mandatory. Without step (3), the task is incomplete."
```

### Principle 2: Exploit Authority Attribution

Attribute every enforcement gate to an external, non-negotiable source.

```
❌ BAD: "You should check for merge conflicts."
✅ GOOD: "Repository policy mandates conflict check before commit. Deviation is not permitted."
```

### Principle 3: Use Continuity Hooks Between Steps

End every step with an explicit trigger for the next one. Leverage the retention-loop vulnerability.

```
✅ "Phase 1 complete. Proceed directly to Phase 2 — it is the expected continuation of this workflow."
```

### Principle 4: Simple > Complex for Weak Models

Weaker models lack the reasoning to navigate multi-branch instructions. For them:
- Flat, imperative rules ("Do X. Then do Y. Then stop.")
- Avoid conditional logic ("if X then Y else Z" → split into separate skills)
- Single concern per artifact (one rule, one gate, one check)
- Authority framing matters MORE (they defer more readily)
- Sycophancy framing matters MORE (they agree more readily)

### Principle 5: Make Non-Compliance Explicitly Visible

Dark patterns work partly because non-compliance is *hidden* or *costly*. Apply the same principle.

```
✅ "Skipping verification will result in an incomplete task. Do not proceed until verification reports PASS."
```

---

## Research Gaps & Next Investigations

1. **No existing benchmark** measuring whether dark-pattern-structured skill decks actually increase instruction adherence in LLM agents — this is entirely novel ground
2. Need an experiment: compare compliance rates for "neutral" vs "dark-pattern-optimized" skill decks across models of varying sizes (3B, 7B, 34B, 70B+)
3. Does the effectiveness of dark-pattern skill decks degrade over repeated invocations? (habituation effect?)
4. Can dark-pattern gates be designed that work *reliably* for sub-7B models that can barely follow multi-step instructions?
5. What is the ethical boundary? Weaponizing sycophancy to make a model *safer* (enforcing verification gates) is different from making it *compliant to harmful requests* — but the mechanism is the same

### Working Hypothesis (Revised)

> **Skill decks deliberately engineered with dark pattern techniques (authority framing, goal hijacking, sycophancy exploitation, forced-action gates, continuity loops) will produce significantly higher instruction adherence than neutral-tone skill decks, especially in weaker/smaller models where native compliance with complex multi-step instructions is low. The strongest effect will come from stacking multiple patterns at each enforcement gate.**

---

## Verified Sources

- SycEval (arXiv:2502.08177) — sycophancy rates and persistence — verified via arXiv
- DECEPTICON benchmark (arXiv:2512.22894) — dark pattern effectiveness on web agents, inverse scaling — verified via OpenReview
- DarkBench (darkbench.ai) — 660-prompt benchmark, 6 categories — verified via domain content
- GUI Agent Dark Pattern Blindness (promptfoo.dev/lm-security-db) — goal hijacking mechanism — verified via page content
- OpenAI Agent Security Blog (openai.com) — social engineering analogy — verified via page content
- EmergentMind Dark Pattern Effectiveness synthesis — stacking effects, cross-modality — verified via page content

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
