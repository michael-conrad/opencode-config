#!/usr/bin/env bash
set -euo pipefail

# SC-4: Remove Channel-Routing Table from 020-go-prohibitions.md
# Evidence type: string
# RED phase: assert absence of "Channel-Routing Table" in 020-go-prohibitions.md
# Expected: FAIL (section still exists)

TARGET_FILE=".opencode/guidelines/020-go-prohibitions.md"
ARTIFACT_DIR="tmp/2127/artifacts"
ARTIFACT_LOG="${ARTIFACT_DIR}/sc-4-test-output.log"

mkdir -p "${ARTIFACT_DIR}"

if grep -q "Channel-Routing Table" "${TARGET_FILE}"; then
  echo "FAIL: 'Channel-Routing Table' still present in ${TARGET_FILE}" | tee "${ARTIFACT_LOG}"
  exit 1
else
  echo "PASS: 'Channel-Routing Table' absent from ${TARGET_FILE}" | tee "${ARTIFACT_LOG}"
  exit 0
fi
