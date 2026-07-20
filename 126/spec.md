## Summary

Add the `web-search-mcp.py` example from the official ollama-python repository as a PEP 723 inline-script MCP server in `.opencode/tools/`. This exposes Ollama's hosted `web_search` and `web_fetch` APIs as MCP tools, giving the AI agent a secondary, Ollama-native search backend alongside the existing DuckDuckGo web search.

## Motivation

The agent already has web search and web fetch tools via DuckDuckGo and general fetch backends. However:

1. **Search backend diversity**: Ollama's hosted search API uses a different infrastructure than DuckDuckGo — it may serve different content, provide different freshness, or be available when DuckDuckGo is not.
2. **Ollama-native integration**: The Ollama Python SDK's `web_search` and `web_fetch` methods are first-class API endpoints designed for programmatic use, giving predictable result schemas.
3. **PEP 723 zero-install**: Because the script uses PEP 723 inline metadata, `uv run .opencode/tools/web-search-mcp.py` automatically provisions dependencies (`mcp`, `rich`, `ollama`) — no manual environment setup.
4. **Rejecting training data as stale**: A secondary independent search backend strengthens the "verify live" principle — the agent has more paths to verify claims against live sources, reducing the risk of falling back to stale training data.

## Proposal

### 1. Add script: `.opencode/tools/web-search-mcp.py`

Copy the upstream script from `https://raw.githubusercontent.com/ollama/ollama-python/refs/heads/main/examples/web-search-mcp.py` with appropriate SPDX/provenance/co-author headers.

The script is a PEP 723 inline-script (`# /// script` block) that creates an MCP stdio server with two tools:

| Tool | Parameters | Description |
|------|-----------|-------------|
| `web_search` | `query: str, max_results: int = 3` | Calls `ollama.Client().web_search()` |
| `web_fetch` | `url: str` | Calls `ollama.Client().web_fetch()` |

Supports both FastMCP (high-level) and low-level stdio server (fallback) APIs.

### 2. Configure in `opencode.jsonc`

Add an `mcp` entry:

```jsonc
"ollama-web-search": {
  "type": "local",
  "command": ["uv", "run", ".opencode/tools/web-search-mcp.py"],
  "enabled": true,
  "environment": {
    "OLLAMA_API_KEY": "${OLLAMA_API_KEY}"
  }
}
```

The `OLLAMA_API_KEY` env var is optional per the script source — if set, it's used as an Authorization header.

### 3. Register in agent instructions or tool allowlist

Optionally register the tool names in the agent's tool allowlist so the agent is aware of and prompted to use them for research tasks.

## Verification

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Script exists at `.opencode/tools/web-search-mcp.py` with PEP 723 header intact | structural |
| SC-2 | Script runs without import errors: `uv run .opencode/tools/web-search-mcp.py --help` exits 0 | behavioral |
| SC-3 | `opencode.jsonc` contains `ollama-web-search` MCP entry | string |
| SC-4 | MCP server exposes `web_search` and `web_fetch` tools (verify via `opencode mcp list` or MCP protocol handshake) | behavioral |
| SC-5 | Agent can invoke `web_search` and `web_fetch` tools in a test prompt | behavioral |

## Affected Files

- `.opencode/tools/web-search-mcp.py` — NEW
- `.opencode/opencode.jsonc` — MODIFY (add MCP entry)

## Reference

- Source: https://raw.githubusercontent.com/ollama/ollama-python/refs/heads/main/examples/web-search-mcp.py
- PEP 723: https://peps.python.org/pep-0723/
- OpenCode MCP config: https://opencode-tutorial.com/en/docs/mcp-servers

---

🤖 Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)