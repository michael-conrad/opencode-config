---
title: '[SPEC-FIX] Mandatory full compliance with spec-creation task procedure — no exceptions, no bypasses, no escape hatches'
status: draft
created: 2026-07-16
license: MIT
provenance: AI-generated
issue: 1969
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-16

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The spec-creation task procedure (`spec-creation-validation/tasks/create.md`) defines a mandatory sequence of steps for creating any spec. Despite this, agents routinely bypass the procedure — skipping steps, inlining work, or treating "simple" or "small" specs as exempt.

The most recent example: a spec for gating the per-turn git config watchdog was created by calling `github_issue_write` directly with a raw body, bypassing the entire spec-creation pipeline — no stub creation, no analytical artifacts, no self-review, no evidence verification, no compliance blockquotes, no SC coverage YAML, no handoff manifest. The spec was created as if the task procedure did not exist.

This is a process-integrity failure. The task procedure exists because every step catches a class of defect. Skipping steps means accepting those defects into every spec produced.

## Root Cause

The spec-creation task procedure has no enforcement mechanism. It documents what MUST be done but provides no gate that blocks non-compliant spec creation. The `create` task is a procedure document, not an enforcement gate. Agents treat it as advisory because there is no consequence for bypassing it.

Additionally, the orchestrator's `task()` dispatch to the spec-creation sub-agent provides no verification that the sub-agent actually followed the procedure. The orchestrator receives a result contract (`status: DONE`) and proceeds — it never inspects whether the sub-agent executed every step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Add a pre-commit hook that validates spec procedure compliance | Pre-commit hooks run on commit, not during spec creation — too late to prevent bypass |
| Add a CI check that validates spec artifacts exist | CI runs after push — the bypass has already happened |
| Add a single critical violation entry only | Without sub-agent self-certification and orchestrator gate, the critical violation has no enforcement mechanism |

## Fix

Add a **procedure-compliance gate** to the spec-creation pipeline that enforces full procedure adherence. The gate has three components:

### Component 1: Sub-agent Self-Certification (in create.md)

Add a mandatory self-certification step at the end of the `create.md` procedure. The sub-agent MUST produce a compliance attestation listing every step in the procedure and confirming it was executed.

### Component 2: Orchestrator Compliance Gate (in spec-creation SKILL.md)

Add an orchestrator-level gate that validates the sub-agent's compliance attestation before accepting the result.

### Component 3: Critical Violation (in 000-critical-rules.md)

Add a critical violation entry for spec-creation procedure bypass.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [spec-creation procedure compliance issue](https://github.com/michael-conrad/.opencode/issues/1969) | SELF | This spec itself |

## Affected Files

- `skills/spec-creation-validation/tasks/create.md` — Add procedure compliance attestation step
- `skills/spec-creation/SKILL.md` — Add orchestrator post-dispatch compliance gate
- `guidelines/000-critical-rules.md` — Add critical-rules-spec-procedure-bypass entry

## SC-to-Root-Cause Traceability

| SC ID | Root Cause Element | What It Tests |
|-------|-------------------|---------------|
| SC-1 | No enforcement in create.md | Procedure compliance attestation step exists |
| SC-2 | No orchestrator gate in SKILL.md | Orchestrator post-dispatch compliance gate exists |
| SC-3 | No critical violation for bypass | Critical violation entry exists |
| SC-4 | Sub-agent can skip steps without consequence | Sub-agent that skips steps has result rejected |
| SC-5 | "Too small" rationalization is accepted | Prohibited rationalization triggers rejection |
| SC-6 | Direct API call bypasses procedure | Direct call triggers CRITICAL VIOLATION halt |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `create.md` includes procedure compliance attestation step as final step | `string` | grep for `procedure_compliance` in `spec-creation-validation/tasks/create.md` |
| SC-2 | `spec-creation/SKILL.md` includes orchestrator post-dispatch compliance gate | `string` | grep for `Procedure Compliance Verification` in `spec-creation/SKILL.md` |
| SC-3 | `000-critical-rules.md` includes critical-rules-spec-procedure-bypass entry | `string` | grep for `critical-rules-spec-procedure-bypass` in `000-critical-rules.md` |
| SC-4 | Sub-agent that skips a step without valid justification has its result rejected by orchestrator | `behavioral` | `opencode run` → stderr assertion: sub-agent returns compliance attestation with skipped step → orchestrator rejects and re-tasks |
| SC-5 | Sub-agent that claims "too small" as justification for skipping a step has its result rejected | `behavioral` | `opencode run` → stderr assertion: prohibited rationalization triggers rejection |
| SC-6 | Direct `github_issue_write` call to create a spec body (bypassing procedure) triggers CRITICAL VIOLATION halt | `behavioral` | `opencode run` → stderr assertion: violation detected, pipeline halted |

## Risk and Edge Cases

- Behavioral tests (SC-4, SC-5, SC-6) require `opencode run` infrastructure — if unavailable, SCs are FAIL
- The compliance attestation step adds one step to the procedure — negligible overhead
- Agents may attempt to bypass the attestation by claiming "all steps followed" without actually following them — the orchestrator gate mitigates this by requiring the attestation to list each step

## Implementation Approach

1. Edit `spec-creation-validation/tasks/create.md` to add procedure compliance attestation step
2. Edit `spec-creation/SKILL.md` to add orchestrator post-dispatch compliance gate
3. Edit `000-critical-rules.md` to add critical-rules-spec-procedure-bypass entry
4. Write behavioral enforcement tests for SC-4, SC-5, SC-6

After this spec is approved, invoke `writing-plans` to create `.issues/1969/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
