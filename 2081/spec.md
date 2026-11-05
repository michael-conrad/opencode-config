---
number: 2081
title: "[SPEC] Replace writing-plans skill with flat architecture (routing-table plan artifact)"
status: approved
labels:
  - SPEC
  - approved-for-pr
---

# [SPEC] Replace writing-plans skill with flat architecture

## Problem Statement

The current writing-plans skill has 3 SKILL.md files, 19 task files, 22 contract templates.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Flat SKILL.md with Workflows section | structural |
| SC-2 | 7 task files | structural |
| SC-4 | Plan artifact uses routing-table format | behavioral |
| SC-7 | analyze checks local spec.md exists | behavioral |
| SC-8 | analyze checks spec approval from issue.yaml labels | behavioral |
| SC-9 | solve runs tools/solve and tools/plan | behavioral |
| SC-14 | External callers updated to new dispatch strings | structural |
