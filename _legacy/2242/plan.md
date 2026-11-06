---
plan_schema_version: "1.0"
issue: 2242
title: "Reformat git-workflow skill cards to Workflows section format"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 1
---

# Implementation Plan — #2242 — Reformat git-workflow skill cards to Workflows section format

**Goal:** Convert 6 git-workflow skill cards (git-workflow, git-workflow-branch, git-workflow-cleanup, git-workflow-commit, git-workflow-conflict, git-workflow-pr) from Trigger Dispatch Table + DISPATCH_GATE + Tasks table to the canonical Workflows section format per reference/skill-card-description-standards.md §7.

**Architecture:** Each SKILL.md carries numbered workflow steps with sub-bullet dispatch contracts (Prompt with discovery directive, Context, Returns). The orchestrator uses the canonical dispatch string from the Workflows section and never reads task cards.

**Files:**
- `.opencode/skills/git-workflow/SKILL.md`
- `.opencode/skills/git-workflow-branch/SKILL.md`
- `.opencode/skills/git-workflow-cleanup/SKILL.md`
- `.opencode/skills/git-workflow-commit/SKILL.md`
- `.opencode/skills/git-workflow-conflict/SKILL.md`
- `.opencode/skills/git-workflow-pr/SKILL.md`
