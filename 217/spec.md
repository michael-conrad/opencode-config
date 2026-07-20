## Parent

https://github.com/michael-conrad/opencode-config/issues/212 — Audit: Skill Card "Use When" Description Compliance

## Problem

The skill card linter (in `skill-creator` skill) has no structural checks for description compliance. Four linting rules are needed to catch violations at validation time rather than relying solely on semantic audit.

## Requirements

Add the following structural checks to the skill card linter:

### SC-LINT-001: Description starts with "Use when"

- **Check**: Description field starts with the literal string `"Use when"`
- **Applies to**: All skills
- **Failure**: Description does not start with `"Use when"`
- **Severity**: ERROR

### SC-LINT-002: Description contains mandatory keyword

- **Check**: Description contains at least one of: `MUST`, `REQUIRED`, `always`, `not optional`, `mandatory`
- **Applies to**: All skills
- **Failure**: No mandatory keyword found
- **Severity**: WARNING

### SC-LINT-003: No standalone narrative-only sentence

- **Check**: Description does not end with a sentence that adds zero dispatch information. Narrative-only patterns to detect: metaphors ("X is the Y"), slogans ("X produces Y"), value judgments ("Professional engineers X"), benefit statements ("X turns Y into Z")
- **Applies to**: All skills
- **Failure**: Description contains a sentence matching narrative-only patterns
- **Severity**: WARNING

### SC-LINT-004: Description length limit

- **Check**: Description does not exceed 300 characters
- **Applies to**: All skills
- **Failure**: Description exceeds 300 characters
- **Severity**: WARNING

## Implementation Notes

- Linting rules should be added to the `skill-creator` skill's validation task
- Each rule should produce a structured result: `{ rule_id, skill_name, severity, pass/fail, detail }`
- Rules should run on `skill-creator --task validate`
- The linter should report all failures, not stop on first failure

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | SC-LINT-001 implemented and detects missing "Use when" | `behavioral` |
| SC-2 | SC-LINT-002 implemented and detects missing mandatory keyword | `behavioral` |
| SC-3 | SC-LINT-003 implemented and detects narrative-only sentences | `behavioral` |
| SC-4 | SC-LINT-004 implemented and detects descriptions over 300 chars | `behavioral` |
| SC-5 | All 4 rules produce structured results with rule_id, severity, pass/fail | `structural` |
| SC-6 | Linter reports all failures, not first-failure-only | `behavioral` |

## References

- Audit spec #212 §Linting Rules
- `skill-creator` skill — validation task
- `skill-creator/tasks/validate.md`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)