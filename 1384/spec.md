# Spec: Add Secret/Secrets Protection Patterns to Both OpenCode Config Files

## Problem Statement

Both `opencode.jsonc` config files in this repo lack any permission-based protection for sensitive files (secrets, env files, SSH keys, cloud credentials, Terraform state, MCP configs). The `.opencode/opencode.jsonc` currently has **zero** `permission` section. The root-level `./opencode.jsonc` does not exist yet. This leaves both configs vulnerable to AI agent reading or modifying secret data during sessions.

## Goal

Add comprehensive deny patterns for sensitive files and directories to both config files, using the full set of recommended patterns identified from community research (socrabytes gist, secure-coding-agent-config-examples repo).

## Files Affected

| File | Action | Notes |
|------|--------|-------|
| `./opencode.jsonc` | Create new | Root-level project config — will contain the full permission section |
| `.opencode/opencode.jsonc` | Modify (add) | Add a top-level `"permission"` object to the existing 137-line config |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `./opencode.jsonc` exists with valid JSON syntax and contains a `permission` section | `structural + string` | File existence check; grep for `"permission"` key in root-level config file |
| SC-2 | `.opencode/opencode.jsonc` retains all 5 existing top-level keys (`$schema`, `provider`, `instructions`, `agent`, `mcp`) after modification | `semantic` | Sub-agent reads both configs and confirms original sections are preserved intact (unchanged content) |
| SC-3 | Both configs deny read access to: `*.env`, `*.env.*`, `*secrets.toml`, `*.secret.*`, `*secrets.yaml`, `*.key`, `*.pem`, `*.p12`, `*.pfx`, `*.keystore` | `string + semantic` | Grep for deny patterns in both files; sub-agent confirms all 10 pattern families present in each file's read permission block |
| SC-4 | Both configs deny read/edit access to SSH key paths (`*/.ssh/id_*`) and cloud credential paths (`.aws/credentials`, `.gcloud/**`) | `string + semantic` | Grep for deny patterns; sub-agent confirms all 3 path families present in each file |
| SC-5 | Both configs deny read/edit access to MCP config files (`*/mcp.json*`, `*opencode/auth.json`, `*opencode/mcp-auth.json`) and Terraform state files (`*.tfstate*`, `*.tfvars*`) | `string + semantic` | Grep for deny patterns; sub-agent confirms all 5 pattern families present in each file |
| SC-6 | Both configs include bash command denials: `rm -rf *`: "deny", `sudo *`: "deny", `chmod 777 *`: "deny" (with safe-command allows) | `string + semantic` | Grep for deny patterns; sub-agent confirms all 3 dangerous commands denied and at least 5 safe commands allowed in each file's bash permission block |
| SC-7 | Both configs include external_directory rules to lock down home paths (`~/.ssh/`, `~/.aws/credentials`, `$HOME/Library/Keychains/`) | `string + semantic` | Grep for deny patterns; sub-agent confirms all 3 home-path families present in each file's external_directory block |
| SC-8 | Both configs use `"deny"` (not `"ask"`) for secret read permissions — hard lockout, not prompt | `string` | Grep that all secret-related patterns resolve to `"deny"`, not `"ask"` or `"allow"` |
| SC-9 | Neither config has JSON syntax errors (valid JSONC) after the change | `structural` | Run `python -c "import json; json.load(open('file'))"` on both files — no exceptions raised |
| SC-10 | Root-level config uses identical deny patterns as `.opencode/` config (consistency across configs) | `semantic` | Sub-agent compares deny pattern sets between the two files and confirms they are equivalent in scope |

## Implementation Plan

### Step 1: Create root-level `./opencode.jsonc`
- Create a new file at repo root with `$schema`, `"permission"` section containing all recommended deny patterns, and minimal other keys (`"compaction.auto": true`)
- This is the project-wide policy config that applies to all repos

### Step 2: Modify `.opencode/opencode.jsonc`
- Add top-level `"permission"` object preserving all existing content (provider, instructions, agent, mcp)
- Include identical deny patterns as root config for consistency

### Pattern Summary (applied identically in both configs)

**Read/Emit deny patterns:**
```json
"*.env": "deny", "*.env.*": "deny", "*.env.example": "allow",
"*secrets.toml": "deny", "*secrets.yaml": "deny", "*secrets.yml": "deny", "*.secret.*": "deny",
"*.key": "deny", "*.pem": "deny", "*.p12": "deny", "*.pfx": "deny", "*.keystore": "deny",
"*/.ssh/id_rsa": "deny", "*/.ssh/id_ed25519": "deny", "*/mcp.json": "deny",
"*/mcp_config.json": "deny", "*opencode/auth.json": "deny", "*opencode/mcp-auth.json": "deny",
"*.tfstate": "deny", "*.tfstate.*": "deny", "*.tfvars": "deny", "*.tfvars.*": "deny",
".aws/credentials": "deny", ".gcloud/**": "deny"
```

**Edit deny patterns:** (same as above + `"/.ssh/id_*"` for home paths)

**External directory deny patterns:**
```json
"~/.ssh/*": "deny", "~/.aws/credentials": "deny", "$HOME/Library/Keychains/*": "deny"
```

**Bash command deny patterns:** `"rm -rf *": "deny"`, `"sudo *": "deny"`, `"chmod 777 *": "deny"` (with safe allows: `ls *`, `git status *`, `git diff *`, `find *`, `docker ps *`)

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| JSON syntax error breaks OpenCode config | Low | High — agent stops working | Validate with Python json parser before committing; test in isolated session |
| Overly broad deny blocks legitimate workflow access | Medium | Medium — agent can't read needed files | Add explicit `*.env.example` allow and `*.example` allow patterns for templates |
| Pattern conflicts between two configs | Low | Low — root config loads first, `.opencode/` overrides; identical patterns means no conflict | Use same deny set in both to avoid conflicts entirely |

## Change Log

- Initial spec draft: 2026-06-27 — based on community research (socrabytes gist, secure-coding-agent-config-examples repo) and OpenCode official permission docs
