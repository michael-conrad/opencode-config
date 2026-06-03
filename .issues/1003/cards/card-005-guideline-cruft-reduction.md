# Card 005: Proposed Fix — Guideline Cruft Reduction

## Date
2026-06-03

## Predecessor
Card-003, Card-004

## Proposal

Reduce session-start context from ~47,000 words to ~5,300 words (89% reduction). Move non-safety content to skill cards loaded on-demand by sub-agents.

## What Stays in Session Start

| File | Current Words | Keep Words | Keep Content |
|------|-------------|------------|-------------|
| `default.txt` | 2,141 | ~400 | Authorization scope, skill dispatch mandate, tone/style, action discipline, bright-line mandates (condensed) |
| `AGENTS.md` | 1,876 | ~400 | Identity detection, pipeline re-priming, universal skill dispatch gate, direct-branch workflow, boundaries |
| `000-critical-rules.md` | 11,562 | ~1,500 | Essential Tier 1 safety rules only. Remove symbolic yaml block (~300 lines). |
| `010-approval-gate.md` | 2,391 | ~300 | Scope model table only. |
| `020-go-prohibitions.md` | 5,388 | ~400 | Never solicit, questions ≠ auth, discussion conclusions ≠ auth. |
| `060-tool-usage.md` | 2,637 | ~400 | Path rules, no sed -i/printf/heredoc, no --recursive submodule. |
| `065-verification-honesty.md` | 4,993 | ~300 | Core principle: memory ≠ evidence, show tool calls. |
| `067-context-completeness.md` | 1,168 | ~150 | Read all comments before acting. |
| `075-docs-verification.md` | 696 | ~100 | Verify API sigs before calling. |
| `080-code-standards.md` | 7,636 | ~300 | Byline requirement, no re-exports, numbering. |
| `090-data-integrity.md` | 1,408 | ~150 | No synthetic data, hard fail on missing. |
| `091-incremental-build.md` | 781 | ~100 | Decompose before implement. |
| `117-session-trigger-behavior.md` | 526 | ~100 | No-echo rule, nested_opencode_fatal halt. |
| `130-authority-source.md` | 1,145 | ~150 | Code wins, check superseding. |
| INDEX.md | 599 | 599 | Keep as-is. |
| **Total** | **46,947** | **~5,349** | |

## Rationale

Skills are loaded dynamically when dispatched. A sub-agent gets ~200k fresh context. The session-start orchestrator should hold only enough to *route correctly* — not enough to *execute correctly*. The current ~47,000 words makes it impossible for the agent to distinguish "dispatch first" (200 words) from "verify everything" (46,000 words).