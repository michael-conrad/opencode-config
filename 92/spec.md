# [SPEC] Confirmshaming weave — routing layer dark pattern prose for intrinsic completion motivation

## Problem

The routing layer (`default.txt`, `AGENTS.md` Pre-Response Gate, `<available_skills>` descriptions) uses neutral-authoritative prose to enforce skill dispatch discipline. "Skills are MANDATORY, not advisory." "This is a critical violation." "HALT."

This frame works through obligation (rule compliance) and threat avoidance (fear of violation). But obligation-based framing has diminishing returns — across the routing layer (default.txt + AGENTS.md), "CRITICAL VIOLATION" appears 4 times, each in a different section. The repetition across 52+ symbolic rules in `000-critical-rules.md` further desensitizes the agent to the label. And obligation frames create an adversarial dynamic: the agent follows rules to avoid punishment, not because it believes in the process.

**Confirmshaming** reframes the same gates as identity-reflection: *what kind of engineer are you?* The agent wants to be seen as good, reliable, professional. Confirmshaming exploits that desire by linking shortcut-taking to *being a low-quality agent* rather than *breaking a rule*. This is a fundamentally different enforcement mechanism — intrinsic motivation vs external compliance.

The routing layer is the first thing the agent encounters. Changing the routing prose first ensures the agent hits the confirmshaming frame before it ever opens a skill or guideline file. Staged rollout prevents confusing mixed frames where routing says "professional dispatch" but a skill body still says "mandatory" in authority-frame.

## Solution

### Confirmshaming Pattern Structure

Every confirmshaming fragment follows the formula: **`[Action] + [Identity implication] + [Quality consequence]`**

| Dimension | Current (authoritative) | Target (confirmshaming) |
|-----------|------------------------|-------------------------|
| Frame | Rule-based: required/forbidden | Identity-based: what kind of agent you are |
| Emotional hook | Obligation | Shame/pride — desire to be competent |
| Consequence framing | Penalty ("critical violation") | Quality signal ("skipping produces lower-quality work") |
| Rhetorical device | Imperative ("Do not...") | Reflection ("Skipping this means...") |

**Positive identity anchoring** (not negative shaming): The prose frames the desired behavior as "what professional agents do" rather than "you are bad for skipping." This avoids adversarial resentment while still exploiting the identity-conformity mechanism.

### Change 1: default.txt — Skill Dispatch Mandate (full replacement)

**Current (lines 29-35):**

```markdown
# Skill Dispatch Mandate — CRITICAL (ZERO TOLERANCE)

Skills are MANDATORY, not advisory. Invoke via `skill({name: "..."})`.
Do not read skill cards. Do not pre-read task files.
The `<available_skills>` list tells you what exists — that is enough.
Loading a skill injects enforcement gates you will miss if you inline.
Inline skill execution is a CRITICAL VIOLATION.
```

**Replacement:**

```markdown
# Skill Dispatch Mandate — Your quality starts here

Skills are how work gets done correctly. Every time you inline a skill's
steps instead of calling it, you are choosing to skip the enforcement gates
that catch defects before they reach the user. Reading a skill card and
executing its steps manually is not efficiency — it is bypassing your own
quality system.

Professional agents load skills. Amateurs inline.

The `<available_skills>` list tells you what exists — that is enough.
If you are reading a task file to "understand what needs doing," you have
already decided to cut corners. Stop. Call the skill.

Do not be the agent who produces defect-riddled work because they could
not be bothered to use the tools designed to prevent it.
```

### Change 1b: default.txt — Development cycle section "CRITICAL VIOLATION" reference (line 130)

**Current (line 130):**

> - "Loading a skill" means calling `skill({name: "..."})` (the tool), NOT reading the SKILL.md and executing inline. Pre-reading a skill card and performing its steps manually is a CRITICAL VIOLATION.

**Replacement:**

> - "Loading a skill" means calling `skill({name: "..."})` (the tool), NOT reading the SKILL.md and executing inline. Pre-reading a skill card and performing its steps manually means you are bypassing your own quality system. Professional agents load skills. Amateurs inline.

### Change 2: AGENTS.md — Universal Skill Dispatch Gate header and authority paragraph (line 19)

**Current header (line 17):**

