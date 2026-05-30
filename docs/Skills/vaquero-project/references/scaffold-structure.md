# Vaquero Scaffold Structure — Full Layer Reference

Source document: `Project-Folder-Architecture.docx` v1.1.0
Compliance: PIPEDA/PIPA | Canada Central data residency | All layers active

---

## Layer 0 — Identity & Global Routing

```
PROJECT-ROOT/
├── CLAUDE.md          ⬆ LOAD — Global identity map. AI loads FIRST every session.
│                               Links to: CONTEXT.md, _config/voice.md,
│                               _config/tech-standards.md,
│                               docs/llm-guardrails/SYSTEM_PROMPT_GUARDRAILS.md,
│                               stages/ index. RFC 2119 verbs. Semver-tagged.
├── CONTEXT.md         ⬆ LOAD — Master task router. Maps every task type → correct
│                               stage folder + reference files. Read before touching
│                               any file.
├── README.md                 — Human-readable overview. NOT for AI instruction.
└── .gitignore                — Excludes: .env, .env.*, logs/, outputs/*, *.key, secrets/
```

---

## Layer 1 — AI Instruction & Rules

```
├── .claude/
│   └── rules/
│       ├── global.md          ⬆ LOAD — Core constraints: Zero Guess Rule,
│       │                               Triple-Check Policy, confidence 1-3,
│       │                               no PII output, no hallucinated regulations.
│       ├── memory-decisions.md       — Immutable append-only decision log.
│       │                               Format: [DATE] DECISION | RATIONALE |
│       │                               LINKED FILE. Never delete.
│       └── path-scopes.md            — Maps folder paths to scoped rule sets.
├── .claude_ignore                    — Files Claude must NEVER read or index:
│                                       .env, secrets/, logs/, node_modules/,
│                                       dist/, .git/
└── .cursor/                          — Editor config only. No AI instructions.
```

---

## Layer 2 — Persistent Reference (The Factory)

*Changes here cascade everywhere — treat like a schema change.*

```
├── _config/
│   ├── voice.md          ⬆ LOAD — Brand voice, tone, prohibited phrases.
│   │                               Load before ANY copy, email, or UI text.
│   ├── design-system.md  ⬆ LOAD — UI/UX tokens, component patterns, typography.
│   │                               Load before ANY frontend code.
│   └── tech-standards.md ⬆ LOAD — Coding conventions, API-first rules, naming
│                                   standards, forbidden patterns. Semver-tagged.
```

---

## Layer 3 — Compliance & Security Architecture

*Load `compliance/COMPLIANCE.md` and `compliance/DATA_LIFECYCLE.md` before any
code touching user data or regulatory logic.*

```
├── compliance/
│   ├── COMPLIANCE.md          ⬆ LOAD — Master regulatory map: PIPEDA/PIPA/GDPR
│   │                                   table, Data Classification Matrix
│   │                                   (Restricted/Confidential/Public), Canada
│   │                                   Central residency lock, Safety Credentials
│   │                                   Guard, AER/OHS Firecrawl schedule.
│   │                                   RFC 2119 verbs. Semver. Live Mermaid.js.
│   ├── ARCHITECTURE-DECISIONS.md     — Append-only ADR log.
│   │                                   Format: [DATE] | DECISION | COMPLIANCE
│   │                                   JUSTIFICATION | ROLLBACK PLAN. Never delete.
│   ├── DATA_LIFECYCLE.md             — Live Mermaid.js data flow diagrams.
│   │                                   Retention schedules. Cryptographic deletion
│   │                                   protocols.
│   └── THREAT_MODEL.md               — Attacker personas, mitigation mapping to
│                                       file:line references, residual risk log.
│                                       Update every sprint where attack surface changes.
```

---

## Layer 4 — LLM Guardrails & AI Execution Controls

*Load before every compliance or data task. Linked from CLAUDE.md.*

