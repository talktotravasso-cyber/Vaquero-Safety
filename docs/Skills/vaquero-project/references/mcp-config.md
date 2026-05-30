# MCP Configuration Reference — Vaquero & Agency Clients

## Credential Architecture

### Why Windows System Environment Variables (not .env)

`.env` files were abandoned due to process-scope read failures with N8N.
Windows System Environment Variables (`%VAR_NAME%`) are read natively by Cursor
at process start — no file loading required.

Set via: Windows → System Properties → Advanced → Environment Variables → System Variables

---

## Active MCP Servers

### Global config location
```
~/.cursor/mcp.json
```

### Current configuration
```json
{
  "mcpServers": {
    "supabase-vaquero": {
      "command": "cmd",
      "args": [
        "/c", "npx", "-y",
        "@supabase/mcp-server-supabase@latest",
        "--access-token", "%CURSOR_MCP_VAQUERO%"
      ]
    },
    "sequential-thinking": {
      "command": "cmd",
      "args": [
        "/c", "npx", "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    },
    "pagecrawl": {
      "command": "cmd",
      "args": [
        "/c", "npx", "-y",
        "@pagecrawl/mcp-server"
      ]
    }
  }
}
```

### Why `cmd /c` wrapper
Raw `npx` without the `cmd /c` wrapper fails on Windows. Always use this
pattern for Windows MCP entries.

---

## Adding a New Agency Client

### Step 1 — Windows Environment Variable
```
Variable name:  CURSOR_MCP_[CLIENTNAME]
Variable value: [client supabase token]
Set at:         System Variables (not User Variables)
```

### Step 2 — Add MCP entry to `~/.cursor/mcp.json`
```json
"supabase-[clientname]": {
  "command": "cmd",
  "args": [
    "/c", "npx", "-y",
    "@supabase/mcp-server-supabase@latest",
    "--access-token", "%CURSOR_MCP_[CLIENTNAME]%"
  ]
}
```

### Step 3 — Restart Cursor
Changes to mcp.json require Cursor restart to activate.

### Step 4 — Verify
Settings → Tools & Integrations — confirm new server appears as active.

---

## Naming Convention Registry

| Client | Environment Variable | MCP Server Name |
|--------|---------------------|-----------------|
| Vaquero Safety Inc. | `%CURSOR_MCP_VAQUERO%` | `supabase-vaquero` |
| PageCrawl | OAuth (no env var) | `pagecrawl` |
| *(next client)* | `%CURSOR_MCP_[NAME]%` | `supabase-[name]` |

---

## MCP Companion Skill Requirements

| MCP | Companion Skill Required? | Reason |
|-----|--------------------------|--------|
| `sequential-thinking` | No | Self-describing, reasoning tool |
| `supabase-vaquero` | No | Self-describing via MCP protocol |
| `pagecrawl` | No | Self-describing via MCP protocol |
| Custom-built MCP | Yes | Tool behavior not self-describing |

---

## JSON Validation Rule

`mcp.json` allows only ONE root-level `{}` object. Multiple root objects
cause silent failure — Cursor ignores the entire file.

All servers must be nested under a single `"mcpServers": {}` block.

---

## Credential Security Rules

- Tokens NEVER appear in `args[]` as hardcoded strings
- Tokens NEVER appear in source files, comments, or logs
- Audit logging must never capture raw credential values
- `.env` is gitignored — `.env.example` with placeholders is committed
- `secrets/` folder is gitignored and listed in `.claude_ignore`
- OAuth-authenticated MCPs require no env var — credential handled via browser flow only
