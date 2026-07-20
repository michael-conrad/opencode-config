## Problem

The spec writer (`spec-creation/tasks/write.md`) and plan writer (`writing-plans/tasks/create/plan-structure.md`) define Success Criteria sections but lack enforcement language. The SC sections do not state that:

- ALL SCs must pass for implementation to be considered complete
- Skipped SCs are treated as failures
- Failed SCs require documented remediation with tool-call evidence and re-verification

The spec auditor (`spec-audit.md`) and plan fidelity auditor (`plan-fidelity.md`) also lack criteria checking for the presence of this enforcement language.

The verification consumers (`verification-before-completion/tasks/verify.md`, `cross-validate.md`) already have strong all-or-nothing gates, but the **producers** (spec writer, plan writer) never inject the gate language into the artifacts they create, and the **checkers** (spec auditor, plan fidelity auditor) never verify the gate language exists.

## Scope

| In Scope | Out of Scope |
|----------|-------------|
| Fragment master for SC enforcement gate text | Modifying verification-before-completion or cross-validate (already have gates) |
| spec-creation/tasks/write.md — Step 3 and Step 4 changes | Modifying any other SC consumer files |
| writing-plans/plan-structure.md — Step 1 changes | Changing the fragment registry schema |
| spec-audit.md — Step 2 SC-12 addition | Creating a new skill |
| plan-fidelity.md — Step 3 PF-7 addition + PF-3 update | |
| 4 behavioral enforcement tests | |
| Fragment registry registration | |

## Fragment Master

Create `.opencode/.guidelines/sc-enforcement-gate.md`:

```markdown
# Fragment: SC Enforcement Gate

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| Rule | Description |
|------|-------------|
| ALL pass | Implementation is complete — proceed to next pipeline step |
| Any SKIPPED | Treated as FAIL — skipped SCs must be explicitly documented as superseded or out of scope with rationale |
| Any FAILED | Implementation is blocked — requires documented remediation with tool-call evidence, then re-verification |
| Remediated SC | Re-verified independently — same PASS/FAIL gate applies; no carryover credit from prior passes |
| Re-verification | Repeat the verification command/assertion; confirm PASS before claiming remediation complete |

**SC Table Format (4-column):**

| ID | Criterion | Verification Method | Remediation |
|----|-----------|-------------------|-------------|
| SC-1 | ... | Executable command/assertion producing deterministic PASS/FAIL | What corrective action is required on FAIL, including re-verification procedure |

**The Verification Method column MUST specify an executable command or assertion producing deterministic PASS/FAIL. The Remediation column MUST specify what corrective action is required on FAIL and how re-verification is performed. The Remediation column accepts prose (not a strict enum), matching the convention used in cross-validate.md.**

<!--
Fragment ID: sc-enforcement-gate
Estimated tokens: 280
Type: text-block
Sync status: synchronized
-->
```

## Changes by File

### 1. spec-creation/tasks/write.md — Step 3 (Define Acceptance Criteria)

Add the fragment content as the authoritative format for the SC section. This means:

- The SC table that spec-auditor agents generate MUST include the all-or-nothing gate statement at the top
- The SC table MUST use the 4-column format (ID, Criterion, Verification Method, Remediation)
- The Verification Method column MUST contain executable commands with exact expected values
- The Remediation column MUST specify corrective action + re-verification procedure

### 2. spec-creation/tasks/write.md — Step 4 (Determinism Gate)

Add a sub-check: "Verify the all-or-nothing gate statement is present in the assembled spec body. If absent → STRUCTURE-VIOLATION requiring rewrite before submission."

### 3. writing-plans/tasks/create/plan-structure.md — Step 1 (Read Approved Spec)

After "Extract objectives, constraints, success criteria", add:

"Extract the all-or-nothing gate statement from the spec's SC section. The plan MUST preserve this gate language in its task structure — each TDD RED checkpoint is a sub-gate in the all-or-nothing chain. If the spec lacks the gate statement, flag as SPEC_GAP: the spec must be revised to include the gate before the plan proceeds."

### 4. adversarial-audit/tasks/spec-audit.md — Step 2 (Build Evaluation Criteria)

Add criterion SC-12:

```markdown
| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| SC-12 | SC Enforcement Gate present and explicit | Spec contains all-or-nothing gate statement with PASS/FAIL/Remediation requirements per `.opencode/.guidelines/sc-enforcement-gate.md` format |
```

### 5. adversarial-audit/tasks/plan-fidelity.md — Step 3 (Build Evaluation Criteria)

Update PF-3 description from "Steps cover all success criteria" to "Steps cover ALL success criteria; missing any is automatic FAIL per spec gate."

Add criterion PF-7:

```markdown
| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| PF-7 | SC gate language preserved in plan tasks | Plan task structure references the all-or-nothing gate from spec; each TDD RED checkpoint is a sub-gate in the chain |
```

### 6. registry.yaml

