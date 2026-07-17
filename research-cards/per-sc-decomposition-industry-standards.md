---
research_question: "Does the per-SC RED/GREEN decomposition approach align with industry standards for test-driven development, requirements traceability, and incremental build?"
confidence: 0.95
status: active
tags:
  - tdd
  - requirements-traceability
  - incremental-build
  - decomposition
  - spec-303
created: 2026-07-17
last_updated: 2026-07-17
sources:
  - https://www.qwan.eu/2021/08/27/tdd-one-assert-per-test.html
  - https://codemanship.wordpress.com/2025/10/13/tdd-under-the-microscope-3-one-outcome-per-test/
  - https://stackoverflow.blog/2022/11/03/multiple-assertions-per-test-are-fine/
  - https://medium.com/@abdulkadirakyurt.de/one-reason-to-fail-why-single-assertion-tests-are-worth-the-overhead-811f8215ec75
  - https://www.parasoft.com/learning-center/do-178c/requirements-traceability/
  - https://www.parasoft.com/learning-center/iso-26262/requirements-traceability/
  - https://tobeagile.com/split-stories-on-acceptance-criteria/
---

## Summary

The per-SC RED/GREEN decomposition approach (spec #303) is strongly aligned with established industry standards across TDD, requirements traceability, and agile decomposition. No significant divergence was found. The approach is consistent with or stricter than industry norms.

## Findings

### 1. One Reason To Fail / One Outcome Per Test (TDD Heuristics)

**Industry consensus:** A test should have exactly one reason to fail. This principle goes by several names:

| Name | Source | Year |
|------|--------|------|
| One Assertion Per Test | Dave Astels (eXtreme Programming) | 2004 |
| Specific (Test Desiderata) | Kent Beck | 2002 |
| One Reason To Fail | Common TDD heuristic | — |
| One Outcome Per Test | Jason Gorman (Codemanship) | 2025 |
| One Question Per Test | Common TDD heuristic | — |

**Key sources:**

- **Qwan.eu (2021):** "A test case that has many expectations is difficult to understand when it fails. Our guideline is that a test should have one (and only one) reason to fail." Uses the example of `savesOrderAndNotifiesOwnerIfPaid` → split into `savesOrderIfPaid` + `notifiesOwnerIfPaid`.

- **Codemanship (2025):** "If a test fails, the cause of the failure should be obvious. A test should be about one thing. If a test's about many things, then when it fails we may well end up in the debugger trying to figure out which of them has gone wrong."

- **Medium / Abdulkadir Akyurt (2026):** "Each test should have exactly one reason to fail. When a test fails, you should be able to describe the failure in a single sentence without using the word 'and'." Reports real-world data: splitting 200 tests into 600 single-concern tests increased CI time from 14min to 18min but reduced diagnostic time from 40min to under 10min.

- **Stack Overflow Blog (2022):** Argues that multiple assertions are fine when they test the same conceptual outcome (e.g., status code + response body schema for a single API call). This is consistent with "one reason to fail" — the assertions share a single concern. The anti-pattern is "Assertion Roulette" where multiple independent concerns are bundled.

**Alignment with spec #303:** Strong. The per-SC RED/GREEN cycle enforces one-reason-to-fail at the implementation item level. Each SC is a single independently verifiable claim. The decomposition-depth mandate in `decompose.md` (lines 99-125) already codifies this: "Decompose until each unit is a single independently verifiable claim whose PASS/FAIL cannot be split across two assertions."

**Nuance:** The Stack Overflow article correctly notes that multiple technical assertions can serve a single conceptual concern. Our approach already handles this — a single SC may require multiple assertions (e.g., "API returns 200 AND body has correct schema"), but those assertions all test the same SC. The decomposition-depth mandate's "cannot be split" criterion captures this: if two assertions test the same conceptual outcome, they stay together.

### 2. Requirements Traceability Matrix (RTM) — ISO 26262, DO-178C, ASPICE

**Industry standard:** Bidirectional traceability from each requirement to its test case(s) is mandatory in safety-critical domains:

| Standard | Domain | Traceability Requirement |
|----------|--------|------------------------|
| DO-178C | Aerospace (aviation software) | Every high-level and low-level requirement must trace to verification tests. Bidirectional traceability required. |
| ISO 26262 | Automotive (functional safety) | Every safety requirement must link to hazards, design, and verification results. Part 8, Clause 6. |
| ASPICE | Automotive (process capability) | Requirements traceability to test cases is a key process attribute (SUP.4, SYS.5, SWE.6). |

**Key sources:**

- **Parasoft (DO-178C):** "You must demonstrate bidirectional traceability from high-level requirements all the way through low-level requirements, source code, and test cases."
- **Parasoft (ISO 26262):** "A requirements traceability matrix (RTM) maps and documents user requirements with test cases."
- **GeeksforGeeks (RTM):** "Each requirement is mapped with one or more corresponding test cases in the RTM."

**Alignment with spec #303:** Strong. The SC-to-item mapping in the plan writer (SC-2) and the SC-ID binding in checkpoint tags (SC-4) implement bidirectional traceability at the implementation level. Each SC maps to exactly one item, and each item references exactly one SC-ID. This is stricter than industry norms (which allow one-to-many requirement-to-test mappings) but is a valid and beneficial strictness for AI-agent-driven development where traceability must be machine-parseable.

### 3. User Story Splitting by Acceptance Criteria (Agile)

**Industry practice:** If a user story has multiple acceptance criteria, split it into separate stories — one per criterion.

**Key sources:**

- **ToBeAgile:** "If there are multiple acceptance criteria, then it usually means that the user wants something that can be composed of other little things. If this is the case, then we can split these little things into separate stories."
- **LinkedIn / Jason Hood:** "The 'Splitting by Acceptance Criteria' approach involves dividing user stories based on the specific conditions that must be met for the story to be considered complete."
- **BugPilot (2026):** "Break down the requirements into specific, testable actions, creating a test case for each acceptance item."

**Alignment with spec #303:** Strong. The per-SC item approach is the direct equivalent of splitting user stories by acceptance criteria. Each SC is an acceptance criterion, and each gets its own implementation item.

### 4. Incremental TDD Microcycle

**Industry practice:** The TDD cycle (RED → GREEN → REFACTOR) works best when each cycle adds exactly one behavior. This is the "micro feedback loop" that makes TDD effective.

**Key sources:**

- **Codemanship (2025):** "In a test-driven approach to development, we aim to flesh out our software one feature at a time, one scenario (set-up + action) at a time, and one outcome at a time. The benefit of our tests being about one outcome is that it helps us to work in these micro feedback loops, effectively putting one foot in front of the other."
- **GitScrum (2026):** "Red-Green-Refactor: Implement TDD with the red-green-refactor cycle."

**Alignment with spec #303:** Strong. The per-SC RED/GREEN/verify/commit cycle is exactly this microcycle. Each cycle adds one SC's worth of behavior, with per-SC checkpointing and verification.

## Gaps

No significant gaps found. The approach is consistent with or stricter than industry norms across all four dimensions examined.

## Classification

- **Type**: Validation research
- **Confidence**: 0.95
- **Verdict**: Approach is well-aligned with industry standards. No changes needed to spec #303 based on this research.
- **Applicable SCs**: SC-1 through SC-8 (all implementation SCs benefit from this validation)

## Sources

- [TDD Heuristics: One Assert Per Test](https://www.qwan.eu/2021/08/27/tdd-one-assert-per-test.html) — Qwan.eu, 2021
- [TDD Under The Microscope #3: One Outcome Per Test](https://codemanship.wordpress.com/2025/10/13/tdd-under-the-microscope-3-one-outcome-per-test/) — Codemanship, 2025
- [Stop requiring only one assertion per unit test](https://stackoverflow.blog/2022/11/03/multiple-assertions-per-test-are-fine/) — Stack Overflow Blog, 2022
- [One Reason to Fail: Why Single-Assertion Tests Are Worth the Overhead](https://medium.com/@abdulkadirakyurt.de/one-reason-to-fail-why-single-assertion-tests-are-worth-the-overhead-811f8215ec75) — Medium, 2026
- [Requirements Traceability Matrix for DO-178C Compliance](https://www.parasoft.com/learning-center/do-178c/requirements-traceability/) — Parasoft
- [Requirements Traceability: ISO 26262 Software Compliance](https://www.parasoft.com/learning-center/iso-26262/requirements-traceability/) — Parasoft
- [Split Stories on Acceptance Criteria](https://tobeagile.com/split-stories-on-acceptance-criteria/) — ToBeAgile
- [Requirements Traceability Matrix (RTM)](https://www.geeksforgeeks.org/software-testing/requirement-traceability-matrix/) — GeeksforGeeks
