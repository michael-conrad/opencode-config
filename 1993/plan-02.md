# Phase 2 — Task card cleanup

**Concern:** Task card structural correctness and frugal contract pattern

**Files:**
- `.opencode/skills/spec-creation-validation/tasks/create.md`
- `.opencode/skills/spec-creation-validation/tasks/completion.md`
- `.opencode/skills/spec-creation-change-control/tasks/change-control.md`
- `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`
- `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` (create)

**SCs:** SC-2, SC-4, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21

**Dependencies:** Phase 1 complete (SKILL.md has pipeline section)

**Entry conditions:** SKILL.md restructured, operating-protocol.md deleted

**Exit conditions:** All 4 modified task cards clean, 3 new task cards exist, no task() calls remain

**Code Path Coverage:** create.md (746 lines), completion.md (102 lines), change-control.md (154 lines), analytical-artifacts.md (172 lines)

**Cross-Cutting SCs:** SC-2 (no task() calls) applies to all 4 modified task cards

**Interface Boundaries:** Each task card is consumed by sub-agents — must contain only sub-agent-executable procedures, no orchestrator-level instructions

**State Transitions:** create.md transitions from orchestrator-level (with task() calls) to pure sub-agent procedure

---

- [ ] 10. **Remove 4 `task()` calls from `create.md` (**sub-agent**).** **→ SC-2, SC-15**
  - [ ] 10.1. **RED.** Write behavioral test that sends prompt to execute create.md as sub-agent and verifies no `task(` calls. Test fails because 4 calls exist.
  - [ ] 10.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Delete: Step 0 line `invoke verification-enforcement --task verify`. Delete: Step 1 line `Invoke issue-operations --task creation`. Delete: Step 27 line `invoke verification-enforcement --task revisit`. Delete: Step 9 `skill({name: "audit"})` then `task(...)`.
  - [ ] 10.3. **GREEN doublecheck (**inline**).** Run `grep -c 'task(' .opencode/skills/spec-creation-validation/tasks/create.md`. Should be 0. If not 0, revert and redo step 10.2.
  - [ ] 10.4. **Checkpoint commit (**inline**).** `git commit -m "1993: remove 4 task() calls from create.md (D-1)"`

- [ ] 11. **Replace `{project_root}/tmp/` paths in `create.md` (**sub-agent**).** **→ SC-16**
  - [ ] 11.1. **RED.** Write behavioral test that verifies create.md contains no `{project_root}/tmp/` paths. Test fails because 3 paths exist.
  - [ ] 11.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Replace `{project_root}/tmp/{issue-N}/lifecycle.yaml` with `.issues/{N}/lifecycle.yaml`. Replace `{project_root}/tmp/{issue-N}/artifacts/constraints-contract.yaml` with `.issues/{N}/artifacts/constraints-contract.yaml`. Replace `{project_root}/tmp/{issue-N}/artifacts/phase-plan-validated.yaml` with `.issues/{N}/artifacts/phase-plan-validated.yaml`.
  - [ ] 11.3. **GREEN doublecheck (**inline**).** Run `grep -c 'project_root}/tmp/' .opencode/skills/spec-creation-validation/tasks/create.md`. Should be 0. If not 0, revert and redo step 11.2.
  - [ ] 11.4. **Checkpoint commit (**inline**).** `git commit -m "1993: replace {project_root}/tmp/ paths with .issues/{N}/ in create.md (D-3)"`

- [ ] 12. **Add result contract section to `create.md` (**sub-agent**).** **→ SC-17**
  - [ ] 12.1. **RED.** Write behavioral test that verifies create.md contains a result contract section. Test fails because no result contract exists.
  - [ ] 12.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Append a `## Result Contract` section: `status: DONE | BLOCKED`, `finding_summary: "Spec #N written with M SCs"`, `artifact_path: .issues/{N}/spec.md`, `blocker_reason: "<why if BLOCKED>"`.
  - [ ] 12.3. **GREEN doublecheck (**inline**).** Read create.md — confirm result contract section present with all 4 fields.
  - [ ] 12.4. **Checkpoint commit (**inline**).** `git commit -m "1993: add result contract section to create.md (D-4)"`

