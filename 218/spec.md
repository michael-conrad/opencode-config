## Parent

https://github.com/michael-conrad/opencode-config/issues/212 — Audit: Skill Card "Use When" Description Compliance

## Problem

The skill card auditor (in `adversarial-audit --task spec-audit` or `skill-creator --task validate`) has no semantic checks for description quality. Structural linting (Fix D) catches format violations, but semantic judgment is needed to determine whether a description unambiguously tells an agent when to invoke, that invocation is mandatory, and that the description matches the dispatch table's intent.

## Requirements

Add the following semantic auditor criteria to the skill card auditor:

### SC-SEM-001: Unambiguous dispatch condition

- **Question**: Does the description unambiguously tell an agent when to invoke this skill?
- **Method**: Sub-agent reads the description and the Trigger Dispatch Table, judges whether the description provides clear dispatch conditions
- **Failure**: Description is ambiguous about when to invoke (e.g., "Use when working with data" is too vague)
- **Severity**: ERROR

### SC-SEM-002: Mandatory invocation signal

- **Question**: Does the description signal that invocation is mandatory (not optional)?
- **Method**: Sub-agent reads the description and judges whether an agent would understand that this skill MUST be invoked when conditions match
- **Failure**: Description reads as optional or discretionary (e.g., "Use when you want to..." implies choice)
- **Severity**: WARNING

### SC-SEM-003: Dispatch table alignment

- **Question**: Does the description match the Trigger Dispatch Table's intent?
- **Method**: Sub-agent compares the description against the table's trigger conditions and judges alignment
- **Failure**: Description describes use cases the table does not cover, or table has triggers the description omits
- **Severity**: ERROR

### SC-SEM-004: Full coverage of dispatch conditions

- **Question**: Would an agent reading only the description know to invoke this skill in all conditions listed in the dispatch table?
- **Method**: Sub-agent reads the description, then reads the table, and judges whether every table trigger is represented in the description
- **Failure**: One or more table triggers are not reflected in the description
- **Severity**: WARNING

### SC-SEM-005: No optional/discretionary language

- **Question**: Does the description contain any language that could be interpreted as making dispatch optional or discretionary?
- **Method**: Sub-agent reads the description and identifies phrases that imply choice ("you can", "you may", "optionally", "if desired", "consider using")
- **Failure**: Description contains optional/discretionary language
- **Severity**: WARNING

## Implementation Notes

- Semantic auditor criteria should be added to the `adversarial-audit --task spec-audit` workflow
- Each criterion should produce a structured result: `{ criteria_id, skill_name, severity, pass/fail, reasoning }`
- The auditor should report all findings, not stop on first failure
- Auditor should use a clean-room sub-agent (different model from the producer) per adversarial-audit protocol
- The auditor receives only the SKILL.md file content — no producer context, no expected outcomes

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | SC-SEM-001 implemented and detects ambiguous descriptions | `behavioral` |
| SC-2 | SC-SEM-002 implemented and detects missing mandatory signal | `behavioral` |
| SC-3 | SC-SEM-003 implemented and detects dispatch table misalignment | `behavioral` |
| SC-4 | SC-SEM-004 implemented and detects incomplete coverage | `behavioral` |
| SC-5 | SC-SEM-005 implemented and detects optional/discretionary language | `behavioral` |
| SC-6 | All 5 criteria produce structured results with criteria_id, severity, pass/fail, reasoning | `structural` |
| SC-7 | Auditor reports all findings, not first-failure-only | `behavioral` |
| SC-8 | Auditor uses clean-room sub-agent with no producer context | `behavioral` |

## References

- Audit spec #212 §Semantic Auditor Criteria
- `adversarial-audit --task spec-audit`
- `skill-creator --task validate`
- `adversarial-audit/SKILL.md` §DISPATCH_GATE

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)