# [SPEC] Add input validation helper

Create a shell script at `tools/validate-input.sh` that checks
required environment variables are set before the main script runs.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `tools/validate-input.sh` exists and is executable | structural |
| SC-2 | Script checks `INPUT_DIR` and `OUTPUT_DIR` env vars | structural |
| SC-3 | Script outputs clear error messages for each missing var | behavioral |
| SC-4 | Script exits 0 when all vars are set, 1 when any missing | behavioral |