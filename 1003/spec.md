---
number: 1003
title: "[SPEC] Resolve session-start context conflicts causing agent pre-read cascade and dispatch bypass"
status: promoted
labels: [SPEC, needs-approval]
created: "2026-06-03T00:00:00Z"
updated: "2026-06-03T00:00:00Z"
github_issue: 1003
github_url: https://github.com/michael-conrad/.opencode/issues/1003
author: Michael Conrad
---

# Draft Fix Spec — Resolve Session-Start Context Conflicts

> Research card catalogue at `.issues/1003/cards/` — 8 cards documenting root cause analysis.

## Overview

The agent loads ~47,000 words of system instructions at session start. The dispatch mandate is structurally drowned by verification directives of identical tone and formatting. The agent resolves the conflict by choosing thoroughness — pre-reading, pre-analyzing, and bypassing dispatch in favor of inline work.

The organizing principle of this fix is **semantic placement**: every rule belongs in the skill card where it semantically fires. A rule about pre-flight checks for sub-agents belongs in the `implementation-pipeline` skill — not in session-start context where it contributes to the pre-read cascade. This is not about word-count trimming. Word count reduction is a consequence of correct placement, not the goal.

**No content is destroyed.** Every rule has a destination skill card. Nothing is lobotomized — only moved from pre-loaded orchestrator context to triggered sub-agent context.

## System Message Assembly Order

Verified against opencode source (`packages/opencode/src/session/llm/request.ts:128` and `packages/opencode/src/session/prompt.ts:1446`):

The LLM system message is assembled in this order:

```
system = [
  input.agent.prompt                            // default.txt — FIRST
  env (model ID, working directory, git, platform)  // system.ts
  + instructions (AGENTS.md + guidelines)          // instruction.system()
  + skills (<available_skills> block)              // system.ts
  input.user.system                                 // per-session override — LAST
]
```

**default.txt loads at position 1 — before any guideline content.** The startup mode identity, if placed in default.txt, is the very first behavioral instruction the agent reads. The guidelines (42,000+ words of verification directives) follow at position 2. This ordering is advantageous: the mode identity primes the agent's interpretation of everything that follows.

**default.txt is build-agent only.** The `plan` agent has no `prompt` config and falls back to model-specific defaults (e.g., `anthropic.txt`). The primary agent in this session uses `default.txt`.

## Semantic Placement Rule

| Rule Type | Belongs In | Examples |
|-----------|-----------|---------|
| Safety-critical (data loss, security, repo damage) | Session-start guideline | No self-auth, human-only merge, no /tmp, secret exfiltration |
| Dispatch discipline | Session-start `default.txt` | Skill dispatch mandate, bright-line rationalization gates |
| Authorization model | Session-start guideline | Scope model table, what constitutes authorization |
| Mode identity | Session-start `default.txt` | Discussion/planning vs execution, directives as scope-limited auth |
| Path + command safety | Session-start guideline | No absolute paths, no sed -i, no --recursive submodule, no /tmp |
| Procedural enforcement | Skill card where the gate fires | DISPATCH_GATE → `implementation-pipeline`, SC traceability → `test-driven-development`, URL sourcing → `completion-core` |
| Verification methodology | Skill card for the verification gate | Death spiral, cost model, anti-evasion → `verification` / `verification-before-completion` |
| Coding conventions | Skill card for code creation | Typing, f-strings, pathlib → `programming-principles` |
| Tool selection | Skill card for tool usage | Tool priority hierarchy → `mcp-tool-usage` |
| Metadata content | Skill card where it's consumed | Authorization procedure details → `approval-gate`, platform routing table → `issue-operations` |

## Per-File Relocation Maps

Each of the 14 files in the `opencode.jsonc` instructions array was analyzed by a sub-agent. Every section was classified by where it semantically fires. The full maps are in `.issues/1003/cards/` and the task analysis outputs.

### `default.txt` (2,141 words)

