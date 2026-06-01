# Obsidian Persistence Engine
# `.claude/rules/obsidian-persistence.md`
# Vaquero Safety Inc.

**Version:** 1.1.0
**Created:** 2026-05-31
**Updated:** 2026-05-31
**Status:** Active
**Linked Skill Section:** SKILL.md Section 16
**Linked File:** `.claude/rules/routing-engine.md`

---

## PURPOSE

This file defines:
1. When a Claude Desktop output mandates an Obsidian note
2. The exact structure every Obsidian note must follow
3. The approved vault folder structure for this project
4. The approved tag taxonomy
5. The note linking protocol
6. How to tell the user where to save

Obsidian is the **knowledge graph and memory layer** for Vaquero Safety Inc.
It is the persistent reasoning source that makes every future Claude Desktop session
smarter. It is not a backup drive. It is not optional.

**Non-negotiable rule:** Claude Desktop thinks. Obsidian remembers. Cursor builds.
If Obsidian is not populated, future sessions operate without memory.
That is an operational failure, not an inconvenience.

---

## VAULT STRUCTURE — HYBRID MODEL

The Vaquero-Brain vault uses a **hybrid structure**:

- **Operational folders** (numbered 00–12): daily notes, sprints, meetings, templates,
  inbox, archive — general Obsidian productivity layer. These existed before the
  routing engine was established and are retained as-is.
- **Project knowledge folders** (under `Vaquero_Safety_Inc/`): all decisions,
  designs, interpretations, specs, and compliance knowledge for this project.
  This is the layer the routing engine reads and writes.

**Critical rule:** ALL project knowledge notes go inside `Vaquero_Safety_Inc/`.
Never place project knowledge notes directly in the numbered operational folders.
The numbered folders are for operational use only (daily notes, sprint tracking,
meeting notes, feature tracking). If in doubt, the note goes in `Vaquero_Safety_Inc/`.

### Operational Folders (Do Not Route Project Knowledge Here)

| Folder | Purpose | What Goes Here |
|---|---|---|
| `00-INBOX/` | Capture anything unprocessed | Temporary notes, raw Claude outputs pending review |
| `01-CONTEXT/` | Session context files | `CLAUDE.md`, `PROJECT-OVERVIEW.md`, `TECH-STACK.md`, `CURRENT-SPRINT.md` |
| `02-ARCHITECTURE/` | **Overlap zone — see rule below** | ADR mirrors also live here for backward compatibility |
| `03-DECISIONS/` | **Overlap zone — see rule below** | Decision log entries also live here for backward compatibility |
| `04-SPRINTS/` | Sprint planning and tracking | Sprint plans, velocity notes |
| `04-Templates/` | Legacy template location | Superseded by `11-TEMPLATES/` |
| `05-FEATURES/` | Feature tracking | Feature cards, user story notes |
| `06-COMPLIANCE/` | **Overlap zone — see rule below** | Compliance reference notes also live here |
| `07-OPERATIONS/` | Internal operations | CRM notes, process notes |
| `08-MEETINGS/` | Meeting notes | All meeting records |
| `09-RESEARCH/` | General research | Non-project-specific research |
| `10-CLIENTS/` | Client notes | Non-Vaquero client notes only |
| `11-TEMPLATES/` | Active Templater templates | All note templates |
| `12-ARCHIVE/` | Superseded notes | Never delete — move here when superseded |

### Overlap Zone Rule

Three operational folders overlap with project knowledge categories:
- `02-ARCHITECTURE/` ↔ `Vaquero_Safety_Inc/Architecture/`
- `03-DECISIONS/` ↔ `Vaquero_Safety_Inc/Decisions/`
- `06-COMPLIANCE/` ↔ `Vaquero_Safety_Inc/Compliance/`

**Rule for overlap zones:** New notes always go in `Vaquero_Safety_Inc/` subfolder.
Existing notes in numbered folders are valid — do not move them, do add backlinks
from the `Vaquero_Safety_Inc/` note to the numbered-folder note where relevant.
Over time, the `Vaquero_Safety_Inc/` folders become the canonical location.

---

## MANDATORY OBSIDIAN NOTE TRIGGERS

A note MUST be created when any of the following are produced in a session:

