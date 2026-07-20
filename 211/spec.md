## Problem Statement

The adversarial auditors (`spec-audit`, `verification-audit`, `plan-fidelity`) and the plan writer (`writing-plans`) all require a local spec file in `.issues/{N}/spec.md` (or `*/.issues/{N}/spec.md` for submodules). Currently:

1. **Auditors** return a generic `BLOCKED` with `MISSING_REQUIRED_INPUT` / `missing: "spec_local_dir"` — the BLOCK message does NOT tell the orchestrator what skill to dispatch to fix the problem.
2. **Plan writer** (`create.md`) lists "Spec stored in `.issues/{N}/spec.md`" as a prerequisite but has no BLOCK mechanism at all — it silently assumes the file exists.
3. Neither the auditors nor the plan writer have a standardized BLOCK message that directs the orchestrator to dispatch the appropriate skill (`issue-operations --task sync-pull-to-local` or equivalent) to place a copy of the spec into the local spec folder.
4. **No prohibition on hunting.** The current task files do not explicitly forbid the agent from searching for the spec in other locations (GitHub API, other `.issues/` directories, cached copies) when the required local file is missing. This leads to agents accepting untrusted spec sources.

## Root Cause

The `spec_local_dir` contract is documented in the auditor entry criteria (spec-audit.md line 17: "If the spec is only on GitHub (not locally mirrored), the orchestrator MUST mirror it as .md files in `spec_local_dir/` first"), but the BLOCK messages returned by the auditors do not include a dispatch directive. The plan writer's `create.md` has no BLOCK mechanism at all for this prerequisite. None of the task files explicitly prohibit hunting for the spec in other locations.

## Scope

| In scope | Out of scope |
|----------|-------------|
| Update auditor pre-flight BLOCK messages to include dispatch directive | Changing the sync-pull-to-local or import-remote task logic |
| Add BLOCK mechanism to plan writer's `create.md` prerequisite check | Changing how spec_local_dir is resolved |
| Standardize the BLOCK message format across all three auditor tasks and the plan writer | Adding new sync mechanisms |
| Update `plan-fidelity.md` Step 0 pre-flight to check `spec_local_dir` for spec content (currently only checks for `clean_room_plan`) | |
| Add explicit no-hunt prohibition to all four task files | |
| Add explicit no-hunt prohibition to `adversarial-audit/SKILL.md` and `writing-plans/SKILL.md` | |

## Affected Files

All in `michael-conrad/.opencode` (submodule):

- `skills/adversarial-audit/SKILL.md` — Add no-hunt prohibition to entry criteria
- `skills/adversarial-audit/tasks/spec-audit.md` — Step 0 pre-flight BLOCK message + no-hunt prohibition
- `skills/adversarial-audit/tasks/verification-audit.md` — Step 0 pre-flight BLOCK message + no-hunt prohibition
- `skills/adversarial-audit/tasks/plan-fidelity.md` — Step 0 pre-flight BLOCK message (currently only checks `clean_room_plan`, needs `spec_local_dir` check added) + no-hunt prohibition
- `skills/writing-plans/SKILL.md` — Add no-hunt prohibition to entry criteria
- `skills/writing-plans/tasks/create.md` — Prerequisites section needs BLOCK mechanism + no-hunt prohibition

## Success Criteria

**SC-1 (behavioral):** When `spec_local_dir` is missing or empty in `spec-audit.md`, the BLOCKED response MUST include a `remediation` field directing the orchestrator to dispatch `issue-operations --task sync-pull-to-local` (or equivalent) to place a copy of the spec into the local spec folder. The agent MUST NOT search for the spec in any other location (GitHub API, other directories, cached copies) — it is an immediate BLOCK.

**SC-2 (behavioral):** When `spec_local_dir` is missing or empty in `verification-audit.md`, the BLOCKED response MUST include a `remediation` field directing the orchestrator to dispatch `issue-operations --task sync-pull-to-local` (or equivalent). The agent MUST NOT search for the spec in any other location.

**SC-3 (behavioral):** When `spec_local_dir` is missing or empty in `plan-fidelity.md`, the BLOCKED response MUST include a `remediation` field directing the orchestrator to dispatch `issue-operations --task sync-pull-to-local` (or equivalent). Additionally, `plan-fidelity.md` Step 0 MUST check `spec_local_dir` (currently only checks `clean_room_plan`). The agent MUST NOT search for the spec in any other location.