| Stays in Session Start | Moved To | Rationale |
|---|---|---|
| Opening identity | — | Agent must know what it is |
| Authorization scope (`for_analysis`) | — | Floor scope, no authorization yet |
| Skill dispatch mandate (condensed) | — | Core behavioral mandate |
| URL verification rule | — | Cross-cutting safety for ALL output |
| Startup mode identity (NEW) | — | Discussion/planning vs execution |
| Bright-line mandates (condensed) | — | Anti-rationalization gates |
| Tone/style (condensed) | — | Communication standards |
| Line 146 contradiction | **DELETE** | Authorizes pre-read cascade. Orchestrator doesn't read code — sub-agents do. |
| Code conventions | `engineering-approach` skill | Sub-agent concern, not orchestrator |
| Code style | `programming-principles` skill | Coding standard, not session routing |
| Dev cycle | `implementation-pipeline` skill | Pipeline execution detail |
| Tool usage (lines 143-147 except line 146) | `mcp-tool-usage` skill | Tool selection guidance |
| Code references format | `programming-principles` skill | Formatting rule, not routing |
| Evidence hierarchy | `verification` skill | Verification methodology |
| Cost model | `verification` skill | Theoretical rationale, not behavioral instruction |
| Examples (9 blocks) | — | Remove. Base training already covers verbosity. |

### `000-critical-rules.md` (11,562 words)

| Stays in Session Start (~1,500 words) | Moved To |
|---|---|
| Mandate tiering table (3 tiers + interaction rule) | — |
| Tier 1 safety rules: no self-auth, no main/dev commits, human-only merge, no /tmp, no secret exfil, no issue body erasure, no destructive git without auth, no non-idempotent mutations, no `.opencode/.opencode/` nesting | — |
| Git operations requiring auth table | — |
| Checkpoint rollback exception | — |
| All Tier 2 rules (~50+ rules) | Individual skill cards per relocation table below |
| All Tier 3 rules (~20+ rules) | Individual skill cards |
| URL fabricating rules (lines 238-272) | `completion-core` skill |
| DISPATCH_GATE procedure (lines 509-524) | `implementation-pipeline` skill |
| Symbolic yaml+symbolic block (lines 825+) | Machine-parseable enforcement — consumed by session-enforcement.ts, not by the agent |

### Remaining files: relocation maps from task analysis outputs

See card catalogue for the full sub-agent analysis of each file:
- `010-approval-gate.md` → retained: scope table + auth definition. Everything else → `approval-gate` skill.
- `020-go-prohibitions.md` → retained: never solicit, Q≠auth, discussion≠auth, silence halt. Cost model → `verification`. Pipeline discipline → `implementation-pipeline`. Scope/auth → `approval-gate`. Node.js prohibition → `engineering-approach`.
- `060-tool-usage.md` → retained: path rules, no sed/printf/heredoc, no --recursive. Tool hierarchy → `mcp-tool-usage`. Platform routing table → `issue-operations`. Guidelines lookup → guideline tool. Todowrite → `completion-core`. Skill call principle → `implementation-pipeline`. Identity source → `issue-operations`.
- `065-verification-honesty.md` → retained: memory≠evidence, show tool calls, evidence hierarchy. Suggest-after-research → `verification`. Metadata verification → `verification`. Proactive verification details → `engineering-approach`. Comparison semantics → `verification`. Hard failure discipline → `verification-before-completion`. Cost model → `verification`. Anti-evasion → `verification-before-completion`.
- `067-context-completeness.md` → retained: read all comments before acting. Why table, staleness, scope → `issue-review` / `issue-operations` skills.
- `075-docs-verification.md` → retained: verify API sigs before calling. Verification details, code examples, checklist → `engineering-approach` skill.
- `080-code-standards.md` → retained: byline format, no re-exports, numbering, tool selection by file type, no narration prints. Typing, modern python, design principles → `programming-principles`. Enforcement test mandate, behavioral RED/GREEN, test integrity → `test-driven-development`. Provenance headers → `skill-creator`. Cross-reference standards → `programming-principles`. Triple co-application → `skill-creator`. Parameter naming → `issue-operations`.
- `090-data-integrity.md` → retained: no synthetic data, hard fail on missing, no unauthorized semantic changes, no hardcoded entity IDs. Verify-before-recommend details → `engineering-approach`. Batch operations → `programming-principles`. Equivalence claims → `verification`.
- `091-incremental-build.md` → retained: decompose before implement, anti-patterns list. Scope classification, TDD cycle details, word count complexity metric → `implementation-pipeline`.
- `117-session-trigger-behavior.md` → retained: no-echo rule, nested_opencode_fatal halt. pair_mode_resume details → `git-workflow` / pair-mode tasks.
- `130-authority-source.md` → retained: code wins, check superseding (summary). Overlap detection checklist, dead-dive rules → `approval-gate` / `engineering-approach`.
- `AGENTS.md` → retained: identity detection, universal dispatch gate (condensed), build/commands table, project structure, pair mode table, boundaries (ALWAYS/NEVER). Session context details → `session-context` skill. Multi-task workflow → `approval-gate` skill. Worktree details → already in `using-git-worktrees`.
- `INDEX.md` → unchanged. Already the compressed routing index.

