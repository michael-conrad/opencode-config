#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Behavioral test: explore-skill
# Verifies the explore skill dispatches correctly
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="explore-skill"
SCENARIO_PROMPT="Use the explore skill to investigate the codebase structure for issue #2084"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
