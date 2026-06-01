# Document Creation Routing Engine
# `.claude/rules/routing-engine.md`
# Vaquero Safety Inc.

**Version:** 1.1.0
**Created:** 2026-05-31
**Updated:** 2026-05-31
**Status:** Active
**Linked Skill Section:** SKILL.md Section 16
**Linked File:** `.claude/rules/obsidian-persistence.md`

---

## PURPOSE

This file governs three decisions that must be made before any output is created in a
Claude Desktop session:

1. **Where does this output get created?** (Claude Desktop vs. Cursor)
2. **Does this output need to persist?** (Obsidian + scaffold save required?)
3. **Should I search before generating?** (Session context vs. Obsidian vs. Firecrawl)

These rules are active from message one in every Claude Desktop session.
They are non-optional. Consult this file before creating anything.

---

## THE THREE-LAYER MODEL

Every output in this project belongs to one of three layers:

```
LAYER 1 — THINKING & PLANNING         → Claude Desktop (this session)
  Strategy, research, analysis, decisions, frameworks, interpretations

LAYER 2 — KNOWLEDGE GRAPH & MEMORY    → Obsidian Brain (Vaquero_Safety_Inc/ folder)
  Persistent, linked, searchable knowledge
  The memory layer Claude Desktop queries on re-entry
  The source of truth for decisions, interpretations, procedures
  Cursor pulls FROM here — Obsidian is never populated BY Cursor

LAYER 3 — IMPLEMENTATION               → Cursor + Claude (integrated)
  Code, automations, schemas, scaffold files
  Always pulls from Obsidian before writing
```

**Rule:** If Cursor will ever need it, it must exist in Obsidian first.
**Rule:** Obsidian is never populated by Cursor. Flow is always Layer 1 → Layer 2 → Layer 3.
**Rule:** All project knowledge notes go under `Vaquero_Safety_Inc/` in the vault.
         The numbered operational folders (00–12) are for daily ops only.

---

## ENGINE 1 — DOCUMENT CREATION ROUTER

### Output Type → Destination Table

| Output Type | Create In | Save To Obsidian | Save To Scaffold |
|---|---|---|---|
| Strategy, positioning, ICP | Claude Desktop | `Vaquero_Safety_Inc/GTM/` | `GTM-Strategy/` |
| Architecture decision | Claude Desktop | `Vaquero_Safety_Inc/Architecture/` | `compliance/ARCHITECTURE-DECISIONS.md` |
| Compliance interpretation | Claude Desktop | `Vaquero_Safety_Inc/Compliance/OHS-Interpretations/` | `compliance/` |
| Regulatory research / mapping | Claude Desktop | `Vaquero_Safety_Inc/Compliance/Regulatory-Changes/` | `compliance/` if matrix-relevant |
| Workflow design (any stage) | Claude Desktop | `Vaquero_Safety_Inc/Workflows/Stage-0N/` | `stages/05_Workflows/` |
| SOP / policy / operating procedure | Claude Desktop | `Vaquero_Safety_Inc/SOPs/` | Client SharePoint on activation |
| Product requirement / user story | Claude Desktop | `Vaquero_Safety_Inc/Product/` | `stages/02_specification/` |
| Decision log entry | Claude Desktop | `Vaquero_Safety_Inc/Decisions/` | `compliance/ARCHITECTURE-DECISIONS.md` if ADR-level |
| Competitive intelligence | Claude Desktop | `Vaquero_Safety_Inc/Competitive/` | `GTM-Strategy/` if actionable |
| Client profile / onboarding context | Claude Desktop | `Vaquero_Safety_Inc/Clients/[client_id]/` | `client-assets/` (read-only) |
| Research / verification output | Claude Desktop | `Vaquero_Safety_Inc/Research/` | `compliance/` if regulatory |
| Source code / automation / schema | Cursor | None required | `src/` or `stages/` |
| Make.com scenario blueprint | Cursor | None required | `stages/05_Workflows/` |
| Scaffold file update | Cursor | None required | Target scaffold path |
| Matrix seed / XLSX output | Cursor | None required | `compliance/` |

### Hard Rules

- **Never combine planning and implementation in a single output** unless explicitly instructed.
- **Never create a scaffold file from Claude Desktop** — generate the artifact, download it, place via Cursor.
- **Never route compliance evidence through Make.com logs** — CEL is the system of record.
- **Cursor always pulls from Obsidian before writing** when the task references existing decisions or architecture.
- **Never place project knowledge notes in numbered operational folders** — always use `Vaquero_Safety_Inc/` subfolders.

---

## ENGINE 2 — WHEN TO USE CURSOR VS. CLAUDE DESKTOP

### Decision Tree

```
Do I need to produce output?
│
├── Is it primarily thinking, analysis, research, planning, or documentation?
│   └── YES → Claude Desktop
│         └── Will this output need to persist beyond this session?
│               ├── YES → Save to Obsidian under Vaquero_Safety_Inc/ (mandatory)
│               │         + scaffold if applicable
│               │         Consult obsidian-persistence.md for note format and path
│               └── NO  → Inline only — document why persistence is not required
│
├── Does it require writing or modifying files in the scaffold?
│   └── YES → Cursor
│         └── Does it require understanding of prior decisions or architecture?
│               ├── YES → Pull relevant Obsidian notes from Vaquero_Safety_Inc/ FIRST,
│               │         then proceed in Cursor
│               └── NO  → Cursor directly
│
└── Does it require BOTH analysis AND implementation?
      └── YES → Phase 1: Claude Desktop (strategy/spec) → Obsidian → Phase 2: Cursor
                Never combine both phases in a single output
                State clearly which phase you are in at session start
```

