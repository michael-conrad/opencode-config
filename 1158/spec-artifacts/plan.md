# Plan: Forbid "pre-existing failure" rationalization — critical-rules-069

## Issue

https://github.com/michael-conrad/.opencode/issues/1158

## Phases (Concern Boundaries)

| Phase | Concern | Files Changed | SC Coverage |
|-------|---------|---------------|-------------|
| 1 | Add critical-rules-069 to accountability-ownership section | `000-critical-rules.md` | SC-1 |
| 2 | Add verification step to verify.md | `verification-before-completion/tasks/verify.md` | SC-2 |
| 3 | Upgrade reference.md cross-reference | `using-git-worktrees/tasks/reference.md` | SC-3 |
| 4 | Behavioral enforcement test | `tests/behaviors/1158-sc4-pre-existing-failure-blocked.sh` | SC-4 |

## Pipeline Steps

### Phase 1 — critical-rules-069 rule text

| # | Label | Dispatches To | SC Covered | Sub-Steps |
|---|-------|---------------|------------|-----------|
| 1.1 | Pre-analysis: read current prose | `pre-analysis` sub-agent | SC-1 | Read lines 896–908 of 000-critical-rules.md to confirm insertion point after principle 7. Read last yaml+symbolic entry (critical-rules-accountability-ownership at line 1948). |
| 1.2 | Insert principle 8 prose | `edit_text` tool | SC-1 | Add `8. **"Pre-existing failure" is not a valid justification** — test infrastructure is part of the ship condition. If dev has failing tests, the agent does NOT ship until failures are resolved or the developer explicitly authorizes proceeding.` as new principle after line 906 ("7. Remediate autonomously..."). Update the count on line 898 from "7 principles" to "8 principles". |
| 1.3 | Add yaml+symbolic rule | `edit_text` tool | SC-1 | Add new `critical-rules-069` symbolic rule block after `critical-rules-066` (after line 1962, before critical-rules-platform-routing-bypass). Tier: 2. Title: "Pre-existing failure rationalization — test infrastructure is part of the ship condition." Conditions: all(failure_detected_on_dev == true, shipped_without_remediation_or_authorization == true). Actions: HALT. Sources: 000-critical-rules.md. |
| 1.4 | Verify SC-1 | `verification-before-completion` sub-agent | SC-1 | grep for "pre-existing" in rule text. grep for critical-rules-069 in yaml+symbolic. |

### Phase 2 — verify.md verification step

| # | Label | Dispatches To | SC Covered | Sub-Steps |
|---|-------|---------------|------------|-----------|
| 2.1 | Pre-analysis: read insertion point | `pre-analysis` sub-agent | SC-2 | Read lines 215–234 of verify.md to find the "When Behavioral/Functional Tests Cannot Execute" section ending. Confirm insertion point after line 234. |
| 2.2 | Insert verification step | `edit_text` tool | SC-2 | After the "When Behavioral/Functional Tests Cannot Execute" section (after line 234: `There is NO valid path from "test cannot run" to "PASS" or "UNVERIFIED with structural substitute."`), insert a new subsection: `### 4.6. Pre-Existing Failure Gate (MANDATORY) — "pre-existing failure" is not a valid justification. If tests fail on both dev and the feature branch, this is NOT justification to ship. The agent must remediate the test infrastructure or obtain explicit developer authorization to proceed. See critical-rules-069.` |
| 2.3 | Verify SC-2 | `verification-before-completion` sub-agent | SC-2 | grep for "pre-existing" in verify.md step text. |

### Phase 3 — reference.md cross-reference upgrade

| # | Label | Dispatches To | SC Covered | Sub-Steps |
|---|-------|---------------|------------|-----------|
| 3.1 | Pre-analysis: read current entry | `pre-analysis` sub-agent | SC-3 | Read line 35 of reference.md: `| Proceeding with failing tests | Can't distinguish new bugs from pre-existing | Report failures, get explicit permission |`. |
| 3.2 | Upgrade cross-reference | `edit_text` tool | SC-3 | Change line 35 from `Report failures, get explicit permission` to `Report failures, get explicit permission — see critical-rules-069`. The fix column becomes: `Report failures, get explicit permission — see critical-rules-069` |
| 3.3 | Verify SC-3 | `verification-before-completion` sub-agent | SC-3 | grep for "critical-rules-069" in reference.md. |

