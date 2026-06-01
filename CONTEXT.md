# CONTEXT.md — Vaquero Safety Inc. Task Router

> This is the entry point for all Cursor and Claude sessions working in this scaffold.
> Read this first. Then load the files listed under your task type.

---

## What This Project Is

Vaquero Safety Inc. — compliance automation platform for Alberta industrial SMBs.
Four industries: Oil & Gas, Construction, Logging/Forestry, Commercial Trucking.
Geographic sequence: Alberta → Western Canada (AB + BC) → Canada-wide.
Platform model: push-only, no client portal, DocuSign execution, CEL audit trail.

Full context: Load `SKILL.md` from project root.
Workflow detail: Load `Vaquero_Workflow_Compressed.md` from project root.

---

## Task Router — Load These Files For Your Task Type

### Compliance Matrix Work
```
SKILL.md
compliance/MATRIX_INSTRUCTIONS_MASTER.md
compliance/MATRIX_INSTRUCTIONS_[INDUSTRY].md
```

### Stage Build or Debug (Make.com / SharePoint / DocuSign)
```
SKILL.md
Vaquero_Workflow_Compressed.md
stages/0N_[stagename]/CONTEXT.md
```

### Regulatory Research
```
SKILL.md (Section 9 — verified facts)
compliance/COMPLIANCE.md
```

### SOP or Document Template Work
```
SKILL.md
Vaquero_Workflow_Compressed.md (Stage 6)
_config/voice.md
```

### Frontend / UI Work
```
_config/design-system.md
_config/tech-standards.md
src/ — relevant component files
```

### GTM / Marketing / Positioning
```
GTM-Strategy/ — load relevant file
_config/voice.md
```

### Architecture Decision
```
compliance/ARCHITECTURE-DECISIONS.md (append only)
SKILL.md (Section 4 — operating rules)
```

### Client Onboarding
```
SKILL.md (Section 12 — agency client model)
Vaquero_Workflow_Compressed.md (Stage 1)
```

---

## Critical Rules — Active Every Session

1. **CEL is the system of record** — Make.com logs are not compliance evidence
2. **Zero Guess Rule** — flag ambiguity, never speculate on regulatory content
3. **No SOR Invention** — never cite unconfirmed regulation numbers
4. **Human gates cannot be automated** — 8 permanent human-only decisions
5. **Approve/Amend only** — no Reject path exists anywhere in the platform
6. **client_id validated before every SharePoint write** — no exceptions
7. **Credentials never hardcoded** — environment variables only (see SKILL.md Section 2)
8. **Push-only model** — no feature requiring daily client login without ADR first

---

## Scaffold Root — Key File Index

| File | Purpose |
|------|---------|
| `SKILL.md` | Master project context — load every session |
| `Vaquero_Workflow_Compressed.md` | All 9 automation stages — load for stage work |
| `CONTEXT.md` | This file — task router |
| `.env` | Non-injected secrets — never committed |
| `compliance/COMPLIANCE.md` | Compliance rules + regulatory monitoring schedule |
| `compliance/ARCHITECTURE-DECISIONS.md` | Append-only ADR log |
| `compliance/DATA_LIFECYCLE.md` | Data retention and lifecycle rules |
| `compliance/THREAT_MODEL.md` | Security threat model |
| `_config/voice.md` | Brand voice constants |
| `_config/design-system.md` | Design tokens and UI standards |
| `_config/tech-standards.md` | Coding and architecture standards |
| `scripts/verify-compliance.py` | Deterministic credential verification — run before any COR/NCSO/CRSP output |
| `scripts/firecrawl-sync.py` | Regulatory source scraper and verification |

---

## Environment Root

All paths: `C:\Projects\Vaquero_Safety_Inc\`
Never use `~`, `/home/`, or `C:\Users\` paths.
Windows separators (`\`) except in WSL, Git Bash, or Docker contexts.
