---
name: vaquero-project
description: >
  Master context skill for the Vaquero Safety Inc. project and its associated AI automation
  agency clients. Load this skill before any task involving: scaffold navigation, file placement,
  credential handling, MCP configuration, compliance logic, agent workflow design, client
  onboarding, or any code generation within C:\Projects\Vaquero_Safety_Inc\. Also triggers when
  the user references stage folders, CLAUDE.md, CONTEXT.md, AGENTS.md, compliance docs,
  Windows environment variables, multi-client MCP namespacing, or Cursor IDE configuration.
  Do NOT load for generic coding questions unrelated to this project scaffold.
---

# Vaquero Safety Inc. — Project Context Skill

## Environment Root

All paths use Windows root: `C:\Projects\Vaquero_Safety_Inc\`
- NEVER use `~`, `/home/`, or `C:\Users\` paths
- Use Windows path separators (`\`) except in WSL, Git Bash, or Docker contexts
- If a subfolder path is ambiguous, ask before generating a command

---

## Credential & MCP Rules

### Credential Source of Truth
- **Project API keys / base URLs**: injected at runtime via Windows R command input — never in files
- **All other secrets**: `.env` file using `os.environ.get()` / `process.env.VAR_NAME`
- **Cursor MCP tokens**: Windows System Environment Variables using `%VAR_NAME%` syntax
- **OAuth-based MCPs**: authenticated via browser OAuth flow — no env var required

### MCP Credential Naming Convention
```
%CURSOR_MCP_VAQUERO%       ← Vaquero Supabase token
%CURSOR_MCP_CLIENT_A%      ← Agency client A
%CURSOR_MCP_CLIENT_B%      ← Agency client B
```
New clients follow the same pattern: `%CURSOR_MCP_[CLIENTNAME]%`
OAuth-authenticated MCPs (e.g. PageCrawl) use no env var — credential handled via browser flow.

### Active MCPs (global `~/.cursor/mcp.json`)
```json
{
  "mcpServers": {
    "supabase-vaquero": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@supabase/mcp-server-supabase@latest",
               "--access-token", "%CURSOR_MCP_VAQUERO%"]
    },
    "sequential-thinking": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "pagecrawl": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@pagecrawl/mcp-server"],
      "note": "OAuth authenticated — no env var required"
    }
  }
}
```
New clients get their own named server entry: `supabase-[clientname]`

### MCP Companion Skills
- `sequential-thinking` → no companion skill required
- `supabase-vaquero` → no companion skill required
- `pagecrawl` → no companion skill required — self-describing via MCP protocol
- Custom-built MCPs → require a companion SKILL.md if tool behavior is not self-describing

---

## Scaffold Architecture — Layer Reference

See `references/scaffold-structure.md` for full Layer 0–12 detail.

### Critical Load Sequencing (AI must follow)
1. `CLAUDE.md` — always first, every session
2. Relevant stage `CONTEXT.md` — before any task in that stage
3. Tagged `⬆ LOAD` files for that task type
4. Compliance tasks additionally require `COMPLIANCE.md` + `SYSTEM_PROMPT_GUARDRAILS.md`

### Layer Summary
| Layer | Folder | Purpose |
|-------|--------|---------|
| 0 | `/` root | Identity & global routing — `CLAUDE.md`, `CONTEXT.md` |
| 1 | `.claude/rules/` | AI instruction rules — global constraints, memory log |
| 2 | `_config/` | Persistent reference — voice, design system, tech standards |
| 3 | `compliance/` | Regulatory map — PIPEDA/PIPA, data lifecycle, threat model |
| 4 | `docs/llm-guardrails/` | LLM execution controls — zero-hallucination, triple-check |
| 5 | `GTM-Strategy/` | Go-to-market — load ONLY for positioning/copy/outreach tasks |
| 6 | `stages/01–05/` | Sequential build pipeline — each has own `CONTEXT.md` |
| 7 | `scripts/` | Automation — RUN don't read; execute and return output |
| 8 | `marketing/` | Lead gen and content — load `voice.md` before generating copy |
| 9 | `operations/` | CRM sync and agent tasks |
| 10 | `src/` | Application source code |
| 11 | `client-assets/`, `secrets/`, `.env` | Assets and credentials — gitignored |
| 12 | `.github/` | CI/CD and automation hooks |

---

## Critical Operating Rules

### 1. Script Execution Rule
Files in `scripts/` MUST be executed via bash — never read or paraphrased.
Return the execution output. This rule applies in every `CONTEXT.md` that references `scripts/`.

### 2. Safety Credentials Guard
`scripts/verify-compliance.py` MUST execute before any output involving COR, NCSO, or CRSP
certifications. LLM scoring of safety credentials is **absolutely prohibited**.

### 3. Zero Guess Rule
Never speculate on regulatory content. If data is ambiguous, output exactly:
`[ERROR: REGULATORY_DATA_AMBIGUOUS. Manual intervention required.]` and halt.

### 4. Append-Only Logs
`memory-decisions.md` and `ARCHITECTURE-DECISIONS.md` are append-only.
Format: `[DATE] | DECISION | RATIONALE | LINKED FILE | COMPLIANCE RULE`

### 5. AGENTS.md Modularity
Each workflow in `stages/05_workflows/` has its own `AGENTS.md`.
Never merge agent logic into global `CLAUDE.md`.

### 6. GTM Isolation
Load `GTM-Strategy/` ONLY for positioning, copy, outreach, or persona tasks.
Never load during implementation stages.

### 7. No Overbuilding
Challenge complexity at every step. Recommend lean infrastructure first.
Sequence complexity intelligently — do not build platform before product.

---

## Compliance Jurisdiction
- **Primary**: PIPEDA / PIPA (Alberta)
- **Data residency**: Canada Central
- **Safety credentials**: COR / NCSO / CRSP — deterministic Python verification only
- **Regulatory data source**: AER / OHS via Firecrawl (schedule in `compliance/COMPLIANCE.md`)

---

## File Placement Rules

When generating any new file, resolve location against this hierarchy:
- Global AI rules → `.claude/rules/`
- Brand/tech/design constants → `_config/`
- Regulatory documents → `compliance/`
- Stage deliverables → `stages/0N_[name]/output/`
- Workflow agent logic → `stages/05_workflows/` with own `AGENTS.md`
- Automation scripts → `scripts/` or `scripts/helpers/`
- Source code → `src/`
- Client files → `client-assets/` (read-only, never AI-modified without explicit instruction)
- Credentials → `secrets/` or `.env` (gitignored, never committed)

If placement is ambiguous, ask before creating the file.

---

## Agency Client Model

Vaquero Safety Inc. is the primary project. Additional clients are managed as:
- Separate project folders at `C:\Projects\[ClientName]\`
- Separate named MCP server entries in global `mcp.json`
- Separate Windows environment variables following `%CURSOR_MCP_[CLIENTNAME]%` convention
- Client-provided files in `client-assets/` — read-only reference only

New client onboarding requires:
1. Add Windows System Environment Variable: `%CURSOR_MCP_[CLIENTNAME]%`
2. Add named MCP entry to `~/.cursor/mcp.json`
3. Restart Cursor to activate
4. Do NOT cross-contaminate client credentials or agent logic

---

## Coding Standards (from `_config/tech-standards.md`)

- API-first architecture
- No hardcoded environment variables — ever
- No untyped returns
- Modular, agent-friendly file separation
- No monolithic files
- Confidence ratings required on all technical claims (1=hypothetical, 2=probable, 3=verified)
- Triple-Check Policy before any final answer, code, or recommendation

---

## Skill Update Triggers

This skill requires re-upload to Claude Project Knowledge when:
- A new scaffold layer is added
- A new MCP is configured
- A new agency client is onboarded
- A credential naming convention changes
- A compliance jurisdiction or regulation is added
- The Windows environment root changes

Does NOT require update for:
- New files created inside existing layers
- Content updates to existing `.md` files
- New `AGENTS.md` inside existing workflow folders
- New scripts inside `scripts/helpers/`
