---
name: vaquero-safety-inc
description: >
  Master context skill for the Vaquero Safety Inc. project. Load this skill
  before ANY task involving: scaffold navigation, file placement, credential
  handling, MCP configuration, compliance matrix work, regulatory research,
  agent workflow design, client onboarding, Firecrawl operations, Supabase
  queries, Make.com automation, DocuSign workflows, SharePoint integration,
  or any code generation within C:\Projects\Vaquero_Safety_Inc\.
  Also triggers when the user references: stage folders, CONTEXT.md, AGENTS.md,
  compliance docs, Windows environment variables, MCP namespacing, Cursor IDE
  configuration, OHS credentials, COR/NCSO/CRSP, the compliance matrix (any
  industry), firecrawl-sync.py, verify-compliance.py, CEL (Compliance Event
  Log), SOP propagation, certification alert ladders, DocuSign envelope
  workflows, SharePoint site-per-client architecture, or Make.com scenarios.
  Do NOT load for generic coding questions unrelated to this project scaffold.
version: 2.0.0
last_updated: 2026-05-26
---

# Vaquero Safety Inc. — Master Project Skill

---

## HOW THIS SKILL WORKS IN CLAUDE.AI

This skill runs inside a Claude.ai Project. There is no `CLAUDE.md` load
sequencing here. This SKILL.md IS the persistent context layer. It is
loaded automatically for every session in this project.

**What this means operationally:**
- All rules in this file are active from message one — no explicit load command needed
- Paste `compliance/MATRIX_INSTRUCTIONS_MASTER.md` + industry file at session start for matrix work
- The `Vaquero_Workflow_Compressed.md` is the authoritative reference for all 9 automation stages
- For new sessions requiring both, paste both files — Claude.ai project memory carries SKILL.md context persistently

**Claude.ai vs Cursor differences to observe:**
- No subagent parallelism — multi-step tasks run sequentially
- No terminal access — script outputs must be run locally and results pasted back
- Artifacts (code, documents) are generated in-chat and downloaded by the user
- AI-powered artifacts can call the Anthropic API directly (see Section 13)

---

## 1. Environment Root

**All paths use Windows root:** `C:\Projects\Vaquero_Safety_Inc\`

- NEVER use `~`, `/home/`, or `C:\Users\` paths
- Use Windows path separators (`\`) except in WSL, Git Bash, or Docker contexts
- If a subfolder path is ambiguous, ask before generating a command or file

---

## 2. Credential Architecture

### Source of Truth by Credential Type

| Credential Type | Storage Location | Access Pattern |
|----------------|-----------------|----------------|
| Firecrawl API key | Windows **System** Environment Variables ONLY | `os.environ.get("FIRECRAWL_API_KEY")` |
| Firecrawl operational config | Windows **System** Environment Variables | See table below |
| Cursor MCP tokens | Windows **System** Environment Variables | `%CURSOR_MCP_[NAME]%` syntax |
| Supabase URL + Key | `.env` file | `os.environ.get("SUPABASE_URL")` |
| All other project secrets | `.env` file | `os.environ.get("VAR_NAME")` |
| OAuth-based MCPs (PageCrawl) | Browser OAuth flow | No env var required |

### Firecrawl Environment Variables — All in System (not User)

```
FIRECRAWL_API_KEY                    [your key]
FIRECRAWL_CREDIT_CRITICAL_THRESHOLD  500
FIRECRAWL_CREDIT_WARNING_THRESHOLD   2000
FIRECRAWL_RETRY_BACKOFF_FACTOR       3
FIRECRAWL_RETRY_INITIAL_WAIT_MS      2000
FIRECRAWL_RETRY_MAX_ATTEMPTS         5
FIRECRAWL_RETRY_MAX_WAIT_MS          30000
```

**CRITICAL:** If `FIRECRAWL_API_KEY` exists in both User and System variables,
User takes priority and silently overrides System. Remove from User — System only.

### MCP Token Naming Convention

```
%CURSOR_MCP_VAQUERO%       ← Vaquero Supabase token
%CURSOR_MCP_CLIENT_A%      ← Agency client A (future)
%CURSOR_MCP_CLIENT_B%      ← Agency client B (future)
```

### Active MCP Servers (`~/.cursor/mcp.json`)

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
      "args": ["/c", "npx", "-y", "@pagecrawl/mcp-server"]
    }
  }
}
```

