#!/usr/bin/env bash
set -euo pipefail

# RED test for P1-I1 (SC-1, SC-3, SC-7)
# Asserts dispatch table pattern is ABSENT from plan-structure.md
# Expected: FAIL (pattern IS present before GREEN implementation)

TARGET_FILE=".opencode/skills/writing-plans/tasks/create/plan-structure.md"
PATTERN='| Gate | Dispatch Type | Blind?'

if grep -q "$PATTERN" "$TARGET_FILE"; then
  echo "FAIL: Dispatch table pattern found in $TARGET_FILE (expected absent)"
  echo "Match at line: $(grep -n "$PATTERN" "$TARGET_FILE")"
  exit 1
else
  echo "PASS: Dispatch table pattern absent from $TARGET_FILE"
  exit 0
fi
