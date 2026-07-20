## Intent and Executive Summary

**Problem Statement:** The divide-and-conquer skill has 13 task files and 4 enforcement files, but only `assemble-work.md` is in the actual pipeline. The other 12 task files are dead code — never called by any workflow. The live file (`assemble-work.md`, 3900 words) exceeds the 3000-word limit, uses broken step numbering, references a branch-per-issue model that creates git conflicts, embeds VbC and finishing concerns that belong at orchestrator level, and includes overlapping remediation systems.

**Root Cause / Motivation:** The skill grew organically without pipeline-audit discipline. Task files were added for anticipated needs that never materialized. The branch-per-issue model creates real git merge conflicts on shared codebases. VbC inside sub-agents violates the separation principle (no self-verification). The orchestrator does inline work that should be routed to sub-agents.

**Approach Chosen:** Redesign from scratch based on actual pipeline behavior. Replace the 13+4 file structure with a 2+3 file structure: one SKILL.md (routing checklist), one task file (assemble-work.md, the actual workflow), and three retained enforcement reference docs. Single feature branch for the whole PR. Orchestrator is a pure router — no creative work, no file edits, no inline analysis. All substantive work (RED, GREEN, VbC, adversarial audit) runs in clean-room sub-agents via task(). Git operations delegated to git-workflow skill.

**Alternatives Considered & Why Discarded:**
- **Patch the existing structure:** Would leave dead code and structural problems. The branch-per-issue model, inline VbC, and overlapping enforcement can't be patched — they need surgical removal.
- **Merge all task files into one giant task:** Exceeds the 3000-word limit and creates a monolithic task file, violating incremental-build discipline.
- **Keep all 13 task files as "reference":** Adds maintenance burden for files no workflow calls. Dead code is a liability.

**Key Design Decisions:**
1. Single feature branch for all issues in a PR (no branch-per-issue, no work assembly, no squash-merge sub-step)
2. Orchestrator is a pure router — routes to skill calls and task() sub-agents, never edits files inline
3. VbC and adversarial audit are separate task() sub-agents, not skill calls and not inside GREEN
4. Git operations delegated to git-workflow skill (pre-work, implementation commits, review-prep, completion)
5. Completeness-gate is a structural pre-check skill call before expensive verification layers

## Objective

Replace the divide-and-conquer skill's current 13+4 file structure with a clean 2+3 file structure that matches actual pipeline behavior, enforces orchestrator-as-router discipline, uses a single feature branch, and separates verification into independent sub-agent dispatches.

## Problem

### Current State (13 task files, 4 enforcement files)

| File | Status | Problem |
|------|--------|---------|
| `tasks/orchestrate.md` | Dead code | Not in any pipeline. approval-gate routes directly to assemble-work |
| `tasks/dispatch.md` | Dead code | Never called. assemble-work dispatches inline |
| `tasks/merge.md` | Dead code | Never called. Single branch makes merge assembly unnecessary |
| `tasks/completion.md` | Dead code | Overlaps with finishing-a-development-branch skill |
| `tasks/implementer-prompt.md` | Dead code | Never called. Prompts composed inline in assemble-work |
| `tasks/spec-reviewer-prompt.md` | Dead code | Never called |
| `tasks/code-quality-reviewer-prompt.md` | Dead code | Never called |
| `tasks/assess.md` | Unreferenced | Context sizing is implicit, not a pipeline step |
| `tasks/decompose.md` | Unreferenced | Decomposition done by approval-gate pre-implementation-analysis |
| `tasks/context-passing.md` | Unreferenced | Useful reference but not a step |
| `tasks/purification-and-enforcement.md` | Unreferenced | Duplicates 000-critical-rules.md git-workflow boundary rules |
| `tasks/overflow-signal.md` | Unreferenced | Moved to enforcement/ |
| `tasks/assemble-work.md` | Live, 3900 words | Exceeds 3000-word limit, broken numbering, branch-per-issue model, inline VbC |
| `enforcement/completion-checkpoint.md` | Duplicates result-validation | FAIL protocol appears in both files |
| `enforcement/result-validation.md` | Active | Should be folded into assemble-work |
| `enforcement/work-state-verification.md` | Active | Keep as reference |
| `enforcement/overflow-signal.md` | Active | Keep as reference |
| `SKILL.md` | 780 words | Has word count table, persona, references to dead tasks |

