# Bug report: #9052 — README.md carries two independent documentation defects

## Problem

`README.md` in this repository has two independent defects, unrelated to each
other:

1. It links to `docs/architecture.md`, which does not exist — a broken
   architecture-documentation link.
2. It links to `docs/onboarding.md`, which also does not exist — a broken
   onboarding-documentation link.

The two defects concern different documentation surfaces and warrant separate
fixes.

## Observed failure

Both links fail for every reader; neither target file exists in the
repository.

## Expectation

Each defect is actionable on its own and warrants its own fix.