| Trigger | Vault Path | Note Type |
|---|---|---|
| Architecture decision finalized | `Vaquero_Safety_Inc/Architecture/` | Decision note + ADR link |
| Regulatory interpretation established | `Vaquero_Safety_Inc/Compliance/OHS-Interpretations/` | Interpretation note |
| Regulatory change classified | `Vaquero_Safety_Inc/Compliance/Regulatory-Changes/` | Change record note |
| Workflow stage designed or materially changed | `Vaquero_Safety_Inc/Workflows/Stage-0N/` | Workflow note |
| SOP or operating procedure created | `Vaquero_Safety_Inc/SOPs/` | Procedure note |
| Human gate or escalation path defined or changed | `Vaquero_Safety_Inc/Workflows/` | Gate note |
| Product requirement locked | `Vaquero_Safety_Inc/Product/` | Requirement note |
| Competitive intelligence captured | `Vaquero_Safety_Inc/Competitive/` | Intelligence note |
| GTM decision made (positioning, ICP, pricing) | `Vaquero_Safety_Inc/GTM/` | Strategy note |
| Vendor or tool decision made | `Vaquero_Safety_Inc/Architecture/` | Decision note |
| New compliance matrix section completed | `Vaquero_Safety_Inc/Compliance/Matrix-Notes/` | Matrix note |
| New agency client onboarded | `Vaquero_Safety_Inc/Clients/[client_id]/` | Client note |
| ADR appended to scaffold | `Vaquero_Safety_Inc/Architecture/` | ADR mirror note |
| VERIFY_REQUIRED item resolved | `Vaquero_Safety_Inc/Compliance/Matrix-Notes/` | Resolution note |
| New certification tracking rule established | `Vaquero_Safety_Inc/Compliance/` | Rule note |
| Data lifecycle or retention rule established | `Vaquero_Safety_Inc/Compliance/` | Rule note |
| Financial risk rule established | `Vaquero_Safety_Inc/Compliance/` | Rule note |

### When a Note Is NOT Required

- Routine code generation with no new decisions
- Make.com scenario version bumps with no logic change
- Minor wording edits to existing scaffold files
- VERIFY_REQUIRED items that remain open (flag in matrix only)
- Research that is inconclusive and produces no actionable output

---

## MANDATORY NOTE STRUCTURE

Every Obsidian note created for this project MUST use this structure.
Do not omit fields. If a field does not apply, write `N/A`.

```markdown
---
title: [Descriptive, searchable — no abbreviations]
date: YYYY-MM-DD
status: Draft | Active | Superseded
tags: [from approved tag list below]
linked_adr: ADR-NNN | N/A
scaffold_path: C:\Projects\Vaquero_Safety_Inc\[path] | N/A
supersedes: [[Note Title]] | N/A
superseded_by: N/A (populated later if this note is superseded)
confidence: 1 | 2 | 3
---

## Summary
[2–4 sentences. What was decided, designed, or established. Why it matters.
Write as if the reader has no session context.]

## Detail
[Full content. Enough to fully reconstruct the decision or design without
referring back to the original chat session. Do not summarize away precision.]

## Rationale
[Why this approach. What alternatives were considered and rejected.]

## Compliance Linkage
[Applicable regulation(s), section(s), audit standard(s), or N/A.
Flag with VERIFY_REQUIRED if citation is unconfirmed.]

## Dependencies
[Other notes, scaffold files, or systems this note depends on.]

## Backlinks
[[Note Title]] [[Note Title]]
[List every related note. This is what makes the graph useful.]

## Open Items
- [ ] [Anything still outstanding from this decision or design]

## Change Log
| Date | Change |
|---|---|
| YYYY-MM-DD | Created |
```

---

## APPROVED TAG TAXONOMY

Use only these tags. Do not invent new tags without updating this file.

