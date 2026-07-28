> **Full spec and artifacts: [`.issues/356/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/356)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/356/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Objective

Configure the opencode-vibeguard@0.1.0 plugin to only redact real credentials (API keys, tokens, private keys, password/secret assignments) and stop redacting benign identifiers (email addresses, IPs, UUIDs, phone numbers, MAC addresses, keyword substring matches).

# Background

The opencode-vibeguard@0.1.0 plugin currently has builtin scanners enabled for email, china_phone, china_id, uuid, ipv4, and mac_address, plus broad keyword matching on "secret", "password", "token", "key". These produce extensive false positives:

- **Builtin email scanner**: Redacts all email addresses including test/dev emails and commit author emails
- **Builtin ipv4 scanner**: Redacts all IPs including localhost, container IPs, documentation IPs
- **Builtin uuid scanner**: Redacts all UUIDs including entity IDs, session IDs, correlation IDs
- **Builtin china_phone scanner**: Redacts any 11-digit number starting with 1[3-9]
- **Builtin china_id scanner**: Redacts any 18-character string ending in digit/X
- **Builtin mac scanner**: Redacts all MAC addresses including test fixtures
- **Keyword 'key'**: Matches `api_key`, `ssh-key`, `primary_key`, `foreign_key`, `key_name`, `key_value`, `monkey`, `keyboard`
- **Keyword 'token'**: Matches `tokenizer`, `tokenize`, `token_type`, `csrf_token`, `id_token`, `token_count`
- **Keyword 'secret'**: Matches `secret_key`, `secret_value`, `secret_name`, `mysecret`
- **Keyword 'password'**: Matches `password_hash`, `password_reset`, `password_field`

The fix is a config-only change: disable builtin scanners and keywords, add targeted regex patterns for real credentials only.

# Not Included

- Changes to the vibeguard plugin source code
- Changes to `.opencode/opencode.jsonc` plugin declaration
- Changes to any other project files
- Adding new builtin scanners or keyword patterns

# Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `vibeguard.config.json` has `patterns.builtin` set to an empty array `[]` | `string` | grep for `builtin: []` in config file |
| SC-2 | `vibeguard.config.json` has no `patterns.keywords` key | `string` | grep confirms absence of `keywords` key |
| SC-3 | `vibeguard.config.json` contains a regex pattern for private key blocks (`-----BEGIN ... PRIVATE KEY-----`) | `string` | grep for `private-key` pattern name in config |
| SC-4 | `vibeguard.config.json` contains a regex pattern for password/passwd/pwd assignments | `string` | grep for `password-assignment` pattern name in config |
| SC-5 | `vibeguard.config.json` contains a regex pattern for secret/API key assignments | `string` | grep for `secret-assignment` pattern name in config |
| SC-6 | `vibeguard.config.json` is valid JSON and the vibeguard plugin loads it without error | `behavioral` | `opencode run` with test prompt verifies plugin loads without error |

# Requirements

1. The config file SHALL be named `vibeguard.config.json` and located at the project root.
2. The `patterns.builtin` array SHALL be empty (`[]`).
3. The `patterns.keywords` key SHALL be absent from the config.
4. The `patterns.regex` array SHALL include at minimum: openai-api-key, github-pat, aws-access-key, private-key, password-assignment, and secret-assignment patterns.
5. The private-key pattern SHALL match `-----BEGIN` followed by optional key type (RSA, DSA, EC, PGP, SSH, OPENSSH) followed by `PRIVATE KEY-----`.
6. The password-assignment pattern SHALL match `password`, `passwd`, or `pwd` followed by `=` or `:` and a non-whitespace value.
7. The secret-assignment pattern SHALL match `secret`, `api_key`, `api-key`, `secret_key`, or `secret_token` followed by `=` or `:` and a non-whitespace value.
8. The config SHALL be valid JSON (parseable by `JSON.parse`).

# Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Set `patterns.builtin` to `[]` |
| 2 | SC-2 | Remove `patterns.keywords` key |
| 3 | SC-3 | Add private-key regex pattern |
| 4 | SC-4 | Add password-assignment regex pattern |
| 5 | SC-5 | Add secret-assignment regex pattern |
| 6 | SC-6 | Validate final config JSON |

# Dependencies

- opencode-vibeguard@0.1.0 plugin declared in `.opencode/opencode.jsonc`
- Plugin config loading: project root `vibeguard.config.json` → `.opencode/vibeguard.config.json` → `~/.config/opencode/vibeguard.config.json`

# Traceability

| Requirement | SCs | Items |
|-------------|-----|-------|
| R1 (config file name/location) | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | 1, 2, 3, 4, 5, 6 |
| R2 (builtin empty) | SC-1 | 1 |
| R3 (keywords absent) | SC-2 | 2 |
| R4 (regex patterns) | SC-3, SC-4, SC-5 | 3, 4, 5 |
| R5 (private-key pattern) | SC-3 | 3 |
| R6 (password-assignment pattern) | SC-4 | 4 |
| R7 (secret-assignment pattern) | SC-5 | 5 |
| R8 (valid JSON) | SC-6 | 6 |
