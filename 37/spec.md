## STATUS: 1.0 (DRAFT — NEEDS APPROVAL)

### Purpose

Investigate whether Unix shell pipeline composition (`&&`/`||`/`|`) — composing a sequence of sub-agent dispatches with error-semantic connectors and dispatching the composed sequence as a single clean-room agent — is a viable alternative to the current sequential orchestrator-dispatch model. Produce an exploratory essay comparing this model against four other classic orchestration approaches, and a formal spec derived from the essay's findings.

### Background

The existing paper **"Do One Thing Well: Unix Philosophy for AI Agent Skill Deck Architecture"** (`docs/unix-philosophy-skilldeck/unix-philosophy-skilldeck.tex`) analyzes the opencode-config skill deck against Unix design principles. Section 7 ("The Unix Pipeline Model for Sub-Agents") proposes contract-based pipeline assembly — stages declare input/output contracts, and a composable assembler selects stages whose contracts are compatible. This replaces the current hardcoded dispatch chain.

However, Section 7 does **not** explore the specific pattern where:

1. The orchestrator composes a sequence of sub-agent dispatches with `&&`/`||` semantics into a structured pipeline definition
2. The orchestrator dispatches that composed pipeline as a **single** clean-room sub-agent
3. The pipeline executor agent processes the composed sequence internally — executing each stage, routing based on `&&` (proceed on success) and `||` (fallback on failure)
4. The pipeline executor agent may itself dispatch its own sub-sub-agents for individual stages (recursive nesting)

This pattern is the Unix analog of: `find . -name '*.rs' | xargs grep 'TODO' | sort | uniq -c || echo 'No TODOs found'`

Piskala (arXiv:2601.11672) argues that "file- and code-centric interaction models → maintainable, auditable agent systems." The question is whether applying this composition model to sub-agent dispatch produces the same maintainability gains, or whether consolidating stages into a single context window defeats the isolation that clean-room dispatch was designed to enforce.

### Scope

**Covers:**
- Analysis of five orchestration models (sequential dispatch, fan-out parallel, DAG dispatch, Unix pipeline composition, recursive pipeline nesting)
- &&/|| semantics for agent-level error handling and fallback
- Contract passing between stages within the pipeline executor vs. through the parent orchestrator
- Recursion boundary: where pipeline nesting produces value vs. creates context-bloat recursion
- Experimental design for measuring outcomes

