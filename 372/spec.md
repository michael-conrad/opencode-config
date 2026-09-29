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

## Approach Chosen

Insert a repo-scope qualifier into root `AGENTS.md` § Test Framework Discipline that (a) distinguishes `.opencode`-targeted (submodule) work from root-repo (non-submodule) work, (b) states the canonical `.opencode` framework applies to `.opencode`-targeted work only, and (c) names `tests/behaviors/*.sh` as the root-repo test instrument with a SHALL NOT prohibition on touching the `.opencode` submodule or its test framework. The change is a text-only edit to one section of one file.

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
| R-1 | Root `AGENTS.md` § Test Framework Discipline SHALL contain an explicit repo-scope qualifier distinguishing `.opencode`-targeted (submodule) work from root-repo (non-submodule) work | Problem Statement; Decision 1 |
| R-2 | The qualifier SHALL state that the canonical `.opencode` framework (`with-test-home`, `opencode run`, `tests-v2`) applies to `.opencode`-targeted work only | Problem Statement failure mode 2; Decision 1 |
| R-3 | The qualifier SHALL state that root-repo work uses the in-repo test instrument `tests/behaviors/*.sh` and root-repo work SHALL NOT touch the `.opencode` submodule or its test framework | Problem Statement failure mode 1; Decision 2 |
| R-4 | The change SHALL modify only root `AGENTS.md`; no `.opencode/` file shall be modified | Out-of-scope guard; Impact |

**RFC 2119 keyword convention:** SHALL = mandatory; SHALL NOT = absolute prohibition; MAY = optional. Keywords are uppercase in Requirements and Success Criteria.

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
| SC-1 | Root `AGENTS.md` § Test Framework Discipline contains a repo-scope qualifier distinguishing `.opencode`-targeted (submodule) work from root-repo (non-submodule) work | string | `read` of `AGENTS.md` § Test Framework Discipline at commit: the qualifying scoped text is present in the section (content-presence check against spec wording) | `.issues/372/spec.md` (this spec); root `AGENTS.md` § Test Framework Discipline | Action cost: one targeted text edit and one `read` of the section. Skipping cost: the qualifier is absent and an agent performing root-repo work is directed to a framework that does not exist in its context, producing fabricated excuses or `.opencode` submodule forays. Consequence: unscoped mandate persists, reproducing the defect family fixed by michael-conrad/.opencode#2469. |
| SC-2 | The qualifier states that the canonical `.opencode` framework (`with-test-home`, `opencode run`, `tests-v2`) applies to `.opencode`-targeted work only | string | `read` of `AGENTS.md` § Test Framework Discipline at commit: the framework-applicability statement is present in the section (content-presence check against R-2 wording) | `.issues/372/spec.md`; root `AGENTS.md` § Test Framework Discipline | Action cost: one text edit adding the applicability statement and one `read` to verify presence. Skipping cost: the mandate remains universal and root-repo agents foray into the `.opencode` submodule to satisfy the letter of the rule. Consequence: contamination of unrelated submodule state per Problem Statement failure mode 2. |
| SC-3 | The qualifier names `tests/behaviors/*.sh` as the root-repo test instrument | string | `read` of `AGENTS.md` § Test Framework Discipline at commit: the instrument name `tests/behaviors/*.sh` is present in the section (content-presence check against R-3 wording) | `.issues/372/spec.md`; root `AGENTS.md` § Test Framework Discipline | Action cost: one text edit adding the instrument name and one `read` to verify presence. Skipping cost: root-repo behavior remains unspecified, so agents run tests without any defined instrument. Consequence: fabricated-availability excuses per Problem Statement failure mode 1. |
| SC-4 | The qualifier states that root-repo work SHALL NOT touch the `.opencode` submodule or its test framework | string | `read` of `AGENTS.md` § Test Framework Discipline at commit: the submodule-prohibition statement is present in the section (content-presence check against R-3 wording) | `.issues/372/spec.md`; root `AGENTS.md` § Test Framework Discipline | Action cost: one text edit adding the prohibition and one `read` to verify presence. Skipping cost: agents reach into `.opencode/tests-v2` for unrelated root-repo work. Consequence: submodule contamination per Problem Statement failure mode 1. |
| SC-5 | The change commit modified only root `AGENTS.md` and no file under `.opencode/` | structural | `git diff --stat <base>..HEAD` at commit (file-existence-level check): exactly one changed path, `AGENTS.md` (root); zero paths under `.opencode/` | `.issues/372/spec.md`; `git diff` output | Action cost: one scoped commit and one `git diff --stat` run. Skipping cost: scope containment of R-4 is unverified and the edit could silently reach into `.opencode/`. Consequence: unauthorized deck-repo mutation — the exact contamination this fix is written to prevent. |