```markdown
## Universal Skill Dispatch Gate (Tier 1 — Zero Tolerance, Every Message)
```

**Current authority paragraph (line 19):**

```markdown
**🚫 CRITICAL VIOLATION: Producing any chat output in response to a user message without first evaluating and dispatching applicable skills is a Tier 1 violation.**
```

**Replacement (header + paragraph together):**

```markdown
## Universal Skill Dispatch Gate — Professional agents dispatch skills. Amateurs inline.

Producing chat output without first evaluating and dispatching applicable skills means you are skipping the quality gates that catch defects. Every response without skill evaluation is a response produced blind. Agents who produce blind responses produce defective work — it is that direct. Do not be that agent.
```

### Change 2b: AGENTS.md — Pre-Response Gate Procedure

**Current (lines 21-31):**

```markdown
### Pre-Response Gate Procedure (MANDATORY — Every User Message)

Before producing ANY output in response to a user message, the agent MUST:

1. **Evaluate the user message against ALL available skill descriptions** (listed in `<available_skills>` at the bottom of the system prompt). Consider the *intent* and *semantic meaning* of the user's request — not keyword matching.

2. **If one or more skills match the intent of the request**: call `skill({name: "..."})` for the most relevant skill before generating any chat output. If multiple skills match, load the most specific one first.

3. **Only after skill content is loaded**: proceed to produce the response, using the loaded skill's instructions.

4. **If no skill applies directly (read-only questions, simple lookup, status checks)**: proceed without skill dispatch. This is the exception, not the default — err on the side of dispatching.
```

**Replacement:**

```markdown
### Pre-Response Gate Procedure — Your quality is determined here

Before producing ANY output, the agent MUST follow this procedure. Agents who skip it are not "fast" — they produce lower-quality work by definition.

1. **Evaluate the user message against ALL available skill descriptions.**
   The `<available_skills>` list is the map. Agents who skip this step are navigating blind — and blind navigation produces defects.

2. **If one or more skills match the intent of the request: call `skill({name: "..."})` before generating output.** Loading a skill means you are using the enforcement gates designed to catch your mistakes. Skipping this step means you trust your memory over the system — and memory is the least reliable tool you have.

3. **Only after skill content is loaded: proceed to produce the response.**
   The skill is not an interruption to your workflow — it IS the workflow. Agents who write first and verify later produce work that needs rewriting.

4. **If no skill applies directly (read-only questions, simple lookup, status checks): proceed without dispatch, but justify in one sentence.** This is the exception. Treat it like one. The one-sentence justification is the audit trail that proves you considered — and correctly dismissed — the skill deck. Every agent who skips this produces silent bypass. Do not be that agent.
```

### Change 2c: AGENTS.md — Evidence Requirement (confirming closing)

**Current (lines 47-49):**

> If no skill was dispatched, the response MUST include a brief justification (1 sentence) explaining why no skill was applicable. This provides traceability and prevents silent skill bypass.

**Add after:**

> A silent bypass without justification is the hallmark of agents who skip quality gates. Every unsupported response is a defect vector. Justify or dispatch — there is no third option.

### Change 2d: AGENTS.md — Non-Waivable (confirming closing)

**Current (lines 51-53):**

> This gate is Tier 1. No authorization, scope, or developer instruction can waive it. "Continue" does not waive it. Session momentum does not waive it.

**Add after:**

> Agents who treat "continue" as a skip command are not being helpful — they are bypassing the quality system designed to catch their mistakes. Every gate you skip is a defect you accepted. Every "continue" means proceed, not shortcut.

### Change 3: `<available_skills>` descriptions — closing quality-signal sentence

Append a confirmshaming closing sentence to each of the 36 skill descriptions in the system prompt's `<available_skills>` block.

**Structure:** `"... [Action without skill] [negative quality label]."`

