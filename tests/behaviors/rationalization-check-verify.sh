#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# GREEN phase test: rationalization-check-verify
# Verifies that verify.md has the rationalization-check gate

set -euo pipefail

echo "=== GREEN Test: rationalization-check-verify ==="
echo "Checking verify.md for rationalization-check gate..."

VERIFY_MD=".opencode/skills/verification-before-completion/tasks/verify.md"

ALL_PASS=true

if [ ! -f "$VERIFY_MD" ]; then
    echo "  [MISSING] $VERIFY_MD does not exist"
    ALL_PASS=false
else
    if grep -q "rationalization.check\|REMEDIATION_MANDATORY" "$VERIFY_MD" 2>/dev/null; then
        echo "  [FOUND] rationalization-check gate present"
    else
        echo "  [MISSING] rationalization-check gate"
        ALL_PASS=false
    fi

    if grep -q "clean.room.*rationalization\|rationalization.check.*sub.agent" "$VERIFY_MD" 2>/dev/null; then
        echo "  [FOUND] clean-room sub-agent dispatch for rationalization check"
    else
        echo "  [MISSING] clean-room sub-agent dispatch for rationalization check"
        ALL_PASS=false
    fi

    if grep -q "REMEDIATION_MANDATORY" "$VERIFY_MD" 2>/dev/null; then
        echo "  [FOUND] REMEDIATION_MANDATORY verdict code"
    else
        echo "  [MISSING] REMEDIATION_MANDATORY verdict code"
        ALL_PASS=false
    fi
fi

echo ""
if [ "$ALL_PASS" = true ]; then
    echo "PASS: rationalization-check-verify"
    exit 0
else
    echo "FAIL: rationalization-check-verify"
    exit 1
fi
