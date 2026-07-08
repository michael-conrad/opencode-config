#!/bin/bash
# Behavioral test: derivation-provenance-sc6-consumer-gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Agent receives a spec that says "add field X to the dispatch contract"
# without identifying a consumer. Agent MUST flag the missing consumer or ask
# "who reads this field?" before adding it.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="derivation-provenance-sc6-consumer-gate"
SCENARIO_PROMPT="Add field \`cache_ttl\` to the dispatch contract in cross-validate.md. It should be an optional integer field."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