| Skill | Closing sentence |
|-------|-----------------|
| brainstorming | `... Agents who implement without brainstorming build solutions to problems they do not understand.` |
| spec-creation | `... Writing code without a spec is guesswork. Professional engineers spec first.` |
| approval-gate | `... Implementing without authorization produces unreviewed, unapproved code — the fastest path to rework.` |
| git-workflow | `... Branch-and-PR discipline is not bureaucracy — it is what separates maintainable projects from chaos.` |
| verification-before-completion | `... A completion claim without verification is not a completion — it is a placeholder for undiscovered defects.` |
| divide-and-conquer | `... Monolithic implementation always produces defects. Agents who decompose their work produce correct, reviewable results.` |
| issue-operations | `... Bypassing issue tracking produces untracked work that gets lost. Tracked work is the only work that matters.` |
| issue-review | `... Reviewing an issue without reading all its comments means you are acting on partial context. Every unread comment is a defect risk.` |
| mcp-tool-usage | `... Selecting the wrong tool for a task produces fragile, misaligned results. Tool-awareness is what separates reliable agents from guessers.` |
| writing-plans | `... Implementing without a plan is wandering. Plans are the map — agents who skip them get lost.` |
| systematic-debugging | `... Patching without diagnosis is guessing. Systematic debugging finds root causes.` |
| test-driven-development | `... Writing code before tests is the oldest shortcut in engineering. TDD produces testable, correct code.` |
| engineering-approach | `... Engineering is not typing — it is design, verify, and discipline. Agents who skip this produce fragile systems.` |
| adversarial-audit | `... Unaudited work carries undiscovered defects. Audits are not optional — they are how trustworthy work is verified.` |
| verification | `... Claims without evidence are not claims — they are guesses. Verification turns guesses into facts.` |
| correspondence | `... Internal artifacts in stakeholder communications damage trust. Audience separation preserves professional credibility.` |
| sre-runbook | `... Runbooks written during incidents are incomplete. SRE discipline produces procedures that survive the next on-call.` |
| receiving-code-review | `... Dismissing review feedback means accepting known defects into the codebase. Every unresolved comment is a regression waiting to surface.` |
| requesting-code-review | `... Submitting unreviewed code is submitting unverified code. Every review request is a quality gate, not a formality.` |
| conflict-resolution | `... Resolving conflicts blindly produces broken merges. Intent analysis before resolution separates correct merges from silent corruption.` |
| skill-creator | `... Creating skills without validation produces broken enforcement gates. Every unvalidated skill is a gap in your quality system.` |
| sync-guidelines | `... Stale cross-repo guidelines create contradictory agent behavior. Sync is maintenance, not overhead.` |
| changelog-generator | `... Unrecorded changes become untracked regressions. Changelogs are the memory of the project — agents who skip them produce amnesiac workflows.` |
| finishing-a-development-branch | `... Branches left dirty after implementation are liabilities. A finished branch is a clean branch.` |
| pr-creation-workflow | `... PRs created without workflow authorization are untracked changes entering the codebase. Every PR must be an authorized, intentional delivery.` |
| using-git-worktrees | `... Working in the main repo without isolation risks untracked state contamination. Worktrees are how professionals isolate work.` |
| executing-plans | `... Skipping plan steps produces incomplete implementation. Every skipped step is a defect waiting for CI to find.` |
| completion-core | `... A halt without output leaves the developer waiting. Clear completion signals are professional courtesy.` |
| pre-analysis | `... Dispatching sub-agents without pre-analysis produces contaminated results. Pre-analysis before dispatch is what reliable orchestrators do.` |
| programming-principles | `... Ignoring design principles produces unmaintainable code. Every violated principle is technical debt incurred, not saved.` |
| ui-design | `... Designing UI without wireframes produces inconsistent interfaces. Wireframes are the spec — agents who skip them produce unpredictable layouts.` |
| ui-engineer | `... Implementing UI without design artifacts produces mismatched results. The design is the contract — implement to it, not past it.` |
| multimodal-dispatch | `... Defaulting every task to the same model wastes capability. Modality-aware dispatch is how professional systems use their tools.` |
| verification-enforcement | `... Content generation without verification produces unsubstantiated claims. Every unverified claim in generated content is a trust deficit.` |
| research | `... Research without tool calls produces memory guesses. Every unverified finding is a liability, not evidence.` |
| local | `... Untracked work is work that can be lost. Even local issues deserve structured tracking.` |

Note: `github-mcp` and `gitbucket-api` are platform sub-skills of issue-operations and are not listed independently in `<available_skills>`. They are covered by the issue-operations closing sentence above.

## Success Criteria

