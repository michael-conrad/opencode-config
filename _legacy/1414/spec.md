# [SPEC-FIX] Add one-step-at-a-time protocol admonishment to plan files

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Plan format requirements include the one-step-at-a-time protocol admonishment | `string` | grep for admonishment text in plan format docs |
| SC-2 | Plan-fidelity auditor checks for the admonishment presence | `behavioral` | `opencode-cli run` → stderr assertions |
| SC-3 | Auditor reports FAIL when admonishment is missing | `behavioral` | `opencode-cli run` → stderr assertions |
| SC-4 | Auditor reports PASS when admonishment is present | `behavioral` | `opencode-cli run` → stderr assertions |
