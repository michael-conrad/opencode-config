<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, opencode-config#378; sibling .opencode#2748 -->

# Spec — Release PR: .opencode pointer update, release-gate command declaration, README/CHANGELOG reconciliation

## 1. Intent and Executive Summary

**Problem Statement.** The parent repo's `.opencode` submodule pointer is
behind the deck content it serves (recorded `e1b41776` vs the deck's
checked-out tip, 7+ merged upstream PRs, and advancing further when the
sibling deck spec `.opencode#2748`'s PR merges). The developer directed a
release PR to update the pointers after that deck PR merges. Three
defects stand in its way: (1) the parent README's submodule guidance is
wrong — it instructs dev-branch tracking (the dev branch was removed;
main is the single trunk) and pointer-only commits (parent AGENTS.md
forbids pointer-only commits; pointer updates ride with real parent
changes); (2) the release-promoter clean-room gate cannot resolve
build/test commands for this parent — no declared build manifest, no
session-init per-root build/test facts, no documented build framework —
so the terminal `NO_SOURCE_FAIL` blocks the release PR; (3) the parent
has no other pending real change for the pointer to ride with.

**Root Cause / Motivation.** Pointer drift accumulated under the
rides-with-real-changes discipline (no parent change has landed since the
#2617 conformance commit); the README predates the dev-branch removal;
the release gate's command-source resolution (.opencode#2736, Unreleased)
has never run against this parent, which declares no commands anywhere.

**Approach Chosen.** After the sibling deck PR merges: a release branch
carries (1) the pointer update to the merged deck tip; (2) a parent
AGENTS.md declaration of canonical build/test commands — build:
`cd .opencode && uv sync`, test: `cd .opencode && uv run pytest` — as the
sanctioned manifest source the gate protocol names (the repository's
AGENTS.md); (3) parent README submodule-section corrections; (4) a parent
CHANGELOG entry. The clean-room gate then verifies the pushed branch
(shallow clone, submodule resolve at pinned SHAs, drift assertion,
`uv sync` + `uv run pytest` zero-failure) before the release PR is filed.
Post-merge: drift and tree-identity re-check, annotated v-prefixed tag,
GitHub Release with the changelog body, verified live.

**Alternatives Considered & Why Discarded.**
- *Pointer-only release commit* — discarded: violates the parent
  AGENTS.md pointer discipline (pointer rides with real parent changes);
  also leaves the release gate with no command source.
- *Declare the deck's behavioral harness (with-test-home) as the test
  command* — discarded: behavioral runs are model-executing and
  non-deterministic; the gate needs a zero-failure assertion against a
  deterministic suite. The deck's pytest suite (local-issues + session-init
  tool tests) is that suite.
- *Skip or soften the gate* — discarded: the release-promoter card's
  gate is mandatory and `NO_SOURCE_FAIL` is a real blocking failure; the
  command declaration must land on the release branch, and it is itself
  the real parent change the pointer rides with.
- *Tag the deck repo instead* — discarded: a submodule repository never
  hosts its own release PR or tag; the parent ships the content via
  pointer capture (release-promoter card).

**Key Design Decisions.**
- The command declaration lives in the parent AGENTS.md — the gate
  protocol's first sanctioned source ("its AGENTS.md or an equivalent
  the repository names").
- The commands run in the composed tree against the deck's own
  pyproject (uv-managed, host PATH provides uv — verified; suite
  verified passing at spec time: 194 tests, 30.8s, 2026-11-18). The
  gate's own fallback design sanctions the parent declaring commands
  that live in the submodule manifest, executed through the parent's
  declaration.
- The version number is determined at release time from the changelog
  per the operating protocol (dev suffix stripped; number re-derived
  from the changelog, authoritative over any dev base claim).
- Sequencing: nothing in this spec executes before the sibling deck PR
  merges (human gate); the pointer target is the deck PR's merged SHA,
  not a moving branch tip.

**User Intent / Original Prompt.** "create a spec to track changes then
implement for PR. […] 3. create a release PR to update pointers after
the submodule PR is merged […] re-analyze and report" (developer,
2026-11-18). The deck-side items (1, 2, 4, 5) are the sibling spec
`.opencode#2748`.

## 2. Not Included

- Deck-repo changes of any kind — sibling spec `.opencode#2748`.
- Parent working-tree strays cleanup (`1`, `linux-x64-deb`, empty dirs
  `1968`, `2090`, `issues`) and the `skills/` content tracked at the
  parent top level — observed in analysis, not named by the developer.
- CI/workflow additions (`.github/`) — not named.
- Generic `.gitignore` changes — not named for the parent.

## 3. Requirements

- **R-1**: The parent repository SHALL carry a release PR (per the
  release-promoter pipeline) that updates the `.opencode` submodule
  pointer to the sibling deck PR's merged SHA.
