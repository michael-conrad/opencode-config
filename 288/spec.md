## Problem

The opencode guidelines use ~136 cross-references of the form `See \`FILENAME.md\` §SECTION` or `See \`SKILLNAME\` skill`. These are written as prose citations. The agent treats them as decorative closing sentences rather than as load directives. The agent reads the summary sentence before "see" and treats it as the complete rule, never loading the referenced content where the actual rule lives.

The guidelines are structured correctly for progressive disclosure — lightweight identifiers pointing to content that should be loaded on demand. The agent has the tools to resolve every cross-reference (`read` for guideline files, `skill()` for skills, `grep` for section lookup). The failure is that the cross-references are framed as citations, not as load directives.

## Root Cause

The word "See" is a passive verb. The agent interprets it as a citation, not an instruction. The backtick-wrapped filename is not recognized as a loadable resource. The `§` section reference is not recognized as a navigation target. The agent has no rule anywhere in the system that says cross-references are load directives.

## Fix

Add a mandate to the system prompt (`default.txt`) and project instructions (`.opencode/AGENTS.md`) that explicitly states: when a guideline or skill file says "See `FILENAME.md` §SECTION" or "See `SKILLNAME` skill", this is a load directive, not a citation. The text before "see" is a summary. The complete rule lives at the referenced location. Load the referenced content before acting on the rule.

Also add documentation and linting to catch and prevent citation-style cross-references in future updates.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `default.txt` contains a cross-reference load directive mandate in the Pre-Response Gate section | `string` | grep for load-directive language in default.txt |
| SC-2 | `.opencode/AGENTS.md` contains the same cross-reference load directive mandate | `string` | grep for load-directive language in .opencode/AGENTS.md |
| SC-3 | A guideline file documents the cross-reference format and its meaning as a load directive (not a citation) | `string` | grep for cross-reference format documentation in guidelines |
| SC-4 | A linting rule detects citation-style cross-references (`See \`...\``) in guideline files and flags them as violations | `behavioral` | Run lint on a test file containing citation-style cross-references; verify it flags them |
| SC-5 | The linting rule is integrated into the markdown lint pipeline (`.opencode/AGENTS.md` build/lint/test commands) | `string` | grep for the lint rule in AGENTS.md or lint config |
| SC-6 | Existing citation-style cross-references in guidelines are NOT modified by this spec (band-aid only — holistic fix is separate spec) | `structural` | Verify no guideline files were modified by this change |

## Affected Files

- `/home/muksihs/ollama/.opencode/prompts/default.txt` — system prompt
- `.opencode/AGENTS.md` — project instructions
- `.opencode/guidelines/` — new or updated guideline documenting cross-reference format
- `.opencode/AGENTS.md` — build/lint/test commands (lint rule integration)

## Research Card

`.issues/research-cards/cross-reference-lobotomization.md`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)