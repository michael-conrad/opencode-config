# Plan: Refactor spec-creation skill

**Issue:** #1993
**Spec:** https://github.com/michael-conrad/.opencode/issues/1993
**Status:** DRAFT
**Created:** 2026-07-19

## Phase 1 — SKILL.md restructure

### Step 1.1 — Remove 8 fake dispatch entries from SKILL.md

1. Open `.opencode/skills/spec-creation/SKILL.md`
2. In the Trigger Dispatch Table, remove these rows: `requirements`, `decompose`, `analytical-artifacts`, `holistic-self-check`, `pipeline-readiness-gate`, `risk`, `traceability`, `operating-protocol`
3. In the Invocation table, remove the corresponding 8 entries
4. Verify: grep for dispatch rows in SKILL.md — count should be 2 (create, completion)
5. Commit: `git commit -m "1993: remove 8 fake dispatch entries from spec-creation SKILL.md"`

### Step 1.2 — Add `revise` dispatch entry to SKILL.md

1. Open `.opencode/skills/spec-creation/SKILL.md`
2. Add to Trigger Dispatch Table:
   - User says: `"revise spec" / "update spec"`
   - Task: `revise`
   - Dispatches To: `spec-creation-validation --task revise`
   - Dispatch: `sub-task`
   - Context passed: `{issue_number}`
3. Add to Invocation table:
   - Task: `revise`
   - Canonical Dispatch String: `task(..., prompt: "execute revise from spec-creation-validation. Read \`spec-creation-validation/tasks/revise.md\` first")`
4. Verify: grep for `revise` in SKILL.md dispatch table — found
5. Commit: `git commit -m "1993: add revise dispatch entry to spec-creation SKILL.md"`

### Step 1.3 — Add Pipeline section to SKILL.md

1. Open `.opencode/skills/spec-creation/SKILL.md`
2. After the Invocation table, add a `## Pipeline` section
3. Define the 25-step create procedure:

```
 1. [inline]  local-issues sync
 2. [sub-task] create-remote-stub
 3. [sub-task] pre-spec-inspection
 4. [sub-task] research-card-consultation
 5. [sub-task] requirements
 6. [sub-task] concern-analysis
 7. [sub-task] decompose
 8. [sub-task] blast-radius
 9. [sub-task] cross-cutting
10. [sub-task] traceability
11. [sub-task] code-path-analysis
12. [sub-task] interface-compatibility
13. [sub-task] state-analysis
14. [sub-task] pipeline-readiness-gate
15. [sub-task] testability-assessment
16. [sub-task] risk
17. [inline]  solve model
18. [inline]  solve check
19. [inline]  plan plan
20. [sub-task] interdependency-check
21. [sub-task] create (local only)
22. [sub-task] revise-remote-body
23. [inline]  local-issues sync
24. [sub-task] completion
25. [inline]  spec-audit
```

4. Define the 6-step revise procedure:

```
 1. [inline]  local-issues sync
 2. [sub-task] change-control
 3. [sub-task] revise-remote-body
 4. [inline]  spec-audit
 5. [inline]  local-issues sync
 6. [sub-task] completion
```

5. For each sub-task step, specify:
   - What the sub-agent reads from disk (`.issues/{N}/artifacts/{name}.yaml`)
   - What the sub-agent writes to disk (`.issues/{N}/artifacts/{name}.yaml`)
   - The result contract format: `{status, finding_summary, artifact_path, blocker_reason}`
6. Ensure no `{project_root}/tmp/{N}/contracts/` paths appear — all data passes through `.issues/{N}/artifacts/`
7. Verify: pipeline step labels exist in SKILL.md, no "contracts/" paths
8. Commit: `git commit -m "1993: add 25-step create and 6-step revise pipeline to spec-creation SKILL.md"`

### Step 1.4 — Delete `operating-protocol.md` task card

1. Run: `rm .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md`
2. Grep all spec-creation files for references to `operating-protocol.md` — if any remain, update them to reference the SKILL.md Pipeline section instead
3. Verify: file no longer exists
4. Commit: `git commit -m "1993: delete operating-protocol.md task card, content moved to SKILL.md"`

### Phase 1 Exit Criteria

- [ ] SKILL.md Trigger Dispatch Table has exactly 3 entries (create, revise, completion)
- [ ] `revise` dispatch entry exists in SKILL.md
- [ ] Pipeline section exists in SKILL.md with read/write/contract for each sub-task step
- [ ] No `{project_root}/tmp/{N}/contracts/` paths in SKILL.md pipeline
- [ ] Create pipeline starts with `local-issues sync`, ends with `local-issues sync`
- [ ] `operating-protocol.md` deleted

