## Problem

The evaluation of LLM-based agents — systems that autonomously reason, plan, call tools, and adapt across multi-turn interactions — remains a fragmented and underdeveloped field. Existing evaluation approaches conflate model output generation with model output evaluation in a single pass, using the same model (or same agent class) to both produce and judge results. This creates a blind spot: a false PASS is undetectable when the evaluator shares the same failure modes as the producer.

Additionally, the field lacks:

1. A clean separation of concerns between test harness (generation) and test evaluation (verdict)
2. A formal cost model for orchestrator context that explains WHY sub-agent dispatch is economically necessary
3. A cross-validated auditor architecture where multiple independent models inspect the same artifacts
4. A canonical definition of evidence types (behavioral > semantic > string > structural) with hard gates between them

## Proposed Solution

A LaTeX paper formalizing the **Artifact-Only Generator Paradigm** for LLM agent behavioral testing. The paper will define, analyze, and benchmark the architecture implemented in the opencode-config repository, which separates model evaluation into two distinct phases:

**Phase 1 — Artifact Generation (Test Harness):**
- A test script sends a prompt to a real LLM agent
- Collects all output (stdout, stderr, tool traces, session state) into a structured artifact directory
- Exits 0 unconditionally (exit code signals "artifacts produced", not "test passed")

**Phase 2 — Clean-Room Semantic Inspection (Evaluation):**
- A different model, with no context preloading and no cached results, reads the artifacts cold
- Renders PASS/FAIL per success criterion with evidence
- Cross-validation via adversarial auditor consensus (two different model families must agree)

## Key Contributions

1. **Formal definition of the Artifact-Only Generator Paradigm** — separating generation from evaluation as an architectural pattern for LLM agent behavioral testing
2. **Evidence Type Taxonomy** — behavioral, semantic, string, structural with DDL cost model proving WHY behavioral testing is the cheapest, not the most expensive, approach
3. **Two-Role Context Cost Model** — `orchestrator_cost = size × remaining_dispatches²` vs `sub_agent_cost = size × 1`
4. **Cross-Validated Auditor Architecture** — adversarial consensus between different model families as a quality gate
5. **Empirical validation** — 200+ behavioral test scenarios across multiple model families
6. **Comparison with industry practice** — Anthropic, DeepEval, LangSmith, Microsoft Agent-Pex

## Research Already Conducted

Exhaustive research has been conducted covering:
- Anthropic's "Demystifying Evals for AI Agents" (Jan 2026)
- KDD 2025 survey on LLM Agent Evaluation
- Confident AI / DeepEval agent evaluation framework
- Industry practice from LangSmith, LangFuse, OpenLayer, Microsoft
- The opencode-config implementation (202+ behavioral test scripts, 400+ content-verification scenarios)

Full research index cards and analysis will be maintained locally under this issue's directory.

## Paper Structure (Draft)

1. Introduction
2. Related Work (LLM evaluation, agent evaluation, traditional software testing)
3. The Artifact-Only Generator Paradigm
   3.1 Phase 1: Harness Generation
   3.2 Phase 2: Clean-Room Semantic Inspection
   3.3 Phase 3: Adversarial Cross-Validation
4. Evidence Type Taxonomy and Cost Model
   4.1 The DDL Cost Model
   4.2 Evidence Hierarchy and Gates
5. Two-Role Context Cost Model
6. Implementation: the opencode-config Behavioral Test System
   6.1 Harness Architecture
   6.2 Artifact Schema
   6.3 Clean-Room Evaluation Pipeline
7. Empirical Evaluation
   7.1 Test Suite Composition
   7.2 Cross-Validator Agreement Rates
   7.3 False Positive/Negative Analysis
8. Comparison with Existing Approaches
9. Limitations and Future Work
10. Conclusion

## Target

A LaTeX paper suitable for submission to venues such as:
- NeurIPS (Datasets and Benchmarks Track)
- ICML
- ACL (System Demonstrations Track)
- ICLR

## Status

DRAFT — research phase complete, paper structure proposed, index card research archive being compiled.
