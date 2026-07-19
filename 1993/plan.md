# Plan: Refactor spec-creation skill

**Issue:** #1993
**Spec:** https://github.com/michael-conrad/.opencode/issues/1993
**Status:** DRAFT
**Created:** 2026-07-19

## Phase Overview

| Phase | Name | Depends On | SCs | Items |
|-------|------|-----------|-----|-------|
| 1 | SKILL.md restructure | — | SC-1, SC-3, SC-7, SC-8, SC-9, SC-10 | 4 items |
| 2 | Task card cleanup | Phase 1 | SC-2, SC-4, SC-11–SC-21 | 14 items |
| 3 | Critical violation + verification | Phase 2 | SC-5, SC-6 | 2 items |

## Pipeline Gates (applied per phase)

Every phase runs the full pipeline after its items are complete:

1. **Coherence gate** — Verify plan items match spec SCs for this phase
2. **Pre-red-baseline** — Run `git stash` to capture clean state, run existing tests to confirm baseline PASS
3. **Per-item RED/GREEN** — Each item below follows RED → GREEN → REFACTOR → COMMIT
4. **VbC** — Verify all SCs for this phase pass
5. **Audit** — `skill({name: "audit"})` then `task(..., prompt: "execute spec-audit task from audit for issue 1993")`
6. **Cross-validate** — Verify audit PASS, no regressions
7. **Regression check** — Run `git stash pop`, re-run tests, confirm no breakage
8. **Finishing checklist** — `skill({name: "finishing-a-development-branch"})` then `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
9. **Review-prep** — `skill({name: "git-workflow"})` then `task(..., prompt: "execute review-prep task from git-workflow")`
10. **Cleanup** — `skill({name: "git-workflow"})` then `task(..., prompt: "execute cleanup task from git-workflow")`

## SC-to-Item Traceability

### Phase 1 — SKILL.md restructure

| SC ID | Criterion | Item(s) |
|-------|-----------|---------|
| SC-1 | SKILL.md Trigger Dispatch Table has exactly 3 entries: `create`, `revise`, `completion` | 1.1, 1.2 |
| SC-3 | Pipeline procedure is in the SKILL.md (or a reference file the SKILL.md loads), not in a task card | 1.3, 1.4 |
| SC-7 | No sub-task step references `{project_root}/tmp/{N}/contracts/` paths | 1.3 |
| SC-8 | Every sub-task step specifies what the sub-agent reads from disk and writes to disk | 1.3 |
| SC-9 | Every sub-task step specifies the result contract format | 1.3 |
| SC-10 | Create pipeline starts with `local-issues sync`, then `create-remote-stub`, ends with `revise-remote-body`, then `local-issues sync` | 1.3 |

### Phase 2 — Task card cleanup

| SC ID | Criterion | Item(s) |
|-------|-----------|---------|
| SC-2 | No task card under any spec-creation sub-skill contains `task(...)` | 2.1–2.10, 2.12 |
| SC-4 | `analytical-artifacts.md` contains no orchestrator-level instructions | 2.11 |
| SC-11 | `create` sub-agent task card does NOT create the remote issue | 2.1 |
| SC-12 | `create-remote-stub.md` exists and handles both remote and local platforms | 2.13 |
| SC-13 | `pre-spec-inspection.md` exists | 2.14 |
| SC-14 | `revise-remote-body.md` exists | 2.15 |
| SC-15 | `create.md` contains no `task(` or `skill({name:` calls | 2.1 |
| SC-16 | `create.md` contains no `{project_root}/tmp/` paths | 2.2 |
| SC-17 | `create.md` contains a result contract section | 2.3 |
| SC-18 | `create.md` contains a read-from-disk specification | 2.4 |
| SC-19 | `create.md` has sequentially numbered steps | 2.5 |
| SC-20 | `create.md` self-review reads from local `.issues/{N}/spec.md`, not from remote API | 2.6 |
| SC-21 | `create.md` does not reference a non-existent "pre-PR gate" | 2.7 |

### Phase 3 — Critical violation + verification

| SC ID | Criterion | Item(s) |
|-------|-----------|---------|
| SC-5 | `000-critical-rules.md` contains the sub-agent task() prohibition entry | 3.1 |
| SC-6 | All 13 clean task cards remain unmodified | 3.2 |

---

## Phase 1 — SKILL.md restructure

**Goal:** Replace the 11-entry Trigger Dispatch Table with 3 entries (`create`, `revise`, `completion`). Move the pipeline procedure from `operating-protocol.md` into the SKILL.md. Strip all `{project_root}/tmp/{N}/contracts/` paths. Add read/write/contract specifications for every sub-task step. Fix pipeline order to sync-first.

**Files modified:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md` (delete)

### Item 1.1 — Remove 8 fake dispatch entries from SKILL.md

**RED:** Write behavioral enforcement test that sends prompt "create spec" and verifies SKILL.md Trigger Dispatch Table has exactly 3 entries. Test fails because 11 entries exist.

**GREEN:** Edit `.opencode/skills/spec-creation/SKILL.md` Trigger Dispatch Table. Remove rows: `requirements`, `decompose`, `analytical-artifacts`, `holistic-self-check`, `pipeline-readiness-gate`, `risk`, `traceability`, `operating-protocol`. Keep only `create`, `completion`. Remove corresponding Invocation table entries.

**REFACTOR:** Verify no dangling cross-references to removed entries.

**COMMIT:** `git commit -m "1993: remove 8 fake dispatch entries from spec-creation SKILL.md"`

**SC coverage:** SC-1
**Evidence type:** `string` — grep for dispatch rows in SKILL.md, count = 2 (before adding `revise`)

### Item 1.2 — Add `revise` dispatch entry to SKILL.md

**RED:** Write behavioral enforcement test that sends prompt "revise spec" and verifies `revise` dispatch entry exists. Test fails because entry doesn't exist.

**GREEN:** Add `revise` row to Trigger Dispatch Table: `"revise spec" / "update spec"` → `revise` → `spec-creation-validation --task revise` → `sub-task` → `{issue_number}`. Add corresponding Invocation table entry.

**REFACTOR:** Verify `revise` entry is properly formatted and consistent with other entries.

**COMMIT:** `git commit -m "1993: add revise dispatch entry to spec-creation SKILL.md"`

**SC coverage:** SC-1
**Evidence type:** `string` — grep for `revise` in SKILL.md dispatch table

### Item 1.3 — Add Pipeline section to SKILL.md

**RED:** Write behavioral enforcement test that sends prompt "create spec" and verifies the orchestrator follows the 25-step pipeline with correct order. Test fails because pipeline section doesn't exist.

**GREEN:** Add Pipeline section to `.opencode/skills/spec-creation/SKILL.md` defining:
- 25-step create procedure with each step labeled `[inline]` or `[sub-task]`
- 6-step revise procedure
- Each sub-task step specifies: what the sub-agent reads from disk, what it writes to disk, and the result contract format
- Pipeline order: `local-issues sync` → `create-remote-stub` → ... → `revise-remote-body` → `local-issues sync`
- No `{project_root}/tmp/{N}/contracts/` paths — all data passes through `.issues/{N}/artifacts/`

**REFACTOR:** Verify pipeline section is complete, no missing steps, all contract formats specified.

**COMMIT:** `git commit -m "1993: add 25-step create and 6-step revise pipeline to spec-creation SKILL.md"`

**SC coverage:** SC-3, SC-7, SC-8, SC-9, SC-10
**Evidence type:** `string` + `semantic`

### Item 1.4 — Delete `operating-protocol.md` task card

**RED:** Write behavioral enforcement test that verifies `operating-protocol.md` does not exist under spec-creation-operating-protocol/tasks/. Test fails because file exists.

**GREEN:** Delete `.opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md`. Content has been moved to SKILL.md Pipeline section (Item 1.3).

**REFACTOR:** Verify no remaining cross-references to `operating-protocol.md` in any spec-creation file.

**COMMIT:** `git commit -m "1993: delete operating-protocol.md task card, content moved to SKILL.md"`

**SC coverage:** SC-3
**Evidence type:** `structural` — file no longer exists

### Phase 1 Exit Criteria

- [ ] SKILL.md Trigger Dispatch Table has exactly 3 entries (SC-1)
- [ ] `revise` dispatch entry exists in SKILL.md (SC-1)
- [ ] Pipeline section exists in SKILL.md with read/write/contract for each sub-task step (SC-3, SC-8, SC-9)
- [ ] No `{project_root}/tmp/{N}/contracts/` paths in SKILL.md pipeline (SC-7)
- [ ] Create pipeline starts with sync, ends with sync (SC-10)
- [ ] `operating-protocol.md` deleted (SC-3)

---

## Phase 2 — Task card cleanup

**Goal:** Remove all `task()` and `skill()` calls from task cards. Remove remote issue creation from `create.md`. Replace `{project_root}/tmp/` paths with `.issues/{N}/`. Add result contract and read-from-disk sections. Renumber steps. Create 3 new task cards. Fix `analytical-artifacts.md` category error.

**Files modified:**
- `.opencode/skills/spec-creation-validation/tasks/create.md`
- `.opencode/skills/spec-creation-validation/tasks/completion.md`
- `.opencode/skills/spec-creation-change-control/tasks/change-control.md`
- `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`

**Files created:**
- `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md`
- `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md`
- `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md`

### Item 2.1 — Remove `task()` calls from `create.md` (D-1)

**RED:** Write behavioral enforcement test that sends prompt to execute `create.md` as sub-agent and verifies no `task(` calls are present. Test fails because 4 `task()` calls exist.

**GREEN:** Remove 4 `task()` calls from `.opencode/skills/spec-creation-validation/tasks/create.md`:
- Step 0: Remove `invoke verification-enforcement --task verify` — this dispatch moves to SKILL.md pipeline
- Step 1: Remove `Invoke issue-operations --task creation` — this dispatch moves to SKILL.md pipeline
- Step 27: Remove `invoke verification-enforcement --task revisit` — this dispatch moves to SKILL.md pipeline
- Step 9: Remove `skill({name: "audit"})` then `task(...)` — this dispatch moves to SKILL.md pipeline

**REFACTOR:** Verify no remaining `task(` calls in create.md.

**COMMIT:** `git commit -m "1993: remove 4 task() calls from create.md (D-1)"`

**SC coverage:** SC-2, SC-15
**Evidence type:** `string` — grep for `task(` in create.md — 0 matches

### Item 2.2 — Replace `{project_root}/tmp/` paths in `create.md` (D-3)

**RED:** Write behavioral enforcement test that verifies `create.md` contains no `{project_root}/tmp/` paths. Test fails because 3 paths exist.

**GREEN:** Replace 3 `{project_root}/tmp/` paths in `.opencode/skills/spec-creation-validation/tasks/create.md`:
- Step 1.3: `{project_root}/tmp/{issue-N}/lifecycle.yaml` → `.issues/{N}/lifecycle.yaml`
- Step 5.6: `{project_root}/tmp/{issue-N}/artifacts/constraints-contract.yaml` → `.issues/{N}/artifacts/constraints-contract.yaml`
- Step 5.6: `{project_root}/tmp/{issue-N}/artifacts/phase-plan-validated.yaml` → `.issues/{N}/artifacts/phase-plan-validated.yaml`

**REFACTOR:** Verify no remaining `{project_root}/tmp/` paths in create.md.

**COMMIT:** `git commit -m "1993: replace {project_root}/tmp/ paths with .issues/{N}/ in create.md (D-3)"`

**SC coverage:** SC-16
**Evidence type:** `string` — grep for `project_root}/tmp/` in create.md — 0 matches

### Item 2.3 — Add result contract section to `create.md` (D-4)

**RED:** Write behavioral enforcement test that verifies `create.md` contains a result contract section. Test fails because no result contract exists.

**GREEN:** Add result contract section to `.opencode/skills/spec-creation-validation/tasks/create.md`:

```yaml
## Result Contract

status: DONE | BLOCKED
finding_summary: "Spec #N written with M SCs"
artifact_path: .issues/{N}/spec.md
blocker_reason: "<why if BLOCKED>"
```

**REFACTOR:** Verify result contract format matches frugal contract pattern from spec.

**COMMIT:** `git commit -m "1993: add result contract section to create.md (D-4)"`

**SC coverage:** SC-17
**Evidence type:** `semantic` — sub-agent reads create.md — confirms result contract section present

### Item 2.4 — Add read-from-disk specification to `create.md` (D-5)

**RED:** Write behavioral enforcement test that verifies `create.md` contains a read-from-disk section listing prior artifact paths. Test fails because no such section exists.

**GREEN:** Add read-from-disk specification to `.opencode/skills/spec-creation-validation/tasks/create.md`:

```yaml
## Input Artifacts

The sub-agent reads from the following paths on disk:
- `.issues/{N}/artifacts/requirements.yaml`
- `.issues/{N}/artifacts/concern-map.yaml`
- `.issues/{N}/artifacts/decomposition.yaml`
- `.issues/{N}/artifacts/blast-radius.yaml`
- `.issues/{N}/artifacts/cross-cutting-matrix.yaml`
- `.issues/{N}/artifacts/traceability.yaml`
- `.issues/{N}/artifacts/code-path-inventory.yaml`
- `.issues/{N}/artifacts/interface-compatibility.yaml`
- `.issues/{N}/artifacts/state-analysis.yaml`
- `.issues/{N}/artifacts/sc-pipeline-readiness.yaml`
- `.issues/{N}/artifacts/testability-assessment.yaml`
- `.issues/{N}/artifacts/risk.yaml`
- `.issues/{N}/artifacts/interdependency-check.yaml`
```

**REFACTOR:** Verify all artifact paths match the spec's artifact directory structure.

**COMMIT:** `git commit -m "1993: add read-from-disk specification to create.md (D-5)"`

**SC coverage:** SC-18
**Evidence type:** `semantic` — sub-agent reads create.md — confirms read-from-disk section present

### Item 2.5 — Renumber steps sequentially in `create.md` (D-6)

**RED:** Write behavioral enforcement test that verifies `create.md` has monotonically increasing step numbers. Test fails because steps are numbered 0, 1, 2, 3, 1, 1a, 1.1, etc.

**GREEN:** Renumber all steps in `.opencode/skills/spec-creation-validation/tasks/create.md` sequentially 1-N. Remove all sub-step numbering (1a, 1.1, 1.2, 1.3, 1.35, 1.4, 1d, 1d.5, etc.) — replace with flat sequential numbering.

**REFACTOR:** Verify no duplicate or out-of-order step numbers.

**COMMIT:** `git commit -m "1993: renumber steps sequentially in create.md (D-6)"`

**SC coverage:** SC-19
**Evidence type:** `string` — grep for step numbers in create.md — verify monotonic sequence

### Item 2.6 — Replace remote API reads with local file reads in `create.md` (D-7)

**RED:** Write behavioral enforcement test that verifies `create.md` self-review reads from local `.issues/{N}/spec.md`, not from remote API. Test fails because Step 6.5 references `issue-operations -> read-issue`.

**GREEN:** Replace remote API reads in `.opencode/skills/spec-creation-validation/tasks/create.md` Step 6.5:
- `issue-operations -> read-issue` → `read(filePath=".issues/{N}/spec.md")`
- All self-review checkpoints read from local file, not remote API

**REFACTOR:** Verify no remaining `read-issue` references in create.md.

**COMMIT:** `git commit -m "1993: replace remote API reads with local file reads in create.md (D-7)"`

**SC coverage:** SC-20
**Evidence type:** `string` — grep for "read-issue" in create.md — 0 matches

### Item 2.7 — Remove forward reference to non-existent pre-PR gate (D-10)

**RED:** Write behavioral enforcement test that verifies `create.md` does not reference "pre-PR gate". Test fails because Step 7.3 references it.

**GREEN:** Delete Step 7.3 from `.opencode/skills/spec-creation-validation/tasks/create.md` (lines 724).

**REFACTOR:** Verify no remaining "pre-PR gate" references in create.md.

**COMMIT:** `git commit -m "1993: remove forward reference to non-existent pre-PR gate (D-10)"`

**SC coverage:** SC-21
**Evidence type:** `string` — grep for "pre-PR gate" in create.md — 0 matches

### Item 2.8 — Remove remote issue creation from `create.md` (D-2)

**RED:** Write behavioral enforcement test that verifies `create.md` does NOT create the remote issue. Test fails because Step 7.2 handles remote issue creation.

**GREEN:** Remove Step 7.2 from `.opencode/skills/spec-creation-validation/tasks/create.md` (lines 646-722). This section moves to `create-remote-stub.md` (Item 2.13) and `revise-remote-body.md` (Item 2.15).

**REFACTOR:** Verify no remaining remote issue creation instructions in create.md.

**COMMIT:** `git commit -m "1993: remove remote issue creation from create.md (D-2)"`

**SC coverage:** SC-2, SC-11
**Evidence type:** `semantic` — sub-agent reads create.md — confirms no remote issue creation instructions

### Item 2.9 — Remove `skill()` call from `create.md` (D-8)

**RED:** Write behavioral enforcement test that verifies `create.md` contains no `skill({name:` calls. Test fails because Step 5.6 references `skill({name: "plan"})`.

**GREEN:** Remove `skill({name: "plan"})` from `.opencode/skills/spec-creation-validation/tasks/create.md` Step 5.6 (line 539). Replace with reference to the SKILL.md pipeline which handles `plan plan` as an inline orchestrator step.

**REFACTOR:** Verify no remaining `skill({name:` calls in create.md.

**COMMIT:** `git commit -m "1993: remove skill() call from create.md (D-8)"`

**SC coverage:** SC-2, SC-15
**Evidence type:** `string` — grep for `skill({name:` in create.md — 0 matches

### Item 2.10 — Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (D-9)

**RED:** Write behavioral enforcement test that verifies `create.md` references `.issues/{N}/lifecycle.yaml` instead of `{project_root}/tmp/{N}/lifecycle.yaml`. Test fails because phantom path is used.

**GREEN:** In `.opencode/skills/spec-creation-validation/tasks/create.md`:
- Change Step 1.3 lifecycle manifest path from `{project_root}/tmp/{issue-N}/lifecycle.yaml` to `.issues/{N}/lifecycle.yaml`
- Document append-only semantics: if file exists, append; if not, create

**REFACTOR:** Verify lifecycle.yaml path is correct and consistent with artifact directory structure.

**COMMIT:** `git commit -m "1993: move lifecycle manifest to .issues/{N}/lifecycle.yaml (D-9)"`

**SC coverage:** SC-16
**Evidence type:** `string` — grep for `lifecycle.yaml` in create.md — references `.issues/{N}/lifecycle.yaml`

### Item 2.11 — Fix `analytical-artifacts.md` category error

**RED:** Write behavioral enforcement test that verifies `analytical-artifacts.md` contains no orchestrator-level instructions. Test fails because file contains "orchestrator dispatches" and "(*orchestrator*)" labels.

**GREEN:** Rewrite `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`:
- Remove all "orchestrator dispatches via SKILL.md Trigger Dispatch Table" language
- Remove all "(*orchestrator*)" labels
- Convert to sub-agent-executable procedure: sub-agent reads `.issues/{N}/spec.md`, writes 7 YAML files to `.issues/{N}/artifacts/`
- Add result contract section
- Add read-from-disk specification

**REFACTOR:** Verify no remaining "orchestrator" references in analytical-artifacts.md.

**COMMIT:** `git commit -m "1993: fix analytical-artifacts.md category error — convert to sub-agent procedure"`

**SC coverage:** SC-4
**Evidence type:** `string` — grep for "orchestrator" in analytical-artifacts.md — 0 matches

### Item 2.12 — Clean `completion.md` and `change-control.md`

**RED:** Write behavioral enforcement test that verifies `completion.md` and `change-control.md` contain no `task(` calls. Tests fail because both contain `task()` calls.

**GREEN:**
- `.opencode/skills/spec-creation-validation/tasks/completion.md`: Remove 2 `Dispatch task(...)` lines. Convert to pure sub-agent procedure that checks state and returns result contract.
- `.opencode/skills/spec-creation-change-control/tasks/change-control.md`: Remove `Dispatch audit --task spec-audit` line (Step 3.5). Convert to pure sub-agent procedure.

**REFACTOR:** Verify no remaining `task(` calls in either file.

**COMMIT:** `git commit -m "1993: remove task() calls from completion.md and change-control.md"`

**SC coverage:** SC-2
**Evidence type:** `string` — grep for `task(` in completion.md and change-control.md — 0 matches each

### Item 2.13 — Create `create-remote-stub.md`

**RED:** Write behavioral enforcement test that verifies `create-remote-stub.md` exists. Test fails because file doesn't exist.

**GREEN:** Create `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md`:
- Purpose: Obtain spec issue number and create stub file
- Handles both remote and local platforms transparently
- Remote: create issue via platform API, save response as `.issues/{N}/remote.md`
- Local: list `.issues/` directories, max+1, create `.issues/{N}/remote.md` with stub content
- Returns `{status: DONE, finding_summary: "Issue #N created via <platform>", artifact_path: ".issues/{N}/remote.md", spec_number: N}`
- Never BLOCKED on platform — always returns a spec number

**REFACTOR:** Verify file is well-formed, follows task card template, includes result contract.

**COMMIT:** `git commit -m "1993: create create-remote-stub.md task card"`

**SC coverage:** SC-12
**Evidence type:** `structural` — file exists

### Item 2.14 — Create `pre-spec-inspection.md`

**RED:** Write behavioral enforcement test that verifies `pre-spec-inspection.md` exists. Test fails because file doesn't exist.

**GREEN:** Create `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md`:
- Purpose: Check for superseding issues, already-implemented specs, codebase state
- Search GitHub Issues for open `[SPEC]` issues with overlapping scope
- Check for already-implemented specs (merged PRs with related functionality)
- Read codebase state for affected files
- Classify findings: FULL-SUPERSESSION, PARTIAL-OVERLAP, CONFLICT-RISK, INDEPENDENT
- Returns BLOCKED with `reason: CONFLICT-RISK` or `reason: FULL-SUPERSESSION` if blocking conflicts found
- Writes findings to `.issues/{N}/artifacts/pre-spec-inspection.yaml`

**REFACTOR:** Verify file is well-formed, follows task card template, includes result contract.

**COMMIT:** `git commit -m "1993: create pre-spec-inspection.md task card"`

**SC coverage:** SC-13
**Evidence type:** `structural` — file exists

### Item 2.15 — Create `revise-remote-body.md`

**RED:** Write behavioral enforcement test that verifies `revise-remote-body.md` exists. Test fails because file doesn't exist.

**GREEN:** Create `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md`:
- Purpose: Update remote issue body with correct `.issues/{N}/` folder links after local spec is written
- Check `github.platform` — if `local`, return `{status: SKIPPED}`
- Read `.issues/{N}/spec.md` for spec content
- Construct `.issues/{N}/` folder URL from session-init values
- Update remote issue body via platform API with spec reference blockquote
- Returns `{status: DONE | SKIPPED, finding_summary: "Remote body updated" | "No remote API — skipped", artifact_path: null, blocker_reason: null}`

**REFACTOR:** Verify file is well-formed, follows task card template, includes result contract.

**COMMIT:** `git commit -m "1993: create revise-remote-body.md task card"`

**SC coverage:** SC-14
**Evidence type:** `structural` — file exists

### Phase 2 Exit Criteria

- [ ] `create.md` contains no `task(` or `skill({name:` calls (SC-15)
- [ ] `create.md` contains no `{project_root}/tmp/` paths (SC-16)
- [ ] `create.md` contains result contract section (SC-17)
- [ ] `create.md` contains read-from-disk specification (SC-18)
- [ ] `create.md` has sequentially numbered steps (SC-19)
- [ ] `create.md` self-review reads from local `.issues/{N}/spec.md` (SC-20)
- [ ] `create.md` does not reference "pre-PR gate" (SC-21)
- [ ] `create.md` does NOT create the remote issue (SC-11)
- [ ] `completion.md` has no `task(` calls (SC-2)
- [ ] `change-control.md` has no `task(` calls (SC-2)
- [ ] `analytical-artifacts.md` has no orchestrator-level instructions (SC-4)
- [ ] `create-remote-stub.md` exists (SC-12)
- [ ] `pre-spec-inspection.md` exists (SC-13)
- [ ] `revise-remote-body.md` exists (SC-14)
- [ ] No task card under any spec-creation sub-skill contains `task(...)` (SC-2)

---

## Phase 3 — Critical violation + verification

**Goal:** Add the sub-agent task() prohibition to `000-critical-rules.md`. Verify all 13 clean task cards remain unmodified.

**Files modified:**
- `.opencode/guidelines/000-critical-rules.md`

### Item 3.1 — Add critical violation to `000-critical-rules.md`

**RED:** Write behavioral enforcement test that sends prompt with a task card containing `task()` and verifies the agent declines to execute it. Test fails because no prohibition exists.

**GREEN:** Append to `.opencode/guidelines/000-critical-rules.md` in the Tier 2 (process-integrity) section:

```
### [critical-rules-XXX] CRITICAL VIOLATION — Sub-agent task cards MUST NOT contain task() or skill() calls
Only orchestrator-level SKILL.md files may contain dispatch instructions. A task card that contains a task() or skill() call is structurally defective — the sub-agent cannot execute it. This applies to ALL task cards across ALL skills. Violation: HALT with blocker report.
```

**REFACTOR:** Verify entry is in the correct tier section, uses consistent formatting.

**COMMIT:** `git commit -m "1993: add critical violation for sub-agent task() calls in task cards"`

**SC coverage:** SC-5
**Evidence type:** `string` — grep for "task cards MUST NOT contain task()" in 000-critical-rules.md — found

### Item 3.2 — Verify 13 clean task cards unmodified

**RED:** Write behavioral enforcement test that verifies git diff shows zero changes to the 13 clean task cards. Test fails if any changes detected.

**GREEN:** Run `git diff` against the 13 clean task cards listed in the spec's "Files NOT to modify" section. Confirm zero changes. If any changes detected, revert them with `git checkout -- <file>`.

**REFACTOR:** Verify the diff is clean — no unintended modifications.

**COMMIT:** `git commit -m "1993: verify 13 clean task cards unmodified"` (or no commit if no changes needed)

**SC coverage:** SC-6
**Evidence type:** `structural` — git diff shows no changes to those files

### Phase 3 Exit Criteria

- [ ] `000-critical-rules.md` contains sub-agent task() prohibition (SC-5)
- [ ] All 13 clean task cards have zero changes in git diff (SC-6)

---

## Verification Plan

### Per-SC Verification

| SC ID | Evidence Type | Verification Method |
|-------|---------------|-------------------|
| SC-1 | `string` | grep for dispatch rows in SKILL.md — count = 3 |
| SC-2 | `string` | grep for `task(` across all spec-creation task cards — 0 matches |
| SC-3 | `string` | grep for pipeline step labels in SKILL.md — found |
| SC-4 | `string` | grep for "orchestrator" in analytical-artifacts.md — 0 matches |
| SC-5 | `string` | grep for "task cards MUST NOT contain task()" in 000-critical-rules.md — found |
| SC-6 | `structural` | git diff shows no changes to 13 clean task cards |
| SC-7 | `string` | grep for "contracts/" in SKILL.md — 0 matches |
| SC-8 | `semantic` | Sub-agent reads SKILL.md pipeline section — confirms read/write specified |
| SC-9 | `semantic` | Sub-agent reads SKILL.md pipeline section — confirms contract format specified |
| SC-10 | `string` | grep for pipeline step order in SKILL.md — first 2 and last 2 steps match |
| SC-11 | `semantic` | Sub-agent reads create.md — confirms no remote issue creation instructions |
| SC-12 | `structural` | File exists at `spec-creation-validation/tasks/create-remote-stub.md` |
| SC-13 | `structural` | File exists at `spec-creation-validation/tasks/pre-spec-inspection.md` |
| SC-14 | `structural` | File exists at `spec-creation-validation/tasks/revise-remote-body.md` |
| SC-15 | `string` | grep for `task(` and `skill({name:` in create.md — 0 matches |
| SC-16 | `string` | grep for `project_root}/tmp/` in create.md — 0 matches |
| SC-17 | `semantic` | Sub-agent reads create.md — confirms result contract section present |
| SC-18 | `semantic` | Sub-agent reads create.md — confirms read-from-disk section present |
| SC-19 | `string` | grep for step numbers in create.md — verify monotonic sequence |
| SC-20 | `string` | grep for "read-issue" in create.md — 0 matches |
| SC-21 | `string` | grep for "pre-PR gate" in create.md — 0 matches |

## Safety/Rollback

| Phase | Destructive Ops | Rollback |
|-------|----------------|----------|
| 1 | Delete `operating-protocol.md` | `git checkout -- .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md` |
| 1 | Rewrite SKILL.md | `git checkout -- .opencode/skills/spec-creation/SKILL.md` |
| 2 | Rewrite `create.md` (746 lines) | `git checkout -- .opencode/skills/spec-creation-validation/tasks/create.md` |
| 2 | Modify 3 task cards | `git checkout` each modified file |
| 2 | Create 3 new files | `git rm` each new file |
| 3 | Append to `000-critical-rules.md` | `git checkout -- .opencode/guidelines/000-critical-rules.md` |