---

## Phase 2 — Task card cleanup

### Step 2.1 — Remove 4 `task()` calls from `create.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Remove Step 0: delete the line `invoke verification-enforcement --task verify`
3. Remove Step 1: delete the line `Invoke issue-operations --task creation`
4. Remove Step 27: delete the line `invoke verification-enforcement --task revisit`
5. Remove Step 9: delete `skill({name: "audit"})` then `task(...)`
6. Verify: grep for `task(` in create.md — 0 matches
7. Commit: `git commit -m "1993: remove 4 task() calls from create.md (D-1)"`

### Step 2.2 — Replace `{project_root}/tmp/` paths in `create.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Replace `{project_root}/tmp/{issue-N}/lifecycle.yaml` with `.issues/{N}/lifecycle.yaml`
3. Replace `{project_root}/tmp/{issue-N}/artifacts/constraints-contract.yaml` with `.issues/{N}/artifacts/constraints-contract.yaml`
4. Replace `{project_root}/tmp/{issue-N}/artifacts/phase-plan-validated.yaml` with `.issues/{N}/artifacts/phase-plan-validated.yaml`
5. Verify: grep for `project_root}/tmp/` in create.md — 0 matches
6. Commit: `git commit -m "1993: replace {project_root}/tmp/ paths with .issues/{N}/ in create.md (D-3)"`

### Step 2.3 — Add result contract section to `create.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Add a `## Result Contract` section at the end of the file:

```yaml
## Result Contract

status: DONE | BLOCKED
finding_summary: "Spec #N written with M SCs"
artifact_path: .issues/{N}/spec.md
blocker_reason: "<why if BLOCKED>"
```

3. Verify: sub-agent reading create.md confirms result contract section present
4. Commit: `git commit -m "1993: add result contract section to create.md (D-4)"`

### Step 2.4 — Add read-from-disk specification to `create.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Add an `## Input Artifacts` section after the Entry Criteria:

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

3. Verify: sub-agent reading create.md confirms read-from-disk section present
4. Commit: `git commit -m "1993: add read-from-disk specification to create.md (D-5)"`

### Step 2.5 — Renumber steps sequentially in `create.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Replace all step numbers with flat sequential numbering 1 through N
3. Remove all sub-step numbering: 0, 1a, 1.1, 1.2, 1.3, 1.35, 1.4, 1d, 1d.5, 1d.6, 1d.7, 1d.8, 1d.9, 1d.10, 1d.11, 1e, 1f, 2a, 2b, 5.5, 5.6, 6.2, 6.5, 6.8, 7.1, 7.2, 7.3, 7.4
4. Each step gets a single integer: Step 1, Step 2, Step 3, etc.
5. Verify: step numbers are monotonically increasing with no duplicates
6. Commit: `git commit -m "1993: renumber steps sequentially in create.md (D-6)"`

### Step 2.6 — Replace remote API reads with local file reads in `create.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. In the self-review section (formerly Step 6.5), replace all `issue-operations -> read-issue` references with `read(filePath=".issues/{N}/spec.md")`
3. Verify: grep for "read-issue" in create.md — 0 matches
4. Commit: `git commit -m "1993: replace remote API reads with local file reads in create.md (D-7)"`

### Step 2.7 — Remove forward reference to non-existent pre-PR gate

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Delete the section titled "Step 7.3: Pre-PR Gate (Enforcement Constraint)" — approximately lines 724
3. Verify: grep for "pre-PR gate" in create.md — 0 matches
4. Commit: `git commit -m "1993: remove forward reference to non-existent pre-PR gate (D-10)"`

### Step 2.8 — Remove remote issue creation from `create.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Delete the section titled "Step 7.2: Remote Issue Body (Exec Summary)" — approximately lines 646-722
3. This content moves to `create-remote-stub.md` (Step 2.13) and `revise-remote-body.md` (Step 2.15)
4. Verify: sub-agent reading create.md confirms no remote issue creation instructions
5. Commit: `git commit -m "1993: remove remote issue creation from create.md (D-2)"`