**SC decomposition notes (validation iteration 3 remediation):** former compound SC-3 (instrument naming AND submodule prohibition joined in one row) split into atomic SC-3 (instrument naming — `tests/behaviors/*.sh` named as root-repo test instrument) and SC-4 (submodule prohibition — SHALL NOT touch `.opencode` submodule or its test framework); the existing diff-scope SC renumbered SC-4 → SC-5. Iteration 2 remediation remains in force: former compound SC-1 (elements a/b/c in one row) decomposed into atomic SC-1 (element a — qualifier-present-with-target-distinction) and SC-2 (element b — framework-applicability statement). Evidence types: SC-1/SC-2/SC-3/SC-4 are content-presence checks verified by reading file text — declared **string** (not structural); SC-5 is a file-existence-level diff check and remains **structural**.

## Items

> Per spec-structure-standards §3: each SC maps to exactly one item; no item covers multiple SCs. Per §5: each item carries the RED/GREEN/verify/commit format.

### ITEM-1: Insert repo-scope qualifier distinguishing work targets into root `AGENTS.md` § Test Framework Discipline

Related SC: SC-1

| Phase | Detail |
|-------|--------|
| RED | `read` of `AGENTS.md` § Test Framework Discipline: assert the repo-scope qualifier distinguishing `.opencode`-targeted (submodule) work from root-repo (non-submodule) work is absent — assertion FAILS the presence check (change not yet made), establishing RED |
| GREEN | Edit root `AGENTS.md` § Test Framework Discipline to insert the repo-scope qualifier text per R-1; re-run `read` presence check — assertion passes, establishing GREEN |
| Verify | SC-1 string-evidence check: `read` of the section confirms the qualifier distinguishing `.opencode`-targeted work from root-repo work is present |
| Commit | Commit the qualifier text edit scoped to root `AGENTS.md` |

### ITEM-2: Insert framework-applicability statement into root `AGENTS.md` § Test Framework Discipline

Related SC: SC-2

| Phase | Detail |
|-------|--------|
| RED | `read` of `AGENTS.md` § Test Framework Discipline: assert the statement "canonical `.opencode` framework applies to `.opencode`-targeted work only" is absent — assertion FAILS the presence check (change not yet made), establishing RED |
| GREEN | Edit root `AGENTS.md` § Test Framework Discipline to add the framework-applicability statement per R-2; re-run `read` presence check — assertion passes, establishing GREEN |
| Verify | SC-2 string-evidence check: `read` of the section confirms the framework-applicability statement is present |
| Commit | Commit the applicability statement edit scoped to root `AGENTS.md` |

### ITEM-3: Name `tests/behaviors/*.sh` as the root-repo test instrument in root `AGENTS.md` § Test Framework Discipline

Related SC: SC-3

| Phase | Detail |
|-------|--------|
| RED | `read` of `AGENTS.md` § Test Framework Discipline: assert the instrument name `tests/behaviors/*.sh` is absent from the section — assertion FAILS the presence check (change not yet made), establishing RED |
| GREEN | Edit root `AGENTS.md` § Test Framework Discipline to name the in-repo test instrument per R-3; re-run `read` presence check — assertion passes, establishing GREEN |
| Verify | SC-3 string-evidence check: `read` of the section confirms `tests/behaviors/*.sh` is named as the root-repo test instrument |
| Commit | Commit the instrument-naming edit scoped to root `AGENTS.md` |

### ITEM-4: Insert SHALL NOT submodule-prohibition statement into root `AGENTS.md` § Test Framework Discipline

Related SC: SC-4

| Phase | Detail |
|-------|--------|
| RED | `read` of `AGENTS.md` § Test Framework Discipline: assert the SHALL NOT submodule-prohibition statement is absent — assertion FAILS the presence check (change not yet made), establishing RED |
| GREEN | Edit root `AGENTS.md` § Test Framework Discipline to add the prohibition per R-3; re-run `read` presence check — assertion passes, establishing GREEN |
| Verify | SC-4 string-evidence check: `read` of the section confirms the submodule-prohibition statement is present |
| Commit | Commit the prohibition edit scoped to root `AGENTS.md` |

### ITEM-5: Verify commit scope containment (diff check)

Related SC: SC-5

