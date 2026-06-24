#!/usr/bin/env bash
# SC-10: Z3-verifiable contract fields for state transitions
# RED phase: verify the work state format lacks Z3 contract fields
# Expected: FAIL (contract fields not yet added)

set -euo pipefail
OVERALL_RESULT=0

WORK_STATE_FILE=".opencode/skills/implementation-pipeline/enforcement/work-state-verification.md"
STATE_MACHINE=".opencode/skills/implementation-pipeline/pipeline-state-machine.yaml"
ISSUE=1346
ARTIFACT_DIR="./tmp/${ISSUE}/artifacts"
mkdir -p "$ARTIFACT_DIR"
ARTIFACT_LOG="${ARTIFACT_DIR}/phase-3-test-sc10-output.log"

echo "=== SC-10: Z3-verifiable contract fields ===" | tee "$ARTIFACT_LOG"

# --- Check 1: Work state format includes current_step and pipeline_state ---
echo "--- Check 1: Work state format has current_step and pipeline_state ---" | tee -a "$ARTIFACT_LOG"
if grep -q "current_step:" "$WORK_STATE_FILE" 2>/dev/null; then
    echo "PASS: current_step found in work state format" | tee -a "$ARTIFACT_LOG"
else
    echo "FAIL: current_step NOT found in work state format" | tee -a "$ARTIFACT_LOG"
    OVERALL_RESULT=1
fi
if grep -q "pipeline_state:" "$WORK_STATE_FILE" 2>/dev/null; then
    echo "PASS: pipeline_state found in work state format" | tee -a "$ARTIFACT_LOG"
else
    echo "FAIL: pipeline_state NOT found in work state format" | tee -a "$ARTIFACT_LOG"
    OVERALL_RESULT=1
fi

# --- Check 2: Work state format declares Z3 types for contract fields ---
echo "--- Check 2: Work state format has Z3 type declarations for contract fields ---" | tee -a "$ARTIFACT_LOG"
# The work state format should declare Z3-compatible types (type, domain) for current_step and pipeline_state
# Currently it only has them as plain YAML fields without Z3 type declarations
Z3_TYPE_DECL=$(grep -c "type:" "$WORK_STATE_FILE" 2>/dev/null || true)
Z3_DOMAIN_DECL=$(grep -c "domain:" "$WORK_STATE_FILE" 2>/dev/null || true)
if [ "$Z3_TYPE_DECL" -ge 2 ] && [ "$Z3_DOMAIN_DECL" -ge 1 ]; then
    echo "PASS: Z3 type declarations found in work state format" | tee -a "$ARTIFACT_LOG"
else
    echo "FAIL: Z3 type declarations MISSING from work state format (types=$Z3_TYPE_DECL, domains=$Z3_DOMAIN_DECL)" | tee -a "$ARTIFACT_LOG"
    echo "  Expected: type and domain declarations for current_step and pipeline_state" | tee -a "$ARTIFACT_LOG"
    OVERALL_RESULT=1
fi

# --- Check 3: Work state format has contract_path field linking to state machine ---
echo "--- Check 3: Work state format has contract_path field ---" | tee -a "$ARTIFACT_LOG"
if grep -q "contract_path:" "$WORK_STATE_FILE" 2>/dev/null; then
    echo "PASS: contract_path found in work state format" | tee -a "$ARTIFACT_LOG"
else
    echo "FAIL: contract_path NOT found in work state format" | tee -a "$ARTIFACT_LOG"
    echo "  Expected: contract_path field pointing to pipeline-state-machine.yaml" | tee -a "$ARTIFACT_LOG"
    OVERALL_RESULT=1
fi

# --- Check 4: State transition rules documented in pipeline-state-machine.yaml ---
echo "--- Check 4: State transition rules documented ---" | tee -a "$ARTIFACT_LOG"
if [ -f "$STATE_MACHINE" ]; then
    echo "PASS: pipeline-state-machine.yaml exists" | tee -a "$ARTIFACT_LOG"
    TRANSITION_COUNT=$(grep -c "z3.Implies" "$STATE_MACHINE" 2>/dev/null || true)
    echo "  Found $TRANSITION_COUNT transition rules" | tee -a "$ARTIFACT_LOG"
else
    echo "FAIL: pipeline-state-machine.yaml NOT found" | tee -a "$ARTIFACT_LOG"
    OVERALL_RESULT=1
fi

# --- Check 5: Z3 can load the contract ---
echo "--- Check 5: Z3 can load the contract ---" | tee -a "$ARTIFACT_LOG"
if command -v .opencode/tools/solve &>/dev/null; then
    # Try to check the contract with Z3
    SOLVE_OUTPUT=$(.opencode/tools/solve check \
        --state-path /dev/null \
        --contract-path "$STATE_MACHINE" 2>&1 || true)
    echo "  solve output: $SOLVE_OUTPUT" | tee -a "$ARTIFACT_LOG"
    if echo "$SOLVE_OUTPUT" | grep -qi "error\|fail\|invalid\|not found"; then
        echo "FAIL: Z3 could not load the contract" | tee -a "$ARTIFACT_LOG"
        OVERALL_RESULT=1
    else
        echo "PASS: Z3 loaded the contract" | tee -a "$ARTIFACT_LOG"
    fi
else
    echo "WARN: solve tool not available, skipping Z3 load check" | tee -a "$ARTIFACT_LOG"
    # This is a soft fail - the tool might not be installed
fi

# --- Summary ---
echo "=== SC-10 RESULT ===" | tee -a "$ARTIFACT_LOG"
if [ "$OVERALL_RESULT" -ne 0 ]; then
    echo "STATUS: FAIL (RED) - Z3 contract fields not yet added to work state format" | tee -a "$ARTIFACT_LOG"
else
    echo "STATUS: PASS - Z3 contract fields already present" | tee -a "$ARTIFACT_LOG"
fi

exit $OVERALL_RESULT
