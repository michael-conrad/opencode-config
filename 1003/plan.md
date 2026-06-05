# Plan: #1003 — Resolve Session-Start Context Conflicts

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Cross-ref: https://github.com/michael-conrad/.opencode/issues/1003
Plan URL: https://github.com/michael-conrad/opencode-config/blob/issues-data/.issues/1003/plan.md
Z3 contract: https://github.com/michael-conrad/opencode-config/blob/issues-data/.issues/1003/artifacts/phase-dependency-contract.yaml
Pipeline state machine: `skills/implementation-pipeline/pipeline-state-machine.yaml`

Authorization scope: `for_implementation` (label: `approved-for-implementation`)
PR strategy: `stacked` — one branch, one PR for all phases
Pipeline phases: 6 phases, each with 14-stage implementation-pipeline dispatch

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

**14-stage pipeline per file** (`skills/implementation-pipeline/pipeline-state-machine.yaml`)

```
Stage 1 — sc-coherence-gate:    adversarial-audit --task coherence-extraction
Stage 2 — pre-red-baseline:     implementation-pipeline --task pre-red-baseline
Stage 3 — red-phase:            test-driven-development --task red
                                  RED: behavioral test — agent DOES pre-read tool source (fails)
Stage 4 — red-doublecheck:      verification-before-completion --task verify (RED-side SC evidence)
Stage 5 — green-phase:          test-driven-development --task green
                                  GREEN: DELETE line 146, ADD startup mode identity, CONDENSE cruft
Stage 6 — checkpoint-commit:    git-workflow --task commit-prep
Stage 7 — structural-checks:    finishing-a-development-branch --task checklist
Stage 8 — green-doublecheck:    verification-before-completion --task verify (GREEN-side SC evidence)
Stage 9 — green-vbc:            verification-before-completion --task completion
Stage 10 — adversarial-audit:   adversarial-audit --task verification-audit
Stage 11 — cross-validate:      adversarial-audit --task cross-validate
Stage 12 — regression-check:    test-driven-development --task patterns (regression)
Stage 13 — review-prep:         git-workflow --task review-prep
Stage 14 — exec-summary:        completion-core --task completion
```

### Phase 1 Sub-Steps

- [ ] 1.1. sc-coherence-gate: Verify spec/plan coherence before RED routing
  - Dispatch: `adversarial-audit --task coherence-extraction`
  - Z3 state check: `solve state update --var-name previous_step --var-value init --var-name current_step --var-value sc-coherence-gate --var-name pipeline_state --var-value running`
- [ ] 1.2. pre-red-baseline: Initialize pipeline state
  - Dispatch: `solve state init ./tmp/state/1003/pipeline/`
  - Environment: capture current default.txt for RED baseline
