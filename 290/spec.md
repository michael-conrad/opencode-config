## Problem

The opencode guidelines use ~136 cross-references of the form `See `FILENAME.md` §SECTION` or `See `SKILLNAME` skill`. These are written as prose citations. The agent treats them as decorative closing sentences rather than as load directives. The agent reads the summary sentence before "see" and treats it as the complete rule, never loading the referenced content where the actual rule lives.

## Goals

- Add a mandate to the system prompt and project instructions that cross-references are load directives
- Document the cross-reference format as a load directive in a guideline
- Add linting to detect citation-style cross-references
- Integrate linting into the markdown lint pipeline
- Preserve existing cross-references (band-aid only)

## Non-Goals

- Modifying existing citation-style cross-references
- Changing the cross-reference format itself

## Scope

- System prompt (`.opencode/prompts/default.txt`) mandate addition
- Project instructions (`.opencode/AGENTS.md`) mandate addition
- New or updated guideline documenting cross-reference load directive
- Linting rule for citation-style cross-references
- Markdown lint pipeline integration

## Approach

Add a band-aid mandate to the system prompt and project instructions that explicitly states cross-references are load directives. Add documentation and linting to prevent future citation-style cross-references. Do not modify existing cross-references.

## Impact

- Risk: Agent may still ignore cross-references if mandate is not strong enough. Mitigation: behavioral enforcement test.
- Risk: Linting rule may produce false positives. Mitigation: careful regex design.

## Research Card

`.issues/research-cards/cross-reference-lobotomization.md`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)