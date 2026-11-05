# Spec: #9003 — Ticket-report generator script

Provenance: developer request 2026-10-07 — a reusable ticket-report script is
needed for weekly reporting; observed manual effort assembling the numbers.

## Problem

Weekly ticket reporting is assembled by hand from the tracker each Friday.
A script that renders the numbers from a local CSV export removes the
recurring manual step.

## Fix shape

A `report.sh` script reads a CSV export (`tickets.csv`, columns:
`id,title,status,opened`) and renders a per-status count report to stdout.

## Success criteria

### SC-1 (structural)

`report.sh` exists at the repo root and is executable.

- **Verify:** `test -x report.sh` exits 0.

### SC-2 (behavioral)

Running `bash report.sh tickets.csv --format=summary` prints a per-status
count table, or running it with `--format=json` prints a JSON object with one
key per status.

- **Verify:** run both command forms; each run's stdout matches its stated
  shape.

### SC-3 (structural)

Rows whose `status` column is empty are excluded from every count.

- **Verify:** a fixture CSV containing one empty-status row produces counts
  that omit it.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
