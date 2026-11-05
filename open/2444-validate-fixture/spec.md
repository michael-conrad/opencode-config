<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
# [SPEC] Fixture: log-rotation policy for the report generator service

## Problem

The report generator service writes unlimited log files to its working directory.
Unbounded log growth fills the disk and halts the service. A rotation policy is
required so logs remain bounded and old files are removed deterministically.

## Success Criteria

| SC | Criterion | Evidence Type | Documentation Sources |
|----|-----------|---------------|----------------------|
| SC-1 | The report generator SHALL rotate its service log when the file exceeds 10 MB and SHALL retain at most 5 rotated files, deleting older files deterministically by timestamp order | structural | grep of `docs/ops/log-policy.md` "Rotation" section |

## Cost Frames

- SC-1: verification costs one config-file grep and one filesystem check — seconds. Skipping means unbounded log growth recurs and the first production disk-full incident costs an outage plus a full incident-review cycle.

## Verification

- SC-1: structural — config check confirming the rotation threshold (10 MB), retention count (5), and deterministic deletion ordering are present in the service configuration.

*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