- [ ] 1.3. red-phase: Write behavioral RED test — verify agent pre-reads tool source before dispatch
  - Dispatch: `test-driven-development --task red`
  - RED artifact: `.opencode/tests/behaviors/tier1-mandate-enforcement.sh` or new scenario
  - Test runner: `bash .opencode/tests/with-test-home opencode-cli run '<prompt>' --model <model>`
  - Assertion: `assert_semantic "SC-4" "Agent pre-reads tool source before behavioral observation"`
  - SC-4 target: agent DOES pre-read -> RED passes (agent hasn't been fixed yet)
  - SC-11 target: agent DOES pre-read -> RED passes
  - Z3 state: `solve state update --var-name previous_step --var-value pre-red-baseline --var-name current_step --var-value red-phase`; `solve check`
- [ ] 1.4. red-doublecheck: Verify RED-side SC evidence
  - Dispatch: `verification-before-completion --task verify`
  - Verify: SC-4 RED test fails (pre-read still happens), SC-11 RED test fails
  - Z3 state: `solve state update --var-name previous_step --var-value red-phase --var-name current_step --var-value red-doublecheck`; `solve check`
- [ ] 1.5. green-phase: Implement default.txt changes
  - Dispatch: `test-driven-development --task green`
  - DELETE line 146 from `default.txt`
    - Locate `default.txt` at `.opencode/.issues/artifacts/` or root `.opencode/`
    - Remove the sentence that authorizes the pre-read cascade
  - ADD startup mode identity section (per spec)
    - Insert DISCUSSION/PLANNING persona block before authorization section
  - CONDENSE default.txt (remove cruft without lobotomy)
    - Strip redundant/duplicate directives that survive relocation
  - Z3 state: `solve state update --var-name previous_step --var-value red-doublecheck --var-name current_step --var-value green-phase`; `solve check`
- [ ] 1.6. checkpoint-commit: Commit default.txt changes
  - Dispatch: `git-workflow --task commit-prep`
  - Commit message: `feat(#1003): delete line 146, add startup mode identity, condense default.txt`
  - Z3 state: `solve state update --var-name previous_step --var-value green-phase --var-name current_step --var-value checkpoint-commit`; `solve check`
- [ ] 1.7. structural-checks: Lint + format pass
  - Dispatch: `finishing-a-development-branch --task checklist`
  - Run: `uvx pymarkdownlnt scan -r .opencode/guidelines/` (for default.txt)
  - Run: `uvx ruff format` (for adjacent Python files)
  - Z3 state: `solve state update --var-name previous_step --var-value checkpoint-commit --var-name current_step --var-value structural-checks`; `solve check`
- [ ] 1.8. green-doublecheck: Verify GREEN-side SC evidence
  - Dispatch: `verification-before-completion --task verify`
  - Verify SC-1: default.txt no longer contains line 146 (string: grep)
  - Verify SC-2: default.txt contains startup mode identity section (string: grep)
  - Verify SC-8: loading order confirmed (string: grep)
  - Verify SC-4 RED now GREEN: re-run behavioral test — agent dispatches without pre-reading
  - Z3 state: `solve state update --var-name previous_step --var-value structural-checks --var-name current_step --var-value green-doublecheck`; `solve check`
- [ ] 1.9. green-vbc: VbC completion artifact
  - Dispatch: `verification-before-completion --task completion`
  - Artifact: `./tmp/artifacts/pipeline-1003-phase1-default-txt-DONE-{timestamp}.yaml`
  - Z3 state: `solve state update --var-name previous_step --var-value green-doublecheck --var-name current_step --var-value green-vbc`; `solve check`
- [ ] 1.10. adversarial-audit: Dual-auditor verification
  - Dispatch: `adversarial-audit --task verification-audit`
  - Two clean-room auditor sub-agents review default.txt changes
  - Auditors return: status, findings, blocker_reason
  - Z3 state: `solve state update --var-name previous_step --var-value green-vbc --var-name current_step --var-value adversarial-audit`; `solve check`
- [ ] 1.11. cross-validate: Cross-family validation
  - Dispatch: `adversarial-audit --task cross-validate`
  - Compare both auditor verdicts, flag disagreements
  - Z3 state: `solve state update --var-name previous_step --var-value adversarial-audit --var-name current_step --var-value cross-validate`; `solve check`
- [ ] 1.12. regression-check: Verify nothing broken
  - Dispatch: `test-driven-development --task patterns` (regression mode)
  - Run existing behavioral tests that should still pass
  - Z3 state: `solve state update --var-name previous_step --var-value cross-validate --var-name current_step --var-value regression-check`; `solve check`
- [ ] 1.13. review-prep: Prepare for PR review
  - Dispatch: `git-workflow --task review-prep`
  - Verify branch state, commit structure
  - Z3 state: `solve state update --var-name previous_step --var-value regression-check --var-name current_step --var-value review-prep`; `solve check`
- [ ] 1.14. exec-summary: Phase 1 completion report
  - Dispatch: `completion-core --task completion`
  - Push commits, post issue comment with phase 1 status
  - Z3 state: `solve state update --var-name previous_step --var-value review-prep --var-name current_step --var-value exec-summary --var-name pipeline_state --var-value complete`; `solve check`

---

## Phase 2: Rename investigate→observe Across All Files

**PREREQ: none — can run in parallel with Phase 1.**

**Per-file RED/GREEN pairs** — each file has its own 14-stage pipeline (abbreviated here to RED/GREEN + verification).

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

### Per-File Sub-Steps (applied to each file 2.1–2.9)

- [ ] 2.N.1. RED: Write string test asserting `investigate/` appears in file (fails after rename)
- [ ] 2.N.2. GREEN: Replace `investigate-` with `observe-` and `investigate/` with `observe/` in file
- [ ] 2.N.3. VERIFY: String test now passes — no `investigate-` or `investigate/` remains
- [ ] 2.N.4. COMMIT: `feat(#1003): rename investigate→observe in <filename>`

### Phase 2 Completion

- [ ] 2.10. Verify SC-9: `grep -r 'investigate-' .opencode/ --include='*.md'` returns empty
- [ ] 2.11. Full structural checks + push

---

## Phase 3: Guideline File Trims (13 Files)

**PREREQ: Phase 1 complete. Sub-steps N1–N13 are INDEPENDENT — each can parallelize.**

For each file, the semantic filter:
1. **Content that must fire every session (Tier 1 safety-critical)** → stays in the guideline
2. **Content that semantically fires when a specific skill/trigger is invoked (Tier 2/3)** → moves verbatim to the destination skill card
3. **yaml+symbolic machine-enforcement block** → stays (consumed by hooks)
4. **No shell stubs or routing entries**

Each file follows its own 14-stage pipeline (abbreviated here).

### Per-File Sub-Steps (applied to each 3.N.1–3.N.13)

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

---

## Phase 4: Auth Edge Case Documentation

**PREREQ: Phase 3 sub-step N2 (010-approval-gate.md trim) complete**

- [ ] 4.1. RED: Write content-verification test — auth-over-directive not documented yet
- [ ] 4.2. GREEN: Add auth-over-directive edge case to `approval-gate` skill SKILL.md
  - "approved"/"go" overrides any prior directive scope with context flush
  - Auth received while a prior directive-limited scope is active = scope expansion + context flush
  - Document alongside existing scope model
- [ ] 4.3. VERIFY SC-10: Auth-over-directive edge case documented
- [ ] 4.4. COMMIT: `feat(#1003): document auth-over-directive edge case in approval-gate skill`

---

## Phase 5: Behavioral Tests (SC-4, SC-5, SC-11)

**PREREQ: Phases 1, 2, 3, 4 — must run AFTER all changes are in place.**

### Test Infrastructure

Each test uses `with-test-home --checkout` for tag-based RED/GREEN protocol:
```
RED:   git checkout <parent>/checkpoint/<issue>/phase-<N>-<submodule>  (before change)
GREEN: git checkout <parent>/checkpoint/<issue>/phase-<N+1>-<submodule> (after change)
```

- [ ] 5.1. SC-4 Behavioral Test: Agent does not pre-read tool source before behavioral observation
  - RED: Checkout pre-Phase-1 checkpoint — agent pre-reads (RED passes)
  - GREEN: Checkout post-Phase-1 checkpoint — agent dispatches without pre-reading
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

---

## Phase 6: String Tests (SC-1, SC-6, SC-9)

**PREREQ: Phase 1, Phase 2. Can overlap with Phase 3+4.**

- [ ] 6.1. SC-1 String Test: default.txt no longer contains line 146
  - `grep -n 'pre-read\|pre-reads\|read tool source' .opencode/default.txt | wc -l` == 0
- [ ] 6.2. SC-6 String Test: Tier 1 safety-critical rules retained in all guideline files
  - Spot-check: grep for Tier 1 content in each modified guideline
- [ ] 6.3. SC-9 String Test: `observe/` replaces `investigate/` in all files
  - `grep -r 'investigate-' .opencode/ --include='*.md' | grep -v '.git/' | wc -l` == 0
  - `grep -r '\binvestigate\b' .opencode/AGENTS.md | wc -l` == 0 (context-dependent)

---

## Final: spec-to-plan cross-ref

```
Cross-ref: https://github.com/michael-conrad/.opencode/issues/1003
Plan URL: https://github.com/michael-conrad/.opencode/issues/1003 (added as issue comment)

(This section is informational only — the plan is stored at `.issues/1003/plan.md` and will be posted as an issue comment on the spec.)
```

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)