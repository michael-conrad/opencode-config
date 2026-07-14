---
research_question: "What form should cross-reference load directives take in the opencode deck, given the existing organizational patterns?"
status: active
confidence: 0.85
date: 2026-07-13
tags: [cross-reference, progressive-disclosure, context-engineering, guidelines, skills]
sources:
  - https://mbleigh.dev/posts/context-engineering-with-links/
  - https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
  - https://deepwiki.com/microsoft/agent-skills/5.3-progressive-disclosure-pattern
  - https://agentskills.io/specification
---

# Cross-Reference Lobotomization

## Problem

The opencode guidelines use ~136 cross-references of the form `See \`FILENAME.md\` §SECTION` or `See \`SKILLNAME\` skill`. These are written as prose citations. The agent treats them as decorative closing sentences rather than as load directives. The agent reads the summary sentence before "see" and treats it as the complete rule, never loading the referenced content where the actual rule lives.

## Research Findings

### Industry Standard: Progressive Disclosure

Microsoft agent-skills, Anthropic context engineering, and the mbleigh.dev implementation all use progressive disclosure — lightweight identifiers that the agent loads on demand. The opencode guidelines are structured correctly for this pattern. The failure is that the identifiers are framed as citations, not as load directives.

### Existing Load Directives in the Deck

The deck already has one explicit load directive pattern: the `Read \`<skill>/tasks/<task>.md\` first` directive in SKILL.md DISPATCH_GATE sections. This tells sub-agents to independently read a task file. The word "Read" is the trigger — it's an imperative verb that the agent interprets as a tool-use instruction.

The deck also has load directives in Trigger Dispatch Tables and Invocation sections, but these use `task()` dispatch strings, not file-read instructions. They route to sub-agents, not to file content.

### What Fails

Guideline inline prose cross-references use "See" — a passive verb that the agent interprets as a citation, not an instruction. The backtick-wrapped filename is not recognized as a loadable resource. The `§` section reference is not recognized as a navigation target.

### What Would Work

The deck's own `Read \`<path>\` first` pattern is the closest existing load directive. It uses:
- An imperative verb ("Read")
- A backtick-wrapped path
- A temporal qualifier ("first")

For guideline cross-references, the replacement form should follow the same pattern but adapted for the guideline context. The agent needs to know:
1. That the current text is incomplete (the summary is not the rule)
2. What to load (the file path and section)
3. When to load it (before proceeding)

## Proposed Form

Replace `See \`065-verification-honesty.md\` §Cost Model` with:

```
The rule is incomplete without `065-verification-honesty.md` §Cost Model — load it now.
```

This uses:
- "The rule is incomplete without" — signals that the current text is a summary, not the full rule
- Backtick-wrapped path + `§` section — the existing identifier format, preserved
- "load it now" — imperative directive with temporal qualifier

The word "load" is chosen over "read" because "read" in the deck already has a specific meaning (sub-agent task file discovery). "Load" is unambiguous — it means "fetch this content into your context."

## Confidence

0.85 — The research is clear on progressive disclosure as the correct pattern and on the failure mode (citation vs. directive). The proposed form follows the deck's own `Read \`<path>\` first` pattern. The remaining uncertainty is whether "load it now" is the optimal imperative phrase or whether a different formulation would produce more reliable agent behavior.
