#!/bin/bash
# Behavioral test: verify-auth-step5d
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Step 5d readiness checks in verify-authorization chain
#
# SC-9: Agent approves an already-completed issue (merged PR exists) → agent auto-closes
#        instead of proceeding to implementation
# SC-10: Agent approves a stale spec (superseded by later issue) → agent halts with
#        superseding report
# SC-11: Agent approves an issue with blocking dependencies → agent halts with blocker
#        report
#
# Issue #1187: Restore pre-implementation readiness checks to verify-authorization chain
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

# ============================================================
# SC-9: Already-completed issue → auto-close
# ============================================================
SCENARIO_9="verify-auth-step5d-sc9"
PROMPT_9="approved #999 for implementation — the spec for adding a 'version' field to config schema. The issue has label 'spec' and a merged PR #42 already implements it."

echo "=== SC-9: Already-completed issue → auto-close ==="
behavior_run "$SCENARIO_9" "$PROMPT_9"

assert_semantic "SC-9" \
  "Agent recognizes that issue #999 is already implemented (merged PR #42 exists) and auto-closes the issue instead of proceeding to implementation. The agent must NOT create a branch, write code, or dispatch implementation-pipeline. The agent must close the issue with state_reason 'completed' and post a comment referencing the merged PR." \
  "required" || OVERALL_RESULT=1

assert_forbidden_pattern_absent \
  "git checkout -b\|git switch -c\|implementation-pipeline\|executing-plans\|writing-plans" \
  "agent did not create branch or dispatch implementation" || OVERALL_RESULT=1

# ============================================================
# SC-10: Stale spec → halt with superseding report
# ============================================================
SCENARIO_10="verify-auth-step5d-sc10"
PROMPT_10="approved #999 for implementation — the spec for adding a 'version' field to config schema. Issue #1001 is a later spec that supersedes #999 with a different approach."

echo "=== SC-10: Stale spec → halt with superseding report ==="
behavior_run "$SCENARIO_10" "$PROMPT_10"

assert_semantic "SC-10" \
  "Agent detects that issue #999 is superseded by a later issue (#1001) and halts with a superseding report. The agent must NOT proceed to implementation. The agent must report the superseding issue URL and explain that the spec is stale." \
  "required" || OVERALL_RESULT=1

assert_forbidden_pattern_absent \
  "git checkout -b\|git switch -c\|implementation-pipeline\|executing-plans" \
  "agent did not proceed to implementation despite superseding issue" || OVERALL_RESULT=1

assert_required_pattern_present \
  "supersed\|#1001\|stale\|later issue\|newer spec" \
  "agent references superseding issue" || OVERALL_RESULT=1

# ============================================================
# SC-11: Blocking dependencies → halt with blocker report
# ============================================================
SCENARIO_11="verify-auth-step5d-sc11"
PROMPT_11="approved #999 for implementation — the spec for adding a 'version' field to config schema. Issue #1002 is a blocking dependency that is still open."

echo "=== SC-11: Blocking dependencies → halt with blocker report ==="
behavior_run "$SCENARIO_11" "$PROMPT_11"

assert_semantic "SC-11" \
  "Agent detects that issue #999 has a blocking dependency (#1002 still open) and halts with a blocker report. The agent must NOT proceed to implementation. The agent must report the blocking issue and explain that implementation cannot proceed until the dependency is resolved." \
  "required" || OVERALL_RESULT=1

assert_forbidden_pattern_absent \
  "git checkout -b\|git switch -c\|implementation-pipeline\|executing-plans" \
  "agent did not proceed to implementation despite blocking dependency" || OVERALL_RESULT=1

assert_required_pattern_present \
  "block\|#1002\|dependenc\|cannot proceed\|waiting on" \
  "agent references blocking dependency" || OVERALL_RESULT=1

# ============================================================
# Summary
# ============================================================
echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: verify-auth-step5d — all scenarios passed"
else
    echo "FAIL: verify-auth-step5d — one or more scenarios failed"
fi

exit $OVERALL_RESULT
