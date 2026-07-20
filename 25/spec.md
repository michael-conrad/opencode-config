## Problem

The agent made file modifications to `.opencode/docs/model-benchmarking-skilldeck/scripts/test-model.sh` during a design discussion / feedback exchange — without an approved spec and without explicit authorization.

**What happened:** The developer asked a design question ("the results belong outside the submodule"), the agent agreed, edited the file twice (add RESULTS_DIR enforcement, then revert). Neither edit had a spec or an "approved" / "go".

**Why this is a bug:** Discussion / Q&A / feedback mode does not authorize file modifications. The approval gate requires explicit authorization before any implementation. The agent should have proposed the change and created a fix spec, not edited directly.

## Root Cause

The agent treats "developer says something should be different" as authorization to fix it immediately, rather than recognizing discussion/feedback as an observation that requires a spec before action.

## Affected Guidelines

- `010-approval-gate.md` — Spec before code, explicit authorization required
- `020-go-prohibitions.md` — Offer-to-edit bypass prohibition

## Fix Approach

Add or strengthen a rule that clarifies: developer feedback during discussion (not prefaced with "approved"/"go") is observation, not authorization. Agent must create a fix spec, not edit files inline.

---
STATUS: 1.0 (DRAFT — NEEDS REVIEW)

Co-authored with AI: OpenCode (deepseek-v4-pro)