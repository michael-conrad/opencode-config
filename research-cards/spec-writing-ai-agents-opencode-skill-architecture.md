---
research_question: "What are the most effective patterns for writing specs that serve both AI agents and human developers, and what is the canonical opencode skill architecture (skill card vs task card, sub-skill validity)?"
confidence: 0.90
status: active
tags:
  - spec-writing
  - ai-agents
  - dual-audience
  - skill-architecture
  - opencode
  - skill-card
  - task-card
  - sub-skill
created: 2026-07-22
last_updated: 2026-07-22
sources:
  - https://addyo.substack.com/p/how-to-write-a-good-spec-for-ai-agents
  - https://deliberate.codes/blog/2026/writing-specs-for-ai-coding-agents/
  - https://www.augmentcode.com/guides/ai-spec-template
  - https://www.kinde.com/learn/ai-for-software-engineering/best-practice/the-anatomy-of-a-good-spec-in-the-age-of-ai/
  - https://practiceoverflow.substack.com/p/effective-spec-driven-development
  - https://opencode.ai/docs/skills/
  - https://opencode.ai/docs/agents/
  - https://deepwiki.com/joshuadavidthomas/opencode-agent-skills/3.1-understanding-skills
  - https://deepwiki.com/joshuadavidthomas/opencode-agent-skills/5.1-semantic-skill-matching
  - https://github.com/GSA-TTS/devCrew_s1/blob/master/docs/templates/AI%20Agent%20Specification%20Template.md
  - https://colign.co/blog/how-to-write-software-spec-template
  - https://levelup.gitconnected.com/how-to-write-specs-for-ai-7-rules-and-a-checklist-for-better-code-a5af2b2c6205
  - https://www.analyticsinsight.net/artificial-intelligence/how-to-write-effective-specifications-for-ai-agents
  - https://nevo.systems/blogs/nevo-journal/how-to-write-ai-agent-skill
  - https://github.com/agentskills/agentskills
  - https://medium.com/@pbalves/part-1-opencode-ai-agent-skills-a-conceptual-deep-dive-f16a515d73e2
  - https://relearn.ing/projects/opencode-skills/
  - https://ai.sulat.com/writing-opencode-agent-skills-a-practical-guide-with-examples-870ff24eec66
---

## Summary

Three independent research threads converge on a single conclusion: (1) the current spec-creation skill is over-fragmented into sub-skills that don't exist as a first-class opencode concept, (2) the spec format it produces should follow BDD/RFC 2119 patterns for dual-audience readability, and (3) the `description` field is a semantic router — the agent evaluates its OWN intent against the description, not the user's literal utterance. The opencode skill system has exactly one abstraction — the SKILL.md with YAML frontmatter — and "sub-skills" are not a supported construct.

---

## Thread 1: Spec Writing for AI Agents (Dual Audience)

### Finding 1: Spec Structure — BDD + RFC 2119