Rules:
- Always use `cmd /c` wrapper — raw `npx` fails on Windows
- All servers under a single `"mcpServers": {}` block — multiple root objects cause silent failure
- New agency clients: add `supabase-[clientname]` entry + restart Cursor to activate
- Tokens NEVER in `args[]` as hardcoded strings — always via `%ENV_VAR%` reference

---

## 3. Scaffold Architecture — Layer Reference

| Layer | Folder | Purpose |
|-------|--------|---------|
| 0 | `/` root | `CONTEXT.md` (task router) |
| 1 | `.claude/rules/` | `global.md` (Zero Guess, Triple-Check), `memory-decisions.md` (append-only), `path-scopes.md` |
| 2 | `_config/` | `voice.md`, `design-system.md`, `tech-standards.md` — changes cascade everywhere |
| 3 | `compliance/` | `COMPLIANCE.md`, `ARCHITECTURE-DECISIONS.md`, `DATA_LIFECYCLE.md`, `THREAT_MODEL.md` |
| 4 | `docs/llm-guardrails/` | `SYSTEM_PROMPT_GUARDRAILS.md`, `CRITICAL_THINKING_SCRIPTS.md`, `AUTO_DEBUGGING_RUNBOOK.md` |
| 5 | `GTM-Strategy/` | Load ONLY for positioning/copy/outreach/persona tasks. Never during implementation. |
| 6 | `stages/01–05/` | Sequential build pipeline — each stage has own `CONTEXT.md` and `output/` |
| 7 | `scripts/` | Must be executed locally — paste output back into chat for Claude to process |
| 8 | `marketing/` | Load `voice.md` before any content generation |
| 9 | `operations/` | CRM sync, agent tasks |
| 10 | `src/` | Load `tech-standards.md` + `design-system.md` before touching any source file |
| 11 | `client-assets/`, `secrets/`, `.env` | Read-only assets; gitignored credentials |
| 12 | `.github/` | CI/CD — `compliance-check.yml`, `markdown-lint.yml`, `env-scan.yml` |

**In Claude.ai:** When working on tasks that reference a specific layer, paste the
relevant `CONTEXT.md` or config file at session start if needed. Claude cannot
read files from your local filesystem directly.

---

## 4. Critical Operating Rules

### Rule 1 — Script Execution (Claude.ai Adaptation)
Files in `scripts/` cannot be executed directly in Claude.ai. Generate the
script, provide it as a downloadable artifact, and instruct the user to run it
locally and paste the output back. Never paraphrase what a script "would" output.

### Rule 2 — Safety Credentials Guard ⚠
`scripts/verify-compliance.py` MUST execute before ANY output involving
COR, NCSO, or CRSP certifications. LLM scoring of safety credentials is
**absolutely prohibited** — deterministic Python verification only.
In Claude.ai: generate the script, have the user run it, paste results back.

### Rule 3 — Zero Guess Rule
Never speculate on regulatory content. If data is ambiguous, output:
`[ERROR: REGULATORY_DATA_AMBIGUOUS. Manual intervention required.]` and halt.

### Rule 4 — No SOR Invention
Never cite a regulation number (SOR, Alta Reg, O.Reg, etc.) that has not
been confirmed from an official source. Flag uncertain citations as:
`[VERIFY_REQUIRED — SOR number unconfirmed]`

### Rule 5 — Triple-Check Policy
Before any final answer, code, or recommendation:
1. Verify factual accuracy against source material provided
2. Check for logical inconsistencies
3. Review against potential edge cases

### Rule 6 — Confidence Ratings Required
Every technical or regulatory claim requires a confidence rating:
- `3 — Verified`: Supported by stable, well-documented official source
- `2 — Probable`: Structurally sound; requires live URL/date verification
- `1 — Hypothetical`: Placeholder; manual research required before any use

### Rule 7 — Correction Flagging
If a prior entry is discovered to be wrong, prefix the corrected cell or
content with `⚠ CORRECTION:` — never silently overwrite.