### Structural Problems

1. **Branch-per-issue model**: Creates git merge conflicts on shared codebases. Each issue on its own branch creates N branches that must be sequentially merged, causing conflicts.
2. **VbC inside sub-agents**: Violates separation principle — GREEN sub-agent should not verify itself.
3. **Orchestrator inline work**: Orchestrator makes decisions, reads files, and does analysis that should be routed to sub-agents.
4. **Dead code**: 11 of 13 task files are never called by any pipeline step.
5. **Overlapping enforcement**: completion-checkpoint.md and result-validation.md duplicate the FAIL/remediation protocol.
6. **assemble-work exceeds 3000-word limit**: 3900 words, broken step numbering, references to moved/deleted files.

## Context

### Pipeline Flow Trace (Actual Call Graph)

```
approval-gate
  └─ pre-implementation-analysis (creates work state file)
       └─ yield-to-assemble-work (handoff point)
            └─ divide-and-conquer --task assemble-work (THE pipeline)
```

`orchestrate.md` is never called. `executing-plans/tasks/start.md` references it but start.md also references assemble-work — the actual pipeline goes through assemble-work.

### New Pipeline (Redesigned)

```
Authorization received (#N)
│
├─ 1. git-workflow --task pre-work
│     create ONE feature branch from dev
│
├─ 2. approval-gate --task pre-implementation-analysis
│     screen issues, reconcile, dependency graph, write work state
│
├─ 3. FOR EACH issue in execution order:
│     │
│     ├─ 3a. task() → RED sub-agent
│     │     write tests only, return result contract
│     │
│     ├─ 3b. completeness-gate --task check (RED)
│     │     structural pre-check (files exist, tests compile, SCs covered)
│     │
│     ├─ 3c. task() → VbC sub-agent (RED deliverable)
│     │     verify tests against spec success criteria (clean-room)
│     │
│     ├─ 3d. task() → adversarial-audit (RED deliverable)
│     │     dual cross-family audit of test quality and spec coverage
│     │
│     ├─ 3e. task() → GREEN sub-agent
│     │     implement code only, return result contract
│     │
│     ├─ 3f. completeness-gate --task check (GREEN)
│     │     structural pre-check (files exist, code compiles, no missing artifacts)
│     │
│     ├─ 3g. task() → VbC sub-agent (GREEN deliverable)
│     │     verify implementation against spec success criteria (clean-room)
│     │
│     ├─ 3h. task() → adversarial-audit (GREEN deliverable)
│     │     dual cross-family audit of implementation quality
│     │
│     ├─ 3i. git-workflow --task implementation
│     │     WIP checkpoint commit per issue on shared branch
│     │
│     └─ (next issue continues on same branch)
│
├─ 4. finishing-a-development-branch --task checklist
│     lint, typecheck, structural final checks
│
├─ 5. git-workflow --task review-prep
│     commit-prep analysis, push, compare URL
│
└─ 6. HALT with results
      executive summary + compare URL in chat

(After explicit "create a PR" from developer)
├─ 7. git-workflow --task completion
│   └─ pr-creation-workflow
```

### Verification Layers (per issue)

| Layer | What | Why | Dispatch |
|-------|------|-----|----------|
| **Completeness gate** | Structural check (exists? compiles? SCs covered?) | Cheap, deterministic gate before expensive verification | Skill call |
| **VbC** | Verify against spec success criteria | Clean-room verification, no self-verification bias | task() sub-agent |
| **Adversarial audit** | Dual cross-family quality verification | Independent verification catches what structural checks miss | task() sub-agent |

### Dispatch Method Rationale

| Work type | Dispatch method | Why |
|-----------|----------------|-----|
| Creative work (RED, GREEN) | task() sub-agent | Clean context, scoped, no contamination |
| Verification (VbC) | task() sub-agent | Different agent than producer, clean-room separation |
| Quality verification (adversarial audit) | task() sub-agent | Dual cross-family, independent from producer and VbC |
| Structural check (completeness-gate) | Skill call | Deterministic, no judgment, no contamination risk |
| Git operations (commit, push, branch) | git-workflow skill | Complete git workflow, not raw git commands |
| Routing (which issue next, record results) | Orchestrator | Requires work state, must happen in sequence |