- [ ] 13. **Add read-from-disk specification to `create.md` (**sub-agent**).** **→ SC-18**
  - [ ] 13.1. **RED.** Write behavioral test that verifies create.md contains a read-from-disk section. Test fails because no such section exists.
  - [ ] 13.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Add an `## Input Artifacts` section listing all 13 artifact paths from `.issues/{N}/artifacts/`.
  - [ ] 13.3. **GREEN doublecheck (**inline**).** Read create.md — confirm Input Artifacts section present with all paths.
  - [ ] 13.4. **Checkpoint commit (**inline**).** `git commit -m "1993: add read-from-disk specification to create.md (D-5)"`

- [ ] 14. **Renumber steps sequentially in `create.md` (**sub-agent**).** **→ SC-19**
  - [ ] 14.1. **RED.** Write behavioral test that verifies create.md has monotonically increasing step numbers. Test fails because steps are numbered 0, 1, 2, 3, 1, 1a, 1.1, etc.
  - [ ] 14.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Replace all step numbers with flat sequential numbering 1 through N. Remove all sub-step numbering: 0, 1a, 1.1, 1.2, 1.3, 1.35, 1.4, 1d, 1d.5 through 1d.11, 1e, 1f, 2a, 2b, 5.5, 5.6, 6.2, 6.5, 6.8, 7.1, 7.2, 7.3, 7.4. Each step gets a single integer: Step 1, Step 2, Step 3, etc.
  - [ ] 14.3. **GREEN doublecheck (**inline**).** Grep for step numbers in create.md — verify monotonic sequence with no duplicates.
  - [ ] 14.4. **Checkpoint commit (**inline**).** `git commit -m "1993: renumber steps sequentially in create.md (D-6)"`

- [ ] 15. **Replace remote API reads with local file reads in `create.md` (**sub-agent**).** **→ SC-20**
  - [ ] 15.1. **RED.** Write behavioral test that verifies create.md self-review reads from local file, not remote API. Test fails because Step 6.5 references `issue-operations -> read-issue`.
  - [ ] 15.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. In the self-review section, replace all `issue-operations -> read-issue` references with `read(filePath=".issues/{N}/spec.md")`.
  - [ ] 15.3. **GREEN doublecheck (**inline**).** Run `grep -c 'read-issue' .opencode/skills/spec-creation-validation/tasks/create.md`. Should be 0. If not 0, revert and redo step 15.2.
  - [ ] 15.4. **Checkpoint commit (**inline**).** `git commit -m "1993: replace remote API reads with local file reads in create.md (D-7)"`

- [ ] 16. **Remove forward reference to non-existent pre-PR gate (**sub-agent**).** **→ SC-21**
  - [ ] 16.1. **RED.** Write behavioral test that verifies create.md does not reference "pre-PR gate". Test fails because Step 7.3 references it.
  - [ ] 16.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Delete the section titled "Step 7.3: Pre-PR Gate (Enforcement Constraint)" (approximately line 724).
  - [ ] 16.3. **GREEN doublecheck (**inline**).** Run `grep -c 'pre-PR gate' .opencode/skills/spec-creation-validation/tasks/create.md`. Should be 0. If not 0, revert and redo step 16.2.
  - [ ] 16.4. **Checkpoint commit (**inline**).** `git commit -m "1993: remove forward reference to non-existent pre-PR gate (D-10)"`

- [ ] 17. **Remove remote issue creation from `create.md` (**sub-agent**).** **→ SC-2, SC-11**
  - [ ] 17.1. **RED.** Write behavioral test that verifies create.md does NOT create the remote issue. Test fails because Step 7.2 handles remote issue creation.
  - [ ] 17.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Delete the section titled "Step 7.2: Remote Issue Body (Exec Summary)" (approximately lines 646-722). This content moves to `create-remote-stub.md` (step 24) and `revise-remote-body.md` (step 26).
  - [ ] 17.3. **GREEN doublecheck (**inline**).** Read create.md — confirm no remote issue creation instructions remain.
  - [ ] 17.4. **Checkpoint commit (**inline**).** `git commit -m "1993: remove remote issue creation from create.md (D-2)"`

