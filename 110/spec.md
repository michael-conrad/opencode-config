## Intent and Executive Summary

**Problem Statement:** Specs drift over time and become hard to interpret later. Without recorded context, future readers — including AI agents — cannot reconstruct why a particular approach was chosen, what alternatives were considered, or what problem was being solved. This erodes the spec's value as a historical artifact.

**Root Cause:** Specs capture the *what* and the *how* but not the *why* — rationale, discarded alternatives, and design decisions are implicit in the author's mind at creation time but never persisted.

**Approach Chosen:** Add a structured preamble section (`## Intent and Executive Summary`) to every spec, positioned before the existing body. It captures the historical context without diluting the spec itself.

**Alternatives Considered:**
- Appending the section to the end (rejected — loses chronological prominence at time of reading)
- Embedding context inline in existing sections (rejected — fragments the intent, harder to reconstruct)
- A separate metadata YAML block (rejected — less readable, agents handle it worse)

**Key Design Decisions:**
- Preamble fields are plain Markdown prose (not YAML frontmatter) for readability
- Preamble is mandatory for all standard+ complexity specs; minimal specs may omit
- Preamble does NOT replace Summary/Objective — it precedes and contextualizes it
- Existing specs are NOT retrofitted (forward-only)

---

STATUS: DRAFT
CREATED: 2026-05-20
ISSUE: <!-- placeholder -->
ISSUE_TITLE: Add Intent & Executive Summary Preamble to Specs
LABELS: [SPEC, spec-structure]
CONTENT_COVERAGE: problem, motivation, approach, alternatives, design-decisions

## Requirements

### Explicit Requirements

| ID | Requirement | Verification |
|----|-------------|-------------|
| R1 | `## Intent and Executive Summary` section defined as first section after STATUS/CREATED header, before any spec body | Guideline text specifies position |
| R2 | Preamble contains exactly 5 fields: Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions | Guideline defines fields |
| R3 | Preamble is mandatory for standard+ complexity specs; minimal/bug-fix specs may omit | Exception rule documented |
| R4 | Existing specs are NOT retrofitted | Explicit non-requirement |
| R5 | Preamble does NOT replace existing Summary/Objective sections | Positional rule: precedes, does not replace |

### Implicit Requirements

| ID | Requirement |
|----|-------------|
| I1 | Spec auditor must verify preamble presence for standard+ specs |
| I2 | Preamble fields populated at creation time, not post-hoc |
| I3 | All templates and examples updated to show preamble |

## Affected Files

| File | Change |
|------|--------|
| `142-planning-archive-workflow.md` §6 | Add preamble to canonical template |
| `142-planning-archive-workflow.md` §7 | Add preamble to required elements list |
| `140-planning-spec-creation.md` Content Coverage | Add preamble fields as required content areas |
| `143-planning-spec-templates.md` | Show preamble in feature/guideline/bug examples |
| `144-planning-spec-examples.md` | Show preamble in standard and comprehensive examples |
| `spec-creation/tasks/write.md` Step 5 | Add preamble as required section for standard+ specs |
| `adversarial-audit` tasks (spec-audit) | Add preamble completeness checks |

## Success Criteria

| SC | Criterion | Verification |
|----|-----------|-------------|
| SC-1 | All spec structure guidelines list `## Intent and Executive Summary` as the first section | `grep` for presence in 140, 142, 143, 144 |
| SC-2 | `write.md` Step 5 lists preamble for standard+ complexity specs | Read task file |
| SC-3 | Spec-audit checks include preamble content area verification | Read audit task files |
| SC-4 | No existing specs were modified (forward-only) | `git diff --stat` against dev |

## Risk Table

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Forgetting preamble in new specs | Medium | Medium | Spec-audit check + mandatory status in write task |
| Preamble duplicates Summary content | Medium | Low | Guidance: preamble is historical context, Summary is spec purpose |
| Existing templates missed in update | Low | Medium | File-level checklist in affected files section |

## Edge Cases

- **Trivial bug fix spec (1 line change):** Preamble optional per complexity-tier model
- **Spec already has extensive rationale:** Preamble supplements, does not replace — existing body rationale stays
- **Multi-phase spec with sub-issues:** Preamble goes in parent spec only; sub-issues inherit context

## Documentation Sources

| Source | What It Provides |
|--------|-----------------|
| Existing spec examples in `.issues/` | Current structure to understand insertion point |
| `140-planning-spec-creation.md` | Content coverage requirements to update |
| `142-planning-archive-workflow.md` §6-7 | Canonical template and required elements |
| `143-planning-spec-templates.md` | Example variants to modify |
| `144-planning-spec-examples.md` | Example variants to modify |
| `spec-creation/tasks/write.md` | Spec assembly task to update |
| `adversarial-audit` tasks/*.md | Audit checks to extend |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)