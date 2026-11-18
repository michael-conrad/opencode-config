<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, opencode-config#378; spec opencode-config#378 -->

# Plan — Release PR: pointer update + gate command declaration (opencode-config#378)

## 1. Goal

Implements spec `opencode-config#378`: the parent repo's release PR
updating the `.opencode` pointer to the sibling deck PR's merged SHA,
carrying the real parent changes the pointer rides with (AGENTS.md
canonical-command declaration, README submodule-section corrections,
CHANGELOG entry), verified through the release-promoter clean-room gate
before the PR is filed, then tagged and released post-merge.

## 2. Execution surface

Parent repository (`michael-conrad/opencode-config`, workspace root).
Release branch `release/vX.Y.Z` (version derived at execution time from
the changelog per the release-promoter operating protocol), cut from the
remote trunk tip (`main`). Execution begins only after the sibling deck
PR (`.opencode#2748`) merges — the pointer target must exist as a merge.
`uv` is on the host PATH; the test command executes the deck's pytest
suite against the deck's pyproject in the composed clean-room checkout.

## 3. Items

### Item 1 — parent README submodule-section corrections

- **Deliverable**: README.md submodule guidance corrected.
- **RED**: the README instructs dev-branch tracking (removed branch) and
  pointer-only commits (parent AGENTS.md forbids pointer-only commits).
- **GREEN**: main-branch tracking statement (matching `.gitmodules`
  `branch = main`); pointer-only commit instructions replaced with the
  rides-with-real-changes discipline from parent AGENTS.md; structure
  diagram corrected to the tracked layout.
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: grep README for `dev branch` (absent); pointer guidance
  text matches parent AGENTS.md discipline.

### Item 2 — parent AGENTS.md canonical-command declaration

- **Deliverable**: AGENTS.md declares the repository's canonical build
  and test commands.
- **RED**: no canonical build/test command source exists in the parent
  (the release gate's resolution order yields nothing → `NO_SOURCE_FAIL`).
- **GREEN**: a canonical-commands section declaring build
  `cd .opencode && uv sync` and test `cd .opencode && uv run pytest`,
  named as the repository's canonical command source.
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: read the section; commands match the deck pyproject's
  pytest configuration (deterministic tool suite — not the behavioral
  harness).

### Item 3 — parent CHANGELOG entry

- **Deliverable**: CHANGELOG.md Unreleased gains the release entry.
- **RED**: no entry for this release exists.
- **GREEN**: entry naming the pointer update to the deck PR's merged tip,
  the command declaration, the README corrections, referencing
  `.opencode#2748`.
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: read the entry.

### Item 4 — pointer capture on the release branch

- **Deliverable**: the `.opencode` gitlink updated to the deck PR's
  merged SHA, committed with items 1–3 on the release branch.
- **RED**: the parent gitlink does not equal the deck PR's merged SHA
  (`git ls-tree` comparison fails).
- **GREEN**: `git add .opencode` after the deck merge lands (the checkout
  already tracks the deck repo's `main`); committed in the release commit
  together with items 1–3 per the pointer-discipline rule.
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: `git ls-tree HEAD .opencode` == deck PR merge SHA.

### Item 5 — clean-room gate

- **Deliverable**: the release candidate proven from a clean room.
- **RED**: no gate record exists for the release branch.
- **GREEN**: operating-protocol Phase A — shallow clone of the parent
  remote at the release branch, `git submodule update --init --depth 1`,
  per-submodule drift assertion, `cd .opencode && uv sync`, then
  `cd .opencode && uv run pytest`, both zero-failure; record
  `CHECKOUT_OK`, drift outcomes, the resolved commands and their
  supplying source in the release work record.
- **Tier marks**: no authored tests — instrument class is executed
  transcript (fact check).
- **Instrument**: the gate transcript in the release work record; any
  `DRIFT_FAIL`/`BUILD_FAIL`/`NO_SOURCE_FAIL` blocks (no retry within the
  release run).

### Item 6 — release PR

- **Deliverable**: the release PR filed from the verified branch.
- **RED**: no release PR exists for the branch.
- **GREEN**: PR per `git-workflow-pr` with the release-promoter body
  composition — the changelog plus the Submodule-bump section,
  `Closes` lines only where a release issue applies.
- **Tier marks**: no authored tests — instrument class is fact checks.
- **Instrument**: PR view output (diff contains pointer + the three
  parent files).

### Item 7 — post-merge tag and GitHub Release

- **Deliverable**: annotated v-tag and GitHub Release on the merged
  release commit.
- **RED**: no v-tag exists on the merged commit; no release exists.
- **GREEN**: operating-protocol Phase B (shallow clone of merged trunk,
  drift assertion, tree-content-identity re-check against the gate's
  recorded tree), then annotated `v`-prefixed tag at the merged release
  commit and `gh release create` with the changelog body; verify live.
- **Tier marks**: no authored tests — instrument class is fact checks +
  live API verification.
- **Instrument**: `git tag -l -n` (annotated, correct SHA) +
  `gh release view` output.

## 4. Dependency order

Item 1 → Item 2 → Item 3 → Item 4 → Item 5 → Item 6 → Item 7. Items 1–3
are the ride-along parent changes; item 4 captures the pointer into the
same release commit (items 1–4 are one branch state); item 5 gates the
pushed branch; item 6 files the PR only from a gate-clean state; item 7
runs only after the PR's human merge. The whole plan begins only after
the sibling deck PR (`.opencode#2748`) merges — the pointer target in
item 4's GREEN exists only then. No item's RED or GREEN depends on a
later item.

## 5. Traceability

| Item | Implements |
|---|---|
| Item 1 | SC-2 (README corrections) |
| Item 2 | SC-2 (command declaration) |
| Item 3 | SC-2 (CHANGELOG) |
| Item 4 | SC-1 |
| Item 5 | SC-3 |
| Item 6 | SC-1, SC-2 (diff surfaces) |
| Item 7 | SC-4 |

## 6. Verification summary

Items 1–4 and 6 verify through fact checks (read/grep/git) at cycle time;
item 5 verifies through the executed gate transcript (recorded evidence,
deterministic suite — the deck pytest suite, no behavioral model runs);
item 7 verifies through fact checks plus live API verification
(`gh release view`). No authored tests exist in this plan. The PR
carries the gate transcript and instrument outputs.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3)
