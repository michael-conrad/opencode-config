## SPEC-FIX: Decouple State Tracking from Design Artifacts

### Problem

Four bugs were identified where the agent conflates **design artifacts** (specs, plans) with **state tracking** (progress, phase status, authorization, completion). Specs and plans are static design documents — they define *what* and *how*, not *where we are*. State tracking belongs in `./tmp/{N}/`.

### Bug 1: STATUS markers in plan bodies (PRIMARY)

The agent mutates plan issue bodies with `STATUS: in progress`, `STATUS: completed` markers to track execution progress. This is state tracking embedded in a design artifact.

**Affected files:**

| File | Pattern |
|------|---------|
| `executing-plans/tasks/step.md:43` | "Update STATUS in plan issue body" — direct mutation of plan body for state |
| `executing-plans/tasks/start.md:13-15` | "Read Plan STATUS to compose initial phase progress" — reads state from plan body |
| `executing-plans/tasks/completion.md:8,17-19` | "Verify plan issue STATUS reflects actual outcome" — verifies state in plan body |
| `approval-gate/tasks/verify-sub-issues.md:52-64,120,178` | Prescribes embedding STATUS markers in plan bodies; calls sub-issues "phase tracking" |
| `approval-gate/enforcement/scope-parsing.md:128` | Reads STATUS markers for `resolve_next_phase()` |
| `implementation-pipeline/enforcement/context-passing.md:73,76` | Reads Plan STATUS for phase progress context |

**Fix:** Remove all STATUS marker reads/writes from plan bodies. Route all phase progress tracking to `./tmp/{N}/work.md` (which already exists with a defined schema in `approval-gate/enforcement/work-state-schema.md`).

### Bug 2: Lifecycle manifest in wrong location

The append-only event log (lifecycle manifest) is stored at `.issues/{issue-N}/lifecycle.yaml` — the same directory as the spec/plan design artifacts.

**Affected files:**

| File | Pattern |
|------|---------|
| `implementation-pipeline/SKILL.md:216-239` | Prescribes `.issues/{issue-N}/lifecycle.yaml` for pipeline step events |
| `spec-creation/tasks/write.md:74` | Prescribes `.issues/{issue-N}/lifecycle.yaml` with initial `spec_created` event |
| `writing-plans/tasks/create/create-and-validate.md:69,91` | Verifies lifecycle manifest at `.issues/{issue-N}/lifecycle.yaml` |

**Fix:** Move lifecycle manifest location to `./tmp/{issue-N}/lifecycle.yaml`. The event log is ephemeral execution state, not a design artifact.

### Bug 3: Labels used as authorization gate (advisory only)

Labels (`approved-for-*`, `needs-approval`) are used as the primary authorization mechanism. Labels are for stakeholders — they are advisory metadata, not authoritative state.

**Affected files:**

| File | Pattern |
|------|---------|
| `approval-gate/tasks/verify-blockers.md:29-30` | HALTs on `needs-approval` label presence |
| `approval-gate/tasks/verify-authorization.md:28` | Applies `approved-for-*` labels as primary authorization marker |
| `approval-gate/enforcement/work-state-schema.md:5` | Already tracks `authorization_scope`, `halt_at`, `pr_strategy` in `./tmp/{N}/work.md` |

**Fix:** Labels remain present for stakeholder visibility (advisory), but the agent's authorization gate reads from `./tmp/{N}/work.md`. Labels are written as a courtesy sync after the work state file is updated. The `needs-approval` label does not halt the agent — only the work state file's authorization scope gates execution.

### Bug 4: No checklist generation (missing feature)

No skill or task generates `./tmp/{N}/checklist.md` from plan phases. The STATUS markers in plan bodies exist because there is no alternative. The fix is to add checklist generation.

**Affected gap:**

- `writing-plans/tasks/create/create-and-validate.md:60` mentions "mandatory checklist generation" but no implementation exists
- No file in the skill deck generates a `./tmp/{N}/checklist.md`

**Fix:** Add checklist generation to `writing-plans` — on plan creation, generate `./tmp/{N}/checklist.md` with:
- Every phase as a section
- Every step as a checkbox with dispatch instruction
- Status tracking (pending/in_progress/done/blocked) per step
- Agent reads checklist to determine next action; updates it on completion

### Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No `executing-plans` task file reads or writes STATUS in plan body | `string` | grep for "STATUS" in `executing-plans/tasks/*.md` — pattern absent |
| SC-2 | No `approval-gate` task file reads STATUS from plan body for phase resolution | `string` | grep for "STATUS" in `approval-gate/` — patterns referencing plan body STATUS removed |
| SC-3 | No `implementation-pipeline` task reads Plan STATUS for context passing | `string` | grep for "Plan STATUS" in `implementation-pipeline/` — pattern absent |
| SC-4 | Lifecycle manifest path changed to `./tmp/{issue-N}/lifecycle.yaml` | `string` | grep for `.issues/.*lifecycle` — no references to `.issues/{N}/lifecycle.yaml` |
| SC-5 | Authorization gate reads from `./tmp/{N}/work.md`, not labels | `behavioral` | Agent halts on missing authorization in work state file, not on `needs-approval` label |
| SC-6 | Labels are advisory-only — agent does not halt on `needs-approval` label | `behavioral` | Agent proceeds when work state has authorization even if `needs-approval` label present |
| SC-7 | Checklist generated at `./tmp/{N}/checklist.md` on plan creation | `behavioral` | Plan creation generates checklist with phases, steps, dispatch instructions |
| SC-8 | Checklist is single file with sections per phase, not file-per-phase hierarchy | `structural` | `./tmp/{N}/checklist.md` exists, no `./tmp/{N}/checklist-phase-*.md` files |
| SC-9 | Agent uses checklist (not plan body STATUS) to determine next action | `behavioral` | Agent reads `./tmp/{N}/checklist.md` for progress; does not read plan body STATUS |

### Labels

- `spec-fix`
- `needs-approval`

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)