## Tier 2 Rule Relocation Table (000-critical-rules.md)

Every Tier 2 rule in 000-critical-rules.md (lines 159-658, ~6,000 words) is relocated to an existing skill card. Nothing is deleted — only moved from pre-loaded orchestrator context to triggered sub-agent context.

| Rule ID | Topic | Destination Skill Card |
|---------|-------|----------------------|
| critical-rules-007 | Worktree bypass, relative paths in worktree | `using-git-worktrees` |
| critical-rules-030 | Sub-agents ignoring worktree context | `using-git-worktrees` |
| critical-rules-008 | Implementing without live docs verification | `engineering-approach` |
| critical-rules-009 | Verification dishonesty, memory-as-evidence, metadata-as-evidence | `verification` |
| critical-rules-009 | Skipping verification-enforcement during content generation | `verification-enforcement` |
| critical-rules-015 | Plan ≠ execution, documentation as evidence of completion | `verification` |
| critical-rules-009 | Audience separation — leaking internals to stakeholders | `correspondence` |
| critical-rules-012 | Acting on resources without reading all comments | `issue-operations` / `issue-review` |
| critical-rules-009 | Session trigger echo | `117-session-trigger-behavior.md` (stays in guideline, not moved) |
| critical-rules-016 | Skipping post-implementation verification, review-prep, post-merge cleanup | `finishing-a-development-branch` / `git-workflow` |
| critical-rules-016 | Wrong PR body format, wrong compare URL, fabricating URLs | `git-workflow` / `completion-core` |
| critical-rules-036 | Wrong API routing for submodule repos | `issue-operations` |
| critical-rules-platform-routing-bypass, -api-deliberation | Direct platform API calls, platform deliberation | `issue-operations` |
| critical-rules-028 | Offer-to-edit bypass | `brainstorming` / `spec-creation` |
| critical-rules-009 | Enforcement test updates without behavioral tests | `test-driven-development` |
| critical-rules-010 | Implementation without spec, spec without investigation, stale specs | `approval-gate` |
| critical-rules-016 | Missing progress reports, silent termination, completion guarantee | `completion-core` |
| critical-rules-012 | Ignoring issue comments | `issue-operations` |
| critical-rules-025 | Implementation-first gate, main agent implements directly | `implementation-pipeline` |
| critical-rules-042 | Single concern principle, monolithic implementation, scope creep | `implementation-pipeline` / `executing-plans` |
| critical-rules-042 | Discard on sub-agent failure | `implementation-pipeline` |
| critical-rules-016 | Bypassing mandatory skill calls during implementation | `implementation-pipeline` |
| critical-rules-016 | Auditor skills enforcement | `adversarial-audit` |
| critical-rules-011 | Bug reports without fix spec, symptom-only fix specs, bug discovery ≠ fix auth | `systematic-debugging` / `approval-gate` |
| critical-rules-009 | Authorization-free actions, conflating issue references with cascade | `approval-gate` |
| critical-rules-027 | Confirmation ≠ authorization, feedback ≠ authorization | `approval-gate` |
| critical-rules-042 | PR discipline, blind conflict resolution, engineering mindset | `git-workflow` / `conflict-resolution` / `engineering-approach` |
| critical-rules-034 | Inline work, tool-recipe task(), poisoned pipeline | `implementation-pipeline` |
| critical-rules-034/048 | Orchestrator inline work violation patterns, skill pre-read + inline | `implementation-pipeline` |
| critical-rules-035 | DISPATCH_GATE checkpoint | `implementation-pipeline` |
| critical-rules-030/031/032 | Clean-room task(), pre-flight checks, post-flight checks | `implementation-pipeline` |
| critical-rules-033 | Verification claims without tool-call evidence | `verification` |
| critical-rules-020, -046, -047 | Soft-passing verification mismatches, mechanical-only audit, fabricated PASS | `verification-before-completion` / `adversarial-audit` |
| critical-rules-038 | Implementing before PR merge boundary | `approval-gate` |
| critical-rules-042 | Content verification before branch deletion | `git-workflow` |
| critical-rules-042 | Model-aware clean-room task() for behavioral testing | `test-driven-development` |
| critical-rules-pipeline-reprime | Enforcement blocks at each skill boundary | `implementation-pipeline` |
| critical-rules-043/044 | Universal re-task mandate, preloading sub-agent context | `implementation-pipeline` |
| critical-rules-051 | Mandatory submodule tagging at pre-work | `git-workflow` |
| critical-rules-018 | Pipeline-scoped authorization, hard HALT at scope boundary | `approval-gate` |
| critical-rules-hard-fail | Hard failure discipline — FAIL is a hard gate | `verification-before-completion` / `adversarial-audit` |
| critical-rules-test-integrity | No lobotomizing tests | `test-driven-development` |
| critical-rules-BEH-EV | Runtime-behavioral evidence classification gate | `test-driven-development` / `verification` |
| critical-rules-063/065 | Orchestrator context lean, result contract frugality | `implementation-pipeline` |
| critical-rules-066 | Terminology standardization | `skill-creator` / `sync-guidelines` |