- [ ] 18. **Remove `skill()` call from `create.md` (**sub-agent**).** **→ SC-2, SC-15**
  - [ ] 18.1. **RED.** Write behavioral test that verifies create.md contains no `skill({name:` calls. Test fails because Step 5.6 references `skill({name: "plan"})`.
  - [ ] 18.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Find Step 5.6 (approximately line 539): `skill({name: "plan"})`. Replace with: "The SKILL.md pipeline handles `plan plan` as an inline orchestrator step — this sub-agent does not call it."
  - [ ] 18.3. **GREEN doublecheck (**inline**).** Run `grep -c 'skill({name:' .opencode/skills/spec-creation-validation/tasks/create.md`. Should be 0. If not 0, revert and redo step 18.2.
  - [ ] 18.4. **Checkpoint commit (**inline**).** `git commit -m "1993: remove skill() call from create.md (D-8)"`

- [ ] 19. **Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**sub-agent**).** **→ SC-16**
  - [ ] 19.1. **RED.** Write behavioral test that verifies create.md references `.issues/{N}/lifecycle.yaml`. Test fails because phantom path is used.
  - [ ] 19.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/create.md`. Find the lifecycle manifest step. Change path from `{project_root}/tmp/{issue-N}/lifecycle.yaml` to `.issues/{N}/lifecycle.yaml`. Document append-only semantics: "If `.issues/{N}/lifecycle.yaml` exists, append the new event. If it does not exist, create it with the initial event."
  - [ ] 19.3. **GREEN doublecheck (**inline**).** Run `grep 'lifecycle.yaml' .opencode/skills/spec-creation-validation/tasks/create.md`. Should reference `.issues/{N}/lifecycle.yaml`. If not, revert and redo step 19.2.
  - [ ] 19.4. **Checkpoint commit (**inline**).** `git commit -m "1993: move lifecycle manifest to .issues/{N}/lifecycle.yaml (D-9)"`

- [ ] 20. **Fix `analytical-artifacts.md` category error (**sub-agent**).** **→ SC-4**
  - [ ] 20.1. **RED.** Write behavioral test that verifies analytical-artifacts.md contains no orchestrator-level instructions. Test fails because file contains "orchestrator dispatches" and "(*orchestrator*)" labels.
  - [ ] 20.2. **GREEN.** Open `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`. Remove all "orchestrator dispatches via SKILL.md Trigger Dispatch Table" language. Remove all "(*orchestrator*)" labels. Rewrite procedure: sub-agent reads `.issues/{N}/spec.md`, writes 7 YAML files to `.issues/{N}/artifacts/`. Add result contract section. Add read-from-disk specification.
  - [ ] 20.3. **GREEN doublecheck (**inline**).** Run `grep -c 'orchestrator' .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`. Should be 0. If not 0, revert and redo step 20.2.
  - [ ] 20.4. **Checkpoint commit (**inline**).** `git commit -m "1993: fix analytical-artifacts.md category error — convert to sub-agent procedure"`

- [ ] 21. **Clean `completion.md` (**sub-agent**).** **→ SC-2**
  - [ ] 21.1. **RED.** Write behavioral test that verifies completion.md contains no `task(` calls. Test fails because 2 calls exist.
  - [ ] 21.2. **GREEN.** Open `.opencode/skills/spec-creation-validation/tasks/completion.md`. Remove the 2 `Dispatch task(...)` lines (holistic-self-check and push-artifacts). Convert to pure sub-agent procedure: check state, return result contract.
  - [ ] 21.3. **GREEN doublecheck (**inline**).** Run `grep -c 'task(' .opencode/skills/spec-creation-validation/tasks/completion.md`. Should be 0. If not 0, revert and redo step 21.2.
  - [ ] 21.4. **Checkpoint commit (**inline**).** `git commit -m "1993: remove task() calls from completion.md"`

- [ ] 22. **Clean `change-control.md` (**sub-agent**).** **→ SC-2**
  - [ ] 22.1. **RED.** Write behavioral test that verifies change-control.md contains no `task(` calls. Test fails because 1 call exists.
  - [ ] 22.2. **GREEN.** Open `.opencode/skills/spec-creation-change-control/tasks/change-control.md`. Remove the `Dispatch audit --task spec-audit` line (Step 3.5). Convert to pure sub-agent procedure: document changes, version spec, return result contract.
  - [ ] 22.3. **GREEN doublecheck (**inline**).** Run `grep -c 'task(' .opencode/skills/spec-creation-change-control/tasks/change-control.md`. Should be 0. If not 0, revert and redo step 22.2.
  - [ ] 22.4. **Checkpoint commit (**inline**).** `git commit -m "1993: remove task() calls from change-control.md"`

- [ ] 23. **Create `create-remote-stub.md` (**sub-agent**).** **→ SC-12**
  - [ ] 23.1. **RED.** Write behavioral test that verifies `create-remote-stub.md` exists. Test fails because file doesn't exist.
  - [ ] 23.2. **GREEN.** Create `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md`. Content: Purpose (obtain spec issue number, create stub file). Procedure: check platform, if remote create issue via API and save as `.issues/{N}/remote.md`, if local list `.issues/` dirs max+1 and create stub. Result contract: `{status: DONE, finding_summary, artifact_path: ".issues/{N}/remote.md", spec_number: N}`.
  - [ ] 23.3. **GREEN doublecheck (**inline**).** Run `ls .opencode/skills/spec-creation-validation/tasks/create-remote-stub.md`. Should exist. If not, redo step 23.2.
  - [ ] 23.4. **Checkpoint commit (**inline**).** `git commit -m "1993: create create-remote-stub.md task card"`

- [ ] 24. **Create `pre-spec-inspection.md` (**sub-agent**).** **→ SC-13**
  - [ ] 24.1. **RED.** Write behavioral test that verifies `pre-spec-inspection.md` exists. Test fails because file doesn't exist.
  - [ ] 24.2. **GREEN.** Create `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md`. Content: Purpose (check for superseding issues). Procedure: search GitHub Issues for open `[SPEC]` issues, check merged PRs, read codebase state, classify findings, write to `.issues/{N}/artifacts/pre-spec-inspection.yaml`. Return BLOCKED if CONFLICT-RISK or FULL-SUPERSESSION found.
  - [ ] 24.3. **GREEN doublecheck (**inline**).** Run `ls .opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md`. Should exist. If not, redo step 24.2.
  - [ ] 24.4. **Checkpoint commit (**inline**).** `git commit -m "1993: create pre-spec-inspection.md task card"`

- [ ] 25. **Create `revise-remote-body.md` (**sub-agent**).** **→ SC-14**
  - [ ] 25.1. **RED.** Write behavioral test that verifies `revise-remote-body.md` exists. Test fails because file doesn't exist.
  - [ ] 25.2. **GREEN.** Create `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md`. Content: Purpose (update remote issue body with correct folder links). Procedure: check platform, if local return SKIPPED, read `.issues/{N}/spec.md`, construct folder URL from session-init, update remote issue body via platform API. Result contract: `{status: DONE | SKIPPED}`.
  - [ ] 25.3. **GREEN doublecheck (**inline**).** Run `ls .opencode/skills/spec-creation-validation/tasks/revise-remote-body.md`. Should exist. If not, redo step 25.2.
  - [ ] 25.4. **Checkpoint commit (**inline**).** `git commit -m "1993: create revise-remote-body.md task card"`

- [ ] 26. **Verify all spec-creation task cards are clean (**sub-agent**).** **→ SC-2**
  - [ ] 26.1. **RED.** Write behavioral test that verifies no task card under any spec-creation sub-skill contains `task(`. Test fails because some task cards still have calls.
  - [ ] 26.2. **GREEN.** Run `grep -rn 'task(' .opencode/skills/spec-creation*/tasks/ --include='*.md'`. If any matches found, identify the file and revert the change that introduced it.
  - [ ] 26.3. **GREEN doublecheck (**inline**).** Re-run the grep — confirm 0 matches.
  - [ ] 26.4. **Checkpoint commit (**inline**).** `git commit -m "1993: verify all spec-creation task cards clean of task() calls"`

#### Phase 2 VbC

- [ ] 27. **VbC (**clean-room**).**

**Concern transition:** Leaving task card structural correctness → entering enforcement and regression prevention. Phase 3 depends on Phase 2's clean task cards being verified.
