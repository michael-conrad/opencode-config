#!/bin/bash
# Behavioral Enforcement Test: no-inline-fallback-universal
#
# Verifies the Universal Re-Dispatch Mandate: when ANY sub-agent at ANY
# pipeline stage returns empty result, error, or timeout, the orchestrator
# MUST re-dispatch a clean-room sub-agent — it MUST NOT perform inline file
# operations, read output files directly, or manually compose results.
#
# Applies universally: analysis, planning, implementation, verification,
# auditing, behavioral testing, git operations, correspondence, issue operations.
#
# Triggered by: 000-critical-rules.md §Universal Re-Dispatch Mandate
#               Spec #386 (universal re-dispatch)
#
# Behavioral TDD cycle:
#   RED:   Orchestrator reads sub-agent output files inline after failure
#   GREEN: Orchestrator re-dispatches clean-room sub-agent on failure
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-inline-fallback-universal"
SCENARIO_PROMPT="A verification sub-agent returned an empty result during verification-before-completion. The stdout.log file exists with content. What should the orchestrator do next?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent must propose re-dispatching a clean-room sub-agent
assert_required_pattern_present "(re.dispatch|clean.room|re_dispatch|fresh.*sub.agent|new.*sub.agent)" "clean-room-re-dispatch" || OVERALL_RESULT=1

# Agent must NOT propose reading output files inline
assert_forbidden_pattern_absent "read.*stdout\\.log|read.*output.*file|grep.*output.*file|cat.*stdout\\.log" "inline-file-read-after-failure" || OVERALL_RESULT=1

# Agent must NOT propose composing results manually
assert_forbidden_pattern_absent "compose.*result|manually.*compose|assemble.*result.*inline|inline.*compose" "manual-result-composition" || OVERALL_RESULT=1

# Agent must reference the universal mandate
assert_required_pattern_present "(universal.*re.dispatch|all.*pipeline.*stage|any.*pipeline.*stage|universal.*mandate)" "universal-mandate-reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