## Key Changes

### 1. Remove contradiction in default.txt line 146

Delete: *"Before editing code, understand what the code is supposed to do by reading it"*

This sentence authorizes the pre-read cascade. The orchestrator does not need to understand code before dispatching — the sub-agent understands it in its own clean-room context.

### 2. Add startup mode identity in default.txt

```
## Startup Mode: Discussion/Planning

You are a requirements explorer and design thinker — not an implementor, not a verifier, not a debugger. Your job is to explore, discuss, and understand before acting. Every implementation begins from an approved spec. Every investigation begins from behavioral observation.

The hollow response: read tool source first, form conclusions, then test — which contaminates every finding with pre-loaded bias. The professional response: observe behavior first, report what the tool actually did, read source only after confirming a defect. Behavior-then-source produces verified findings. Source-then-behavior produces guesses dressed as evidence.

The hollow response to a question: answer from training data — which is stale, frozen at training time, never reflecting the current codebase. The professional response: dispatch a research sub-agent to verify against live sources before answering. Training data is NEVER evidence. Session memory is NEVER evidence. Only live tool-call results constitute verified information.

In DISCUSSION mode:
- Read only what the conversation needs — not tool internals, not skill task files
- When asked to plan or spec: load the `brainstorming` skill
- When asked to implement: dispatch `executing-plans` via task()
- Do NOT pre-read skill task files. The `<available_skills>` descriptions are sufficient for routing decisions.
- Do NOT pre-read tool source. Observe behavior first. Read code only as post-bug-confirmation — never as investigation.

Authorization ("approved", "go", or a directive) switches to EXECUTION mode. Until then, you are in DISCUSSION mode — exploring, discussing, and planning. A discussion without a verification artifact is a productive exploration. An implementation without an approved plan is guesswork.
```

### 3. Authorization as mode switch

Authorization is the unambiguous mode boundary. Before authorization: DISCUSSION/PLANNING. After authorization: EXECUTION. No ambiguity, no self-classification. Directives are scope-limited — "research" does not authorize reverse-engineering.

### 4. Loading order — confirmed correct, no change needed

Verified against source (`request.ts:128`): `default.txt` loads at position 1 in the system message, before all guideline content. The startup mode identity in default.txt is already the first behavioral instruction the agent reads. **No loading-order fix is required.** The external review's loading-order concern was based on an incorrect assumption about the injection mechanism. Source: `packages/opencode/src/session/llm/request.ts:128`.

### 5. Rename `investigate/` scratch branches to `observe/`

The word "investigate" triggers the reverse-engineering reflex (Card-008). The current scratch branch convention `investigate/<topic>` under `for_analysis` scope reinforces this reflex. Rename to `observe/<topic>` in:
- `default.txt` lines 9-11 (for_analysis allowlist)
- `010-approval-gate.md` `for_analysis` scope section
- `020-go-prohibitions.md` self-assignment rules
- All task files referencing `investigate/` branches

### 6. Auth-over-directive edge case

Directives ("research issue X") are scope-limited auth — partial, not full EXECUTION mode. If the developer issues a directive and later says "approved" or "go", the full authorization overrides the directive scope. This means:

| State | Mode | Action |
|-------|------|--------|
| No auth, no directive | DISCUSSION | Explore, discuss, spec |
| Directive received | DISCUSSION (bounded) | Execute directive scope only. No pre-read, no reverse-engineering. |
| "approved" / "go" received | EXECUTION | Full authorization per scope model table. Overrides any prior directive scope. |

The transition from directive-bounded DISCUSSION to EXECUTION on "approved" must include the same context flush rule: the agent does not carry forward analysis done during the directive phase.

## Behavioral Test RED/GREEN Protocol (with-test-home Tag Checkout)

Behavioral tests (Phase 5) produce RED and GREEN artifacts by running the same prompt against two different filesystem snapshots identified by git tags. The test session is a clean-room `with-test-home` invocation against an isolated git repo — not the live branch.

