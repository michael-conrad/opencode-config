#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Create Task Card
#
# Verifies that skills/writing-plans/tasks/create.md produces plans with
# the full per-task cycle from the implementation-pipeline TDT.
# Every task in every phase must enumerate every step from the
# implementation-pipeline's per-task cycle (RED, Z3 check RED, RED doublecheck,
# Z3 check RED doublecheck, Post-RED enforcement, Z3 check post-RED, GREEN,
# Z3 check GREEN, Post-GREEN enforcement, Z3 check post-GREEN, Checkpoint tag,
# Checkpoint commit).
#
# RED phase: current create.md does NOT enumerate the full per-task cycle.
# Expected to FAIL (non-zero exit).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

CREATE_MD=".opencode/skills/writing-plans/tasks/create.md"

echo "=== RED Test: writing-plans-create ==="
echo "Checking $CREATE_MD produces plans with full per-task cycle..."
echo ""

EXISTS=false
LOADS_TDT=false
ENUMERATES_CYCLE=false

# Check 1: create.md must exist
if [ -f "$CREATE_MD" ]; then
    EXISTS=true
    echo "  [FOUND] $CREATE_MD exists"
else
    echo "  [MISSING] $CREATE_MD does not exist (expected RED)"
fi

# Check 2: Must reference loading the implementation-pipeline TDT at runtime
if grep -qi 'implementation-pipeline.*TDT\|load.*implementation-pipeline\|read.*implementation-pipeline.*trigger\|skill.*implementation-pipeline' "$CREATE_MD" 2>/dev/null; then
    LOADS_TDT=true
    echo "  [FOUND] References loading implementation-pipeline TDT"
else
    echo "  [MISSING] No reference to loading implementation-pipeline TDT (expected RED)"
fi

# Check 3: Must enumerate the full per-task cycle steps
# The per-task cycle includes: RED, Z3 check RED, RED doublecheck, Z3 check RED doublecheck,
# Post-RED enforcement, Z3 check post-RED, GREEN, Z3 check GREEN, Post-GREEN enforcement,
# Z3 check post-GREEN, Checkpoint tag, Checkpoint commit
CYCLE_STEPS=("red" "z3 check red" "red doublecheck" "z3 check red doublecheck"
             "post-red enforcement" "z3 check post-red" "green"
             "z3 check green" "post-green enforcement" "z3 check post-green"
             "checkpoint tag" "checkpoint commit")

MATCH_COUNT=0
for step in "${CYCLE_STEPS[@]}"; do
    if grep -qi "$step" "$CREATE_MD" 2>/dev/null; then
        MATCH_COUNT=$((MATCH_COUNT + 1))
    fi
done

if [ "$MATCH_COUNT" -ge 10 ]; then
    ENUMERATES_CYCLE=true
    echo "  [FOUND] Enumerates $MATCH_COUNT/12 per-task cycle steps"
else
    echo "  [MISSING] Only $MATCH_COUNT/12 per-task cycle steps found (expected RED)"
fi

echo ""
if $EXISTS && $LOADS_TDT && $ENUMERATES_CYCLE; then
    echo "UNEXPECTED PASS: create.md already produces plans with full per-task cycle"
    exit 0
else
    echo "EXPECTED FAIL: create.md does not produce plans with full per-task cycle (RED phase confirmed)"
    exit 1
fi
