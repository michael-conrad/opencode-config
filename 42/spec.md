# [SPEC] Add dark mode toggle to settings page

## Problem
Users need a dark mode option for reduced eye strain.

## Scope
- Add dark mode toggle to settings page
- Persist preference across sessions

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Toggle exists on settings page | `string` | grep for toggle element |
| SC-2 | Preference persists across sessions | `behavioral` | opencode-cli run test |
