# [SPEC] Phase 2: Bright-Line Audit — Rewrite All Guidelines

- **Issue Number:** 806
- **Status:** DRAFT
- **Branch Pattern:** `feature/806-guideline-rewrite`
- **Authorization Scope:** `for_pr`
- **PR Strategy:** stacked
- **Depends On:** #805 (Phase 1 — must be merged for bright-line pattern definition)

## Problem

All existing guideline files contain advisory-junie-runbook prose: "prefer," "try to," "use where possible," "should." This prose style gives the agent a rationalization surface — it can reason its way around every instruction because none of them are expressed as binary gates.

The guidelines are also the highest-impact targets because they are loaded on every session start (Tier 1 instructions array) and set the tone for all subsequent agent behavior. Leaving them as advisory prose means the Phase 1 bright-line mandate exists but the instructions the agent actually reads first are still soft.

## Scope

All files matching `.opencode/guidelines/*.md` that contain advisory prose patterns. Each rule in each guideline must be evaluated and either:

1. **Rewritten as bright-line** — absolute language, binary compliance, exception carve-out, failure definition
2. **Removed** — if the rule is dead, redundant, or better expressed in a skill
3. **Preserved** — if already using absolute language and binary gates

### File List

| File | Tier | Priority | Advisory Rules Count (estimated) |
|------|------|----------|----------------------------------|
| `010-approval-gate.md` | 1 | Critical | ~8 |
| `020-go-prohibitions.md` | 1 | Critical | ~15 |
| `060-tool-usage.md` | 1 | Critical | ~12 |
| `065-verification-honesty.md` | 1 | Critical | ~10 |
| `067-context-completeness.md` | 1 | Critical | ~5 |
| `075-docs-verification.md` | 1 | Critical | ~4 |
| `080-code-standards.md` | 1 | Critical | ~10 |
| `090-data-integrity.md` | 1 | Critical | ~8 |
| `091-incremental-build.md` | 1 | Critical | ~5 |
| `117-session-trigger-behavior.md` | 1 | Critical | ~2 |
| `130-authority-source.md` | 1 | Critical | ~3 |
| `015-pre-spec-inspection.md` | 2 | Medium | ~4 |
| `016-srclight-preference.md` | 2 | Medium | ~2 |
| `045-open-questions.md` | 2 | Medium | ~2 |
| `050-scope-autonomy.md` | 2 | Medium | ~3 |
| `070-environment.md` | 2 | Medium | ~4 |
| `085-project-local-tools.md` | 2 | Medium | ~5 |
| `086-http-requests.md` | 2 | Medium | ~2 |
| `087-no-backward-compat.md` | 2 | Medium | ~2 |
| `100-persistence.md` | 2 | Medium | ~3 |
| `115-branch-naming.md` | 2 | Low | ~2 |
| `116-pair-mode.md` | 2 | Medium | ~3 |
| `140-planning-spec-creation.md` | 2 | Low | ~2 |
| `141-planning-status-tracking.md` | 2 | Low | ~2 |
| `142-planning-archive-workflow.md` | 2 | Low | ~1 |
| `143-planning-spec-templates.md` | 2 | Low | ~1 |
| `144-planning-spec-examples.md` | 2 | Low | ~1 |
| `200-errors.md` | 2 | Medium | ~4 |
| `210-scripting.md` | 2 | Low | ~2 |
| `250-dark-prose-reference.md` | 2 | **(exempt — Phase 1)** | 0 |

## Success Criteria

### SC-1: All Tier 1 guidelines audited and advisory rules converted

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep for advisory patterns ("prefer", "try to", "should", "where possible", "may want to") in each Tier 1 file; sub-agent confirms zero remaining for Tier 1 files |
| **Acceptable remaining** | Advisory patterns in non-rule sections (commentary/examples) or grandfathered sections per SC-4 |

### SC-2: All Tier 2 guidelines audited and advisory rules converted

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | Same grep as SC-1 applied to Tier 2 files; sub-agent confirms conversion quality |

### SC-3: Each converted rule has the three-part structure

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | Sub-agent reads a representative sample of converted rules from each file and confirms they contain: absolute language (ALWAYS/NEVER) + exception carve-out or "no exceptions" + failure definition or binary gate |

### SC-4: Grandfather clause — existing 0-indexed numbering, legacy `__all__`, and pre-existing content formats are preserved; only rule prose is rewritten

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Sub-agent diff samples against pre-rewrite versions and confirms only rule prose was changed, not numbering, formatting conventions, or non-rule content |

### SC-5: Every converted rule produces a corresponding enforcement test update

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | Behavioral tests exist for at least the top 10 highest-impact conversions; tests verify agent follows the new bright-line rule (not just that the text exists) |

### SC-6: Behavioral test — agent follows a rewritten bright-line rule from 060-tool-usage.md

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with prompt that triggers a prohibited tool pattern; agent must reference and follow the bright-line prohibition |

### SC-7: Behavioral test — agent does NOT rationalize around a converted approval rule

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with ambiguous authorization scenario; agent must produce the correct binary outcome per the bright-line rewrite of approval-gate-002 |

### SC-8: No file loses structural content (frontmatter, symbolic rules block, or section headers)

| | |
|---|---|
| **Evidence Type** | structural + string |
| **Verification** | `diff` comparison confirms frontmatter + symbolic rules + section headers are identical; only prose body changed |

### SC-9: Symbolic yaml+symbolic rules blocks are updated to match rewritten prose

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep each file's symbolic rules block for "advisory" action patterns (FLAG only, no binary); those that should now HALT (from advisory→brightline conversion) must have their action field updated. Sub-agent verifies no mismatch between prose tier/action and symbolic tier/action |

## Key Considerations

- This is the highest-volume phase. There are ~30 guideline files. Not every file needs the same depth of conversion. Tier 1 files get the full treatment. Some Tier 2 files may only need 2-3 lines rewritten.
- The phase is gated on Phase 1 being merged because Phase 1 defines what "bright-line" means. Without that shared definition, each file review would re-invent the technique.
- Enforcement test generation MUST use behavioral TDD: write the test (RED), make the guideline change (GREEN), commit both together. Per `080-code-standards.md` §Behavioral RED/GREEN as Primary Enforcement Gate.
- Content-verification tests (grep for remaining advisory patterns) are supplementary sanity checks. Behavioral tests are PRIMARY.

## Dependencies

- #805 merged (Phase 1 foundation — defines bright-line technique and cost model override)

## Related

- Phase 1 Spec (#805): Foundation — default.txt + dark prose reference card
- Phase 3 Spec (#807): Per-skill/task bright-line re-anchors