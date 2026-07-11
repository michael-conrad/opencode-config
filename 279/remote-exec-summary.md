> **Full spec and artifacts: [`.issues/279/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/279)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/279/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

Rewrite all 43 SKILL.md `description` frontmatter fields from user-trigger-phrase-oriented prose to agent-intent-oriented prose. The current pattern ("Use when... Trigger phrases:") is written for a keyword matcher that doesn't exist in the runtime. The opencode runtime only recognizes `name`, `description`, and `slash` in frontmatter — the `description` is rendered verbatim into the `<available_skills>` XML block for the LLM to read and decide whether to call `skill()`. The new pattern leads with what the agent is doing when it should dispatch, with user trigger phrases as supplementary info.

### Cards (dependency order)
1. **Spec and pattern definition** — Define the new description pattern, update reference docs and templates
2. **Validation script update** — Update `validate_skill_cards.py` and `session-enforcement.ts` to accept the new pattern
3. **Rewrite all 43 SKILL.md files** — Apply the new pattern to every skill card
4. **Behavioral enforcement tests** — Write tests verifying the new pattern is enforced

### Key Decisions
- **Agent-intent-first**: Description leads with "what the agent is doing" not "what the user said"
- **User phrases retained**: Trigger phrases kept as supplementary info appended after agent-facing content
- **No new frontmatter fields**: Works within existing `description` field only
- **Backward compatibility**: `session-enforcement.ts` validation updated to accept both old and new patterns during transition

### Risk Callouts
- **Validation breakage**: Changing the "Use when" prefix requirement will cause all 43 skills to fail validation until rewritten — must update validator first or in lockstep
- **LLM routing regression**: The new pattern must be tested to confirm the LLM still correctly dispatches skills with agent-intent descriptions