- **R-2**: The same release SHALL carry the real parent changes the
  pointer rides with: (a) a parent AGENTS.md declaration of canonical
  build/test commands — build: `cd .opencode && uv sync`, test:
  `cd .opencode && uv run pytest` — naming them as the repository's
  canonical command source; (b) parent README submodule-section
  corrections (main-branch tracking; rides-with-real-changes pointer
  guidance replacing the pointer-only commit instructions); (c) a parent
  CHANGELOG entry naming the release and the deck PR.
- **R-3**: The clean-room gate SHALL pass on the pushed release branch —
  `CHECKOUT_OK`, per-submodule drift assertion (resolved SHA == pinned
  SHA), `uv sync` and `uv run pytest` zero-failure — with the resolved
  commands and their supplying source recorded, before the release PR
  is filed.
- **R-4**: Post-merge, an annotated v-prefixed tag on the parent trunk's
  merged release commit and a GitHub Release with the changelog body
  SHALL be created and verified live (`gh release view` evidence).

## 4. Success Criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | Release branch/PR diff updates the `.opencode` gitlink to the sibling deck PR's merged SHA | structural | `git diff <trunk>...<release-branch> -- .opencode` shows the gitlink SHA; compare with the deck PR's merge commit |
| SC-2 | Release diff carries the parent AGENTS.md command declaration, the README submodule-section corrections, and the CHANGELOG entry | structural | `git diff --stat` file list + content read of the three files on the release branch |
| SC-3 | Clean-room gate record states `CHECKOUT_OK`, per-submodule drift pass, and `uv sync` + `uv run pytest` zero-failure with resolved commands and source | structural | gate transcript in the release work record (executed gate output) |
| SC-4 | Post-merge: annotated v-prefixed tag exists on the merged release commit and the GitHub Release exists with the changelog body | structural | `git tag -l -n` (annotated, correct SHA) + `gh release view` output |

## 5. Dependencies

| Reference | Relationship | Status |
|---|---|---|
| `.opencode#2748` (sibling deck spec) | Sequencing gate: this spec's execution starts after that spec's PR is merged (human merge gate); the pointer target SHA is that PR's merge | pending |
| release-promoter card + operating protocol | Governs the gate, PR body, tag, and release steps | satisfied (deck cards) |
| Parent trunk freshness at execution time | Release branch cut from remote trunk tip per git-workflow-branch | pending (executed at item-3 time) |

## 6. Traceability

| Requirement | Verified by |
|---|---|
| R-1 | SC-1 |
| R-2 | SC-2 |
| R-3 | SC-3 |
| R-4 | SC-4 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| release-promoter SKILL.md + operating-protocol.md | card | `.opencode/skills/release-promoter/` | read, 2026-11-18 |
| Parent release precedent (v0.2.0, PR #362) | git history | parent repo, tag v0.2.0 | `git show v0.2.0 --stat`, `git log --grep release`, 2026-11-18 |
| Parent AGENTS.md / README.md / CHANGELOG.md | documents | parent repo root | read, 2026-11-18 |
| Deck pyproject.toml (pytest suite) | config | `.opencode/pyproject.toml` | read, 2026-11-18 |
| Deck pytest suite execution | execution | `.opencode/tests/` | `uv run pytest` — 194 passed, 30.8s, 2026-11-18 |
| Submodule pointer state | git | parent repo (`git ls-tree HEAD .opencode` = e1b41776; deck checkout 26db2ee96) | executed, 2026-11-18 |
| uv availability | execution | host PATH | `command -v uv` = /home/muksihs/.local/bin/uv, 2026-11-18 |

## 8. Cost Frame

- Gate execution ≈ shallow clone + submodule resolve + `uv sync` +
  pytest (~1–2 minutes total); acting on it ships a release proven from
  a clean room.
- Skipping SC-3: the release promotes an unverified pointer — the exact
  failure class the gate exists to catch (DRIFT/BUILD failures ship
  broken consumption layouts).
- Skipping SC-2's README correction: every reader keeps being instructed
  to violate the repo's own pointer discipline and to track a removed
  branch.
- Skipping SC-4's live verification: tag/release drift goes undetected
  (partial-state duplicates per the card's no-retry rule).

## 9. Edge Cases

| Condition | Expected behavior |
|---|---|
| Gate hits `DRIFT_FAIL` (deck advances between release-branch push and gate) | Blocked, no retry within the release; pointer re-captured on a fresh release branch from the trunk tip |
| `uv run pytest` fails in the clean room | `BUILD_FAIL` blocks; no PR filed until the deck suite passes at the pinned pointer; routed to the owning ticket, not worked around |
| `TREE_MISMATCH` at post-merge re-check | No tag; release stops for developer direction per the card |
| Deck PR not yet merged when this spec's execution starts | Halt at the dependency — sequencing gate (SC-1's target SHA must exist as a merge) |
| uv not on PATH in the gate environment | Environment/transport setup defect (not a release blocker): diagnosed and the gate re-run with uv available |

## 10. Completion Gate

Every success criterion passes before the deliverable is complete;
partial implementation is not permitted. The tag and GitHub Release
(SC-4) exist only after the release PR's human merge — that ordering is
the card's, and no criterion is waived by it.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3)