### Step 2.9 — Remove `skill()` call from `create.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Find Step 5.6 (approximately line 539): `skill({name: "plan"})`
3. Replace with: "The SKILL.md pipeline handles `plan plan` as an inline orchestrator step — this sub-agent does not call it."
4. Verify: grep for `skill({name:` in create.md — 0 matches
5. Commit: `git commit -m "1993: remove skill() call from create.md (D-8)"`

### Step 2.10 — Move lifecycle manifest to `.issues/{N}/lifecycle.yaml`

1. Open `.opencode/skills/spec-creation-validation/tasks/create.md`
2. Find the lifecycle manifest step (formerly Step 1.3)
3. Change path from `{project_root}/tmp/{issue-N}/lifecycle.yaml` to `.issues/{N}/lifecycle.yaml`
4. Document append-only semantics: "If `.issues/{N}/lifecycle.yaml` exists, append the new event. If it does not exist, create it with the initial event."
5. Verify: grep for `lifecycle.yaml` in create.md — references `.issues/{N}/lifecycle.yaml`
6. Commit: `git commit -m "1993: move lifecycle manifest to .issues/{N}/lifecycle.yaml (D-9)"`

### Step 2.11 — Fix `analytical-artifacts.md` category error

1. Open `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`
2. Remove all "orchestrator dispatches via SKILL.md Trigger Dispatch Table" language
3. Remove all "(*orchestrator*)" labels
4. Rewrite the procedure so the sub-agent:
   - Reads `.issues/{N}/spec.md` from disk
   - Writes 7 YAML files to `.issues/{N}/artifacts/`:
     - `blast-radius.yaml`
     - `concern-map.yaml`
     - `code-path-inventory.yaml`
     - `cross-cutting-matrix.yaml`
     - `interface-compatibility.yaml`
     - `state-analysis.yaml`
     - `testability-assessment.yaml`
5. Add a result contract section
6. Add a read-from-disk specification
7. Verify: grep for "orchestrator" in analytical-artifacts.md — 0 matches
8. Commit: `git commit -m "1993: fix analytical-artifacts.md category error — convert to sub-agent procedure"`

### Step 2.12 — Clean `completion.md` and `change-control.md`

1. Open `.opencode/skills/spec-creation-validation/tasks/completion.md`
2. Remove the 2 `Dispatch task(...)` lines (holistic-self-check and push-artifacts)
3. Convert to pure sub-agent procedure: check state, return result contract
4. Open `.opencode/skills/spec-creation-change-control/tasks/change-control.md`
5. Remove the `Dispatch audit --task spec-audit` line (Step 3.5)
6. Convert to pure sub-agent procedure: document changes, version spec, return result contract
7. Verify: grep for `task(` in completion.md — 0 matches; grep for `task(` in change-control.md — 0 matches
8. Commit: `git commit -m "1993: remove task() calls from completion.md and change-control.md"`

### Step 2.13 — Create `create-remote-stub.md`

1. Create `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md`
2. File content:

```markdown
# Task: create-remote-stub

## Purpose

Obtain the spec issue number and create the stub file. Handles both remote and local platforms transparently — the orchestrator always gets a spec number back the same way.

## Procedure

1. Check `github.platform` from session-init
2. If remote API available (`github` or `gitbucket`):
   a. Create issue via platform API with minimal body (title, `needs-approval` label)
   b. Extract `issue_number` and `html_url` from API response
   c. Save response as `.issues/{N}/remote.md`
3. If local (no remote API):
   a. List directories in `.issues/`, find max number, add 1
   b. Create `.issues/{N}/remote.md` with stub content and local spec number
4. Return result contract

## Result Contract

status: DONE
finding_summary: "Issue #N created via <platform>"
artifact_path: ".issues/{N}/remote.md"
spec_number: N
blocker_reason: null
```

3. Verify: file exists
4. Commit: `git commit -m "1993: create create-remote-stub.md task card"`

### Step 2.14 — Create `pre-spec-inspection.md`

1. Create `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md`
2. File content:

```markdown
# Task: pre-spec-inspection

## Purpose

Check for superseding issues, already-implemented specs, and codebase state before the spec is written.

## Procedure

1. Search GitHub Issues for open `[SPEC]` issues with overlapping scope
2. Check for already-implemented specs (merged PRs with related functionality)
3. Read codebase state for affected files
4. Classify findings: FULL-SUPERSESSION, PARTIAL-OVERLAP, CONFLICT-RISK, INDEPENDENT
5. Write findings to `.issues/{N}/artifacts/pre-spec-inspection.yaml`
6. If CONFLICT-RISK or FULL-SUPERSESSION found, return BLOCKED

## Result Contract

status: DONE | BLOCKED
finding_summary: "<classification summary>"
artifact_path: ".issues/{N}/artifacts/pre-spec-inspection.yaml"
blocker_reason: "CONFLICT-RISK with #M" (if BLOCKED)
```

