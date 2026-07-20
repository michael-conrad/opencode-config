## Problem

The current plan format uses a single monolithic `plan.md` file with phases as sections. This forces the orchestrator to hold the entire plan in context (~300+ lines) even when only one phase is being executed. The format also lacks explicit dispatch contract fields (`must_receive`/`must_not_receive`), which means sub-agents receive inconsistent context — sometimes preloaded with orchestrator reasoning, sometimes missing required fields.

## Approach

Replace the single-file plan format with a multi-file format:

1. **Master ToC** (`plan.md`): A ~50-line routing index containing the phase list table, dependency ordering, and exit criteria. The orchestrator holds this in context as routing metadata.

2. **Per-phase sub-plans** (`plan-phase-N.md`): One self-contained file per phase with the full checkbox sequence (Pre-RED Common → Per-Item RED/GREEN Chains → Post-RED/green). Each TDD item includes dispatch contract fields (`must_receive` by name, `must_not_receive`).

3. **Work state file** (`.tmp/work-state-NNN.yaml`): Disk-persistent phase tracking with Z3-verifiable state transitions. Survives session resets.

4. **writing-plans skill update**: The skill produces the new multi-file format instead of the single-file format.

## Phases

### Phase 1 — Master ToC Format

Define the `plan.md` routing index file.

**SCs:** SC-1, SC-2, SC-3, SC-4

### Phase 2 — Sub-Plan File Format

Define the `plan-phase-N.md` structure with dispatch contracts.

**SCs:** SC-5, SC-6, SC-7, SC-8

### Phase 3 — Work State File

Define the `.tmp/work-state-NNN.yaml` format with Z3-verifiable contracts.

**SCs:** SC-9, SC-10, SC-11

### Phase 4 — writing-plans Skill Changes

Update the writing-plans skill to produce the new format.

**SCs:** SC-12, SC-13, SC-14, SC-15

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `plan.md` exists as routing index, ≤50 lines, with phase list table and exit criteria | `structural` | File existence + `wc -l` + grep for table columns |
| SC-2 | Phase list table includes `Depends On` column, acyclic dependency graph | `string` | Extract Depends On values, verify acyclic, Phase 1 has no deps |
| SC-3 | Exit criteria per phase are verifiable (not subjective) | `string` | Grep for Exit Criteria column, verify non-empty, verifiable language |
| SC-4 | ToC is orchestrator-loadable without opening sub-plan files | `behavioral` | Agent reads only plan.md to list phases (stderr evidence) |
| SC-5 | `plan-phase-N.md` files follow three-section structure (Pre-RED, RED/GREEN, Post-RED) | `string` | Verify file naming, section headers present and in order |
| SC-6 | Dispatch contract fields (`must_receive` by name, `must_not_receive`) in each TDD item | `string` | Grep for must_receive/must_not_receive, verify field names not values |
| SC-7 | Markdown checkbox format preserved (`- [ ]` / `- [x]`) | `string` | Verify all step lines use checkbox format |
| SC-8 | Sub-plan files are self-contained, no cross-file references | `string` | Grep for cross-file reference patterns, zero matches |
| SC-9 | Work state file format defined with required fields | `structural` | File path pattern match, YAML parse, required fields present |
| SC-10 | Z3-verifiable contract fields for state transitions | `string` | State transition rules documented, Z3 can load contract |
| SC-11 | Session-resilient disk persistence (not memory-only) | `behavioral` | Simulate session boundary, verify orchestrator resumes from work state file |
| SC-12 | writing-plans skill produces master ToC + sub-plans (not monolithic) | `behavioral` | Invoke skill for 3-phase spec, verify plan.md + 3 sub-plan files output |
| SC-13 | Dispatch contract fields included in generated sub-plans | `behavioral` | Invoke skill, verify must_receive/must_not_receive in generated files |
| SC-14 | Work state file contract created by writing-plans | `behavioral` | Invoke skill, verify .tmp/work-state-NNN.yaml created with required fields |
| SC-15 | plan-structure.md and create-and-validate.md updated for new format | `string` | Verify both files reference multi-file format and dispatch contracts |

## Out of Scope

- Orchestrator execution model (how the orchestrator consumes the new format)
- Migration from old single-file plans to the new format
- Additional tooling beyond Z3 verification

## Constraints

- Markdown checkbox format preserved (`- [ ] N. ...`)
- Master ToC ≤ 50 lines (orchestrator context discipline)
- Pre-RED/Post-RED sections duplicated per sub-plan (no shared/abstracted sections)

## Dependencies

- `writing-plans` skill is the sole producer of the new format
- `plan-structure.md` and `create-and-validate.md` task files define the canonical format
- Z3 solve tool for work state file verification

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)