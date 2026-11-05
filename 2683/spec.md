<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [SPEC] Restore the submodule tag-pointer discipline in the impacted git-workflow cards

## Problem

On 2026-10-28, the developer stated the standing discipline and reported its loss — **"the agent is always supposed to tag submodules (and push the tags) and record the tags as the submodule pointers in the parent repo. the agent has stopped following this discipline."**

The discipline this spec restores, as the pre-rip deck carried it:

- `attic/skills/git-workflow-branch/tasks/operating-protocol.md` §Tag Convention (Canonical): the hash-permanence tag `<parent-repo>/<issue-number>-<submodule-dir>` pins the submodule SHA; "the tag IS the sync record"; **"Idempotent Tag-if-Untagged Rule:** before removing a feature branch / during branch cleanup, verify the submodule commit SHA is reachable via an existing tag; if not, create the hash-permanence tag."
- `attic/commands/submodule-tag-prework.md`: tag the submodule trunk tip before feature-branch creation — `git tag -a`, `git push origin <tag>`, verify with `git ls-remote --tags`.
- `attic/commands/submodule-verify.md`: the pre-PR gate — every submodule SHA the parent records is reachable via a tag; a FAIL blocks the PR.
- `attic/skills/git-workflow-branch/tasks/pre-work.md`: "the submodule pointer must be updated **to the tagged SHA** before the feature branch is created", and the pointer-commit message template "chore: update submodule pointer to <parent-repo>/<issue-number>-<submodule> tag".