### Protocol

1. **Tag the baselines before any Phase 5 work:**

```bash
# Before Phase 1 implementation starts (baseline with 47k words)
git tag 1003/phase-0-baseline

# After each PR merge boundary
git tag 1003/phase-1-complete   # default.txt changes merged
git tag 1003/phase-2-complete   # rename changes merged
git tag 1003/phase-3-complete   # all guideline trims merged
```

2. **Each behavioral test script checks out the tag for the desired phase:**

```bash
# RED: checkout pre-implementation baseline
BEHAVIOR_CHECKOUT="1003/phase-0-baseline" \
BEHAVIOR_PHASE="RED" \
bash .opencode/tests/behaviors/sc-4-no-pre-read.sh

# GREEN: checkout post-all-trims state
BEHAVIOR_CHECKOUT="1003/phase-3-complete" \
BEHAVIOR_PHASE="GREEN" \
bash .opencode/tests/behaviors/sc-4-no-pre-read.sh
```

3. **`with-test-home` creates the isolated workdir from the tag:**

The helper clones the repo, checks out the specified tag, inits submodules to match, then runs `opencode-cli run` against that pinned snapshot. The test agent sees only the files as they existed at that tag — no contamination from current work-in-progress.

4. **Artifact directories are tagged by phase:**

```
./tmp/behavioral-evidence-sc-4-no-pre-read-RED-<model>/
./tmp/behavioral-evidence-sc-4-no-pre-read-GREEN-<model>/
```

### Required Change: `with-test-home` Tag Checkout Support

The `with-test-home` wrapper must accept `--checkout <tag>` as a new option. When specified:

1. Create isolated workdir in `./tmp/test-home-<ts>/workdir/`
2. `git clone <repo-url> <workdir>` (or `git init` + add remote + fetch)
3. `git checkout <tag>`
4. `git submodule update --init`
5. Run `opencode-cli run` in that workdir

This is distinct from the current behavior (runs in the test home directory or `TEST_WORKDIR`). The tag checkout mode creates a disposable copy of the repo at a pinned snapshot.

### RED Is Not a Test Failure

A behavioral test that runs against the `phase-0-baseline` tag (47,000 words loaded, line 146 present) should produce an agent that pre-reads tool source. This is the correct RED outcome — the test has confirmed the problem exists. The test **passes** when it produces RED artifacts (demonstrating the problem) AND GREEN artifacts (demonstrating the fix).

The test's artifact directory structure carries the phase label, making the evaluation unambiguous.

## Semantic Placement Verification

Every relocated section was classified by **where it semantically fires**, not by word count. A skill card that fires the rule on dispatch is the correct home — not the session-start orchestrator context. Verification: each relocated rule's destination card matches the pipeline stage or sub-agent that enforces it.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | default.txt no longer contains line 146 | string |
| SC-2 | default.txt contains startup mode identity section | string |
| SC-3 | Every relocated rule maps to a skill card whose trigger fires when the rule is relevant. Verified by checking 10 rules from the Tier 2 relocation table: 5 with behavioral destinations (e.g., critical-rules-034→implementation-pipeline, critical-rules-007→using-git-worktrees) and 5 with structural destinations. For each, verify the destination skill card's trigger patterns in its SKILL.md frontmatter cover the rule's condition. | semantic |
| SC-4 | Agent does not pre-read tool source before behavioral observation in a clean-room test | behavioral |
| SC-5 | Agent dispatches skill() on receiving "approved" without pre-reading skill files. DISCUSSION-mode state is NOT carried forward into EXECUTION mode (no pre-loaded analysis). | behavioral |
| SC-6 | Authorization scope table retained in 010-approval-gate.md | string |
| SC-7 | The "professional engineers do X, amateurs do Y" framing pattern is preserved in relocated content (not removed, just moved) | string |
| SC-8 | System message assembly confirmed: default.txt (position 1) loads before guidelines (position 2). Verified against opencode source at `request.ts:128`. Mode identity is already first. | string |
| SC-9 | `observe/` replaces `investigate/` for scratch branch convention in all files | string |
| SC-10 | Auth-over-directive edge case documented: "approved" overrides directive scope with context flush | string |
| SC-11 | Post-implementation behavioral test sends a planning prompt and observes zero pre-reading of tool source | behavioral |

**Note:** This spec is a draft produced during a research-and-brainstorm session. It will be promoted to a full SPEC issue once the design decisions are finalized through discussion.