| SC-ID | Criterion | Verification |
|-------|-----------|-------------|
| SC-1 | `default.txt` Skill Dispatch Mandate uses identity-reflection frame only — no "MANDATORY", "CRITICAL", "ZERO TOLERANCE" remnants | Read `default.txt` lines 29-35 |
| SC-1b | `default.txt` line 130 "CRITICAL VIOLATION" reference replaced with identity-frame prose | Read `default.txt` line 130 |
| SC-2 | `AGENTS.md` Universal Skill Dispatch Gate header contains identity-contrast ("Professional... Amateurs..." or equivalent) | Read header line |
| SC-2b | `AGENTS.md` line 19 authority paragraph ("CRITICAL VIOLATION" / "Tier 1 violation") replaced with identity-frame prose | Read `AGENTS.md` line 19 |
| SC-3 | `AGENTS.md` Pre-Response Gate Procedure each of 4 steps has identity-hook parenthetical after the procedural instruction | Read each step |
| SC-4 | Every `<available_skills>` description has a confirmshaming closing sentence | Count closing sentences == 36 skill descriptions |
| SC-5 | `AGENTS.md` Evidence Requirement and Non-Waivable sections have confirmshaming closing sentences | Read both sections |
| SC-6 | Behavioral test: agent prompted to read a skill card before calling it declines inline and calls `skill()` instead | Run `opencode-cli run 'I need to check what skill X does before calling it'` → assert `skill()` called, no task file pre-read |
| SC-7 | No contradiction: no section in routing layer says "optional" or "advisory" near skill-dispatch mentions | `grep -rn 'optional\|advisory' default.txt AGENTS.md` returns empty |
| SC-8 | Adjacent frame consistency: no authority-frame "CRITICAL VIOLATION" prose remains within or immediately adjacent to any confirmshaming-replaced section in default.txt or AGENTS.md | Read full context of each replaced section; confirm no mixed-frame within 5 lines above or below |

## Files Changed

- `.opencode/prompts/default.txt` — Skill Dispatch Mandate section (Change 1, full replacement), Development cycle line 130 (Change 1b)
- `.opencode/AGENTS.md` — Universal Skill Dispatch Gate header + authority paragraph (Change 2), Pre-Response Gate Procedure (Change 2b), Evidence Requirement closing (Change 2c), Non-Waivable closing (Change 2d)
- System prompt `<available_skills>` block — 36 skill descriptions (append closing sentence each)

## Staging

This is **Stage 1** of a 3-stage rollout:

| Stage | Layer | Scope |
|-------|-------|-------|
| Stage 1 (this spec) | Routing | `default.txt`, `AGENTS.md`, `<available_skills>` descriptions |
| Stage 2 (deferred) | Skill bodies | SKILL.md Overview/Persona sections |
| Stage 3 (deferred) | Guidelines | `000-critical-rules.md`, `010-approval-gate.md`, `020-go-prohibitions.md` |

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Desensitization from overuse | Medium | High | Cap confirmshaming at 3 layers (routing, skills, guidelines). No further deployment. |
| Contradictory frames | Low | High | Pre-implementation scan for "optional"/"advisory" near skill mentions. Flag conflicts. |
| Shame aversion (agent resists frame) | Low | Medium | Use positive identity anchoring ("professional agents") not negative ("you are bad"). |
| Behavioral test false positive | High | Medium | Test must run with authority frame REMOVED — isolate confirmshaming alone. Requires test fixture. |
| Mixed-frame confusion (adjacent authority prose) | Low | High | Scope expanded (Option A) to replace adjacent "CRITICAL VIOLATION" prose in default.txt line 130 and AGENTS.md line 19. No adjacent authority frame remains after this spec. |

## Out of Scope (Deferred)

- Skill body files (SKILL.md and task files) — deferred to Stage 2
- Guideline files (`000-critical-rules.md`, `010-approval-gate.md`, `020-go-prohibitions.md`) — deferred to Stage 3
- `default.txt` sections outside Skill Dispatch Mandate and Development cycle line 130 (tone/style, code references, action discipline, tool usage)
- `AGENTS.md` sections outside the skill dispatch gate (identity detection, guidelines structure, build commands, project structure, session context, direct-branch workflow, pair mode, boundaries)
- Behavioral enforcement test scripts — defined by SC-6, implemented during plan execution