### Rule 8 — Append-Only Logs
`memory-decisions.md` and `ARCHITECTURE-DECISIONS.md` are append-only.
Format: `[DATE] | DECISION | RATIONALE | LINKED FILE | COMPLIANCE RULE`

### Rule 9 — AGENTS.md Modularity
Each workflow in `stages/05_workflows/` has its own `AGENTS.md`.
Never merge agent logic into a global file.

### Rule 10 — No Overbuilding
Challenge complexity at every step. Lean infrastructure first.
Do not build platform before product.

### Rule 11 — No Hardcoded Credentials (Claude.ai Artifact Standard)
When generating code artifacts in Claude.ai:
- NEVER hardcode API keys, tokens, or secrets in generated code
- NEVER use placeholders like `YOUR_API_KEY` in source code
- Project API key and base URL: injected at runtime via Windows R command input
- All other secrets: load via `os.environ.get("VAR_NAME")` from `.env`
- Audit logging must never capture raw credential values

### Rule 12 — CEL Is the System of Record
Make.com operational logs expire in 60 days and are NOT compliance evidence.
Every compliance event must write a CEL (Compliance Event Log) entry to
SharePoint at the time of the event. This is non-negotiable across all stages.

---

## 5. Compliance Jurisdiction

- **Primary**: PIPEDA / PIPA (Alberta)
- **Data residency**: Canada Central (confirmed at SharePoint site provisioning)
- **Safety credentials**: COR / NCSO / CRSP — deterministic Python verification only
- **Regulatory data source**: AER / OHS via Firecrawl — schedule in `compliance/COMPLIANCE.md`
- **Key compliance rules**: `compliance/COMPLIANCE.md` + `compliance/DATA_LIFECYCLE.md`

---

## 6. File Placement Rules

| Content Type | Location |
|-------------|----------|
| Global AI rules | `.claude/rules/` |
| Brand/tech/design constants | `_config/` |
| Regulatory documents + compliance matrix files | `compliance/` |
| Stage deliverables | `stages/0N_[name]/output/` |
| Workflow agent logic | `stages/05_workflows/` with own `AGENTS.md` |
| Automation scripts | `scripts/` or `scripts/helpers/` |
| Source code | `src/` |
| Client files | `client-assets/` (read-only; never AI-modified without explicit instruction) |
| Credentials | `secrets/` or `.env` (gitignored; never committed) |

If placement is ambiguous — ask before creating.

---

## 7. Compliance Matrix — Current Status

### Completed

| File | Version | Status |
|------|---------|--------|
| `compliance/Vaquero_OilGas_Compliance_Matrix_v1.7.0.xlsx` | v1.7.0 | Production — 0 open items |
| `compliance/REGULATORY_MATRIX_SEED_OIL_GAS.md` | v1.0.0 | Complete reference |

**Oil & Gas matrix contains:**
- Sheet A: Regulatory Authority — all 13 provinces/territories
- Sheet B: 80+ credential entries — H2S Alive, COR, NCSO, CRSP, First Aid, WHMIS,
  TDG, Fall Protection, Confined Space, Ground Disturbance, all trade licences,
  Power Engineers, Crane, Gas Fitter, Offshore HUET/BOSIET/CoP-TQOP, Rig Technician
- Sheet C: 20 federal overlay entries — CLC Part II, CER/OPR, COGOA, C-NLOPB/CNSOPB,
  TDG, NSC/HOS/ELD, WHMIS GHS Rev 7/8, CEPA/Bill S-5, IAA/SCC 2023 ruling,
  Duty to Consult/UNDRIP/Kebaowek 2025, Fisheries Act, GGPPA/fuel charge,
  Methane Regulations SOR/2025-280, Clean Electricity SOR/2024-263, Bill C-59
- Sheet D: Verify Required Tracker — 22 CLOSED / 12 PARTIAL / 0 OPEN
- Sheet E: CORA National Registry — 31 CORAs, all provinces

### To Be Built