| Phase | Detail |
|-------|--------|
| RED | Run `git diff --stat <base>..HEAD`: assert changes exist only in root `AGENTS.md` and zero paths under `.opencode/`; with commits from ITEM-1..4 unverified, the containment assertion is not yet demonstrated — establishing RED |
| GREEN | Ensure all edits are committed scoped to root `AGENTS.md` only; re-run `git diff --stat <base>..HEAD` — containment assertion passes, establishing GREEN |
| Verify | SC-5 structural-evidence check: `git diff --stat <base>..HEAD` shows exactly one changed path, root `AGENTS.md`, and zero `.opencode/` paths |
| Commit | No additional commit required (verification item); the diff check validates the single-file scope of R-4 |

## Dependencies

| Dependency | Type | Detail |
|------------|------|--------|
| michael-conrad/.opencode#2469 | informational | Deck-side counterpart (same defect family); merged independently — no runtime coupling to this change |

## Traceability

| Requirement | SC | Item | Verification |
|-------------|----|------|--------------|
| R-1 | SC-1 | ITEM-1 | `read` of AGENTS.md section (string) |
| R-2 | SC-2 | ITEM-2 | `read` of AGENTS.md section (string) |
| R-3 | SC-3 | ITEM-3 | `read` of AGENTS.md section (string — instrument naming) |
| R-3 | SC-4 | ITEM-4 | `read` of AGENTS.md section (string — submodule prohibition) |
| R-4 | SC-5 | ITEM-5 | `git diff --stat` (structural) |

## Documentation Sources

| Source | Role |
|--------|------|
| Root `AGENTS.md` § Test Framework Discipline (lines 45–92 at revision time) | Target file, authoritative current text |
| `.issues/372/spec.md` | This spec — source of truth for intent |
| michael-conrad/.opencode#2469 | Precedent for the same defect family (deck-side fix) |

## Enforcement Gate

ALL of the following MUST hold or the SC set is FAIL — no partial PASS, no advisory:

1. SC-1 MUST be verified by string evidence: `read` of `AGENTS.md` § Test Framework Discipline shows the repo-scope qualifier distinguishing `.opencode`-targeted work from root-repo work.
2. SC-2 MUST be verified by string evidence: the applicability statement — canonical `.opencode` framework applies to `.opencode`-targeted work only — is present in the section.
3. SC-3 MUST be verified by string evidence: `tests/behaviors/*.sh` is named as the root-repo test instrument.
4. SC-4 MUST be verified by string evidence: the SHALL NOT submodule-prohibition statement is present in the section.
5. SC-5 MUST be verified by structural evidence: `git diff --stat <base>..HEAD` shows exactly one changed path, root `AGENTS.md`, and no `.opencode/` path.

Behavioral agent-facing text change: verify no skill-enforcement regression by running `bash .opencode/tests-v2/test-enforcement.sh` BEFORE and AFTER the AGENTS.md edit, confirming the enforcement suite is unaffected by the text-only change. If the enforcement suite regresses, the SC set is FAIL regardless of string/structural evidence. The behavioral variant does not apply — this is a text-scoping fix, not a new rule requiring behavioral RED/GREEN.

## Cost Frame

| SC | Action cost | Skipping cost | Consequence |
|----|-------------|---------------|-------------|
| SC-1 | One targeted text edit plus one `read` to verify qualifier presence | Scope-distinction text omitted; agent verification skipped | Root-repo agents run tests without a defined instrument, reproducing fabricated-availability excuses |
| SC-2 | One text edit plus one `read` to verify applicability statement | Applicability statement omitted | Universal mandate persists; agents foray into `.opencode` for unrelated root work |
| SC-3 | One text edit plus one `read` to verify instrument name | Instrument name omitted | No defined root-repo test instrument |
| SC-4 | One text edit plus one `read` to verify prohibition | Prohibition omitted | Uncontrolled submodule touching |
| SC-5 | One scoped commit plus one `git diff --stat` | Diff check skipped | Scope containment unverified; unauthorized `.opencode/` changes pass silently |
| Enforcement Gate regression run | Two `test-enforcement.sh` runs (before/after) | Regression run skipped | Skill-enforcement regression ships undetected in the text-only change |

Resource cost in verification decisions is not a factor (cost-blind verification mandate — `080-code-standards.md`).

## Edge Cases

