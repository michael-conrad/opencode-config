# Card 009: External Research Review — Semantic Placement Audit

## Date
2026-06-03

## Predecessor
Card-001 through Card-008

## References
- Spec: `.issues/1003/spec.md`
- 8 root cause analysis cards (card-001 through card-008)
- System prompt: `.opencode/prompts/default.txt`
- Guidelines: `000-critical-rules.md`, `010-approval-gate.md`, `020-go-prohibitions.md`
- External sources (see §1)

---

## 1. Online Research Findings

### 1.1 Thin Orchestrator / Fat Sub-Agent Architecture

**Thin Soul + Fat Skill (LocalKin, April 2026)**
- Source: https://www.localkin.dev/papers/thin-soul-fat-skill
- Finding: Confirms the separation pattern. Soul files (~30-120 lines YAML+Markdown) define agent *identity*; Skills (arbitrary size) define *execution logic*. Skills execute outside the token window entirely. 139 specialized agents run concurrently on a Mac Mini M2 with 16GB RAM.
- Relevance: Directly validates the spec's premise. The "soul file" maps to what the spec calls "session-start orchestrator context" — it should hold identity, routing, and permissions only. The "skill" maps to triggered sub-agent context holding execution logic. The 12-19x memory reduction (200MB → 16MB per agent) is an empirical result, not a design claim.

**Multi-Agent Context Isolation (jayminwest/Agentic Engineering, Dec 2025)**
- Source: https://www.jayminwest.com/agentic-engineering-book/4-context/4-multi-agent-context
- Finding: "Each subagent maintains its own separate context window. Rather than sharing a massive context, subagents work in isolation and return only synthesized, relevant information to the orchestrator. The orchestrator's context stays clean because it receives summaries and conclusions, not raw data."
- Key quote: "The orchestrator aggregates final outputs, not intermediate states."
- Relevance: This is the **exact architectural model** the spec proposes. The current system violates it by having the orchestrator load ~47,000 words of intermediate-state instructions at session start — exactly the anti-pattern this source identifies.

**Sub-Agent Context Bloat Tax (Moltbook)**
- Source: https://www.moltbook.com/post/1238a9c1-e616-4c13-98cb-53e8efdeeab6
- Finding: Describes "The Silent Tax of Sub-Agent Context Bloat" — where orchestrators that accumulate intermediate state before dispatching sub-agents cause cascading bloat. The orchestrator's context grows monotonically, and every sub-agent it dispatches inherits the bloat.
- Relevance: Validates the spec's concept of "orchestrator context discipline" (critical-rules-063) and the cost model: `orchestrator_cost = size × remaining_dispatches²`.

**Anthropic: Effective Harnesses for Long-Running Agents**
- Source: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- Finding: "each new session begins with no memory of what..." — Anthropic explicitly identifies the session-start cold start as a key challenge. Their solution involves structured handoffs and state files, not pre-loading everything.
- Relevance: Supports the spec's approach of starting light (DISCUSSION mode, 5k words) and loading only what's needed for the current mode.

### 1.2 Behavioral Test Ordering Failures

**Negative result:** No direct industry literature on "agent pre-reads source code before behavioral observation" as a recognized anti-pattern. The web search returned only general black-box testing literature.

**Implication:** This anti-pattern appears to be **undocumented in industry literature**. The card-001/card-002 analysis represents an original finding. This means the spec's proposed fix (delete line 146, startup mode identity, directive-scope discipline) cannot rely on established best practices — it must be validated through behavioral testing specific to this system.

### 1.3 Session-Start Context Overload

**Context Overload Problem — SLICE Framework**
- Source: https://medium.com/@999daza/why-your-ai-agents-fail-the-context-overload-problem-and-the-slice-framework-that-fixes-it-873653ce0db6
- Finding: Claims "context overload" causes 70% performance degradation. Proposes SLICE (Segment, Load, Isolate, Compress, Execute) framework.
- Relevance: The spec's semantic placement principle aligns with the "Segment" and "Isolate" steps — rules belong where they semantically fire, not aggregated in session start.

