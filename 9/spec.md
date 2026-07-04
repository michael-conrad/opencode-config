---
number: 9
title: "[SPEC-FIX] Infrastructure Failure Claim Proof Mandate — evidence + user report + hard halt for all workflows"
status: DRAFT
labels: [SPEC-FIX]
created: 2026-07-02T00:00:00+00:00
---

# [SPEC-FIX] Infrastructure Failure Claim Proof Mandate — evidence + user report + hard halt for all workflows

## Intent and Executive Summary

- **Problem Statement:** When an agent claims an infrastructure component (model, MCP server, CLI tool, network endpoint, credential, test harness) is missing, unavailable, or failing, it currently produces that claim without mandatory proof and without a structured user-facing report. The agent may continue working despite the claimed failure, or escalate without the user ever seeing what actually failed. This creates a blind spot: the user cannot verify the claim, and the agent's halt state is ambiguous.

- **Root Cause/Motivation:** Existing rules (`065-verification-honesty.md` anti-evasion, `000-critical-rules.md` §accountability-ownership, `080-code-standards.md` behavioral test integrity) address domain-specific subsets (model unavailability, behavioral test failures, pre-existing failures) but there is no single unified mandate that applies to ALL infrastructure/test requirement failure claims with three non-negotiable obligations: (1) produce tool-call evidence proving the claim, (2) report the evidence to the user immediately, (3) halt in an explicit "can't continue" state. Without this unification, agents can route around domain-specific rules by claiming failures in areas not yet covered.

- **Approach Chosen:** Add a new Tier 1 critical rule (`critical-rules-070` or next available) to `000-critical-rules.md` titled "Infrastructure Failure Claim Proof Mandate" that establishes three obligations for any infrastructure/test requirement failure claim. Add corresponding entries to `065-verification-honesty.md` §Anti-Evasion Rules as a new pattern. Add a yaml+symbolic rule to `000-critical-rules.md` for machine-parseable enforcement. Update `020-go-prohibitions.md` §1 ALWAYS DO to cross-reference. No behavioral test needed — this is a structural rule addition (string evidence type).

## Problem Analysis

### What Constitutes an "Infrastructure or Test Requirement Failure Claim"

Any agent assertion that one of the following is missing, unavailable, broken, or failing:

| Category | Examples |
|----------|----------|
| **Model availability** | "model X is not available", "Ollama server is down", "inference timeout" |
| **MCP server** | "srclight MCP not responding", "GitHub MCP disconnected", "the-notebook-mcp unavailable" |
| **CLI tool** | "gb CLI not found", "opencode-cli not installed", "uv not available" |
| **Network/credential** | "cannot reach GitHub API", "token expired", "SSH key missing" |
| **Test infrastructure** | "pytest fixtures broken", "test DB unavailable", "Jupyter server not running" |
| **Build toolchain** | "ruff not installed", "TypeScript compiler missing", "build system broken" |
| **Any other infrastructure** | Any claim that a required component cannot fulfill its role |

### Why This Matters

| Without Proof Mandate | With Proof Mandate |
|----------------------|-------------------|
| Agent claims "model unavailable" — user cannot verify | Agent must show `opencode-cli models` output proving the model is absent |
| Agent claims "MCP server down" — user must trust the claim | Agent must show the actual error/timeout from the MCP call |
| Agent claims "test infrastructure broken" — user must investigate | Agent must show the failing command output |
| Agent halts with vague "blocked" message | Agent halts with structured evidence block: claim, proof, remediation attempted |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `000-critical-rules.md` contains a new rule section "Infrastructure Failure Claim Proof Mandate" with three obligations: evidence, user report, hard halt | `string` |
| SC-2 | `000-critical-rules.md` yaml+symbolic rules block includes a new rule for infrastructure-failure-proof | `string` |
| SC-3 | `065-verification-honesty.md` §Anti-Evasion Rules contains a new Pattern (d) covering infrastructure failure claims | `string` |
| SC-4 | `020-go-prohibitions.md` §1 ALWAYS DO contains a cross-reference to the new infrastructure-failure-proof rule | `string` |

## Scope of Change

### Files to Modify

