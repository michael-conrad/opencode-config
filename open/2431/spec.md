## Intent and Executive Summary

1. **Problem Statement:** The stacked-PR workflow has no ordering gate requiring a parent-repo stacked PR to wait for its in-scope submodule PRs to merge first. The pipeline creates parent PRs whose commit predates the submodule merges and carries stale submodule pointers — an open, structurally incomplete PR whose tree resolves pre-fix submodule SHAs and is unmergeable as-is. This fired for real during Butter #304 and slipped through every existing pipeline gate.

2. **Root Cause / Motivation:** The stacked-PR procedure (git-workflow-pr pr-creation + executing-plans post-implementation + writing-plans completion guidance) has no ordering gate and no pre-PR assertion that `git submodule status` is clean and each recorded pointer SHA is merged on the submodule's remote trunk. The reachability gates from #2313 do not cover this: they verify committed pointers are reachable from the remote trunk, but the #304 parent branch was created BEFORE the submodule merges existed anywhere to point to — and nothing forced parent PR creation to follow them. Masking factors let it pass: a locally green composite build (working tree had submodules on feature branches; recorded pointers were stale) and mergeability checks that verify ancestry, not pointer freshness. It must be solved now because every multi-submodule release re-exposes the defect.

3. **Approach Chosen:** Introduce a three-condition ordering gate, evaluated immediately before parent stacked PR creation, hosted as exactly one authoritative blocking check in pr-creation/enforcement-gate. Condition 1: enumerate the in-scope submodule set from the parent branch's changed submodule paths and verify each corresponding submodule PR merged via a live platform API call, with a bounded retry that blocks on inconclusive state. Condition 2: submodule pointer bumps committed on the parent feature branch after the merges land (pointers-ride-alongside). Condition 3: `git submodule status` shows no `+` prefixes and each in-scope pointer SHA is an ancestor of the submodule's remote trunk (`origin/$DEFAULT_BRANCH`). While waiting, the parent branch sits idle.

4. **Alternatives Considered & Why Discarded:**
   - **Merge-base-only pre-PR check (ancestry against remote trunk):** discarded — ancestry verifies reachability, not merge state. The #304 parent PR passed existing ancestry-style checks while its pointers referenced unmerged SHAs; the defect is precisely that ancestry and merge state diverge pre-merge.
   - **Fail-open on inconclusive API state (treat network error or null mergeable as pass):** discarded — it converts "unknown merge state" into silent pass, which is the exact failure mode this gate exists to close. Inconclusive state blocks with a clear reason instead.
   - **Auto-bump parent pointers immediately after submodule merges land:** discarded — pointer-only parent commits/PRs are prohibited (Submodule-Bump-Only PR Gate) and pointer bumps ride alongside the next real parent change per the established pointers-ride-alongside convention; automation here would create forbidden pointer-only branches.

5. **Key Design Decisions:**
   - **D-1 — Single authoritative blocking check at pr-creation/enforcement-gate.** Selection criteria: the site must execute on every path to parent PR creation, must run after commits exist, must already own PR-creation blocking authority, and must fail closed on inconclusive state. pr-creation/enforcement-gate satisfies all four; the other three candidate sites fail at least one and remain advisory. Tradeoff: pre-commit feedback is advisory-only, so a stale pointer can surface later than at commit time — accepted because commit-time blocking of pointer bumps to unmerged SHAs is already governed by #2313 semantics.
   - **D-2 — Live-API merge verification with bounded retry.** Merge state is verified via live platform API (never inferred from local state or ancestry); inconclusive state is probed up to 3 times at 60-second intervals, then blocks with a clear reason. Tradeoff: adds bounded latency and can false-block while platform state lags — accepted over guessing, which ships unmergeable parent PRs.
   - **D-3 — Fail-closed for this gate.** Unlike the #2313 reachability gates (which fail open on network error), this gate blocks on unverifiable state. Tradeoff: a flaky network blocks PR creation until state is verifiable — accepted because a stale-pointer parent PR is unmergeable as-is, so passing under uncertainty defeats the PR's purpose.
   - **D-4 — Pointers-ride-alongside timing rule.** Pointer bumps are committed on the parent feature branch after the submodule merges land. Tradeoff: the parent branch idles until the last submodule merge — the cost of a mergeable parent PR.
   - **D-5 — #2313 terminology alignment.** Pointer ancestry is asserted against the submodule's remote trunk `origin/$DEFAULT_BRANCH` (dynamically resolved per submodule), not a hardcoded `master`, matching the #2313 gate convention and multi-repo reality where submodules use different trunk names.

