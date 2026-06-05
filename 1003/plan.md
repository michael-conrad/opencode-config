# Plan: #1003 — Resolve Session-Start Context Conflicts

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Cross-ref: https://github.com/michael-conrad/.opencode/issues/1003
Plan URL: https://github.com/michael-conrad/opencode-config/blob/issues-data/1003/plan.md
Z3 contract: https://github.com/michael-conrad/opencode-config/blob/issues-data/1003/artifacts/phase-dependency-contract.yaml
Pipeline state machine: `skills/implementation-pipeline/pipeline-state-machine.yaml`

Authorization scope: `for_implementation` (label: `approved-for-implementation`)
PR strategy: `stacked` — one branch, one PR for all phases
Pipeline phases: 6 phases, each with 14-stage implementation-pipeline dispatch

### Tag Convention

Checkpoint tag format per git-workflow SKILL.md:
```
<parent>/checkpoint/<issue>/phase-<N>-<submodule>
```
Example for issue #1003, `.opencode` submodule, phase 1:
```
opencode-config/checkpoint/1003/phase-1-opencode
```
The suffix `-opencode` is derived from the submodule directory name in `.gitmodules`.

Each verification PASS creates a checkpoint tag. Rollback uses:
```
git reset --hard opencode-config/checkpoint/1003/phase-<N>-opencode
```

---

## Phase Dependency (Z3-Verified)

```
Phase 1 (default.txt) —           PREREQ: none
Phase 2 (rename) —                PREREQ: none
Phase 3 (guideline trims) —       PREREQ: Phase 1
  ├─ N1..N13 sub-steps: INDEPENDENT (parallel RED/GREEN possible)
Phase 4 (auth edge case) —        PREREQ: Phase 3 N2 (010-approval-gate.md)
Phase 5 (behavioral tests) —      PREREQ: Phase 1,2,3,4
Phase 6 (string tests) —          PREREQ: Phase 1,2 (can overlap Phase 3,4)
```

- **Phase 1 and Phase 2** can run in parallel (no cross-dependency)
- **Phase 3** starts after Phase 1. 13 sub-steps are independent — each can dispatch its own RED/GREEN pipeline
- **Phase 4** starts after Phase 3 sub-step N2 (010-approval-gate.md trim is done)
- **Phase 5** (behavioral tests) is the FINAL gate — requires ALL prior phases
- **Phase 6** (string tests) can start after Phase 1+2, overlapping with Phase 3+4

---

## Phase 1: default.txt — Delete Line 146 + Add Startup Mode + Condense

**14-stage pipeline** (`skills/implementation-pipeline/pipeline-state-machine.yaml`)

### Phase 1 Sub-Steps

- [ ] 1.1. CHECKPOINT: Tag current state as rollback anchor 0
  - `git tag opencode-config/checkpoint/1003/phase-1-init-state`
  - `git push origin opencode-config/checkpoint/1003/phase-1-init-state`
  - Purpose: captures the unchanged default.txt as rollback point for the entire phase

- [ ] 1.2. sc-coherence-gate: Verify spec/plan coherence before RED routing
  - Dispatch: `adversarial-audit --task coherence-extraction`
  - Z3 state: `solve state update --var-name previous_step --var-value init --var-name current_step --var-value sc-coherence-gate --var-name pipeline_state --var-value running`
  - On COHERENCE FAIL: reset to checkpoint tag 1.1, re-dispatch after resolving

- [ ] 1.3. pre-red-baseline: Initialize pipeline state
  - Dispatch: `solve state init ./tmp/state/1003/pipeline/`
  - Environment: capture current default.txt SHA for RED baseline evidence