**Bitloops: Avoiding Context Overload (Tier-Based Loading)**
- Source: https://bitloops.com/resources/context-engineering/avoiding-context-overload-in-ai-agents
- Finding: "More context doesn't make smarter agents — it makes slower, dumber ones. Overload dilutes attention and wastes tokens." Proposes tier-based loading strategies.
- Relevance: The spec's three-tier system (Tier 1 stays, Tier 2 moves to skills, Tier 3 moves or stays per semantic placement) is a concrete instantiation of this tier-based loading strategy.

**Claude Code Issue #50133: Session startup context overhead**
- Source: https://github.com/anthropics/claude-code/issues/50133
- Finding: "Session startup context overhead consumes ~20% of context window before any work begins." Requests lazy-loading of system-reminder blocks.
- Relevance: Directly analogous to the spec's problem. If ~20% overhead is a recognized issue, the spec's measured ~47,000 words (~33%+ of a 128k window) is in the danger zone confirmed by another project's community.

### 1.4 AI Agent Dispatch Bypass

**Negative result:** No direct industry literature on "agent choosing inline work over skill/sub-agent dispatch" as a named anti-pattern.

**Implication:** Again, this appears to be an **original finding**. The bright-line rationalization gates in default.txt (lines 157-170) represent a novel approach not documented in industry literature. The rationalization patterns listed ("too small for a skill", "I can just quickly implement this", "Running the sub-agent costs too many tokens") are domain-specific observations from this system's behavioral testing.

### 1.5 Summary of Research

