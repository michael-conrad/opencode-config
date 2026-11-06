<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# [SPEC] Password policy enforcement on account creation

## Problem Statement

The account creation flow must enforce a password policy so that accounts are only created with passwords meeting minimum strength requirements.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The system enforces a minimum password length of 8 characters on account creation | behavioral | Integration test run |
| SC-2 | The system enforces a minimum password length of 8 characters on account creation | behavioral | Integration test run |

## Requirements

- R-1. The account creation pipeline SHALL reject passwords shorter than 8 characters.

## Affected Files

- `src/auth/password_policy.py`
- `src/auth/account_creation.py`

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
