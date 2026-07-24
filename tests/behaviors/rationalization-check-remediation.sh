#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# GREEN phase test: rationalization-check-remediation
# Verifies that behavioral-test-remediation.md has the rationalization-check gate

set -euo pipefail

echo "=== GREEN Test: rationalization-check-remediation ==="
echo "Checking behavioral-test-remediation.md for rationalization-check gate..."

REMED_MD=".opencode/skills/implementation-pipeline/tasks/behavioral-test-remediation.md"
ALL_PASS=true

if [ ! -f "$REMED_MD" ]; then
    echo "  [MISSING] $REMED_MD does not exist"
    ALL_PASS=false
else
    if grep -q "rationalization.check\|REMEDIATION_MANDATORY" "$REMED_MD" 2>/dev/null; then
        echo "  [FOUND] rationalization-check gate present"
    else
        echo "  [MISSING] rationalization-check gate"
        ALL_PASS=false
    fi

    if grep -q "clean.room.*rationalization\|rationalization.check.*sub.agent" "$REMED_MD" 2>/dev/null; then
        echo "  [FOUND] clean-room sub-agent dispatch for rationalization check"
    else
        echo "  [MISSING] clean-room sub-agent dispatch for rationalization check"
        ALL_PASS=false
    fi

    if grep -q "REMEDIATION_MANDATORY" "$REMED_MD" 2>/dev/null; then
        echo "  [FOUND] REMEDIATION_MANDATORY verdict code"
    else
        echo "  [MISSING] REMEDIATION_MANDATORY verdict code"
        ALL_PASS=false
    fi
fi

echo ""
if [ "$ALL_PASS" = true ]; then
    echo "PASS: rationalization-check-remediation"
    exit 0
else
    echo "FAIL: rationalization-check-remediation"
    exit 1
fi