3. Verify: file exists
4. Commit: `git commit -m "1993: create pre-spec-inspection.md task card"`

### Step 2.15 — Create `revise-remote-body.md`

1. Create `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md`
2. File content:

```markdown
# Task: revise-remote-body

## Purpose

Update the remote issue body with correct `.issues/{N}/` folder links after the local spec is written.

## Procedure

1. Check `github.platform` — if `local`, return SKIPPED
2. Read `.issues/{N}/spec.md` for the spec content
3. Construct the `.issues/{N}/` folder URL from session-init values
4. Update the remote issue body via platform API with the spec reference blockquote
5. Return result contract

## Result Contract

status: DONE | SKIPPED
finding_summary: "Remote body updated" | "No remote API — skipped"
artifact_path: null
blocker_reason: null
```

3. Verify: file exists
4. Commit: `git commit -m "1993: create revise-remote-body.md task card"`

### Phase 2 Exit Criteria

- [ ] `create.md` contains no `task(` or `skill({name:` calls
- [ ] `create.md` contains no `{project_root}/tmp/` paths
- [ ] `create.md` contains result contract section
- [ ] `create.md` contains read-from-disk specification
- [ ] `create.md` has sequentially numbered steps
- [ ] `create.md` self-review reads from local `.issues/{N}/spec.md`
- [ ] `create.md` does not reference "pre-PR gate"
- [ ] `create.md` does NOT create the remote issue
- [ ] `completion.md` has no `task(` calls
- [ ] `change-control.md` has no `task(` calls
- [ ] `analytical-artifacts.md` has no orchestrator-level instructions
- [ ] `create-remote-stub.md` exists
- [ ] `pre-spec-inspection.md` exists
- [ ] `revise-remote-body.md` exists
- [ ] No task card under any spec-creation sub-skill contains `task(...)`

---

## Phase 3 — Critical violation + verification

### Step 3.1 — Add critical violation to `000-critical-rules.md`

1. Open `.opencode/guidelines/000-critical-rules.md`
2. Find the Tier 2 (process-integrity) section
3. Append:

```
### [critical-rules-XXX] CRITICAL VIOLATION — Sub-agent task cards MUST NOT contain task() or skill() calls
Only orchestrator-level SKILL.md files may contain dispatch instructions. A task card that contains a task() or skill() call is structurally defective — the sub-agent cannot execute it. This applies to ALL task cards across ALL skills. Violation: HALT with blocker report.
```

4. Verify: grep for "task cards MUST NOT contain task()" in 000-critical-rules.md — found
5. Commit: `git commit -m "1993: add critical violation for sub-agent task() calls in task cards"`

### Step 3.2 — Verify 13 clean task cards unmodified

1. Run: `git diff -- .opencode/skills/spec-creation-requirements/tasks/requirements.md .opencode/skills/spec-creation-decomposition/tasks/decompose.md .opencode/skills/spec-creation-decomposition/tasks/blast-radius.md .opencode/skills/spec-creation-decomposition/tasks/code-path-analysis.md .opencode/skills/spec-creation-decomposition/tasks/concern-analysis.md .opencode/skills/spec-creation-decomposition/tasks/cross-cutting.md .opencode/skills/spec-creation-decomposition/tasks/state-analysis.md .opencode/skills/spec-creation-decomposition/tasks/testability-assessment.md .opencode/skills/spec-creation-decomposition/tasks/interface-compatibility.md .opencode/skills/spec-creation-validation/tasks/holistic-self-check.md .opencode/skills/spec-creation-validation/tasks/pipeline-readiness-gate.md .opencode/skills/spec-creation-validation/tasks/risk.md .opencode/skills/spec-creation-validation/tasks/traceability.md`
2. If any changes detected, revert them: `git checkout -- <file>`
3. Verify: git diff shows zero changes to those files
4. Commit: `git commit -m "1993: verify 13 clean task cards unmodified"` (only if changes were reverted)

### Phase 3 Exit Criteria

- [ ] `000-critical-rules.md` contains sub-agent task() prohibition
- [ ] All 13 clean task cards have zero changes in git diff

---

## Verification Plan

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
