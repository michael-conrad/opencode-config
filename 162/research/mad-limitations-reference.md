# MAD Limitations Reference — Issue #162

## Sources

1. **Wu et al., "Can LLM Agents Really Debate?"** (arXiv:2511.07784, Nov 2025)
2. **ICLR Blogpost, "Multi-LLM-Agents Debate — Performance, Efficiency, and Scaling Challenges"** (2025)

## Key Findings

### Wu et al. — Controlled Study of MAD in Logical Reasoning

- **Intrinsic reasoning strength and group diversity** are the dominant drivers of debate success
- Structural parameters (order, confidence visibility) offer limited gains
- **Majority pressure suppresses independent correction** — agents conform to the majority even when wrong
- Effective teams overturn incorrect consensus through rational, validity-aligned reasoning
- Process-level analysis: agents that identify mistakes, adopt peer suggestions, and revise answers produce better outcomes

### ICLR Blogpost — MAD Fails to Consistently Outperform Single-Agent

- Current MAD frameworks **fail to consistently outperform simple single-agent test-time computation strategies** (CoT, Self-Consistency)
- No stable scaling law observed — more debate rounds don't reliably improve accuracy
- MAD does not effectively leverage extra test-time computation
- Evaluated 5 MAD frameworks across 9 benchmarks

## Relevance to DiMo-Aligned Architecture

- **Supports DiMo's approach**: role differentiation provides the group diversity that makes debate effective
- **Sequential chain prevents majority pressure**: downstream roles read upstream artifacts independently — no synchronous debate where majority pressure can suppress correction
- **DiMo's structured protocols differ from naive MAD**: DiMo constrains interaction into divergent and logical modes with explicit role personas, which the ICLR blogpost identifies as missing from current MAD frameworks
- **Key risk**: same-model auditors may share blind spots (Calboreanu) — the sequential chain mitigates this by forcing each role to evaluate independently rather than converge
