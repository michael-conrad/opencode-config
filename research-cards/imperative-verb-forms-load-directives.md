---
title: Imperative verb forms for LLM cross-reference load directives
created: 2026-07-15
confidence: 0.85
tags: research, read-link, verb-forms, cross-reference, llm-directives
sources:
  - url: https://ampcode.com/manual#writing-agentsmd-files
    verified: true
    finding: Amp uses @-mention syntax for file references, the only production system with explicit file-to-file cross-references
  - url: https://openai.com/index/introducing-codex/#appendix
    verified: true
    finding: OpenAI Codex uses imperative "MUST" language in AGENTS.md spec
  - url: https://gist.github.com/0xdevalias/f40bc5a6f84c4c5ad862e314894b2fa6
    verified: true
    finding: Comprehensive catalog of LLM guideline file patterns across 12+ frameworks
  - url: https://futureagi.com/blog/llm-prompts-best-practices-2025/
    verified: true
    finding: Instruction-first ordering, constraint pinning, delimiter-locked sections
  - url: https://agent-patterns.readthedocs.io/en/stable/guides/prompt-customization.html
    verified: true
    finding: 9-section structure for agent prompts
  - url: https://paxrel.com/blog-ai-agent-prompts
    verified: true
    finding: 10 patterns for AI agent prompts
  - url: https://arxiv.org/html/2603.08993v1
    verified: true
    finding: Arbiter framework for detecting interference in system prompts
  - url: https://arxiv.org/html/2504.02052v2
    verified: true
    finding: Prompt template analysis
---

# Imperative Verb Forms for LLM Cross-Reference Load Directives

## Key Findings

1. **Dominant pattern is native auto-loading**: Claude Code, Cursor, Copilot, Codex, Gemini CLI all load files into context automatically without agent instruction. OpenCode's `Read [Text](path)` and Amp's `@-mention` are the only two systems where the *agent* is instructed to load a file.

2. **No production system** uses `Read [Text](path)` as a pattern except OpenCode itself. The closest equivalent is Amp's `@-mention`, but that's a tool-native mechanism.

3. **No research on verb effectiveness** — which verbs ("Read", "See", "Consult", "Load", "Fetch") produce the most reliable file-loading behavior in LLMs. This is entirely unexplored.

4. **"See [file]" is documented as defective** — agents treat it as a citation to ignore, not an instruction to read. Confirmed by OpenCode's own guidelines.

5. **Imperative language improves adherence**: OpenAI Codex uses "MUST run all checks", "MUST obey instructions". Anthropic uses "IMPORTANT" and "YOU MUST" emphasis markers.

6. **@-mention (Amp)**: The only production system supporting explicit file-to-file cross-references within agent guidelines. Uses `@doc/style.md` syntax with glob support.

## Candidate Verb Forms to Test

| Verb | Rationale | Source |
|------|----------|--------|
| Read | Current pattern | OpenCode convention |
| Load | Different verb, same semantics | Hypothesis |
| Fetch | Stronger imperative | Hypothesis |
| Consult | Advisory but directive | Hypothesis |
| Open | Tool name collision risk | Hypothesis |
| Retrieve | Formal, imperative | Hypothesis |
| Access | Neutral, directive | Hypothesis |
| Follow instructions in | Multi-word, explicit | Hypothesis |
| Check | Common in prompts | Hypothesis |
| Look up | Common in prompts | Hypothesis |
| See @ | Amp's pattern | Amp docs |
| MUST read | OpenAI Codex style | OpenAI Codex spec |

## Implications

The verb testing spec should test these candidates systematically using the test framework. The winning verb form should be the one that most reliably causes the agent to call the `read` tool (or any available tool) on the referenced file path, without falling back to grep/search or pre-loaded context.
