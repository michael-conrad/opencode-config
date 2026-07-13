---
question: What text-only mechanism prevents agents from making unverified factual claims?
confidence: 0.9
tags: [verification-gate, research-first, proactive-verification, pre-response-gate]
source: Session analysis with developer Michael Conrad — defect pattern: agent made factual claims about .issues/ worktree behavior with zero tool calls. Multiple approaches tested and discarded.
date: 2026-07-12
status: active
---

## Finding

The only text-only mechanism that works is a **numbered pre-response procedure with binary checks and a halt condition**, modeled on the existing skill dispatch gate in the system prompt. The `<thinking>` block approach was discarded — there is no mechanism to "insert" text into the agent's reasoning block.

### Discarded Approaches

| Approach | Why Discarded |
|----------|---------------|
| `<thinking>` block verification checkpoint | No injection mechanism exists. The agent generates its own thinking — guideline text cannot place a literal string there. |
| Behavioral enforcement test | Requires code changes (test scripts). Out of scope. |
| Plugin / session-enforcement.ts | Requires code changes. Out of scope. |
| opencode.jsonc config | Requires code changes. Out of scope. |

### Working Approach: Pre-Response Factual Claim Gate

A numbered procedure in `065-verification-honesty.md` that replaces the existing prose-heavy Research-First Mandate and Proactive Verification sections:

```
### Pre-Response Factual Claim Gate

Before producing ANY response that contains factual claims about the workspace,
codebase, configuration, system behavior, or any observable property, you MUST
follow this procedure:

1. Identify each factual claim in the response you are about to produce.
2. For each claim, check: Has a tool call been made in this exchange that
   verifies this claim?
3. If NO tool call has been made: Make one before producing the claim.
4. If the tool call contradicts the claim: Correct the claim.
5. If no tool can verify the claim: Do not make the claim.

HALT condition: A response with factual claims and zero preceding tool calls
is a CRITICAL VIOLATION.
```

### Why This Works

| Existing prose | Numbered procedure |
|---|---|
| "the agent MUST attempt exhaustive research" — mandate, easy to skip | "Step 1: identify claims. Step 2: check each one." — checklist, harder to skip |
| Describes *what* to do | Describes *how* to do it, in order |
| No binary pass/fail condition | Binary check: tool call made / not made |
| No halt condition | HALT on zero tool calls with factual claims |
| Reactive framing ("when instructed to check") | Proactive framing ("fires on every response") |

### Files Changed

- `065-verification-honesty.md` — Replace Research-First Mandate and Proactive Verification sections with the numbered procedure. Delete old prose.

### Limitations

- No programmatic enforcement — relies on agent compliance with the procedure
- No behavioral test to verify agent follows the rule (out of scope)
- The numbered procedure pattern works for the skill dispatch gate because it's in the system prompt (instructions array), not in a guideline file the agent reads reactively. This guideline is loaded on-demand, not at session start.

### Related Research

- `020-go-prohibitions.md` §1 — cost-blind verification mandate
- `065-verification-honesty.md` — the file being changed
- `257-procedural-discipline-reference.md` p-dis-006 — "internal reasoning IS NOT verification"
