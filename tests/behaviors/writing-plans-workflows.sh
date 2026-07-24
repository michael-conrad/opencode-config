#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Workflows
#
# Verifies the writing-plans SKILL.md has 3 self-contained workflow tables
# (Create, Revise, Retroactive) with no cross-references between them.
#
# RED phase: SKILL.md currently has prose workflows, not tables.
# Expected to FAIL (non-zero exit).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SKILL_MD=".opencode/skills/writing-plans/SKILL.md"

echo "=== RED Test: writing-plans-workflows ==="
echo "Checking $SKILL_MD for 3 self-contained workflow tables..."
echo ""

HAS_CREATE=false
HAS_REVISE=false
HAS_RETROACTIVE=false
HAS_CROSS_REF=false

# Check 1: SKILL.md must have a markdown table row containing "Create"
if grep -q '|.*Create.*|' "$SKILL_MD" 2>/dev/null; then
    HAS_CREATE=true
    echo "  [FOUND] Create workflow table row"
else
    echo "  [MISSING] Create workflow table row (expected RED)"
fi

# Check 2: Must have a table row containing "Revise"
if grep -q '|.*Revise.*|' "$SKILL_MD" 2>/dev/null; then
    HAS_REVISE=true
    echo "  [FOUND] Revise workflow table row"
else
    echo "  [MISSING] Revise workflow table row (expected RED)"
fi

# Check 3: Must have a table row containing "Retroactive"
if grep -q '|.*Retroactive.*|' "$SKILL_MD" 2>/dev/null; then
    HAS_RETROACTIVE=true
    echo "  [FOUND] Retroactive workflow table row"
else
    echo "  [MISSING] Retroactive workflow table row (expected RED)"
fi

# Check 4: Tables must be self-contained (no cross-references)
if grep -qi 'same as\|see.*workflow\|as step\|as above\|see above' "$SKILL_MD" 2>/dev/null; then
    HAS_CROSS_REF=true
    echo "  [FOUND] Cross-references between workflows (expected RED)"
else
    echo "  [CLEAN] No cross-references between workflows"
fi

echo ""
if $HAS_CREATE && $HAS_REVISE && $HAS_RETROACTIVE && ! $HAS_CROSS_REF; then
    echo "UNEXPECTED PASS: All 3 workflow tables already exist with no cross-references"
    exit 0
else
    echo "EXPECTED FAIL: SKILL.md missing workflow tables (RED phase confirmed)"
    exit 1
fi