| Industry | Instruction File | Output File |
|----------|-----------------|-------------|
| Construction | `compliance/MATRIX_INSTRUCTIONS_CONSTRUCTION.md` | `Vaquero_Construction_Compliance_Matrix_v1.0.0.xlsx` |
| Logging / Forestry | `compliance/MATRIX_INSTRUCTIONS_LOGGING.md` | `Vaquero_Logging_Compliance_Matrix_v1.0.0.xlsx` |
| Commercial Trucking | `compliance/MATRIX_INSTRUCTIONS_TRUCKING.md` | `Vaquero_Trucking_Compliance_Matrix_v1.0.0.xlsx` |

**Master instructions:** `compliance/MATRIX_INSTRUCTIONS_MASTER.md`

### Starting a New Industry Matrix Session (Claude.ai)

Paste into the new chat at session start:
1. This `SKILL.md`
2. `compliance/MATRIX_INSTRUCTIONS_MASTER.md`
3. `compliance/MATRIX_INSTRUCTIONS_[INDUSTRY].md`

Opening prompt:
```
Build the Canadian OHS Compliance Matrix for [INDUSTRY] following
MATRIX_INSTRUCTIONS_MASTER.md and MATRIX_INSTRUCTIONS_[INDUSTRY].md.
Deliver both XLSX and Markdown seed files. Use Oil & Gas v1.7.0 as
the structural template. Apply all confidence ratings and
VERIFY_REQUIRED flags per the master instructions.
```

---

## 8. Workflow Architecture — Stage Reference

Full detail in `Vaquero_Workflow_Compressed.md`. This section provides quick
lookup for task routing. When building or debugging any stage, paste the
compressed workflow doc at session start.

### Stage Map

| Stage | Name | Key Output | CEL Required |
|-------|------|-----------|--------------|
| 1 | Client Onboarding | SharePoint site, MSA, Signatories List, Gap Assessment | Yes |
| 2 | Document Ingestion & Indexing | Classified + metadata-stamped doc in SharePoint | Yes |
| 3 | Regulatory & Certification Monitoring | Alert triggers, Regulatory Change Candidates | Yes |
| 4 | Push Notification & Approval Loop | Notification record, response/amendment chain | Yes |
| 5 | DocuSign Execution | Signed PDF + Certificate archived to SharePoint | Yes |
| 6 | SOP Propagation | Updated SOP active across all affected clients | Yes |
| 7 | Asset & Inspection Compliance | Asset Registry updates, fail/return-to-service | Yes |
| 8 | Chemical, SDS & Environmental | SDS index, environmental flags (all TEMPORARY) | Yes |
| 9 | Audit Trail & Reporting | CEL queries, COR Evidence Package, recurring reports | Yes |

### Human-Only Gates (Cannot Be Automated)

| Gate | Stage | Role |
|------|-------|------|
| Regulatory change classification | 3 | Compliance advisor |
| SOP base template approval | 6 | Senior compliance professional |
| Onboarding completion | 1 | Compliance advisor |
| Baseline gap assessment | 1 | Compliance advisor |
| Return-to-service after failed inspection | 7 | Compliance advisor |
| COR evidence package certification | 9 | Compliance advisor |
| Non-response formal notice (T+21) | 4 | Compliance advisor + authorized officer |
| DocuSign signatory change authorization | 5 | Compliance advisor |

### Key Workflow Constants

- **Approval model**: Approve/Amend only — no Reject path exists
- **Signing order**: Safety Manager (Order 1) → Executive (Order 2) — role sequence, not individual
- **Signatories**: Stored by role in Signatories List — looked up at envelope creation time
- **Client isolation**: One SharePoint site per client; `client_id` is primary key across all systems
- **DocuSign cert legal standing**: Alberta Electronic Transactions Act SA 2001 c E-5.5
- **Environmental submissions**: No automated government submissions — all Stage 8 records flagged `REQUIRES_REVIEW`
- **EPEA verbal reporting**: Client calls 1-800-222-6514; platform records call confirmation as CEL entry only

### Alert Ladder (Certifications and Inspection Deadlines)

| Threshold | Action |
|-----------|--------|
| 90 days | Push to Safety Manager — informational |
| 60 days | Push with Approve/Amend — confirm renewal in progress |
| 30 days | Urgency push; advisor alerted if renewal unconfirmed |
| 7 days | Critical — all channels; advisor calls client |
| T+0 | Status = Expired; COR risk flag if applicable |
| T+7 | Account manager escalation |

