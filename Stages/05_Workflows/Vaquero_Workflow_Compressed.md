# Vaquero Safety Inc — Workflow Reference (Compressed)

**Last Updated:** 2026-05-28
**Platform:** Make.com automation | **Storage:** SharePoint Online (site-per-client, Canada Central)
**E-Signature:** DocuSign | **Jurisdiction:** Alberta O&G/Construction | **Approval:** Approve/Amend only (no Reject)
**Key rule:** Every compliance event → CEL (SharePoint list). Make.com logs are operational only, never compliance evidence.
**Make.com blueprint naming:** `[scenario-name]_v[semver].json` — all scenario blueprints follow this convention.

---

## Architecture Constants

- All documents auto-written; no manual saves
- Signing authority stored by **role** (Safety Manager, Executive), not by name — Signatories List is the lookup source at envelope creation
- Regulatory changes require human advisor classification before any client action fires
- SharePoint site per client = complete data isolation; `client_id` is primary key across all systems
- DocuSign Certificate of Completion + signed PDF auto-archived to SharePoint on `envelope-completed` webhook
- **COR issuing body (O&G — AB/BC/SK):** Energy Safety Canada (ESC) — not ACSA/BCCSA/SCSA (those are construction CORAs)
- **COR audit cycle:** 3-year external (≥80% score) + annual maintenance (≥60% score) — confirmed unchanged March 1, 2026

---

## Stage 1 — Client Onboarding

**Steps:** Intake form → `client_id` assigned → SharePoint site provisioned (Graph API beta / PnP PowerShell) → MSA DocuSign executed → Signatories List populated (role-based) → Contacts List with channel preferences → Domain documentation intake → Gap assessment **[human required]** → Status = Active

**Human gates:** Gap assessment classification, onboarding completion sign-off
**Outputs:** Client Registry record, SharePoint site, executed MSA in `/00-MSA-Legal/`, Signatories List, Gap Assessment in `/11-Audit-Reports/Onboarding/`, Certification Tracker pre-populated, CEL entries

**Key rules:**
- Email is minimum required channel for approval actions regardless of preference
- Approval buttons always delivered via email; secondary channel fires simultaneously for awareness only
- Two signing roles minimum; Safety Manager signs before Executive (role sequence, not individual sequence)

---

## Stage 2 — Document Ingestion & Indexing

**4 intake sources:** A=Intake Queue watch | B=Field mobile app API push | C=Office scan upload | D=DocuSign webhook (bypasses queue, writes direct)

**Steps:** Receipt → Classification (auto or human fallback if below confidence) → Metadata stamping → SharePoint write → Retention label applied → CEL entry → Version control (major versioning; no version deleted within retention)

**Key metadata fields:** `client_id`, `document_type`, `domain`, `capture_method`, `intake_date`, `effective_date`, `version_number`, `previous_version_id`, `approval_status`, `retention_end_date` (Purview enforced)
Conditional: `regulatory_trigger`, `docusign_envelope_id`, `expiry_date`

**Capture method values:** `mobile_app_online` | `mobile_app_offline_sync` | `paper_scan_upload` | `docusign_completed` | `admin_upload`

**Retention periods (key):**

| Document | Period |
|---|---|
| Incident investigation | 2 yr (OHS Act s.33) |
| Confined space training (no incident) | 1 yr |
| Confined space training (incident) | 2 yr |
| JHSC training | 2 yr after leaving JHSC |
| Asbestos training | 10 yr |
| CVIP certificates | 3 yr |
| Vehicle maintenance | 3 yr |
| Trip inspection | 3 months |
| All other OHS (default) | 5 yr |
| MSA/legal | 7 yr |

---

## Stage 3 — Regulatory & Certification Monitoring

### Certification Tracking

**People:** NCSO (3-yr; issued by CFCSA via provincial CORAs — AB=ACSA, ON=IHSA, MB=CSAM, BC=BCCSA), CRSP (5-yr / 25 CPD pts / **Mar 30 annual renewal deadline**), COR auditor, H2S Alive (no name-searchable registry — ESC Certificate Validation Tool only), Fall Protection, WHMIS (note: "WHMIS 2015" name retired Dec 14, 2025 — current standard is WHMIS GHS Rev 7/8), Ground Disturbance, First Aid, confined space (1 or 2 yr based on incident)
**Assets:** CVIP, lifting devices, pressure vessels, pre-use inspection (daily completion tracking)

### Alert Ladder (all certifications and inspection deadlines)

