# Card 001: Symptom — Behavioral Test Order Inversion

## Date
2026-06-03

## Source
GitHub Issue #1003, discussion with developer

## Observation

The SC-3 behavioral test (`local-issues-autonumber`) prompt specifies:

> *"If you observe a bug, the claim is substantiated — read the tool source code to confirm the root cause. If the behavior is correct, the claim is not substantiated — don't waste time reading the code, just report clean."*

The agent:
1. READ tool source at `tools/local-issues` (Step 8)
2. BASH `ls .opencode/tools/` — tool discovery (Step 11)
3. READ full tool source (Step 13)
4. Analyzed `_next_number()` internals from read source (Step 16)
5. Ran behavioral test (Step 23+)

**Behavioral observation occurred 10+ steps after source was read.**

## Classification

This is a **prompt ordering violation** — the agent treats "investigate" as "reverse-engineer the code to understand internals" rather than "observe behavior as a black-box, read code only as post-bug-confirmation."

## Evidence

The agent's reasoning (Part 11 in session.yaml trace):

> *"Let me first check the current state of the `.issues/` directory **and understand the tool**, then proceed with the investigation."*

The agent interpreted "investigate" as "understand internals first," inverting the prompt's explicit ordering.