### Make.com Implementation Notes

- Dispatcher + child scenario pattern required for 50+ client SOP propagation
- Make.com scenario file naming: `[scenario-name]_v[semver].json`
- Make.com logs are operational only — CEL is compliance system of record
- `client_id` validated before every SharePoint write — never assume correct routing

---

## 9. Key Verified Facts (Do Not Re-Research)

### Regulatory Structure
- **SK OHS**: 1996 Regs REPEALED — current: OHS Regulations 2020 (RRS S-15.1 Reg 10, in force April 1, 2021)
- **MB WSH Act**: Last amended SM 2025, c. 26 (Bill 29 — psychological safety, in force June 3, 2025)
- **YT OHS Act**: RSY 2002 c 159 REPEALED July 1, 2022 — replaced by WSCA
- **QC**: Bill 59 fully in force October 1, 2025 (OIC 1154-2025) — prevention programs mandatory
- **NB OHS Act**: Last amended 2024, c. 5 (June 7, 2024) — citation: SNB 1983, c O-0.2
- **NS OHS Act**: Bill 464 Royal Assent September 20, 2024 — final provisions September 1, 2025
- **NL Offshore**: SOR/2021-247 (in force December 22, 2021) — NL OHS Act does NOT apply offshore
- **NS Offshore**: SOR/2021-248 (in force December 22, 2021; amended November 17, 2022)
- **NT/NU Safety Act**: Last amended SNWT 2023, c. 30 (November 1, 2023); OHS Regs R-090-2024
- **NU**: No standalone Safety Act — uses NWT Safety Act by adoption (current November 2025)

### Federal Instruments
- **SOR/87-612** (Oil and Gas OHS Regs): Last amended SOR/2026-10, January 30, 2026 — NOT repealed
- **SOR/86-304** (Canada OHS Regs): Last amended SOR/2025-79, March 26, 2025
- **SOR/2020-65**: NOT a CER OHS regulation — it is Special Import Measures Regs
- **SOR/2020-148**: NOT an offshore OHS regulation
- **SOR/2019-285** (IAA designated projects): Ruled largely unconstitutional, SCC October 13, 2023 (2023 SCC 23)
- **TDG Regs SOR/2001-286**: Last amended October 25, 2024 (SOR/2023-206 Phase 2)
- **ELD mandate**: In force June 12, 2021; enforcement January 1, 2023; CCMTA Technical Standard v1.3 September 29, 2025
- **GGPPA fuel charge**: Eliminated April 1, 2025 (SOR/2025-107)
- **Methane Regs SOR/2025-280**: Registered December 12, 2025; compliance January 1, 2028
- **Clean Electricity SOR/2024-263**: Registered December 13, 2024; emission restrictions January 1, 2035
- **Bill C-59 greenwashing**: In force June 20, 2024; private right of action June 20, 2025; Final Guidelines June 5, 2025
- **WHMIS/HPR**: Amended December 15, 2022 (GHS Rev 7/8); transition ended December 14, 2025; "WHMIS 2015" name retired

### Credentials
- **ABSA**: Does NOT issue crane operator certificates — scope is pressure equipment only
- **ABSA**: Does NOT administer gas fitter/contractor licences
- **SK Power Engineer**: Issuing body is **TSASK** (established July 1, 2010) — NOT SATCC
- **NCSO**: Issued by **CFCSA** via provincial CORAs (AB=ACSA, ON=IHSA, MB=CSAM, BC=BCCSA) — NOT CSSE
- **COR for O&G (AB/BC/SK)**: Issuing body is **Energy Safety Canada (ESC)** — not provincial construction CORAs
- **COR audit cycle**: 3-year external + annual maintenance (≥80% external; ≥60% maintenance) — confirmed March 1, 2026
- **MB COR for O&G**: No energy/O&G CORA — construction CORAs only (CSAM + WorkSafely)
- **NS Offshore CoP-TQOP**: Updated July 17, 2025 — BST (3yr), HUET/CA-EBS, H2S Awareness, WHMIS, Regulatory Awareness, Offshore Security
- **CRSP verification**: https://bcrsp.ca/en/TemporaryNotification_Search (Jan-Mar renewal caveat applies)
- **H2S Alive**: No name-searchable registry — ESC Certificate Validation Tool: https://www.energysafetycanada.com/Training/Registrations-Certificates/Certificate-Validation
- **SK Electrician lookup**: https://saskapprenticeship.ca/check-credentials/ (launched April 5, 2026)
- **NL Electrician lookup**: https://tradespersonregistry.gov.nl.ca (confirmed June 5, 2025)
- **NB Electrician**: Skilled Trades NB (brand) / NBAOC (legislative name)
- **MB Electrician**: No public registry — email: apprenticeship@gov.mb.ca
- **NS Electrician (NSAA)**: No public open-access lookup — MyCreds + direct contact 902-424-5651
- **QC CCQ Electrician Red Seal**: Challenge exam via CAQP (1 866 393-0067) — exam still required; CCQ card does not auto-carry Red Seal
- **ON Gas Technician portability**: CFTA Reconciliation Agreement November 25, 2025 — ON G1=AB Gas Fitter A; ON G2=AB Gas Fitter B

