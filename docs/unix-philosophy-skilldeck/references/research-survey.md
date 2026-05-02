# Research Survey — AI Agent Skill Deck Architectures

## Sources Consulted

### Academic Papers
| Paper | Authors | Date | Venue | Key Finding |
|-------|---------|------|-------|-------------|
| SoK: Agentic Skills | Jiang et al. | Feb 2026 | arXiv:2602.20867 | 7 design patterns; self-generated skills degrade; 1,200 malicious skills found |
| Agent Skills for LLMs | Xu & Yan | Feb 2026 | arXiv:2602.12430 | 26.1% of community skills have vulns; 4-tier permission model |
| GraSP | Xia et al. | Apr 2026 | arXiv:2604.17870 | More skills ≠ better; DAG orchestration +19 reward, -41% steps |
| AgentSkillOS | Li et al. | Mar 2026 | arXiv:2603.02176 | Tree-based retrieval ≈ oracle at 200K skills |
| SkillCraft | Chen et al. | Feb 2026 | arXiv:2603.00718 | Token usage -80% via skill caching |
| SKILL0 | Lu et al. | Apr 2026 | arXiv:2604.02268 | Skill internalization > runtime retrieval; +9.7% ALFWorld |
| Atomic Skills | Ma et al. | Apr 2026 | arXiv:2604.05013 | 5 atomic basis skills; joint RL +18.7% |
| PolySkill | Yu et al. | Oct 2025 | arXiv:2510.15863 | Goal/impl decoupling; 1.7x reuse; over-specialization is failure mode |
| CAID | Geng & Neubig | Mar 2026 | arXiv:2603.21489 | Structured pipeline +26.7% improvement |
| Debug2Fix | Garg & Huang | Feb 2026 | arXiv:2602.18571 | Architecture beats model capability |
| More Agents | Li et al. | Feb 2024 | arXiv:2402.05120 | Ensemble voting improves reliability |
| NL2Repo-Bench | Ding et al. | Dec 2025 | arXiv:2512.12730 | Long-horizon failure: premature termination, coherence loss |
| Bug Triggers | — | Apr 2026 | arXiv:2604.08906 | 409 bugs analyzed; orchestration layer unique faults |
| NeuroClaw | — | Apr 2026 | arXiv:2604.24696 | 3-tier hierarchy; checkpointing + post-exec verification |
| Small Orchestrator | — | Apr 2026 | arXiv:2604.17009 | Lightweight orchestrator; decouples planning/execution |

### Industry Essays
| Source | Date | Key Point |
|--------|------|-----------|
| Anthropic "Building Effective Agents" | Dec 2024 | Workflows (predefined paths) outperform agents for well-defined tasks; gates on intermediate steps essential |
| Anthropic "Effective Context Engineering" | 2025 | Challenge is curating context, not crafting prompts; compaction + structured notes + sub-agents |
| Anthropic "Agent Skills Best Practices" | Oct 2025 | Progressive disclosure; escalation language accumulates model-specific assumptions |
| LangGraph Launch | Jan 2024 | State machines > conversations; three multi-agent architectures all use fixed routing |
| Cursor "Scaling Agents" | Apr 2026 | Recursive planner-worker hierarchy; removed integrator role (became bottleneck) |
| Lillian Weng "LLM Powered Agents" | Jun 2023 | Foundational survey; 3 core agent challenges (context, planning, NL unreliability) |
| Agent Skills Specification | 2025–26 | Open standard; 30+ adopters; 17.6K GitHub stars |

### Production Agent Systems Surveyed
Claude Code, OpenAI Codex/Agents SDK, GitHub Copilot, Cursor, Windsurf Cascade, CrewAI, AutoGen, Aider, Sweep AI, Goose AI, MetaGPT, ChatDev, Devin, OpenHands, SWE-Agent, Amazon Q Developer, JetBrains Junie, Tabnine, GPT-Engineer, Cline, CodeGate, Cover-Agent

## Key Patterns Found Nowhere Else

1. **Pure Orchestrator** — main agent never implements; enforced as Tier 1 critical violation
2. **Pipeline-Scoped Authorization** — "approved #N to PR" carries scope horizon; hard HALT at boundary
3. **Tiered Mandates** — rules classified by override eligibility (Tier 1 never yields, Tier 2 waivable)
4. **Tool-Call Evidence Requirement** — every verification claim must reference a tool-call artifact
5. **Plan-Bridge Hierarchy** — Spec → Plan → Sub-issues with phase-count cross-reference verification

## Documented Failure Modes Addressed

1. Context pollution → Pure orchestrator never loads implementation context
2. Skill overload → Trigger-based routing, progressive disclosure
3. Self-verification unreliability → Clean-room dispatch (verifier ≠ producer)
4. Guardrail bypass → Tier 1 mandates as structural invariants, not text advisories
5. Premature completion → Structural completeness gate with per-SC evidence
6. Confirmation-as-authorization → Explicit tiered authorization model
7. Skill interference → Trigger-based routing; only one skill active
8. Approval fatigue → Pipeline-scoped authorization (approve once, not per-action)
9. Over-specialization → Atomic skill composition (basis skills → composites)
10. Overtriggering subagents → DISPATCH_GATE enforces deliberate dispatch
11. Long-horizon coherence → Work state file carries context across stages

## Research Gaps (Open Problems)

| Gap | Source | Status |
|-----|--------|--------|
| Skill internalization (training-time withdrawal) | SKILL0 | Open — no production system implements |
| Capability-based cross-model compilation | SkVM | Open — skills behave differently across LLMs |
| Polymorphic abstraction (goal/implementation separation) | PolySkill | Open — over-specialization unsolved |
| Power-law skill composition (structural information theory) | STEPS | Open — flat representation hides natural hierarchies |
