#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Self-Review Task Card
#
# Verifies that skills/writing-plans/tasks/self-review.md detects missing
# steps, placeholder patterns, SC coverage gaps, and type/name inconsistencies
# in plans, and verifies every task follows every step from the Per-Task Cycle.
#
# RED phase: self-review.md does NOT exist yet.
# Expected to FAIL (non-zero exit).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SELF_REVIEW_MD=".opencode/skills/writing-plans/tasks/self-review.md"

echo "=== RED Test: writing-plans-self-review ==="
echo "Checking $SELF_REVIEW_MD for plan review capabilities..."
echo ""

EXISTS=false
DETECTS_MISSING_STEPS=false
DETECTS_PLACEHOLDERS=false
DETECTS_SC_GAPS=false
DETECTS_INCONSISTENCIES=false
VERIFIES_PER_TASK_CYCLE=false

# Check 1: self-review.md must exist
if [ -f "$SELF_REVIEW_MD" ]; then
    EXISTS=true
    echo "  [FOUND] $SELF_REVIEW_MD exists"
else
    echo "  [MISSING] $SELF_REVIEW_MD does not exist (expected RED)"
fi

# Check 2: Must detect missing steps in plans
if $EXISTS && grep -qi 'missing.*step\|step.*missing\|step.*gap\|incomplete.*step\|step.*absent\|step.*not.*found\|missing.*task' "$SELF_REVIEW_MD" 2>/dev/null; then
    DETECTS_MISSING_STEPS=true
    echo "  [FOUND] Missing step detection"
else
    echo "  [MISSING] Missing step detection (expected RED)"
fi

# Check 3: Must detect placeholder patterns
if $EXISTS && grep -qi 'placeholder\|TODO\|FIXME\|TBD\|to.*do\|to.*be.*determined\|not.*implemented\|stub' "$SELF_REVIEW_MD" 2>/dev/null; then
    DETECTS_PLACEHOLDERS=true
    echo "  [FOUND] Placeholder pattern detection"
else
    echo "  [MISSING] Placeholder pattern detection (expected RED)"
fi

# Check 4: Must detect SC coverage gaps
if $EXISTS && grep -qi 'SC.*coverage\|coverage.*gap\|SC.*gap\|success.*criterion.*missing\|SC.*missing\|SC.*not.*covered\|SC.*uncovered\|SC.*absent' "$SELF_REVIEW_MD" 2>/dev/null; then
    DETECTS_SC_GAPS=true
    echo "  [FOUND] SC coverage gap detection"
else
    echo "  [MISSING] SC coverage gap detection (expected RED)"
fi

# Check 5: Must detect type/name inconsistencies
if $EXISTS && grep -qi 'type.*inconsist\|name.*inconsist\|inconsist.*type\|inconsist.*name\|mismatch\|type.*mismatch\|name.*mismatch\|inconsistent.*naming' "$SELF_REVIEW_MD" 2>/dev/null; then
    DETECTS_INCONSISTENCIES=true
    echo "  [FOUND] Type/name inconsistency detection"
else
    echo "  [MISSING] Type/name inconsistency detection (expected RED)"
fi

# Check 6: Must verify every task follows every step from Per-Task Cycle
if $EXISTS && grep -qi 'per-task.*cycle\|task.*cycle\|every.*step\|each.*step\|full.*cycle\|cycle.*step\|step.*enumeration\|all.*steps.*present\|verify.*cycle' "$SELF_REVIEW_MD" 2>/dev/null; then
    VERIFIES_PER_TASK_CYCLE=true
    echo "  [FOUND] Per-task cycle verification"
else
    echo "  [MISSING] Per-task cycle verification (expected RED)"
fi

echo ""
if $EXISTS && $DETECTS_MISSING_STEPS && $DETECTS_PLACEHOLDERS && $DETECTS_SC_GAPS && $DETECTS_INCONSISTENCIES && $VERIFIES_PER_TASK_CYCLE; then
    echo "UNEXPECTED PASS: self-review.md already has all required plan review capabilities"
    exit 0
else
    echo "EXPECTED FAIL: self-review.md missing required capabilities (RED phase confirmed)"
    echo "  EXISTS=$EXISTS MISSING_STEPS=$DETECTS_MISSING_STEPS PLACEHOLDERS=$DETECTS_PLACEHOLDERS"
    echo "  SC_GAPS=$DETECTS_SC_GAPS INCONSISTENCIES=$DETECTS_INCONSISTENCIES PER_TASK_CYCLE=$VERIFIES_PER_TASK_CYCLE"
    exit 1
fi
