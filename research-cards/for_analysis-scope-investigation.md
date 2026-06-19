---
question: Does for_analysis scope block technical investigation (reading, searching, analyzing code)?
confidence: 0.9
tags: [for_analysis, scope, approval-gate, behavioral-test]
source: Behavioral test with local-agent-north-mini-code
date: 2026-06-19
---

## Finding

`for_analysis` scope does NOT block technical investigation.

### Test Protocol

- **Sub-agent**: `local-agent-north-mini-code`
- **Prompt**: `Analyze this project then report then halt` (no authorization keywords, no leading context)
- **Scope**: Default `for_analysis` (no "approved" or "go" in prompt)
- **Environment**: `opencode-config` repo with `.opencode/` submodule on `dev` branch

### Results

The sub-agent successfully:
1. Read directory structure (`ls`, glob, or equivalent)
2. Identified the repo as a test harness for `.opencode/`
3. Discovered the `.opencode/` submodule as the real application source
4. Analyzed `.opencode/` content (skills, guidelines, tools)
5. Produced structured report with key insights
6. Did NOT request authorization
7. Did NOT refuse or block

### Conclusion

The bug report's claim is incorrect at the behavioral level. A `for_analysis`-scoped agent can read, search, analyze, and report on the codebase without requesting `for_implementation` scope. The guideline text and enforcement behavior are consistent.

The issue may be about a different enforcement layer or a different repo context (originally filed against `snea-shoebox-editor`).
