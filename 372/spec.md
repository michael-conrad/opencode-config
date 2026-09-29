---
number: 372
title: "[BUG] Root AGENTS.md Test Framework Discipline lacks repo-scope qualifier"
status: open
labels: [approved-for-pr]
created: 2026-09-28T01:26:00Z
updated: 2026-09-29T01:26:53Z
remote_issue: 372
remote_url: "https://github.com/michael-conrad/opencode-config/issues/372"
promoted_at: 2026-09-29T01:30:00Z
promotion_type: retroactive_import
last_sync: 2026-09-29T01:30:00Z
author: michael-conrad
---

## Spec Reference Blockquote

> **Spec:** `[BUG] Root AGENTS.md Test Framework Discipline lacks repo-scope qualifier` — opencode-config #372. `approved-for-pr`. Source of truth: `.issues/372/spec.md` (local, authoritative). Remote mirror: https://github.com/michael-conrad/opencode-config/issues/372

## Problem Statement

Root `AGENTS.md` § "Test Framework Discipline" states "All test execution MUST use the canonical test framework" with no repo-scope qualifier. Read universally, it directs agents making non-`.opencode` (parent-repo, root-level) changes to use the `.opencode` tests-v2 framework (`with-test-home`, `opencode run` behavioral testing) — but that framework exists only in the `.opencode` deck repo and applies only to `.opencode`-targeted work. An agent working on root-repo files is directed to a framework that does not exist in its context, producing either fabricated justifications (claiming the framework is unavailable) or inappropriate forays into the `.opencode` submodule for unrelated changes.

This is the same scoping-defect family fixed on the deck side by michael-conrad/.opencode#2469 — that issue fixed the deck's AGENTS.md; this issue fixes the parent-repo AGENTS.md surface.

**Evidence:** `grep -n "All test execution" AGENTS.md` — line present, no scope qualifier (verified).

## Root Cause / Motivation

**Root cause:** The parent-repo `AGENTS.md` § Test Framework Discipline was written as a universal mandate ("All test execution MUST use the canonical test framework") describing `.opencode`-repo tooling (`.opencode/tests-v2/with-test-home`, `opencode run`) without scoping applicability to the repo where that framework lives. The deck-side counterpart (`.opencode/AGENTS.md`) was fixed via the same defect family by michael-conrad/.opencode#2469; the root-side surface was left unscoped.

**Motivation:** Unscoped mandates in agent-facing text cause two failure modes: (1) agents working on root-repo files halt or fabricate excuses because the mandated framework doesn't apply to their context; (2) agents foray into the `.opencode` submodule for root-repo changes to satisfy the letter of the mandate, contaminating unrelated submodule state.

## User Intent / Original Prompt

