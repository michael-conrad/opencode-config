---
title: Microsoft markdown link patterns in LLM agent guidelines
created: 2026-07-15
confidence: 0.8
tags: research, read-link, microsoft, markdown, cross-reference
sources:
  - url: https://code.visualstudio.com/docs/agent-customization/prompt-files
    verified: true
    finding: VS Code prompt files use markdown links as passive references, not load directives
  - url: https://code.visualstudio.com/docs/agent-customization/custom-agents
    verified: true
    finding: Custom agents can reference other files via markdown links
  - url: https://visualstudiomagazine.com/articles/2026/02/24/in-agentic-ai-its-all-about-the-markdown.aspx
    verified: true
    finding: Markdown as "version-controlled instruction layer" for AI agents
---

# Microsoft Markdown Link Patterns in LLM Agent Guidelines

## Key Findings

1. **VS Code prompt files** use markdown links as passive references (`[Text](path)`), NOT as active load directives. The documentation says "you can reference other workspace files" — not "you MUST read this file."

2. **No Microsoft source** uses `Read [Text](path)` as an explicit load directive. The pattern appears to be an opencode convention, not one originating from Microsoft.

3. **Markdown as instruction layer**: Microsoft and GitHub now use markdown files (`.github/copilot-instructions.md`, `*.prompt.md`, `SKILL.md`) to persist AI rules, but cross-referencing between files is done via native tool mechanisms, not agent-invoked reading.

4. **Gap**: No Microsoft research papers study markdown link effectiveness in LLM prompts. No documented mechanism forces the LLM to read the referenced file.

## Implications

The `Read [Text](path)` pattern is NOT cargo-culted from Microsoft. It's an independent convention. Microsoft's documented pattern is passive reference, not active load directive. This means we are free to change the pattern without worrying about diverging from Microsoft's approach.
