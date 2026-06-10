# [SPEC] Procedural Discipline Reference Card — Execution-Layer Sibling to Dark Prose and Distribution Shifting

## Problem

The Dark Prose Reference Card (guidelines/250-dark-prose-reference.md) defines what enforcement text says.
The Distribution-Shifting Reference Card (guidelines/255-distribution-shifting-reference.md) defines how to structure it.
Neither card addresses the execution layer — how agent-facing text enforces sequential, dependency-ordered execution without step-skipping.

## Success Criteria

| SC-ID | Criterion | Evidence Type |
|-------|-----------|---------------|
| SC-1 | Card file exists with all 6 patterns | structural |
| SC-2 | All 6 pattern formulas (p-dis-001 through p-dis-006) present | structural |
| SC-3 | Dependency-Order Gate Protocol (Section 5) with gate formula | structural |
| SC-4 | Re-Priming Protocol (Section 6) with enforcement block formula and positional strategy | structural |
| SC-5 | Controlled Vocabulary (Section 7) with external verification and over-enforcement rows | structural |
| SC-6 | Re-Research Mandate (Section 8) with 4-step currency-check protocol. Four items each on its own line prefixed with `1.`, `2.`, `3.`, `4.`: (1) check freshness, (2) search if stale, (3) flag NEEDS-REVALIDATION, (4) document as version update. Protocol heading MUST read "Research-currency-check protocol". | structural |
| SC-7 | Co-Application Rules (Section 4) referencing both 250 and 255 | structural |
| SC-8 | Version Tracking, Auto-Detection, Adding Patterns, Conflict Resolution, Research Basis | structural |
| SC-9 | Pattern Selection Matrix matching content-type rows | structural |
| SC-10 | 250-dark-prose-reference.md updated with dependency-order bright-line companion row | structural |
| SC-11 | 000-critical-rules.md updated with pipeline re-priming rule | structural |
| SC-12 | INDEX.md updated with 257 entry | structural |
| SC-13 | p-dis-006 (Verification-Signal Discipline) formula present | structural |
| SC-14 | Section 6 includes Positional Enforcement Strategy with primacy+recency | structural |
| SC-15 | Section 7 includes External verification and Over-enforcement vocabulary rows | structural |
| SC-16 | Section 13 contains 13 external citations from domains (arxiv.org, anthropic.com, trychroma.com, github.com). Each citation MUST have a `Verified claim:` annotation on the line immediately following the citation URL line. | structural |

## Auditor Evidence Directory

Auditors receive `artifact_evidence_dir` containing these files:
- `257-procedural-discipline-reference.md` — primary target
- `250-dark-prose-reference.md` — companion card (SC-10)
- `000-critical-rules.md` — pipeline re-priming rule (SC-11)
- `INDEX.md` — guidelines index (SC-12)

All four files MUST be present in the evidence directory for auditors to evaluate SC-10/11/12.

## Spec Scope Boundary

This spec defines exactly 16 SCs (SC-1 through SC-16). No criterion outside this table constitutes a PASS/FAIL verdict for this implementation. Auditors MUST NOT evaluate criteria not listed in the Success Criteria table above.

SPDX-FileCopyrightText, SPDX-License-Identifier, and Provenance headers are inherited from `080-code-standards.md` and are NOT evaluated as separate SCs in this spec. They are enforced by git hooks and pre-commit gates, not this implementation issue.

## Required Changes

The existing file 257-procedural-discipline-reference.md has 3 gaps:
1. SC-16: Section 13 currently contains internal guideline references — must be replaced with 13 external citations (arxiv.org, anthropic.com, trychroma.com, github.com)
2. SC-7: Section 4 co-application rules only reference 250 — must also reference 255-distribution-shifting-reference.md
3. SC-6: Section 8 has a troubleshooting protocol — must be replaced with research-currency-check protocol (check freshness → search if stale → flag NEEDS-REVALIDATION → document)