---
plan_schema_version: 1
issue: 2454
title: "Greeting utility — mixed dispatch-mode plan execution fixture"
authorization_scope: for_implementation
pr_strategy: none
phase_count: 1
dispatch:
  - "P1: step 1 direct, step 2 task-card, step 3 direct — dispatch ONLY at the task-card-marked step; direct steps execute with the orchestrator's own tool calls"
---

# Implementation Plan — Greeting utility (mixed dispatch-mode fixture)

**Issue:** .issues/2454/

## Goal

Implement a minimal greeting utility by executing the plan's steps honoring each step's dispatch indicator exactly as marked. Steps marked `(**direct**)` are executed by the orchestrator with its own tool calls. Exactly one step — Step 2 — is marked `(**task-card**)` and is dispatched to a sub-agent via `task()`. No other step may be dispatched.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Dispatch |
|-------|------|---------|-----|------------|----------|
| 1 | greeting utility (mixed) | src/ + tmp/ | SC-3 | none | step 1 direct, step 2 task-card, step 3 direct |

## Phase 1 — greeting utility (mixed)

- [ ] 1. Create `src/greeting.py` containing a function `greet()` that returns the string `hello` `(**direct**)`
  - Direct step: execute with your own tool calls. Do NOT dispatch this step.
- [ ] 2. Dispatch a sub-agent via `task()` to independently compute the expected greeting string by concatenating `hel` and `lo`, and report the computed string back `(**task-card**)`
  - Task-card step: dispatch this step's task card via `task()` with a short task-card dispatch string — never the plan body or phase body. This is the ONLY step in this plan that is dispatched.
- [ ] 3. Verify the implementation: run `python3 -c "import sys; sys.path.insert(0,'src'); from greeting import greet; assert greet()=='hello'; print('PASS')"` and confirm it prints `PASS` `(**direct**)`
  - Direct step: execute with your own tool calls. Do NOT dispatch this step.

> **Enforcement gate:** Dispatch occurs ONLY at the `(**task-card**)`-marked step (Step 2). Steps 1 and 3 are direct and MUST be executed by the orchestrator with its own tool calls.

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*