| # | Case | Handling |
|---|------|----------|
| 1 | An agent makes a change to both root files and `.opencode` in one task | The qualifier applies per work target: `.opencode`-targeted portions follow the canonical framework; root-repo portions follow `tests/behaviors/*.sh`; the existing submodule-discipline rules (pointer sync) still govern the submodule portion |
| 2 | Submodule pointer is dirty while making a root-repo edit | Pointer sync rules in § Test Framework Discipline / § Submodule Pointer Updates are unchanged by this fix — the qualifier does not weaken pointer discipline |
| 3 | Agent runs tests for root-repo changes and finds no script match in `tests/behaviors/` | The invariant is the sub-touch prohibition: the agent verifies with direct commands and SHALL NOT reach into `.opencode/tests-v2` — the qualifier states the prohibition explicitly |

## Impact

- **Affected files:** `AGENTS.md` (root, § Test Framework Discipline)
- **Blast radius:** Agent-facing text only — no runtime code, no test framework changes, no submodule changes.
- **Downstream unblocks:** Plan creation for this issue was blocked on `NO_SUCCESS_CRITERIA`; this revision adds the SCs required to proceed.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-28 | Initial spec body composed during retroactive import revision | Pipeline-initiated continuation under approved-for-pr (#372): retroactively imported spec body contained zero success criteria; SCs derived from bug statement to unblock plan creation | Developer authorization label `approved-for-pr` (pipeline-initiated, non-substantive revision exemption, approval-gate-008 exception class) |
| 2026-09-28 | Validation-iteration-1 revision: added required template sections (Root Cause/Motivation, User Intent/Original Prompt, Key Design Decisions, Requirements, Alternatives Considered, Not Included, Items, Dependencies, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, Edge Cases); added Documentation Sources and Cost Frame columns to SC table; folded former SC-2 into SC-1; decomposed former SC-3 into atomic SC-1 elements with deterministic in-repo test instrument (`tests/behaviors/*.sh`); split former SC-4 into single verifiable SC-2 | Structural validation FAIL findings (iteration 1) listed in revision_reason: missing template sections; SC table missing Documentation Sources column and per-SC cost frames; SC-3 compound/non-deterministic; SC-4 disjunctive; SC-2 ceremony entailed by SC-1 | `approved-for-pr` (#372) — pipeline-initiated validation gate, automatic revise→validate loop |
| 2026-09-28 | Validation-iteration-2 revision: decomposed compound SC-1 into atomic SC-1/SC-2/SC-3 (elements a/b/c each a verifiable criterion); rewrote R-1/R-2 in RFC 2119 SHALL form and R-3 as SHALL (+SHALL NOT prohibition); added preamble field `Approach Chosen` (completing the 6-field preamble: Problem Statement, Approach Chosen, Root Cause/Motivation, User Intent/Original Prompt, Key Design Decisions, Requirements); rewrote Cost Frame entries in dark-prose-007 format per SC (action cost + skipping cost + consequence) replacing O-notation entries; re-declared evidence types — SC-1/SC-2/SC-3 content-presence checks from structural to string, SC-4 restated as file-existence-level structural diff check; rewrote Enforcement Gate in canonical all-or-nothing statement format (ALL MUST hold or FAIL); added RFC 2119 keyword convention note; R-4 SHALL form | Validation FAIL findings (iteration 2) listed in revision_reason: compound SC-1; Requirements not in RFC 2119 form; missing `Approach Chosen` preamble field; Cost Frame in O-notation not dark-prose-007 format; evidence type mis-declaration (content-presence declared structural); Enforcement Gate not in all-or-nothing format | `approved-for-pr` (#372) — pipeline-initiated validation gate, automatic revise→validate loop |
| 2026-09-28 | Validation-iteration-3 revision: split compound SC-3 (instrument naming AND submodule prohibition) into atomic SC-3 (instrument naming — `tests/behaviors/*.sh` named as root-repo test instrument) and SC-4 (submodule prohibition — SHALL NOT touch `.opencode` submodule or its test framework); renumbered existing diff-scope SC-4 → SC-5 (updating SC table, SC decomposition notes, Items, Traceability, Enforcement Gate, Cost Frame); decomposed ITEM-1 into per-SC items ITEM-1..ITEM-5, one item per SC with the required RED/GREEN/verify/commit format per spec-structure-standards §3 and §5 | Validation FAIL findings (iteration 3) listed in revision_reason: items_sc_mapping — spec-structure-standards §3 requires each SC to map to exactly one item, no item may cover multiple SCs; compound_sc_detection + decomposition_atomicity — SC-3 joined two independently verifiable claims with 'and' | `approved-for-pr` (#372) — pipeline-initiated validation gate, automatic revise→validate loop |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)