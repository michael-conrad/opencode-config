<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# [SPEC] Email validation on registration

## Problem Statement

The registration flow must validate the email address format before accepting a registration so that accounts are only created with deliverable addresses.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The system validates email format on registration | behavioral | Integration test run |

## Requirements

- R-1. The registration pipeline SHALL validate the email format before accepting a registration.

## Affected Files

- `src/registration/email_validator.py`
- `src/registration/registration_service.py`

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
