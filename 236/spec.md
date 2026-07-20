## Summary

The symbolic rule condition `"verification_sub_agent_dispatched_with_file_list == true"` in `critical-rules-044` is overbroad. It treats verification sub-agents (which need file lists as operational context to do their job) the same as execution sub-agents (where preloading file paths is harmful). This would incorrectly HALT legitimate VbC dispatch.

## Root Cause

`critical-rules-044` was designed to prevent preloading *execution* sub-agent context with pre-determined outcomes. However, the symbolic rule conditions array includes `verification_sub_agent_dispatched_with_file_list == true`, which catches legitimate verification dispatches where the orchestrator correctly passes a file list as operational context (not as a pre-determined outcome).

The prose section of critical-rules-044 already correctly scopes to "execution" sub-agents — only the symbolic condition needs removal.

## Fix Required

Remove the `verification_sub_agent_dispatched_with_file_list == true` condition from critical-rules-044's symbolic rule conditions array in `.opencode/guidelines/000-critical-rules.md`.

The remaining conditions (`sub_agent_dispatched_with_file_paths`, `sub_agent_dispatched_with_line_numbers`, `sub_agent_dispatched_with_expected_outcomes`, `sub_agent_dispatched_with_orchestrator_reasoning`) are the correct scope — they target execution sub-agents where preloading is harmful.