```
├── docs/llm-guardrails/
│   ├── SYSTEM_PROMPT_GUARDRAILS.md  ⬆ LOAD — Zero-hallucination rules: no invented
│   │                                          OHS sections, citation constraint
│   │                                          (URL or section code required), PIPA
│   │                                          PII masking protocol, Firecrawl
│   │                                          ambiguity fallback.
│   ├── CRITICAL_THINKING_SCRIPTS.md ⬆ LOAD — Triple-Check verification loop.
│   │                                          Confidence score 1-5; trigger human
│   │                                          review if <5. Run before every
│   │                                          compliance output.
│   └── AUTO_DEBUGGING_RUNBOOK.md            — Firecrawl/PageCrawl fail-safe.
│                                              403/429 handler → Langfuse log →
│                                              revert to cached pgvector embedding
│                                              → user warning banner.
│                                              Activate at months 4-5.
```

---

## Layer 5 — Go-To-Market & Strategy

*Load ONLY for positioning, copy, outreach, or persona tasks.
NEVER load during implementation stages.*

```
├── GTM-Strategy/
│   ├── Strategy.md            ⬆ LOAD — GTM blueprint: beachhead market, wedge
│   │                                   strategy, distribution leverage.
│   ├── ICP-profiles/                 — One file per persona. Load for copy,
│   │                                   onboarding flows, lead scoring logic.
│   └── Messaging-Frameworks/         — Email copy variants, competitive
│                                       differentiators, objection handling.
```

---

## Layer 6 — Execution Stages

*Sequential build pipeline. Always read the stage CONTEXT.md before beginning
any task in that stage. output/ artifacts are immutable once stage closes.*

```
├── stages/
│   ├── 01_discovery/
│   │   ├── CONTEXT.md    ⬆ LOAD — Links: Business-Goals.md, compliance scope
│   │   ├── Business-Goals.md     — Revenue targets, strategic milestones.
│   │   │                           Strategic context only — not for code gen.
│   │   └── output/               — Immutable once stage closes.
│   │
│   ├── 02_specification/
│   │   ├── CONTEXT.md    ⬆ LOAD — Links: Specs.md, output/01_discovery,
│   │   │                          _config/tech-standards.md
│   │   ├── Specs.md      ⬆ LOAD — Single source of truth for feature scope.
│   │   │                          Always refer here before implementation.
│   │   ├── references/           — Competitor analysis, user research,
│   │   │                           regulatory constraints per feature.
│   │   └── output/
│   │
│   ├── 03_implementation/
│   │   ├── CONTEXT.md    ⬆ LOAD — Links: _config/design-system.md,
│   │   │                          _config/tech-standards.md,
│   │   │                          compliance/COMPLIANCE.md
│   │   │                          Load all three before generating any code.
│   │   └── output/
│   │
│   ├── 04_architecture/
│   │   ├── CONTEXT.md    ⬆ LOAD — Links compliance/ARCHITECTURE-DECISIONS.md
│   │   ├── System-Diagram.md     — Live Mermaid.js flowcharts and tool maps.
│   │   │                           No static image links. Anonymized — no real
│   │   │                           IPs, server names, or employee identifiers.
│   │   └── output/
│   │
│   └── 05_workflows/
│       ├── CONTEXT.md    ⬆ LOAD — Load AGENTS.md before building or modifying
│       │                          any workflow in this stage.
│       ├── AGENTS.md     ⬆ LOAD — Scoped behavioural logic. Modular — one
│       │                          AGENTS.md per major workflow. Defines: allowed
│       │                          tool calls, forbidden actions, escalation
│       │                          triggers, human-in-the-loop checkpoints.
│       │                          NEVER merge into global CLAUDE.md.
│       ├── make-workflows/       — Exported Make.com scenario blueprints.
│       │                           Filename: [scenario-name]_v[semver].json
│       └── output/
```

---

## Layer 7 — Scripts & Automation

*When a script file is referenced: RUN it via bash. Do NOT read or paraphrase.
Execute and return the output. Add this rule to every CONTEXT.md referencing scripts/.*

