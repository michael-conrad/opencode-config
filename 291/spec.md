---
title: Holistic Cross-Reference Load Directive Fix — Rewrite All Citation-Style Cross-References
status: draft
created: 2026-07-13
license: MIT
provenance: AI-generated
issue: 291
authors:
  - OpenCode (ollama-cloud/deepseek-v4-pro)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-13

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The opencode guidelines use ~164 cross-references of the form `See `FILENAME.md` §SECTION` or `See `SKILLNAME` skill` across `.opencode/guidelines/` and `.opencode/skills/`. These are written as prose citations. The agent treats them as decorative closing sentences rather than as load directives. The agent reads the summary sentence before "see" and treats it as the complete rule, never loading the referenced content where the actual rule lives.

The band-aid spec (#288) adds a text mandate to `default.txt` and `.opencode/AGENTS.md` telling the agent that cross-references are load directives. This spec addresses the root cause: the cross-references themselves are written in a form the agent interprets as citations.

## Root Cause Analysis

The word "See" is a passive verb. The agent interprets it as a citation, not an instruction. The backtick-wrapped filename is not recognized as a loadable resource. The `§` section reference is not recognized as a navigation target.

The deck already has one explicit load directive pattern that works: `Read `<skill>/tasks/<task>.md` first` in SKILL.md DISPATCH_GATE sections. It uses an imperative verb ("Read"), a backtick-wrapped path, and a temporal qualifier ("first"). The agent follows it.

The fix is to rewrite all ~164 guideline cross-references from citation form to load-directive form, following the deck's own pattern adapted for the guideline context.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Band-aid only (#288) — add mandate to system prompt without rewriting cross-references | Does not address root cause; agent may still ignore the mandate if the cross-references themselves look like citations |
| Remove all cross-references entirely | Loses progressive disclosure structure; guidelines become monolithic |
| Use `Read `FILE.md` §SECTION` pattern | "Read" already has a specific meaning in the deck (sub-agent task file discovery in DISPATCH_GATE sections); would create ambiguity |
| Use `Load `FILE.md` §SECTION` without incompleteness signal | Agent may still treat as optional citation if the preceding text reads as a complete rule |

## Fix

Rewrite every citation-style cross-reference from:

```
See `065-verification-honesty.md` §Cost Model.
```

to:

```
The rule is incomplete without `065-verification-honesty.md` §Cost Model — load it now.
```

Three parts:
1. "The rule is incomplete without" — signals that the current text is a summary, not the full rule
2. Backtick-wrapped path + § section — the existing identifier format, preserved
3. "load it now" — imperative directive with temporal qualifier

"Load" rather than "read" because "read" in the deck already has a specific meaning (sub-agent task file discovery in DISPATCH_GATE sections). "Load" is unambiguous: fetch this content into your context.

For skill cross-references, the form is:

```
The rule is incomplete without the `SKILLNAME` skill — load it now.
```

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#288](https://github.com/michael-conrad/opencode-config/issues/288) | BLOCKED_BY | Band-aid spec — mandate in default.txt and AGENTS.md must be implemented first |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. The rule is incomplete without `080-code-standards.md` §Test Integrity Mandate — load it now.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All ~164 guideline cross-references rewritten from citation form (`See `FILE.md` §SECTION`) to load-directive form (`The rule is incomplete without `FILE.md` §SECTION — load it now.`) | `string` | grep for `See `[^`]+\.md` §` in `.opencode/guidelines/` and `.opencode/skills/` — must return zero matches | Re-run grep; fix any remaining citation-style references | red-green | `.issues/291/string/` | Root cause: citation form is not recognized as load directive | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-2 | All ~20 skill cross-references rewritten from citation form (`See `SKILLNAME` skill`) to load-directive form (`The rule is incomplete without the `SKILLNAME` skill — load it now.`) | `string` | grep for `See `[^`]+` skill` in `.opencode/guidelines/` and `.opencode/skills/` — must return zero matches | Re-run grep; fix any remaining citation-style references | red-green | `.issues/291/string/` | Root cause: citation form is not recognized as load directive | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-3 | Behavioral enforcement test verifies agent loads referenced content when encountering a load-directive cross-reference | `behavioral` | `opencode-cli run` with a prompt that triggers a rule whose guideline contains a load-directive; verify via stderr that the agent reads the referenced file | Diagnose timeout/model availability; re-run with increased timeout; escalate only after 2+ remediation failures | red-green | `.issues/291/behavioral/` | Root cause: agent treats cross-references as decorative prose | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-4 | Behavioral enforcement test verifies agent does NOT treat load-directives as decorative prose (i.e., agent does not skip loading referenced content) | `behavioral` | `opencode-cli run` with a prompt that triggers a rule whose guideline contains a load-directive; verify via stderr that the agent does NOT produce output that treats the rule as complete without loading the reference | Diagnose timeout/model availability; re-run with increased timeout; escalate only after 2+ remediation failures | red-green | `.issues/291/behavioral/` | Root cause: agent treats cross-references as decorative prose | Phase 2 | pre-commit | sequential | — | — | — | Phase 2 |
| SC-5 | Linting rule detects citation-style cross-references (`See `FILE.md` §SECTION` and `See `SKILLNAME` skill`) in guideline and skill files | `behavioral` | Run lint on a test file containing citation-style cross-references; verify it flags them as violations | Fix lint rule regex; re-run on test file | red-green | `.issues/291/behavioral/` | Root cause: no automated detection of citation-style cross-references | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-6 | Linting rule integrated into markdown lint pipeline (`.opencode/AGENTS.md` build/lint/test commands) | `string` | grep for the lint rule reference in `.opencode/AGENTS.md` or lint config | Add the lint rule to the pipeline documentation | red-green | `.issues/291/string/` | Root cause: no automated detection of citation-style cross-references | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-7 | Guideline documents the correct load-directive format with examples | `string` | grep for load-directive format documentation in `.opencode/guidelines/` | Add or update the guideline | red-green | `.issues/291/string/` | Root cause: no documentation of correct format | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-8 | SKILL.md cross-reference sections updated to use load-directive form | `string` | grep for `See ` in `.opencode/skills/*/SKILL.md` — must return zero matches | Re-run grep; fix any remaining citation-style references | red-green | `.issues/291/string/` | Root cause: citation form is not recognized as load directive | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-9 | No existing behavioral tests broken by the cross-reference rewrites | `behavioral` | Run `bash .opencode/tests/test-enforcement.sh --changed` after all rewrites; all must PASS | Diagnose failures; fix any broken tests; re-run | red-green | `.issues/291/behavioral/` | Regression: rewrites must not break existing enforcement | Phase 4 | pre-commit | sequential | — | — | — | Phase 4 |
| SC-10 | Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rule; confirm RED state (test fails before change). If the tests are missing from the working tree when implementation begins, they must be re-created before any source changes. | `behavioral` | Verify behavioral test files exist and fail (RED) before any source changes are made | Create missing test files; confirm RED state | red-green | `.issues/291/behavioral/` | TDD mandate: tests before implementation | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-11 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | Audit SC table after implementation; verify all SCs have correct evidence types and none were downgraded | Restore original evidence types; re-implement | red-green | `.issues/291/behavioral/` | Anti-lobotomization mandate | Phase 4 | pre-commit | sequential | — | — | — | Phase 4 |

## Affected Files

- `.opencode/guidelines/*.md` — all guideline files with citation-style cross-references (~43 references across 12 files)
- `.opencode/skills/*/SKILL.md` — skill card cross-reference sections
- `.opencode/skills/*/tasks/*.md` — task file cross-references (~21 references across 11 files)
- `.opencode/tests/behaviors/` — new behavioral enforcement tests
- `.opencode/AGENTS.md` — lint rule integration in build/lint/test commands

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `rg 'See `' .opencode/guidelines/ .opencode/skills/` | Count and locate all citation-style cross-references |
| Direct source search | `rg 'See `[^`]+\.md` §' .opencode/` | Count guideline cross-references |
| Direct source search | `rg 'See `[^`]+` skill' .opencode/` | Count skill cross-references |
| GitHub Issues | `github_issue_read(method=get, issue_number=288)` | Verify band-aid spec exists and is the dependency |
| GitHub Issues | `github_search_issues(query="repo:michael-conrad/opencode-config cross-reference load directive")` | Check for existing related specs |

## Research Card

`.issues/research-cards/cross-reference-lobotomization.md` — not yet created; to be created during implementation.

After this spec is approved, invoke `writing-plans` to create `.issues/291/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
