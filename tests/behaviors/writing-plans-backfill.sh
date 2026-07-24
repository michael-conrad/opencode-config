#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Backfill Task Card
#
# Verifies that skills/writing-plans/tasks/backfill.md exists and
# blocks on missing spec (entry criteria requiring spec presence).
#
# RED phase: backfill.md does NOT exist yet.
# Expected to FAIL (non-zero exit).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

BACKFILL_MD=".opencode/skills/writing-plans/tasks/backfill.md"

echo "=== RED Test: writing-plans-backfill ==="
echo "Checking $BACKFILL_MD exists and blocks on missing spec..."
echo ""

EXISTS=false
BLOCKS_ON_MISSING=false

# Check 1: backfill.md must exist
if [ -f "$BACKFILL_MD" ]; then
    EXISTS=true
    echo "  [FOUND] $BACKFILL_MD exists"

    # Check 2: Must have entry criteria requiring spec presence
    if grep -qi 'spec.*required\|missing.*spec\|spec.*not.*found\|no.*spec\|spec.*must\|entry.*criterion.*spec' "$BACKFILL_MD" 2>/dev/null; then
        BLOCKS_ON_MISSING=true
        echo "  [FOUND] Entry criteria blocks on missing spec"
    else
        echo "  [MISSING] No spec-required entry criteria (expected RED)"
    fi
else
    echo "  [MISSING] $BACKFILL_MD does not exist (expected RED)"
fi

echo ""
if $EXISTS && $BLOCKS_ON_MISSING; then
    echo "UNEXPECTED PASS: backfill.md exists with spec-required entry criteria"
    exit 0
else
    echo "EXPECTED FAIL: backfill.md not found or missing spec-required entry criteria (RED phase confirmed)"
    exit 1
fi
