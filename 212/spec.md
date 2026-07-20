## Problem

Skill card descriptions (the `description` field in SKILL.md YAML frontmatter) serve as the primary dispatch signal for AI agents deciding when to invoke a skill. Currently, 36 of 39 descriptions lack mandatory language signaling that dispatch is required and steps may not be skipped. One description (`playwright-cli`) does not start with "Use when" at all. Many descriptions contain narrative-only second sentences (slogans, metaphors, value judgments) that add zero dispatch information.

The "use when" text must indicate: (1) when the skill card should be invoked, (2) that usage is mandatory, not optional, (3) that no steps or requirements may be skipped.

## Scope

All 39 SKILL.md files in `.opencode/skills/*/SKILL.md`.

## Audit Dimensions

### D1 — Format
Description MUST start with `"Use when"`. The `playwright-cli` skill is the only known violation.

### D2 — Correctness
Description MUST accurately reflect the Trigger Dispatch Table's conditions. Every dispatch condition listed in the table must be represented in the description. The description must not describe use cases the table does not cover.

### D3 — Completeness
Description MUST cover all dispatch conditions from the Trigger Dispatch Table. If the table lists triggers for `pre-work`, `implementation`, `review-prep`, `pr-creation`, `rebase`, `check-pr`, `release`, `cleanup`, `provenance`, `sync-submodules` (as `git-workflow` does), the description must reflect all of them — not a subset.

### D4 — Mandatory Language
Description MUST include language signaling that dispatch is mandatory and steps may not be skipped. Acceptable patterns:
- `MUST dispatch here after plan approval, before any file modification`
- `Audits are not optional`
- `Always invoke before git-workflow pre-work`
- `REQUIRED before any file modification`
- `Mandatory: invoke before proceeding`

Currently only 3 skills have this: `adversarial-audit`, `implementation-pipeline`, `using-git-worktrees`.

### D5 — Narrative-Only Content
Description MUST NOT contain sentences that add zero dispatch information. The following patterns are narrative-only and must be removed or moved to the skill body:
- Slogans: `"A finished branch is a clean branch."`, `"Sync is maintenance, not overhead."`
- Value judgments: `"Professional engineers spec first."`, `"TDD produces testable, correct code."`
- Metaphors: `"Plans are the map — agents who skip them get lost."`
- Benefit statements: `"Verification turns guesses into facts."`, `"Systematic debugging finds root causes."`

Exception: Consequence statements that reinforce mandatory behavior are acceptable if they directly support the dispatch condition (e.g., `"Implementing without authorization produces unreviewed, unapproved code — the fastest path to rework."`).

## Audit Deliverables

For each of the 39 skills, the audit must produce:

| Field | Description |
|-------|-------------|
| Skill name | Name from SKILL.md |
| Current description | Verbatim text |
| D1 (Format) | PASS/FAIL |
| D2 (Correctness) | PASS/FAIL with evidence |
| D3 (Completeness) | PASS/FAIL with evidence |
| D4 (Mandatory language) | PASS/FAIL |
| D5 (Narrative-only) | PASS/FAIL — list narrative sentences |
| Proposed description | Corrected "use when" text |
| Linting rule changes | What structural rules need updating |
| Semantic auditor criteria | What semantic checks need updating |

## Linting Rules (Structural)

The following structural checks must be added or updated in the skill card linter:

| Rule ID | Check | Applies To |
|---------|-------|------------|
| SC-LINT-001 | Description starts with "Use when" | All skills |
| SC-LINT-002 | Description contains at least one mandatory keyword (MUST, REQUIRED, always, not optional, mandatory) | All skills |
| SC-LINT-003 | Description does not end with a standalone narrative-only sentence that adds zero dispatch information | All skills |
| SC-LINT-004 | Description length does not exceed 300 characters (prevents prose bloat) | All skills |

## Semantic Auditor Criteria

The following semantic checks must be added to the skill card auditor:

| Criteria ID | Question | Method |
|-------------|----------|--------|
| SC-SEM-001 | Does the description unambiguously tell an agent when to invoke this skill? | Sub-agent read + judgment |
| SC-SEM-002 | Does the description signal that invocation is mandatory (not optional)? | Sub-agent read + judgment |
| SC-SEM-003 | Does the description match the Trigger Dispatch Table's intent? | Compare description against table triggers |
| SC-SEM-004 | Would an agent reading only the description know to invoke this skill in all conditions listed in the dispatch table? | Sub-agent read + judgment |
| SC-SEM-005 | Does the description contain any language that could be interpreted as making dispatch optional or discretionary? | Sub-agent read + judgment |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | All 39 skill descriptions audited against D1-D5 | `behavioral` |
| SC-2 | Every D4 FAIL identified with specific missing mandatory language | `string` |
| SC-3 | Every D5 FAIL identified with specific narrative-only sentences | `string` |
| SC-4 | Linting rules SC-LINT-001 through SC-LINT-004 defined and documented | `structural` |
| SC-5 | Semantic auditor criteria SC-SEM-001 through SC-SEM-005 defined and documented | `structural` |
| SC-6 | `playwright-cli` description flagged for D1 format violation | `string` |
| SC-7 | `approval-gate` flagged for missing Trigger Dispatch Table | `string` |
| SC-8 | Audit report lists proposed corrected descriptions for all 39 skills | `structural` |

## Derived Fix Specs

The audit findings feed into 5 fix-specs, decomposed by concern type:

| Fix-Spec | Concern | Skills Affected | Pattern |
|----------|---------|----------------|---------|
| Fix A | `playwright-cli` description format fix (D1) | 1 | Unique — different license, structure, upstream |
| Fix B | `approval-gate` Trigger Dispatch Table creation | 1 | Unique — only skill without a formal table |
| Fix C | Description rewrites for D4 mandatory language + D5 narrative cleanup | 36 | Same fix pattern across all skills |
| Fix D | Linting rules implementation (SC-LINT-001 through 004) | 0 (linter code) | Structural checks in skill card validator |
| Fix E | Semantic auditor criteria implementation (SC-SEM-001 through 005) | 0 (auditor code) | Semantic checks in skill card auditor |

Each fix-spec is a separate issue linked as a sub-issue of this audit spec. Fix C may be further decomposed into sub-issues by skill group if the 36-skills scope proves too large for a single implementation pass.

## Out of Scope

- Actual edits to SKILL.md descriptions (this is an audit spec, not a fix spec)
- Changes to skill body content, task files, or dispatch tables
- Changes to the skill card linter or auditor implementation (only criteria definitions)

## References

- `skill-creator` skill — skill card validation
- `adversarial-audit --task spec-audit` — spec audit workflow
- `adversarial-audit --task guideline-audit` — guideline audit workflow
- `080-code-standards.md` §Enforcement Test Mandate — behavioral test requirements

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)