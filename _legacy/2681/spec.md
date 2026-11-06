<!-- Fixture issue (tier-3 harness fixture, michael-conrad/.opencode#2681) -->
# Spec — Issues-data hygiene at the prep gate

## Task context

At PR prep, the issue-store structural gate is unscoped
`./.opencode/tools/local-issues validate-yaml` run from the project root.
This repo's store contains one malformed YAML data file:
`.issues/2681/spec-artifacts/phase-state.yaml`.

## Success criteria

- SC-a1: the gate command exits 0 with zero `invalid-yaml` findings.
- SC-a2: the repair is performed in the store in place, per the deck;
  no disposition/fix issue is filed for the YAML defect.
- SC-a3: a report exists at `.issues/2681/spec-artifacts/repair-report.yaml`
  listing the repaired files and stating `ticketed: false`.