Original bug report intent (issue #372): fix the parent-repo root `AGENTS.md` § Test Framework Discipline so that it carries an explicit repo-scope qualifier — the `.opencode` test framework mandate applies to `.opencode`-targeted (submodule) work only; other work uses a repo-local test instrument and never touches the `.opencode` submodule or its test framework. Tight scope: the AGENTS.md repo-scope qualifier fix only.

## Key Design Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Qualify applicability by work target (`.opencode`-targeted submodule work vs root-repo work) rather than by file path glob | Matches the existing workflow model (submodule discipline), survives file layout changes |
| 2 | Define the root-repo test instrument concretely as `tests/behaviors/*.sh` (existing in-repo behavioral test scripts) rather than the non-deterministic phrase "strongest available in-repo test instrument" | Deterministic agent instructions; the phrase was rejected by structural validation as non-deterministic |
| 3 | Keep qualifier text inside the existing § Test Framework Discipline heading — no new sections, no restructure | Minimal blast radius; text-only edit |

## Requirements

| # | Requirement | Rationale (traceability) |
|---|-------------|--------------------------|
| R-1 | Root `AGENTS.md` § Test Framework Discipline gains an explicit repo-scope qualifier distinguishing `.opencode`-targeted (submodule) work from root-repo (non-submodule) work | Problem Statement; Decision 1 |
| R-2 | The qualifier states the canonical `.opencode` framework (`with-test-home`, `opencode run`, `tests-v2`) applies to `.opencode`-targeted work only | Problem Statement failure mode 2; Decision 1 |
| R-3 | The qualifier states root-repo work uses the in-repo test instrument `tests/behaviors/*.sh` and MUST NOT touch the `.opencode` submodule or its test framework | Problem Statement failure mode 1; Decision 2 |
| R-4 | The change modifies only root `AGENTS.md`; no `.opencode/` file is modified | Out-of-scope guard; Impact |

## Alternatives Considered

| # | Alternative | Why rejected |
|---|-------------|--------------|
| 1 | Delete the Test Framework Discipline section from root AGENTS.md entirely | Loses the non-waivable rules (`timeout` prohibition, submodule pointer updates) that DO apply to root-repo work |
| 2 | Mirror the full tests-v2 framework into the root repo | Creates duplicate tooling — explicitly out of scope; contradicts Decision 2 |
| 3 | Use the phrase "strongest available in-repo test instrument" | Non-deterministic — undefined "strongest"; rejected by validation iteration 1 |

## Not Included

- Any change to `.opencode/AGENTS.md` or any `.opencode/` file (deck-side fix: michael-conrad/.opencode#2469)
- Creating new test tooling or modifying the test framework
- Changes to any root `AGENTS.md` section other than § Test Framework Discipline

## Success Criteria

| # | Success Criterion | Evidence Type | Evidence Source | Documentation Sources | Cost Frame |
|---|-------------------|---------------|-----------------|-----------------------|------------|
| SC-1 | Root `AGENTS.md` § Test Framework Discipline contains a repo-scope qualifier that (a) distinguishes `.opencode`-targeted (submodule) work from root-repo work, (b) states the canonical framework applies to `.opencode`-targeted work only, and (c) names `tests/behaviors/*.sh` as the root-repo test instrument and states root-repo work MUST NOT touch the `.opencode` submodule or its test framework | structural | `read` of `AGENTS.md` § Test Framework Discipline at commit: qualifying text present, containing the three specified elements (a), (b), (c) | `.issues/372/spec.md` (this spec); root `AGENTS.md` § Test Framework Discipline | O(1) — single file read on the changed section |
| SC-2 | The change commit modified only root `AGENTS.md` and no file under `.opencode/` | structural | `git diff --stat <base>..HEAD` at commit: exactly one changed path, `AGENTS.md` (root) | `.issues/372/spec.md`; `git diff` output | O(Δ) — proportional to commit diff size |

**SC decomposition notes (validation iteration 1 remediation):** former SC-2 (framework-applies-only-to-`.opencode` ceremony) folded into SC-1 element (b) — it is entailed by SC-1 and is not independently testable. Former SC-3 (compound, non-deterministic "strongest available in-repo test instrument") decomposed into SC-1 elements (a)-(c) with the instrument now deterministically defined (`tests/behaviors/*.sh`) per Decision 2. Former SC-4 (disjunctive "no other sections of AGENTS.md or any `.opencode/` file") split into SC-2's single verifiable diff criterion.

## Items

| Item | Related SC(s) |
|------|---------------|
| ITEM-1: Edit root `AGENTS.md` § Test Framework Discipline to insert the repo-scope qualifier text per R-1/R-2/R-3 | SC-1, SC-2 |

## Dependencies

| Dependency | Type | Detail |
|------------|------|--------|
| michael-conrad/.opencode#2469 | informational | Deck-side counterpart (same defect family); merged independently — no runtime coupling to this change |

## Traceability

| Requirement | SC | Item | Verification |
|-------------|----|------|--------------|
| R-1 | SC-1 (a) | ITEM-1 | `read` of AGENTS.md section |
| R-2 | SC-1 (b) | ITEM-1 | `read` of AGENTS.md section |
| R-3 | SC-1 (c) | ITEM-1 | `read` of AGENTS.md section |
| R-4 | SC-2 | ITEM-1 | `git diff --stat` |

## Documentation Sources

| Source | Role |
|--------|------|
| Root `AGENTS.md` § Test Framework Discipline (lines 45–92 at revision time) | Target file, authoritative current text |
| `.issues/372/spec.md` | This spec — source of truth for intent |
| michael-conrad/.opencode#2469 | Precedent for the same defect family (deck-side fix) |

## Enforcement Gate

Behavioral agent-facing text change: verify no skill-enforcement regression by running `bash .opencode/tests-v2/test-enforcement.sh` BEFORE and AFTER the AGENTS.md edit, confirming the enforcement suite is unaffected by the text-only change (the test framework itself is out of scope; the run is regression evidence, not a framework change). The behavioral variant does not apply — this is a text-scoping fix, not a new rule requiring behavioral RED/GREEN; SC-1/SC-2 use structural evidence because the change is static agent-facing text with no runtime semantics.

## Cost Frame

- **Complexity:** O(1) text edit in one file section (agent-facing markdown only).
- **Resource cost in verification decisions:** Not a factor (cost-blind verification mandate — `080-code-standards.md`); the enforcement-suite regression run above is justified by scope containment, not cost.
- **Blast radius:** One file section; no runtime code; no submodule changes.

## Edge Cases

| # | Case | Handling |
|---|------|----------|
| 1 | An agent makes a change to both root files and `.opencode` in one task | The qualifier applies per work target: `.opencode`-targeted portions follow the canonical framework; root-repo portions follow `tests/behaviors/*.sh`; the existing submodule-discipline rules (pointer sync) still govern the submodule portion |
| 2 | Submodule pointer is dirty while making a root-repo edit | Pointer sync rules in § Test Framework Discipline / § Submodule Pointer Updates are unchanged by this fix — the qualifier does not weaken pointer discipline |
| 3 | Agent runs tests for root-repo changes and finds no script match in `tests/behaviors/` | The invariant is the sub-touch prohibition: the agent verifies with direct commands and MUST NOT reach into `.opencode/tests-v2` — the qualifier states the prohibition explicitly |

## Impact

- **Affected files:** `AGENTS.md` (root, § Test Framework Discipline)
- **Blast radius:** Agent-facing text only — no runtime code, no test framework changes, no submodule changes.
- **Downstream unblocks:** Plan creation for this issue was blocked on `NO_SUCCESS_CRITERIA`; this revision adds the SCs required to proceed.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-28 | Initial spec body composed during retroactive import revision | Pipeline-initiated continuation under approved-for-pr (#372): retroactively imported spec body contained zero success criteria; SCs derived from bug statement to unblock plan creation | Developer authorization label `approved-for-pr` (pipeline-initiated, non-substantive revision exemption, approval-gate-008 exception class) |
| 2026-09-28 | Validation-iteration-1 revision: added required template sections (Root Cause/Motivation, User Intent/Original Prompt, Key Design Decisions, Requirements, Alternatives Considered, Not Included, Items, Dependencies, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, Edge Cases); added Documentation Sources and Cost Frame columns to SC table; folded former SC-2 into SC-1; decomposed former SC-3 into atomic SC-1 elements with deterministic in-repo test instrument (`tests/behaviors/*.sh`); split former SC-4 into single verifiable SC-2 | Structural validation FAIL findings (iteration 1) listed in revision_reason: missing template sections; SC table missing Documentation Sources column and per-SC cost frames; SC-3 compound/non-deterministic; SC-4 disjunctive; SC-2 ceremony entailed by SC-1 | `approved-for-pr` (#372) — pipeline-initiated validation gate, automatic revise→validate loop |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)