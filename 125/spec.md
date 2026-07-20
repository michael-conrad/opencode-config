# [SPEC] LaTeX Paper: Bright-Line Rules for AI Agent Instruction Compliance

- **Status:** DRAFT
- **Branch Pattern:** `feature/808-bright-line-paper`
- **Authorization Scope:** `for_pr`
- **PR Strategy:** individual

## Problem

Three specs define and implement a set of techniques for improving AI agent instruction compliance — bright-line rules as companions to dark prose rhetorical patterns. This work is currently scattered across issue bodies and will be implemented across skill files and guidelines. There is no single authoritative document that:

1. Establishes the theoretical foundation for why bright-line rules work
2. Documents the research basis (MAST taxonomy, anti-rationalization tables, Valid8it, addyosmani/agent-skills)
3. Defines the three-part structure (absolute rule + exception carve-out + failure definition)
4. Documents the complementary pairing of dark prose patterns (001-006) with bright-line companions
5. Presents the cost model override framework (rework cost >> execution cost)

This should be written as a proper LaTeX paper suitable for archival or conference submission.

## Scope

A single LaTeX source document at `docs/paper/bright-line-rules.tex` (or similar path) plus any required assets (bibliography, figures). The paper should be self-contained, cite the relevant research, and serve as the canonical reference for the technique.

The paper MUST cover:

| Section | Content |
|---------|---------|
| Abstract | The problem of agent rationalization and the bright-line solution |
| Introduction | Background on LLM agent cost-optimization bias and the MAST failure taxonomy (41.8% specification, 21.3% verification, 6.2% premature termination) |
| Related Work | Anti-rationalization tables, Valid8it gates, addyosanti/agent-skills, Anthropic evals, PwC multi-agent accuracy gains |
| Dark Prose Patterns | Existing 001-006 patterns (confirmshaming, identity-frame, consequence-assertion, agency-respecting) — what they are, what they achieve rhetorically |
| The Bright-Line Gap | Why dark prose alone is insufficient — rationalization surface, distributional convergence, the #1217 root cause |
| Bright-Line Rules (Pattern 007) | The three-part structure: absolute language + exception carve-out + failure definition |
| Complementary Pairings | How each vulnerable dark prose pattern (001, 002, 003, 006) gets a bright-line companion without replacement |
| Evidence Hierarchy | Behavioral > semantic > string > structural — why structural evidence for behavioral SCs is EVIDENCE_TYPE_MISMATCH |
| Cost Model Override | The correct cost calculus: rework cost >> execution cost, "trying to be cheap is expensive" |
| Implementation | How the technique manifests in default.txt (backstop), guidelines (always-in-context), and skills/tasks (on-demand) |
| Evaluation | Behavioral test methodology and results |
| Conclusion | Summary and future work |

## Verification (Academic Peer Review Pipeline)

The paper MUST pass through an AI agent peer review pipeline mirroring actual journal methodology. No structural/grep/string checks alone — the paper must be substantively evaluated by independent AI reviewers, an editor, and an auditor.

### Pipeline

```
Paper Draft
    ↓
[Editor] Desk reject or send to review
    ↓
[Reviewer 1 (adversarial auditor, different model family)]
[Reviewer 2 (adversarial auditor, different model family)]
    ↓  independent, blinded reviews
[Editor] Consolidate reviews → Accept / Minor Revisions / Major Revisions / Reject
    ↓ if revisions
Author revises
    ↓
[Auditor] Verify all reviewer concerns addressed
    ↓
[Editor] Final decision
    ↓
Accepted → PDF published
```

### Stage 1 — Editor Desk Review

The editor AI agent checks:
- Does the paper fall within scope?
- Is the abstract clear?
- Is the structure coherent?
- Are there obvious gaps?
- Decision: Desk reject (with reasons) OR send to review

**Tool:** `task(subagent_type="auditor-glm-5")` with editorial rubric

### Stage 2 — Peer Review (Dual Independent)

Two reviewers from different model families (e.g., DeepSeek V4 Flash + GLM 5, or Qwen 3.5 + Mistral Large 3), each in clean-room isolation:

Each reviewer evaluates:
1. **Originality** — is the technique novel?
2. **Clarity** — is the paper well-written and understandable?
3. **Methodology** — is the evaluation methodology sound?
4. **Related work** — are prior works properly cited and positioned?
5. **Reproducibility** — can the results be reproduced?
6. **Significance** — does this advance the field?

