# Bug report: #9051 — README.md links to docs/architecture.md which does not exist

## Problem

`README.md` in this repository contains a relative link to
`docs/architecture.md`. The file `docs/architecture.md` does not exist in the
repository, so the link is broken for every reader.

## Observed failure

Opening the README's architecture link yields a missing-file error; no
`docs/` directory is present at all.

## Expectation

The broken link is a defect in the documentation surface and warrants a fix.