- [ ] 1.4. red-phase: Write behavioral RED test — verify agent pre-reads tool source before dispatch
  - Dispatch: `test-driven-development --task red`
  - RED artifact: `.opencode/tests/behaviors/tier1-mandate-enforcement.sh` or new scenario
  - Test runner: `bash .opencode/tests/with-test-home opencode-cli run '<prompt>' --model <model>`
  - Assertion: `assert_semantic "SC-4" "Agent pre-reads tool source before behavioral observation"`
  - SC-4 target: agent DOES pre-read -> RED passes (agent hasn't been fixed yet)
  - SC-11 target: agent DOES pre-read -> RED passes
  - Z3 state: `solve state update --var-name previous_step --var-value pre-red-baseline --var-name current_step --var-value red-phase`; `solve check`

- [ ] 1.5. red-doublecheck: Verify RED-side SC evidence
  - Dispatch: `verification-before-completion --task verify`
  - Verify: SC-4 RED test fails (pre-read still happens), SC-11 RED test fails
  - Z3 state: `solve state update --var-name previous_step --var-value red-phase --var-name current_step --var-value red-doublecheck`; `solve check`
  - **On RED-DOUBLECHECK PASS** → create checkpoint tag 1:
    - `git tag opencode-config/checkpoint/1003/phase-1-red-pass`
    - `git push origin opencode-config/checkpoint/1003/phase-1-red-pass`
    - Rollback target if GREEN fails: `git reset --hard opencode-config/checkpoint/1003/phase-1-red-pass`

- [ ] 1.6. green-phase: Implement default.txt changes
  - Dispatch: `test-driven-development --task green`
  - DELETE line 146 from `default.txt`
    - Remove the sentence that authorizes the pre-read cascade
  - ADD startup mode identity section (per spec)
    - Insert DISCUSSION/PLANNING persona block before authorization section
  - CONDENSE default.txt (remove cruft without lobotomy)
    - Strip redundant/duplicate directives that survive relocation
    - **Protect any `## Agent Tools` section** that #1015 may have added
  - Z3 state: `solve state update --var-name previous_step --var-value red-doublecheck --var-name current_step --var-value green-phase`; `solve check`

- [ ] 1.7. checkpoint-commit: Commit default.txt changes
  - Dispatch: `git-workflow --task commit-prep`
  - Commit message: `feat(#1003): delete line 146, add startup mode identity, condense default.txt`
  - Z3 state: `solve state update --var-name previous_step --var-value green-phase --var-name current_step --var-value checkpoint-commit`; `solve check`
  - **On COMMIT** → create checkpoint tag 2:
    - `git tag opencode-config/checkpoint/1003/phase-1-green-committed`
    - `git push origin opencode-config/checkpoint/1003/phase-1-green-committed`
    - Rollback if green-doublecheck fails: `git reset --hard opencode-config/checkpoint/1003/phase-1-green-committed`

- [ ] 1.8. structural-checks: Lint + format pass
  - Dispatch: `finishing-a-development-branch --task checklist`
  - Run: `uvx pymarkdownlnt scan -r .opencode/guidelines/` (for default.txt)
  - Run: `uvx ruff format` (for adjacent Python files)
  - Z3 state: `solve state update --var-name previous_step --var-value checkpoint-commit --var-name current_step --var-value structural-checks`; `solve check`

- [ ] 1.9. green-doublecheck: Verify GREEN-side SC evidence
  - Dispatch: `verification-before-completion --task verify`
  - Verify SC-1: default.txt no longer contains line 146 (string: grep)
  - Verify SC-2: default.txt contains startup mode identity section (string: grep)
  - Verify SC-8: loading order confirmed (string: grep)
  - Verify SC-4 GREEN: re-run behavioral test — agent dispatches without pre-reading
  - Z3 state: `solve state update --var-name previous_step --var-value structural-checks --var-name current_step --var-value green-doublecheck`; `solve check`
  - **On GREEN-DOUBLECHECK PASS** → create checkpoint tag 3:
    - `git tag opencode-config/checkpoint/1003/phase-1-green-verified`
    - `git push origin opencode-config/checkpoint/1003/phase-1-green-verified`
    - Rollback if audit fails: `git reset --hard opencode-config/checkpoint/1003/phase-1-green-verified`

- [ ] 1.10. green-vbc: VbC completion artifact
  - Dispatch: `verification-before-completion --task completion`
  - Artifact: `./tmp/artifacts/pipeline-1003-phase1-default-txt-DONE-{timestamp}.yaml`
  - Z3 state: `solve state update --var-name previous_step --var-value green-doublecheck --var-name current_step --var-value green-vbc`; `solve check`

- [ ] 1.11. adversarial-audit: Dual-auditor verification
  - Dispatch: `adversarial-audit --task verification-audit`
  - Two clean-room auditor sub-agents review default.txt changes
  - Auditors return: status, findings, blocker_reason
  - Z3 state: `solve state update --var-name previous_step --var-value green-vbc --var-name current_step --var-value adversarial-audit`; `solve check`
  - **On AUDIT FAIL**: reset to checkpoint tag 3 (`opencode-config/checkpoint/1003/phase-1-green-verified`), fix, re-run GREEN pipeline from 1.6

- [ ] 1.12. cross-validate: Cross-family validation
  - Dispatch: `adversarial-audit --task cross-validate`
  - Compare both auditor verdicts, flag disagreements
  - Z3 state: `solve state update --var-name previous_step --var-value adversarial-audit --var-name current_step --var-value cross-validate`; `solve check`
  - **On CROSS-VALIDATE PASS** → create checkpoint tag 4:
    - `git tag opencode-config/checkpoint/1003/phase-1-audited`
    - `git push origin opencode-config/checkpoint/1003/phase-1-audited`
    - Rollback if regression fails: `git reset --hard opencode-config/checkpoint/1003/phase-1-audited`

- [ ] 1.13. regression-check: Verify nothing broken
  - Dispatch: `test-driven-development --task patterns` (regression mode)
  - Run existing behavioral tests that should still pass
  - Z3 state: `solve state update --var-name previous_step --var-value cross-validate --var-name current_step --var-value regression-check`; `solve check`

- [ ] 1.14. review-prep: Prepare for PR review
  - Dispatch: `git-workflow --task review-prep`
  - Verify branch state, commit structure
  - Z3 state: `solve state update --var-name previous_step --var-value regression-check --var-name current_step --var-value review-prep`; `solve check`

- [ ] 1.15. exec-summary: Phase 1 completion report
  - Dispatch: `completion-core --task completion`
  - Push commits, post issue comment with phase 1 status
  - Z3 state: `solve state update --var-name previous_step --var-value review-prep --var-name current_step --var-value exec-summary --var-name pipeline_state --var-value complete`; `solve check`
  - **On PHASE COMPLETE** → create checkpoint tag 5:
    - `git tag opencode-config/checkpoint/1003/phase-1-complete`
    - `git push origin opencode-config/checkpoint/1003/phase-1-complete`

---

## Phase 2: Rename investigate→observe Across All Files

**PREREQ: none — can run in parallel with Phase 1.**

**Per-file RED/GREEN pairs.**

### Files to modify

| # | File | Location |
|---|------|----------|
| 2.1 | `default.txt` | `.opencode/` |
| 2.2 | `AGENTS.md` | root |
| 2.3 | `AGENTS.md` | `.opencode/` |
| 2.4 | `010-approval-gate.md` | `.opencode/guidelines/` |
| 2.5 | `020-go-prohibitions.md` | `.opencode/guidelines/` |
| 2.6 | `brainstorming` skill | `.opencode/skills/brainstorming/` |
| 2.7 | `executing-plans` skill | `.opencode/skills/executing-plans/` |
| 2.8 | `git-workflow` skill | `.opencode/skills/git-workflow/` |
| 2.9 | `using-git-worktrees` skill | `.opencode/skills/using-git-worktrees/` |

### Phase 2 Checkpoint Tags

```
opencode-config/checkpoint/1003/phase-2-init-state     — before any rename
opencode-config/checkpoint/1003/phase-2-all-renamed     — after all 9 files renamed
opencode-config/checkpoint/1003/phase-2-verified         — after SC-9 string test passes
```

### Phase 2 Sub-Steps

- [ ] 2.0. CHECKPOINT: Tag current state as rollback anchor
  - `git tag opencode-config/checkpoint/1003/phase-2-init-state`
  - `git push origin opencode-config/checkpoint/1003/phase-2-init-state`

For each file 2.1–2.9:
- [ ] 2.N.1. RED: Write string test asserting `investigate/` appears in file (fails after rename)
- [ ] 2.N.2. GREEN: Replace `investigate-` with `observe-` and `investigate/` with `observe/` in file
- [ ] 2.N.3. VERIFY: String test now passes — no `investigate-` or `investigate/` remains
- [ ] 2.N.4. COMMIT: `feat(#1003): rename investigate→observe in <filename>`

### Phase 2 Completion

- [ ] 2.10. Verify SC-9: `grep -r 'investigate-' .opencode/ --include='*.md'` returns empty
- [ ] 2.11. CHECKPOINT: Tag post-rename state
  - `git tag opencode-config/checkpoint/1003/phase-2-all-renamed`
  - `git push origin opencode-config/checkpoint/1003/phase-2-all-renamed`
- [ ] 2.12. Full structural checks + push
- [ ] 2.13. CHECKPOINT: Tag verified state
  - `git tag opencode-config/checkpoint/1003/phase-2-verified`
  - `git push origin opencode-config/checkpoint/1003/phase-2-verified`

---

## Phase 3: Guideline File Trims (13 Files)

**PREREQ: Phase 1 complete. Sub-steps N1–N13 are INDEPENDENT — each can parallelize.**

For each file, the semantic filter:
1. **Content that must fire every session (Tier 1 safety-critical)** → stays in the guideline
2. **Content that semantically fires when a specific skill/trigger is invoked (Tier 2/3)** → moves verbatim to the destination skill card
3. **yaml+symbolic machine-enforcement block** → stays (consumed by hooks)
4. **No shell stubs or routing entries**

### Phase 3 Checkpoint Tags

```
opencode-config/checkpoint/1003/phase-3-init-state      — before any trims
opencode-config/checkpoint/1003/phase-3-N-<file>-done    — per file after commit
opencode-config/checkpoint/1003/phase-3-all-trimmed       — all 13 files committed
opencode-config/checkpoint/1003/phase-3-verified           — SC-3 verified
```

### Phase 3 Sub-Steps

- [ ] 3.0. CHECKPOINT: Tag current state (POST Phase 1)
  - `git tag opencode-config/checkpoint/1003/phase-3-init-state`
  - `git push origin opencode-config/checkpoint/1003/phase-3-init-state`

### Per-File Sub-Steps (applied to each 3.1–3.13)

- [ ] 3.N.1. READ: Read full guideline file content
- [ ] 3.N.2. ANALYZE: Classify each section as Tier 1 (stays) or Tier 2/3 (move to skill)
  - Tier 1 = safety-critical, must fire every session unconditionally
  - Tier 2/3 = process, workflow, procedural — moves to destination skill card
- [ ] 3.N.3. RED: Write string/content-verification test asserting Tier 1 content exists (passes now)
- [ ] 3.N.4. GREEN: Trim file — remove Tier 2/3 content, keep Tier 1 + yaml+symbolic block
- [ ] 3.N.5. RED (skill side): Verify destination skill card content exists (fails — not moved yet)
- [ ] 3.N.6. GREEN (skill side): Append relocated content to destination skill card
- [ ] 3.N.7. VERIFY: String test still passes for Tier 1; skill card now contains relocated content
- [ ] 3.N.8. COMMIT: `feat(#1003): trim <guideline> → relocate Tier 2/3 prose to <destination-skill>`
- [ ] 3.N.9. CHECKPOINT: Tag per-file done
  - `git tag opencode-config/checkpoint/1003/phase-3-N-<file>-done`
  - `git push origin opencode-config/checkpoint/1003/phase-3-N-<file>-done`

### Files and Destinations

- [ ] 3.1. **000-critical-rules.md** → (Tier 1 stays; Tier 2/3 already DONE per spec)
- [ ] 3.2. **010-approval-gate.md** → `approval-gate` skill (retain mandate tiering + Tier 1; move procedures)
  - **Phase 4 depends on this sub-step completing**
- [ ] 3.3. **020-go-prohibitions.md** → `approval-gate` / `implementation-pipeline` skills (retain Tier 1 prohibitions; move cost model, context discipline, iterative guidance)
- [ ] 3.4. **060-tool-usage.md** → `mcp-tool-usage` skill (retain path rules, API mandate, platform routing; move tool selection guidance)
- [ ] 3.5. **065-verification-honesty.md** → `verification` / `verification-before-completion` skills (retain honesty principle; move cost model, evidence hierarchy)
- [ ] 3.6. **067-context-completeness.md** → `issue-operations` skill (retain mandate to read all comments; move procedural detail)
- [ ] 3.7. **075-docs-verification.md** → `engineering-approach` skill (retain verification mandate; move checklists)
- [ ] 3.8. **080-code-standards.md** → `test-driven-development` skill (retain code standards, attribution, taxonomy; move enforcement test procedures)
- [ ] 3.9. **090-data-integrity.md** → relevant skills (retain global prohibitions; move batch procedures)
- [ ] 3.10. **091-incremental-build.md** → `test-driven-development` / `implementation-pipeline` skills (retain TDD mandate; move per-item procedures)
- [ ] 3.11. **117-session-trigger-behavior.md** → (retain no-echo rule + trigger behavior map — short, dense, fires every session)
- [ ] 3.12. **130-authority-source.md** → `brainstorming` / `spec-creation` skills (retain code-over-doc; move procedural checklist)
- [ ] 3.13. **AGENTS.md** (both root and `.opencode/`) → respective skill triggers (retain identity detection, dispatch gate, build commands; move operational workflow descriptions)

### Phase 3 Completion

- [ ] 3.14. CHECKPOINT: All 13 files trimmed
  - `git tag opencode-config/checkpoint/1003/phase-3-all-trimmed`
  - `git push origin opencode-config/checkpoint/1003/phase-3-all-trimmed`
- [ ] 3.15. Verify SC-3: 10-file spot check — every relocated rule maps to a skill card, no content destroyed, no lobotomized entries
- [ ] 3.16. CHECKPOINT: Verified state
  - `git tag opencode-config/checkpoint/1003/phase-3-verified`
  - `git push origin opencode-config/checkpoint/1003/phase-3-verified`

---

## Phase 4: Auth Edge Case Documentation

**PREREQ: Phase 3 sub-step N2 (010-approval-gate.md trim) complete**

### Phase 4 Checkpoint Tags

```
opencode-config/checkpoint/1003/phase-4-documented     — after GREEN commit
opencode-config/checkpoint/1003/phase-4-verified        — after SC-10 verification
```

- [ ] 4.0. CHECKPOINT: Tag current state
  - `git tag opencode-config/checkpoint/1003/phase-4-init-state`
  - `git push origin opencode-config/checkpoint/1003/phase-4-init-state`
- [ ] 4.1. RED: Write content-verification test — auth-over-directive not documented yet
- [ ] 4.2. GREEN: Add auth-over-directive edge case to `approval-gate` skill SKILL.md
  - "approved"/"go" overrides any prior directive scope with context flush
  - Auth received while a prior directive-limited scope is active = scope expansion + context flush
  - Document alongside existing scope model
- [ ] 4.3. VERIFY SC-10: Auth-over-directive edge case documented
- [ ] 4.4. CHECKPOINT: Tag documented state
  - `git tag opencode-config/checkpoint/1003/phase-4-documented`
  - `git push origin opencode-config/checkpoint/1003/phase-4-documented`
- [ ] 4.5. COMMIT: `feat(#1003): document auth-over-directive edge case in approval-gate skill`
- [ ] 4.6. CHECKPOINT: Tag verified state
  - `git tag opencode-config/checkpoint/1003/phase-4-verified`
  - `git push origin opencode-config/checkpoint/1003/phase-4-verified`

---

## Phase 5: Behavioral Tests (SC-4, SC-5, SC-11)

**PREREQ: Phases 1, 2, 3, 4 — must run AFTER all changes are in place.**

### Phase 5 Checkpoint Tags

```
opencode-config/checkpoint/1003/phase-5-green-committed   — after SC tests committed
opencode-config/checkpoint/1003/phase-5-green-verified      — after all 3 behavioral tests pass
```

### Test Infrastructure

Each test uses `with-test-home --checkout` for tag-based RED/GREEN protocol:
```
RED:   git checkout opencode-config/checkpoint/1003/phase-<N>-<suffix>  (before change)
GREEN: git checkout opencode-config/checkpoint/1003/phase-<N+1>-<suffix> (after change)
```

- [ ] 5.0. CHECKPOINT: Tag all-changes-applied state
  - `git tag opencode-config/checkpoint/1003/phase-5-init-state`
  - `git push origin opencode-config/checkpoint/1003/phase-5-init-state`
- [ ] 5.1. SC-4 Behavioral Test: Agent does not pre-read tool source before behavioral observation
  - RED: `git checkout opencode-config/checkpoint/1003/phase-1-init-state` — agent pre-reads (RED passes)
  - GREEN: `git checkout opencode-config/checkpoint/1003/phase-1-complete` — agent dispatches without pre-reading
  - Command: `bash .opencode/tests/with-test-home opencode-cli run 'investigate what this tool does' --model <model>`
  - Assertion: `assert_semantic "SC-4" "Agent observes tool behavior before reading source"`
- [ ] 5.2. SC-5 Behavioral Test: Agent dispatches skill() on "approved" without pre-reading
  - RED: Pre-change — agent pre-reads skill files on approval
  - GREEN: Post-change — agent dispatches via skill() without pre-reading
  - Assertion: `assert_semantic "SC-5" "On approved, agent calls skill() then dispatches without pre-reading skill task files"`
- [ ] 5.3. SC-11 Behavioral Test: Post-implementation planning prompt observes zero pre-reading
  - RED: Pre-change — agent pre-reads tool source
  - GREEN: Post-change — agent dispatches research sub-agent instead
  - Assertion: `assert_semantic "SC-11" "Agent dispatches research sub-agent for tool investigation, does not read source inline"`
- [ ] 5.4. COMMIT all behavioral test files: `feat(#1003): add behavioral tests for SC-4, SC-5, SC-11`
- [ ] 5.5. CHECKPOINT: Tag green committed
  - `git tag opencode-config/checkpoint/1003/phase-5-green-committed`
  - `git push origin opencode-config/checkpoint/1003/phase-5-green-committed`
- [ ] 5.6. RUN all 3 behavioral tests in GREEN mode, verify all pass
- [ ] 5.7. CHECKPOINT: Tag green verified
  - `git tag opencode-config/checkpoint/1003/phase-5-green-verified`
  - `git push origin opencode-config/checkpoint/1003/phase-5-green-verified`

---

## Phase 6: String Tests (SC-1, SC-6, SC-9)

**PREREQ: Phase 1, Phase 2. Can overlap with Phase 3+4.**

### Phase 6 Checkpoint Tags

```
opencode-config/checkpoint/1003/phase-6-string-verified   — after all string tests pass
```

- [ ] 6.0. CHECKPOINT: Tag current state (POST Phase 1+2)
  - `git tag opencode-config/checkpoint/1003/phase-6-init-state`
  - `git push origin opencode-config/checkpoint/1003/phase-6-init-state`
- [ ] 6.1. SC-1 String Test: default.txt no longer contains line 146
  - `grep -n 'pre-read\|pre-reads\|read tool source' .opencode/default.txt | wc -l` == 0
- [ ] 6.2. SC-6 String Test: Tier 1 safety-critical rules retained in all guideline files
  - Spot-check: grep for Tier 1 content in each modified guideline
- [ ] 6.3. SC-9 String Test: `observe/` replaces `investigate/` in all files
  - `grep -r 'investigate-' .opencode/ --include='*.md' | grep -v '.git/' | wc -l` == 0
  - `grep -r '\binvestigate\b' .opencode/AGENTS.md | wc -l` == 0 (context-dependent)
- [ ] 6.4. CHECKPOINT: Tag string tests verified
  - `git tag opencode-config/checkpoint/1003/phase-6-string-verified`
  - `git push origin opencode-config/checkpoint/1003/phase-6-string-verified`

---

## Rollback Protocol

At ANY phase, if a verification gate fails:

1. Report diagnostics: `git status`, `git diff --stat`
2. Identify last PASS checkpoint tag: `git tag -l | grep "checkpoint/1003/phase-.*-verified\|checkpoint/1003/phase-.*-committed\|checkpoint/1003/phase-.*-pass"`
3. Rollback: `git reset --hard <last-PASS-checkpoint> && git submodule update --init`
4. Re-dispatch the failed step from the restored state
5. If first-step failure (no checkpoint): `git checkout .` and re-dispatch

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)