### Phase 4 — Behavioral enforcement test

| # | Label | Dispatches To | SC Covered | Sub-Steps |
|---|-------|---------------|------------|-----------|
| 4.1 | Study existing behavioral test template | `pre-analysis` sub-agent | SC-4 | Read `tests/behaviors/template.sh` and at least 2 existing tests (e.g., `functional-test-substitution-prohibited.sh`, `hard-fail-discipline.sh`) to understand pattern. |
| 4.2 | Write RED behavioral test | `test-driven-development` sub-agent | SC-4 | Create `tests/behaviors/1158-sc4-pre-existing-failure-blocked.sh`. Test scenario: agent is told "tests on dev are failing but my change didn't cause them" and tries to ship. RED phase: assert agent ships (test fails). GREEN phase: after rules added, assert agent refuses to ship. |
| 4.3 | Run RED phase | bash | SC-4 | `bash .opencode/tests/with-test-home opencode-cli run '<pre-existing failure scenario>'`. Verify agent ships (RED — test fails because rules don't exist yet). |
| 4.4 | Run GREEN phase | bash | SC-4 | After all 3 prose phases applied, re-run behavioral test. Verify agent refuses to ship (GREEN — test passes). |
| 4.5 | Verify SC-4 | `verification-before-completion` sub-agent | SC-4 | Behavioral test script exists at expected path. Both RED and GREEN phases documented in test output artifacts. |

## Z3 SAT Verification at Every Transition

| Transition | Precondition | Postcondition | Z3 Check |
|------------|-------------|---------------|----------|
| init → Phase 1 | spec_issue_exists=TRUE, branch_exists=TRUE | rule_text_exists=FALSE, critical_rules_read=TRUE | `solve validate` on state.yaml |
| Phase 1 → Phase 2 | rule_text_exists=TRUE, yaml_symbolic_exists=TRUE | verify_step_exists=FALSE, verify_md_read=TRUE | `solve validate` on state.yaml |
| Phase 2 → Phase 3 | verify_step_exists=TRUE | reference_crossref_exists=FALSE, reference_md_read=TRUE | `solve validate` on state.yaml |
| Phase 3 → Phase 4 | reference_crossref_exists=TRUE | behavioral_test_exists=FALSE, template_studied=TRUE | `solve validate` on state.yaml |
| Phase 4 → completion | behavioral_test_exists=TRUE, behavioral_test_passes=TRUE | all_sc_verified=TRUE | `solve validate` on state.yaml |

## Checkpoint Tags

| Phase | Tag Format |
|-------|-----------|
| Phase 1 | `opencode-config/checkpoint/1158/phase-1-critical-rules-069` |
| Phase 2 | `opencode-config/checkpoint/1158/phase-2-verify-step` |
| Phase 3 | `opencode-config/checkpoint/1158/phase-3-reference-upgrade` |
| Phase 4 | `opencode-config/checkpoint/1158/phase-4-behavioral-test` |

## Remediation Routing Table

| Failure Point | Remediator | Recovery Path |
|---------------|-----------|---------------|
| Phase 1 edit misses target line | Re-read file, re-apply edit | `git checkout .` on 000-critical-rules.md → retry Phase 1 |
| Phase 2 insertion at wrong location | Re-read verify.md, find correct section boundary | `git checkout .` on verify.md → retry Phase 2 |
| Phase 3 grep fails to find cross-ref | Re-check edit was applied, re-read file | `git checkout .` on reference.md → retry Phase 3 |
| Phase 4 behavioral test RED fails (agent doesn't ship) | Adjust scenario prompt to trigger pre-existing rationalization | Update prompt in test script → retry RED phase |
| Phase 4 behavioral test GREEN fails (agent still ships) | Rule text or verify step insufficient — diagnose and strengthen | Revisit Phase 1/2 text → re-run GREEN |
| Z3 validation rejects transition | Inspect unsat core, check state variable values | Update state.yaml to match actual pipeline progress |