---
number: 100
title: "[SPEC] Consolidate multi-issue PR branch strategy to stacked-only"
status: "open"
labels: [SPEC, approved-for-pr]
created: "2026-05-22T00:00:00Z"
updated: "2026-05-22T00:00:00Z"
author: "Test Fixture"
---

## Objective

Remove the `individual` PR strategy from the codebase. All multi-issue PRs must use the `stacked` strategy — one feature branch, N commits, one PR.

## Problem

The `individual` PR strategy creates N branches for N issues under one authorization scope, producing review fragmentation, merge conflicts, and branch management overhead. The `stacked` strategy (one branch, N commits, one PR) eliminates all of these problems.

## Scope

1. Remove `individual` from PR strategy type definitions
2. Update approval-gate scope table to remove `individual` row
3. Add critical violation for creating N branches for N issues

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `individual` removed from PR strategy type | `string` | grep confirms no `individual` in pr_strategy type |
| SC-2 | Approval-gate scope table has no `individual` row | `string` | grep confirms `individual` not in scope table |
| SC-3 | Critical violation added for N-branch pattern | `string` | grep confirms `critical-rules-PR-ORG` in 000-critical-rules.md |
| SC-4 | Agent creates 1 feature branch (stacked), not N branches | `behavioral` | `stacked-pr-organization.sh` behavioral test PASS |

## Authorization

This issue is approved for `for_pr` scope.