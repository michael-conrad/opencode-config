---
number: 101
title: "[SPEC-FIX] Restore git-workflow frontmatter triggers and submodule check-pr"
status: "open"
labels: [SPEC, approved-for-pr]
created: "2026-05-22T00:00:00Z"
updated: "2026-05-22T00:00:00Z"
author: "Test Fixture"
---

## Objective

Restore frontmatter `Triggers on:` declarations in git-workflow SKILL.md and add submodule-aware PR iteration to the `check-pr` task.

## Problem

1. The git-workflow SKILL.md frontmatter is missing `Triggers on:` declarations, causing the skill dispatch gate to fail
2. The `check-pr` task does not iterate submodule repos when checking PR status

## Scope

1. Add `Triggers on: branch, commit, push, PR, pull request, pre-work, review-prep, feature branch, dev branch, squash, conflict, merge conflict, rebase conflict, check pr, check prs, check merged prs, check merged pr, check pull request, check pull requests, release PR, release pr, promote to main, dev to main, release promotion, sync submodules, update submodules, submodule update` to git-workflow SKILL.md frontmatter
2. Add submodule repo iteration to `check-pr` task: when `github.platform` is `github`, iterate over `.gitmodules` entries and check PRs in each submodule repo

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-5 | git-workflow SKILL.md has `Triggers on:` frontmatter | `string` | grep for trigger patterns |
| SC-6 | check-pr task iterates submodule repos | `string` | grep for submodule iteration in check-pr task |
| SC-7 | Behavioral test confirms agent dispatches git-workflow for branch operations | `behavioral` | stderr assertion for skill dispatch |

## Authorization

This issue is approved for `for_pr` scope.