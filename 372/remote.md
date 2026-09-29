## Spec Reference Blockquote

> **Spec:** `[BUG] Root AGENTS.md Test Framework Discipline lacks repo-scope qualifier` — opencode-config #372. `approved-for-pr`. Source of truth: `.issues/372/spec.md` (local, authoritative). Remote mirror: https://github.com/michael-conrad/opencode-config/issues/372

## Problem

Root `AGENTS.md` § Test Framework Discipline states "All test execution MUST use the canonical test framework" with no repo-scope qualifier. Read universally, it directs agents making non-`.opencode` changes to use the `.opencode` tests-v2 framework (`with-test-home`, `opencode run` behavioral testing) — but that framework exists only in the `.opencode` deck repo and applies only to `.opencode`-targeted work. Failure modes: fabricated availability excuses; inappropriate forays into the `.opencode` submodule for unrelated root-repo changes. Same defect family fixed on the deck side by michael-conrad/.opencode#2469.

**Evidence:** `grep -n "All test execution" AGENTS.md` — line present, no scope qualifier (verified).

## Scope

In scope: add a repo-scope qualifier to root `AGENTS.md` § Test Framework Discipline — the canonical `.opencode` framework applies to `.opencode`-targeted (submodule) work only; root-repo work uses `tests/behaviors/*.sh` and SHALL NOT touch the `.opencode` submodule or its test framework. Out of scope: any `.opencode/` file change (deck-side fix: .opencode#2469), new test tooling, framework changes.

## Approach

Revise root `AGENTS.md` § Test Framework Discipline to insert an explicit repo-scope qualifier distinguishing work targets and naming the deterministic root-repo test instrument (`tests/behaviors/*.sh`). Success verified via string evidence (SC-1 qualifier-with-target-distinction, SC-2 framework-applicability statement, SC-3 instrument naming + submodule prohibition — each by `read` of the section) and structural evidence (SC-4: `git diff --stat` shows only root `AGENTS.md` modified, zero `.opencode/` paths). Enforcement Gate is all-or-nothing: all four SCs MUST hold or the SC set is FAIL, with a before/after `bash .opencode/tests-v2/test-enforcement.sh` regression run confirming the enforcement suite is unaffected by the text-only change.

## Impact

- Affected files: `AGENTS.md` (root, § Test Framework Discipline) — agent-facing text only, no runtime code, no submodule changes
- Downstream: unblocks plan creation (previously blocked on `NO_SUCCESS_CRITERIA`)

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
