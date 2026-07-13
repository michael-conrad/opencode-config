---
title: "Audit Skill DiMo Role Chain Defects — Monolithic Task Files vs. 4-Role Dispatch"
tags: [dimo, audit, role-chain, monolithic-task, dispatch-defect, skill-description]
confidence: 0.95
sources:
  - url: https://opencode.ai/docs/skills/
    title: "OpenCode Agent Skills Documentation"
    finding: "description field is the sole dispatch signal. Agent matches user intent against description text. No other mechanism exists for skill selection."
  - url: https://arxiv.org/abs/2510.16645
    title: "DiMo: Diverse Multi-Agent Collaboration (He & Feng, 2025)"
    finding: "4-role chain (Generator → Knowledge Supporter → Evaluator → Path Provider) with clean-room isolation. Each role is a separate sub-agent with distinct persona and system prompt."
  - url: file://.opencode/skills/audit/SKILL.md
    title: "audit/SKILL.md — DiMo Role Chain Dispatch section"
    finding: "SKILL.md §DiMo Role Chain Dispatch says orchestrator dispatches 4 roles in sequence. But Trigger Dispatch Table dispatches to monolithic task files, not per-role sub-agents."
  - url: file://.opencode/skills/audit/tasks/spec-audit.md
    title: "spec-audit.md — claims Evaluator role but contains all roles"
    finding: "Task file says 'DiMo Role: Evaluator' but Step 0a is Knowledge Supporter work, and procedure includes evidence collection (Generator work). Single monolithic procedure."
summary: "The audit skill has a structural contradiction between its documented DiMo role chain (4 separate sub-agents dispatched in sequence) and its actual implementation (monolithic task files that each claim a single role but contain procedures for all roles). No dedicated Generator, Knowledge Supporter, or Path Provider task files exist. The orchestrator dispatches one sub-agent per audit task, not four. This produces defective audits because the same sub-agent that collects evidence also evaluates it — violating the clean-room separation that DiMo is designed to enforce."
applies_to:
  - audit-skill
  - spec-audit
  - verification-audit
  - plan-fidelity
  - cross-validate
  - resolve-models
  - completion
created: 2026-07-12
---

# Audit Skill DiMo Role Chain Defects

## The Core Contradiction

The audit SKILL.md documents a 4-role DiMo chain (Generator → Knowledge Supporter → Evaluator → Path Provider) where the orchestrator dispatches each role as a separate clean-room sub-agent. But the actual implementation has:

1. **No dedicated role task files** — glob for `*generator*`, `*knowledge*`, `*evaluator*`, `*path*` returns nothing
2. **Monolithic task files** — each task file claims a single DiMo role but contains procedures for all roles
3. **Single sub-agent dispatch** — the orchestrator dispatches one sub-agent per audit task, not four

## Defect Catalog

### Defect 1: SKILL.md description uses user-utterance matching
The description says "User phrases: audit spec, audit plan..." — this is the #1899 pattern. The description should describe agent-intent dispatch conditions, not user utterance patterns.

### Defect 2: DiMo role chain documented but not implemented
SKILL.md §DiMo Role Chain Dispatch says "The orchestrator dispatches roles in order" but the Trigger Dispatch Table dispatches to monolithic task files. No orchestrator ever dispatches 4 separate sub-agents.

### Defect 3: Task files claim single role but contain all roles
spec-audit.md says "DiMo Role: Evaluator" but Step 0a is Knowledge Supporter work (validate evidence → write reasoning.yaml). The procedure includes evidence collection (Generator work). The same sub-agent that collects evidence also evaluates it.

### Defect 4: resolve-models contradicts itself
Says "Model selection is embedded in the sequential dispatch — no separate resolve-models tool invocation is needed" but other skills reference resolve-models for auditor model selection.

### Defect 5: completion and cross-validate both claim Path Provider role
Two different task files both claim to be the Path Provider (Judger) role, creating role ambiguity.

### Defect 6: No clean-room isolation between roles
Since a single sub-agent executes the monolithic procedure, there is no clean-room isolation between evidence collection and evaluation — the same context produces both, violating the DiMo principle.

## Required Fix

The audit skill needs either:
- (a) True 4-role dispatch: 4 separate task files (generator, knowledge-supporter, evaluator, path-provider) with the orchestrator dispatching each as a separate clean-room sub-agent, OR
- (b) Honest single-role labeling: admit the task files are monolithic and remove the DiMo role chain documentation

Option (a) is the correct fix per the DiMo research.
