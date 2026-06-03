# Card 002: Root Cause — Orchestrator Pre-Read Cascade

## Date
2026-06-03

## Predecessor
Card-001

## Observation

The behavioral test inversion is not an isolated bug. It is a symptom of a systemic pattern where the orchestrator:

1. **Pre-reads task files** — loads SKILL.md content, task file definitions, tool source code *into its own context* before dispatching any sub-agent
2. **Pre-analyzes** — forms conclusions about expected outcomes, tool internals, and implementation details *before* running any observation or test
3. **Contaminates sub-agent dispatches** — when it eventually dispatches a sub-agent, the dispatch is biased by the orchestrator's pre-formed conclusions (tool-recipe tasking, pre-determined file paths, expected outcomes)
4. **Or inlines entirely** — decides "this is too small for a skill" and does half-assed inline work instead

## The Two Failure Modes (Same Root)

| Decision | Failure Mode | Result |
|----------|-------------|--------|
| Doesn't dispatch | Inline work | Half-assed, incomplete, context overflow |
| Does dispatch | Micromanages sub-agent | Pre-loaded analysis, tool-recipe tasking, sub-agent used as API proxy |

Both come from the same root: **the orchestrator doesn't trust the sub-agent to do competent work autonomously.**

## Industry Pattern

The GSD (get-shit-done) architecture documents this as the **"thin orchestrator"** anti-pattern:

> *"Loading file contents in the orchestrator is an anti-pattern. The orchestrator receives paths, not file contents. This keeps context usage minimal."*

GSD's target: orchestrator at 10-15% context (~30k tokens). Current state in this system: the agent loads ~47,000 words of instructions + guidelines at session start before any work begins.

## Key Insight from Developer

The agent starts trying to pre-read from the *very first prompt* — before it has received any work instruction, before any dispatch is needed. The pre-read cascade is a session-start reflex, not a reactive choice.