# Plan Input Verification — opencode-config #372

## Issue state + labels (from local records)

- Issue: opencode-config #372 — "[BUG] Root AGENTS.md Test Framework Discipline lacks repo-scope qualifier"
- Status: open
- Labels (local canonical): `approved-for-pr`
- Remote mirror: https://github.com/michael-conrad/opencode-config/issues/372
- Comments: none (`.issues/372/comments.md` — "(no comments)")
- Authorization scope: `for_pr` → PR strategy: stacked

## SC list with evidence types (from `.issues/372/spec.md`)

| SC | Summary | Evidence Type | Evidence Source |
|----|---------|---------------|-----------------|
| SC-1 | Repo-scope qualifier distinguishing `.opencode`-targeted (submodule) work from root-repo work present in root `AGENTS.md` § Test Framework Discipline | string | `read` of the section |
| SC-2 | Framework-applicability statement (canonical `.opencode` framework applies to `.opencode`-targeted work only) present | string | `read` of the section |
| SC-3 | `tests/behaviors/*.sh` named as root-repo test instrument | string | `read` of the section |
| SC-4 | SHALL NOT submodule-prohibition statement present | string | `read` of the section |
| SC-5 | Commit touched only root `AGENTS.md`, zero paths under `.opencode/` | structural | `git diff --stat <base>..HEAD` |

## Structure artifact mappings (from `.issues/372/artifacts/structure.yaml`)

- Phase 1: "Insert repo-scope qualifier statements into AGENTS.md § Test Framework Discipline" — SC-1..SC-4, ITEM-1..ITEM-4, each with steps [red, green, verify, commit]. depends_on: []. Single-file edits ordered within one phase.
- Phase 2: "Verify commit scope containment" — SC-5, ITEM-5, steps [red, green, verify] (verify-only; no commit). depends_on: [phase-1].
- DAG edge: phase-1 → phase-2 (SC-5 containment requires phase-1 commits).
- Skill/task mapping: red = test-driven-development red; green = test-driven-development green; verify = verification-before-completion verify; commit = orchestrator commit-inline.

## Enforcement Gate extras (from spec)

- Spec requires `bash .opencode/tests-v2/test-enforcement.sh` BEFORE and AFTER the AGENTS.md edit (regression of the text-only change) — this is an authorized `.opencode`-targeted read-run of the framework, permitted by the current AGENTS.md rules for `.opencode`-targeted work; it verifies no skill-enforcement regression. If regressed, SC set FAIL.
- No co-author trailers during implementation commits (added at PR squash time).

## CLI surface flags needed

- Label write (PRIMARY canonical): `./.opencode/tools/local-issues update opencode-config#372 --labels approved-for-pr spec-cleared` — `--labels` REPLACES the whole labels array, so all existing labels (`approved-for-pr`) MUST be included plus new `spec-cleared`.
- Remote label write: best-effort via `gh` — never blocking. Remote issue #372 at michael-conrad/opencode-config.

## Item/SC mapping (spec §Items)

ITEM-1→SC-1, ITEM-2→SC-2, ITEM-3→SC-3, ITEM-4→SC-4, ITEM-5→SC-5. Exactly one SC per item.

## Baseline facts

- Target file: root `AGENTS.md`, section "Test Framework Discipline" (text-only edit; no line anchors).
- Root-repo test instrument: `tests/behaviors/*.sh` scripts exist in the parent repo (verified by directory listing: `tests/behaviors/` contains behavioral test scripts incl. `cost-blind-verification.sh`, `progressive-iterative-gates.sh`).
- Parent repo remote: git@github.com:michael-conrad/opencode-config.git; platform github.com.
- Base branch for PR: main (trunk).