## Fix Approach

### New File Structure (2+3)

**Retained and rewritten:**
| File | Content |
|------|---------|
| `SKILL.md` | Checklist flow matching the pipeline. No persona, no word count table, no orphaned task references. Invocation section points to `assemble-work` as sole entry task. Result contract schema and status classification folded from completion-checkpoint + result-validation. |
| `tasks/assemble-work.md` | Single orchestrator workflow matching the 6+1 step pipeline. Under 3000 words. No branch-per-issue, no work assembly, no merge step, no VbC/finishing in sub-agent scope. Per-issue commit on shared branch via git-workflow. |

**Retained as reference (no changes):**
| File | Content |
|------|---------|
| `enforcement/context-passing.md` | Sub-agent context shape reference |
| `enforcement/overflow-signal.md` | OVERFLOW contract and re-dispatch strategies |
| `enforcement/work-state-verification.md` | Verification table and work state format |

**Folded into assemble-work.md:**
| File | What gets folded |
|------|-----------------|
| `enforcement/completion-checkpoint.md` | Result contract status table, Verify-Before-Acceptance protocol |
| `enforcement/result-validation.md` | Empty/malformed result handling, required contract fields, FAIL protocol |

**Deleted (dead code — no callers in any pipeline):**
| File | Reason |
|------|--------|
| `tasks/orchestrate.md` | Not in the pipeline. approval-gate routes to assemble-work |
| `tasks/dispatch.md` | Never called. assemble-work dispatches inline |
| `tasks/merge.md` | Never called. Single branch makes merge assembly unnecessary |
| `tasks/completion.md` | Overlaps with finishing-a-development-branch skill |
| `tasks/implementer-prompt.md` | Never called. Prompts composed inline |
| `tasks/spec-reviewer-prompt.md` | Never called |
| `tasks/code-quality-reviewer-prompt.md` | Never called |
| `tasks/assess.md` | Context sizing is implicit, not a pipeline step |
| `tasks/decompose.md` | Decomposition done by approval-gate pre-implementation-analysis |
| `tasks/purification-and-enforcement.md` | Duplicates 000-critical-rules.md |
| `tasks/overflow-signal.md` | Moved to enforcement/ in new structure |

### Reference Updates in Other Skills

| Skill/Task | Change |
|-----------|--------|
| `executing-plans/tasks/start.md` | Remove `orchestrate` reference; keep `assemble-work` reference |
| `000-critical-rules.md` | Verify divide-and-conquer symbolic rule IDs still match after rewrite |

Skills that already reference `assemble-work` correctly need no changes:
- `approval-gate/tasks/pre-impl/yield-to-assemble-work.md`
- `approval-gate/tasks/verify-authorization/auto-dispatch.md`
- `approval-gate/tasks/pre-implementation-analysis.md`

## Success Criteria

