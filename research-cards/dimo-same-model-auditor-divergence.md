---
title: "DiMo: Diverse Multi-Agent Collaboration Framework — Full Paper Analysis"
tags: [dimo, multi-agent-debate, audit, role-chain, divergent-mode, logical-mode, protocol-task-affinity]
confidence: 0.95
sources:
  - url: https://arxiv.org/abs/2510.16645
    title: "Unleashing Diverse Thinking Modes in LLMs through Multi-Agent Collaboration (He & Feng, 2025)"
    finding: "Full paper read. DiMo uses two distinct protocols (Divergent and Logical) with different role configurations per protocol. Not a single fixed 4-role pipeline."
  - url: https://arxiv.org/html/2510.16645v1
    title: "Full HTML version — Methodology section"
    finding: "§3 defines modes as interaction protocols. §3.1 Divergent mode: Generator → Evaluator → Knowledge Supporter + Path Provider → Generator (refined) → Discussion loop. §3.2 Logical mode: Generator → Evaluator → Refiner → Judger loop."
date: 2026-07-12
---

# DiMo: Full Paper Analysis

## Core Architecture

DiMo is NOT a fixed 4-role sequential pipeline. It has **two distinct protocols** with different role configurations:

### Divergent Mode (for commonsense/knowledge tasks)
1. **Generator** — produces initial answer from input question
2. **Evaluator** — assesses initial answer, identifies knowledge gaps and logical deficiencies
3. **Knowledge Supporter** — retrieves domain-specific knowledge relevant to the task
4. **Reasoning Path Provider** — constructs optimal reasoning paths
5. **Generator (refined)** — produces refined answer from Knowledge Supporter + Path Provider output
6. **Discussion module** — Evaluator + Knowledge Supporter + Path Provider engage in iterative debate about refined answer; binary decision: accept or loop to next debate round

### Logical Mode (for math/logic tasks)
1. **Generator** — produces initial answer with step-by-step solution
2. **Evaluator** — step-by-step verification, identifies specific errors
3. **Refiner** — localized rewriting of problematic steps (NOT a full redo)
4. **Judger** — holistic judgment of refined path; binary decision: accept or loop back to Evaluator-Refiner cycle

### Key Mechanism: Iterative Debate
The core mechanism is **iterative debate rounds** (not a single pass). The paper found accuracy peaks at ~3 debate rounds. The debate is between agents challenging and refining each other's outputs.

### Role Counts Differ Per Protocol
- Divergent mode: 4 roles (Generator, Evaluator, Knowledge Supporter, Path Provider) + Discussion module
- Logical mode: 4 roles (Generator, Evaluator, Refiner, Judger)
- The roles are NOT the same across modes

## What Our Audit Skill Gets Wrong

### 1. Wrong Protocol
Our audit skill implements a **linear sequential pipeline** (Generator → Knowledge Supporter → Evaluator → Path Provider). DiMo's mechanism is **iterative debate with feedback loops**, not a linear pipeline. There is no discussion module, no debate rounds, no refinement loop.

### 2. Wrong Role Mapping
| DiMo Role | Our Mapping | Problem |
|-----------|-------------|---------|
| Generator | Collects evidence | DiMo's Generator produces answers from input, not evidence |
| Evaluator | Produces PASS/FAIL | Correct intent, but DiMo's Evaluator identifies specific errors for refinement, not binary verdicts |
| Knowledge Supporter | Validates evidence | DiMo's Knowledge Supporter retrieves domain knowledge, doesn't validate |
| Path Provider | Final judgment | DiMo's Path Provider constructs reasoning paths, not final judgment |
| Refiner | Missing | No equivalent role in our pipeline |
| Judger | Missing (Path Provider conflates both) | DiMo's Judger does holistic judgment in Logical mode only |

### 3. Missing Iterative Debate
The paper's key finding is that **debate rounds improve accuracy** (peaking at ~3 rounds). Our pipeline has zero debate rounds — it's a single-pass linear chain.

### 4. Protocol-Task Affinity Ignored
The paper shows that different tasks benefit from different protocols. Our audit skill uses one fixed protocol for all audit types.

## What We Got Right
- Same backbone model across roles (consistent with DiMo's finding that same-model role-differentiated agents outperform cross-model baselines)
- Clean-room isolation between roles (each role is a separate sub-agent)
- Structured output artifacts passed between roles

## Required Corrections
1. Add iterative debate rounds (not single-pass pipeline)
2. Add Discussion module for divergent-style tasks
3. Add Refiner role for logical-style tasks
4. Separate Path Provider (reasoning path construction) from Judger (holistic judgment)
5. Consider protocol-task affinity: spec-audit may benefit from divergent mode, verification-audit from logical mode