**SC-4 (behavioral):** When the spec file is not found in `.issues/{N}/spec.md` during `writing-plans/tasks/create.md` prerequisite check, the orchestrator MUST BLOCK with a remediation directive to dispatch `issue-operations --task sync-pull-to-local` (or equivalent). The agent MUST NOT search for the spec in any other location.

**SC-5 (string):** All four BLOCK messages MUST use a standardized format:

```yaml
status: BLOCKED
error: MISSING_LOCAL_SPEC_FILE
missing: "spec_local_dir"
remediation: "Local spec file in <spec_local_dir>/spec.md is mandatory. Dispatch `issue-operations --task sync-pull-to-local` with issue number <N> to place a copy of the spec into the local spec folder before re-dispatching. Do NOT search for the spec in any other location — only the spec in the correct local spec folder is trusted."
```

**SC-6 (string):** The `plan-fidelity.md` Step 0 pre-flight MUST include a `spec_local_dir` check (currently absent — only checks `clean_room_plan`).

**SC-7 (string):** The `adversarial-audit/SKILL.md` MUST include a no-hunt prohibition in its entry criteria section, stating that auditors must not search for spec files outside the designated `spec_local_dir`.

**SC-8 (string):** The `writing-plans/SKILL.md` MUST include a no-hunt prohibition in its entry criteria section, stating that the plan writer must not search for spec files outside `.issues/{N}/spec.md` or `*/.issues/{N}/spec.md`.

**SC-9 (string):** The same no-hunt prohibition MUST apply to plan files. When `plan.md` is not found in the local spec folder, the agent MUST NOT search for it elsewhere — immediate BLOCK with dispatch directive.

## No-Hunt Prohibition — Canonical Wording

The following wording MUST appear in all affected task files and SKILL.md entry criteria:

> **No-hunt rule:** If the spec file is not found in the designated local spec folder (`spec_local_dir`), the agent MUST NOT search for it in any other location — not the GitHub API, not other `.issues/` directories, not cached copies, not the remote issue body. Only the spec in the correct local spec folder is a trusted spec source. Absence of the local spec file is an immediate BLOCK with a dispatch directive. The same rule applies to plan files: only `plan.md` in the designated local spec folder is a trusted plan source.

## Phases

### Phase 1: Update Auditor BLOCK Messages + No-Hunt Prohibition

Update `spec-audit.md`, `verification-audit.md`, and `plan-fidelity.md` Step 0 pre-flight BLOCK messages to include the standardized `MISSING_LOCAL_SPEC_FILE` format with dispatch directive and no-hunt prohibition.

For `plan-fidelity.md`: add `spec_local_dir` check to Step 0 (currently only checks `clean_room_plan`).

### Phase 2: Add BLOCK Mechanism + No-Hunt Prohibition to Plan Writer

Update `writing-plans/tasks/create.md` Prerequisites section to add a BLOCK mechanism when `.issues/{N}/spec.md` is not found, using the same standardized format with no-hunt prohibition.

### Phase 3: Add No-Hunt Prohibition to SKILL.md Files

Add the no-hunt prohibition to `adversarial-audit/SKILL.md` and `writing-plans/SKILL.md` entry criteria sections.

## Documentation Sources

| File | Purpose |
|------|---------|
| `skills/adversarial-audit/SKILL.md` | Add no-hunt prohibition to entry criteria |
| `skills/adversarial-audit/tasks/spec-audit.md` | Spec audit task — Step 0 pre-flight BLOCK for missing spec_local_dir |
| `skills/adversarial-audit/tasks/verification-audit.md` | Verification audit task — Step 0 pre-flight BLOCK for missing spec_local_dir |
| `skills/adversarial-audit/tasks/plan-fidelity.md` | Plan fidelity task — Step 0 pre-flight (missing spec_local_dir check) |
| `skills/writing-plans/SKILL.md` | Add no-hunt prohibition to entry criteria |
| `skills/writing-plans/tasks/create.md` | Plan creation — Prerequisites section (no BLOCK mechanism) |
| `skills/issue-operations/tasks/sync-pull-to-local.md` | The skill to dispatch when spec needs mirroring to local folder |
| `skills/issue-operations/tasks/import-remote.md` | Alternative: import remote issue into local |