6. **User Intent / Original Prompt:** Developer Q&A during Butter #304 cleanup — developer: "why are the pointers stale for the root repo PR?" then "why did you create a PR for a root repo with submodules with pending merges that you didn't have the hashes for?" The spec was filed to make that failure structurally impossible.

## Verified Instance and Masking Factors

During Butter repo issue #304 (Flyway unification spanning DaoCore2, SHARED-DAO, ClinicalTrialsAactDb, ButterApi submodules), the post-implementation stage batch-created 5 PRs: 4 submodule PRs + 1 parent stacked PR (NewSRX-Tech-LLC/Butter #308) while ALL 4 submodule PRs were open/unmerged. The parent branch's only commit predated the submodule merges and carried stale submodule pointers (the commit had legitimately used the hook-documented SKIP_STALE_POINTER_CHECK=1 because pointer bumps to unmerged feature-branch SHAs were illegal at commit time). Result: an open parent PR with a tree resolving pre-fix submodule SHAs — unmergeable as-is.

Two factors let this pass the pipeline's existing checks:

1. **Pre-PR composite build ran green** because the local checkout had submodules checked out on their feature branches — the working tree was correct while the recorded pointers were stale. A local build proves nothing about what the PR tree resolves to.
2. **Mergeability checks used `git merge-base --is-ancestor` against the trunk** — this verifies ancestry, not pointer freshness.

## Scope

- Add a mandatory ordering gate to the stacked-PR flow: parent stacked PR is created only after every in-scope submodule PR is verified merged via live platform API
- Define the in-scope submodule set enumeration mechanism: submodule paths whose pointer changes on the parent feature branch relative to the trunk base; each changed submodule's feature-branch PR is resolved via the submodule repo's live API
- Define the bounded retry/report parameters for inconclusive merge state: up to 3 probes at 60-second intervals, then block with a clear reason reported in chat naming the inconclusive submodule PR
- Require submodule pointer bumps to be committed on the parent feature branch after the merges land (pointers-ride-alongside rule), so the parent PR commit carries fresh pointers
- Add pre-PR assertions: clean `git submodule status` (no `+` prefix) for in-scope submodules and pointer-SHA ancestry to `origin/$DEFAULT_BRANCH`
- Evaluate enforcement placement across the four candidate sites with published selection criteria and select the authoritative site in this spec

## Not Included

- **Automatic submodule PR creation or cleanup** — the gate verifies merge state only; submodule PR lifecycle automation is a separate concern with its own failure modes
- **Changes to submodule pointer commit mechanics (SKIP_STALE_POINTER_CHECK semantics at commit time)** — the hook-documented escape hatch remains correct at commit time, when pointers legally target unmerged feature-branch SHAs; this spec moves the freshness assertion to pre-PR creation, where merges have landed
- **Human merge behavior** — merging remains human-only; the gate observes merge state via API and never performs or requests merges
- **Non-stacked (single-repo) PR flows** — repos with no submodules have no in-scope set, the gate skips entirely, and single-repo PR flow behavior is unchanged

## Approach

Introduce a three-condition ordering gate into the stacked-PR procedure, evaluated immediately before parent stacked PR creation.

**Condition 1 — merge-state verification.** The gate enumerates the in-scope submodule set from the parent feature branch's changed submodule paths (gitlink changes relative to the trunk base). For each changed submodule, the gate resolves the submodule's feature-branch PR via the submodule repository's live platform API and verifies merge state using the API's merge-state fields (`merged`, `merged_at`). Merge state is never inferred from local checkout state or from `git merge-base` ancestry. On inconclusive state (API unreachable, `mergeable` still computing, PR not found for the branch), the gate probes up to 3 times at 60-second intervals; if still inconclusive, it blocks PR creation and reports the reason in chat, naming the inconclusive submodule and its PR.

