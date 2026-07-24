#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Comprehensive
#
# Verifies the new writing-plans structure:
# 1. SKILL.md has 3 self-contained workflow tables (Create, Revise, Retroactive)
# 2. 9 task cards exist (analyze, backfill, structure, create, self-review,
#    solve, validate, revise, completion)
# 3. Plan artifact uses structured markdown format with dispatch frontmatter,
#    per-task checkbox lists, and dash sub-bullets
#
# GREEN phase: implementation is already in place from Phase 1.
# Expected to PASS (exit 0).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SKILL_MD=".opencode/skills/writing-plans/SKILL.md"
TASKS_DIR=".opencode/skills/writing-plans/tasks"
PLAN_FILE=".opencode/.issues/2085/plan.md"

echo "=== GREEN Test: writing-plans ==="
echo "Checking SKILL.md workflows, task cards, and plan format..."
echo ""

ALL_PASS=true

# ============================================================
# CHECK 1: SKILL.md has 3 self-contained workflow tables
# ============================================================
echo "--- Check 1: SKILL.md workflow tables ---"

HAS_CREATE=false
HAS_REVISE=false
HAS_RETROACTIVE=false
HAS_CROSS_REF=false

# Check 1a: Create workflow section heading + table
if grep -q '^### Create a plan from an approved spec' "$SKILL_MD" 2>/dev/null; then
    HAS_CREATE=true
    echo "  [FOUND] Create workflow section"
else
    echo "  [MISSING] Create workflow section"
fi

# Check 1b: Revise workflow section heading + table
if grep -q '^### Revise an existing plan' "$SKILL_MD" 2>/dev/null; then
    HAS_REVISE=true
    echo "  [FOUND] Revise workflow section"
else
    echo "  [MISSING] Revise workflow section"
fi

# Check 1c: Retroactive workflow section heading + table
if grep -q '^### Retroactive plan' "$SKILL_MD" 2>/dev/null; then
    HAS_RETROACTIVE=true
    echo "  [FOUND] Retroactive workflow section"
else
    echo "  [MISSING] Retroactive workflow section"
fi

# Check 1d: No cross-references between workflow tables
# Scope the check to lines between first workflow heading and last workflow table end
WORKFLOW_START=$(grep -n '^### Create a plan' "$SKILL_MD" | head -1 | cut -d: -f1)
WORKFLOW_END=$(grep -n '^## Task Cards' "$SKILL_MD" | head -1 | cut -d: -f1)
if [ -n "$WORKFLOW_START" ] && [ -n "$WORKFLOW_END" ]; then
    if sed -n "${WORKFLOW_START},${WORKFLOW_END}p" "$SKILL_MD" | grep -qi 'same as\|see.*workflow\|as step\|as above\|see above'; then
        HAS_CROSS_REF=true
        echo "  [CROSS-REF] Cross-references detected between workflows"
    else
        echo "  [CLEAN] No cross-references between workflows"
    fi
else
    echo "  [SKIP] Could not determine workflow boundaries"
fi

if $HAS_CREATE && $HAS_REVISE && $HAS_RETROACTIVE && ! $HAS_CROSS_REF; then
    echo "  >> PASS: 3 workflow tables, no cross-references"
else
    echo "  >> FAIL: workflow table check"
    ALL_PASS=false
fi
echo ""

# ============================================================
# CHECK 2: 9 task cards exist
# ============================================================
echo "--- Check 2: Task cards ---"

REQUIRED_TASKS=("analyze" "backfill" "structure" "create" "self-review" "solve" "validate" "revise" "completion")
MISSING_TASKS=()

for task in "${REQUIRED_TASKS[@]}"; do
    if [ -f "$TASKS_DIR/$task.md" ]; then
        echo "  [FOUND] tasks/$task.md"
    else
        echo "  [MISSING] tasks/$task.md"
        MISSING_TASKS+=("$task")
    fi
done

