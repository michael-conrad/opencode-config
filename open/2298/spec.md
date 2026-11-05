---
remote_issue: 2298
remote_url: https://github.com/michael-conrad/.opencode/issues/2298
---

# [SPEC] TDD RED/GREEN Abort Protocol for Irregular Test Conditions

## Intent and Executive Summary

- **Problem Statement:** The TDD RED and GREEN task cards (`red.md` and `green.md`) define exactly one valid terminal state each: RED must produce a confirmed-failing test, GREEN must produce a passing implementation. When a sub-agent detects an irregular condition that makes that terminal state unreachable or invalid — a red test that is already green, a test based on a false premise, a test not relevant to the code path, a red/green conflict, a green test with no purpose, or scope creep / un-spec'ed feature removal — the sub-agent has no defined exit. It loops between the mandate and reality, never reaching a terminal state and never reporting.
- **Root Cause / Motivation:** Neither task card defines a classified-abort terminal state. The `red.md` card has a "RED != FALSE Clause" distinguishing non-execution (FALSE) from an executed failing test (RED), but no path for the sub-agent that cannot validly produce a failing test. Without a defined exit, the sub-agent is structurally forced to either loop, force an invalid outcome, or silently fail — each of which is a defect vector.
- **Approach Chosen:** Add a second valid terminal state to each of the two TDD task cards: a classified ABORT returned as `status: BLOCKED` with a `blocker_reason` classification. Each card enumerates its own classification set and its own post-abort orchestrator routing guidance, kept self-contained per card. On abort, the orchestrator dispatches a cold-reading re-evaluation sub-agent that routes to `spec-creation --task revise` / `writing-plans --task revise` to adjust the SCs so RED/GREEN do not retrigger the abort. A behavioral enforcement test (ALREADY_GREEN case) verifies the sub-agent returns a classified abort instead of looping.

## Not Included

- Phase 0 / Phase 4 BLOCKED-on-failure protocols.
- Shared abort protocol in `operating-protocol.md` — explicitly forbidden; the protocol must be self-contained per task card.
- SKILL.md routing changes (Trigger Dispatch Table).
- Behavioral test harness infrastructure (`helpers.sh`, `default-model.sh`, artifact-only generator paradigm).
- Default test model changes.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `red.md` defines a second valid terminal state: a classified ABORT returned as `status: BLOCKED` with a `blocker_reason` classification. | string + behavioral | `grep` for abort terminal state in red.md; behavioral ALREADY_GREEN scenario via `opencode run` |
| SC-2 | `green.md` defines a second valid terminal state: a classified ABORT returned as `status: BLOCKED` with a `blocker_reason` classification. | string + behavioral | `grep` for abort terminal state in green.md; behavioral NO_PURPOSE scenario via `opencode run` |
| SC-3 | RED abort protocol enumerates classifications ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT. | string | `grep` red.md for the four classification identifiers |
| SC-4 | GREEN abort protocol enumerates classifications NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, BAD_TEST_NEEDS_REVISION. | string | `grep` green.md for the five classification identifiers |
| SC-5 | Abort is defined as task completion: the sub-agent must not force the outcome, must not modify a test to make it fail, and must not loop. | string + behavioral | `grep` for abort-is-completion normative language in both cards; behavioral scenario asserts classified abort returned, not a forced/looping test |
| SC-6 | Orchestrator abort handling routes to a cold-reading re-evaluation sub-agent that identifies the defect and routes to `spec-creation --task revise` / `writing-plans --task revise`. | string + semantic | `grep` for post-abort routing guidance in both cards; clean-room sub-agent evaluation of routing behavior |
| SC-7 | Re-evaluation sub-agent autonomously classifies the adjustment as substantive (revokes plan approval, requires re-auth) or non-substantive (auto-revise, no re-auth). | string + semantic | `grep` for substantive/non-substantive classification guidance; clean-room sub-agent evaluation |
| SC-8 | Retrigger ladder: after 2 aborts with the same classification, dispatch a re-decomposition/rework evaluation sub-agent; escalate to spec-audit only if re-decomposition is NOT the fix. | string + semantic | `grep` for retrigger ladder guidance in both cards; clean-room sub-agent evaluation |
| SC-9 | Abort protocol is self-contained in each task card (red.md and green.md), customized to that card's role — not shared in `operating-protocol.md`. | string | `grep` for abort protocol in red.md and green.md; `grep` negative check that operating-protocol.md does not contain the abort protocol |
| SC-10 | A behavioral enforcement test verifies the sub-agent returns a classified abort (ALREADY_GREEN case) instead of looping. | behavioral | `bash .opencode/tests-v2/behaviors/<scenario>.sh` with clean-room session.yaml evaluation |
| SC-11 | GREEN abort protocol defines a `BAD_TEST_NEEDS_REVISION` classification: when the test being implemented against is defective and needs revision, the GREEN sub-agent SHALL abort via immediate `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION` (shuffling the test back to RED for revision) rather than implementing against the defective test. | string + behavioral | `grep` green.md for the BAD_TEST_NEEDS_REVISION classification and shuffle-to-RED routing; behavioral BAD_TEST_NEEDS_REVISION scenario via `opencode run` asserting the classified BLOCK abort, not implementation against a defective test |

## Requirements

- R-1. `red.md` SHALL define a classified ABORT terminal state returned as `status: BLOCKED` with a `blocker_reason` classification.
- R-3. The RED abort protocol SHALL enumerate the classifications ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, and CONFLICT.
- R-5. Both task cards SHALL state that returning a classified abort IS completing the task correctly, and SHALL prohibit forcing the outcome, modifying a test to make it fail, and looping.
- R-10. The change SHALL ship a behavioral enforcement test verifying the sub-agent returns a classified abort (ALREADY_GREEN case) instead of looping.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
