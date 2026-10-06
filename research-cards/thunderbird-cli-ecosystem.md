# Research Card: thunderbird-cli ecosystem

Date: 2026-10-06 · Confidence: high (core findings) · Sources fetched live this session.

## Question

Research `thunderbird-cli` (Go program on GitHub): existing skill card sets, its
CLI options, and whether it supports progressive disclosure out of the box via
the CLI. Follow-up: can `buddhism5080/thunderbird-agent` be installed into
`.tools/` without global npm?

## Findings

### Name collision — two `thunderbird-cli` repos exist

| Repo | Language | Stars | What it is |
|---|---|---|---|
| `avikalpa/thunderbird-cli` | Go 1.25 | 1 | Terminal workflow over existing Thunderbird/Betterbird profiles (`tb` binary). Last push 2026-08-13. |
| `vitalio-sh/thunderbird-cli` | JavaScript | 54 | "CLI + MCP server for AI agents" — WebExtension + localhost bridge (127.0.0.1:7700) + `tb` CLI (38 commands) + `tb-mcp` (12 tools). Bundles its own skill. |

The Go program is `avikalpa/thunderbird-cli`. `thunderbird-agent` is **not on
npm** (registry query returned no versions) — git clone/vendor is the only
install path for it.

### Existing skill card sets — yes, at least five independent ones

1. **avikalpa/thunderbird-cli** ships root `SKILL.md` (agentskills frontmatter,
   `name: thunderbird-cli`) that deliberately delegates: "The instructions live
   in AGENTS.md" — plus `PLAYBOOK.md` and a "Coding-Agent Workflows" README
   section (Codex/Claude Code prompts).
2. **buddhism5080/thunderbird-agent** (MIT, v0.6.1, created 2026-05-07, pushed
   2026-05-08 — one-day burst, 2★) ships exactly one skill:
   `skills/thunderbird-agent/SKILL.md` (full frontmatter incl. tags
   `agentskills`), plus `AGENTS.md`, `CLAUDE.md`, `docs/agents/{claude-code,
   codex,openclaw}.md`. Refactored from `TKasperczyk/thunderbird-mcp` (359★,
   MCP-only flagship, actively maintained 2026-10-05).
3. **hangox/thunderbird-skill-cli** (Apache-2.0, macOS-centric, anti-MCP by
   design) ships `skill/thunderbird/SKILL.md` + `references/cli-reference.md` +
   `references/safety-policy.md`, installable as a Claude Code plugin
   (`/plugin install thunderbird@hangox-tools`).
4. **vitalio-sh/thunderbird-cli** bundles `skills/thunderbird-cli/SKILL.md`
   (v1.1.0, token-optimization patterns, draft-by-default, 12-tool table) with
   its MCP server. Derivative exists: `geometry-xenz/thunderbird-cli-attachments`
   (adds attachment support on a branch).
5. **mvanhorn/printing-press-library** ships `library/productivity/thunderbird/
   SKILL.md` wrapping its own Go CLI `thunderbird-pp-cli` (read-only profile
   indexer into SQLite) — a second independent "skill card wrapping a Go
   Thunderbird CLI".

Curated indexes: `anthropics/skills` has 19 skills, **zero** email/Thunderbird;
`VoltAgent/awesome-agent-skills` (35.3k★) has **zero** thunderbird mentions.
Discovery currently happens via GitHub code search and MCP directories.
Thunderbird MCP ecosystem broadly: 20+ servers (TKasperczyk flagship; forks
static9, commonpost; vitalio-sh; U-C4N 112-tool; native-messaging variants).

### Go `tb` CLI options (from source, verified by clone)

Top-level (`tb --help`, hand-rolled dispatch in main.go; pflag for flags):
`version` · `features` · `doctor` · `update [--check]` · `mail` · `q|ask` ·
`reply` · plus aliases `list`→`mail recent`, `tail`→`mail unified`,
`head`→`mail unified --oldest`, `read`→`mail show`, `find`/`search`→`mail
search`.

`tb mail` subcommands (from `mailUsage()`): `profiles`, `folders`,
`recent [folder]`, `unified`, `search <query>`, `index`, `fetch [--sync]`,
`sync`, `show/read [--save-attachments DIR]`, `compose/send`, `sentcheck`,
`authcheck`, `move`, `reply`, `credential set|list`. Notable flags: `--sync`,
`--raw`, `--limit`, `--account`, `--profile`, `--message-id`, `--thread`,
`--send` (reply/compose are dry-run unless `--send`), `--verify <duration>`,
`--in-reply-to/--references`. Data output is JSON-when-piped.

Architecture: reads existing TB/Betterbird profiles, SQLite cache (XDG state;
optional PostgreSQL via `TB_STORE=postgres`), headless direct send via
NSS-decrypted credentials/OAuth XOAUTH2 (Linux+cgo only; macOS/Windows are
read/search/cache only). Single static binary, `go build`, no runtime deps.

### buddhism5080/thunderbird-agent CLI + install story

CLI (`packages/cli/thunderbird-agent.cjs`, 5.3 KB thin client →
`packages/core/index.cjs` 21.6 KB → localhost JSON-RPC server inside the
installed Thunderbird extension): `help` · `doctor` · `rpc --request <json>` ·
`tools list [--catalog]` · `tools call <name> [--args <json>]` ·
`catalog [show <name>]`. 36 tools in `shared/tool-catalog.json` (groups:
messages, folders, contacts, calendar, filters, system), each entry with
`name/title/group/crud/description/inputSchema`.

**`.tools/` install verdict: yes, without global npm.**
- package.json has **no `dependencies`/`devDependencies`** at all; both `.cjs`
  files require only Node builtins (`fs`, `http`, `os`, `path`); `engines:
  node >=18`. Nothing to `npm install`.