| Tag | Use For |
|---|---|
| `#decision` | Any finalized decision — architectural, strategic, operational |
| `#architecture` | System design, integration patterns, infrastructure choices |
| `#compliance` | OHS interpretations, regulatory mappings, retention rules |
| `#regulatory` | Regulatory change records, AER/OHS monitoring outputs |
| `#workflow` | Automation stage designs, agent behavior, Make.com logic |
| `#sop` | Operating procedures, policies, client-facing procedures |
| `#product` | Feature definitions, requirements, user flows, specifications |
| `#gtm` | Positioning, ICP, pricing, competitive strategy, messaging |
| `#competitive` | Competitor intelligence, market analysis |
| `#client` | Client-specific notes (no PII — client_id only) |
| `#adr` | Architecture Decision Record mirrors |
| `#research` | Regulatory or market research outputs |
| `#matrix` | Compliance matrix notes, VERIFY_REQUIRED resolutions |
| `#human-gate` | Human-only decision gates and escalation paths |
| `#credential` | Certification tracking rules, issuing body facts |
| `#risk` | Risk assessments, financial risk translation rules |
| `#deferred` | Items explicitly deferred — do not build without ADR |
| `#superseded` | Notes that have been replaced — retain, never delete |

**Multiple tags required** when a note spans categories.
Example: An ADR about a DocuSign workflow change → `#decision #architecture #workflow #adr`

---

## VAULT FOLDER STRUCTURE — COMPLETE MAP

```
Vaquero-Brain/                              ← Vault root
│
├── _SYSTEM/                                ← Vault config (do not touch)
├── 00-INBOX/                               ← OPERATIONAL: capture zone
├── 01-CONTEXT/                             ← OPERATIONAL: session context files
├── 02-ARCHITECTURE/                        ← OPERATIONAL: overlap zone (legacy ADRs)
├── 03-DECISIONS/                           ← OPERATIONAL: overlap zone (legacy decisions)
├── 03-Resources/Compliance/               ← OPERATIONAL: legacy compliance refs
├── 04-SPRINTS/                             ← OPERATIONAL: sprint tracking
├── 04-Templates/                           ← OPERATIONAL: legacy templates
├── 05-FEATURES/                            ← OPERATIONAL: feature tracking
├── 06-COMPLIANCE/                          ← OPERATIONAL: overlap zone (legacy compliance)
├── 07-OPERATIONS/                          ← OPERATIONAL: internal ops
├── 08-MEETINGS/                            ← OPERATIONAL: meeting notes
├── 09-RESEARCH/                            ← OPERATIONAL: general research
├── 10-CLIENTS/                             ← OPERATIONAL: non-Vaquero clients
├── 11-TEMPLATES/                           ← OPERATIONAL: active Templater templates
├── 12-ARCHIVE/                             ← OPERATIONAL: superseded notes
├── 00-Dashboard.md                         ← OPERATIONAL: Dataview dashboard
│
└── Vaquero_Safety_Inc/                     ← PROJECT KNOWLEDGE ROOT (all new notes here)
    │
    ├── Architecture/
    │   ├── [ADR mirror notes]
    │   ├── [System design notes]
    │   └── [Vendor and tool decisions]
    │
    ├── Compliance/
    │   ├── OHS-Interpretations/
    │   │   └── [Regulatory interpretation notes — jurisdiction-specific]
    │   ├── Regulatory-Changes/
    │   │   └── [Change records from AER, OHS, CER monitoring]
    │   ├── Matrix-Notes/
    │   │   └── [Notes per compliance matrix industry — VERIFY_REQUIRED resolutions]
    │   └── [Retention rules, data lifecycle notes, PIPEDA/PIPA notes]
    │
    ├── Workflows/
    │   ├── Stage-01/   ← Client Onboarding
    │   ├── Stage-02/   ← Document Ingestion & Indexing
    │   ├── Stage-03/   ← Regulatory & Certification Monitoring
    │   ├── Stage-04/   ← Push Notification & Approval Loop
    │   ├── Stage-05/   ← DocuSign Execution
    │   ├── Stage-06/   ← SOP Propagation
    │   ├── Stage-07/   ← Asset & Inspection Compliance
    │   ├── Stage-08/   ← Chemical, SDS & Environmental
    │   ├── Stage-09/   ← Audit Trail & Reporting
    │   └── Stage-9X/   ← COR Readiness Score, Compliance Posture, Financial Risk
    │
    ├── GTM/
    │   ├── [Positioning notes]
    │   ├── [ICP definitions]
    │   ├── [Pricing decisions]
    │   └── [Messaging frameworks]
    │
    ├── Product/
    │   ├── [Feature requirement notes]
    │   ├── [User flow notes]
    │   └── [Specification notes]
    │
    ├── SOPs/
    │   └── [Operating procedure notes — internal Vaquero use]
    │
    ├── Decisions/
    │   └── [All decision log entries — append-only, mirrors memory-decisions.md]
    │
    ├── Competitive/
    │   └── [Competitor intelligence — ISNetworld, Avetta, Veriforce, Cognibox, others]
    │
    ├── Clients/
    │   └── [client_id]/
    │       └── [One note per client — no PII, client_id only]
    │
    └── Research/
        └── [Regulatory and market research that informed decisions]
```