if [ ${#MISSING_TASKS[@]} -eq 0 ]; then
    echo "  >> PASS: All 9 task cards present"
else
    echo "  >> FAIL: Missing ${#MISSING_TASKS[@]} task card(s): ${MISSING_TASKS[*]}"
    ALL_PASS=false
fi
echo ""

# ============================================================
# CHECK 3: Plan artifact uses structured markdown format
# ============================================================
echo "--- Check 3: Plan structured markdown format ---"

HAS_FRONTMATTER=false
HAS_DISPATCH=false
HAS_TITLE=false
HAS_GOAL=false
HAS_ARCHITECTURE=false
HAS_TECH_STACK=false
HAS_PRE_IMPL=false
HAS_PHASE=false
HAS_TASK=false
HAS_CHECKBOX=false
HAS_DASH_BULLET=false

# Check 3a: YAML frontmatter with plan_schema_version
if grep -q 'plan_schema_version:' "$PLAN_FILE" 2>/dev/null; then
    HAS_FRONTMATTER=true
    echo "  [FOUND] YAML frontmatter with plan_schema_version"
else
    echo "  [MISSING] YAML frontmatter with plan_schema_version"
fi

# Check 3b: Dispatch section in frontmatter
if grep -q 'dispatch:' "$PLAN_FILE" 2>/dev/null; then
    HAS_DISPATCH=true
    echo "  [FOUND] Dispatch section in frontmatter"
else
    echo "  [MISSING] Dispatch section in frontmatter"
fi

# Check 3c: Title section
if grep -q '^# Implementation Plan' "$PLAN_FILE" 2>/dev/null; then
    HAS_TITLE=true
    echo "  [FOUND] Title section"
else
    echo "  [MISSING] Title section"
fi

# Check 3d: Goal section
if grep -q '^\*\*Goal:\*\*' "$PLAN_FILE" 2>/dev/null; then
    HAS_GOAL=true
    echo "  [FOUND] Goal section"
else
    echo "  [MISSING] Goal section"
fi

# Check 3e: Architecture section
if grep -q '^\*\*Architecture:\*\*' "$PLAN_FILE" 2>/dev/null; then
    HAS_ARCHITECTURE=true
    echo "  [FOUND] Architecture section"
else
    echo "  [MISSING] Architecture section"
fi

# Check 3f: Tech Stack section
if grep -q '^\*\*Tech Stack:\*\*' "$PLAN_FILE" 2>/dev/null; then
    HAS_TECH_STACK=true
    echo "  [FOUND] Tech Stack section"
else
    echo "  [MISSING] Tech Stack section"
fi

# Check 3g: Pre-Implementation section
if grep -q '^## Pre-Implementation' "$PLAN_FILE" 2>/dev/null; then
    HAS_PRE_IMPL=true
    echo "  [FOUND] Pre-Implementation section"
else
    echo "  [MISSING] Pre-Implementation section"
fi

# Check 3h: Phase sections
if grep -q '^## Phase' "$PLAN_FILE" 2>/dev/null; then
    HAS_PHASE=true
    echo "  [FOUND] Phase sections"
else
    echo "  [MISSING] Phase sections"
fi

# Check 3i: Task subsections
if grep -q '^### Task' "$PLAN_FILE" 2>/dev/null; then
    HAS_TASK=true
    echo "  [FOUND] Task subsections"
else
    echo "  [MISSING] Task subsections"
fi

# Check 3j: Checkbox lists
if grep -q '\- \[ \]' "$PLAN_FILE" 2>/dev/null; then
    HAS_CHECKBOX=true
    echo "  [FOUND] Checkbox lists"
else
    echo "  [MISSING] Checkbox lists"
fi

# Check 3k: Dash sub-bullets (Dispatch/Context lines)
if grep -q '^  - Dispatch:\|^  - Context:' "$PLAN_FILE" 2>/dev/null; then
    HAS_DASH_BULLET=true
    echo "  [FOUND] Dash sub-bullets (Dispatch/Context)"
else
    echo "  [MISSING] Dash sub-bullets (Dispatch/Context)"
fi

if $HAS_FRONTMATTER && $HAS_DISPATCH && $HAS_TITLE && $HAS_GOAL && $HAS_ARCHITECTURE && $HAS_TECH_STACK && $HAS_PRE_IMPL && $HAS_PHASE && $HAS_TASK && $HAS_CHECKBOX && $HAS_DASH_BULLET; then
    echo "  >> PASS: Plan follows structured markdown format"
else
    echo "  >> FAIL: Plan missing required sections"
    ALL_PASS=false
fi
echo ""

# ============================================================
# RESULT
# ============================================================
echo "=== RESULT ==="
if $ALL_PASS; then
    echo "PASS: All 3 checks pass (writing-plans satisfies new behavior)"
    exit 0
else
    echo "FAIL: writing-plans does not fully satisfy new behavior checks"
    exit 1
fi