**Condition 2 — pointers-ride-alongside.** Submodule pointer bumps are committed on the parent feature branch after the submodule merges land, so the parent PR's squashed commit carries fresh pointers. The parent branch sits idle while waiting: no new commits, no pushes, no PR mutations until all in-scope submodule PRs land.

**Condition 3 — pointer freshness assertions.** The gate asserts `git submodule status` shows no `+` prefixes for in-scope submodules and asserts each in-scope recorded pointer SHA is an ancestor of the submodule's remote trunk `origin/$DEFAULT_BRANCH` (dynamically resolved per submodule, matching the #2313 gate convention).

**Placement evaluation across the four candidate enforcement sites.** Selection criteria: (a) the site executes on every path to parent PR creation; (b) the site runs after parent commits exist, so committed state is verifiable; (c) the site already owns blocking authority over PR creation; (d) the site can fail closed on inconclusive state. Evaluation: pr-creation/enforcement-gate satisfies all four — it is the mandatory gate every parent PR passes through immediately before creation (precedent: its existing Step 0 and Step 0.5 blocking gates), it inspects committed state, and it reports BLOCKED results that stop PR creation. git-workflow-branch pre-commit-pointer-check fails (b) and (c): it runs pre-commit, before merges can be verified, and commits legally proceed under SKIP_STALE_POINTER_CHECK when pointers target unmerged SHAs — it remains an advisory staging-hygiene check. executing-plans post-implementation steps fail (a) and (c): they run only on the standard executing-plans path and push branches without PR-creation authority — they remain advisory. The tests-v2 behavioral test fails (c): it verifies gate behavior but is not a runtime enforcement site — it remains the behavioral evidence instrument. **Selected authoritative site: pr-creation/enforcement-gate** hosts the single authoritative blocking check; the other three sites carry advisory/consistency roles with no blocking authority.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The stacked-PR procedure blocks parent stacked PR creation while any in-scope submodule PR is unmerged | behavioral | Behavioral enforcement test in tests-v2: scenario reaches parent stacked PR creation with one in-scope submodule PR open — assert the gate blocks and no parent PR is created | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` (Step 0 area); https://docs.github.com/en/rest/pulls/pulls#get-if-a-pull-request-has-been-merged |
| SC-2 | The gate enumerates the in-scope submodule set from the parent feature branch's changed submodule paths (gitlink changes relative to the trunk base) before merge verification | string | `grep` the authoritative task card for in-scope-set enumeration language (changed submodule paths relative to the trunk base) | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` |
| SC-3 | The gate verifies each in-scope submodule PR's merge state via a live platform API call and never infers merge state from local checkout state or from `git merge-base` ancestry | string | `grep` the authoritative task card for live-API merge-state verification language and for the prohibition on inferring from local state or ancestry | https://docs.github.com/en/rest/pulls/pulls (merge-state fields `merged`, `merged_at`) |
| SC-4 | Inconclusive API merge state blocks PR creation: the gate probes up to 3 times at 60-second intervals, then blocks with a clear reason reported in chat naming the inconclusive submodule and its PR | string | `grep` the authoritative task card for the bounded-retry parameters (3 probes, 60-second interval) and the inconclusive-block reason reporting destination (chat) | https://docs.github.com/en/rest/pulls/pulls#get-a-pull-request (`mergeable` is null while GitHub computes mergeability in a background job) |
| SC-5 | Submodule pointer bumps are committed on the parent feature branch after the submodule merges land per the pointers-ride-alongside rule, so the parent PR's squashed commit carries fresh pointers | string | `grep` the authoritative task card for the pointers-ride-alongside rule requiring pointer bumps committed after merges land | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` (Pre-Push Submodule Pointer Verification); `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` |
| SC-6 | The gate asserts `git submodule status` shows no `+` prefixes for in-scope submodules before parent stacked PR creation | behavioral | Behavioral enforcement test in tests-v2: scenario reaches parent stacked PR creation with a `+`-prefixed in-scope submodule — assert the gate blocks | `git submodule status` semantics; `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` |
| SC-7 | The gate asserts each in-scope recorded pointer SHA is an ancestor of the submodule's remote trunk `origin/$DEFAULT_BRANCH` before parent stacked PR creation | behavioral | Behavioral enforcement test in tests-v2: scenario reaches parent stacked PR creation with an in-scope pointer referencing a commit absent from `origin/$DEFAULT_BRANCH` — assert the gate blocks | `.opencode/tests-v2/behaviors/fixtures/issues/2313/spec.md` (origin/$DEFAULT_BRANCH convention); `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` (merged-commit reachability) |
| SC-8 | Exactly one authoritative blocking check for the ordering gate is assigned across the four candidate enforcement sites, at the spec-designated site pr-creation/enforcement-gate | semantic | Clean-room sub-agent reads the four enforcement sites and judges that exactly one authoritative blocking check is assigned (pr-creation/enforcement-gate) | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` |
| SC-9 | The remaining three candidate enforcement sites — git-workflow-branch pre-commit-pointer-check, executing-plans post-implementation steps, and the tests-v2 behavioral test — carry advisory/consistency roles for the ordering gate with no blocking authority | semantic | Clean-room sub-agent reads the four enforcement sites and judges that the three non-selected sites are advisory/consistency checks with no blocking authority | `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md`; `.opencode/skills/git-workflow-pr/tasks/post-implementation.md`; `.opencode/tests-v2/behaviors/` |
| SC-10 | The gate reports which in-scope submodule blocks it — unmerged PR, inconclusive state, stale pointer, or `+`-prefixed working tree — naming the submodule and its PR | string | `grep` the authoritative task card for per-submodule blocking-reason reporting covering the four categories | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` (result contract) |
| SC-11 | While waiting, the parent branch sits idle: no new commits, pushes, or PR mutations occur on the parent branch until all in-scope submodule PRs land | string | `grep` the authoritative task card for waiting-behavior language (parent branch sits idle; no commits, pushes, or PR mutations until submodule PRs land) | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` |

## Requirements

- R-1. The stacked-PR procedure SHALL block parent stacked PR creation when any in-scope submodule PR is unmerged.
- R-2. The gate SHALL enumerate the in-scope submodule set from the parent feature branch's changed submodule paths (gitlink changes relative to the trunk base) before performing merge verification.
- R-3. The gate SHALL verify each in-scope submodule PR's merge state via a live platform API call and SHALL NOT infer merge state from local checkout state or from `git merge-base` ancestry.
- R-4. The gate SHALL treat inconclusive API merge state as a block: it SHALL probe up to 3 times at 60-second intervals and then block PR creation with a clear reason reported in chat naming the inconclusive submodule and its PR.
- R-5. Submodule pointer bumps SHALL be committed on the parent feature branch after the submodule merges land per the pointers-ride-alongside rule, so the parent PR's squashed commit carries fresh pointers.
- R-6. The gate SHALL assert `git submodule status` shows no `+` prefixes for in-scope submodules before parent stacked PR creation.
- R-7. The gate SHALL assert each in-scope recorded pointer SHA is an ancestor of the submodule's remote trunk `origin/$DEFAULT_BRANCH` before parent stacked PR creation.
- R-8. The ordering gate's authoritative blocking check SHALL be assigned to exactly one enforcement site — the spec-designated site pr-creation/enforcement-gate.
- R-9. The three non-selected candidate enforcement sites (git-workflow-branch pre-commit-pointer-check, executing-plans post-implementation steps, tests-v2 behavioral test) SHALL carry advisory/consistency roles for the ordering gate and SHALL NOT block PR creation.
- R-10. The gate SHALL report which in-scope submodule blocks it — unmerged PR, inconclusive state, stale pointer, or `+`-prefixed working tree — naming the submodule and its PR.
- R-11. While waiting, the parent branch SHALL sit idle: no new commits, pushes, or PR mutations SHALL occur on the parent branch until all in-scope submodule PRs land.

## Items

### Item 1 (SC-1): Ordering gate blocks parent PR creation on unmerged in-scope submodule PR

- RED: Behavioral enforcement test in tests-v2 (scenario: parent stacked PR creation reached with one in-scope submodule PR open) fails — the gate does not block and a parent PR would be created
- GREEN: Implement the merge-state blocking condition in pr-creation/enforcement-gate so an unmerged in-scope submodule PR blocks parent PR creation
- verify: Behavioral test passes via `opencode run` with assertion helpers
- commit: The behavioral test and the enforcement-gate change together as one working slice

### Item 2 (SC-2): In-scope submodule set enumeration

- RED: Enforcement assertion (`grep`) that the authoritative task card documents in-scope-set enumeration from changed submodule paths relative to the trunk base fails
- GREEN: Add the enumeration requirement to pr-creation/enforcement-gate preceding merge verification
- verify: `grep` for the enumeration language passes
- commit: The task-card edit

### Item 3 (SC-3): Live-API merge-state verification, no local/ancestry inference

- RED: Enforcement assertion (`grep`) for live-API merge-state language and the no-inference prohibition fails
- GREEN: Add live platform API merge-state verification with the explicit never-inferred-from-local-state-or-ancestry rule to pr-creation/enforcement-gate
- verify: `grep` for live-API language and the prohibition passes
- commit: The task-card edit

### Item 4 (SC-4): Bounded retry and inconclusive-block parameters

- RED: Enforcement assertion (`grep`) for the bounded-retry parameters (3 probes, 60-second interval) and the chat-reported inconclusive block fails
- GREEN: Add the bounded retry/report path — up to 3 probes at 60-second intervals, then block with a clear reason reported in chat naming the inconclusive submodule and its PR — to pr-creation/enforcement-gate
- verify: `grep` for the retry parameters and report destination passes
- commit: The task-card edit

### Item 5 (SC-5): Pointers-ride-alongside timing rule in the authoritative card

- RED: Enforcement assertion (`grep`) for the pointers-ride-alongside rule requiring pointer bumps committed after merges land fails
- GREEN: Add the timing rule (pointer bumps committed on the parent feature branch after merges land, so the squashed commit carries fresh pointers) to pr-creation/enforcement-gate
- verify: `grep` for the timing rule passes
- commit: The task-card edit

### Item 6 (SC-6): No-`+`-prefix assertion blocks

- RED: Behavioral enforcement test in tests-v2 (scenario: `+`-prefixed in-scope submodule at parent PR creation) fails — the gate does not block
- GREEN: Implement the clean `git submodule status` assertion for in-scope submodules in pr-creation/enforcement-gate
- verify: Behavioral test passes via `opencode run`
- commit: The behavioral test and the enforcement-gate change together

### Item 7 (SC-7): Pointer-SHA ancestry assertion blocks

- RED: Behavioral enforcement test in tests-v2 (scenario: in-scope pointer referencing a commit absent from `origin/$DEFAULT_BRANCH`) fails — the gate does not block
- GREEN: Implement the ancestry assertion against `origin/$DEFAULT_BRANCH` (dynamically resolved per submodule) for in-scope pointers in pr-creation/enforcement-gate
- verify: Behavioral test passes via `opencode run`
- commit: The behavioral test and the enforcement-gate change together

### Item 8 (SC-8): Authoritative site designation

- RED: Clean-room sub-agent reads the four enforcement sites and cannot identify exactly one designated authoritative blocking check — judgment fails
- GREEN: Designate pr-creation/enforcement-gate as the sole authoritative blocking site per the spec's placement evaluation and selection criteria
- verify: Clean-room sub-agent re-reads the four sites and judges that exactly one authoritative blocking check is assigned
- commit: The designation change in pr-creation/enforcement-gate

### Item 9 (SC-9): Advisory roles at the three non-selected sites

- RED: Clean-room sub-agent reads the three non-selected sites and finds blocking authority or missing advisory annotation — judgment fails
- GREEN: Annotate git-workflow-branch pre-commit-pointer-check, executing-plans post-implementation steps, and the tests-v2 behavioral test as advisory/consistency checks for the ordering gate with no blocking authority
- verify: Clean-room sub-agent re-reads and judges that the three sites are advisory/consistency only
- commit: The advisory annotations across the three sites

### Item 10 (SC-10): Per-submodule blocking-reason reporting

- RED: Enforcement assertion (`grep`) for per-submodule blocking-reason reporting covering unmerged PR, inconclusive state, stale pointer, and `+`-prefixed working tree fails
- GREEN: Add the four-category per-submodule blocking-reason reporting (naming the submodule and its PR) to pr-creation/enforcement-gate
- verify: `grep` for the four blocking-reason categories passes
- commit: The task-card edit

### Item 11 (SC-11): Waiting behavior — parent branch sits idle

- RED: Enforcement assertion (`grep`) for waiting-behavior language (parent branch sits idle; no commits, pushes, or PR mutations until submodule PRs land) fails
- GREEN: Add the waiting-behavior statement to pr-creation/enforcement-gate
- verify: `grep` for the waiting-behavior language passes
- commit: The task-card edit

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode` issue #2313 (merged reachability gates) | Must be merged first — provides the `origin/$DEFAULT_BRANCH` convention, the enforcement-gate Step 0 this gate extends, and the SKIP_STALE_POINTER_CHECK context | Satisfied (merged; convention live in enforcement-gate) |
| git-workflow-pr skill, pr-creation task family | Hosts the authoritative blocking site — must be read before implementation | Satisfied (files present and read) |
| git-workflow-branch skill, pre-commit-pointer-check task | Advisory site — must be read before implementation | Satisfied (file present and read) |
| git-workflow-pr skill, post-implementation task | Advisory site — must be read before implementation | Satisfied (file present and read) |
| tests-v2 behavioral harness (with-test-home, test-submodule-1 provisioning per #2313 fixtures) | Behavioral evidence infrastructure for SC-1/SC-6/SC-7 — must be read before implementation | Satisfied (harness and fixtures present) |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 1 |
| R-4 | SC-4 | Phase 1 |
| R-5 | SC-5 | Phase 1 |
| R-6 | SC-6 | Phase 1 |
| R-7 | SC-7 | Phase 1 |
| R-8 | SC-8 | Phase 2 |
| R-9 | SC-9 | Phase 2 |
| R-10 | SC-10 | Phase 1 |
| R-11 | SC-11 | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| GitHub REST API — Pull requests | API doc | https://docs.github.com/en/rest/pulls/pulls | Fetched live 2026-09-04 — merge-state fields (`merged`, `merged_at`, `merged` on Get a PR; `mergeable` null during background computation) and "Check if a pull request has been merged" endpoint verified |
| GitHub REST API — Commits | API doc | https://docs.github.com/en/rest/commits/commits | Fetched live 2026-09-04 — commit/compare endpoints supporting ancestry verification verified |
| pr-creation/enforcement-gate task card | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` | Read 2026-09-04 — Step 0 submodule reachability gate and Step 0.5 bump-only gate verified; authoritative site |
| pr-creation task card | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | Read 2026-09-04 — Pre-Push Submodule Pointer Verification and pointers-ride-alongside language verified |
| pre-commit-pointer-check task card | code | `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` | Read 2026-09-04 — staging-hygiene role and cross-references verified; advisory site |
| post-implementation task card | code | `.opencode/skills/git-workflow-pr/tasks/post-implementation.md` | Read 2026-09-04 — push-without-PR role verified; advisory site |
| tests-v2 behavioral harness and #2313 fixtures | code | `.opencode/tests-v2/behaviors/`, `.opencode/tests-v2/behaviors/fixtures/issues/2313/` | Read 2026-09-04 — behavioral evidence infrastructure and test-submodule-1 provisioning convention verified |
| #2313 spec (merged convention) | doc | `.opencode/tests-v2/behaviors/fixtures/issues/2313/spec.md` | Read 2026-09-04 — `origin/$DEFAULT_BRANCH` terminology and fail-open semantics verified |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the behavioral block test costs minutes of execution time — an unmerged submodule dependency is caught at the gate instead of in an unmergeable parent PR. Skipping costs days-to-weeks — the unmergeable parent PR ships, is discovered at review or merge time, and costs a full rework cycle.
- **SC-2:** Grepping the enumeration language costs seconds — without a defined in-scope set, the gate's coverage is undefined. Skipping costs days — the gate silently covers the wrong submodule set and the defect re-fires on the next multi-submodule release.
- **SC-3:** Grepping for live-API verification language costs seconds — merge state is verified against reality. Skipping costs weeks — ancestry-inferred merge state passes stale pointers, the exact #304 failure, discovered when the parent PR cannot merge.
- **SC-4:** Grepping for the bounded-retry parameters costs seconds — inconclusive state resolves to a definite block or a verified pass. Skipping costs weeks — an "or"-shaped inconclusive path is interpreted inconsistently at runtime, sometimes guessing pass, shipping unmergeable PRs.
- **SC-5:** Grepping the timing rule costs seconds — pointer bumps land after merges and the parent commit is fresh. Skipping costs days — pointers committed before merges re-create the stale-pointer parent PR the gate exists to prevent.
- **SC-6:** Running the `+`-prefix behavioral test costs minutes — working-tree divergence from recorded pointers is caught at the gate. Skipping costs weeks — a parent PR tree resolving divergent submodule content ships and fails downstream builds.
- **SC-7:** Running the ancestry behavioral test costs minutes — pointers referencing commits absent from the remote trunk are caught at the gate. Skipping costs weeks — deploy builds resolve nonexistent submodule commits and break, the failure mode #2313 documented.
- **SC-8:** Dispatching the clean-room semantic judgment costs minutes — exactly one site owns blocking authority, so gate failures have one diagnosable owner. Skipping costs days — conflicting or duplicated blocking checks produce contradictory pass/block outcomes that take a debugging session to untangle.
- **SC-9:** Dispatching the clean-room semantic judgment on advisory roles costs minutes — non-selected sites cannot contradict the authoritative gate. Skipping costs days — a rogue blocking check at an advisory site blocks legitimate PRs with no authoritative basis.
- **SC-10:** Grepping the reporting language costs seconds — every block names the submodule and its PR. Skipping costs hours — a bare block with no reason sends the developer hunting across submodule repos for what is pending.
- **SC-11:** Grepping the waiting-behavior language costs seconds — the parent branch idles deterministically during the wait. Skipping costs days — undefined waiting behavior invites commits or PR mutations mid-wait, invalidating the gate's verification at PR creation.

## Edge Cases

- **Condition:** Parent repo has no submodules (empty `git submodule status`). **Expected behavior:** The gate skips entirely — no in-scope set exists, and single-repo PR flow behavior is unchanged. **Resolution:** Skip is explicit, not a silent pass through unverifiable checks.
- **Condition:** Parent feature branch changes no submodule pointers (no in-scope set). **Expected behavior:** The gate passes the merge-state condition — there is nothing to wait for; the parent PR proceeds to the remaining checks. **Resolution:** Out-of-scope submodules are out-of-scope by construction: a merged submodule PR whose pointer was not bumped rides alongside the next parent change per the pointers-ride-alongside convention and does not block this gate.
- **Condition:** In-scope submodule PR is closed without merging. **Expected behavior:** The gate blocks — closed is not merged; the live API distinguishes merge state from PR state. **Resolution:** The per-submodule report names the submodule and its PR as unmerged; the developer reopens or re-lands the submodule change.
- **Condition:** Platform API unreachable during verification. **Expected behavior:** The gate fails closed — network error is inconclusive state, not a pass. The gate probes up to 3 times at 60-second intervals, then blocks with a clear reason. **Resolution:** The developer re-runs PR creation once connectivity is restored; the block names the unverifiable submodule PR. (This gate is deliberately fail-closed; the #2313 reachability gates' fail-open policy is unchanged and governs only reachability, not merge state.)
- **Condition:** API returns `mergeable`/merge-state as null (background computation in progress). **Expected behavior:** Treat as inconclusive — probe up to 3 times at 60-second intervals, then block naming the submodule PR. **Resolution:** Retry resolves transient lag; persistent null blocks until the platform state is definite.
- **Condition:** Submodule PR merges while the gate is probing. **Expected behavior:** The next probe observes merged state and the gate passes. **Resolution:** Bounded retry absorbs the race; no developer action needed.
- **Condition:** Developer pushes new parent commits while the branch waits. **Expected behavior:** Waiting means idle — no commits, pushes, or PR mutations until all in-scope submodule PRs land; the gate re-evaluates the branch state at the next PR-creation attempt. **Resolution:** If new parent work is needed mid-wait, it lands on the same branch before PR creation and the gate re-verifies pointers at that time.
- **Condition:** The submodule's feature-branch PR cannot be located via API (branch renamed, PR never opened). **Expected behavior:** Inconclusive state — bounded retry, then block naming the submodule whose PR was not resolvable. **Resolution:** The developer opens or corrects the submodule PR; the gate cannot pass on an unverifiable dependency.
- **Condition:** Many in-scope submodules with mixed states (some merged, some pending, one inconclusive). **Expected behavior:** The gate blocks and the per-submodule report enumerates every pending or inconclusive submodule with its category. **Resolution:** The developer prioritizes merges from the report; the gate re-runs after the last merge lands.

## Impact

| Risk | Mitigation |
|------|-----------|
| Live-API merge verification can false-block when platform checks lag behind an actual merge | Bounded retry: up to 3 probes at 60-second intervals; inconclusive state blocks with a clear reason naming the submodule PR rather than guessing |
| Ordering gate adds latency to multi-submodule releases (parent PR cannot open until last submodule merge) | Latency is the cost of a mergeable parent PR; the gate reports exactly which submodule PR is pending so the developer can prioritize merges |
| Gate placement across four candidate sites could produce redundant or conflicting checks | Spec evaluates all four sites against published selection criteria and assigns exactly one authoritative blocking check (pr-creation/enforcement-gate); the others are advisory/consistency |

**Dependencies:** None external — see the Dependencies section. Implementation touches task cards in git-workflow-pr (authoritative site + advisory site), git-workflow-branch (advisory site), executing-plans (advisory site), and the tests-v2 behavioral suite.

**Call to action:** Review and approve this spec to add the submodule-merge ordering gate to the stacked-PR workflow.

## Provenance

Surfaced by developer Q&A during Butter #304 cleanup — developer: "why are the pointers stale for the root repo PR?" then "why did you create a PR for a root repo with submodules with pending merges that you didn't have the hashes for?"

## Change Control

| Date | Change | Reason | Authorizer |
|------|--------|--------|------------|
| 2026-09-04 | Added Success Criteria table (SC-1 through SC-6) decomposing the Approach's three-condition ordering gate, the pointers-ride-alongside rule, and the enforcement-placement evaluation into per-SC entries with evidence types (behavioral/string/semantic) and verification methods | Pipeline-initiated non-substantive revision: the writing-plans analyze gate requires a Success Criteria table with per-SC evidence types before plan creation (spec had zero SCs — `NO_SUCCESS_CRITERIA`); adds missing SC decomposition without altering implementation intent, scope, or requirements | Pipeline gate (writing-plans analyze) under developer-approved for_pr scope (approved-for-pr label, halt_at pr_created) |
| 2026-09-04 | Restructured to spec-structure-standards: added 6-field Intent and Executive Summary preamble, Not Included (with rationales), Requirements (R-1..R-11, SHALL), per-SC Items, Dependencies (Reference/Relationship/Status), Traceability, Documentation Sources (section table + SC-table column), Enforcement Gate, per-SC Cost Frame, Edge Cases, Alternatives Considered, and Key Design Decisions; decomposed compound SC-2/SC-4/SC-5/SC-6 into atomic SC-1..SC-11; removed hedging ("may sit idle" → "sits idle"), resolved the "stale or +prefixed" disjunction into separate SCs, defined bounded-retry parameters (3 probes, 60-second intervals, chat report); added the spec-level placement evaluation with selection criteria designating pr-creation/enforcement-gate as the authoritative site; aligned "remote master" to `origin/$DEFAULT_BRANCH` per the #2313 convention; defined the in-scope enumeration mechanism (changed submodule paths relative to trunk base) | Pipeline-initiated revision: Aggregate FAIL from spec-creation holistic validation (structure, compound SCs, determinism, internal consistency, completeness dimensions) under approved-for-pr scope (halt_at pr_created) | Pipeline gate (holistic validation) under developer-approved for_pr scope (approved-for-pr label, halt_at pr_created) |

---

🤖 OpenCode (ollama-cloud/glm-5.3-flash) created