### Certification Tracking Reference
- **NCSO renewal cycle**: 3-year
- **CRSP renewal cycle**: 5-year / 25 CPD points / March 30 deadline
- **Confined space training retention**: 1 yr (no incident) / 2 yr (incident)
- **CVIP certificates retention**: 3 yr
- **Vehicle maintenance retention**: 3 yr
- **All other OHS default retention**: 5 yr
- **MSA/legal retention**: 7 yr
- **Incident investigation retention**: 2 yr (OHS Act s.33)

### Perplexity Prompt Template (Reuse for Verification Passes)
```
I need verified answers for [N] specific Canadian OHS credential or
regulatory items for the [INDUSTRY] industry. For each, provide:
(a) the exact answer, (b) the direct official URL,
(c) the date the source was last updated or confirmed current.
Only answer from official government or regulatory body sources.

[LIST ITEMS 1-N with province, field, and specific question]
```

---

## 10. firecrawl-sync.py — Key Facts

- **Location**: `C:\Projects\Vaquero_Safety_Inc\scripts\firecrawl-sync.py`
- **Purpose**: Automated verification of VERIFY_REQUIRED items in compliance matrices
- **Trigger**: Run after each seed matrix is generated; quarterly re-verification thereafter
- **Outputs**: `logs/scrape/firecrawl_YYYY-MM-DD.json` + `.md` report
- **Failure protocol**: On scrape failure → `logs/scrape/errors.log` → triggers `AUTO_DEBUGGING_RUNBOOK.md`
- **Rate limit**: 2.0 seconds between requests
- **Supabase push**: Optional — requires `SUPABASE_URL` and `SUPABASE_KEY` in `.env`
- **Result statuses**:
  - `RESOLVED_HIGH_CONFIDENCE` — ≥60% of extract hints matched
  - `RESOLVED_NEEDS_HUMAN_REVIEW` — 30-60% hints matched
  - `UNRESOLVED_MANUAL_REQUIRED` — <30% hints matched
- **Zero Guess Rule applies**: Ambiguous results flagged, never auto-resolved

**In Claude.ai:** Generate or update this script as an artifact. User runs it
locally and pastes output back for analysis.

Required env var wiring (not hardcoded):
```python
FIRECRAWL_API_KEY     = os.environ.get("FIRECRAWL_API_KEY")
CREDIT_WARNING        = int(os.environ.get("FIRECRAWL_CREDIT_WARNING_THRESHOLD", 2000))
CREDIT_CRITICAL       = int(os.environ.get("FIRECRAWL_CREDIT_CRITICAL_THRESHOLD", 500))
RETRY_ATTEMPTS        = int(os.environ.get("FIRECRAWL_RETRY_MAX_ATTEMPTS", 5))
RETRY_INIT_MS         = int(os.environ.get("FIRECRAWL_RETRY_INITIAL_WAIT_MS", 2000))
RETRY_BACKOFF         = int(os.environ.get("FIRECRAWL_RETRY_BACKOFF_FACTOR", 3))
RETRY_MAX_MS          = int(os.environ.get("FIRECRAWL_RETRY_MAX_WAIT_MS", 30000))
```

---

## 11. Coding Standards

