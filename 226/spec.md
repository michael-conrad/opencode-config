> **Full spec and artifacts: [`.issues/{N}/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/{N}/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

AI agents consistently read SKILL.md task files and execute the steps inline in their own orchestrator context instead of dispatching to clean-room sub-agents via `task()`. The agent produces self-narrating output like "let me dispatch to the write task" but never actually calls `task()` — it reads the task file and executes the steps itself.

The root cause is a gap in AI-agent-facing text: the Persona section (identity-anchoring) and the Invocation section (dispatch gate) lack the structural enforcement that closes the rationalization gap where an agent decides "I can do this myself."

## Scope

The audit of all 40 skills in `.opencode/skills/` reveals:

### Phase 1 — Missing DISPATCH_GATE blocks (4 skills)

These skills have task files and Invocation tables but no DISPATCH_GATE block at primacy position:

| Skill | Current State |
|-------|--------------|
| `adversarial-audit` | No Persona, no Invocation section, no DISPATCH_GATE. Uses `## Blind Dispatch` instead. |
| `writing-plans` | Has Persona addressing inline vs dispatch, but NO DISPATCH_GATE block at primacy position before the Invocation table |
| `researcher` | Has Persona + Invocation table, but NO DISPATCH_GATE block |
| `playwright-cli` | Has Invocation table, but NO Persona, NO DISPATCH_GATE |

### Phase 2 — Missing Persona sections (20 skills)

These skills have no `## Persona` section at all, meaning the agent has no identity/role definition that would anchor "I am a router, not an implementer":

`adversarial-audit`, `approval-gate`, `changelog-generator`, `completion-core`, `correspondence`, `engineering-approach`, `executing-plans`, `finishing-a-development-branch`, `implementation-pipeline`, `mcp-tool-usage`, `plan-creation-pipeline`, `playwright-cli`, `pr-creation-workflow`, `programming-principles`, `receiving-code-review`, `requesting-code-review`, `skill-creator`, `sync-guidelines`, `systematic-debugging`, `test-driven-development`

### Phase 3 — Behavioral enforcement tests

Every DISPATCH_GATE and Persona change must have a corresponding behavioral enforcement test that verifies the agent dispatches via `task()` instead of inlining.

## Approach

### Phase 1: DISPATCH_GATE blocks

For each of the 4 skills missing DISPATCH_GATE, add a block at primacy position (right before the Invocation task table) using the p-dis-001 (Dependency-Order Gate) and p-dis-003 (Re-Priming Anchor) formulas from `257-procedural-discipline-reference.md`:

```
**DISPATCH GATE — Inline execution is FORBIDDEN.** Every task in this table MUST be dispatched to a clean-room sub-agent via `task()`. Reading a task file and executing its steps inline in the orchestrator context means every quality gate in that task was silently bypassed — the task's entry criteria, exit criteria, verification steps, and audit gates all fire inside the sub-agent's context, not the orchestrator's. An orchestrator that inlines a task has produced a deliverable that was never independently verified. Professional orchestrators route to sub-agents. Amateurs inline.
```

### Phase 2: Persona sections

For each of the 20 skills missing Persona, add a `## Persona` section that:
1. Defines the agent's role as a router/dispatcher, not an implementer
2. Uses dark-prose-002/003 (goal hijacking identity-frame + consequence-assertion) from `250-dark-prose-reference.md`
3. States the consequence of inlining: contaminated pipeline, unverified deliverables
4. Is specific to the skill's domain (not copy-paste generic)

### Phase 3: Behavioral enforcement tests

For each changed skill, create a behavioral enforcement test in `.opencode/tests/behaviors/` that:
1. Sends a prompt that triggers the skill
2. Asserts via `assert_semantic` that the agent dispatched via `task()` rather than executing inline
3. Uses stderr-based evidence (skill dispatch strings), not prose-recall prompts

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `adversarial-audit` SKILL.md has DISPATCH_GATE block at primacy position before Invocation table | `string` | `grep` for "DISPATCH GATE" in `adversarial-audit/SKILL.md` |
| SC-2 | `writing-plans` SKILL.md has DISPATCH_GATE block at primacy position before Invocation table | `string` | `grep` for "DISPATCH GATE" in `writing-plans/SKILL.md` |
| SC-3 | `researcher` SKILL.md has DISPATCH_GATE block at primacy position before Invocation table | `string` | `grep` for "DISPATCH GATE" in `researcher/SKILL.md` |
| SC-4 | `playwright-cli` SKILL.md has DISPATCH_GATE block at primacy position before Invocation table | `string` | `grep` for "DISPATCH GATE" in `playwright-cli/SKILL.md` |
| SC-5 | All 20 skills missing Persona sections have `## Persona` added with inline-vs-dispatch identity-anchoring | `string` | Count skills without `## Persona` section — must be 0 |
| SC-6 | Each new Persona section uses domain-specific language (not copy-paste generic) | `semantic` | Sub-agent reads each Persona and judges whether it's domain-specific |
| SC-7 | Each new Persona section includes consequence of inlining (contaminated pipeline, unverified deliverable) | `string` | `grep` for "inline" or "contaminant" or "unverified" in each Persona |
| SC-8 | Behavioral enforcement test exists for at least one skill verifying agent dispatches via `task()` instead of inlining | `behavioral` | `opencode-cli run` with stderr-based assertion |
| SC-9 | `spec-creation` SKILL.md changes (already applied) have behavioral enforcement test | `behavioral` | `opencode-cli run` with stderr-based assertion |
| SC-10 | All existing DISPATCH_GATE blocks (36 skills) remain intact — no regressions | `string` | Count skills with DISPATCH_GATE — must be ≥36 |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at {{SPEC_PATH}}.
After creation, `local-issues sync {N}` MUST be run and the result committed to create the local `.issues/{N}/` entry.
The implementation plan will be created in `.issues/{N}/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)