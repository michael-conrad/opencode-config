> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The `spec-creation/SKILL.md` and `writing-plans/SKILL.md` skill cards have three structural defects that cause orchestrator agents to perform work inline instead of dispatching sub-agents:

**Defect 1 — Persona identity frame (root cause):** Both Persona sections use first-person identity framing ("Spec Architect", "Plan Author") that causes the orchestrator to self-identify as the doer. The orchestrator reads "you are the person who does this work" and performs the work inline — bypassing the DISPATCH_GATE sections that appear later. Per `250-dark-prose-reference.md`, identity frames encountered first override procedural rules encountered later.

**Defect 2 — No unified step-by-step checklist in SKILL.md:** The Operating Protocol sections list requirements as bullet items, not as a sequential `- [ ] N.` checklist. The orchestrator has no single ordered workflow to follow. Task files (write.md, create.md) use mixed prose/checklist format with `### Step N:` headers interspersed with prose paragraphs — not pure `- [ ] N.` format.

**Defect 3 — Missing `solve` and `plan` tool steps in SKILL.md Operating Protocol:** The `solve` and `plan` tool invocations exist only in task files (write.md Step 5.6, create.md §Inter-Phase Handoff). The SKILL.md Operating Protocol does not mandate them, so orchestrators skip them when routing.

## Workflow Analysis

### spec-creation — one workflow

| Aspect | Current State |
|--------|--------------|
| Workflows | 1 (spec creation) |
| Tasks in dispatch table | 9 (requirements, decompose, traceability, pipeline-readiness-gate, risk, diagram, write, change-control, completion) |
| Operating Protocol items | 9 bullet items — not a sequential checklist |
| `solve`/`plan` in SKILL.md | Absent — only in write.md Step 5.6 |
| Persona | "Spec Architect" — first-person identity frame |

### writing-plans — one workflow

| Aspect | Current State |
|--------|--------------|
| Workflows | 1 (plan creation) |
| Tasks in dispatch table | 2 (create, completion) |
| Operating Protocol items | 7 bullet items — not a sequential checklist |
| `solve`/`plan` in SKILL.md | Absent — only in create.md §Inter-Phase Handoff |
| Persona | "Plan Author" — first-person identity frame |

## Scope

**In scope:**
- Fix Persona sections in both SKILL.md files to use third-person dispatch framing
- Add unified `- [ ] N.` checklists to both SKILL.md Operating Protocols organized by workflow
- Add `solve` and `plan` tool invocation steps to both SKILL.md Operating Protocols
- Reformat `write.md` task file to use pure `- [ ] N.` format throughout
- Reformat `create.md` task file to use pure `- [ ] N.` format throughout
- Z3 SAT validation of checklists and workflows
- Plan tool validation of phase structure

**Out of scope:**
- Changes to DISPATCH_GATE sections (already correct)
- Changes to other task files (requirements.md, decompose.md, etc.)
- Changes to other skill cards

## Fix Approach

### Phase 1: Fix Persona sections

Replace first-person identity frames with third-person dispatch framing:

**spec-creation/SKILL.md Persona (current):**
> Spec Architect. Focus: structure investigation results into complete, well-organized spec with traceability, interface definitions, risk analysis, and change control.

**spec-creation/SKILL.md Persona (replacement):**
> This skill produces specs by dispatching sub-agents. The orchestrator routes; sub-agents write. Sub-agents are intelligent agents, not dumb terminals — they read specs and use skills autonomously. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW.

**writing-plans/SKILL.md Persona (current):**
> Plan Author. Focus: transform spec into phased plan with file structure, TDD steps, and concern boundary annotations.

**writing-plans/SKILL.md Persona (replacement):**
> This skill produces plans by dispatching sub-agents. The orchestrator routes; sub-agents author. Sub-agents are intelligent agents, not dumb terminals — they read specs and use skills autonomously. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW.

### Phase 2: Add unified checklists to SKILL.md Operating Protocols

**spec-creation/SKILL.md Operating Protocol** — replace 9 bullet items with a single sequential checklist:

```
- [ ] 1. Pre-spec inspection mandatory per `015-pre-spec-inspection.md`
- [ ] 2. Verification-enforcement gate before generation
- [ ] 3. Select-existing pathway: search GitHub Issues for existing specs
- [ ] 4. Requirements task mandatory before write (unless trivial)
- [ ] 5. Concern enumeration guard: enumerate single concerns before writing
- [ ] 6. Invoke `solve model` for dependency-ordering constraints contract
- [ ] 7. Invoke `solve check` to verify SAT
- [ ] 8. Invoke `plan plan` for phase solvability validation
- [ ] 9. Write spec via `issue-operations --task creation`
- [ ] 10. Adversarial-audit call: `adversarial-audit --task spec-audit --issue <N>`
- [ ] 11. PR merge boundaries required when dependencies exist
- [ ] 12. Mermaid diagram required for multi-phase specs
```