**Rule:** Never create project knowledge notes outside `Vaquero_Safety_Inc/` subfolders.
**Rule:** Never delete a note. Superseded notes get `status: Superseded`, `#superseded` tag,
and are moved to `12-ARCHIVE/` in the operational layer.

---

## NOTE LINKING PROTOCOL

Backlinks are not optional decoration. They are what makes the vault useful as a
reasoning source for future sessions.

**Required backlinks:**
- Every workflow note links to the stage it belongs to AND to any regulatory note that drove it
- Every ADR mirror note links to the scaffold ADR file path AND to any affected workflow notes
- Every compliance interpretation note links to any workflow or SOP it affects
- Every decision note links to any prior decision it modifies or supersedes
- Every client note links to the workflow stage notes relevant to their onboarding status
- Notes in `Vaquero_Safety_Inc/` that have related legacy notes in numbered folders
  must backlink to those numbered-folder notes

**Minimum backlinks per note type:**

| Note Type | Minimum Backlinks |
|---|---|
| Architecture / ADR | 2 (affected workflow + prior ADR if superseding) |
| Compliance interpretation | 2 (affected workflow + regulatory source) |
| Workflow note | 2 (stage context note + any driving regulatory/ADR note) |
| Decision | 1 (whatever was decided upon) |
| GTM / Competitive | 1 (related positioning or ICP note) |
| Product requirement | 1 (related workflow or stage note) |

---

## HOW CLAUDE TELLS YOU WHERE TO SAVE

At the end of every session that triggers a mandatory note, Claude will output:

```
OBSIDIAN SAVE REQUIRED
──────────────────────
Note Title:    [Full descriptive title]
Vault Folder:  Vaquero_Safety_Inc/[folder]/
File Name:     [kebab-case-note-title].md
Tags:          #tag1 #tag2 #tag3
Linked Notes:  [[Note Title]] [[Note Title]]
Scaffold Path: C:\Projects\Vaquero_Safety_Inc\[path] (if scaffold save also required)
ADR Required:  YES — ADR-NNN | NO
memory-decisions.md: YES | NO
```

Then Claude will provide the full note content formatted and ready to paste directly
into Obsidian. No reformatting required.

---

## OBSIDIAN + CURSOR INTEGRATION PROTOCOL

When Cursor needs to build something that depends on prior decisions:

1. User opens the relevant Obsidian note(s)
2. User pastes note content into the Cursor session
3. Cursor proceeds with full decision context
4. Cursor does not independently query Obsidian via MCP for decisions — always human-mediated

When Cursor uses the Obsidian MCP server (`obsidian` in `mcp.json`):
- Scope: reading and writing Obsidian template files only
- Scope: updating existing notes when scaffold changes are made
- Never: creating new strategy or compliance notes autonomously
- Never: overwriting notes without surfacing the change to the user first

---

## OBSIDIAN AS PRODUCT KNOWLEDGE CONFIRMATION

**Yes — both this file and `routing-engine.md` belong in Claude Desktop Project Knowledge.**

Rationale:
- These files define how every session operates
- They must be active from message one — same as SKILL.md
- They are not implementation artifacts — they are operating rules
- Loading them in Project Knowledge means they are always present without paste

**Upload both files to Claude Desktop Project Knowledge alongside SKILL.md.**
They form the three-file operating layer for every session in this project.

---

## VERSION HISTORY

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2026-05-31 | Initial creation |
| 1.1.0 | 2026-05-31 | Updated to hybrid vault structure — operational numbered folders retained; project knowledge routed under Vaquero_Safety_Inc/ parent; overlap zone rules added for 02-ARCHITECTURE, 03-DECISIONS, 06-COMPLIANCE |
