# Phase 3 — Critical violation + verification

**Concern:** Enforcement and regression prevention

**Files:**
- `.opencode/guidelines/000-critical-rules.md`

**SCs:** SC-5, SC-6

**Dependencies:** Phase 2 complete (all task cards cleaned)

**Entry conditions:** All task cards cleaned, 3 new task cards created

**Exit conditions:** Critical violation entry added, 13 clean task cards verified unmodified

**Code Path Coverage:** 000-critical-rules.md (Tier 2 section)

**Cross-Cutting SCs:** None

**Interface Boundaries:** 000-critical-rules.md is consumed by all agents — entry must use correct critical-rules-XXX format and be placed in the correct tier section

**State Transitions:** 000-critical-rules.md gains a new prohibition entry

---

- [ ] 28. **Add critical violation to `000-critical-rules.md` (**sub-agent**).** **→ SC-5**
  - [ ] 28.1. **RED.** Write behavioral test that sends prompt with a task card containing `task()` and verifies the agent declines to execute it. Test fails because no prohibition exists.
  - [ ] 28.2. **GREEN.** Open `.opencode/guidelines/000-critical-rules.md`. Find the Tier 2 (process-integrity) section. Append:

```
### [critical-rules-XXX] CRITICAL VIOLATION — Sub-agent task cards MUST NOT contain task() or skill() calls
Only orchestrator-level SKILL.md files may contain dispatch instructions. A task card that contains a task() or skill() call is structurally defective — the sub-agent cannot execute it. This applies to ALL task cards across ALL skills. Violation: HALT with blocker report.
```
  - [ ] 28.3. **GREEN doublecheck (**inline**).** Run `grep -c 'task cards MUST NOT contain task()' .opencode/guidelines/000-critical-rules.md`. Should be 1. If not 1, revert and redo step 28.2.
  - [ ] 28.4. **Checkpoint commit (**inline**).** `git commit -m "1993: add critical violation for sub-agent task() calls in task cards"`

- [ ] 29. **Verify 13 clean task cards unmodified (**sub-agent**).** **→ SC-6**
  - [ ] 29.1. **RED.** Write behavioral test that verifies git diff shows zero changes to the 13 clean task cards. Test fails if any changes detected.
  - [ ] 29.2. **GREEN.** Run:

```
git diff -- .opencode/skills/spec-creation-requirements/tasks/requirements.md .opencode/skills/spec-creation-decomposition/tasks/decompose.md .opencode/skills/spec-creation-decomposition/tasks/blast-radius.md .opencode/skills/spec-creation-decomposition/tasks/code-path-analysis.md .opencode/skills/spec-creation-decomposition/tasks/concern-analysis.md .opencode/skills/spec-creation-decomposition/tasks/cross-cutting.md .opencode/skills/spec-creation-decomposition/tasks/state-analysis.md .opencode/skills/spec-creation-decomposition/tasks/testability-assessment.md .opencode/skills/spec-creation-decomposition/tasks/interface-compatibility.md .opencode/skills/spec-creation-validation/tasks/holistic-self-check.md .opencode/skills/spec-creation-validation/tasks/pipeline-readiness-gate.md .opencode/skills/spec-creation-validation/tasks/risk.md .opencode/skills/spec-creation-validation/tasks/traceability.md
```

If any changes detected, revert them with `git checkout -- <file>`.
  - [ ] 29.3. **GREEN doublecheck (**inline**).** Re-run the git diff — confirm zero changes.
  - [ ] 29.4. **Checkpoint commit (**inline**).** `git commit -m "1993: verify 13 clean task cards unmodified"` (only if changes were reverted)

#### Phase 3 VbC

- [ ] 30. **VbC (**clean-room**).**

**Concern transition:** All phases complete. Ready for post-implementation gates.