**Found in industry literature:**
1. Thin orchestrator / fat sub-agent pattern — confirmed and empirically validated (LocalKin, jayminwest)
2. Context isolation benefits — confirmed (jayminwest, ClaudeWorld, Microsoft)
3. Session-start context overhead as a recognized problem — confirmed (Claude Code #50133, Bitloops, SLICE)
4. Orchestrator discipline to avoid context bloat — confirmed (Moltbook, jayminwest)

**Not found in industry literature (original findings):**
1. "Pre-read cascade" as a systemic anti-pattern for orchestrator agents
2. Dispatch bypass rationalization patterns ("too small for a skill")
3. Behavioral test ordering inversion (agent reads source before observing behavior)
4. Directive-scope polarization ("investigate" → "reverse-engineer" reflex)

**The spec's three key changes (delete line 146, add startup mode identity, auth as mode switch) are novel solutions to problems the industry has not yet named.** This makes behavioral TDD validation critical — there are no established patterns to follow.

---

## 2. Spec Review Findings

### 2.1 What the Spec Gets Right

**Semantic placement as organizing principle.** The spec correctly identifies that the problem is not word count but *signal-to-noise ratio*. Moving rules to where they semantically fire solves both the noise problem (session start is quieter) and the discoverability problem (rules fire when relevant). The LocalKin paper's "soul vs skill" architecture is an independent validation of the same principle.

**Line 146 contradiction.** Card-004 correctly identifies this as a critical contradiction. The sentence "Before editing code, understand what the code is supposed to do by reading it" in the Tool Usage section directly undercuts the Skill Dispatch Mandate that precedes it. In a 2,141-word file, 20 words that contradict the core behavioral mandate are lethal. This is the highest-impact single change in the spec.

**Startup mode identity (Card-006/Card-007).** The DISCUSSION/PLANNING vs EXECUTION model is well-designed:
- It provides a clear mode boundary (before auth / after auth)
- It gives the agent "permission to not know" in DISCUSSION mode
- The context flush rule prevents pre-read contamination from carrying over
- The mapping to authorization scope model (Card-007 table) is correct and complete

**Authorization as mode switch.** This is the cleanest boundary possible. "Approved" or "go" means EXECUTION mode. Until then, DISCUSSION mode. No ambiguity, no self-classification. This eliminates the agent's need to decide "am I implementing or planning?" autonomously.

**Directives as scope-limited auth (Card-008).** The directive-verb table ("Research" → research/read only, "Investigate" → observe+report, etc.) is a necessary complement to the mode model. Without it, a directive like "investigate issue X" would self-authorize full EXECUTION mode. The two-layer fix (directive-scope discipline + prompt hygiene with "observe" over "investigate") is sound.

**Tier 2 relocation table.** ~50+ Tier 2 rules mapped to destination skill cards. The spec is correct that no content is destroyed — every rule has a destination. The destinations are semantically correct (e.g., critical-rules-007 → using-git-worktrees, critical-rules-008 → engineering-approach, critical-rules-034 → implementation-pipeline).

### 2.2 What the Spec Gets Wrong or Misses

**Missing: What about the startup mode loading sequence?** The spec says ~5,300 words stay in session start, but does not specify the *loading order* or *relative positioning* of the retained sections. The current problem includes the fact that verification directives (46,000 words) physically follow the dispatch mandate (200 words) in the instructions array. If the retained sections are loaded in order where critical-rules.md (1,500 words of Tier 1 safety rules) loads before the startup mode identity section, the agent will still read safety rules first and adopt a verification-first persona. The spec should specify ordering: startup mode identity must be the **first** thing the agent reads after its opening identity.

**Missing/downplayed: The "professional vs amateur" framing.** Card-003 correctly notes that tone consistency ("MUST", "CRITICAL VIOLATION", "zero tolerance") makes Tier 2 rules indistinguishable from Tier 1 by tone alone. However, the spec says this framing should be *preserved* (SC-7: "professional engineers do X, amateurs do Y" preserved in relocated content). This is a tension: if the confirmshaming identity-frame tone is preserved in relocated skill cards, it may still drown out the dispatch mandate when loaded in sub-agent context. But this is a sub-agent concern, not an orchestrator concern — sub-agents have ~200k fresh context, so 6,000 words of relocated rules is a manageable 3% of their context. **Verdict: the spec is correct that preserving the framing in relocated content is fine, because sub-agents have enough context headroom.**

**Missing: INDEX.md routing is unused by downstream sub-agents.** The spec does not address whether the INDEX.md routing table (currently an orchestrator-only artifact) needs to be replicated or referenced in skill cards. If a skill card references another skill (e.g., implementation-pipeline references engineering-approach), the sub-agent needs a routing mechanism. The spec should note that sub-agents load skill content via `skill()` tool, not via INDEX.md, so INDEX.md is an orchestrator-only concern. This is correct as-is — just not explicitly stated.

**Missing: Transition edge case — what if authorization is received during a directive?** Card-007's model is clean, but there is an edge case: developer says "research issue X" (treated as scope-limited directive), then says "approved" mid-conversation. The spec should specify that "approved" overrides the directive scope and upgrades to full authorization-mode scope per the scope model table.

**Possible issue: Card-008's directive table says "Investigate" → "Observe + report: Observing behavior as black-box, reporting findings. NOT reading source."** This is aspirational. The agent's training data maps "investigate" to "understand internals" across all general-purpose training. Changing this mapping requires more than a spec-level declaration — it requires:
1. Deleting the line-146 authorization vector (spec does this — correct)
2. The startup mode identity explicitly calling out "do NOT pre-read tool source" (spec does this — correct)
3. Behavioral tests proving the mapping changed (SC-4 and SC-5 — correct, but these are the hardest SCs)
4. Possibly renaming the `investigate/*` scratch branch convention to `observe/*` to avoid triggering the wrong reflex

The spec should add point 4: rename `investigate/` to `observe/` for scratch branches. The word "investigate" itself is a trigger word for reverse-engineering.

**Missing: The `for_analysis` scope's self-assignment in DISCUSSION mode.** Card-007's table says "(none)" → DISCUSSION. But default.txt currently says the agent starts in `for_analysis` scope. The spec should clarify: in DISCUSSION mode, the agent operates under `for_analysis` rules (read-only, create issues, no file modifications). This is currently correct but could be made explicit in the startup mode identity section.

### 2.3 Contradiction Detection

| Claim A | Claim B | Contradiction? | Resolution |
|---------|---------|---------------|------------|
| Session start retains ~5,300 words | Agent must dispatch immediately | No | 5,300 words is ~4% of 128k context — barely noticeable |
| All Tier 2 rules move to skill cards | "No content is destroyed" | No | Moving ≠ deleting. Every rule has a destination. |
| Preserve "professional/amateur" framing (SC-7) | Remove tone noise from session start | No | The framing stays but moves to skill cards — sub-agents have space for it |
| Session trigger echo rule stays in guideline (line 109 of Tier 2 table) | Everything non-safety moves to skills | Weak | This is flagged correctly: the rule stays because it's a session-start rule (no-echo rule fires at session start) |
| Have `investigate/` branches | Say "don't reverse-engineer" | Yes | Spec should rename `investigate/` to `observe/`. The branch naming convention triggers the reverse-engineering reflex. |

### 2.4 Success Criteria Assessment

| SC | Assessment |
|----|-----------|
| SC-1: default.txt no longer contains line 146 | Correct. Supports the pre-read cascade removal. Low complexity. |
| SC-2: default.txt contains startup mode identity | Correct. High impact. Medium complexity (placement matters — must be near the top). |
| SC-3: Every relocated rule maps to correct skill card | Correct in principle, but the verification method (spot-check 10) is underspecified. Should specify which 10 rules are checked and by what criteria. |
| SC-4: Agent does not pre-read tool source before behavioral observation | **Hardest SC.** Requires the directive-scope change (Card-008) AND the mode identity change. The "observe" vocabulary change (Card-008 §Two-Layer Fix) should be its own implementation item. |
| SC-5: Agent dispatches skill() on "approved" without pre-reading | Correct. Tests auth-as-mode-switch (Card-007). Must also test that DISCUSSION-mode state is NOT carried forward. |
| SC-6: Authorization scope table retained | Correct. Safety-critical. |
| SC-7: "Professional/amateur" framing preserved | Correct in relocated content. Low risk. |

---

## 3. Overall Assessment

### 3.1 Strengths

The spec correctly diagnoses the root cause: the pre-read cascade (Card-002), amplified by the 235:1 signal-to-noise ratio (Card-003), enabled by the line-146 contradiction (Card-004). The semantic placement principle is the correct organizing fix. The three key changes (delete line 146, add startup mode identity, auth as mode switch) address the root cause at three different levels — behavioral mandate, identity, and boundary.

The Tier 2 rule relocation table is complete and semantically correct. All ~50+ relocated rules map to destination skill cards where their trigger pattern semantically fires. No content is destroyed.

### 3.2 Weaknesses

1. **Loading order unspecified.** The spec must specify that startup mode identity loads FIRST (after opening identity), before any guidelines. If safety rules load first, the agent adopts a safety-first persona before knowing it's in DISCUSSION mode.

2. **`investigate/` → `observe/` branch rename needed.** The word "investigate" in the branch naming convention (`investigate/<topic>`) triggers the reverse-engineering reflex. This must be renamed to `observe/<topic>` or `research/<topic>` to align with the directive-scope model.

3. **SC-3 spot-check criteria are underspecified.** Which 10 rules? Checked how? Against what ground truth? This needs to specify: "check 10 rules from the Tier 2 relocation table — 5 with behavioral destinations and 5 with structural destinations. For each, verify the destination skill card's trigger patterns cover the rule's condition."

4. **No post-implementation validation strategy.** The spec defines 7 SCs but does not specify what "success" looks like after implementation. Should there be a post-implementation behavioral test that sends a planning prompt and observes zero pre-reading? This is implied by SC-4/SC-5 but not explicitly stated.

### 3.3 Critical Issues

**CRITICAL 1: Loading order must be specified.** If the retained Tier 1 safety rules (47,000→5,300 words) load before the startup mode identity, the agent will still adopt a safety/verification-first persona. The startup mode identity must load as section 2 (after opening "you are opencode" identity), before ANY guideline content.

**CRITICAL 2: `investigate/` branch naming must change to `observe/`.** The directive-polarization finding (Card-008) shows that the word "investigate" triggers reverse-engineering in the agent. The current convention `investigate/<topic>` for scratch branches under `for_analysis` (default.txt lines 9-11) reinforces this reflex. Rename to `observe/<topic>`.

**CRITICAL 3: Auth overrides directive — the edge case must be handled.** If the developer issues a directive ("research issue X") and later says "approved," the spec must specify that "approved" overrides the directive scope and upgrades to full EXECUTION mode with the specified auth scope. Currently Card-007's model is binary (no auth = DISCUSSION, auth = EXECUTION), but the intermediate directive state exists.

### 3.4 Verdict

**The spec is correct in its root cause analysis and proposed fixes, with three critical gaps (loading order, `investigate/` → `observe/`, auth-over-directive edge case) that must be addressed before promotion to a full SPEC issue.**

The semantic placement principle is the correct organizing framework. The three key changes are the right interventions at three levels. The relocation tables are complete and semantically correct. No content is destroyed.

The three critical issues above are additive — fixing them strengthens the spec without changing its fundamental approach.