**Does NOT cover:**
- Implementation of any changes to the dispatch chain
- Changes to guideline files, skill files, or plugin code
- Contract-based pipeline assembly implementation (that is the paper's Section 7 scope)
- Sub-agent role taxonomy (Gap 8 — separate concern)

### Success Criteria

| SC# | Criterion | Verification Method |
|-----|-----------|---------------------|
| SC-1 | Exploratory essay exists at `docs/unix-philosophy-skilldeck/investigations/shell-composition-orchestration.md` | File existence check |
| SC-2 | Essay analyzes all five orchestration models with comparison tables | Content verification — five named models present in comparison table |
| SC-3 | Essay addresses all five investigative questions (coherence vs. isolation, `\|\|` semantics, executor-orchestrator role, contract passing, recursion boundary) | Content verification — each question has a dedicated section |
| SC-4 | Essay references the existing paper's Section 7, Piskala (arXiv:2601.11672), and at least two other academic sources from research-survey.md | Content verification — bibliography or inline citations |
| SC-5 | Formal spec exists at `docs/unix-philosophy-skilldeck/investigations/shell-composition-spec.md` | File existence check |
| SC-6 | Formal spec derives concrete findings from the essay — not an independent re-analysis | Content verification — spec's Background section links to essay |
| SC-7 | Experiment designs are registered in `docs/unix-philosophy-skilldeck/experiments/experiment-log.md` | Content verification — at least one experiment entry per model compared |
| SC-8 | Both documents cite AI byline: `Co-authored with AI: OpenCode (deepseek-v4-pro)` | Content verification |

### Deliverables

| Item | Path | Format |
|------|------|--------|
| Exploratory essay | `docs/unix-philosophy-skilldeck/investigations/shell-composition-orchestration.md` | Markdown, ~3,000–5,000 words |
| Formal spec | `docs/unix-philosophy-skilldeck/investigations/shell-composition-spec.md` | Markdown, ~1,000–2,000 words |
| Experiment entries | `docs/unix-philosophy-skilldeck/experiments/experiment-log.md` (appended) | Per existing template format |
| Investigation directory | `docs/unix-philosophy-skilldeck/investigations/` | New directory |

### Five Orchestration Models to Compare

| Model | Description | Key Metric |
|-------|-------------|------------|
| **Sequential dispatch** | Orchestrator dispatches one sub-agent, collects result contract, routes to next stage (current baseline) | Latency, orchestrator context overhead |
| **Fan-out parallel** | All independent sub-agents dispatched simultaneously; results merged post-hoc | Throughput vs. orchestration control |
| **DAG-based dispatch** | Dependency graph with fan-out/fan-in at dependency boundaries; contract compatibility as connection gate (GraSP-aligned) | Correctness, contract enforcement |
| **Unix pipeline composition** | Orchestrator composes a sequence with `&&`/`\|\|` semantics, dispatches as ONE clean-room sub-agent; that agent executes the composed stages internally | Context consolidation vs. isolation |
| **Recursive pipeline nesting** | Pipeline agents can compose sub-pipelines of sub-sub-agents (recursive dispatch) | Coherence depth vs. context-bloat recursion |

### Key Investigative Questions

1. **Coherence vs. Isolation:** Does consolidating stages into one context window improve coherence (the executor sees the full pipeline) or defeat isolation (the executor's context is polluted with all stages' data)?

2. **`||` Semantics:** What does `||` mean for an agent pipeline? On verification failure, does the executor re-dispatch the implementer internally? Escalate to the parent orchestrator? HALT and return `DONE_WITH_CONCERNS`?

3. **Executor Role:** Is the pipeline executor agent also a pure orchestrator (never loads implementation context, only routes), or does it carry implementation capability (can write code itself for simple stages)? This determines whether the executor is a "shell" or a "program."

4. **Contract Passing:** Within the pipeline executor, do contracts flow directly (agent-internal, no serialization) or through the parent orchestrator (cross-context, serialized to markdown)? Direct flow preserves context; cross-context flow preserves audit trail.

5. **Recursion Boundary:** Where does nesting produce value (spec exploration → plan generation → implementation compose naturally) and where does it create context-bloat recursion that mirrors the current guideline-bloat problem (implementation → sub-implementation → sub-sub-implementation ad infinitum)?

### PR Merge Boundaries

None. This is a standalone investigation with no implementation dependencies. No other spec or PR must merge before this investigation proceeds.

### Fix Approach

N/A. This spec covers investigation only — no code changes, no guideline/skill modifications, no implementation.

### Related Issues

| Issue | Repo | Relevance |
|-------|------|-----------|
| #248 | michael-conrad/.opencode | Gate Dependency Tree — the prescriptive enforcement pipeline this model would integrate with |
| #179 | michael-conrad/.opencode | Prose over static templates — tension between structural routing and agent-driven discovery |
| #80 | michael-conrad/.opencode | Agent-driven graph discovery — complementary model for open-ended traversal |

### Related Paper Sections

| Section | Content |
|---------|---------|
| §5 (The Unix Philosophy Framework) | Maps Unix principles to agent architecture; identifies "NO DAG composition model" as a gap |
| §7 (The Unix Pipeline Model for Sub-Agents) | Proposes contract-based pipeline assembly; GraSP validation |
| §8 (Recommendations) | Shift 5: "Pipeline assembly from contracts, not hardcoded sequence" |
| Piskala (arXiv:2601.11672) | "From Everything-is-a-File to Files-Are-All-You-Need" — foundational reference for Unix-to-agentic-AI mapping |

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)