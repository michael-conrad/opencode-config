#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Cleanup
#
# Verifies that old task files (retroactive.md, explore.md) are removed
# and exactly 18 contract templates exist in contracts/.
#
# RED phase: retroactive.md still exists, contracts incomplete.
# Expected to FAIL (non-zero exit).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

TASKS_DIR=".opencode/skills/writing-plans/tasks"
CONTRACTS_DIR=".opencode/skills/writing-plans/contracts"

echo "=== RED Test: writing-plans-cleanup ==="
echo "Checking old files removed and 18 contract templates exist..."
echo ""

OLD_FILES_REMOVED=true
CONTRACT_COUNT_OK=true

# Check 1: retroactive.md must NOT exist
if [ -f "$TASKS_DIR/retroactive.md" ]; then
    OLD_FILES_REMOVED=false
    echo "  [STILL EXISTS] $TASKS_DIR/retroactive.md (expected REMOVED)"
else
    echo "  [REMOVED] $TASKS_DIR/retroactive.md"
fi

# Check 2: explore.md must NOT exist
if [ -f "$TASKS_DIR/explore.md" ]; then
    OLD_FILES_REMOVED=false
    echo "  [STILL EXISTS] $TASKS_DIR/explore.md (expected REMOVED)"
else
    echo "  [REMOVED] $TASKS_DIR/explore.md"
fi

# Check 3: Exactly 18 contract templates must exist
CONTRACT_COUNT=0
if [ -d "$CONTRACTS_DIR" ]; then
    CONTRACT_COUNT=$(ls -1 "$CONTRACTS_DIR"/*.yaml 2>/dev/null | wc -l)
fi
echo "  Contract templates found: $CONTRACT_COUNT (expected 18)"
if [ "$CONTRACT_COUNT" -ne 18 ]; then
    CONTRACT_COUNT_OK=false
fi

echo ""
if $OLD_FILES_REMOVED && $CONTRACT_COUNT_OK; then
    echo "UNEXPECTED PASS: All old files removed and 18 contract templates exist"
    exit 0
else
    echo "EXPECTED FAIL: Old files still exist or contract count != 18 (RED phase confirmed)"
    exit 1
fi
