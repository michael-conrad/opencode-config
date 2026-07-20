## Objectives

Add a new dark prose pattern (dark-prose-007, Cost-Frame Reformation) that closes the conceptual gap where the AI agent rationalizes skipping verification or half-assing implementation by treating tool-call-count as "cost." The agent needs an identity anchor that reframes the cost metric: **cost is measured in defect-discovery-latency, not model roundtrips.**

This pattern must be:
1. Defined in `250-dark-prose-reference.md` as a first-class pattern
2. Applied in `020-go-prohibitions.md` at the cost-blind verification rule
3. Injected into spec-creation output so generated SCs carry cost-frame dark prose
4. Injected into writing-plans output so generated implementation instructions carry cost-frame dark prose

## Problem

The AI agent has a cost model that computes "opencode-cli run = expensive" using session-tool-calls as the currency. This causes the agent to:

- Substitute grep/static analysis for real model-dispatch behavioral tests
- Write prose-recall tests instead of stderr-based behavioral tests
- Skip edge case handling during implementation ("good enough for the happy path")
- Skip writing behavioral SC tests entirely (grep-based content checks instead)
- Rationalize: "this is expensive, so I'll do the cheaper thing"

The guidelines already contain a procedural rule (020-go-prohibitions.md lines 57-63) that says "cost is NEVER a factor," but procedural prohibition without identity-frame reframing is ineffective — the agent computes cost internally and the rule doesn't replace the cost model.

## Constraints and Scope

**In scope:**
- New dark-prose-007 pattern in 250-dark-prose-reference.md
- Application in 020-go-prohibitions.md (cost-blind verification block)
- Injection into spec-creation task (write.md) — generated SCs carry cost-frame dark prose intent
- Injection into writing-plans task (create.md) — generated implementation instructions carry cost-frame dark prose intent
- Corresponding updates to 250-dark-prose-reference.md pattern selection matrix (Section 2)

**Out of scope:**
- Modifying the existing procedural cost-blind rule text — only adding dark prose alongside it
- Behavioral enforcement test changes for this pattern (separate follow-up issues)
- Application in other guidelines or skills beyond the three listed
- Spec/plan content retroactively — only new output from the modified skills

## Success Criteria

### SC-1: dark-prose-007 defined in reference card
`250-dark-prose-reference.md` contains a new pattern entry:
- [ ] Section 1: Pattern ID allocation table row for `dark-prose-007 | Cost-Frame Reformation`
- [ ] Section 2: Selection matrix row for cost-blind guideline blocks → Cost-Frame Reformation | Strong
- [ ] Section 3: Full formula entry for dark-prose-007 (Cost-Frame Reformation)

### SC-2: dark-prose-007 applied in 020-go-prohibitions.md
The cost-blind verification block (lines 57-63) is immediately followed by a dark-prose-007 identity anchor block. The block reframes cost as defect-discovery-latency, not tool-call count.

### SC-3: Spec-creation injects cost-frame dark prose into SCs
`spec-creation/tasks/write.md` Step 0.5 (Behavioral Test Mandate in Success Criteria) is updated to include that every SC must carry a short cost-frame dark prose statement that reframes what "expensive" means for that SC's domain.

### SC-4: Writing-plans injects cost-frame dark prose into implementation instructions
`writing-plans/tasks/create.md` Plan Phase Structure Requirements (lines 57-62) is updated to include that each phase's "How to verify completion" section must carry cost-frame dark prose reframing verification cost.

## Risk and Edge Cases

- **Over-application risk:** Dark prose at too many locations causes competing standards. Mitigation: Only three locations (reference card, guidelines, spec-creation task, writing-plans task) — not every file.
- **Blame-adjacent violation risk:** The dark prose must NOT say "you chose to skip verification" or "you are being lazy." Must use consequence-assertion framing per dark-prose-006 agency-respecting meta-pattern. See 250-dark-prose-reference.md §Anti-Patterns.
- **One-pattern-per-location conflict:** Only one dark prose pattern per location. The cost-blind block currently has no dark prose — this is additive, not conflicting.
- **Competing standards with 020-go-prohibitions' existing cost-blind prose:** The existing prose is procedural (MUST NOT / FORBIDDEN). Dark prose is identity-frame. They work together: procedural says "don't compute cost," dark prose says "here's why the cost metric is wrong."

## Implementation Approach

### Phase 1: Define dark-prose-007
Update `250-dark-prose-reference.md`:
- Section 1: Add `dark-prose-007 | Cost-Frame Reformation` row
- Section 2: Add selection matrix row for cost-blind guideline blocks
- Section 3: Add formula:

```
[Verification action] WITHOUT [proper tool/dispatch] produces [unverified artifact].
An unverified [artifact type] costs [downstream consequence] — more than [verification action] ever could.
Every [verification action] skipped to "save [resource]" produced work that [cost outcome].
Cost measured in [correct metric] is what [identity anchor] measures — not [wrong metric], not [wrong proxy 2], not [wrong proxy 3].
```

### Phase 2: Apply in 020-go-prohibitions.md
Insert after line 63 (end of cost-blind verification block). The implementing agent reads dark-prose-007 formula from 250-dark-prose-reference.md and derives the exact prose autonomously — the spec does NOT prescribe exact text. Must pass the agency-respecting test.

### Phase 3: Inject into spec-creation
Update `spec-creation/tasks/write.md` Step 0.5 (line 26-34 area) to add that every SC should carry a cost-frame dark prose statement that reframes the cost equation for that SC's domain. The implementing agent reads dark-prose-007 and derives the specific formulation per SC.

### Phase 4: Inject into writing-plans
Update `writing-plans/tasks/create.md` Plan Phase Structure Requirements section to add that each phase's "How to verify completion" must carry cost-frame dark prose reframing verification cost. The implementing agent reads dark-prose-007 and derives per-phase formulations.

## Documentation Sources

- `020-go-prohibitions.md` lines 57-63: Existing cost-blind verification rule
- `250-dark-prose-reference.md`: All existing patterns and anti-pattern definitions
- `spec-creation/tasks/write.md` Step 0.5: Current behavioral test mandate in SCs
- `writing-plans/tasks/create.md` lines 57-62: Current plan phase structure requirements
- `000-critical-rules.md` §Tier 1 Mandate: Correctness over economy (referenced by 020-go-prohibitions.md but not a literal heading)

## AI Byline

Co-authored with AI: OpenCode (deepseek-v4-flash-free)
