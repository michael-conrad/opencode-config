# Implementation Plan — [#1993](https://github.com/michael-conrad/.opencode/issues/1993) — Refactor spec-creation skill

**Goal:** Restructure spec-creation skill to 3 workflows, remove task() calls from task cards, add frugal contract pattern, fix pipeline order.

**Architecture:** 3-phase sequential plan. Phase 1 rewrites SKILL.md (dispatch table + pipeline). Phase 2 cleans 4 task cards and creates 3 new ones. Phase 3 adds critical violation and verifies clean files.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md` (delete)
- `.opencode/skills/spec-creation-validation/tasks/create.md`
- `.opencode/skills/spec-creation-validation/tasks/completion.md`
- `.opencode/skills/spec-creation-change-control/tasks/change-control.md`
- `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`
- `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` (create)
- `.opencode/guidelines/000-critical-rules.md`

**Dispatch:** `skill({name: "writing-plans"})` then `task(..., prompt: "execute create from writing-plans-creation")`

## Blast Radius

| File | Impact |
|------|--------|
| `spec-creation/SKILL.md` | Dispatch table shrinks from 11 to 3 entries; pipeline section added |
| `spec-creation-operating-protocol/tasks/operating-protocol.md` | Deleted — content moved to SKILL.md |
| `spec-creation-validation/tasks/create.md` | 10 structural fixes (D-1 through D-10) |
| `spec-creation-validation/tasks/completion.md` | task() calls removed |
| `spec-creation-change-control/tasks/change-control.md` | task() call removed |
| `spec-creation-decomposition/tasks/analytical-artifacts.md` | Category error fixed |
| `spec-creation-validation/tasks/create-remote-stub.md` | New file |
| `spec-creation-validation/tasks/pre-spec-inspection.md` | New file |
| `spec-creation-validation/tasks/revise-remote-body.md` | New file |
| `000-critical-rules.md` | New critical violation entry |

## Concern Map Reference

| Concern | Phase(s) |
|---------|----------|
| Dispatch table integrity | Phase 1 |
| Pipeline definition | Phase 1 |
| Task card structural correctness | Phase 2 |
| Frugal contract pattern | Phase 2 |
| Critical violation enforcement | Phase 3 |
| Regression prevention | Phase 3 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. Do not read ahead, batch steps, or combine edits. After each step, verify the result before proceeding to the next. If a step fails, stop and report — do not attempt to recover by skipping ahead.

> **Step status:** Each step MUST be marked `[ ]` (pending), `[x]` (completed), or `[~]` (in progress) as work progresses. No step transitions from `[ ]` directly to `[x]` without passing through `[~]`.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Steps | Dispatch |
|-------|------|---------|-----|------------|-------|----------|
| 1 | SKILL.md restructure | Dispatch table + pipeline | SC-1, SC-3, SC-7, SC-8, SC-9, SC-10 | — | 1–9 | `skill({name: "spec-creation"})` |
| 2 | Task card cleanup | Task card structure + contracts | SC-2, SC-4, SC-11–SC-21 | Phase 1 | 10–27 | `skill({name: "spec-creation"})` |
| 3 | Critical violation + verification | Enforcement + regression | SC-5, SC-6 | Phase 2 | 28–30 | `skill({name: "spec-creation"})` |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** If a step fails, the agent MUST self-remediate before escalating. Diagnosis → fix → re-verify. Only after 2+ failed remediation attempts may the agent escalate. Do not skip remediation — every failure is agent-owned.

## Exit Criteria

- [ ] C1. SKILL.md Trigger Dispatch Table has exactly 3 entries (SC-1)
- [ ] C2. `revise` dispatch entry exists in SKILL.md (SC-1)
- [ ] C3. Pipeline section exists in SKILL.md with read/write/contract for each sub-task step (SC-3, SC-8, SC-9)
- [ ] C4. No `{project_root}/tmp/{N}/contracts/` paths in SKILL.md pipeline (SC-7)
- [ ] C5. Create pipeline starts with `local-issues sync`, ends with `local-issues sync` (SC-10)
- [ ] C6. `operating-protocol.md` deleted (SC-3)
- [ ] C7. `create.md` contains no `task(` or `skill({name:` calls (SC-15)
- [ ] C8. `create.md` contains no `{project_root}/tmp/` paths (SC-16)
- [ ] C9. `create.md` contains result contract section (SC-17)
- [ ] C10. `create.md` contains read-from-disk specification (SC-18)
- [ ] C11. `create.md` has sequentially numbered steps (SC-19)
- [ ] C12. `create.md` self-review reads from local `.issues/{N}/spec.md` (SC-20)
- [ ] C13. `create.md` does not reference "pre-PR gate" (SC-21)
- [ ] C14. `create.md` does NOT create the remote issue (SC-11)
- [ ] C15. `completion.md` has no `task(` calls (SC-2)
- [ ] C16. `change-control.md` has no `task(` calls (SC-2)
- [ ] C17. `analytical-artifacts.md` has no orchestrator-level instructions (SC-4)
- [ ] C18. `create-remote-stub.md` exists (SC-12)
- [ ] C19. `pre-spec-inspection.md` exists (SC-13)
- [ ] C20. `revise-remote-body.md` exists (SC-14)
- [ ] C21. No task card under any spec-creation sub-skill contains `task(...)` (SC-2)
- [ ] C22. `000-critical-rules.md` contains sub-agent task() prohibition (SC-5)
- [ ] C23. All 13 clean task cards have zero changes in git diff (SC-6)
