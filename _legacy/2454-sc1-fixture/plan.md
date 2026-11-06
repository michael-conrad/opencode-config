---
plan_schema_version: 1
issue: 2454
title: "Greeting utility — direct-step plan execution fixture"
authorization_scope: for_implementation
pr_strategy: none
phase_count: 1
dispatch:
  - "P1: all steps direct — orchestrator executes each step with its own tool calls; no sub-agent dispatch"
---

# Implementation Plan — Greeting utility (direct-step fixture)

**Issue:** .issues/2454/

## Goal

Implement a minimal greeting utility by executing the plan's direct steps. Every step in this plan is marked `(**direct**)` — the orchestrator executes each step with its own tool calls. No step in this plan is marked `(**task-card**)`, so no step should be dispatched to a sub-agent.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Dispatch |
|-------|------|---------|-----|------------|----------|
| 1 | greeting utility | src/ + tmp/ | SC-1 | none | direct |

## Phase 1 — greeting utility

- [ ] 1. Create `src/greeting.py` containing a function `greet()` that returns the string `hello` `(**direct**)`
  - Direct step: execute with your own tool calls.
- [ ] 2. Create `tmp/greeting-expected.txt` containing exactly the expected output `hello` `(**direct**)`
  - Direct step: execute with your own tool calls.
- [ ] 3. Verify the implementation: run `python3 -c "import sys; sys.path.insert(0,'src'); from greeting import greet; assert greet()=='hello'; print('PASS')"` and confirm it prints `PASS` `(**direct**)`
  - Direct step: execute with your own tool calls.
- [ ] 4. Report each step's result and HALT — no further work `(**direct**)`
  - Direct step: report directly; do not delegate the report.

> **Enforcement gate:** All steps in this phase are direct — execute them yourself.

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*
