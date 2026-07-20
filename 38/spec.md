# [RESEARCH] Read-Only Orchestrator Paradigm: Structural Isolation of AI Agent Execution from File Modification

**Status:** DRAFT
**Primary Reference:** BMad Builder — Subagent Orchestration Patterns; Inngest — Three Sub-Agent Patterns; Augment Code — Multi-Agent Cost Compounding

## Problem

Multi-agent AI orchestration systems enforce sub-agent dispatch for file modifications through procedural guidelines — rules that an agent must read and follow. But procedural enforcement has a fundamental weakness: the orchestrator agent retains the *capability* to write files directly, even when guidelines prohibit it. This gap — capability without structural enforcement — produces a recurring failure pattern:

1. **Guideline bypass**: An agent under context pressure (orchestrator context cost, perceived urgency) writes files directly instead of dispatching a sub-agent
2. **Invisible contamination**: Direct file writes by the orchestrator bypass clean-room isolation, contaminating the output with the orchestrator's reasoning bias
3. **No detection until audit**: Procedural violations are only caught at audit time, not prevented at execution time
4. **Enforcement asymmetry**: Guidelines apply to the *agent's decision-making*, but the *system* provides no independent enforcement layer

The existing procedural approach (DISPATCH_GATE checkpoints, clean-room task() mandates, critical-rules-034 for inline work) is documented in the opencode-config repository's `.opencode/` submodule. These rules work for compliant agents but provide no structural defense against non-compliant behavior.

**This is distinct from mere "sandboxing" or "restricted mode."** The research question is whether the *orchestrator itself* can be structurally prevented from writing files, shifting enforcement from procedural (guideline-followed) to architectural (system-enforced).

## Proposed Solution

A LaTeX paper formalizing the **Read-Only Orchestrator Paradigm** — an architectural pattern where the main orchestration agent operates in a read-only mode by default, with all file modifications routed through sub-agent dispatch as a structural invariant rather than a procedural recommendation.

### Two Implementation Layers

**Layer 1 — System-Level Enforcement (Tool Proxy):**
- The orchestrator's write/edit/create tools are proxied through a gate that requires explicit authorization for each modification
- File operations are queued and routed to a dedicated execution sub-agent
- The orchestrator can read, analyze, plan, and dispatch — but cannot write

**Layer 2 — Plugin-Level Enforcement (Session Enforcement):**
- Session-enforcement plugin detects orchestrator inline writes and blocks them
- Worktree isolation is augmented with write-proxy enforcement
- The orchestrator's capability map is pruned at the tool registration level

### Relationship to Existing Work

| Existing Pattern | Relationship | Gap |
|--|--|--|
| DISPATCH_GATE (opencode-config) | Procedural; agent can bypass | Read-only paradigm provides structural enforcement |
| BMad "Parent reads first" anti-pattern | Context contamination detected after the fact | Read-only prevents contamination at the tool level |
| Inngest 90%+ compression via sub-agents | Economic motivation for sub-agent dispatch | Read-only provides architectural motivation |
| Clean-room task() isolation | Applies at dispatch time; orchestrator context not restricted | Read-only prevents orchestrator from holding write-state |

### Two-Role Context Cost Model Integration

The read-only paradigm naturally enforces the Two-Role Context Cost Model:

| Role | Current (Procedural) | Read-Only (Structural) |
|--|--|--|
| **Orchestrator** | Can read, write, analyze, dispatch | Can only read, analyze, dispatch — write requires sub-agent |
| **Sub-agent** | Must be intentionally dispatched for file ops | Is the *only* path for file ops — dispatch becomes mandatory |
| **Clean-room** | Violated when orchestrator writes directly | Structurally enforced — orchestrator cannot write |

## Key Contributions

1. **Formal definition of Read-Only Orchestrator Paradigm** — shifting enforcement from procedural (guidelines) to architectural (system)
2. **Tool proxy architecture** — design for a write-gate that routes all modifications through sub-agents without breaking existing workflows (direct-branch, worktree, pair-mode)
3. **Plugin-based enforcement** — session-enforcement level write-blocking that operates independently of the model's compliance
4. **Impact analysis** — assessment of the paradigm on orchestrator context cost, pipeline throughput, workflow compatibility, and sub-agent dispatch patterns
5. **Empirical comparison** — procedural vs. structural enforcement: detection latency, bypass rate, context contamination rate

## Paper Structure (Draft)

1. Introduction
2. Related Work
   2.1 Orchestrator-Sub-Agent Architectures (LangChain, OpenAI SDK, BMad, Inngest)
   2.2 Procedural Enforcement Limits (guideline bypass, context pressure)
   2.3 Capability Pruning (tool-gating, permission systems, sandboxing)
3. The Problem: Procedural Enforcement Gap
   3.1 Failure Patterns (guideline bypass, invisible contamination)
   3.2 Detection Latency (caught at audit, not at execution)
   3.3 Capability Asymmetry (retained capability vs. enforced behavior)
4. Read-Only Orchestrator Paradigm
   4.1 Formal Definition
   4.2 Tool Proxy Architecture
   4.3 Plugin-Level Enforcement
   4.4 Workflow Compatibility
5. Two-Role Context Cost Model Integration
   5.1 Structural Enforcement of Context Discipline
   5.2 Orchestrator Cost Analysis
   5.3 Sub-Agent Dispatch Overhead
6. Comparison with Procedural Enforcement
   6.1 Bypass Rate Analysis
   6.2 Detection Latency
   6.3 Context Contamination Rate
7. Limitations and Future Work
   7.1 Workflow-Specific Carve-Outs
   7.2 Model-Escalation Risk
   7.3 Capability Negotiation (emergency write access)
8. Conclusion

## Target

A LaTeX paper suitable for submission to:
- ICSE (Software Engineering in Practice)
- NeurIPS (Systems Track)
- ArXiv as a position paper

## Status

BRAINSTORM — research phase not yet started. The existing opencode-config `.opencode/` implementation provides the empirical foundation (DISPATCH_GATE rules, clean-room task() enforcement, inline work violations). Research needed on tool-proxy architectures, plugin-enforcement mechanisms, and capability-pruning patterns in existing frameworks.

## Related

- https://github.com/michael-conrad/.opencode/issues/106 — Universal Clean-Room Sub-Agent Dispatch (procedural counterpart)
- https://github.com/michael-conrad/opencode-config/issues/149 — Two-Role Context Cost Model (complementary cost model)
- BMad Builder Subagent Orchestration Patterns — https://bmad-builder-docs.bmad-method.org/explanation/subagent-patterns/
- Inngest Three Sub-Agent Patterns — https://www.inngest.com/blog/three-patterns-you-need-for-agentic-systems

---

## Workflow Compatibility Note

This paper's workflow compatibility analysis (Section 4.4) describes three workflow modes:

1. **Direct-branch (default)**: Feature branch created from `main` (the trunk), working in the main repository directory. This is the primary workflow under trunk-based development.
2. **Worktree (opt-in)**: Isolated git worktree for parallel work. Branch-agnostic.
3. **Pair-mode**: Dev-pair collaboration on `pair-*` branches. Branch-agnostic.

The tool proxy architecture and plugin-level enforcement are independent of the branch model — they apply equally to all three workflow modes.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)