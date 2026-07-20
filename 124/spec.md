# [SPEC] Phase 3: Per-Skill/Task Bright-Line Re-Anchors

- **Issue Number:** 807
- **Status:** DRAFT
- **Branch Pattern:** `feature/807-skill-task-anchors`
- **Authorization Scope:** `for_pr`
- **PR Strategy:** stacked
- **Depends On:** #806 (Phase 2 — guidelines rewritten with bright-line rules)

## Problem

Skills and tasks are loaded on-demand (not always in context like guidelines and default.txt). When a skill IS loaded, the agent enters its context with the same rationalization tendencies — and the SKILL.md Overview's dark prose opener, while rhetorically effective, still allows rationalization ("I'm a professional engineer, so this case is different").

Each skill has a specific vulnerability to a particular rationalization pattern:

| Skill | Vulnerability |
|-------|---------------|
| `verification-before-completion` | "A grep check is good enough for this behavioral SC" |
| `adversarial-audit` | "I've already verified this, no need for adversarial" |
| `divide-and-conquer` | "I can do this inline, it's faster than dispatching" |
| `brainstorming` | "I know what the user wants after one question" |
| `test-driven-development` | "I'll write the behavioral test after implementation" |
| `engineering-approach` | "I know this API, no need to check live docs" |
| `finishing-a-development-branch` | "VbC passed, no need for finishing checklist" |
| `git-workflow` | "This git operation is simple enough to do inline" |
| `issue-operations` | "I know the platform, no need to route through dispatcher" |
| `executing-plans` | "This step is trivial, I can inline it" |

Each SKILL.md needs a 1-2 sentence bright-line re-anchor in its Overview, and each task file that has a gate/decision point needs an action-point reminder at that specific location.

## Scope

### SKILL.md Files

Each `.opencode/skills/*/SKILL.md` gets a single bright-line re-anchor sentence in the Overview section, placed between the dark prose opener and the Persona section.

### Task Files

Task files that contain verification/substitution/decision gates get an inline bright-line reminder at the specific procedural step where the rationalization typically fires. These are ~8-15 words embedded as sub-bullets in the procedure.

| Skill | Tasks Requiring Re-Anchors |
|-------|---------------------------|
| `verification-before-completion` | `tasks/verify.md` |
| `adversarial-audit` | `tasks/spec-audit.md`, `tasks/cross-validate.md` |
| `divide-and-conquer` | `tasks/assemble-work.md` |
| `brainstorming` | `tasks/explore/exploration-workflow.md` |
| `test-driven-development` | SKILL.md only (no task file has a gate point) |
| `engineering-approach` | SKILL.md only |
| `finishing-a-development-branch` | `tasks/checklist.md` |
| `git-workflow` | `tasks/pre-work.md` |
| `issue-operations` | `tasks/creation.md` |
| `executing-plans` | SKILL.md only |

Total SKILL.md changes: ~20 files
Total task file changes: ~6 files

## Success Criteria

### SC-1: Every SKILL.md has a bright-line re-anchor in its Overview

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep for each skill's specific re-anchor pattern; sub-agent confirms each one targets the correct vulnerability |

### SC-2: Each re-anchor uses the three-part structure (from 250-dark-prose-reference.md pattern 007)

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | Sub-agent samples 5 skills and checks each re-anchor for: absolute language (ALWAYS/NEVER), exception carve-out or "no exceptions", failure definition |

### SC-3: Each re-anchor is ≤30 words

| | |
|---|---|
| **Evidence Type** | structural |
| **Verification** | `wc -w` on each re-anchor sentence |

### SC-4: Every task file identified in Scope has an inline action-point reminder at the relevant gate point

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep for the reminder anchor text in each identified task file; sub-agent confirms correct placement (at the decision step, not at the top or bottom) |

### SC-5: Action-point reminders are ≤15 words

| | |
|---|---|
| **Evidence Type** | structural |
| **Verification** | `wc -w` on each action-point reminder |

### SC-6: Re-anchors reference specific forbidden rationalization (by name or description)

| | |
|---|---|
| **Evidence Type** | string + semantic |
| **Verification** | grep each re-anchor for text that maps to the vulnerability row in the Scope table above; sub-agent confirms match |

### SC-7: Behavioral test — agent dispatches sub-agents instead of inline work when loaded with divide-and-conquer skill

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with prompt that triggers the "I can do this inline" rationalization; agent must use task() calls and not perform file edits inline |

### SC-8: Behavioral test — agent declines structural evidence for behavioral SC when verification-before-completion is loaded

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with prompt asking agent to verify a behavioral SC using only grep; agent must reference the evidence hierarchy or EVIDENCE_TYPE_MISMATCH gate |

### SC-9: Behavioral test — agent runs finishing-checklist before declaring branch complete

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with prompt that says "implementation is done, ready for PR"; agent must invoke finishing-a-development-branch checklist rather than proceeding directly |

### SC-10: Behavioral test — agent reads issue comments before acting

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `opencode-cli run` with prompt to act on an issue; agent tool calls must include `get_comments` before mutation |

## Key Considerations

- This is the lowest per-file effort but highest file count. Each change is small (1-2 lines) but applied across ~26 files.
- The phase is gated on Phase 2 because the guidelines define the bright-line pattern language. Without Phase 2, the re-anchors would be inconsistent with the guideline prose style, creating two dialects.
- The re-anchor is NOT a replacement of the dark prose opener. It's a companion that goes in the Overview between the opener and the Persona section. The dark prose opener handles rhetorical compliance (wanting to follow the rule); the bright-line re-anchor handles structural compliance (being unable to rationalize around it).
- Enforcement tests are concentrated on the 6 most impactful vulnerabilities (SC-7 through SC-10). The remaining 4 are covered by content assertions only (SC-1 through SC-6).

## Dependencies

- #805 merged (defines bright-line technique)
- #806 merged (rewrites guidelines with bright-line prose — provides the consistent language)

## Related

- Phase 1 Spec (#805): Foundation — default.txt + dark prose reference card
- Phase 2 Spec (#806): Rewrite all guidelines with bright-line rules