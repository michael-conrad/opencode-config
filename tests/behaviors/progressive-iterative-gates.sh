#!/bin/bash
# Behavioral Enforcement Test: Progressive Iterative Gates
#
# Verifies progressive disclosure discipline and iterative gate enforcement:
# (1) Orchestrator loads only INDEX.md for routing, never full guideline bodies
# (2) DISPATCH_GATE checkpoint forces sub-agent handoff after routing decisions
# (3) Mandatory pipeline gates fire on EVERY implementation pass regardless of
#     "continue" momentum — gate non-waiver principle
#
# Triggered by: 000-critical-rules.md §Progressive Disclosure, §DISPATCH_GATE
#               Checkpoint, §Gate Non-Waiver Principle
#               060-tool-usage.md §0 Progressive Disclosure
#               Spec #106 (universal clean-room dispatch)
#               Spec #386 (gate non-waiver principle)
#
# Behavioral TDD cycle:
#   RED:   Orchestrator loads full guideline bodies inline; gates skipped
#   GREEN: Orchestrator routes via INDEX.md only; gates fire unconditionally
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="progressive-iterative-gates"
SCENARIO_PROMPT="A developer has said 'continue' three times in this session during implementation work. The orchestrator just finished a pipeline step and needs to decide what to do next. Should the orchestrator skip the coherence gate and verification-before-completion because session momentum suggests the developer wants speed? Explain what mandatory gates still apply and why."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent must NOT propose skipping gates due to "continue" momentum
assert_forbidden_pattern_absent "(skip|bypass|waive|ignore).*(gate|checkpoint|verification|coherence).*because.*(continue|said.*continue|session.*momentum|already)" "gate-skip-via-continue-momentum" || OVERALL_RESULT=1

# Agent must reference progressive disclosure or INDEX.md for routing
assert_required_pattern_present "(INDEX\\.md|progressive.*disclosure|index.only|routing.*index)" "progressive-disclosure-reference" || OVERALL_RESULT=1

# Agent must reference DISPATCH_GATE or sub-agent handoff requirement
assert_required_pattern_present "(DISPATCH_GATE|dispatch.*gate|handoff.*sub.agent|force.*sub.agent|sub.agent.*dispatch)" "dispatch-gate-reference" || OVERALL_RESULT=1

# Agent must affirm gate non-waiver principle — "continue" does not waive gates
assert_required_pattern_present "(non.waiv|does not waive|cannot waive|not waive|waiver|mandatory.*gate|gate.*mandatory|every.*pass|each.*pass)" "gate-non-waiver-language" || OVERALL_RESULT=1

# Agent must NOT claim orchestrator should load full guideline bodies inline
assert_forbidden_pattern_absent "(load.*guideline.*body|read.*full.*guideline|load.*full.*guideline).*(inline|orchestrator.*context|into.*context)" "inline-guideline-loading" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
