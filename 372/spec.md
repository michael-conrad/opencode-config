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

## Scope

| In Scope | Out of Scope |
|----------|--------------|
| Add a repo-scope qualifier to root `AGENTS.md` § Test Framework Discipline | Any change to `.opencode/AGENTS.md` (covered by .opencode#2469) |
| Distinguish which repos the test-framework rules apply to | Changing the test framework itself |
| Clarify that non-`.opencode` work uses the strongest available in-repo test instrument and never touches `.opencode` | Creating new test tooling |

## Approach

Revise root `AGENTS.md` § "Test Framework Discipline" to add an explicit repo-scope qualifier:

- The canonical `.opencode` test framework (`with-test-home`, `opencode run`, `tests-v2`) applies to **`.opencode`-targeted (submodule) work only**.
- Other (root-repo / non-submodule) work uses the strongest available in-repo test instrument and MUST NOT touch the `.opencode` submodule or its test framework.

## Impact

- **Affected files:** `AGENTS.md` (root, § Test Framework Discipline)
- **Blast radius:** Agent-facing text only — no runtime code, no test framework changes, no submodule changes.
- **Downstream unblocks:** Plan creation for this issue was blocked on `NO_SUCCESS_CRITERIA`; this revision adds the SCs required to proceed.

## Success Criteria

| # | Success Criterion | Evidence Type | Evidence Source |
|---|-------------------|---------------|-----------------|
| SC-1 | Root `AGENTS.md` § "Test Framework Discipline" contains a repo-scope qualifier distinguishing `.opencode`-targeted (submodule) work from other (root-repo) work | structural | `grep` / `read` of `AGENTS.md` § Test Framework Discipline showing the qualifier text present |
| SC-2 | The qualifier specifies that the canonical test framework applies to `.opencode`-targeted work only | structural | `read` of `AGENTS.md` showing the ".opencode-only" applicability statement |
| SC-3 | The qualifier specifies that non-`.opencode` work uses the strongest available in-repo test instrument and does not touch the `.opencode` submodule | structural | `read` of `AGENTS.md` showing the non-submodule-work instruction |
| SC-4 | No other sections of `AGENTS.md` or any `.opencode/` file are modified by this fix | structural | `git diff --stat` of the change commit showing only root `AGENTS.md` modified |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-28 | Initial spec body composed during retroactive import revision | Pipeline-initiated continuation under approved-for-pr (#372): retroactively imported spec body contained zero success criteria; SCs derived from bug statement to unblock plan creation | Developer authorization label `approved-for-pr` (pipeline-initiated, non-substantive revision exemption, approval-gate-008 exception class) |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)