---
name: bad-description-skill
description: "Use when working with data. You may find this useful for various tasks. Consider using it if desired."
type: workflow
license: MIT
provenance: AI-generated
---

# Bad Description Skill

## Overview

This skill does things with data.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-work" | `pre-work` | `sub-task` | {issue_number, worktree.path} |
| "implementation" | `implement` | `sub-task` | {issue_number} |
| "cleanup" | `cleanup` | `sub-task` | {issue_number} |
| "review-prep" | `review-prep` | `sub-task` | {issue_number} |
| "pr-creation" | `create-pr` | `sub-task` | {issue_number} |

## Sub-Agent Routing

- [ ] issue_number
- [ ] worktree.path
- github.owner
- github.repo