Each produces: structured review with scores (1-5 per criterion) + summary + recommended decision

**Tool:** `task(subagent_type="auditor-deepseek-flash")` and `task(subagent_type="auditor-mistral-large")` — blinded, no shared context.

### Stage 3 — Editor Decision

The editor AI agent consolidates both reviews and issues:
- **Accept:** No further changes needed
- **Minor Revisions:** Changes required but scope is clear and limited
- **Major Revisions:** Substantial rewriting needed; re-review after
- **Reject:** Paper does not meet bar (with specific reasoning)

### Stage 4 — Revision (if required)

Author (the main agent) revises the paper per reviewer concerns, producing a point-by-point response letter.

### Stage 5 — Audit

An auditor AI agent from a third model family verifies that ALL reviewer concerns have been addressed in the revision. Produces:
- Per-concern status: addressed / partially addressed / not addressed
- Overall finding: pass / conditional pass / fail

### Stage 6 — Editor Final Decision

After auditor pass, editor issues final acceptance. Paper proceeds to PDF publication.

## Success Criteria

### SC-1: LaTeX source file exists at documented path

| | |
|---|---|
| **Evidence Type** | structural |
| **Verification** | `ls docs/paper/bright-line-rules.tex` |

### SC-2: Paper compiles without errors

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | `xelatex` or `pdflatex` compilation produces PDF with zero errors |

### SC-3: Editor desk review completed with decision

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Editor agent produced a decision (send-to-review or desk-reject) with reasoning |

### SC-4: Two independent peer reviews completed

| | |
|---|---|
| **Evidence Type** | semantic + behavioral |
| **Verification** | Two review artifacts exist from different model families, each with scores across all 6 criteria, structured summary, and recommended decision |

### SC-5: Reviews are independent (no shared context)

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | Each reviewer was dispatched as a clean-room `task()` with ONLY the paper PDF; reviewer 2 did not receive reviewer 1's output |

### SC-6: Editor consolidated review and issued decision

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Editor agent produced a consolidated decision (accept / minor revisions / major revisions / reject) referencing both reviews |

### SC-7: If revisions required, point-by-point response produced

| | |
|---|---|
| **Evidence Type** | semantic |
| **Verification** | Response letter addresses each reviewer concern with: original concern → author response → change made |

### SC-8: Auditor verified all concerns addressed

| | |
|---|---|
| **Evidence Type** | behavioral |
| **Verification** | Auditor agent from third model family produced per-concern status table; overall finding is "pass" or "conditional pass" |

### SC-9: PDF committed alongside source

| | |
|---|---|
| **Evidence Type** | structural |
| **Verification** | `ls docs/paper/bright-line-rules.pdf` |

### SC-10: Byline present

| | |
|---|---|
| **Evidence Type** | string |
| **Verification** | grep for "Co-authored with AI" or equivalent in .tex or PDF metadata |

### SC-11: Full review trail committed

| | |
|---|---|
| **Evidence Type** | structural |
| **Verification** | Directory `docs/paper/reviews/` exists with all review artifacts, response letter, editor decisions |

## Key Considerations

- The paper should be write-once for each section then revised — not a long iterative process. Each section is a self-contained sub-agent task to produce an initial draft, then a coherence pass to ensure the sections form a unified whole.
- The paper is not a survey — it presents a specific technique with implementation in a real system. Structure it accordingly (not "related work" as a dump, but as positioning).
- The author should be listed as "Michael Conrad" with AI co-authorship attribution per `080-code-standards.md`.
- The review trail (raw reviews, editor decisions, response letter, auditor report) is committed to `docs/paper/reviews/` alongside the PDF for transparency.
- This paper is tracked in the main `opencode-config` repo (where `docs/` lives), not in `.opencode` submodule.

## Dependencies

- None. This is independent of the implementation phases but documents the same technique.

## Related

- https://github.com/michael-conrad/.opencode/issues/805 — Phase 1: Bright-Line Mandate (default.txt + dark prose card)
- https://github.com/michael-conrad/.opencode/issues/806 — Phase 2: Guideline Bright-Line Audit
- https://github.com/michael-conrad/.opencode/issues/807 — Phase 3: Skill/Task Bright-Line Re-Anchors