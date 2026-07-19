# Phase 1 — SKILL.md restructure

**Concern:** Dispatch table integrity and pipeline definition

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md` (delete)

**SCs:** SC-1, SC-3, SC-7, SC-8, SC-9, SC-10

**Dependencies:** None

**Entry conditions:** Spec #1993 approved, plan created

**Exit conditions:** SKILL.md has 3 dispatch entries, pipeline section present, operating-protocol.md deleted

**Code Path Coverage:** SKILL.md dispatch table (lines 27-39), Invocation table (lines 45-57), operating-protocol.md (entire file)

**Cross-Cutting SCs:** None

**Interface Boundaries:** SKILL.md is consumed by orchestrator via `skill()` — dispatch table entries must match canonical dispatch string format

**State Transitions:** SKILL.md transitions from 11-entry dispatch table to 3-entry dispatch table; pipeline content moves from operating-protocol.md to SKILL.md

---

- [ ] 1. **Remove 8 fake dispatch entries from SKILL.md (**sub-agent**).** Open `.opencode/skills/spec-creation/SKILL.md`. In the Trigger Dispatch Table (lines 27-39), remove these 8 rows: `requirements`, `decompose`, `analytical-artifacts`, `holistic-self-check`, `pipeline-readiness-gate`, `risk`, `traceability`, `operating-protocol`. In the Invocation table (lines 45-57), remove the corresponding 8 entries. Keep only `create` and `completion`. **→ SC-1**

- [ ] 2. **RED: verify 2 dispatch entries remain (**inline**).** Run `grep -c '| \`' .opencode/skills/spec-creation/SKILL.md` on the dispatch table section. Count should be 2 (create, completion). If not 2, revert and redo step 1.

- [ ] 3. **Add `revise` dispatch entry to SKILL.md (**sub-agent**).** Open `.opencode/skills/spec-creation/SKILL.md`. Add to Trigger Dispatch Table: row with `"revise spec" / "update spec"` → `revise` → `spec-creation-validation --task revise` → `sub-task` → `{issue_number}`. Add to Invocation table: row with `revise` → `task(..., prompt: "execute revise from spec-creation-validation. Read \`spec-creation-validation/tasks/revise.md\` first")`. **→ SC-1**

- [ ] 4. **RED: verify `revise` entry exists (**inline**).** Run `grep 'revise' .opencode/skills/spec-creation/SKILL.md | grep '|'`. Should find the dispatch row. If not found, revert and redo step 3.

- [ ] 5. **Add Pipeline section to SKILL.md (**sub-agent**).** Open `.opencode/skills/spec-creation/SKILL.md`. After the Invocation table, add a `## Pipeline` section. Define the 25-step create procedure and 6-step revise procedure. Each step labeled `[inline]` or `[sub-task]`. Each sub-task step specifies: what the sub-agent reads from disk, what it writes to disk, and the result contract format `{status, finding_summary, artifact_path, blocker_reason}`. Pipeline order: `local-issues sync` → `create-remote-stub` → ... → `revise-remote-body` → `local-issues sync`. No `{project_root}/tmp/{N}/contracts/` paths. **→ SC-3, SC-7, SC-8, SC-9, SC-10**

- [ ] 6. **RED: verify pipeline section exists (**inline**).** Run `grep '## Pipeline' .opencode/skills/spec-creation/SKILL.md`. Should find the section header. Run `grep -c 'contracts/' .opencode/skills/spec-creation/SKILL.md`. Should be 0. If either check fails, revert and redo step 5.

- [ ] 7. **Delete `operating-protocol.md` task card (**sub-agent**).** Run `rm .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md`. Grep all spec-creation files for references to `operating-protocol.md` — if any remain, update them to reference the SKILL.md Pipeline section instead. **→ SC-3**

- [ ] 8. **RED: verify file deleted (**inline**).** Run `ls .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md 2>&1`. Should return "No such file or directory". If file still exists, redo step 7.

#### Phase 1 VbC

- [ ] 9. **VbC (**clean-room**).** Verify: SKILL.md dispatch table has exactly 3 entries (SC-1). `revise` entry exists (SC-1). Pipeline section exists with read/write/contract for each sub-task step (SC-3, SC-8, SC-9). No `contracts/` paths in SKILL.md (SC-7). Pipeline starts with sync, ends with sync (SC-10). `operating-protocol.md` deleted (SC-3). Report PASS or BLOCKED with findings.

**Concern transition:** Leaving dispatch table integrity → entering task card structural correctness. Phase 2 depends on Phase 1's SKILL.md having the correct pipeline section that the cleaned task cards will reference.