```
├── scripts/
│   ├── setup-mcp.sh          ▶ RUN — MCP server bootstrap. Run on env init.
│   ├── verify-compliance.py  ▶ RUN — Safety Credentials Guard. MUST run before
│   │                                  any output involving COR/NCSO/CRSP.
│   │                                  No LLM scoring permitted as substitute.
│   ├── firecrawl-sync.py     ▶ RUN — AER/OHS regulatory data pull. Schedule in
│   │                                  compliance/COMPLIANCE.md. Logs to logs/scrape/.
│   │                                  On failure: triggers AUTO_DEBUGGING_RUNBOOK.md.
│   └── helpers/                     — Custom utility scripts. Each file requires
│                                      header: PURPOSE, INPUTS, OUTPUTS, DEPENDENCIES.
│
└── logs/   ⊘ GITIGNORE              — Script output, test outputs, Langfuse traces.
                                        Subdirs: logs/scrape/, logs/tests/, logs/agents/
                                        Auto-purge schedule in DATA_LIFECYCLE.md.
```

---

## Layer 8 — Marketing & Lead Generation

*Load `GTM-Strategy/Strategy.md` and `ICP-profiles/` before working here.
Load `_config/voice.md` before generating any content.*

```
├── marketing/
│   ├── lead-gen/                    — Lead gen workflows. Make.com scenario blueprints:
│   │                                  lead-gen_v[semver].json
│   └── content/                     — Campaign copy, blog drafts, ad variants.
```

---

## Layer 9 — Operations & CRM

```
├── operations/
│   ├── CRM-sync/                    — CRM integration logic and field mapping.
│   │                                  Reference ICP-profiles/ for field definitions.
│   │                                  Load AGENTS.md from 05_workflows/ before
│   │                                  modifying sync logic.
│   └── agent-tasks.md               — Format: TASK | AGENT_SCOPE |
│                                       LINKED_SCRIPT | HUMAN_CHECKPOINT
```

---

## Layer 10 — Source Code

*Load `_config/tech-standards.md` and `_config/design-system.md` before touching
any file here. Subdirectories mirror `stages/04_architecture/System-Diagram.md`.*

```
├── src/
│   └── gtm-automation/              — Load corresponding AGENTS.md from
│                                      stages/05_workflows/ and GTM-Strategy/
│                                      Strategy.md before modifying.
```

---

## Layer 11 — Client Assets & Secrets

```
├── client-assets/  — PDFs, brand guides, transcripts, client files.
│                     Read-only reference. Never AI-modified without
│                     explicit user instruction.
├── secrets/        ⊘ GITIGNORE — API keys, credentials. NEVER committed.
│                                  Listed in .claude_ignore and .gitignore.
└── .env            ⊘ GITIGNORE — Real .env in .gitignore and .claude_ignore.
                                   Commit .env.example with placeholders ONLY.
                                   Confirm Canada Central endpoints here.
```

---

## Layer 12 — CI/CD & Automation Hooks

```
└── .github/
    ├── workflows/
    │   ├── compliance-check.yml  — Validates compliance/*.md semver and
    │   │                           RFC 2119 verbs before every deploy.
    │   ├── markdown-lint.yml     — Pre-commit hook.
    │   └── env-scan.yml          — Blocks commits containing real credentials.
    └── prompts/                  — Mirror of docs/llm-guardrails/.
                                    CLAUDE.md points to docs/llm-guardrails/
                                    as canonical — not both locations.
```

---

## File Naming Conventions

| Type | Convention |
|------|-----------|
| Make.com scenario blueprints | `[scenario-name]_v[semver].json` |
| Versioned documents | Semver-tagged in frontmatter (v1.0.0) |
| Stage output artifacts | Immutable once stage closes |
| Script headers | PURPOSE, INPUTS, OUTPUTS, DEPENDENCIES |
| Decision log entries | `[DATE] \| DECISION \| RATIONALE \| LINKED FILE \| COMPLIANCE RULE` |

---

*All infrastructure details in this document are anonymized per compliance/COMPLIANCE.md §7.
No real server names, IPs, or credentials appear here.*
