# [SPEC-FIX] Authorization Scope ≠ Implementation Trigger

## Root Cause

The agent conflates authorization scope (what it *may* do) with implementation trigger (what it *should* do *now*).

## Fix

Add to `010-approval-gate.md`:

> **Authorization scope defines what the agent MAY do, not what it MUST do now.**

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | 010-approval-gate.md contains Authorization Scope ≠ Implementation Trigger block | `string` |
| SC-2 | Behavioral test exists | `structural` |