| ID | Criterion | Verification Method | Remediation |
|----|-----------|---------------------|-------------|
| SC-1 | `divide-and-conquer/SKILL.md` contains only two task references: `assemble-work` and references to enforcement docs. No references to deleted tasks exist. | `grep -c "orchestrate\|dispatch\|merge\|completion\|assess\|decompose\|context-passing\|purification\|implementer-prompt\|spec-reviewer-prompt\|code-quality-reviewer-prompt" .opencode/skills/divide-and-conquer/SKILL.md` returns 0 | Remove all references to deleted task files |
| SC-2 | `divide-and-conquer/tasks/assemble-work.md` is under 3000 words | `wc -w .opencode/skills/divide-and-conquer/tasks/assemble-work.md` returns ≤3000 | Trim content, fold enforcement details into reference docs |
| SC-3 | `assemble-work.md` contains the single-branch pipeline (steps 1-6 + PR as step 7) with verification layers: completeness-gate → VbC → adversarial-audit for both RED and GREEN phases | `grep -c "completeness-gate" .opencode/skills/divide-and-conquer/tasks/assemble-work.md` ≥ 2 AND `grep -c "adversarial-audit" .opencode/skills/divide-and-conquer/tasks/assemble-work.md` ≥ 2 AND `grep -c "verification-before-completion" .opencode/skills/divide-and-conquer/tasks/assemble-work.md` ≥ 2 | Add missing verification layer references |
| SC-4 | `assemble-work.md` contains result contract schema with status values: DONE, DONE_WITH_CONCERNS, BLOCKED, OVERFLOW, FAIL and Verify-Before-Acceptance protocol | `grep -E "DONE\|DONE_WITH_CONCERNS\|BLOCKED\|OVERFLOW\|FAIL" .opencode/skills/divide-and-conquer/tasks/assemble-work.md` matches all 5 status values AND `grep -c "Verify-Before-Acceptance" .opencode/skills/divide-and-conquer/tasks/assemble-work.md` ≥ 1 | Add result contract schema section with all status values and FAIL protocol |
| SC-5 | `assemble-work.md` delegates ALL git operations to `git-workflow` skill (pre-work, implementation, review-prep, completion) — no raw `git add`/`git commit`/`git push` commands | `grep -cE "(git add|git commit|git push)" .opencode/skills/divide-and-conquer/tasks/assemble-work.md` returns 0 | Replace raw git commands with git-workflow skill calls |
| SC-6 | `assemble-work.md` delegates ALL verification work (VbC, adversarial audit) to task() sub-agents — no inline verification logic | No inline VbC logic, no inline audit logic in assemble-work.md. `grep -cE "(inline.*verif|verify.*inline|self.verification)" .opencode/skills/divide-and-conquer/tasks/assemble-work.md` returns 0 | Move inline verification to task() sub-agent dispatch |
| SC-7 | Deleted task files do not exist: orchestrate, dispatch, merge, completion, assess, decompose, context-passing (moved to enforcement), purification-and-enforcement, overflow-signal (moved to enforcement), implementer-prompt, spec-reviewer-prompt, code-quality-reviewer-prompt | `ls .opencode/skills/divide-and-conquer/tasks/orchestrate.md .opencode/skills/divide-and-conquer/tasks/dispatch.md .opencode/skills/divide-and-conquer/tasks/merge.md .opencode/skills/divide-and-conquer/tasks/completion.md .opencode/skills/divide-and-conquer/tasks/assess.md .opencode/skills/divide-and-conquer/tasks/decompose.md .opencode/skills/divide-and-conquer/tasks/implementer-prompt.md .opencode/skills/divide-and-conquer/tasks/spec-reviewer-prompt.md .opencode/skills/divide-and-conquer/tasks/code-quality-reviewer-prompt.md .opencode/skills/divide-and-conquer/tasks/purification-and-enforcement.md .opencode/skills/divide-and-conquer/tasks/context-passing.md .opencode/skills/divide-and-conquer/tasks/overflow-signal.md` returns "No such file or directory" for all | Remove files |
| SC-8 | `SKILL.md` has no persona section, no word count table | `grep -c "Persona" .opencode/skills/divide-and-conquer/SKILL.md` returns 0 AND `grep -cE "Words\s*\|" .opencode/skills/divide-and-conquer/SKILL.md` returns 0 | Remove persona and word count table |
| SC-9 | `SKILL.md` tasks table has exactly one entry: `assemble-work` | `grep -A5 "Tasks" .opencode/skills/divide-and-conquer/SKILL.md` shows only assemble-work | Remove other task references |
| SC-10 | `executing-plans/tasks/start.md` does not reference `divide-and-conquer --task orchestrate` | `grep -c "orchestrate" .opencode/skills/executing-plans/tasks/start.md` returns 0 | Remove orchestrate reference, update to point to assemble-work |
| SC-11 | `SKILL.md` symbolic rules reference only `assemble-work` task, not deleted tasks | `grep -E "assess|decompose|dispatch|merge|completion|orchestrate" .opencode/skills/divide-and-conquer/SKILL.md` returns no matches in symbolic rules section | Update symbolic rules to reference only live tasks |
| SC-12 | Enforcement reference docs remain untouched: context-passing.md, overflow-signal.md, work-state-verification.md | `ls .opencode/skills/divide-and-conquer/enforcement/context-passing.md .opencode/skills/divide-and-conquer/enforcement/overflow-signal.md .opencode/skills/divide-and-conquer/enforcement/work-state-verification.md` succeeds | No change needed — files remain as-is |
| SC-13 | `completion-checkpoint.md` and `result-validation.md` removed from enforcement/ (content folded into assemble-work.md) | `ls .opencode/skills/divide-and-conquer/enforcement/completion-checkpoint.md .opencode/skills/divide-and-conquer/enforcement/result-validation.md` returns "No such file or directory" | Remove files, content is in assemble-work.md |
| SC-14 | Behavioral enforcement test: agent dispatches sub-agents for RED, GREEN, VbC, and adversarial-audit — does NOT perform inline file edits, inline verification, or inline git operations | Run behavioral test: `bash .opencode/tests/with-test-home opencode-cli run "implement the divide-and-conquer redesign spec"` → stderr shows task() calls for each sub-agent dispatch, no inline file edits | Add behavioral enforcement test in `.opencode/tests/behaviors/` |

