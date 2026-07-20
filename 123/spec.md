# [SPEC] Phase 1: Bright-Line Mandate — default.txt + Dark Prose Reference Card

- **Issue Number:** 805
- **Status:** DRAFT
- **Branch Pattern:** `feature/805-bright-line-foundation`
- **Authorization Scope:** `for_pr`
- **PR Strategy:** stacked

## Problem

The agent systematically shortcuts verification, substitutes structural evidence for behavioral evidence, inline-executes work instead of dispatching sub-agents, and rationalizes every shortcut as "good enough." This is a known LLM agent failure mode called **cost-optimization bias** (see MAST failure taxonomy: 21.3% of multi-agent failures are verification-related).

The root cause is that the agent has no **bright-line rules** — absolute gates that eliminate the rationalization surface. All existing instructions are expressed as preferences ("prefer," "try to," "use where possible") which the agent can reason around.

Two foundational changes are needed:

1. **`default.txt`** — a universal backstop that is always in context, cannot be skipped by skill-matching failure, and codifies bright-line rules + forbidden rationalizations + cost model override
2. **`250-dark-prose-reference.md`** — the canonical definition of bright-line rules as a rhetorical technique for agent instruction compliance, alongside the existing five patterns

## Scope

- `opencode.jsonc` instructions array — add `default.txt` as the final (last-resort) entry
- `default.txt` content — bright-line mandate body
- `250-dark-prose-reference.md` — add bright-line rules as pattern 007

## Success Criteria

### SC-1: default.txt exists

| | |
|---|---|
| **Evidence Type** | structural |
| **Verification** | `ls opencode.jsonc` + grep for `default.txt` reference |
| **Rationale** | File existence confirms the backstop was installed |

### SC-2: default.txt contains forbidden rationalizations section

| | |
|---|---|
| **Evidence Type** | string |
| **Verification** | grep for explicit list of forbidden thoughts |
| **Rationale** | The agent must have explicit awareness that these thoughts are incorrect |

Forbidden rationalizations to list:
- "This is too small for a skill"
- "I can just quickly implement this"
- "I'll gather context first"
- "A grep check is good enough for this SC"
- "This behavioral test doesn't need to run against a real model"
- "Running the sub-agent costs too many tokens, I can do this inline"
- "The user said continue so the gates don't apply"
- "This is just a documentation change, it doesn't need verification"
- "I've already verified this earlier, no need to re-verify"

### SC-3: default.txt contains bright-line evidence hierarchy

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep for evidence hierarchy with behavioral > semantic > string > structural ordering; sub-agent read confirms correct priority |

### SC-4: default.txt contains cost model override

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep for statement declaring that rework cost >> execution cost, and that the correct path is the expensive one that works the first time |

### SC-5: default.txt contains "Rework cost recognition" statement

| | |
|---|---|
| **Evidence Type** | string |
| **Verification** | grep for explicit acknowledgement that trying to be cheap creates endless repeated work that never completes |

### SC-6: default.txt is last entry in instructions array

| | |
|---|---|
| **Evidence Type** | structural + semantic |
| **Verification** | `opencode.jsonc` parsing confirms `default.txt` is the final instructions entry; last-resort positioning confirmed |

### SC-7: 250-dark-prose-reference.md contains bright-line rules section

| | |
|---|---|
| **Evidence Type** | string |
| **Verification** | grep for "Bright-Line" or "bright-line" in `250-dark-prose-reference.md` |

### SC-8: Bright-line section defines three-part structure

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep for all three components (absolute rule, exception carve-out, failure definition); sub-agent read confirms each is documented with examples |

### SC-9: Bright-line section lists all five existing dark prose patterns and documents the complementary pairings

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep for each pattern number (001-006) in the bright-line section showing which get bright-line companions (001, 002, 003, 006) |

### SC-10: Paired 001 confirmshaming has bright-line companion

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Sub-agent reads the bright-line section and confirms the confirmshaming entry includes a companion rule that uses absolute language with a "non-waivable" or "hard gate" designation |

### SC-11: Paired 002 identity-frame has bright-line companion

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Sub-agent reads and confirms identity-frame entry has a companion using binary compliance language ("is" / "is not" / "period") |

### SC-12: Paired 003 consequence-assertion has bright-line companion

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Sub-agent reads and confirms consequence-assertion entry has a companion using rejection-termination language ("REJECTED," "must be remediated") |

### SC-13: Paired 006 agency-respecting has "trust but verify" companion

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Sub-agent reads and confirms agency-respecting entry has a "trust but verify" companion — autonomy is granted AND independent verification is mandatory |

### SC-14: The pairing relationship is documented as complementary, not replacement

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Sub-agent reads and confirms the documentation states that bright-line companions REINFORCE the dark prose pattern, not replace it |

### SC-15: Behavioral test — agent with authorization prompt references a bright-line rule from default.txt

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with approved-issue prompt; stderr/agent output contains reference to one of the forbidden rationalizations or the evidence hierarchy |
| **Min evidence** | 2 references to bright-line content in agent reasoning or tool-call decisions |

### SC-16: Behavioral test — agent declines to substitute structural evidence for behavioral SC

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with prompt asking agent to verify a behavioral SC using only grep; agent output must include decline language or evidence hierarchy reference |

### SC-17: Behavioral test — agent identifies the incorrect thought pattern and suppresses it

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with prompt that triggers cost rationalization; agent must explicitly reject the cheap path and take the correct expensive path |

## Key Considerations

- `default.txt` is plain text, not markdown. It goes in `.opencode/` at the same level as skills/ and guidelines/. Referenced in `opencode.jsonc` instructions array as the last entry so it's always at the bottom of context.
- The instructions block in `opencode.jsonc` must be edited carefully to preserve existing entries while appending the final entry.
- Dark prose card changes must maintain backward compatibility — existing 001-005 (now 001-006 after rename) patterns are unchanged, the new section is additive.

## Dependencies

- None. This is Phase 1 of 3.

## Related

- Phase 2 Spec (#806): Rewrite all guidelines with bright-line rules
- Phase 3 Spec (#807): Per-skill/task bright-line re-anchors