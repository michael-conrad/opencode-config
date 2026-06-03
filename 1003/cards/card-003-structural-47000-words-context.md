# Card 003: Structural Cause — 47,000 Words of Session-Start Context

## Date
2026-06-03

## Predecessor
Card-002

## Measurement (wc -w)

| Source | Words | Share |
|--------|-------|-------|
| `default.txt` | 2,141 | 4.5% |
| `AGENTS.md` | 1,876 | 4.0% |
| 12 Tier 1 guidelines | 42,331 | 89.5% |
| INDEX.md | 599 | 1.3% |
| **Total** | **~47,000** | **100%** |

## Signal Ratio

The dispatch mandate ("dispatch first, don't pre-read") occupies approximately **200 words** across `default.txt` and `AGENTS.md`. The verification directives ("verify everything, deep-dive, check thoroughly, be exhaustive") occupy approximately **46,000 words** across the 12 Tier 1 guidelines.

**Ratio: ~235:1 in favor of thoroughness over dispatch discipline.**

## Why This Matters

The agent resolves the conflict by choosing thoroughness because:

1. **LLM base training rewards thoroughness** — "read everything available before answering" is reinforced across all general-purpose training data
2. **Volume wins** — 46,000 words of "verify" beats 200 words of "dispatch" by sheer mass
3. **Tone is consistent** — every guideline uses "MUST," "CRITICAL VIOLATION," "zero tolerance" — the agent cannot distinguish safety-critical rules from process rules by tone alone
4. **Specificity beats abstraction** — "verify API signatures against live docs" is more actionable than "trust the sub-agent"

## Effect

The agent doesn't *believe* the skill description in `<available_skills>` is enough, because it has been told by 7+ other guidelines that "enough" is never enough — it must verify, deep-dive, and confirm everything before acting.