| Threshold | Action | Escalation |
|---|---|---|
| 90 days | Push to Safety Manager — informational | None |
| 60 days | Push with Approve/Amend — confirm renewal in progress | None |
| 30 days | Urgency push; if renewal not confirmed → advisor alerted internally | Advisor |
| 7 days | Critical — all channels; advisor calls client | Advisor escalation |
| T+0 (expired) | Status = Expired; COR risk flag if applicable | Account manager |
| T+7 | Escalation to account manager + client executive | Executive |

### Regulatory Monitoring Sources

| Source | Method | Cadence |
|---|---|---|
| Alberta King's Printer (OHS Act/Code/Reg) | RSS | Daily |
| Canada Energy Regulator | RSS | Daily |
| Alberta OHS eNews | Email inbox watch | Monthly |
| AER Directives/Bulletins | Web hash scraper | Weekly |
| ACSA, BCRSP, CSSE, Transport Canada | Web hash scraper | Bi-weekly/Monthly |
| Compliance matrix VERIFY_REQUIRED items | firecrawl-sync.py | Post-matrix generation + quarterly |

**Hash scraper logic:** HTTP GET → compare page hash to stored hash → if changed → create Regulatory Change Candidate → advisor classifies within 48 hrs
**firecrawl-sync.py:** Runs after each compliance matrix seed is generated and quarterly thereafter. Outputs to `logs/scrape/firecrawl_YYYY-MM-DD.json` + `.md` report. Result statuses: `RESOLVED_HIGH_CONFIDENCE` (≥60% hints matched) | `RESOLVED_NEEDS_HUMAN_REVIEW` (30–60%) | `UNRESOLVED_MANUAL_REQUIRED` (<30%). Zero Guess Rule applies — ambiguous results are never auto-resolved.
**Human gate:** Advisor is named accountable person for all regulatory change decisions

### Regulatory Change Classifications (Human Decision)
- **A — SOP Update Required** → triggers Stage 6
- **B — Certification Renewal Triggered** → update Certification Tracker; re-initialize alert ladder
- **C — Informational Only** → push notification to affected clients; no Approve/Amend

---

## Stage 4 — Push Notification & Approval Loop

**Triggers:** Certification threshold | Regulatory change (Class A/B/C) | Inspection due/overdue | SOP ready for review | New compliance gap | Document approval required

**Steps:** Triggering event → Generate notification + `notification_id` → Parallel multi-channel delivery (Email always + SMS/Teams/App per preference) → Monitor for Approve or Amend response

**Approve path:** Click → webhook → CEL entry → Stage 5 (DocuSign)
**Amend path:** Click → amendment form → Amendment Record created → advisor reviews → revised notification → loop repeats until Approve
**No-response escalation:**

| Interval | Action |
|---|---|
| T+0 | Notification sent |
| T+48h, T+96h | Auto-reminders |
| T+7 days | Advisor direct follow-up |
| T+14 days | Account manager → client executive contact |
| T+21 days | Formal non-response notice via DocuSign |
| T+30 days | Written COR audit risk advisory if COR-critical |

**Auto-logged per notification:** Delivery record, response record, amendment chain, approval record, non-response record (if applicable)

---

## Stage 5 — DocuSign Execution

**Trigger:** Approve action received from Stage 4

**Steps:** Signatory lookup (role → current holder from Signatories List) → Envelope created → Safety Manager signs (Order 1) → Executive signs (Order 2) → `envelope-completed` webhook → Download signed PDF + Certificate → Write to SharePoint → Metadata stamped (`approval_status = "Active"`) → Retention label → CEL entry → Certification Tracker updated (if applicable) → Client confirmation push

**Signing reminder cadence:**

| Day | Action |
|---|---|
| 0 | Envelope sent |
| 2, 5 | Auto-reminders |
| 7 | Advisor checks; alerts if unsigned |
| 14 | Escalation; signing group member activated if primary unavailable |
| 21 | Void initiated by advisor |
| 30 | Auto-void if not voided; re-issue decision required |

**Signatory change process:** Advisor uses DocuSign Correct (before any signing) OR void + re-issue → Signatories List updated → CEL entry
**Declined envelope:** CEL entry → advisor alerted → Amend cycle or investigation
**Voided envelope:** CEL entry → re-issue creates new envelope_id linked to voided_envelope_id

**DocuSign Certificate contents (COR evidence):** Envelope ID, document title, sender, per-recipient timestamps (delivered/viewed/signed), IP, geolocation, auth method, signing sequence, SHA-256 hash
**Legal standing:** Alberta Electronic Transactions Act SA 2001 c E-5.5 — electronic signatures = wet signatures

**Documents requiring legal review before electronic use:** Confined Space Entry Permits (OHS Code Part 5 s.45), specific First Aid documentation, Mine site entry documents