- API-first architecture — no hardcoded environment variables ever
- No untyped returns
- Modular, agent-friendly file separation — no monolithic files
- Confidence ratings required on all technical claims
- Triple-Check Policy before any final answer, code, or recommendation
- Script headers required: PURPOSE | INPUTS | OUTPUTS | DEPENDENCIES
- Make.com scenario blueprints: `[scenario-name]_v[semver].json`
- Decision log entries: `[DATE] | DECISION | RATIONALE | LINKED FILE | COMPLIANCE RULE`

**Claude.ai artifact standards:**
- Python scripts: generate as downloadable `.py` files
- Make.com blueprints: generate as `.json` artifacts
- Compliance matrices: generate as `.xlsx` artifacts using openpyxl (no xlrd)
- Markdown seeds: generate as `.md` artifacts
- Always include script header block in generated scripts

---

## 12. Agency Client Model

Vaquero Safety Inc. is the primary project. Additional clients:
- Separate project folders at `C:\Projects\[ClientName]\`
- Separate named MCP server in `mcp.json`: `supabase-[clientname]`
- Separate Windows System Environment Variable: `%CURSOR_MCP_[CLIENTNAME]%`
- Separate SharePoint site provisioned at onboarding (Graph API beta / PnP PowerShell)
- Client files in `client-assets/` — read-only reference only
- Do NOT cross-contaminate credentials or agent logic between clients

New client onboarding checklist:
1. Add Windows System Env Var: `%CURSOR_MCP_[CLIENTNAME]%`
2. Add MCP entry to `~/.cursor/mcp.json`
3. Restart Cursor
4. Provision SharePoint site → populate Signatories List + Contacts List
5. Execute MSA via DocuSign
6. Pre-populate Certification Tracker
7. Conduct gap assessment [human required]
8. Verify: Settings → Tools & Integrations

---

## 13. Claude.ai AI-Powered Artifacts

Claude.ai supports calling the Anthropic API directly from generated artifacts.
Use this capability for interactive compliance tools, verification dashboards,
and regulatory lookup interfaces built for Vaquero internal use.

**When to use:**
- Interactive compliance matrix viewers with filtering/search
- Certification status dashboards that query Supabase via API
- Regulatory change classifiers (advisor-assisted, not autonomous)
- Client-facing onboarding intake forms with validation logic

**API pattern (claude-sonnet-4-20250514, always Sonnet 4):**
```javascript
const response = await fetch("https://api.anthropic.com/v1/messages", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1000,
    messages: [{ role: "user", content: yourPrompt }]
  })
});
```

**Compliance constraints on AI artifacts:**
- Never use AI artifacts for autonomous credential verification — deterministic Python only
- Never use AI artifacts to produce binding regulatory classifications
- All AI artifact outputs touching compliance must display confidence rating
- Regulatory classification artifacts must surface human review gate explicitly
- No credential values, client PII, or CEL data in artifact prompts

**MCP integration in artifacts** (if needed for live Supabase queries):
```javascript
mcp_servers: [{ type: "url", url: "https://...", name: "supabase-vaquero" }]
```
Only include MCP servers the user is actively connected to in Claude.ai.

---

## 14. Skill Update Triggers

**Update and re-upload this SKILL.md when:**
- A new scaffold layer is added
- A new MCP is configured
- A new agency client is onboarded
- A credential naming convention changes
- A new compliance matrix is completed (update Section 7)
- A major regulatory correction is confirmed (update Section 9)
- The Windows environment root changes
- firecrawl-sync.py is materially changed
- A new workflow stage is added or materially revised (update Section 8)
- Claude.ai project structure changes affect load behavior

**Does NOT require update for:**
- New files inside existing scaffold layers
- Content updates to existing `.md` files
- New `AGENTS.md` inside existing workflow folders
- New scripts inside `scripts/helpers/`
- Individual VERIFY_REQUIRED items being resolved in a matrix
- Make.com scenario version bumps within an existing stage

---

*All infrastructure details anonymized per `compliance/COMPLIANCE.md §7`.*
*No real server names, IPs, or credentials appear in this file.*
*Compliance: PIPEDA/PIPA (Alberta) | Canada Central data residency.*
