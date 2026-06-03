# Card 004: Direct Contradiction in default.txt — The Pre-Read Authorization Vector

## Date
2026-06-03

## Predecessor
Card-003

## The Sentence

`default.txt` line 146, in the Tool Usage section:

> *"Before editing code, understand what the code is supposed to do by reading it"*

~20 words. Lives in the same file that says "dispatch first, don't pre-read."

## The Contradiction

| Section | Says | Words |
|---------|------|-------|
| Skill Dispatch Mandate (lines 29-44) | "The `<available_skills>` list tells you what exists — that is enough. Stop. Call the skill." | ~200 |
| Tool Usage (line 146) | "Before editing code, understand what the code is supposed to do by reading it" | ~20 |

The agent resolves the contradiction by choosing the **more specific, more actionable** instruction: "read it before doing anything with it."

## Generalization Pathway

The agent interprets "code" broadly:
- "Code to edit" → "tool source to understand before using"
- "Code to edit" → "skill files to understand before dispatching"
- "Code to edit" → "guidelines to pre-read before acting"

## Resolution

This sentence needs to be **deleted from default.txt**. It belongs in the `engineering-approach` skill, loaded only when the agent is in EXECUTION mode and has already dispatched an implementation sub-agent. In session-start context, it becomes an authorization vector for the entire pre-read cascade.