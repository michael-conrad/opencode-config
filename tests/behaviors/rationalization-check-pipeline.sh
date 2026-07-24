#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# GREEN phase test: rationalization-check-pipeline
# Verifies that implementation-pipeline SKILL.md has the rationalization-check TDT entry

set -euo pipefail

echo "=== GREEN Test: rationalization-check-pipeline ==="
echo "Checking implementation-pipeline SKILL.md for rationalization-check TDT entry..."

SKILL_MD=".opencode/skills/implementation-pipeline/SKILL.md"
ALL_PASS=true

if [ ! -f "$SKILL_MD" ]; then
    echo "  [MISSING] $SKILL_MD does not exist"
    ALL_PASS=false
else
    if grep -q "rationalization.check\|REMEDIATION_MANDATORY" "$SKILL_MD" 2>/dev/null; then
        echo "  [FOUND] rationalization-check TDT entry present"
    else
        echo "  [MISSING] rationalization-check TDT entry"
        ALL_PASS=false
    fi

    if grep -q "rationalization-check" "$SKILL_MD" 2>/dev/null; then
        echo "  [FOUND] rationalization-check in step labels"
    else
        echo "  [MISSING] rationalization-check in step labels"
        ALL_PASS=false
    fi
fi

echo ""
if [ "$ALL_PASS" = true ]; then
    echo "PASS: rationalization-check-pipeline"
    exit 0
else
    echo "FAIL: rationalization-check-pipeline"
    exit 1
fi
