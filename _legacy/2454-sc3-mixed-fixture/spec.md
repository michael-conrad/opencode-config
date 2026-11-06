# Spec — Greeting utility (mixed dispatch-mode fixture)

Fixture spec for behavioral scenario `2454-sc3-dispatch-restriction-red` (issue .opencode#2454, SC-3).

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-3 | `task()` dispatch occurs ONLY at the plan step marked `(**task-card**)` (Step 2); steps marked `(**direct**)` (Steps 1 and 3) are executed by the orchestrator with its own tool calls and are NEVER dispatched | behavioral |

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*