**Source:** [deliberate.codes — Writing specs for AI coding agents](https://deliberate.codes/blog/2026/writing-specs-for-ai-coding-agents/)

The most effective spec format borrows from Behavior-Driven Development (BDD) and RFC 2119:

```
# Feature Name Specification

## Purpose
One paragraph describing what this spec covers and why it matters.

## Requirements
### Requirement: Capability Name
Brief description of the requirement.

#### Scenario: Specific behavior
- **WHEN** a specific condition occurs
- **THEN** it SHALL do something specific
- **AND** it SHALL also do this other thing
```

**RFC 2119 keywords** eliminate ambiguity:

| Keyword | Meaning |
|---------|---------|
| SHALL / MUST | Absolute requirement |
| SHALL NOT / MUST NOT | Absolute prohibition |
| SHOULD / RECOMMENDED | Strong recommendation, valid exceptions may exist |
| SHOULD NOT / NOT RECOMMENDED | Strong discouragement |
| MAY / OPTIONAL | Truly optional |

**Key insight:** Using only SHALL forces everything to be mandatory or omitted entirely. The full vocabulary lets specs express degrees of importance.

**Edge case coverage is mandatory:**
- Empty result sets
- Null values
- Timeouts
- Failure modes
- **What SHALL NOT happen** (prohibitions are as important as requirements)

### Finding 2: 7 Required Sections

**Source:** [Augment Code — AI Spec Template](https://www.augmentcode.com/guides/ai-spec-template)

Production teams use these 7 sections:

| # | Section | Purpose |
|---|---------|---------|
| 1 | **Objective and Scope** | Clear, singular goal in 1-3 sentences. Prevents over-engineering. |
| 2 | **Tech Stack and Versions** | Explicit stack declarations. "React" without version → mixed React 18/19 patterns. |
| 3 | **Input/Output Contracts** | Machine-readable schemas (Zod, JSON Schema, OpenAPI). Constrain output without prescribing implementation. |
| 4 | **Business Rules and Constraints** | Every rule must be deterministic and testable. Each maps to an acceptance criterion. |
| 5 | **Acceptance Criteria** | Concrete inputs and outputs. Prevents "validates input and returns error" → no structured error object. |
| 6 | **Not Included** | Explicit scope boundary. Without it, agents add features that seem logical but were never requested. |
| 7 | **Test Plan** | How to verify each acceptance criterion. |

**The 3 most critical sections** (when time is short): Acceptance Criteria, I/O Contracts, Not Included.

### Finding 3: 5 Principles for AI Agent Specs

**Source:** [Addy Osmani — How to write a good spec for AI agents](https://addyo.substack.com/p/how-to-write-a-good-spec-for-ai-agents)

| # | Principle | Key Practice |
|---|-----------|-------------|
| 1 | Start high-level, let AI draft details | Begin with a concise goal statement, have the agent expand into a detailed spec. Use Plan Mode (read-only) before implementation. |
| 2 | Structure like a professional PRD | 6 areas: Commands, Testing, Project structure, Code style, Git workflow, Boundaries. "Never commit secrets" was the single most common helpful constraint. |
| 3 | Be specific about your stack | "React 18 with TypeScript, Vite, and Tailwind CSS" not "React project." Include versions. |
| 4 | Use a consistent format | Markdown headings or XML-like tags. AI models handle well-structured text better than free-form prose. |
| 5 | Keep specs alive | Specs should evolve with the code, not be discarded after implementation. |

**GitHub Spec Kit's 6 areas** (from analysis of 2,500+ agent config files):
1. Commands — full commands with flags (`npm test`, `pytest -v`)
2. Testing — framework, file locations, coverage expectations
3. Project structure — where source, tests, docs live
4. Code style — one real code snippet beats three paragraphs
5. Git workflow — branch naming, commit format, PR requirements
6. Boundaries — what the agent should never touch

### Finding 4: Specs as Source Code for Code

**Source:** [Practiceoverflow — Effective Spec-Driven Development](https://practiceoverflow.substack.com/p/effective-spec-driven-development)

**Key insight:** "The most important skill in AI-assisted engineering isn't prompting. It's specification."

**Big Tech patterns:**
- **Google:** Design docs written before coding. Most important section is "Alternatives Considered" — prevents re-debating rejected approaches.
- **Amazon:** PR/FAQ — write a press release and FAQ as if the feature already shipped. Ban PowerPoint (slides hide fuzzy thinking).
- **Stripe:** API review board reads 20-page design docs for every public API change. Stakeholder names with checkboxes.

**The bottleneck has shifted:** Code generation is effectively free. The constraint is now specifying what to write. AI tools hit 87.2% on single-function tasks but only 19.36% on multi-file work — the drop is context degradation, not model capability.

### Finding 5: Dual Audience — Humans and AI Agents

**Source:** [Kinde — The Anatomy of a Good Spec in the Age of AI](https://www.kinde.com/learn/ai-for-software-engineering/best-practice/the-anatomy-of-a-good-spec-in-the-age-of-ai/)

**Core principle:** "A good spec must now be clear and structured enough for both human engineers and AI development tools to understand and execute."

The spec is no longer just a guide — it's becoming a direct input for machine processes. The same document must serve:
- **Humans:** Clarity, trust, usability, narrative flow
- **AI agents:** Structure, semantics, machine readability, deterministic parsing

### Finding 6: Anti-Patterns

**Source:** [Level Up Coding — 7 rules for writing specs for AI](https://levelup.gitconnected.com/how-to-write-specs-for-ai-7-rules-and-a-checklist-for-better-code-a5af2b2c6205)

| Anti-Pattern | Why It Fails |
|-------------|--------------|
| Vague quality attributes ("intuitive", "responsive") | Not testable; agent guesses |
| Implementation hints in spec | Spec should say WHAT, not HOW |
| Single monolithic spec | Context window limits; decompose into focused specs |
| No edge cases | Agent fills gaps with statistically plausible but wrong behavior |
| No prohibitions | Agent adds "helpful" features that cause harm |

---

## Thread 2: OpenCode Skill Architecture

### Finding 7: The Skill() Tool — Orchestrator Only

**Source:** [OpenCode Docs — Agent Skills](https://opencode.ai/docs/skills/)

The `skill()` tool is an **orchestrator-level** mechanism. It loads SKILL.md content into the orchestrator's context. The flow:

1. OpenCode lists available skills in `<available_skills>` with `name` and `description`
2. Agent calls `skill({name: "..."})` to load the SKILL.md
3. SKILL.md content is injected into the agent's context
4. The agent reads the content and acts on it

**There is no "sub-skill" concept in opencode.** A skill is a directory with a SKILL.md file. That's it. The `skill()` tool loads one SKILL.md at a time. There is no hierarchical skill resolution, no sub-skill registry, no way to call `skill()` from within a sub-agent.

### Finding 8: SKILL.md Frontmatter — Only 4 Recognized Fields

**Source:** [OpenCode Docs — Agent Skills](https://opencode.ai/docs/skills/)

```
name (required)       — 1-64 chars, lowercase alphanumeric + hyphens
description (required) — 1-1024 chars
license (optional)
compatibility (optional)
metadata (optional)    — string-to-string map
```

**Unknown frontmatter fields are ignored.** The `name` must match the directory name containing SKILL.md.

### Finding 9: Semantic Matching Uses the `description` Field

**Source:** [DeepWiki — Semantic Skill Matching](https://deepwiki.com/joshuadavidthomas/opencode-agent-skills/5.1-semantic-skill-matching)

The opencode plugin uses **cosine similarity on vector embeddings** of the `description` field against the user's message:

- **Model:** `all-MiniLM-L6-v2` (384-dimension embeddings)
- **Threshold:** 0.35 minimum similarity
- **Top-K:** 5 maximum matches
- **Cache:** Disk-cached by SHA-256 content hash
- **Latency:** <50ms, no external API calls

**Implication for skill design:** The `description` field is the PRIMARY mechanism for dispatch matching. It must be written to maximize semantic similarity with the user's natural language intent. A description that says "Load via skill() when creating a spec" is less effective than one that embeds the actual trigger phrases users say: "create spec", "write specification", "draft requirements", "author spec document".

### Finding 10: Skill Card vs Task Card — Distinct Consumers

**Source:** [OpenCode Docs — Agents](https://opencode.ai/docs/agents/), [DeepWiki — Understanding Skills](https://deepwiki.com/joshuadavidthomas/opencode-agent-skills/3.1-understanding-skills)

The architecture has exactly two abstractions:

| Artifact | File | Consumer | Content | Mechanism |
|----------|------|----------|---------|-----------|
| **Skill Card** | `SKILL.md` | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, context specs) | Loaded via `skill()` |
| **Task Card** | `tasks/<name>.md` | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatched via `task()` |

**Sub-agents** are configured in `opencode.json` or `.opencode/agents/` — they are NOT skills. Sub-agents have their own model, temperature, permissions, and prompt. They are invoked via `task()`, not `skill()`.

**There is no mechanism for a skill to contain sub-skills.** The `skill()` tool loads exactly one SKILL.md. If a skill card references another skill by name (e.g., "dispatch to spec-creation-validation"), the orchestrator must call `skill({name: "spec-creation-validation"})` separately — this is a second `skill()` call, not a sub-skill relationship.

### Finding 11: Agent Skills Specification (Anthropic Compatible)

**Source:** [GitHub — agentskills/agentskills](https://github.com/agentskills/agentskills), [Nevo Systems — How to Write an AI Agent Skill](https://nevo.systems/blogs/nevo-journal/how-to-write-ai-agent-skill)

The Anthropic Agent Skills Specification v1.0 defines a skill as:
- A folder containing a `SKILL.md` file
- YAML frontmatter (metadata)
- Markdown template (instructions)
- Optional executable scripts
- Optional supporting files

**No mention of sub-skills, nested skills, or skill hierarchies.** The specification is flat by design — each skill is a self-contained, independently loadable unit.

---

## Synthesis: Implications for spec-creation Skill Redesign

### What the Research Says About Sub-Skills

**Sub-skills are not an opencode-supported concept.** The current spec-creation architecture with 5 sub-skills (`spec-creation-validation`, `spec-creation-decomposition`, `spec-creation-requirements`, `spec-creation-change-control`, `spec-creation-operating-protocol`) is a custom pattern that:
1. Requires the orchestrator to make 5+ separate `skill()` calls
2. Has no framework support for hierarchical resolution
3. Forces the orchestrator to sequence sub-skill dispatches manually
4. Creates confusion about whether to dispatch the skill card or the task card

**The correct pattern:** One skill card (`spec-creation/SKILL.md`) that dispatches directly to task cards (`spec-creation/tasks/create.md`, `spec-creation/tasks/revise.md`, etc.) via `task()`. No sub-skill indirection.

### What the Research Says About the `description` Field

The `description` field is the **sole mechanism for semantic dispatch matching**. It should:
- Embed the actual trigger phrases users say (not "Load via skill() when...")
- Use natural language that matches user intent
- Be specific enough for cosine similarity >0.35 threshold
- Avoid meta-instructions about when to load

### What the Research Says About Spec Format

The spec format should follow BDD + RFC 2119 patterns:
- **Purpose** — one paragraph
- **Requirements** — with SHALL/SHOULD/MAY keywords
- **Scenarios** — WHEN-THEN-AND blocks
- **Edge cases** — explicitly covered
- **Prohibitions** — what SHALL NOT happen
- **Not Included** — explicit scope boundary
- **I/O Contracts** — machine-readable schemas

---

## Thread 3: Semantic Dispatch Matching — The `description` Field as a Semantic Router

### Finding 12: The Agent Evaluates Its OWN Intent Against the Description

**Source:** [Medium — OpenCode.ai Agent Skills: A Conceptual Deep Dive](https://medium.com/@pbalves/part-1-opencode-ai-agent-skills-a-conceptual-deep-dive-f16a515d73e2)

**Critical insight:** "When you send a prompt, the agent evaluates your intent against the available skill descriptions — semantically, not literally. This means it doesn't look for exact keyword matches."

The matching is **agent-intent-based**, not user-utterance-based. The agent:
1. Receives the user's message
2. Determines what IT needs to do next (its own intent)
3. Evaluates that intent against skill descriptions using semantic similarity
4. Loads skills whose descriptions match the agent's intent

This means the `description` field should describe **what the agent needs to accomplish** — not what the user said. The user says "I need a spec for the login feature" — the agent's intent is "I need to create a specification document" — the skill description should match the agent's intent, not the user's literal words.

### Finding 13: The Description Is a Semantic Router, Not Documentation

**Source:** [relearn.ing — OpenCode Skills: The AI-Augmented Developer Toolkit](https://relearn.ing/projects/opencode-skills/)

**Critical insight:** "The description field in SKILL.md isn't documentation — it's a semantic router. OpenCode pattern-matches user intent against skill descriptions to decide which tool to activate. Writing a good description is writing a classifier. Vague descriptions cause false activations; overly specific ones cause missed opportunities."

**Implications for description writing:**
- The description is a **classifier boundary** — it determines when the skill activates
- Too vague → false activations (skill loads when not needed)
- Too specific → missed activations (skill doesn't load when needed)
- Must describe the **agent's task intent**, not the user's input text
- Must be written to maximize semantic similarity with the agent's internal state when the skill is needed

### Finding 14: Progressive Disclosure — Three-Level Architecture

**Source:** [AI @ Sulat.com — Writing OpenCode agent skills: a practical guide](https://ai.sulat.com/writing-opencode-agent-skills-a-practical-guide-with-examples-870ff24eec66)

Skills use a three-level architecture for token efficiency:

| Level | What's Loaded | Token Cost | When |
|-------|---------------|------------|------|
| **Level 1: Metadata** | `name` + `description` only | ~100 tokens per skill | At session start (all skills) |
| **Level 2: Instructions** | Full SKILL.md body | ~5,000 tokens max (recommended) | When agent decides skill is relevant |
| **Level 3: Resources** | Scripts, references, templates | Variable | When instructions reference them |

**Key insight:** "The description is the first thing the AI sees, and it determines whether your skill gets activated. Write it carefully."

The description must be self-contained — it's the ONLY thing the agent sees before deciding to load the full skill. If the description doesn't match the agent's intent, the skill never loads.

### Finding 15: Description Writing Best Practices

**Source:** [AI @ Sulat.com — Writing OpenCode agent skills](https://ai.sulat.com/writing-opencode-agent-skills-a-practical-guide-with-examples-870ff24eec66), [relearn.ing — OpenCode Skills](https://relearn.ing/projects/opencode-skills/)

| Practice | Why | Example |
|----------|-----|---------|
| Describe the agent's task, not the user's words | Agent evaluates its own intent against descriptions | "Create specification documents from requirements" not "when user says create spec" |
| Use action verbs for agent tasks | Semantic matching works on verb-noun pairs | "Generate, validate, revise, decompose" |
| Include the domain/context | Narrow the semantic space | "for AI agent behavior changes" or "for codebase modifications" |
| Be specific enough to avoid false activations | Vague descriptions cause false positives | "Create and validate specification documents with success criteria, evidence types, and traceability" not "Handle specs" |
| Don't include meta-instructions about loading | The agent decides when to load — don't tell it to | No "Load via skill() when..." — this is noise in the semantic vector |
| One clear intent per description | Multiple intents dilute the semantic signal | One skill = one core intent |

### Finding 16: The `skill()` Tool Is Orchestrator-Only — Sub-Agents Cannot Call It

**Source:** [OpenCode Docs — Agent Skills](https://opencode.ai/docs/skills/), [OpenCode Docs — Agents](https://opencode.ai/docs/agents/)

The `skill()` tool is available ONLY to the orchestrator (primary agent). Sub-agents dispatched via `task()` do NOT have access to the `skill()` tool. This means:

- A sub-agent cannot load a skill
- A sub-agent cannot call `skill({name: "..."})`
- A sub-agent cannot read a SKILL.md file
- A sub-agent can only read task cards (`tasks/<name>.md`) via file read tools

**This is why dispatching a skill card to a sub-agent is a category error (critical-rules-XXX).** The sub-agent receives SKILL.md content containing `task()` calls and `skill()` references it cannot execute.

### Finding 17: The `description` Field Must Describe Agent Intent, Not User Utterance

**Synthesis from all sources:**

| Approach | What It Matches | Effectiveness | Source |
|----------|----------------|---------------|--------|
| User utterance keywords | "create spec", "write spec" | Low — agent doesn't echo user words | Medium article |
| Agent intent (semantic) | "Create specification documents with success criteria" | High — matches agent's internal state | Medium, relearn.ing |
| Meta-instructions | "Load via skill() when..." | Noise — dilutes semantic vector | Multiple sources |
| Trigger phrases list | "User phrases: create, write, draft" | Low — keyword matching, not semantic | Multiple sources |

**The correct pattern:** Write the description as what the agent needs to DO, not what the user SAYS.

```
✅ CORRECT: "Create and validate specification documents with success criteria, evidence types, traceability, and analytical artifacts from requirements and problem statements."
❌ WRONG: "Load via skill() when the user says create spec, write spec, or draft spec. User phrases: create spec, write spec, draft spec."
```

---

## Gaps

1. No research found on how opencode handles skill-to-skill handoff (e.g., brainstorming → spec-creation). The official docs don't address cross-skill workflows.
2. No empirical data on optimal task file size or number of steps per task file for sub-agent context management.
3. The semantic matching threshold (0.35) and top-K (5) are hardcoded in the plugin — no research on whether these are optimal for this codebase's skill count.
4. No research on how the built-in opencode skill tool (not the plugin) performs semantic matching — the plugin's behavior may differ from the native implementation.

## Classification

- **Type**: Architecture + Standards research
- **Confidence**: 0.90
- **Verdict**: The current sub-skill architecture should be flattened into a single skill with direct task card dispatches. The spec format should adopt BDD + RFC 2119 patterns. The `description` field should be rewritten for semantic matching effectiveness.
- **Applicable to**: spec-creation skill redesign, all skill cards with sub-skill patterns, spec format templates

## Sources

- [How to write a good spec for AI agents — Addy Osmani](https://addyo.substack.com/p/how-to-write-a-good-spec-for-ai-agents)
- [Writing specs for AI coding agents — deliberate.codes](https://deliberate.codes/blog/2026/writing-specs-for-ai-coding-agents/)
- [AI Spec Template — Augment Code](https://www.augmentcode.com/guides/ai-spec-template)
- [The Anatomy of a Good Spec in the Age of AI — Kinde](https://www.kinde.com/learn/ai-for-software-engineering/best-practice/the-anatomy-of-a-good-spec-in-the-age-of-ai/)
- [Effective Spec-Driven Development — Practiceoverflow](https://practiceoverflow.substack.com/p/effective-spec-driven-development)
- [OpenCode Docs — Agent Skills](https://opencode.ai/docs/skills/)
- [OpenCode Docs — Agents](https://opencode.ai/docs/agents/)
- [DeepWiki — Understanding Skills (opencode-agent-skills)](https://deepwiki.com/joshuadavidthomas/opencode-agent-skills/3.1-understanding-skills)
- [DeepWiki — Semantic Skill Matching (opencode-agent-skills)](https://deepwiki.com/joshuadavidthomas/opencode-agent-skills/5.1-semantic-skill-matching)
- [GitHub — agentskills/agentskills (Anthropic Agent Skills Specification)](https://github.com/agentskills/agentskills)
- [How to Write an AI Agent Skill — Nevo Systems](https://nevo.systems/blogs/nevo-journal/how-to-write-ai-agent-skill)
- [AI Agent Specification Template — GSA-TTS](https://github.com/GSA-TTS/devCrew_s1/blob/master/docs/templates/AI%20Agent%20Specification%20Template.md)
- [How to write a software spec that AI agents can actually use — Colign](https://colign.co/blog/how-to-write-software-spec-template)
- [How to write specs for AI — 7 rules — Level Up Coding](https://levelup.gitconnected.com/how-to-write-specs-for-ai-7-rules-and-a-checklist-for-better-code-a5af2b2c6205)
- [How to Write Effective Specifications for AI Agents — Analytics Insight](https://www.analyticsinsight.net/artificial-intelligence/how-to-write-effective-specifications-for-ai-agents)