1. **`.opencode/guidelines/000-critical-rules.md`** — Add new Tier 1 rule section + yaml+symbolic rule
2. **`.opencode/guidelines/065-verification-honesty.md`** — Add Pattern (d) to §Anti-Evasion Rules
3. **`.opencode/guidelines/020-go-prohibitions.md`** — Add cross-reference in §1 ALWAYS DO

### Files NOT Modified

- No skill SKILL.md files changed (rule is global, enforced by guidelines)
- No task files changed (rule applies at guideline level, not per-task)
- No test infrastructure changed (string evidence type, content-verification sufficient)

## Rule Specification

### New Rule: Infrastructure Failure Claim Proof Mandate

**Location:** `000-critical-rules.md` — new section after §accountability-ownership or next available slot

**Tier:** 1 (Safety-Critical) — because unverified infrastructure claims can cause the agent to halt incorrectly (false halt) or continue incorrectly (false continue), both of which are pipeline-integrity violations.

**Three Obligations:**

#### Obligation 1: Evidence Before Claim

When the agent asserts that any infrastructure component or test requirement is missing, unavailable, or failing, it MUST produce tool-call evidence proving the claim BEFORE making the assertion. The evidence must be:

- A live tool call in the current session (not memory, not training data)
- Captured in the same exchange as the claim
- Sufficient for a third party to independently verify the failure

**Forbidden patterns:**
- Claiming "model not available" without showing `opencode-cli models` output
- Claiming "MCP server down" without showing the actual error response
- Claiming "tool not found" without showing `command -v` or equivalent
- Claiming "network unreachable" without showing the actual connection error
- Claiming "credential invalid" without showing the API rejection response

#### Obligation 2: Immediate User Report with Evidence

When an infrastructure failure claim is made, the agent MUST immediately report to the user with:

1. **What failed** — the component and the specific failure
2. **The proof** — the tool-call output or error message
3. **What was attempted** — any remediation steps already taken
4. **Current state** — what the agent can and cannot do given the failure

The report goes to chat output (not issue comment). The agent MUST NOT silently halt or continue without the user seeing the evidence.

#### Obligation 3: Hard Halt in "Can't Continue" State

After reporting, the agent MUST halt in an explicit "can't continue" state. This means:

- No further pipeline steps execute
- No implementation, no PR creation, no issue closure
- The halt message MUST include the word "BLOCKED" and the component name
- The agent MUST NOT offer to work around the failure without the user's explicit instruction
- The agent MUST NOT ask "should I continue without X?" — that is solicitation (prohibited)

**Exception:** The agent MAY attempt remediation (alternative model, retry, restart MCP server) BEFORE making the final failure claim. The three obligations fire only when remediation has been exhausted and the claim is final.

### Integration Points

| Existing Rule | Relationship |
|---------------|-------------|
| `065-verification-honesty.md` §Anti-Evasion Pattern (a) | Extends from "model unavailability" to ALL infrastructure |
| `000-critical-rules.md` §accountability-ownership #7 | Complements "remediate autonomously" — this rule defines the proof obligation AFTER remediation fails |
| `000-critical-rules.md` §accountability-ownership #8 | Complements "no pre-existing failure rationalization" — this rule defines the evidence standard |
| `080-code-standards.md` §Test Integrity Mandate | Complements behavioral test integrity — this rule covers infrastructure supporting tests |
| `020-go-prohibitions.md` §1 Cost-blind verification | Reinforces that proof-gathering cost is never a skip justification |

## Risk Analysis

| Risk | Mitigation |
|------|-----------|
| Rule too broad — catches transient network blips | Obligation includes "attempt remediation BEFORE claiming" — transient issues self-resolve |
| Agent spends too long proving failures | Proof is a single tool call — bounded cost |
| User overwhelmed by evidence reports | Report is structured and concise — one chat message per failure |
| Rule conflicts with "silent halt" mandate | This rule supersedes silent halt for infrastructure claims — user MUST see evidence |

## Change Control

- **Labels:** `SPEC-FIX`
- **Scope:** Global guidelines only — no code, no skills, no task files
- **Reversibility:** High — remove the rule section and yaml+symbolic entry