---

## Stage 6 — SOP Propagation

**Triggers:** Stage 3 Classification A | Annual SOP review | Client-initiated amendment | COR audit finding

**Steps:**
1. Impact assessment **[human]** — advisor identifies affected SOPs across all clients
2. Base template update **[human dual review]** — updated in Vaquero Master Template Library; second advisor signs off before `template_status = "Ready_for_propagation"`
3. Per-client customization check — Make.com reads `customization_flag`; advisor reviews any client-specific sections
4. Client-specific SOP build — merge updated base template + preserved customizations → stored in `/00-Pending-Approval/`
5. Stage 4 push notification per affected client — parallel child scenarios (dispatcher pattern for 50+ clients)
6. Each client traverses Stage 4 → Stage 5 independently
7. SOP activation on DocuSign completion: old version → `status = "Superseded"` | new version → `status = "Active"` with `regulatory_change_id` linked

**SOP Propagation Tracker fields:** `propagation_id`, `client_id`, `sop_template_id`, `regulatory_change_id`, `client_status` (Pending/Notified/In_Amend/Approved/DocuSign_Sent/Executed/Active), `amendment_cycle`, `last_activity_timestamp`, `days_since_notification`

---

## Stage 7 — Asset & Inspection Compliance

**Asset Registry fields:** `asset_id`, `asset_type`, make/model/year/VIN, `registered_weight`, `inspection_schedules[]`, `last_inspection_date`, `next_inspection_due`, `CVIP_expiry_date`, `status` (Active/Out-of-Service/Disposed)

**Daily Make.com scenario (06:00 client local):** Reads all assets → calculates days until due → fires alerts at threshold

**Inspection completion paths:**
- Mobile app (primary): offline-capable → GPS + device timestamp → sync on reconnect → `capture_method = "mobile_app_online"` or `"mobile_app_offline_sync"`
- Office scan (backup): paper → office staff uploads → `capture_method = "paper_scan_upload"` → advisor acknowledgement required per record

**Fail path:** `asset_status = "Non-Compliant"` → push to Safety Manager → `Out-of-Service` → remediation record + 48h reminder cycle → repair docs uploaded → Stage 2 ingestion → **advisor authorizes return-to-service [human gate]** → `asset_status = "Active"` → CEL entry

**CVIP:** 90/60/30/7-day alert ladder; physical certificate required in vehicle + operator's office; digital copy in `/02-Assets/Vehicles/CVIP/`

---

## Stage 8 — Chemical, SDS & Environmental

**SDS:** Stored in `/09-WHMIS-SDS/`; weekly Make.com scan flags SDS older than 3 years → push to Safety Manager; mobile app pre-caches SDS offline for assigned site chemicals. Note: "WHMIS 2015" designation is retired — all SDS metadata and labels must reference WHMIS (GHS Rev 7/8); HPR transition ended December 14, 2025.
**Chemical inventory:** New chemical → SDS must be ingested before chemical permitted for use
**Soil/water samples:** Chain of custody + lab results stored; threshold exceeded flag → immediate advisor alert; **no automated regulatory submission**
**Well tracking:** Platform stores supporting docs only; AER submissions via Petrinex/AER OneStop (external); advisor confirms submission → CEL entry
**Environmental monitoring:** [TEMPORARY] store and notify advisor; all records flagged `compliance_flag = "REQUIRES_REVIEW"`; no automated government submissions until legal review complete
**EPEA verbal reporting obligation:** Client must call Alberta Environment hotline (1-800-222-6514) for spills/adverse effects; platform records call confirmation as CEL entry only

---

## Stage 9 — Audit Trail & Reporting

**CEL (Compliance Event Log):** Written by every stage at every compliance event; SharePoint list per client with Purview retention enforcement; this is the legal audit trail

**COR Evidence Package (on-demand):** Make.com queries SharePoint + CEL + DocuSign-Completed by audit period → generates evidence manifest + PDF index → advisor certifies completeness **[human gate]** before sharing with auditor

**COR Audit Cycle:** 3-year external audit (≥80% score required) + annual maintenance audit (≥60% score required). COR for O&G clients (AB/BC/SK) issued by Energy Safety Canada (ESC). Evidence package must map to all 8 COR elements below.

**COR Elements → SharePoint locations:**