- README's canonical path is `node packages/cli/thunderbird-agent.cjs ...`
  from a clone; `npm install -g` is explicitly optional, and the package isn't
  published to npm anyway.
- `npm run build` only produces the XPI (pure-Node scripts); the XPI is also
  committed at `dist/thunderbird-agent.xpi`, so build can be skipped.
- Vendored-node pattern already exists in this deck: `.opencode/tools/
  ensure-node` provisions Node 22.14.0 into `.opencode/.node/` — satisfies
  `>=18`.
- Caveats: (a) keep directory layout intact (`../core/index.cjs` relative
  require; catalog at `../../shared/tool-catalog.json`); (b) the Thunderbird
  side still needs the XPI installed into the profile (scripts/install.sh,
  copies to `extensions/thunderbird-agent@tkasperczyk.dev.xpi`, needs TB
  restart; python3 used for profile detection with glob fallback); (c) live
  tools require Thunderbird running — `doctor` reports that; (d) maintenance
  risk: single one-day burst May 2026, no commits since.

### Progressive disclosure out of the box?

- **buddhism5080/thunderbird-agent: yes.** Three machine-readable levels:
  `doctor` (connectivity/capability discovery) → `tools list [--catalog]` (flat
  36-tool surface with name/title/group/description/required) →
  `catalog show <name>` (full JSON Schema per tool). Generic raw `rpc` escape
  hatch. This is the strongest out-of-the-box progressive disclosure of the set.
- **avikalpa/thunderbird-cli (Go): partial, by design.** Two-level hand-rolled
  text help (`tb --help` → `tb mail --help`); flags documented centrally, not
  per-subcommand; help is not machine-readable, but data output is
  JSON-when-piped, and `tb doctor`/`tb features` are capability-disclosure
  surfaces. Its progressive disclosure lives at the skill layer instead:
  SKILL.md (thin pointer) → AGENTS.md (instructions) → PLAYBOOK.md.
- Thunderbird's **own** CLI (the `thunderbird` binary, snap 157.0 here) is a
  flat single-shot flag set (`-compose`, `-mail`, `-addressbook`, `-calendar`,
  `-safe-mode`, `-P`, …) — no subcommand hierarchy, no layered help; both tools
  above exist precisely to bypass that limitation.

## Sources (all fetched 2026-10-06)

- Cloned and inspected: `github.com/avikalpa/thunderbird-cli` (go.mod, main.go,
  mail.go, meta.go, SKILL.md), `github.com/buddhism5080/thunderbird-agent`
  (package.json, packages/cli+core, scripts/install.sh, shared/
  tool-catalog.json, skills/thunderbird-agent/SKILL.md, README.md)
- Sub-agent fetches: raw READMEs/SKILL.md/LICENSE of buddhism5080, hangox,
  vitalio-sh, avikalpa; `api.github.com/repos/anthropics/skills/contents/skills`;
  authenticated `gh search repos/code` (thunderbird × skill/SKILL.md/mcp);
  npm registry query `registry.npmjs.org/thunderbird-agent` (no published versions)

## Live read-only tests (2026-10-06, this machine)

Authorized read-only testing against the local install (Thunderbird 157 snap;
profile `6t2iilo4.default` under both `~/.thunderbird` and
`~/snap/thunderbird/common/.thunderbird`; real Gmail IMAP accounts, no writes
to the profile, no sync, no send).

**avikalpa/thunderbird-cli — works end-to-end read-only:**
- Prebuilt v3.5.0 (gh release, SHA256SUMS verified) runs without Go installed.
- `tb version` / `features` / `doctor`: all green — profile detection, SQLite
  backend open, NSS runtime OK, direct-send providers listed.
- `tb mail profiles` / `mail folders`: correct real listings (ImapMail folders
  with sizes). First `tb list` built its index in ~9 s into its own SQLite
  cache (~/.config/ai.opencode.desktop/thunderbird-cli/); profile untouched.
- `tb q "jetbrains invoice"` piped: JSON with `query/count/messages/notes/
  scope`; 30 folders searched; per-result `read` field holds the exact next
  command verbatim (`tb read --message-id "<...>"`) — data-level progressive
  disclosure. Notes transparently reported "cache empty; scanned mailbox files
  directly".
- **Snap blind spot confirmed + workaround:** auto-detection picks
  `~/.thunderbird`, never the snap root;
  `THUNDERBIRD_HOME=~/snap/thunderbird/common/.thunderbird` overrides correctly.

**buddhism5080/thunderbird-agent — CLI verified under vendored Node:**
- Runs on `.opencode/.node/bin/node` v22.14.0 (engines >=18 satisfied), zero
  npm deps confirmed in practice.
- `help`, `tools list --catalog` (count 36), `catalog show searchMessages`
  (full JSON Schema incl. query operator docs) — progressive disclosure
  demonstrated live, machine-readable at every level.
- `doctor`: honest JSON failure report enumerating all three discovery paths
  (native tmp, Snap Downloads fallback, Flatpak scan), exit 1, correct
  prerequisite message. Live path requires the XPI in the profile + TB running.

## Gaps (updated after live testing)

- **XPI install into the profile not tested** — that step writes to the
  Thunderbird profile and stayed outside the read-only authorization;
  `thunderbird-agent`'s live tool calls are therefore unexercised here.
- vitalio-sh/thunderbird-cli (JS) not exercised — would need its own
  WebExtension installed in the profile.
- Sub-agent verified most minor ecosystem repos at metadata/tree level only.
- skillmd/skillsmp marketplace listings only seen at snippet level.
