# COMPLIANCE.md — Vaquero Safety Inc.

> Compliance rules, regulatory monitoring schedule, and data governance.
> This file governs platform behaviour. Changes require ADR entry.

---

## §1 — Jurisdiction

### Primary
- Alberta OHS Act / OHS Code / OHS Regulation
- PIPA (Alberta) — Personal Information Protection Act
- PIPEDA — Personal Information Protection and Electronic Documents Act

### Phase 2 Addition (Western Canada)
- BC OHS Regulation (WorkSafeBC)
- BC PIPA

### Federal Overlays (All Phases)
- Canada Labour Code Part II
- Canada Energy Regulator Act / OPR
- Transportation of Dangerous Goods Act (TDG) — SOR/2001-286
- WHMIS / Hazardous Products Regulations
- National Safety Code (NSC) — Commercial Trucking
- Hours of Service (HOS) / ELD mandate
- Methane Regulations SOR/2025-280
- Clean Electricity Regulations SOR/2024-263
- Bill C-59 (greenwashing provisions)

---

## §2 — Data Residency

- All SharePoint sites: Canada Central region
- All Supabase instances: Canada region
- No client data transits outside Canada
- Confirm region at every new SharePoint site provisioning

---

## §3 — Compliance Event Log (CEL) Rules

- Written by every automation stage at every compliance event
- SharePoint list per client with Microsoft Purview retention enforcement
- CEL is the legal audit trail — not Make.com operational logs
- Make.com logs expire in 60 days and are never referenced as compliance evidence
- CEL entries are append-only — never modified after creation
- Minimum CEL fields per entry: `event_type`, `client_id`, `timestamp`, `triggered_by`, `outcome`, `stage`

---

## §4 — Document Retention Schedule

| Document Type | Retention Period | Authority |
|---|---|---|
| Incident investigation | 2 years | OHS Act s.33 |
| Confined space training (no incident) | 1 year | OHS Code |
| Confined space training (incident) | 2 years | OHS Code |
| JHSC training | 2 years after leaving JHSC | OHS Code |
| Asbestos training | 10 years | OHS Code |
| CVIP certificates | 3 years | Traffic Safety Act |
| Vehicle maintenance | 3 years | — |
| Trip inspection | 3 months | — |
| All other OHS (default) | 5 years | OHS Regulation |
| MSA / Legal documents | 7 years | — |
| CEL entries | 7 years minimum | Platform standard |

Retention labels enforced via Microsoft Purview at document write time.
No document deleted within retention period under any circumstance.

---

## §5 — Human-Only Decision Gates

These eight decisions cannot be automated. Any automation touching these gates is a compliance violation:

| Gate | Stage | Accountable Role |
|---|---|---|
| Regulatory change classification | 3 | Compliance Advisor |
| SOP base template approval | 6 | Senior Compliance Professional |
| Onboarding completion sign-off | 1 | Compliance Advisor |
| Baseline gap assessment | 1 | Compliance Advisor |
| Return-to-service after failed inspection | 7 | Compliance Advisor |
| COR evidence package certification | 9 | Compliance Advisor |
| Non-response formal notice at T+21 | 4 | Compliance Advisor + Authorized Officer |
| DocuSign signatory change authorization | 5 | Compliance Advisor |

---

## §6 — Regulatory Monitoring Schedule

| Source | Method | Cadence | Responsible |
|---|---|---|---|
| Alberta King's Printer (OHS Act/Code/Reg) | RSS feed | Daily | Make.com |
| Canada Energy Regulator | RSS feed | Daily | Make.com |
| Alberta OHS eNews | Email inbox watch | Monthly | Make.com |
| AER Directives/Bulletins | Web hash scraper (Firecrawl) | Weekly | Make.com |
| ACSA | Web hash scraper | Bi-weekly | Make.com |
| BCRSP | Web hash scraper | Bi-weekly | Make.com |
| CSSE | Web hash scraper | Monthly | Make.com |
| Transport Canada | Web hash scraper | Monthly | Make.com |

**Hash scraper logic:** HTTP GET → compare page hash to stored hash → if changed → create Regulatory Change Candidate → advisor classifies within 48 hours.

**Human gate:** Compliance Advisor is the named accountable person for all regulatory change decisions. No client action fires before advisor classification.

### Regulatory Change Classifications

| Class | Meaning | What Fires |
|---|---|---|
| A — SOP Update Required | Regulation change requires SOP revision | Stage 6 SOP Propagation |
| B — Certification Renewal Triggered | New or changed credential requirement | Update Certification Tracker; re-initialize alert ladder |
| C — Informational Only | No action required | Push notification to affected clients only |

---

## §7 — Data Anonymization in Documentation

- No real server names, IPs, hostnames, or connection strings in any documentation file
- No credential values in any file committed to version control or stored in Obsidian
- Client names in documentation replaced with `Client_[ID]` format
- This file, SKILL.md, CONTEXT.md, and all architecture docs comply with this rule

---

## §8 — Environmental Submissions

**TEMPORARY STATUS — all Stage 8 environmental workflows**

- No automated government submissions for any environmental or well-related data
- All Stage 8 records flagged `compliance_flag = "REQUIRES_REVIEW"`
- All soil/water/environmental monitoring records require advisor review before any action
- EPEA spill/adverse effects verbal reporting: client calls Alberta Environment hotline 1-800-222-6514 — platform records call confirmation as CEL entry only
- AER/Petrinex/OneStop submissions are performed externally by client — platform stores supporting documents only
- This block remains TEMPORARY until legal review of automated submission workflows is complete

---

## §9 — Electronic Signature Legal Standing

- **Governing legislation:** Alberta Electronic Transactions Act SA 2001 c E-5.5
- Electronic signatures have equivalent legal standing to wet signatures in Alberta
- DocuSign Certificate of Completion is COR audit evidence
- Certificate contents: Envelope ID, document title, sender, per-recipient timestamps, IP, geolocation, auth method, signing sequence, SHA-256 hash

**Documents requiring legal review before electronic execution:**
- Confined Space Entry Permits (OHS Code Part 5 s.45)
- Specific First Aid documentation
- Mine site entry documents

---

## §10 — Credential Verification Standard

- COR, NCSO, CRSP credential scoring by LLM is **absolutely prohibited**
- All credential verification uses deterministic Python only: `scripts/verify-compliance.py`
- Script must execute before any output involving COR, NCSO, or CRSP certifications
- Zero Guess Rule applies to all regulatory content — ambiguity halts output

---

## §11 — Privacy and Access

- One SharePoint site per client — complete data isolation
- `client_id` is primary key across all systems
- No cross-client data access under any circumstance
- Make.com scenario validates `client_id` before every SharePoint write
- Signatories List access: Vaquero advisor role only for write operations
- Client contacts receive push notifications only — no platform access

---

## Change Log

| Date | Change | ADR Reference |
|---|---|---|
| 2026-05-30 | Initial creation | — |
