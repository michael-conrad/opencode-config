#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Structure Task Card
#
# Verifies that skills/writing-plans/tasks/structure.md produces phase
# decomposition, builds a dependency DAG, and selects skill+task from
# the implementation-pipeline Trigger Dispatch Table.
#
# RED phase: structure.md does NOT exist yet.
# Expected to FAIL (non-zero exit).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

STRUCTURE_MD=".opencode/skills/writing-plans/tasks/structure.md"

echo "=== RED Test: writing-plans-structure ==="
echo "Checking $STRUCTURE_MD for phase decomposition, DAG, and TDT selection..."
echo ""

EXISTS=false
HAS_PHASE_DECOMP=false
HAS_DAG=false
HAS_TDT_SELECT=false

# Check 1: structure.md must exist
if [ -f "$STRUCTURE_MD" ]; then
    EXISTS=true
    echo "  [FOUND] $STRUCTURE_MD exists"
else
    echo "  [MISSING] $STRUCTURE_MD does not exist (expected RED)"
fi

# Check 2: Must produce phase decomposition
if $EXISTS && grep -qi 'phase.*decomp\|decompose.*phase\|phase.*structur\|phase.*plan\|phase.*step\|phase.*concern' "$STRUCTURE_MD" 2>/dev/null; then
    HAS_PHASE_DECOMP=true
    echo "  [FOUND] Phase decomposition logic"
else
    echo "  [MISSING] Phase decomposition (expected RED)"
fi

# Check 3: Must build a dependency DAG
if $EXISTS && grep -qi 'dag\|dependency.*graph\|dependency.*dag\|depends.*on\|dependency.*order\|dependency.*chain' "$STRUCTURE_MD" 2>/dev/null; then
    HAS_DAG=true
    echo "  [FOUND] Dependency DAG logic"
else
    echo "  [MISSING] Dependency DAG (expected RED)"
fi

# Check 4: Must select skill+task from implementation-pipeline TDT
if $EXISTS && grep -qi 'implementation-pipeline\|trigger.*dispatch.*table\|tdt\|skill.*task.*select\|dispatch.*table\|pipeline.*tdt' "$STRUCTURE_MD" 2>/dev/null; then
    HAS_TDT_SELECT=true
    echo "  [FOUND] Implementation-pipeline TDT selection"
else
    echo "  [MISSING] Implementation-pipeline TDT selection (expected RED)"
fi

echo ""
if $EXISTS && $HAS_PHASE_DECOMP && $HAS_DAG && $HAS_TDT_SELECT; then
    echo "UNEXPECTED PASS: structure.md has phase decomposition, DAG, and TDT selection"
    exit 0
else
    echo "EXPECTED FAIL: structure.md missing required capabilities (RED phase confirmed)"
    echo "  EXISTS=$EXISTS PHASE_DECOMP=$HAS_PHASE_DECOMP DAG=$HAS_DAG TDT_SELECT=$HAS_TDT_SELECT"
    exit 1
fi
