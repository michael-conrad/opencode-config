# Spec: Workflow Philosophy Paper (LaTeX)

STATUS: draft
CREATED: 2026-06-27

---

## Problem Statement

.opencode#19 is a spec for `.opencode/WORKFLOW-PHILOSOPHY.md` — an operational philosophy document that no longer serves as the right artifact. The content has matured beyond a single markdown file into something suitable for formal publication as a LaTeX paper. This spec creates a new target: a complete, typeset LaTeX document covering the same material (agent workflow philosophy, tandem model, lifecycle, gating principles) but formatted for academic/technical presentation rather than operational reference.

## Context

.opencode#19 covers these content areas that form the basis of this paper:
- **The Tandem Model** — developer authority vs agent intelligence boundary
- **The Lifecycle** — idea to merge as narrative (exploration → spec → authorization → planning → implementation → verification → review → PR/merge directly to trunk)
- **Gating Philosophy** — why gates exist at every stage, not trust issues but volatile context management
- **Interdependencies** — how skills and guidelines connect across the full workflow
- **Prose-Driven Principle** — structure based on problem, not templates
- **Fresh-Start Contract** — self-contained artifacts because sessions start at zero
- **Where Rules Live** — AGENTS.md → guidelines → skills architecture

**Branching model context:** This project uses trunk-based development. Feature branches are short-lived and merge directly to `main` (the trunk). There is no separate `dev` branch and no dev→main release promotion. The lifecycle narrative and gating philosophy reflect this single-mainline workflow.

## Delivered Artifact

A complete LaTeX document (`.tex` file(s)) covering the workflow philosophy content from .opencode#19, formatted as a formal paper suitable for technical/academic presentation. The paper transforms the operational reference into scholarly prose while preserving all substantive concepts.

**Format**: LaTeX source — single `.tex` file with appropriate packages (article class or similar), proper sectioning, and typeset-ready structure. Not markdown. Not HTML.

## Success Criteria

- [ ] LaTeX document exists in opencode-config repo
- [ ] Covers the tandem model (developer/agent boundary) as substantive content
- [ ] Describes the full lifecycle from idea through merge, using trunk-based development as the normative model (feature branches merge directly to `main`, no dev→main promotion)
- [ ] Explains gating philosophy with rationale for each gate type, reflecting the TBD gate topology (no release promotion gates)
- [ ] Maps key interdependencies between skills, guidelines, and workflow stages
- [ ] Addresses prose-driven principle and fresh-start contract
- [ ] Compiles without errors (standard LaTeX toolchain)
- [ ] Content is substantive enough to stand as a standalone technical paper
- [ ] Does NOT duplicate operational rules from AGENTS.md — focuses on *why*, not *what*

## What This Is NOT

- NOT an operational reference manual
- NOT a replacement for `.opencode/AGENTS.md` or any existing skill files
- NOT a template for writing specs or plans
- NOT a policy document tied to implementation details that change frequently

---

**Cross-Ref:** Closes .opencode#19 (superseded), replaces markdown spec with LaTeX paper format.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)