**writing-plans/SKILL.md Operating Protocol** — replace 7 bullet items with a single sequential checklist:

```
- [ ] 1. Plan from approved spec only
- [ ] 2. Verification-enforcement gate before reading spec
- [ ] 3. Combined or separate decision
- [ ] 4. Item decomposition mandatory
- [ ] 5. Invoke `solve model` for dependency-ordering constraints contract
- [ ] 6. Invoke `solve check` to verify SAT
- [ ] 7. Invoke `plan plan` for phase solvability validation
- [ ] 8. Write plan to `.issues/{N}/plan.md`
- [ ] 9. Adversarial-audit: `plan-fidelity` and `concern-separation`
- [ ] 10. Pipeline-readiness gate check
- [ ] 11. Generate implementation-checklist.md
```

### Phase 3: Reformat task files to pure `- [ ] N.` format

**write.md** — convert all `### Step N:` headers and prose paragraphs into sequential `- [ ] N.` checklist items. Each step is one action. No prose paragraphs between steps.

**create.md** — convert all `### Steps 0-5:` routing headers and prose sections into sequential `- [ ] N.` checklist items. Each step is one action. No prose paragraphs between steps.

### Phase 4: Z3 SAT and plan tool validation

- Generate solve contracts for both workflows
- Run `solve check` to verify SAT
- Run `plan plan` to validate phase structure
- Document results in `.issues/{N}/`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | spec-creation/SKILL.md Persona uses third-person dispatch framing (no "Spec Architect" identity) | `string` | `grep -q "This skill produces specs by dispatching sub-agents" .opencode/skills/spec-creation/SKILL.md` |
| SC-2 | writing-plans/SKILL.md Persona uses third-person dispatch framing (no "Plan Author" identity) | `string` | `grep -q "This skill produces plans by dispatching sub-agents" .opencode/skills/writing-plans/SKILL.md` |
| SC-3 | spec-creation/SKILL.md Operating Protocol is a single `- [ ] N.` checklist with `solve` and `plan` steps | `string` | `grep -c "^- \[ \]" .opencode/skills/spec-creation/SKILL.md` ≥ 12 |
| SC-4 | writing-plans/SKILL.md Operating Protocol is a single `- [ ] N.` checklist with `solve` and `plan` steps | `string` | `grep -c "^- \[ \]" .opencode/skills/writing-plans/SKILL.md` ≥ 11 |
| SC-5 | write.md task file uses pure `- [ ] N.` format — no `### Step` headers | `string` | `grep -c "^- \[ \]" .opencode/skills/spec-creation/tasks/write.md` > 0 AND `grep -c "^### Step" .opencode/skills/spec-creation/tasks/write.md` == 0 |
| SC-6 | create.md task file uses pure `- [ ] N.` format — no `### Steps` routing headers | `string` | `grep -c "^- \[ \]" .opencode/skills/writing-plans/tasks/create.md` > 0 AND `grep -c "^### Steps" .opencode/skills/writing-plans/tasks/create.md` == 0 |
| SC-7 | `solve check` returns SAT for spec-creation workflow contract | `behavioral` | `./.opencode/tools/solve check --contract-path .issues/{N}/spec-creation-contract.yaml` returns SAT |
| SC-8 | `solve check` returns SAT for writing-plans workflow contract | `behavioral` | `./.opencode/tools/solve check --contract-path .issues/{N}/writing-plans-contract.yaml` returns SAT |
| SC-9 | `plan plan` validates phase structure for both workflows | `behavioral` | `./.opencode/tools/plan plan --problem .issues/{N}/phase-plan-problem.yaml` returns SOLVED_SATISFICING or SOLVED_OPTIMALLY |
| SC-10 | Both Persona sections include "intelligent agents, not dumb terminals" admonishment | `string` | `grep -c "intelligent agents, not dumb terminals" .opencode/skills/spec-creation/SKILL.md` == 1 AND `grep -c "intelligent agents, not dumb terminals" .opencode/skills/writing-plans/SKILL.md` == 1 |

## Edge Cases

- **Existing specs/plans are not affected** — this change only affects the skill cards and task files, not previously generated artifacts
- **Task files that are not write.md or create.md are not affected** — only the two main task files are reformatted
- **DISPATCH_GATE sections are not changed** — they already correctly mandate sub-agent dispatch
- **The `solve` and `plan` tools must be available** — if unavailable, the implementation must HALT with blocker report

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

🤖 OpenCode (deepseek-v4-flash) created