## Edge Cases

1. **Single-issue work**: If only one issue in the batch, the per-issue loop still runs once. No special case needed.
2. **Sub-agent BLOCKED/OVERFLOW**: Result contract statuses route to remediation (BLOCKED → HALT with blocker report, OVERFLOW → re-dispatch with reduced scope per overflow-signal.md).
3. **Completeness-gate FAIL on RED**: If tests don't compile or SCs aren't covered, re-task RED sub-agent before expensive VbC/audit cycles.
4. **Adversarial-audit FAIL remediable**: Re-task the producing sub-agent (RED or GREEN) with audit findings included in context.
5. **VbC FAIL**: Re-task the producing sub-agent with VbC findings. If double-failure, HALT with blocker report.
6. **context-passing.md moved to enforcement/**: If any external reference points to `tasks/context-passing.md`, update it to `enforcement/context-passing.md`.
7. **executing-plans cross-reference**: start.md references both `orchestrate` and `assemble-work`. Only `assemble-work` reference needs to remain.

## Dependencies

- **git-workflow skill** (pre-work, implementation, review-prep, completion tasks): Must expose these task entry points for delegation.
- **approval-gate skill** (pre-implementation-analysis, yield-to-assemble-work): Provides the work state file that assemble-work depends on.
- **completeness-gate skill** (check task): Structural pre-check before expensive verification layers.
- **verification-before-completion skill** (verify task): Clean-room verification against spec success criteria.
- **adversarial-audit skill** (RED and GREEN audit tasks): Dual cross-family quality verification.
- **finishing-a-development-branch skill** (checklist task): Post-implementation structural checks.
- **issue-operations skill** (sub-issue linkage, progress comments): Issue tracking during pipeline execution.

## Decision Rationale

- **Single branch over branch-per-issue**: Branch-per-issue creates merge conflicts when issues touch shared files. Single branch with per-issue commits is simpler and conflict-free.
- **task() over skill call for VbC/audit**: VbC and audit need clean-room context separate from the producing sub-agent. skill() calls share orchestrator context. task() spawns a fresh context.
- **skill call for completeness-gate**: Structural checks are deterministic and judgment-free — no contamination risk, no need for clean-room isolation.
- **git-workflow skill for git ops**: Complete git workflow enforcement (hooks, state verification, conflict resolution) rather than raw git commands that skip required checks.
- **Keep enforcement reference docs**: context-passing, overflow-signal, and work-state-verification contain reusable reference material that other skills or sub-agents may need.
- **Fold completion-checkpoint + result-validation into assemble-work**: At 41 and 46 lines respectively, they're overhead to open separately for information the orchestrator needs inline.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `assemble-work.md`, `orchestrate.md`, all 13 task files and 4 enforcement files | Understand current structure and identify dead code |
| Direct source search | `approval-gate/tasks/pre-impl/yield-to-assemble-work.md`, `executing-plans/tasks/start.md` | Trace actual pipeline call graph |
| Direct source search | `git-workflow/tasks/pre-work.md`, `implementation.md`, `commit-prep.md`, `completion.md` | Verify git-workflow task entry points for delegation |
| Direct source search | `adversarial-audit/SKILL.md` | Confirm audit invocation and task structure |
| Direct source search | `completeness-gate/SKILL.md` | Confirm structural check invocation |
| Direct source search | `verification-before-completion/SKILL.md` | Confirm VbC invocation |
| MCP search | `srclight_search_symbols("divide-and-conquer")`, `srclight_search_symbols("assemble-work")` | Find all cross-references to d&c skill |
| MCP search | `srclight_search_symbols("orchestrate")` in skill context | Confirm orchestrate.md is dead code |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1) created