#!/bin/bash
# Behavioral test: derivation-provenance-sc8-routing-dead-weight
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Agent is given a routing table with a scope variable that no task file
# reads. Agent MUST flag the variable as dead weight.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="derivation-provenance-sc8-routing-dead-weight"
SCENARIO_PROMPT="Review the sub-agent routing scope in cross-validate.md. The scope includes \`audit_phase\` — is this field necessary?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