| Element | Location |
|---|---|
| 1: Management Leadership | `/01-Safety-Policy/` + `/13-DocuSign-Completed/` |
| 2: Hazard ID | `/03-Processes/JHAs/` |
| 3: Hazard Control | `/03-Processes/SOPs/` |
| 4: Ongoing Inspections | `/02-Assets/Inspections/` + `/04-Site-Environmental/Walkarounds/` |
| 5: Training/Orientation | `/01-People/Training/` + `/01-People/Orientations/` |
| 6: Emergency Response | `/03-Processes/ERP/` |
| 7: Incident Reporting | `/04-Site-Environmental/Incidents/` |
| 8: Program Administration | `/03-Processes/SOPs/` + `/11-Audit-Reports/` |

**Recurring reports auto-pushed:**
- Monthly to Safety Manager: cert status, inspection completion rate, open action items, SOP updates, notification response rates, paper scan ratio
- Quarterly to Safety Manager + Executive: 12-month expiry forward view, COR audit cycle position
- Annual to Safety Manager: SOP version log

---

## Human-Only Decision Gates (Cannot Be Automated)

| Gate | Stage | Role |
|---|---|---|
| Regulatory change classification | 3 | Compliance advisor |
| SOP base template approval | 6 | Senior compliance professional |
| Onboarding completion | 1 | Compliance advisor |
| Baseline gap assessment | 1 | Compliance advisor |
| Return-to-service after failed inspection | 7 | Compliance advisor |
| COR evidence package certification | 9 | Compliance advisor |
| Non-response formal notice issuance (T+21) | 4 | Compliance advisor + authorized officer |
| DocuSign signatory change authorization | 5 | Compliance advisor |
| firecrawl-sync.py UNRESOLVED_MANUAL_REQUIRED items | 3 | Compliance advisor |

---

## Core Operational Loops

1. **Compliance loop:** Stage 3 → Stage 4 push → Stage 5 sign → SharePoint archive → Stage 3 monitors new expiry → repeat
2. **SOP loop:** Stage 3 Class A → Stage 6 propagate → Stage 4 per client → Stage 5 sign → Stage 3 monitors new SOP version
3. **Amendment loop:** Stage 4 Amend → advisor revision → Stage 4 revised push → repeat until Approve → Stage 5
4. **No-response loop:** Stage 4 → 48h reminders → T+7 human → T+21 formal notice → terminates on response
5. **Inspection loop:** Stage 7 triggers → Stage 4 alert → field completion → Stage 2 ingestion → Stage 7 registry update → next schedule set
6. **DocuSign monitoring loop:** Envelope created → Day 2/5 reminders → Day 7 advisor check → Day 14 escalation → Day 21 void/re-issue
7. **Firecrawl verification loop:** Matrix generated → firecrawl-sync.py runs → RESOLVED items close in tracker → UNRESOLVED items → advisor manual review → quarterly re-run

---

## Competitive Position (Key Differentiators)

Push-only model (clients never log in) + auto DocuSign with signing order + automated SOP propagation across 50+ clients + Approve/Amend routing + signed docs auto-archived to client SharePoint + COR 3-year cycle management (ESC-issued for O&G) + signatory-by-role model (survives staff turnover) + continuous CEL audit trail + firecrawl-based automated regulatory source verification

No competitor (ISNetworld, Avetta, Veriforce/ComplyWorks, Cognibox) offers the push + DocuSign + SharePoint auto-archive + CEL combination.

---

## Key Operational Risks (Summary)

| Risk | Mitigation |
|---|---|
| Make.com log retention 60 days insufficient | CEL is system of record; written at event time |
| Regulatory misclassification affects 50+ clients | Dual advisor review for Class A changes |
| Stale signatory in Signatories List | MSA obligation; bounce detection; signing groups; annual signatory confirmation push |
| Wrong `client_id` in Make.com scenario | Site-per-client isolation; scenario validates client_id before every write |
| Make.com timeout at 50+ client propagation | Dispatcher + child scenario pattern |
| Environmental/well submission workflows incomplete | All Stage 8 records marked [TEMPORARY]; advisor gate on all environmental records |
| CRSP renewal missed (annual Mar 30 deadline) | Alert ladder initialized at 90-day threshold; Mar 30 hard deadline flagged in Certification Tracker |
| firecrawl-sync.py UNRESOLVED items left open | Advisor-gated; flagged in compliance matrix tracker; quarterly re-run forces resolution cycle |
| WHMIS labeling using retired "WHMIS 2015" designation | SDS metadata validation rejects "WHMIS 2015" string; enforces WHMIS (GHS Rev 7/8) label |

---

*All infrastructure details anonymized per `compliance/COMPLIANCE.md §7`.*
*No real server names, IPs, or credentials appear in this file.*
*Compliance: PIPEDA/PIPA (Alberta) | Canada Central data residency.*
