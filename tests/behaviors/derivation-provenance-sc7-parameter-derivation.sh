#!/bin/bash
# Behavioral test: derivation-provenance-sc7-parameter-derivation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Agent is given a Java class with a 5-parameter method and asked to
# create a similar class for a different domain. Agent MUST derive parameters
# from the new class's consumers, not copy from the reference class.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="derivation-provenance-sc7-parameter-derivation"
SCENARIO_PROMPT="Create a \`PaymentProcessor\` class similar to the existing \`OrderProcessor\` class. \`OrderProcessor\` has a 5-parameter constructor: \`(orderId, customerId, amount, currency, taxRate)\`. \`PaymentProcessor\` should handle credit card payments."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
