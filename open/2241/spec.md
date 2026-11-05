# [SPEC] Authorization tracking: local issue.yaml is canonical source, not remote API labels

## Problem

Authorization labels (`approved-for-*`) are written to the remote API as the primary
canonical source. The local `issue.yaml` file is the authoritative per-repo record and
must be the primary write target for all authorization labels.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-2 | `apply-label.md` SHALL write `approved-for-{scope}` to local `issue.yaml` as canonical; remote write SHALL be best-effort only | semantic |