### Quick Reference

| Task | Tool |
|---|---|
| Draft a new workflow stage | Claude Desktop → `Vaquero_Safety_Inc/Workflows/` → Cursor for implementation |
| Write a Make.com blueprint | Cursor (pull Obsidian workflow note first) |
| Regulatory research and interpretation | Claude Desktop → `Vaquero_Safety_Inc/Compliance/` |
| Update an existing scaffold `.md` file | Cursor |
| Design an alert ladder or approval path | Claude Desktop → `Vaquero_Safety_Inc/Workflows/` |
| Write Python scripts or automation code | Cursor |
| Create a compliance matrix (XLSX) | Cursor (using openpyxl) |
| Write an ADR entry | Claude Desktop → `Vaquero_Safety_Inc/Architecture/` AND scaffold ADR file |
| Draft positioning copy or GTM content | Claude Desktop → `Vaquero_Safety_Inc/GTM/` |
| Onboard a new agency client | Claude Desktop (checklist) → Cursor (scaffold + MCP config) |

---

## ENGINE 3 — SEARCH TRIGGER RULES

Before generating any output, determine whether a search is required first.

### Use Session Context Only (No Search) When:

- The answer exists in SKILL.md, Vaquero_Workflow_Compressed.md, or content already in session
- The task is synthesis, framework creation, or strategic design
- You are making a new decision — not verifying an existing one
- The claim is already in SKILL.md Section 9 (Verified Facts)

### Trigger Obsidian Search (Before Generating) When:

- A prior decision may already exist — check `Vaquero_Safety_Inc/Decisions/`
- You are designing something that builds on existing architecture — check `Vaquero_Safety_Inc/Architecture/`
- You are writing a compliance interpretation — check `Vaquero_Safety_Inc/Compliance/OHS-Interpretations/` first
- You are designing a workflow — check `Vaquero_Safety_Inc/Workflows/Stage-0N/` for prior stage notes
- You are writing GTM content — check `Vaquero_Safety_Inc/GTM/` for positioning decisions already made
- Any output references a prior session deliverable — verify it exists and is current in Obsidian
- Also check numbered overlap folders (02-ARCHITECTURE, 03-DECISIONS, 06-COMPLIANCE) for
  legacy notes that predate the hybrid structure

**Protocol:** Ask the user to query Obsidian for the relevant note before proceeding.
Do not assume prior decisions don't exist. Always verify.

### Trigger Firecrawl / External Research When:

- A regulatory citation needs verification (amendment date, current status, SOR number)
- A VERIFY_REQUIRED flag is open in any compliance matrix
- Competitive intelligence needs current data
- Any regulatory claim you would rate Confidence 1 or 2
- A new regulation is referenced that is not in SKILL.md Section 9

### Never Search When:

- The answer is already in SKILL.md Section 9 (do not re-research confirmed facts)
- The task is creative or strategic synthesis
- Search would produce regulatory hallucination risk — use deterministic Python instead
- The regulatory item is a live COR/NCSO/CRSP credential — deterministic Python only,
  never LLM scoring, never web search substitution

---

## ENGINE 4 — MANDATORY SESSION-END PERSISTENCE CHECK

At the end of every Claude Desktop session that produced a substantive output,
execute this check before closing:

```
PERSISTENCE REVIEW
──────────────────
Save Required:        YES / NO
Reason:               [Why this output should or should not persist]
Obsidian Path:        Vaquero_Safety_Inc/[folder]/[note-title].md
Obsidian Tags:        [From approved tag list in obsidian-persistence.md]
Scaffold Path:        C:\Projects\Vaquero_Safety_Inc\[path] (if applicable)
ADR Required:         YES / NO — [ADR number if yes]
memory-decisions.md:  YES / NO — [Entry required if decision changes business/platform/compliance/architecture/workflow/GTM]
Action:               Create New Note | Update Existing Note | Append Decision Log | No Action Required
```

This block is non-optional when the session produced any of the following:
a decision, a design, an interpretation, a framework, a procedure, or a competitive insight.

---

## ROUTING EXCEPTIONS — ESCALATION RULE

If an output simultaneously:
- References more than three existing scaffold files, AND
- Must maintain consistency across multiple folders, AND
- Will become a permanent system artifact

→ Route to Cursor. Do not create in Claude Desktop.
→ State "CURSOR REQUIRED" and provide the full file path before generating.

---

## FILE PLACEMENT CROSS-REFERENCE

This engine uses and enforces the placement rules defined in SKILL.md Section 6.
In case of conflict, SKILL.md Section 6 governs.
In case of gap (output type not listed in Section 6), this engine governs.
Unresolvable conflicts → ask before proceeding.

---

## VERSION HISTORY

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2026-05-31 | Initial creation |
| 1.1.0 | 2026-05-31 | Updated all Obsidian paths to Vaquero_Safety_Inc/ hybrid structure; added rule against placing project knowledge in numbered folders; updated search trigger rules to check both Vaquero_Safety_Inc/ and legacy overlap folders |
