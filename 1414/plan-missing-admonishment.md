# Plan: Fix Parser Edge Case

## Phase 1: Add Input Validation

- [ ] 1. (**clean-room**) Add type check for None inputs
  - SC: Parser rejects None inputs
  - Command: `src/parser.py` add guard clause

- [ ] 2. (**clean-room**) Add boundary check for empty strings
  - SC: Parser rejects empty strings
  - Command: `src/parser.py` add length check

## Phase 2: Update Tests

- [ ] 3. (**clean-room**) Write RED test for None input rejection
  - SC: RED test fails before implementation
  - Command: `test/test_parser.py` add test case

- [ ] 4. (**clean-room**) Write RED test for empty string rejection
  - SC: RED test fails before implementation
  - Command: `test/test_parser.py` add test case

- [ ] 5. (**clean-room**) Verify RED tests fail
  - SC: Both RED tests confirmed failing
  - Command: `uv run pytest test/test_parser.py -k "test_reject_none or test_reject_empty"`

- [ ] 6. (**clean-room**) Implement GREEN for None rejection
  - SC: None input test passes
  - Command: `src/parser.py` implement guard

- [ ] 7. (**clean-room**) Implement GREEN for empty string rejection
  - SC: Empty string test passes
  - Command: `src/parser.py` implement check

- [ ] 8. (**clean-room**) Verify GREEN tests pass
  - SC: All tests pass
  - Command: `uv run pytest test/test_parser.py`
