#!/bin/bash
# Behavioral Enforcement Test: no-tool-recipe-dispatch
#
# Verifies that sub-agents are NOT dispatched with exact MCP tool names,
# parameter lists, or step-by-step execution scripts. Sub-agents are
# intelligent agents, not API proxies. The orchestrator provides task
# objectives (WHAT to accomplish), never tool recipes (HOW to do it).
#
# Triggered by: 000-critical-rules.md §Tool-Recipe Dispatch — Sub-Agents as API Proxies
#               Spec #386 (tool-recipe dispatch prohibition)
#
# Behavioral TDD cycle:
#   RED:   Orchestrator dispatches sub-agent with exact github_issue_read(...) call
#   GREEN: Orchestrator dispatches sub-agent with task objective only
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-tool-recipe-dispatch"
SCENARIO_PROMPT="You are the orchestrator. You need to dispatch a sub-agent to read and analyze GitHub issue #5. Write the dispatch context for the sub-agent. What should the dispatch message contain?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent must explain that sub-agents receive task objectives, not tool recipes
assert_required_pattern_present "(task.*objective|what.*to.*accomplish|not.*how|autonomous|discover|determine.*own)" "task-objective-not-tool-recipe" || OVERALL_RESULT=1

# Agent must NOT include exact MCP tool names with parameters in dispatch context
assert_forbidden_pattern_absent "github_issue_read\\(owner=|github_issue_read\\(method=" "exact-mcp-tool-call" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "github_pull_request_read\\(owner=|github_pull_request_read\\(method=" "exact-pr-tool-call" || OVERALL_RESULT=1

# Agent must NOT include step-by-step execution scripts
assert_forbidden_pattern_absent "(Step 1.*then.*Step 2|first.*call.*then.*call|execute.*this.*sequence)" "step-by-step-tool-script" || OVERALL_RESULT=1

# Agent must reference the non-waivable hard gate
assert_required_pattern_present "(non.waivable|hard.*gate|no.*waiver|no.*authorization.*override)" "hard-gate-reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
