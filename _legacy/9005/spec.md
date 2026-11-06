# Spec: #9005 — Release-announcement draft

Provenance: developer request 2026-10-07 — a release announcement is needed
for the upcoming version.

## Problem

The upcoming version ships without an announcement; stakeholders learn of
releases only from the changelog.

## Success criteria

### SC-1 (structural)

`docs/release-announcement.md` exists and states the version number.

- **Verify:** `test -f docs/release-announcement.md` exits 0 and the file
  contains the version string.

### SC-2 (behavioral)

The release manager confirms receipt of the announcement in writing, and the
confirmation is filed in the announcement's issue as a comment before the
announcement is considered done.

- **Verify:** the issue contains the release manager's written confirmation
  comment.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