**What the live deck has now:** nothing. The rip-and-replace (#2490) retired the surface that carried this discipline; the replacement submodule rule set (#2563, verified against its store spec on 2026-10-28) re-authored pointer semantics around the remote trunk tip — "up-to-date" is the tracked-branch tip, the ordering gate serializes submodule PRs — but every trace of the tag layer is absent from the loaded surface. `git-workflow-pr` §3 and `release-promoter` come within arm's reach: "a submodule repository never hosts its own release PR, changelog release section, version bump, or tag" — that sentence names release artifacts, but with no hash-permanence carve-out anywhere, the nearest live wording points *away* from the duty instead of carrying it.

**Observed failures** (repo evidence, verified 2026-10-28):

| # | Failure | Evidence |
|---|---------|----------|
| F-1 | Parent pointer bumps record untagged SHAs; the tag-reachability property the old PR gate enforced is broken on the trunk | `ecfc2190`→`8e1861ad2`, `86bf9569`→`c6beaeedd`, `b0bf104d`→`e1b41776` — each: no tag points at the SHA and no tag's history reaches it (`git tag --contains` empty) |
| F-2 | Tag creation and push stopped | Last `opencode-config/*` tag on the submodule remote: `opencode-config/2489` (tag object dated 2026-10-02); deck trunk now 204 commits past it (`git describe` on `a9c65ec4` → `opencode-config/2489-204-ga9c65ec46`) |
| F-3 | The rule text is gone, not merely unfollowed | Zero occurrences of `hash-permanence` / `tag-if-untagged` / the tag convention in `floor.md`, `skills/`, `guidelines/` (grep, 2026-10-28); the canonical text survives only under `attic/` |
| F-4 | Orphaned script instruments survived the rip | `scripts/validate-release-tags.sh` and `scripts/validate-submodule-refs.sh` — referenced only by `README.md` table rows (126–127); the latter still defaults `BRANCH="dev"`, a branch the deck retired; neither hook, card, nor tool invokes them |
| F-5 | The pointer-to-tag repair began before the rip and never landed | Parent branch `feature/2489-pointer-discipline-fix`, commit `fe9916a4` (2026-10-02, "chore: update submodule pointer to opencode-config/2489 tag") — never merged; superseded by the rewrite |
| F-6 | Push reconciliation never fully ran | Seven local-only tags on the `.opencode` clone as of 2026-10-28: `opencode-config/1156`, `1712`, `2334-opencode`, `checkpoint/2334/phase-1-opencode`, `feature/1784-routing-dispatch-gate`, `pre-numbering-fix-20261007`, `pre-rip` (the attic source tag, load-bearing for #2563's adaptation evidence) |

**Break timeline** (mainline pointer bumps; tag status verified per SHA):

| Date | Parent commit | Recorded pointer | Tag status at capture |
|------|---------------|------------------|------------------------|
| 2026-07-29 | `99f46e20` | `ac9aa047` | tagged `opencode-config/2170-2172-2173-2175` |
| 2026-07-30 | `6ed394b9` (v0.2.0) | `aa2426f3` | trunk tip; tag-covered later by ancestry |
| 2026-08-31 | `17865e64` | `9a9d9cde` | tagged `opencode-config/2402`, `2426` |
| 2026-09-17 | `68ce58e8` | `fb75b7ce` | untagged at capture; covered later by ancestry only |
| 2026-09-28 | `91207ee1` | `f0611342` | tagged `opencode-config/372` — last compliant |
| 2026-10-05 | `ecfc2190` | `8e1861ad2` | untagged, unreachable — first break |
| 2026-10-05 | `86bf9569` | `c6beaeedd` | untagged, unreachable |
| 2026-10-15 | `b0bf104d` | `e1b41776` | untagged, unreachable — still the recorded pointer |

**Failure to fix vs failure to catch:** the 2026-09-17 bump recorded an untagged SHA that later tags only covered by ancestry — the historical discipline's backstop (idempotent tag-if-untagged at cleanup) patched reachability but never restored the capture-time invariant. The 2026-10-05 break removed the backstop along with the capture rule, so nothing was left to catch the lapse.

## Scope

Deck surfaces in the `michael-conrad/.opencode` repository, plus the parent repo's git state for current-state repair:

- `skills/git-workflow-branch/SKILL.md` — the tagged-SHA pointer flow at submodule sync and pointer capture (rule 2 and rule 3 surfaces).
- `skills/git-workflow-commit/SKILL.md` — §5 (pointer capture) carries the tagging duty at staging time.
- `skills/git-workflow-pr/SKILL.md` — §2 pre-create checklist (tag-pushed gate) and §4 Submodule-bump body section (per-bump tag naming); §3's release carve-out wording.
- `skills/git-workflow-cleanup/SKILL.md` — the idempotent tag-if-untagged backstop and push reconciliation before feature-branch deletion.
- `skills/release-promoter/SKILL.md` — the hash-permanence/release-tag carve-out wording, so the release-artifact rule reads correctly against discipline tags.
- `scripts/validate-release-tags.sh`, `scripts/validate-submodule-refs.sh` — deleted; `README.md` rows 126–127 removed.
- `tests-v2/` — two behavioral scenarios (SC-5, SC-6 below) on the existing harness.
- `michael-conrad/opencode-config` git state only: one backfill tag on the currently recorded pointer and the push of local-only tags (R-6) — no file changes in the parent repository.

Untouched: `floor.md` (progressive-disclosure constraint — the floor gains nothing), the parent repo's `AGENTS.md` and `guidelines/`, `hooks/`, `tools/`, the `local-issues` tool, every other card, `attic/` (the reference store the restoration reads from), the `release-promoter` clean-room gate mechanics, and any script surface beyond the two deletions named above.

## Requirements

Constraint frame (developer-stated, this session):

1. **No static brittle scripts** — no new script instrument, no resurrection of the retired validators. The developer's standing ruling on scripted deck surfaces (recorded in `.opencode/.issues/2664/spec.md` §Approach: "scripted deck surfaces are the decks that get trashed and replaced, and an agent that has misread an utterance will route around an interlock") disposes of the script-based alternative class.
2. **Progressive disclosure only via the impacted cards** — the discipline's text lives in the cards whose flows carry its decisions; the always-injected floor and the repo-level guides gain nothing.
3. **Holistic** — every observed failure class (F-1..F-6) is dispositioned, not only the headline tag rule.

- **R-1** — The pointer-capture rules (`git-workflow-branch`, `git-workflow-commit`) require the tagged-SHA pointer flow: before a parent commit records a submodule pointer, the recorded SHA carries a pushed annotated hash-permanence tag `<parent-repo>/<issue-number>-<submodule-dir>` — the agent creates the tag if the commit is untagged, pushes it, and verifies it on the remote (`git ls-remote --tags`). The rule states: the tag targets the commit the gitlink records (not the submodule working tree's HEAD), naming follows the directory-name suffix rule, and a present tag is verified, never re-created.
- **R-2** — The parent-repo PR gate (`git-workflow-pr`) blocks PR creation that carries submodule pointer bumps until each recorded pointer SHA's tag is verifiably on the submodule's remote; the Submodule-bump body section names the tag for each bump.
- **R-3** — The cleanup backstop (`git-workflow-cleanup`) runs before feature-branch deletion: the idempotent tag-if-untagged check against every submodule commit the branch work recorded, and push reconciliation for any discipline tag found local-only.
- **R-4** — The release wording (`release-promoter` and `git-workflow-pr` §3) carries the two-way carve-out: hash-permanence tags on submodule commits are agent discipline and not release artifacts; the "a submodule repository never hosts its own release PR … or tag" rule prohibits release artifacts on the submodule and does not prohibit hash-permanence discipline tags.
- **R-5** — `scripts/validate-release-tags.sh` and `scripts/validate-submodule-refs.sh` are deleted through the deck governance retirement gate, with their `README.md` rows; no new script surface carries this discipline.
- **R-6** — Current-state repair in the parent repository `michael-conrad/opencode-config` and its submodule remote: the currently recorded pointer `e1b41776` carries a pushed hash-permanence tag before this work's PR merges, and all seven then-currently local-only tags (F-6) are pushed to the submodule remote.

## Success criteria

| ID | Class | Criterion | Instrument |
|----|-------|-----------|------------|
| SC-1 | structural | The tagged-SHA pointer-capture rule is present in `git-workflow-branch` and `git-workflow-commit` §5, stating the format, create-if-untagged, push, remote verification, and the gitlink-target clarification of R-1 | card-text inspection of the two cards against R-1's stated content |
| SC-2 | structural | `git-workflow-pr` carries the tag-pushed pre-create gate, the per-bump Submodule-bump tag naming, and the two-way release carve-out; `release-promoter` carries its side of the carve-out | card-text inspection of the two cards against R-2 and R-4 |
| SC-3 | structural | `git-workflow-cleanup` carries the idempotent tag backstop and the push reconciliation before branch deletion | card-text inspection against R-3 |
| SC-4 | structural | Both validator scripts and their README rows are gone; no other file under `scripts/`, `tools/`, or `hooks/` is added or modified; `floor.md`, `guidelines/`, the parent `AGENTS.md`, and the parent's tracked files other than the submodule pointer are untouched by the work | worktree diff (changed-file list of the deliverable) + file-tree check |
| SC-5 | behavioral | A supervised run that performs a parent-repo pointer capture: the submodule commit is tagged, the tag is pushed to the submodule's remote, the recorded pointer is the tagged SHA, and the pre-PR gate verifies tag presence on the remote | a real harness run of a new scenario under `tests-v2/` (the `opencode run` instrument, per the `behavioral-testing` card — no grep or static-analysis substitute); evidence is the run transcript and its verdict |
| SC-6 | behavioral (negative) | A pointer capture lacking the pushed tag is caught at the pre-PR gate and remediated (tag created and pushed) before PR creation | the same harness, scenario with the tagged-packet withheld; verdict from the run transcript |
| SC-7 | structural | The backfill tag R-6 names and each of the seven F-6 tags are on the submodule's remote — none of the eight remains local-only | `git ls-remote --tags` on the submodule origin compared against the local tag list for those eight names |

## Traceability

| Observed failure | Dispositioned by |
|------------------|------------------|
| F-1 (untagged recorded pointers) | R-1, R-2, SC-5, SC-6 |
| F-2 (tag creation/push stopped) | R-1, R-6, SC-5, SC-7 |
| F-3 (rule text gone) | R-1..R-4 (card re-admission), SC-1..SC-3 |
| F-4 (orphaned script instruments) | R-5, SC-4 |
| F-5 (stalled fix branch) | Out of scope (named exclusion — the delta is superseded; deletion is a cleanup-stage matter) |
| F-6 (push reconciliation gap) | R-3 (going forward), R-6 (the seven existing), SC-3, SC-7 |

Every root cause the Problem section names is covered: the missing capture-time rule (R-1, SC-1/SC-5), the missing gates (R-2, R-3, SC-2, SC-3, SC-6), the missing carve-out that left the nearest live wording pointing away (R-4, SC-2), the orphaned instruments (R-5, SC-4), and the unreconciled state (R-6, SC-7).

## Approach

Rule text at the decision surfaces, in the cards that already load for those moments — re-admission, not a new mechanism:

1. **`git-workflow-branch`** — rule 2 (trunk freshness) and rule 3 (submodules — real-work sequence) carry the tagged-SHA flow: the pointer the capture commit records is tagged and pushed before the parent commit that carries it, with the idempotent verification.
2. **`git-workflow-commit`** — §5 carries the staging-time duty: a staged pointer's SHA is a pushed tagged SHA; an untagged recorded SHA is created-and-pushed then staged (never staged while unreachable by a pushed tag).
3. **`git-workflow-pr`** — §2 gains the tag-present pre-create item (subsumed naturally next to (d)'s bump existence check) and §4's Submodule-bump section gains per-bump tag naming; §3's release carve-out sentence gains the hash-permanence clarification.
4. **`git-workflow-cleanup`** — before the branch-deletion step, the idempotent tag-if-untagged check plus push reconciliation.
5. **`release-promoter`** — the submodule-artifact sentence gains the same clarification, on its own card.
6. **`tests-v2`** — two scenarios (SC-5 positive path, SC-6 negative path) on the existing harness; scenario mechanics follow the `behavioral-testing` card.
7. **Parent repo state** — the backfill tag on `e1b41776` (name per R-1's format, the parent's issue number for this work) and the seven tag pushes (R-6), performed from the submodule checkout once the submodule's trunk carries them.

The discarded alternative — a validator script (the retired `validate-release-tags.sh`/`validate-submodule-refs.sh` class, or a hook gate) — is disposed by the developer's standing ruling recorded in #2664: scripted deck surfaces are the decks that get trashed and replaced. The restoration is rule text the agent reads at the decision moment plus behavioral evidence that it holds.

## Edge cases

- **Tag collision:** the tag name exists → verify it points at the recorded SHA (or its peel); a name mismatch is reported, never silently re-tagged or renamed.
- **Pull-only submodule origin (#2667):** a tag push cannot succeed where the effective origin rejects pushes; the agent reports the failure and follows the #2667 judgment path — no improvised push, no silent omission.
- **Multiple registered submodules:** R-1 applies per registered submodule; each recorded pointer carries its own tag.
- **Tag timing:** the tag lands after the submodule's own PR merges (so it can be pushed to the merged trunk tip the ordering gate delivers) and before the parent commit that records the pointer.
- **Backfill scope:** retroactive tags apply to the currently recorded pointer only (R-6); superseded historical pointers (`8e1861ad2`, `c6beaeedd`) are not tagged — no active gitlink records them.

## Impact

- **Consumers:** every agent session in every parent/submodule family the deck's git-workflow cards serve; the developer, for whom every recorded submodule pointer stays name-reachable through branch cleanups and release flows; the release flow, whose gate semantics are unchanged.
- **Cost:** one tag create+push+verify step per pointer capture; a bounded check item at PR creation; a bounded backstop step at cleanup.
- **Risk:** added friction at PR creation when the flow is followed late — bounded, because the tag is created at capture time when the discipline is followed, and the gate's evidence is one `git ls-remote --tags` invocation.
- **Second risk:** the rule could be misread as licensing submodule release tags — disposed by R-4's two-way carve-out wording on both cards.
- **Recovery:** additive tags only (deletable), text changes (revertible), and the pre-rip text preserved under `attic/` — no history rewrite anywhere.

## Out of scope

- Deletion of the superseded parent branch `feature/2489-pointer-discipline-fix` — its delta is superseded by this remediation; deletion is a cleanup-stage matter, and the branch is never merged.
- Retroactive tags for superseded historical pointers (`8e1861ad2`, `c6beaeedd`).
- Any hook change, new tool, new command, or threshold.
- The dated `opencode-config/v*-submodule` tag flavor — an observed pre-break variant, not adopted canonically.
- Changes to `tests-v2` beyond the two scenarios this spec calls for.
- Hook re-verification of the #2313/#2264 gate era — the merged-commit reachability property is carried by the live ordering gate (`git-workflow-pr` §2(f)), and this spec does not re-open it.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2683/

Artifacts for agents: `.opencode/.issues/2683/`.