Register fragment with id `sc-enforcement-gate`:
- Master: `.opencode/.guidelines/sc-enforcement-gate.md`
- Destinations: write.md line range, plan-structure.md line range, spec-audit.md line range (SC-12 row), plan-fidelity.md line ranges (PF-3 update + PF-7 row)
- Initial hashes: TBD (populated after implementation)

### 7. Behavioral Enforcement Tests (4 files)

**Test 1: sc-enforcement-gate-spec-writer.sh**
- Prompt: "Write a spec for fixing a bug in the parser"
- Assert: The generated spec's SC section contains the all-or-nothing gate statement
- Assert: The SC table uses 4-column format with Remediation column

**Test 2: sc-enforcement-gate-plan-writer.sh**
- Prompt: "Create a plan from spec #N that includes SCs"
- Assert: The plan references the all-or-nothing gate from the spec
- Assert: Each task step includes RED checkpoint as a sub-gate in the chain

**Test 3: sc-enforcement-gate-spec-auditor.sh**
- Prompt: "Audit spec #N for quality"
- Assert: The audit checks for SC-12 (gate presence) and reports FAIL when missing

**Test 4: sc-enforcement-gate-plan-fidelity.sh**
- Prompt: "Verify plan fidelity against spec for plan #N"
- Assert: The fidelity check includes PF-7 (gate language preservation)
- Assert: PF-3 description now says "ALL success criteria" (not just "all")

## Success Criteria

| ID | Criterion | Verification Method | Remediation |
|----|-----------|-------------------|-------------|
| SC-1 | Fragment master exists with correct format | `test -f .opencode/.guidelines/sc-enforcement-gate.md && grep -q "Fragment ID: sc-enforcement-gate"` | Create file, verify format matches existing fragments |
| SC-2 | Registry entry exists with master path and 4 destinations | `grep -c "sc-enforcement-gate" .opencode/.guidelines/registry.yaml` must return ≥1 | Register entry, verify yaml syntax |
| SC-3 | write.md Step 3 embeds/allows fragment format as SC structure | Verify Step 3 content references all-or-nothing gate + 4-column table format | Update Step 3 prose, run behavioral test 1 |
| SC-4 | write.md Step 4 includes gate-presence sub-check | grep for "gate statement" or "STRUCTURE-VIOLATION" in write.md Step 4 section | Add sub-check, verify behavioral test 1 still passes |
| SC-5 | plan-structure.md Step 1 extracts gate from spec and flags missing | grep for "gate" + "SPEC_GAP" in plan-structure.md Step 1 | Add extraction + flag logic, run behavioral test 2 |
| SC-6 | spec-audit.md has SC-12 criterion | `grep "SC-12" .opencode/skills/adversarial-audit/tasks/spec-audit.md` returns match | Add SC-12 row, run behavioral test 3 |
| SC-7 | plan-fidelity.md has PF-7 and updated PF-3 | `grep "PF-7" .opencode/skills/adversarial-audit/tasks/plan-fidelity.md` returns match; PF-3 says "ALL" | Add PF-7, update PF-3, run behavioral test 4 |
| SC-8 | 4 behavioral test scripts exist | `ls .opencode/tests/behaviors/sc-enforcement-gate-*.sh` returns 4 files | Create scripts, verify bash syntax |
| SC-9 | Each behavioral test is RED before implementation | Run each test; OVERALL_RESULT ≠ 0 | Document pre-implementation RED state |
| SC-10 | Each destination file has fragment reference comment | `grep -q "Fragment ID: sc-enforcement-gate"` in all 4 destination files | Add HTML comment trailer to inserted content |

## Execution Order

1. **RED phase**: Create 4 behavioral tests, verify RED (fail against current state)
2. **Create fragment**: Write `.opencode/.guidelines/sc-enforcement-gate.md` and register in `registry.yaml`
3. **Update spec-creation/tasks/write.md**: Step 3 (fragment format) + Step 4 (gate-presence sub-check)
4. **Update writing-plans/plan-structure.md**: Step 1 (gate extraction + SPEC_GAP flag)
5. **Update spec-audit.md**: Step 2 SC-12 row
6. **Update plan-fidelity.md**: Step 3 PF-7 row + PF-3 description
7. **GREEN phase**: Re-run 4 behavioral tests, verify GREEN (pass against new state)
8. **Final checks**: content-verification commands per SC-1 through SC-10, structural lints

## Edge Cases

- **Spec has no SC section**: Gate-presence check naturally fails → SPEC_GAP. The spec must be revised before the auditor would pass SC-12.
- **Plan references a spec with the gate but doesn't preserve it**: PF-7 fires → FAIL. Plan must be revised.
- **Fragment content is prose (not a strict enum)**: Intentional — the Remediation column accepts free-text per existing project convention (cross-validate.md uses prose remediation). A strict enum would be more fragile because different SC types need different remediation schemas.
- **Behavioral test dispatch may produce INCONCLUSIVE**: Document as accepted risk; use `BEHAVIOR_DISPATCH_FAILED` gate pattern from existing tests.

---

*Co-authored with AI: OpenCode (deepseek-flash)*

🤖 OpenCode (deepseek-flash) ➕ created