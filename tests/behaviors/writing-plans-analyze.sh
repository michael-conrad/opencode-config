#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Analyze Task Card
#
# Verifies that skills/writing-plans/tasks/analyze.md has explicit entry
# criteria gates for SPEC_NOT_FOUND (missing spec) and SPEC_NOT_APPROVED
# (missing approval in frontmatter), matching the spec's requirement that
# these be Entry Criteria gates, not just Procedure steps.
#
# RED phase: analyze.md has SPEC_NOT_FOUND/SPEC_NOT_APPROVED in Procedure
# but NOT as explicit Entry Criteria gates. Expected to FAIL (non-zero exit).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

ANALYZE_MD=".opencode/skills/writing-plans/tasks/analyze.md"

echo "=== RED Test: writing-plans-analyze ==="
echo "Checking $ANALYZE_MD for entry criteria gates..."
echo ""

HAS_ENTRY_SPEC_NOT_FOUND=false
HAS_ENTRY_SPEC_NOT_APPROVED=false
HAS_PROCEDURE_SPEC_NOT_FOUND=false
HAS_PROCEDURE_SPEC_NOT_APPROVED=false

# Check 1: Entry Criteria must explicitly mention SPEC_NOT_FOUND
if grep -q 'SPEC_NOT_FOUND' "$ANALYZE_MD" 2>/dev/null; then
    # Check if SPEC_NOT_FOUND appears in Entry Criteria section
    if sed -n '/^## Entry Criteria/,/^## /p' "$ANALYZE_MD" | grep -q 'SPEC_NOT_FOUND' 2>/dev/null; then
        HAS_ENTRY_SPEC_NOT_FOUND=true
        echo "  [FOUND] SPEC_NOT_FOUND in Entry Criteria"
    else
        echo "  [MISSING] SPEC_NOT_FOUND in Entry Criteria (expected RED)"
    fi
else
    echo "  [MISSING] SPEC_NOT_FOUND not found anywhere (expected RED)"
fi

# Check 2: Entry Criteria must explicitly mention SPEC_NOT_APPROVED
if grep -q 'SPEC_NOT_APPROVED' "$ANALYZE_MD" 2>/dev/null; then
    # Check if SPEC_NOT_APPROVED appears in Entry Criteria section
    if sed -n '/^## Entry Criteria/,/^## /p' "$ANALYZE_MD" | grep -q 'SPEC_NOT_APPROVED' 2>/dev/null; then
        HAS_ENTRY_SPEC_NOT_APPROVED=true
        echo "  [FOUND] SPEC_NOT_APPROVED in Entry Criteria"
    else
        echo "  [MISSING] SPEC_NOT_APPROVED in Entry Criteria (expected RED)"
    fi
else
    echo "  [MISSING] SPEC_NOT_APPROVED not found anywhere (expected RED)"
fi

# Check 3: Procedure must have SPEC_NOT_FOUND (should already pass)
if grep -q 'SPEC_NOT_FOUND' "$ANALYZE_MD" 2>/dev/null; then
    HAS_PROCEDURE_SPEC_NOT_FOUND=true
    echo "  [FOUND] SPEC_NOT_FOUND in file"
fi

# Check 4: Procedure must have SPEC_NOT_APPROVED (should already pass)
if grep -q 'SPEC_NOT_APPROVED' "$ANALYZE_MD" 2>/dev/null; then
    HAS_PROCEDURE_SPEC_NOT_APPROVED=true
    echo "  [FOUND] SPEC_NOT_APPROVED in file"
fi

echo ""
if $HAS_ENTRY_SPEC_NOT_FOUND && $HAS_ENTRY_SPEC_NOT_APPROVED; then
    echo "UNEXPECTED PASS: analyze.md has both SPEC_NOT_FOUND and SPEC_NOT_APPROVED in Entry Criteria"
    exit 0
else
    echo "EXPECTED FAIL: analyze.md missing entry criteria gates (RED phase confirmed)"
    echo "  Procedure has SPEC_NOT_FOUND=$HAS_PROCEDURE_SPEC_NOT_FOUND, SPEC_NOT_APPROVED=$HAS_PROCEDURE_SPEC_NOT_APPROVED"
    echo "  But Entry Criteria needs explicit gates per spec §Task Cards → analyze.md"
    exit 1
fi
