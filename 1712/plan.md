---
spec: 1712
title: "[PLAN] #1712 — PR creation flow re-uses closed PRs instead of creating fresh ones"
status: DRAFT
created: 2026-07-07
---

## Plan

### Phase 1: Analysis

#### TDD-1: Verify enforcement-gate.md Step 1.5 behavior (SC-1, SC-2, SC-3)

**Scope:** Read `git-workflow/tasks/pr-creation/enforcement-gate.md` Step 1.5 to confirm it lacks `state=open` filter.

**Steps:**
1. Read enforcement-gate.md Step 1.5
2. Verify it queries GitHub without `state=open` filter
3. Verify it says "Check reason, proceed with caution" for closed PRs

**Exit:** Confirm the bug exists in the current code.

---

### Phase 2: Implementation

#### TDD-2: Add `state=open` filter to PR query (SC-1)

**Scope:** Modify enforcement-gate.md Step 1.5 to add `state=open` filter.

**Steps:**
1. Update enforcement-gate.md Step 1.5 to query with `state=open`
2. Add explicit rule: "If a closed (unmerged) PR exists on the branch, do NOT re-open it. Create a new PR."
3. Document that developer must explicitly say "use the closed PR" for it to be considered

**Exit:** enforcement-gate.md contains `state=open` filter and explicit "do not re-open" rule.

---

#### TDD-3: Add developer override logic (SC-3)

**Scope:** Implement logic to check for explicit "use the closed PR" instruction.

**Steps:**
1. Add check for "use the closed PR" phrase in user input
2. If phrase present, allow closed PR to be considered
3. If phrase absent, create fresh PR

**Exit:** Closed PR is only considered when explicitly instructed.

---

### Phase 3: Verification

#### TDD-4: Verify GitBucket workflow already correct (SC-4)

**Scope:** Confirm GitBucket workflow already uses `--state open` filter.

**Steps:**
1. Read `issue-operations/platforms/gitbucket-api/tasks/repository-operations.md`
2. Verify it uses `--state open` filter
3. Confirm no changes needed

**Exit:** SC-4 verified — GitBucket workflow already correct.

---

#### TDD-5: Verify open PR update behavior preserved (SC-5)

**Scope:** Confirm open PRs on branch still get updated (not replaced).

**Steps:**
1. Verify enforcement-gate.md Step 1.5 still handles open PRs correctly
2. Confirm "Open PR → Update existing PR" path preserved
3. Confirm "Closed PR → Create new PR" path added

**Exit:** SC-5 verified — open PRs still get updated.

---

## Sub-Issues

- [ ] #1714: TDD-1: Verify enforcement-gate.md Step 1.5 behavior
- [ ] #1715: TDD-2: Add `state=open` filter to PR query
- [ ] #1716: TDD-3: Add developer override logic
- [ ] #1717: TDD-4: Verify GitBucket workflow already correct
- [ ] #1718: TDD-5: Verify open PR update behavior preserved
