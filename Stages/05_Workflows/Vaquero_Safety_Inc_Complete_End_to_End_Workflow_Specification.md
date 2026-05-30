# Vaquero Safety Inc — Phase 2: Complete End-to-End Workflow Specification (9 Stages)

**Last Updated:** 2026-05-28  
**Platform:** Vaquero Safety Inc. | **Model:** Push-only | **Automation Layer:** Make.com  
**Document Store:** SharePoint Online (site-per-client, Canada Central) | **E-Signature:** DocuSign  
**Jurisdiction:** Alberta, Canada | **Sector:** Oil & Gas, Construction, Energy  
**Approval Actions:** Approve / Amend only (no Reject) | **Reminder Cadence:** Every 48 hours  
**Make.com Blueprint Naming:** `[scenario-name]_v[semver].json` — all scenario blueprints follow this convention  
**Audience:** Phase 2 source document for Mermaid.js workflow diagram construction

***

## Architecture Principles Applied to All Stages

- Every document write is automatic — no manual save steps at any stage
- Every compliance event is logged to a dedicated SharePoint Compliance Event Log (CEL) list per client — this is the legal audit trail, not Make.com execution history[^1][^2]
- Make.com execution logs (max 60 days retention on Enterprise plan) are supplementary operational logs only — they are never cited as compliance evidence[^2]
- DocuSign Certificate of Completion + signed PDF are auto-archived to SharePoint on envelope completion — no human intervention required[^3][^4]
- Signing authority is stored by **role** (Safety Manager role, Executive role), not by individual name — Make.com looks up the current holder of each role from a SharePoint Signatories List at the moment of envelope creation
- Regulatory change signals require human compliance advisor review and classification before any client-facing action fires
- SharePoint site provisioning is automated via Microsoft Graph API (beta — `Sites.Create.All` + `Sites.Selected` scopes) or PnP PowerShell, triggered by Make.com HTTP module[^5][^6]
- **COR issuing body for O&G clients (AB/BC/SK):** Energy Safety Canada (ESC) — not ACSA/BCCSA/SCSA (those are construction CORAs only). COR audit cycle: 3-year external audit (≥80% score required) + annual maintenance audit (≥60% score required) — confirmed unchanged March 1, 2026

***

## Stage 1 — Client Onboarding

### Inputs
- Client intake form (name, ABN, WCB account number, NAICS code, COR status, certifying partner, workforce size, active work sites)
- Existing safety program documents (scanned or digital)
- Signing authority designations (role + individual name)
- Contact list with notification channel preference per contact
- Client MSA and data processing addendum (DocuSign-executed)

### Sequential Workflow Steps

**Step 1.1 — Intake Form Capture**
- Client completes structured intake form (web form or Vaquero-completed during kick-off call)
- Form submitted → Make.com webhook triggered → client record created in master SharePoint Client Registry list
- Client assigned `client_id` (unique, immutable identifier used across all systems)

**Step 1.2 — SharePoint Site Provisioning**
- Make.com HTTP module calls Microsoft Graph API (beta) with `Sites.Create.All` scope to create new site collection: `vaquero.sharepoint.com/sites/[client_id]`[^6]
- PnP PowerShell site template applied via Make.com HTTP call to pre-configure all 13 document libraries and metadata schemas (see structure below)[^7][^8]
- Make.com logs provisioning event (timestamp, client_id, provisioner_user_id) to CEL
- Site permissions configured: Vaquero compliance advisors granted Contribute; client contacts (if portal access granted) granted Read only; no cross-client permission inheritance[^9][^10]

**Step 1.3 — MSA and DPA Execution**
- Make.com generates DocuSign envelope from MSA template
- Envelope routed to: Vaquero authorized officer (signs first) → Client executive (signs second)
- DocuSign webhook: on `envelope-completed` → signed MSA + Certificate of Completion auto-saved to `/00-MSA-Legal/` in client site[^4][^11]
- CEL entry: MSA_executed, envelope_id, signatories, timestamp

**Step 1.4 — Signing Authority Configuration**
- Compliance advisor populates SharePoint Signatories List for client: Role = "Safety Manager", Name = [name], Email = [email], Channel = [preference]; Role = "Executive", Name = [name], Email = [email]
- Minimum two roles required; additional roles configurable
- Signing order stored as role sequence (Safety Manager → Executive), not individual sequence
- Signatories List is the source of truth — all future DocuSign envelopes read from this list at creation time
- Any update to Signatories List triggers Make.com notification to compliance advisor for confirmation + CEL entry

**Step 1.5 — Contact Notification Preferences**
- Each contact record in Contacts List includes: contact_id, name, role, primary_channel (Email | SMS | Teams | App), secondary_channel, email_address, mobile_number, Teams_UPN
- For any approval workflow, email is the **minimum required channel** regardless of preference — SMS/Teams/App may supplement but cannot substitute for approval actions (Phase 1 finding)[^12]
- Mixed channel configuration stored per contact; approval action buttons (Approve/Amend) are always delivered via email as primary, secondary channel fires simultaneously for awareness only
- Channel preference change triggers CEL entry with: changed_by, timestamp, old_value, new_value

**Step 1.6 — Domain-by-Domain Documentation Intake**
- Compliance advisor requests documentation intake for all four domains (People, Assets, Processes, Site & Environmental) via checklist push notification to client
- Client uploads documents to a designated secure intake folder OR Vaquero scans/uploads paper documents to `/00-Intake-Queue/`
- Make.com watches for new items in Intake Queue → triggers Stage 2 (Document Ingestion pipeline)

**Step 1.7 — Baseline Compliance Gap Assessment**
- Compliance advisor reviews intake documents against gap assessment checklist (four domains)
- Gap assessment tool: SharePoint list populated by compliance advisor with: domain, gap_type, document_missing, certification_expired, expiry_date, severity (Critical / Major / Minor)
- **Decision Point (Human Required):** Compliance advisor must review and classify each gap; AI assistance may flag anomalies but classification requires human sign-off
- Gap assessment report generated by Make.com → pushed to client via Stage 4 (Push Notification workflow) as informational notice
- Gaps with Critical severity: immediate push notification to client with remediation timeline; 48-hour reminder cycle initiated

**Step 1.8 — Pre-Existing Gap Handling**
- For expired certifications: Create certification record in Certification Tracker with status = "Expired_at_Onboarding"; 90/60/30/7-day alert cycle initialized from current date
- For missing documents: Create open action item in Action Items list; assign to client contact; push notification with Approve/Amend options (Approve = acknowledge and commit to providing by date; Amend = request modified deadline)
- For incomplete SOPs: Flag in SOP Registry with status = "Incomplete_at_Onboarding"; classify as Stage 6 input item
- All pre-existing gaps documented in onboarding CEL record with classification timestamp and advisor sign-off
- **[FLAG FOR LEGAL REVIEW]:** If a client's existing COR was obtained while holding documentation gaps now identified at onboarding, advise client on potential COR audit risk — this advisory should be captured as a documented notification in CEL

**Step 1.9 — Onboarding Completion Gate**
- **Decision Point (Human Required):** Compliance advisor reviews all four domains; marks onboarding as "Active" in Client Registry only when: MSA executed, SharePoint site provisioned, signatories configured, notification preferences set, gap assessment complete
- Client status in Client Registry updates to "Active" → triggers Certification Monitoring (Stage 3) and Recurring Compliance Review cycle (Stage 4)

### Outputs
- Client record in Master Client Registry (SharePoint)
- Provisioned SharePoint site with full taxonomy
- Executed MSA + DPA in `/00-MSA-Legal/`
- Signatories List (role-based)
- Contacts List with channel preferences
- Gap Assessment Report in `/11-Audit-Reports/Onboarding/`
- CEL entries for all onboarding events
- Certification Tracker pre-populated with known expiry dates
- Action Items list with all identified open gaps

### Automation vs. Human Sign-off

| Step | Automated (Make.com) | Human Required |
|---|---|---|
| SharePoint provisioning | ✓ | Initial template approval |
| MSA envelope creation and routing | ✓ | MSA signing (both parties) |
| Intake queue monitoring | ✓ | — |
| Gap assessment classification | **No** | Compliance advisor required |
| Onboarding completion gate | Notification only | Compliance advisor sign-off |
| Client status = Active | Triggered by advisor sign-off | Advisor initiates |

### Regulatory Checkpoints
- PIPA Alberta s.7: consent for collection of personal information obtained via MSA/DPA[^13]
- PIPA Alberta s.34: accountability — compliance advisor named as designated data steward per client
- SharePoint Canada Central data residency: confirmed at site provisioning; logged in CEL[^14]
- OHS Act: employer (client) responsibility for maintaining accurate safety documentation does not transfer to Vaquero — Vaquero's MSA must clearly state the management vs. advisory relationship[^15]

### Failure Paths
- SharePoint provisioning failure: Make.com error handler → alerts Vaquero operations team → manual provisioning with CEL note documenting reason
- MSA not signed within 7 days: escalation to Vaquero account manager; onboarding suspended
- DocuSign envelope creation failure: Make.com error handler → CEL error log → advisor manual re-send
- Intake document upload failure: retry (3 attempts); if persistent, alert advisor; client notified of intake delay

***

## Stage 2 — Safety Documentation Ingestion & Indexing

### Standard Document Types by Domain

**People:**
- New worker orientation records (OHS Reg s.3.25)[^16]
- Training records (confined space training — 1 year/2 years per incident status, OHS Code s.46/58)[^16]
- JHSC training records (2 years after person leaves JHSC, OHS Reg s.3.27)[^16]
- First aid certification records (CSA Z1210-17 aligned, OHS Code Part 11)
- NCSO, CRSP, COR auditor certificates
- Competency assessments
- Worker tickets (H2S Alive, Fall Protection, WHMIS, Ground Disturbance)
- Medical surveillance records (asbestos training — 10 years, OHS Reg s.6.32)[^16]

**Assets:**
- Pre-use inspection checklists (daily)
- Preventive maintenance logs
- CVIP inspection certificates (3-year retention)[^17]
- Lifting device inspection records (OHS Code Part 6)
- Pressure vessel certificates
- Equipment registration certificates
- Vehicle mileage logs

**Processes:**
- Safety policy statement (signed by senior officer — ACSA COR Element 1)[^18]
- Safe Work Procedures / SOPs (versioned, dated, authorized)
- Job Hazard Analysis / Field Level Risk Assessment records
- Tailgate talk attendance records
- Safety meeting minutes
- Emergency Response Plan (ERP)
- Violence and Harassment Prevention Plan (OHS Code Part 27, AR 202/2024, compliant by March 31 2025)[^19]
- Confined Space Code of Practice (OHS Code Part 5, s.44)[^20]
- Confined Space Entry Permits — **[FLAG FOR LEGAL REVIEW]:** OHS Code Part 5 s.45 requires written entry permit; while Alberta's *Electronic Transactions Act* SA 2001 c E-5.5 gives electronic records equivalent standing, confirm with Alberta OHS that electronic entry permits (DocuSign) are accepted in confined space operations[^21][^22]

**Site & Environmental:**
- Site walkabout inspection reports
- Near miss reports
- Hazard identification logs
- Soil and water sample chain of custody forms and lab results
- Chemical inventories
- SDS library (WHMIS — GHS Rev 7/8; ⚠ CORRECTION: "WHMIS 2015" designation is retired as of December 14, 2025 — do not use this label in metadata, reports, or client communications)
- Environmental monitoring logs
- Well tracking documents (AER-related)

### Sequential Workflow Steps

**Step 2.1 — Document Receipt**
- Source A (native digital): Make.com watches `/00-Intake-Queue/` → new file detected → ingestion triggered
- Source B (field mobile app): record synced from field app → API push → SharePoint write direct to target library
- Source C (office scan upload): compliance advisor uploads to `/00-Intake-Queue/` with capture_method = "paper_scan_upload"
- Source D (automated DocuSign return): DocuSign webhook fires on completion → Make.com downloads signed PDF + Certificate → writes to target library (no queue step)

**Step 2.2 — Document Classification**
- Make.com reads file metadata (file extension, filename pattern, upload source)
- AI classification module (or rules-based routing on filename/upload source): assigns domain (People / Assets / Processes / Site & Environmental), document_type, and target library path
- **Decision Point (Human Required):** Documents that cannot be classified automatically (confidence below threshold) → routed to compliance advisor queue for manual classification → advisor classifies → Make.com proceeds with ingestion
- All classification decisions (auto or manual) logged to CEL with: classifier_type (auto/manual), classifier_user_id (if manual), timestamp, confidence_score (if auto)

**Step 2.3 — Metadata Stamping**

Every document ingested into SharePoint receives the following metadata schema:

| Metadata Field | Source | Required |
|---|---|---|
| client_id | System | Mandatory |
| document_type | Classification | Mandatory |
| domain | Classification | Mandatory |
| capture_method | Source A/B/C/D above | Mandatory |
| intake_date | System timestamp | Mandatory |
| effective_date | Extracted or manually entered | Mandatory |
| version_number | Auto-incremented | Mandatory |
| previous_version_id | SharePoint version history | Mandatory |
| regulatory_trigger | If change-driven update | Conditional |
| regulatory_change_id | Links to Regulatory Change Log | Conditional |
| approval_status | Pending / Approved / Active | Mandatory |
| docusign_envelope_id | If DocuSign-executed | Conditional |
| signing_date | If DocuSign-executed | Conditional |
| expiry_date | If certification/time-limited | Conditional |
| retention_end_date | Calculated from retention policy | Mandatory |
| capture_method_detail | "mobile_app_online" / "mobile_app_offline_sync" / "paper_scan_upload" / "docusign_completed" / "admin_upload" | Mandatory |

- SharePoint retention label applied at ingestion for all documents with defined retention periods[^23]
- Microsoft Purview retention policy prevents deletion before `retention_end_date`

**Step 2.4 — Version Control**
- SharePoint document library with major versioning enabled[^24]
- New version created on every ingestion of a document with the same document_type for the same client
- Previous version marked inactive; all versions retained per retention policy
- Version history linked: new version metadata includes previous_version_id, change_reason (regulatory_trigger_id, client_initiated, periodic_review, SOP_propagation)
- No version ever deleted within retention period (retention label enforcement)[^23]

**Step 2.5 — Non-Standard Format Normalization**
- Paper scans (image PDFs): metadata flag `capture_method = "paper_scan_upload"` + `paper_record_date` field (manually entered by uploading staff) + `reason_for_paper_use` field
- Spreadsheets and informal documents: compliance advisor reviews and normalizes to standard template where possible; non-normalized documents stored with `format_type = "non_standard"`
- Email-origin documents (informal approvals, etc.): [FLAG FOR LEGAL REVIEW] — email-captured approvals may not meet OHS or COR evidentiary standards; compliance advisor must convert to formal document or replace with DocuSign-executed version before marking `approval_status = "Active"`

**Step 2.6 — Field Record Ingestion Paths**

*Mobile App (Primary):*
1. Worker completes form on native mobile app (offline-capable)
2. Record stored locally with: device_timestamp, worker_id, GPS coordinates (if available), form_type, form_version
3. On reconnect: app syncs to platform API → SharePoint write with all locally-captured metadata preserved
4. Make.com triggered by new SharePoint item → classification + advisor notification on any "fail" flag
5. Metadata: `capture_method = "mobile_app_online"` or `"mobile_app_offline_sync"` (distinguished by sync vs. real-time write)

*Office Scan Upload (Backup):*
1. Worker completes paper form in field
2. Office staff scans and uploads to Intake Queue
3. Metadata required at upload: paper_record_date, uploading_user_id, site_location, reason_paper_used, form_type
4. Make.com ingestion pipeline flags with `capture_method = "paper_scan_upload"`
5. Compliance dashboard flags all paper_scan records for advisor review — advisor must acknowledge each paper record
6. COR audit package: paper_scan records are noted separately with explanation if used; not excluded but are of lower evidentiary quality than digitally-captured records

### Outputs
- All documents in correct SharePoint library with complete metadata
- CEL entry per document ingested
- Classification queue (Make.com) with human-required items flagged
- Version history in SharePoint with full lineage

### Retention Policy by Document Type (Alberta OHS and PIPEDA)

| Document Type | Retention Period | Source |
|---|---|---|
| Incident investigation reports | 2 years minimum[^25] | OHS Act s.33 |
| Confined space training records (no incident) | 1 year[^16] | OHS Code s.46/58 |
| Confined space training records (incident occurred) | 2 years[^16] | OHS Code s.46/58 |
| JHSC member training records | 2 years after leaving JHSC[^16] | OHS Reg s.3.27 |
| Asbestos training records | 10 years[^16] | OHS Reg s.6.32 |
| Hazardous drug training records | 3 years[^16] | OHS Reg 6.58(1) |
| Environmental / air or soil testing results | 10 years (best practice)[^26] | OHS Insider / Expert consensus |
| Worker orientation and training records | 5 years (best practice)[^26] | Expert consensus |
| CVIP inspection certificates | 3 years[^17] | NSC / CVSE |
| Vehicle maintenance and repair records | 3 years[^17] | NSC / CVSE |
| Trip inspection reports | 3 months[^17] | NSC |
| All other OHS records without express retention | 5 years (recommended default) | Expert consensus[^26] |

**[UNVERIFIED]:** Several Alberta OHS Code provisions do not specify a retention period — "retain" is required but duration unspecified. Apply 5-year default pending specific legal review per record type.

### Failure Paths
- Document too large for Make.com payload (>5 MB): Make.com passes SharePoint URL reference only; retrieves document via SharePoint module separately[^27]
- Classification failure: routed to advisor queue; CEL logs `classification_status = "manual_required"`
- SharePoint write failure: Make.com error handler → retry (3x) → if persistent, alert advisor; document held in intake queue
- Mobile app sync failure: records retained locally; retry on reconnect; no data loss

***

## Stage 3 — Regulatory & Certification Monitoring

### Certification Monitoring (People Domain)

**Tracked Certifications per Individual:**
- NCSO: 3-year renewal cycle (issued by **CFCSA** via provincial CORAs — AB=ACSA, ON=IHSA, MB=CSAM, BC=BCCSA; ⚠ CORRECTION: previously listed as CSSE-administered — CSSE does not issue NCSO)
- CRSP: 5-year CPD cycle; 25 CPD points required; **March 30 annual submission deadline** (hard cutoff — alert ladder must initialize at 90 days prior); mandatory ethics course[^28]
- COR auditor certification (ACSA): renewal per ACSA schedule
- Worker tickets (H2S Alive — **no name-searchable registry; ESC Certificate Validation Tool only; certificate number required for verification**, Fall Protection, WHMIS, Ground Disturbance, First Aid): per certificate issuer
- Confined space entry training: track against incident-adjusted retention (1 or 2 years)[^16]
- First aid certificate: per CSA Z1210-17 provider cycle (OHS Code Part 11)

**Certification Tracker (SharePoint List — People domain):**

Fields: client_id, worker_id, worker_name, role, certification_type, certifying_body, issue_date, expiry_date, status (Active / Expiring_90 / Expiring_60 / Expiring_30 / Expiring_7 / Expired / Renewed), last_alert_sent, renewal_in_progress (Y/N)

### Certification Monitoring (Assets Domain)

**Tracked Certifications per Asset:**
- CVIP: annual (most vehicles); semi-annual (some classes — [UNVERIFIED] confirm specific categories with Alberta Transportation)[^29]
- Lifting device inspections: per OHS Code Part 6 requirements
- Pressure vessel certificates: per provincial boiler/pressure vessel authority schedule
- Pre-use inspection: daily (recurring completion tracking, not certification expiry)

### Regulatory Body Monitoring Schedule

| Regulatory Body | Feed Type | Make.com Method | Cadence | Human Review Required |
|---|---|---|---|---|
| Alberta Queen's Printer (OHS Act/Code/Reg) | RSS (King's Printer e-Bookmark)[^30] | Make.com RSS module polls feed | Daily | Yes — before any client action |
| Canada Energy Regulator | RSS (News, What's New)[^31] | Make.com RSS module polls feed | Daily | Yes |
| Alberta OHS eNews | Email newsletter | Make.com email inbox watch + parser | Monthly (on receipt) | Yes |
| AER Alberta — Directives, Bulletins | No feed; web page[^32] | Scheduled web scraper (Make.com HTTP GET + compare hash) | Weekly | Yes — mandatory |
| ACSA | No feed; youracsa.ca[^33] | Scheduled web scraper | Bi-weekly | Yes — mandatory |
| BCRSP | No feed; website | Scheduled web scraper | Bi-weekly | Yes — mandatory |
| CSSE | No feed; website | Scheduled web scraper | Bi-weekly | Yes — mandatory |
| Transport Canada (NSC/CVIP) | No feed | Scheduled web scraper | Monthly | Yes — mandatory |
| NAOSH | Not a regulatory body — remove from monitoring scope[^34] | N/A | N/A | N/A |
| Compliance matrix VERIFY_REQUIRED items | firecrawl-sync.py automated scraper | Post-matrix generation + quarterly re-verification | Yes — UNRESOLVED items require advisor review |

**firecrawl-sync.py — Automated Verification Layer:**
- Script location: `C:\Projects\Vaquero_Safety_Inc\scripts\firecrawl-sync.py`
- Runs after each compliance matrix seed file is generated; quarterly re-verification thereafter
- Outputs: `logs/scrape/firecrawl_YYYY-MM-DD.json` + `.md` report
- Result statuses: `RESOLVED_HIGH_CONFIDENCE` (≥60% extract hints matched) | `RESOLVED_NEEDS_HUMAN_REVIEW` (30–60% matched) | `UNRESOLVED_MANUAL_REQUIRED` (<30% matched)
- Zero Guess Rule applies: ambiguous results are flagged and never auto-resolved; `UNRESOLVED_MANUAL_REQUIRED` items routed to compliance advisor queue
- Rate limit: 2.0 seconds between requests; failure protocol → `logs/scrape/errors.log` → triggers `AUTO_DEBUGGING_RUNBOOK.md`

**Manual Monitoring Protocol (Where No Feed Exists):**
- Make.com weekly/bi-weekly scenario: HTTP GET request to regulatory page → extract page hash → compare to stored hash in SharePoint Regulatory Monitor List
- If hash differs: Make.com creates "Regulatory Change Candidate" record → assigns to on-call compliance advisor → advisor reviews and classifies within 48 hours
- If no change detected: log "No change" with timestamp to Regulatory Monitor List
- Compliance advisor is the **named accountable human** for all manual monitoring decisions — this cannot be automated[^19]

### Alert Threshold Ladder (All Certifications and Inspection Deadlines)

| Threshold | Action | Channel | Escalation |
|---|---|---|---|
| **90 days before expiry** | Push notification to client Safety Manager; informational; renewal action recommended | Email (primary) + SMS (secondary) | None at this stage |
| **60 days before expiry** | Push notification with Approve/Amend action buttons: "Confirm renewal in progress" | Email (primary) + secondary channel | None at this stage |
| **30 days before expiry** | Push notification; escalated urgency; if renewal not confirmed, compliance advisor alerted | Email (primary) + secondary channel | Compliance advisor alerted internally |
| **7 days before expiry** | Critical alert; compliance advisor direct contact with client; internal Vaquero flag raised | Email + ALL configured channels | Compliance advisor escalation call |
| **Day of expiry (T+0)** | Status updated to Expired; Make.com triggers COR Employer Review risk assessment flag if applicable[^35] | All channels | Vaquero account manager notified |
| **T+7 (one week overdue)** | Escalation to Vaquero account manager + client executive contact | All channels | Executive-level contact |

All alert events logged to CEL: certification_id, threshold_level, notification_sent_timestamp, channel, delivery_confirmation, response_received (Y/N), response_type.

### Regulatory Change Classification (Human Decision Required)

After compliance advisor reviews a detected change:

**Classification A — SOP Update Required:**
- Advisor logs: change_id, affected_regulation, affected_SOP_types, affected_client_count, effective_date
- Make.com receives classification → triggers Stage 6 (SOP Propagation)
- Action type = "SOP_update"

**Classification B — Certification Renewal Triggered:**
- Advisor logs: certification_type affected, renewal_requirement_change
- Make.com updates Certification Tracker records for all affected clients
- Alert threshold ladder re-initialized if deadline changed

**Classification C — Informational Notice Only:**
- Advisor approves push notification to affected clients
- Make.com delivers informational push notification (no Approve/Amend required)
- CEL records: notification_type = "informational", delivery confirmation

### Failure Paths
- RSS feed unreachable: Make.com error handler → alert Vaquero operations → manual check by advisor; CEL logs feed failure
- Web scraper returns error: Make.com retry (3x) → advisor alert; CEL records scraper failure with timestamp
- Certification Tracker expiry scan: if no response to 90/60/30-day alerts and expiry reached, status = "Expired" is auto-set and COR risk flag is evaluated
- Advisor fails to review regulatory change candidate within 48 hours: Make.com escalates to Vaquero operations manager

***

## Stage 4 — Push Notification & Approval Workflow

### This is the core operational loop.

### Triggering Events

| Trigger Type | Source Stage | Make.com Trigger Mechanism |
|---|---|---|
| Certification approaching expiry | Stage 3 Certification Tracker | Scheduled scenario; reads Certification Tracker; fires on threshold match |
| Regulatory change classified (SOP update required) | Stage 3 Regulatory Monitor | Webhook from advisor classification action |
| Inspection due or overdue | Stage 7 Inspection Schedule | Scheduled scenario; reads Inspection Schedule list |
| SOP update ready for client review | Stage 6 SOP Propagation | Webhook from SOP build completion |
| New compliance gap identified | Stage 1/2 Gap Assessment | Advisor manual trigger or auto-classification flag |
| Document approval required | Any stage | Webhook on new item in Approval Queue list |

### Complete Push Notification and Approval Loop

**Step 4.1 — Notification Generation**
- Make.com reads triggering event record
- Retrieves: client_id → looks up Contacts List (filtered to contacts requiring notification for this event type) → looks up channel preference per contact
- Generates plain-language notification body: summary of change, recommended action, context, Approve and Amend buttons with tracked links
- `notification_id` assigned; notification record created in Notification Log (SharePoint list) with: notification_id, client_id, event_type, event_id, notification_timestamp, contacts_notified[], channels_used[]

**Step 4.2 — Multi-Channel Delivery (Simultaneous)**
- Make.com scenario executes in parallel branches for each channel:[^36][^37]
  - Branch A: Email module → sends to all contacts with Email configured as primary channel; action buttons embedded as tracked hyperlinks
  - Branch B: Twilio SMS module → sends to all contacts with SMS configured; includes link to approval response page[^38]
  - Branch C: Microsoft Teams module → sends adaptive card to contacts with Teams configured; action buttons on card
  - Branch D: Push notification to mobile app via webhook (if app notification configured)
- All branches fire in same scenario execution — email is always sent regardless of preference (approval audit trail requirement)
- Each delivery: delivery_confirmation (server acknowledgement) logged to Notification Log

**Step 4.3 — Response Monitoring**
- Approve button click → tracked link fires GET request to Make.com webhook URL with: notification_id, contact_id, action = "approve", timestamp
- Amend button click → fires GET request with: notification_id, contact_id, action = "amend", timestamp; amendment form link included
- Make.com receives webhook → routes based on action value

**Step 4.4 — Approve Path**

```
Client clicks Approve →
  Make.com receives approve webhook →
  CEL entry: notification_id, contact_id, action="approve", timestamp, channel_used →
  Make.com routes to Stage 5 (DocuSign Execution) →
  [Stage 5 executes] →
  Notification Log updated: status = "Approved", approval_timestamp, approving_contact_id
```

**Step 4.5 — Amend Path**

```
Client clicks Amend →
  Make.com receives amend webhook →
  CEL entry: notification_id, contact_id, action="amend", timestamp →
  Amendment form link sent to client →
  Client submits amendment details (text field) →
  Make.com creates Amendment Record: amendment_id, notification_id, amendment_notes, requested_by, timestamp →
  Routed to Vaquero compliance advisor queue →
  Advisor reviews amendment request →
  [Human Decision Point: advisor revises recommendation or clarifies] →
  Revised notification generated with amendment_cycle_number incremented →
  Cycle repeats from Step 4.1 →
  Loop continues until Approve received
```

- Amendment cycles are logged sequentially: amendment_cycle_1, amendment_cycle_2, etc.
- All amendment notes, timestamps, and advisor responses stored in Amendment Records (SharePoint list)
- Full amendment history is part of the audit evidence chain for COR Element 8 (Program Administration)[^18]

**Step 4.6 — No-Response Path and Escalation**

| Interval | Action | Who |
|---|---|---|
| T+0 | Notification sent; response timer starts | Make.com automated |
| T+48h | 48-hour reminder; same content, same channel | Make.com automated |
| T+96h | Second reminder | Make.com automated |
| T+7 days | Escalation Level 1: Compliance advisor alerted; advisor sends personalized follow-up | Compliance advisor (human) |
| T+14 days | Escalation Level 2: Client executive direct contact by Vaquero account manager; formal notice of unresolved compliance obligation issued | Account manager (human) |
| T+21 days | Escalation Level 3: Formal non-response notice issued via DocuSign (signed by Vaquero authorized officer) — creates legal documentation of notification delivery failure and client non-response | Compliance advisor + DocuSign |
| T+30 days | If COR-critical item: Vaquero advises client in writing of COR audit risk; advisory logged to CEL; advisor documents in client file | Compliance advisor (human) |

**Escalation Threshold Rationale:** 7-day human escalation trigger chosen because (a) 48-hour reminder cadence means four reminders have been sent by Day 7; (b) 7 days is operationally significant for most regulatory deadlines; (c) 14-day executive contact aligns with the window where COR-critical documents approaching 30-day expiry would still allow renewal

**Step 4.7 — Legal and Liability Documentation (Auto-Generated)**

For every notification workflow, the following is automatically created and saved to the client's SharePoint CEL:

- **Notification Delivery Record:** notification_id, event_type, all contacts notified, channels used, delivery_timestamps, delivery_confirmations, server acknowledgements
- **Response Record:** action (Approve/Amend/No-response), responding_contact_id, response_timestamp, response_channel
- **Amendment Chain:** all amendment cycles with timestamps and advisor sign-offs
- **Approval Record:** final approve action, approving_contact_id, timestamp → triggers DocuSign envelope creation (Stage 5)
- **Non-Response Record (if applicable):** T+21 formal notice DocuSign envelope + Certificate of Completion

These records constitute proof of:
- Client was notified (PIPEDA — reasonable communication method)[^12]
- Delivery attempted via multiple channels
- Response (or non-response) is timestamped and attributed
- All amendment cycles captured
- Approval chain documented

### Outputs
- Notification Log entry per notification
- CEL entries for every action event
- Amendment Records (if Amend path)
- Approval Record → triggers Stage 5
- Non-Response Records and formal notices (if escalation reached)

### Failure Paths
- Tracked link click not received (client uses non-tracked browser, URL blocked): advisor monitors Notification Log for aged open items; 48-hour reminder fires regardless
- Email delivery failure (bounce): Make.com receives bounce notification → escalates to advisor immediately; CEL logs delivery failure
- SMS delivery failure: Make.com receives Twilio error → CEL logs; email remains primary channel
- Make.com webhook not received: retry queue (Make.com queues are not lost); max 50 concurrent runs then sequential queue[^39]

***

## Stage 5 — DocuSign Execution & Document Finalization

### Triggering Event
- Approval action from Stage 4 (Approve webhook received by Make.com) → DocuSign envelope created automatically

### Sequential Workflow Steps

**Step 5.1 — Signatory Lookup**
- Make.com reads Signatories List for client_id → retrieves Safety Manager role (current holder name + email) and Executive role (current holder name + email)
- Signing order: Routing Order 1 = Safety Manager; Routing Order 2 = Executive (fires automatically after Order 1 completes)
- If Signing Group configured for a role: any member of the group can complete that routing step[^40]

**Step 5.2 — Envelope Creation**
- Make.com DocuSign module: create envelope from template (matched to document_type)
- Envelope configuration:
  - Subject: `[Client Name] — [Document Type] — [Effective Date] — Action Required`
  - Role 1: Safety Manager (from Signatories List)
  - Role 2: Executive (from Signatories List)
  - CC: Vaquero compliance advisor email
  - CC: Vaquero system webhook email (triggers auto-archive on completion)
  - EventNotification configured: webhook fires on `envelope-completed`, `envelope-declined`, `envelope-voided`[^41][^4]
  - Expiry: 30 days (auto-void if not signed)
  - Auto-reminder: Day 2 and Day 5
- CEL entry: envelope_created, envelope_id, client_id, document_type, signatories, creation_timestamp

**Step 5.3 — Signing Reminder Cadence**

| Day | Action | Who |
|---|---|---|
| Day 0 | Envelope sent to Routing Order 1 (Safety Manager) | DocuSign automated |
| Day 2 | Auto-reminder to Order 1 if unsigned | DocuSign automated |
| Day 5 | Second auto-reminder | DocuSign automated |
| Day 7 | Make.com monitors envelope status via polling — if unsigned, alert to compliance advisor | Make.com automated + advisor (human) |
| Day 14 | Escalation: advisor direct contact + alternative signing group member activated if primary unavailable | Compliance advisor (human) |
| Day 21 | Void envelope; log void reason; re-issue to updated signatory or alternative route | Compliance advisor (human) initiates void |
| Day 30 | Auto-void if not already voided; Make.com receives void webhook → logs to CEL; re-issue decision required | Make.com automated + advisor |

**Step 5.4 — Signatory Unavailable / Change of Signing Officer**

- DocuSign envelopes include a signer-accessible "Notify your organization" button link (implemented as a custom page link in the email) where signatories can flag that a named officer has changed
- Alternative: embedded text in envelope body instructs signer to reply to Vaquero advisor email if the named individual is no longer in the role
- **Workflow triggered by signatory change flag:**
  1. Advisor receives notification
  2. Advisor uses DocuSign "Correct" feature to update recipient name/email (before any signing occurs) OR voids and re-issues if correction is not possible[^42]
  3. Signatories List updated with new individual for the affected role
  4. CEL entry: signatory_change, role, old_holder_name, new_holder_name, changed_by_advisor, timestamp
  5. MSA clause triggers: client must contractually notify Vaquero within 5 business days of signing authority change; CEL records compliance or non-compliance with this obligation
- **[FLAG FOR LEGAL REVIEW]:** If a departing employee signed a document in their last week before departure was processed in the system, the DocuSign audit trail proves signing occurred when the individual was still the system-of-record authorized contact. MSA language should explicitly address authority verification timing.

**Step 5.5 — Envelope Completion and Auto-Archive**

```
DocuSign envelope-completed event fires →
  Make.com receives webhook (EventNotification) →
  DocuSign module: Download signed document PDF →
  DocuSign module: Download Certificate of Completion PDF →
  SharePoint Upload: signed PDF → /[Domain]/[DocumentType]/[DocumentName]_v[version]_[date].pdf →
  SharePoint Upload: Certificate → /13-DocuSign-Completed/[DocumentType]/[EnvelopeID]_cert.pdf →
  SharePoint metadata stamped: docusign_envelope_id, signing_date, signatories[], version_number, approval_status="Active" →
  Retention label applied →
  CEL entry: envelope_completed, envelope_id, signing_date, signatories, document_path →
  Stage 3 Certification Tracker updated (if certification document): status="Renewed", new expiry date extracted →
  Make.com triggers client confirmation notification: "Your [document type] has been executed and is now active"
```

**Step 5.6 — DocuSign Certificate of Completion — Contents and COR Evidentiary Sufficiency**

Contents of every DocuSign Certificate of Completion:[^43][^3]
- Envelope ID (unique, traceable in DocuSign repository permanently)
- Document title
- Sender identity (name, email, organization)
- Per-recipient record: delivered timestamp, viewed timestamp, signed timestamp, IP address, geolocation
- Authentication method used (email, SMS OTP, KBA, ID verification)
- Signing sequence confirmation (Order 1 before Order 2)
- Electronic Record and Signature Disclosure consent captured
- SHA-256 document integrity hash (proves document unaltered post-signing)
- DocuSign retains transaction data permanently even after subscription ends[^3]

**COR Evidentiary Sufficiency Assessment:**
- DocuSign Certificate of Completion + signed PDF constitutes a defensible authorization chain satisfying ACSA COR Element 1 (management commitment — signed policy statement by authorized officer) and Element 8 (program administration — versioned, dated, authorized documents)[^44][^18]
- Alberta *Electronic Transactions Act* SA 2001 c E-5.5 grants electronic signatures equivalent legal standing to wet signatures
- DocuSign certificates have been submitted as evidence in court proceedings[^43][^3]
- **Sufficient as standalone compliance evidence** for safety program documents, SOPs, policy statements, training acknowledgements, orientation sign-offs, and most recurring compliance documents

**Documents Where Wet Signature May Still Be Required — [FLAG FOR LEGAL REVIEW]:**

| Document Type | Risk Assessment |
|---|---|
| Confined Space Entry Permits (OHS Code Part 5, s.45) | Part 5 requires "written" permit — likely acceptable electronically per ETA, but confirm with Alberta OHS[^21][^22] |
| First Aid Program documentation where OHS Code specifies "employer must sign" | Check specific Part 11 language — most sections require designation, not wet signature |
| Mine site entry documents under OHS Code Part 36 | Confirm — mine-specific requirements may exceed general OHS provisions |
| Union collective agreement documents where wet signature is a bargaining condition | Outside platform scope but note for clients in unionized environments |

**Step 5.7 — Declined or Voided Envelope**

```
envelope-declined event fires →
  Make.com receives webhook →
  CEL entry: envelope_declined, envelope_id, declining_contact, decline_reason, timestamp →
  Compliance advisor alerted immediately →
  Advisor reviews: route to Amend cycle (Stage 4) or investigate signatory issue →
  
envelope-voided event fires →
  Make.com receives webhook →
  CEL entry: envelope_voided, envelope_id, void_reason, voided_by, timestamp →
  Void logged as part of document lifecycle in SharePoint →
  Re-issue decision required from compliance advisor →
  Re-issue creates new envelope_id; links back to voided_envelope_id in metadata
```

### Outputs
- Signed document PDF in correct SharePoint library
- Certificate of Completion in `/13-DocuSign-Completed/`
- CEL entries for all envelope events
- Updated Certification Tracker record (if applicable)
- Client confirmation notification (auto-pushed)
- Amendment records and re-issue chain (if declined/voided)

***

## Stage 6 — SOP & Safety Program Update Propagation

### Triggering Events
- Regulatory change classified as "SOP Update Required" (Stage 3 Classification A)
- Periodic SOP review cycle (annual default — ACSA COR Element 8)[^18]
- Client-initiated SOP update request (via Amend path from any stage)
- Certifying Partner or COR audit finding requiring SOP revision

### Sequential Workflow Steps

**Step 6.1 — Impact Assessment (Human Required)**
- Compliance advisor receives Stage 3 regulatory change record
- Advisor reviews: which SOP templates are affected by the change
- Advisor queries SOP Registry (SharePoint list): filters by `sop_template_id` where affected regulation is referenced → returns list of all clients with active versions of affected SOPs
- Advisor documents in Regulatory Change Record: change_id, affected_regulation, affected_sop_template_ids[], affected_client_count, effective_date, urgency_class
- **Decision Point (Human Required):** Advisor classifies change impact and approves propagation — no automated SOP update proceeds without advisor sign-off

**Step 6.2 — Base Template Update**
- Compliance advisor (or safety professional) updates the base SOP template in Vaquero's internal Master Template Library
- Template update creates a new version in Master Template Library with: version_number, regulatory_change_id, change_summary, effective_date, updated_by_user_id
- All template edits are version-controlled in SharePoint (no overwrite)
- **Decision Point (Human Required):** Second compliance advisor or manager reviews updated template for accuracy and regulatory compliance before marking as `template_status = "Ready_for_propagation"`

**Step 6.3 — Client Customization Identification**
- Make.com reads affected client list from Step 6.1
- For each client, Make.com reads their current active SOP version from their SOP Registry
- Make.com compares `customization_flag` field: if `"Y"` → route to customization review sub-path
- Customization Review Sub-path: compliance advisor reviews client-specific custom sections against the base template update; determines whether customization is still valid, needs modification, or conflicts with regulatory change
- Customization decisions documented in SOP Propagation Record per client

**Step 6.4 — Client-Specific SOP Build**
- Make.com generates client-specific updated SOP by merging: updated base template + preserved client customizations (as validated in Step 6.3)
- Generated document stored in `/00-Pending-Approval/` for the client with: sop_template_id, base_version, client_version, regulatory_change_id, customization_preserved (Y/N), build_timestamp

**Step 6.5 — Client Notification and Approval (Routes to Stage 4)**
- Make.com triggers Stage 4 Push Notification for each affected client
- Notification contains: change summary in plain language, link to view updated SOP, Approve / Amend action buttons
- Clients process sequentially via Stage 4 → Stage 5 approval and DocuSign execution
- Each client is an independent workflow — client A's approval does not affect client B's cycle

**Step 6.6 — SOP Status Tracking Across 50+ Clients**

SOP Propagation Tracker (SharePoint list) — one record per client per propagation event:

| Field | Values |
|---|---|
| propagation_id | Unique ID for this change event |
| client_id | — |
| sop_template_id | — |
| regulatory_change_id | — |
| client_status | Pending / Notified / In_Amend / Approved / DocuSign_Sent / Executed / Active |
| amendment_cycle | 0, 1, 2, … |
| last_activity_timestamp | — |
| days_since_notification | Calculated field |
| open_reminder_count | — |

- Vaquero operations dashboard reads SOP Propagation Tracker — shows all 50+ clients sorted by status and days_since_notification
- Clients with `status = "In_Amend"` for >7 days auto-escalate to compliance advisor queue
- Clients with `status = "Notified"` for >14 days trigger escalation (Stage 4 escalation ladder applies)

**Step 6.7 — SOP Activation**
- After DocuSign execution completes (Stage 5): Make.com updates SOP Registry for client
  - Previous version: `status = "Superseded"`, `superseded_by = [new_version_id]`, `superseded_date = [execution_date]`
  - New version: `status = "Active"`, `regulatory_change_id`, `effective_date`, `activation_method = "DocuSign_execution"`
- Old SOP version retained in SharePoint with superseded metadata — never deleted within retention period
- SOP version history is now fully traceable: document → version → regulatory change that triggered update → approval event → DocuSign execution

**Step 6.8 — Data Isolation Safeguard**
- Site-per-client SharePoint architecture ensures complete data isolation: an SOP written to Client A's site has no access path to Client B's site[^10][^9]
- Make.com scenarios use `client_id` as the primary key for all SharePoint module site URL parameters — client_id cannot be substituted in a running scenario without a new scenario invocation
- SOP Propagation Tracker is stored in Vaquero's internal SharePoint (not client sites) — clients do not see other clients' propagation status
- No shared document libraries across client sites — each site is a separate SharePoint site collection[^9]

### Version History Requirements (ACSA COR Element 8)
- Every active SOP must show: current version number, effective date, authorizing signature (DocuSign certificate link), review cycle date, previous version reference
- Superseded versions retained with full metadata — auditors can request "the version in force on date X" and the system returns the exact version active at that date
- Regulatory change that triggered each version is linked by change_id — audit package can show: regulation changed on [date] → SOP updated on [date] → client approved on [date] → signed by [roles] on [date]

### Outputs
- Updated SOP in client SharePoint with full metadata and version chain
- SOP Propagation Tracker updated per client
- Regulatory Change Record with resolution status
- CEL entries for all propagation events
- Client confirmation notifications on activation

***

## Stage 7 — Asset & Inspection Compliance Workflow

### Asset Registry (SharePoint List — Assets Domain)

Fields per asset: client_id, asset_id, asset_type, make, model, year, VIN/serial, registered_weight (for CVIP applicability), assigned_site, inspection_schedules[] (daily/weekly/monthly/annual), last_inspection_date, next_inspection_due, CVIP_expiry_date, CVIP_inspector_facility, status (Active / Out-of-Service / Disposed)

### Recurring Inspection Schedule Monitoring

**Make.com Scheduled Scenario (runs daily at 06:00 client local time):**

For each active asset across all 50+ clients:
1. Read `next_inspection_due` from Asset Registry
2. Calculate days until due: if ≤ threshold → trigger alert
3. For CVIP: use 90/60/30/7-day threshold ladder (same as certification)[^29]
4. For daily inspections: if no record submitted for today → trigger alert at 09:00 client local time
5. For overdue inspections (past due date with no completion record): immediate escalation

### Sequential Workflow Steps

**Step 7.1 — Inspection Due Alert**
- Make.com triggers Stage 4 push notification to client Safety Manager
- Notification content: asset_id, asset_name, inspection_type, due_date, instructions
- For daily pre-use inspections: notification sent via mobile app push (field app) + email to Safety Manager
- Approve/Amend not required for simple inspection reminders (informational push); required for CVIP renewal confirmation

**Step 7.2 — Inspection Completion (Mobile App Path)**
1. Worker opens field app → selects asset from assigned asset list → completes inspection checklist (offline-capable)
2. Each checklist item: Pass / Fail / N/A + notes field + photo capture option
3. GPS stamp + device_timestamp recorded at form completion
4. Worker signature captured on device (touchscreen)
5. On reconnect: sync fires → API writes record to SharePoint `/02-Assets/[asset_type]/[asset_id]/Inspections/[date]_[inspection_type].json`
6. Make.com triggered by new item: validates metadata completeness → updates Asset Registry: `last_inspection_date`, `next_inspection_due` calculated
7. CEL entry: inspection_completed, asset_id, worker_id, completion_timestamp, capture_method = "mobile_app"

**Step 7.3 — Inspection Completion (Office Scan Backup Path)**
1. Worker completes paper form in field
2. Office staff scans → uploads to `/00-Intake-Queue/` via SharePoint upload
3. Stage 2 ingestion pipeline triggered; metadata entered by uploading staff: paper_record_date, site, asset_id, inspection_type, reason_paper_used
4. Make.com routes to Asset Registry update; flags as `capture_method = "paper_scan_upload"`
5. Compliance dashboard flags for advisor review — all paper_scan inspections require acknowledgement
6. Asset Registry updated with `last_inspection_date` = paper_record_date (manually entered)

**Step 7.4 — Inspection Failure / Non-Compliant Asset**

```
Inspection record submitted with any "Fail" item →
  Make.com reads record →
  Asset Registry: asset_status updated to "Non-Compliant" →
  CEL entry: inspection_fail, asset_id, fail_items[], worker_id, timestamp →
  
  Immediate push notification to Safety Manager:
    "Asset [ID] failed inspection on [date]. Fail items: [list]. Asset must be taken out of service pending remediation."
  
  Internal Vaquero alert: compliance advisor notified →
  
  Remediation workflow initiated:
    Asset_status = "Out_of_Service" →
    Remediation record created: asset_id, fail_items[], assigned_remediation_contact, deadline →
    48-hour reminder cycle on remediation record →
    
  Remediation completion:
    Client uploads repair documentation / re-inspection record →
    Stage 2 ingestion pipeline →
    Compliance advisor reviews and approves return-to-service →
    Asset_status updated to "Active" →
    DocuSign return-to-service authorization (if required by client's SOP) →
    CEL entry: remediation_complete, asset_id, authorization_timestamp
```

- **Decision Point (Human Required):** Compliance advisor must review and authorize return-to-service for any asset that failed inspection — this cannot be automated

**Step 7.5 — CVIP Records Management**

- CVIP applies to commercial vehicles >11,794 kg, truck tractors, semi-trailers, full trailers, and buses >10 passengers [UNVERIFIED: confirm exact weight threshold with Alberta Transportation][^29]
- CVIP inspection performed by licensed CVIP facility and certified mechanic only[^45][^29]
- Physical CVIP inspection certificate must be kept in the vehicle + copy at operator's office[^46]
- Digital copy stored in `/02-Assets/Vehicles/CVIP/[asset_id]_CVIP_[year].pdf`
- CVIP expiry tracked in Asset Registry; 90/60/30/7-day alert ladder same as certifications
- **[UNVERIFIED]:** Whether semi-annual CVIP applies and to which specific vehicle categories in Alberta — confirm with Alberta Transportation before building semi-annual trigger logic
- **[UNVERIFIED]:** No confirmed government portal for CVIP digital submission — records retained by operator; platform stores as internal compliance records only
- Platform notification on CVIP approaching expiry: push notification to client with reminder that CVIP must be performed by licensed facility (cannot be self-performed)[^45]
- Physical certificate placement: Make.com sends DocuSign acknowledgement to Safety Manager confirming physical certificate has been placed in vehicle

### Hybrid Field Data Capture Model

| Scenario | Primary Path | Backup Path | Metadata Distinction |
|---|---|---|---|
| Active cellular coverage | Mobile app online submission | N/A | `capture_method = "mobile_app_online"` |
| No cellular (offline sync) | Mobile app offline; sync on reconnect | N/A | `capture_method = "mobile_app_offline_sync"` |
| Mobile device unavailable | Paper form completed | Office staff scans + uploads | `capture_method = "paper_scan_upload"` |
| Device malfunction | Paper form | Notify Vaquero; issue replacement device | `capture_method = "paper_scan_upload"` + `device_issue_flag = "Y"` |

- Paper scan records are flagged in COR audit package with explanatory note
- COR auditor visibility: paper_scan records are valid records; absence of GPS/device_timestamp noted but not disqualifying if explanation documented[^26]

***

## Stage 8 — Chemical, SDS & Environmental Records Workflow

**Note: All items in this stage marked [TEMPORARY — PENDING LEGAL REVIEW] where government submission requirements are unconfirmed. No automated regulatory submission workflows are built until legal review is complete.**

### Step 8.1 — SDS Library Management [INTERNAL RECORD-KEEPING]

- Employer obligation: current SDS (<3 years old) for every hazardous product in the workplace[^47]
- Supplier must update SDS within 90 days of significant new information — but does not proactively notify employer[^48]
- **⚠ CORRECTION — WHMIS designation:** "WHMIS 2015" is retired as of December 14, 2025 (HPR transition ended). All SDS metadata fields, labels, and client communications must reference **WHMIS (GHS Rev 7/8)**. The string "WHMIS 2015" must be rejected by platform metadata validation.
- SDS stored in `/09-WHMIS-SDS/[chemical_name]/[SDS_version]_[date].pdf`
- SDS Registry (SharePoint list): chemical_name, supplier, CAS_number, intake_date, version_number, sds_expiry_flag_date (3 years from intake_date), location_used_in_field (Y/N), field_accessible (Y/N)
- Make.com scheduled scenario (weekly): scans SDS Registry for records where `intake_date` > 3 years → creates alert → push notification to Safety Manager: "SDS for [chemical] is approaching 3 years; request updated SDS from supplier"
- Field accessibility: SDS must be accessible to workers during their shift without delay (OHS Code Part 4 — WHMIS) — mobile app displays SDS as read-only PDF; offline copy pre-cached on device for chemicals in use at assigned site[^49]
- **[UNVERIFIED]:** Whether digital-only SDS on mobile app without paper backup satisfies OHS Code Part 4 in remote/no-connectivity sites — maintain paper backup protocol until confirmed

**Regulatory submission required:** No — SDS library is internal record-keeping only; no government submission required under WHMIS (GHS Rev 7/8)[^50]

### Step 8.2 — Chemical Inventory Management [INTERNAL RECORD-KEEPING]

- Chemical inventory maintained as SharePoint list: chemical_name, SDS_record_id, quantity_on_hand, location, date_added, date_removed, responsible_person
- New chemical added: compliance advisor notified → SDS intake workflow triggered → SDS ingested to library before chemical is permitted for use
- Make.com alert: if `sds_record_id` linked to chemical is flagged as expired → immediate alert to Safety Manager and advisor
- Retention: chemical inventory records retained for the period the chemical is in use plus 3 years (best practice; no Alberta-specific statutory period confirmed for standard workplaces)[^26]
- **[FLAG FOR LEGAL REVIEW]:** Clients with EPEA approvals or AER operating approvals may have chemical inventory reporting conditions in their approval — confirm per client before finalizing retention and reporting workflow

**Regulatory submission required:** No for standard workplaces (internal only). **[FLAG FOR LEGAL REVIEW]:** EPEA approval conditions may create submission obligations — do not automate any submissions until confirmed.

### Step 8.3 — Soil and Water Sample Tracking [TEMPORARY — PENDING LEGAL REVIEW]

**[TEMPORARY WORKFLOW — store records only pending legal review and environmental consultant engagement per client]**

- Chain of Custody (COC) form stored in `/04-Site-Environmental/Sampling/[sample_id]_COC.pdf`
- Lab results stored in `/04-Site-Environmental/Sampling/[sample_id]_LabResult_[date].pdf`
- Sampling Registry (SharePoint list): sample_id, sample_type (soil/water), collection_date, collector_id, GPS_location, lab_name, lab_accreditation_number, COC_form_id, result_received_date, result_summary, threshold_exceeded (Y/N), regulatory_review_required
- On lab result ingestion: Make.com checks `threshold_exceeded` field → if "Y": immediate push notification to compliance advisor AND Safety Manager; flag = "REQUIRES_ENVIRONMENTAL_REVIEW"; no automated regulatory submission triggered
- **Immediate reporting obligation under EPEA:** any spill or adverse environmental effect must be reported verbally immediately to Alberta Environment hotline (1-800-222-6514) — platform captures this obligation as a notification only; actual call must be made by client representative; call confirmation stored as CEL entry[^51]
- **[FLAG FOR LEGAL REVIEW]:** Regulatory thresholds for Alberta Tier 1/2 soil and groundwater guidelines, distinction between EPEA vs. AER reporting obligations, and specific threshold values require environmental consultant review before any automated compliance trigger is built[^52]

**Regulatory submission required:** [FLAG FOR LEGAL REVIEW] — possible under EPEA and AER depending on client operations and findings. Do not build automated submission until legal/environmental review complete.

### Step 8.4 — Well Tracking Records [TEMPORARY — PENDING LEGAL REVIEW]

- AER-regulated operators must report well activity via **Petrinex** (provincial energy data system) and AER OneStop for applications[^32][^53]
- Petrinex and AER OneStop are **separate government submission systems** — platform does not attempt to replicate or integrate
- Platform role: store copies of AER-related documents (well licenses, remediation certificates, inactive well notices, AER correspondence) in `/04-Site-Environmental/Well-Tracking/`
- AER structured well data (ST37, General Well Data) published by AER in TXT/shapefile format (daily/weekly/monthly) can be ingested for reference/cross-check only — not a submission pathway[^54][^32]
- **[UNVERIFIED]:** Whether AER OneStop has an API for automated submission status monitoring — assume no; monitoring is via web portal only
- **[TEMPORARY WORKFLOW]:** Store documents → flag for advisor review → advisor confirms submission obligation per client and confirms submission completed via AER OneStop → CEL records: submission_confirmed, submitted_by, AER_reference_number, timestamp

**Regulatory submission required:** Yes (via Petrinex/AER OneStop) — these are external systems; platform manages supporting document storage and advisor notification only.

### Step 8.5 — Environmental Monitoring Logs [TEMPORARY — PENDING LEGAL REVIEW]

- Compliant environmental monitoring log under EPEA must include: parameter, measurement method, detection limit, result, date/time, sampler identity, instrument calibration records, GPS/grid location[^55]
- Annual Emissions Inventory Report (AEIR): required for EPEA-approved facilities with air emissions; submitted per AER Air Monitoring Directive[^56]
- **[TEMPORARY WORKFLOW]:** Environmental monitoring records ingested to `/04-Site-Environmental/Environmental-Monitoring/` with standard metadata + `compliance_flag = "REQUIRES_REVIEW"` + `potential_submission_required = "Y"`; compliance advisor reviews all records; no automated government submissions until legal review complete
- **[FLAG FOR LEGAL REVIEW]:** Specific EPEA approval conditions vary by client — each client's EPEA approval (if held) must be reviewed to determine monitoring, recording, and submission obligations

**Regulatory submission required:** Likely yes for EPEA-approved facilities — confirm per client.

### Summary: Government Submission Requirements

| Record Type | Internal Only | Submission Required | System | Platform Role |
|---|---|---|---|---|
| SDS library | ✓ | No | SharePoint | Store and manage |
| Chemical inventory | ✓ (standard) | [FLAG FOR LEGAL REVIEW] per EPEA clients | SharePoint | Store and manage |
| Soil/water samples | — | [FLAG FOR LEGAL REVIEW] | Alberta Environment/AER | Store records; notify advisor |
| Well tracking | — | Yes — Petrinex/AER OneStop[^32] | External government system | Store supporting docs; confirm submission |
| Environmental monitoring | — | Yes (AEIR for EPEA facilities)[^56] | AER submission | Store source data; notify advisor |
| WHMIS SDS | ✓ | No | SharePoint | Store and manage; label as WHMIS (GHS Rev 7/8) |

***

## Stage 9 — Audit Trail, Reporting & Compliance Evidence

### COR Audit Evidence Package Components (All Four Domains)

**COR Issuing Body and Audit Cycle (O&G Clients — AB/BC/SK):** Energy Safety Canada (ESC). External audit required every 3 years (≥80% score to pass); annual maintenance audit required in years 2 and 3 (≥60% score to pass). COR for construction clients issued by provincial CORAs (AB=ACSA, BC=BCCSA, etc.). Audit cycle position tracked in Certification Tracker and surfaced in Quarterly Dashboard.

**Required under ACSA 2023 Audit Tool — Three Verification Techniques:**[^57][^44]

| Technique | Platform Evidence Source |
|---|---|
| Documentation | SharePoint document versions with metadata + DocuSign certificates of completion |
| Interviews | Interview summary records stored as advisor-uploaded documents; template in `/11-Audit-Reports/Interview-Records/` |
| Observations | Site walkabout inspection reports from mobile app or paper scan; field observation logs |

**Evidence Package Contents by COR Element:**

| COR Element | Key Evidence Documents | SharePoint Location |
|---|---|---|
| Element 1: Management Leadership | Signed safety policy statement (DocuSign cert + signed PDF); executive sign-off records | `/01-Safety-Policy/` + `/13-DocuSign-Completed/` |
| Element 2: Hazard ID and Assessment | JHAs, FLRAs, formal hazard assessments; dates and authorization | `/03-Processes/JHAs/` |
| Element 3: Hazard Control | SOPs, LOTO procedures, confined space code of practice; version history | `/03-Processes/SOPs/` |
| Element 4: Ongoing Inspections | Equipment inspection logs (mobile app + paper scan); site walkabout reports | `/02-Assets/Inspections/` + `/04-Site-Environmental/Walkarounds/` |
| Element 5: Qualifications, Orientation, Training | Orientation sign-off records (DocuSign); training completion records; ticket scans | `/01-People/Training/` + `/01-People/Orientations/` |
| Element 6: Emergency Response | Signed ERP; drill records; ERP review dates | `/03-Processes/ERP/` |
| Element 7: Incident Reporting and Investigation | Incident investigation reports (retained 2 years minimum[^25]); near miss records; OHS notification records | `/04-Site-Environmental/Incidents/` |
| Element 8: Program Administration | SOP version history with regulatory change links; annual review records; meeting minutes; all DocuSign approval chains | `/03-Processes/SOPs/` + `/11-Audit-Reports/` |

### Data Retention Periods — Confirmed and Flagged

| Document Type | Retention Period | Authority | Status |
|---|---|---|---|
| Incident investigation reports | 2 years minimum | OHS Act s.33[^25] | Confirmed |
| Confined space training (no incident) | 1 year | OHS Code s.46/58[^16] | Confirmed |
| Confined space training (incident occurred) | 2 years | OHS Code s.46/58[^16] | Confirmed |
| JHSC training records | 2 years after leaving JHSC | OHS Reg s.3.27[^16] | Confirmed |
| Asbestos training records | 10 years | OHS Reg s.6.32[^16] | Confirmed |
| Hazardous drug training records | 3 years | OHS Reg 6.58(1)[^16] | Confirmed |
| Environmental/air/soil test results | 10 years (best practice) | Expert consensus[^26] | Best practice — unconfirmed statutory |
| Worker orientation and training (general) | 5 years (best practice) | Expert consensus[^26] | Best practice — confirm per record type |
| CVIP inspection certificates | 3 years | NSC/CVSE[^17] | Confirmed (NSC framework) |
| Vehicle maintenance records | 3 years | NSC/CVSE[^17] | Confirmed |
| Trip inspection reports | 3 months | NSC[^17] | Confirmed |
| SDS records | Duration of use + 3 years (best practice) | WHMIS (GHS Rev 7/8) / expert consensus | Best practice |
| All other OHS records | 5 years default | Best practice[^26] | [UNVERIFIED — confirm per record type] |
| MSA and legal agreements | 7 years | Standard commercial practice | Best practice |

**Platform Enforcement:** All retention periods enforced via Microsoft Purview retention labels applied at document ingestion (Stage 2 Step 2.3) — documents cannot be deleted before `retention_end_date`[^23]

### COR Audit Evidence Package Auto-Compilation

**Step 9.1 — On-Demand Evidence Package Request**

```
Compliance advisor or client triggers COR audit package request →
  Make.com reads COR Audit Period (start_date, end_date, COR_element_scope) →
  For each of 8 COR elements:
    Query SharePoint document libraries: filter by client_id, date range, document types mapped to element →
    Query CEL: filter by client_id, event_types relevant to element, date range →
    Query DocuSign-Completed library: all signed documents in audit period →
  Aggregate results into Evidence Package manifest (SharePoint list: evidence_package_id, element, document_count, documents[]) →
  Generate PDF index document: table of contents with document names, versions, dates, locations →
  Zip package or create SharePoint page with all links →
  Push notification to compliance advisor: "COR evidence package for [client] ready for review" →
  Advisor reviews package completeness →
  [Human Decision Point: advisor certifies package is complete before sharing with auditor]
```

- AI gap detection: Make.com / AI module flags missing evidence types per element (e.g., no interview records found for Element 2 in audit period) → advisor alerted before package is finalized
- Package does not include client personal information beyond what is necessary for audit (PIPA s.7 minimum collection principle)[^13]

### Ongoing Client-Facing Compliance Reports (Push Cadence)

**Monthly Compliance Status Report** (pushed to Safety Manager on first business day of each month):
- Certifications by domain: count Active / Expiring_90 / Expiring_30 / Expired
- Inspections completed vs. due in past 30 days: completion rate by asset type
- Open action items (count and oldest item age)
- SOP updates applied in past 30 days
- Notifications sent and response rates
- Paper scan ratio (paper_scan_upload vs. mobile_app as % of total field records) — drives toward digital capture improvement

**Quarterly Certification Expiry Dashboard** (pushed to Safety Manager + Executive):
- 12-month forward view of all certification expiry dates (People + Assets)
- COR audit cycle position (Year 1/2/3, months until next required audit)
- CRSP CPD points status (updated when available from BCRSP)

**Annual SOP Version Log** (pushed to Safety Manager):
- All SOPs updated in past 12 months: document name, version old → new, regulatory_change_trigger, execution date

**On-Demand Reports Available to Compliance Advisor:**
- SOP Propagation Status (all 50+ clients, current update cycle)
- Certification Expiry Forward Calendar (all clients, all certifications)
- Open Escalation Items (no-response cases, advisor queue)
- Paper Scan Ratio by Client

### Internal Vaquero Operations Reporting (50+ Client Management)

**Vaquero Operations Dashboard (auto-updated by Make.com, real-time SharePoint list view):**
- All clients with open critical escalations (T+7 or later in no-response path)
- All clients with expired certifications (status = "Expired")
- All clients with assets in "Non-Compliant" or "Out-of-Service" status
- SOP Propagation Tracker: % of clients at "Active" status per propagation event
- DocuSign envelopes unsigned for >7 days (advisor review required)
- Regulatory change candidates awaiting advisor classification (>48 hours old)
- Error log: all Make.com scenario failures in past 48 hours

**Automated Weekly Advisor Queue Report** (pushed to compliance advisors every Monday):
- Open items by client, sorted by age
- Items due for advisor action within 7 days
- Clients with upcoming COR audit deadlines (90 days)

### Steps Requiring Named Human Sign-Off (Cannot Be Automated)

| Step | Reason | Role |
|---|---|---|
| Regulatory change classification (Stage 3) | Classification determines client-facing actions; wrong classification = liability | Compliance advisor |
| SOP update base template approval (Stage 6) | Regulatory accuracy; incorrect SOP = OHS violation for 50+ clients | Senior compliance professional |
| Onboarding completion gate (Stage 1) | Confirms all domains are adequately covered before compliance management begins | Compliance advisor |
| Baseline gap assessment (Stage 1) | Risk classification requires professional judgment | Compliance advisor |
| Return-to-service after failed inspection (Stage 7) | OHS duty of care; cannot be delegated to automation | Compliance advisor |
| COR evidence package certification (Stage 9) | Auditor-facing certification requires professional accountability | Compliance advisor |
| Non-response formal notice issuance (Stage 4, T+21) | Legal notice; must be authorized by a named individual | Compliance advisor + authorized officer |
| DocuSign signatory change authorization (Stage 5) | Authority chain integrity; legal consequence of wrong signatory | Compliance advisor |
| firecrawl-sync.py UNRESOLVED_MANUAL_REQUIRED items (Stage 3) | Zero Guess Rule — ambiguous regulatory source results cannot be auto-resolved | Compliance advisor |

***

## End-to-End Workflow Sequence: All 9 Stages Connected

```
[CLIENT ENGAGEMENT]
    ↓
STAGE 1: ONBOARDING
    → Intake form → SharePoint provisioning → MSA DocuSign → Signatories List → 
      Contact preferences → Document intake → Gap assessment [human] → Client = Active
    ↓
STAGE 2: INGESTION
    → Intake Queue watch → Classification [auto + human fallback] → 
      Metadata stamp → SharePoint write → Retention label → CEL log
    ↓
STAGE 3: MONITORING
    ┌──────────────────────────────────────────────────────────┐
    │ RSS/scraper → Regulatory change candidate →              │
    │   [Human: advisor classifies] →                          │
    │   Classification A → Stage 6 (SOP update)               │
    │   Classification B → Certification Tracker update        │
    │   Classification C → Informational push only             │
    │                                                          │
    │ Certification Tracker → 90/60/30/7-day ladder →         │
    │   Threshold breach → Stage 4 push notification          │
    │                                                          │
    │ Inspection Schedule → Approaching due/overdue →         │
    │   Stage 4 push notification / Stage 7                   │
    └──────────────────────────────────────────────────────────┘
    ↓
STAGE 4: PUSH NOTIFICATION & APPROVAL LOOP ← ← ← ← ← (recurring entry from Stage 3, 6, 7)
    → Triggering event → Generate notification → Multi-channel delivery →
    ┌──────────────────────────────────────────────────────────┐
    │ Response: APPROVE → Stage 5                             │
    │ Response: AMEND → Amend cycle → advisor → revised push → repeat │
    │ No response: 48h reminder → ... → T+7 human escalation  │
    │   → T+14 executive contact → T+21 formal notice         │
    └──────────────────────────────────────────────────────────┘
    ↓ (on Approve)
STAGE 5: DOCUSIGN EXECUTION
    → Signatory lookup → Envelope creation → Safety Manager signs →
      Executive signs → envelope-completed webhook →
    → Signed PDF + Certificate → SharePoint auto-archive →
    → Certification Tracker updated → Client confirmation push →
    → CEL entry
    ↓
    [Document is now Active; loop returns to Stage 3 monitoring with new expiry dates]

STAGE 6: SOP PROPAGATION ← (enters from Stage 3 Classification A)
    → Impact assessment [human] → Base template update [human review] →
    → Per-client customization check → Client-specific SOP build →
    → Feeds Stage 4 for each affected client simultaneously (parallel child scenarios) →
    → Each client traverses Stage 4 → Stage 5 independently →
    → SOP Registry updated per client on execution →
    → Version history with regulatory_change_id linked

STAGE 7: ASSET INSPECTION ← (recurring; enters from Stage 3 inspection schedule)
    → Daily/weekly/monthly/annual inspection alerts →
    → Mobile app primary path → SharePoint write → Asset Registry update →
    → Paper scan backup path → Intake Queue → Stage 2 pipeline → Asset Registry update →
    → Fail: Non-Compliant status → Push alert → Remediation workflow [human gate] →
    → CVIP: 90/60/30/7-day ladder via Stage 4

STAGE 8: CHEMICAL/SDS/ENVIRONMENTAL ← (ongoing; triggered by new additions or alerts)
    → SDS intake → SDS Registry → 3-year alert →
    → Chemical inventory → New chemical → SDS required before use →
    → Sampling → COC + lab result → Threshold check → Advisor alert [human gate] →
    → All environmental records: [TEMPORARY] store and notify pending legal review

STAGE 9: AUDIT TRAIL / REPORTING
    → All stages continuously write to CEL →
    → Monthly/quarterly reports auto-pushed to clients →
    → COR evidence package: on-demand compilation → advisor review [human gate] →
    → Operations dashboard: real-time advisor view →
    → Retention labels enforce minimum retention periods
```

### Circular and Recurring Loops

1. **Core compliance loop:** Stage 3 monitoring → Stage 4 push → Stage 5 execute → SharePoint archive → Stage 3 watches new expiry dates → loop
2. **SOP update loop:** Stage 3 detects regulatory change → Stage 6 propagates → Stage 4 push per client → Stage 5 signs → Stage 3 monitors new SOP version → loop
3. **Amendment loop:** Stage 4 Amend → advisor revision → Stage 4 revised push → repeat until Approve → Stage 5 → loop terminates
4. **No-response escalation loop:** Stage 4 → 48h reminder → 48h → ... → human escalation → formal notice → loop terminates on response or formal non-compliance documentation
5. **Inspection loop:** Stage 7 schedule triggers → Stage 4 alert → field completion → Stage 2 ingestion → Stage 7 asset registry update → next inspection scheduled → loop
6. **DocuSign envelope monitoring loop:** Stage 5 creates envelope → Day 2/5 reminders → Day 7 advisor check → Day 14 escalation → Day 21 void/re-issue → loop
7. **Firecrawl verification loop:** Compliance matrix generated → firecrawl-sync.py runs → RESOLVED items close in matrix tracker → UNRESOLVED items routed to advisor manual review → quarterly re-run forces new resolution cycle → loop

***

## All Failure Paths Across the Full System

| Failure Scenario | Detected By | Response | CEL Entry |
|---|---|---|---|
| SharePoint provisioning failure | Make.com error handler | Alert ops team; manual provision | ✓ |
| Document ingestion failure (write error) | Make.com error handler | 3 retries; hold in queue; alert advisor | ✓ |
| Document classification failure | Make.com below-confidence threshold | Route to advisor queue | ✓ |
| RSS feed unreachable | Make.com error handler | Alert ops; manual advisor check | ✓ |
| Web scraper error | Make.com error handler | 3 retries; alert advisor | ✓ |
| Advisor fails to review regulatory candidate >48h | Make.com escalation scenario | Escalate to operations manager | ✓ |
| Notification email bounce | Email delivery failure event | Immediate advisor alert; channel review | ✓ |
| SMS delivery failure (Twilio) | Twilio error response | CEL log; email remains primary | ✓ |
| Client no response (T+7, T+14, T+21) | Make.com age-monitoring scenario | Escalation ladder as defined in Stage 4 | ✓ |
| DocuSign envelope unsigned >7 days | Make.com polling or webhook timeout | Advisor alert; signing group activation | ✓ |
| DocuSign envelope declined | DocuSign webhook | Advisor alert; Amend cycle or investigate | ✓ |
| DocuSign envelope voided | DocuSign webhook | CEL log; re-issue decision required | ✓ |
| Signatory change mid-process | Client flag or advisor discovery | DocuSign Correct or void+re-issue; Signatories List updated | ✓ |
| Mobile app sync failure (field connectivity) | App sync retry failure | Local retention; re-sync on reconnect; no data loss | ✓ on sync |
| Make.com scenario timeout (>45 min)[^58] | Make.com execution error | Redesign as chained sub-scenarios | ✓ |
| Make.com >50 concurrent webhook runs[^39] | Queue overflow | Queue serialized; no data lost; processing slows | N/A (no failure) |
| Asset fails inspection | Inspection record with Fail item | Stage 7 non-compliant workflow; Out-of-Service status | ✓ |
| CVIP expired without renewal | Stage 3 Certification Tracker T+0 | Expired status; COR risk flag; all-channel alert | ✓ |
| SDS >3 years without renewal | Make.com weekly SDS scan | Push alert to Safety Manager; advisor alerted | ✓ |
| Environmental threshold exceeded | Lab result ingestion | Immediate advisor alert; [TEMPORARY] no auto-submission | ✓ |

***

## Prioritized Operational Risks at 50+ Client Scale

**Risk 1 — Make.com log retention (60 days) is insufficient for multi-year compliance evidence**
- Mitigation: CEL (SharePoint list with retention label) is the system of record — every compliance event written to CEL at the moment it occurs[^1][^2]
- Severity: Critical if not mitigated

**Risk 2 — Regulatory change misclassification by compliance advisor**
- One advisor incorrectly classifying a regulatory change affects all 50+ clients simultaneously
- Mitigation: Dual advisor review for Classification A (SOP update required) changes; classification documented with reasoning in Regulatory Change Record
- Severity: High

**Risk 3 — Signatory not updated when personnel change occurs**
- If a Safety Manager leaves and client does not notify Vaquero, all future envelopes route to an invalid address
- Mitigation: MSA contractual obligation; signed envelope bounce detection; signing group model with multiple members; annual signatory confirmation push notification
- Severity: High

**Risk 4 — Cross-client data contamination in Make.com scenarios**
- A scenario error that uses the wrong `client_id` parameter could write to the wrong SharePoint site
- Mitigation: Site-per-client architecture means wrong writes go to wrong client site (not cross-readable); all scenario inputs validate `client_id` before any write; scenario error logging; Vaquero admin site access audited via Unified Audit Log
- Severity: High

**Risk 5 — Make.com scenario timeout at 50+ client propagation events**
- SOP update propagating to 50+ clients in a single scenario will timeout[^58]
- Mitigation: Dispatcher pattern — master scenario sends webhook to child scenario per client batch; parallel child scenarios handle individual client propagation[^36][^39]
- Severity: Medium (operational failure, not compliance failure, if properly handled)

**Risk 6 — DocuSign wet signature requirement unresolved for specific document types**
- Confined space entry permits and specific OHS Code documents where "written" form is specified
- Mitigation: [FLAG FOR LEGAL REVIEW] — use DocuSign as default pending legal confirmation; maintain paper fallback procedure documentation for identified risk documents
- Severity: Medium — legal confirmation resolves to Low

**Risk 7 — Environmental and well tracking record workflows are temporary**
- Environmental records stored but submission workflows not built pending legal review
- Mitigation: Clearly marked [TEMPORARY] status in platform; advisor review gate on all environmental records; no client reliance on platform for government submissions in Stage 8
- Severity: Medium — legal review resolves

**Risk 8 — Paper scan backup records create audit trail asymmetry**
- Paper_scan_upload records have no GPS, no device_timestamp, no worker digital signature
- Mitigation: Paper scan ratio tracked on compliance dashboard; COR audit packages note paper-origin records with explanation; advisor acknowledgement required per paper record; KPI target: minimize paper scan ratio to <5% of total field records
- Severity: Low-Medium

**Risk 9 — CVIP vehicle weight threshold and semi-annual classification unconfirmed**
- Platform may under-alert or over-alert on CVIP if threshold and cadence are wrong
- Mitigation: [UNVERIFIED] flag in platform; advisor confirms CVIP applicability per client vehicle fleet at onboarding; manual verification with Alberta Transportation before automation goes live
- Severity: Low (compliance risk to client if missed)

**Risk 10 — PIPA data subject access requests across 50+ client sites**
- Under PIPA s.7/24, individuals may request access to their personal information; a worker training record or incident report may be requestable
- Mitigation: Canada Central data residency confirmed; SharePoint Unified Audit Log supports access tracking; Purview compliance search can locate personal information across tenant; PIPA access request workflow to be designed as a separate operational procedure[^14]
- Severity: Low-Medium

**Risk 11 — CRSP March 30 annual renewal deadline missed**
- CRSP requires 25 CPD points submitted annually by March 30. If platform alert ladder is not initialized at 90 days prior to March 30 for all active CRSP holders, advisors may miss the hard deadline regardless of 5-year certification cycle.
- Mitigation: Alert ladder initialized at 90/60/30/7 days before March 30 each calendar year for all workers with CRSP certification status = "Active"; separate from expiry date tracking
- Severity: Medium (credential lapse risk; COR evidence gap)

**Risk 12 — firecrawl-sync.py UNRESOLVED items left open in compliance matrix**
- If UNRESOLVED_MANUAL_REQUIRED items in a compliance matrix are not resolved by an advisor, the matrix contains unverified regulatory data that may be cited in client deliverables
- Mitigation: Advisor-gated; UNRESOLVED items surfaced in advisor queue dashboard; quarterly re-run of firecrawl-sync.py forces resolution cycle; Zero Guess Rule prohibits citing unresolved items as confirmed
- Severity: Medium (regulatory accuracy risk)

**Risk 13 — SDS metadata using retired "WHMIS 2015" designation**
- HPR transition ended December 14, 2025. "WHMIS 2015" is no longer the correct designation. Metadata fields, labels, and client-facing documents using this string are non-compliant.
- Mitigation: Platform metadata validation rejects "WHMIS 2015" string; all SDS records label as WHMIS (GHS Rev 7/8); data migration of existing records required at cutover
- Severity: Low (non-material compliance issue once corrected)

***

## Competitive Differentiation Summary

Based on Phase 1 findings, no competitor platform (ISNetworld, Avetta, Veriforce/ComplyWorks, Cognibox) offers the following workflow capabilities that Vaquero delivers:

| Capability | All Competitors | Vaquero |
|---|---|---|
| Push model — client never logs in | ✗ (all are portal-pull) | ✓ (push-only) |
| Auto-executed DocuSign with signing order | ✗ | ✓ |
| Automated SOP propagation across 50+ clients | ✗ | ✓ |
| Approval workflow with Approve/Amend routing | ✗ | ✓ |
| Signed documents auto-archived to client SharePoint | ✗ | ✓ |
| COR 3-year audit cycle management | ✗ | ✓ |
| Per-individual CRSP/NCSO expiry tracking | ✗ | ✓ |
| Regulatory change → SOP update → client approval pipeline | ✗ | ✓ |
| Field mobile app (offline) + office scan hybrid with metadata distinction | ✗ | ✓ |
| Continuous CEL audit trail linked to COR evidence package | ✗ | ✓ |
| Signatory-by-role model (survives staff turnover) | ✗ | ✓ |
| Amendment cycle with full history (no Reject path) | ✗ | ✓ |
| Automated firecrawl-based regulatory source verification with confidence scoring | ✗ | ✓ |

The deepest competitive moat is the combination of push delivery + automated DocuSign execution + SharePoint auto-archive + CEL, which creates an always-on, audit-ready compliance chain that requires zero client portal activity. No competitor's architecture supports this today.

---

## References

1. [How to disable Data Logging and set Data Retention to 1 day for the ...](https://community.make.com/t/how-to-disable-data-logging-and-set-data-retention-to-1-day-for-the-entire-organization-pro-plan/101106) - ... Make will not store anything related to your logs and business data. Keep in mind that this will...

2. [Scenario history - Make Help Center](https://help.make.com/scenario-history) - Monitor execution history and user changes, and export logs for debugging and analysis.

3. [Use of Transaction Data | DocuSign](https://www.docusign.com/trust/security/transaction-data-use) - Docusign uses transaction data from activities occurring on the Docusign eSignature service platform...

4. [Building best practices webhook listeners, part 1 - Docusign](https://www.docusign.com/blog/developers/dsdev-webhook-listeners-part-1)

5. [Microsoft 365 Provisioning: Graph API, PnP, Third-party Tools](https://www.solutions2share.com/microsoft-365-provisioning/) - Explore Graph API, PnP and third-party tools for Microsoft 365 provisioning: methods, limits, real-w...

6. [SharePoint Site Creation in Microsoft Graph](https://devblogs.microsoft.com/microsoft365dev/sharepoint-site-creation-in-microsoft-graph/) - The SharePoint team is excited to (finally) bring Site Collection creation to Graph! Starting in Mic...

7. [SharePoint site template and site script overview | Microsoft Learn](https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-overview) - Use SharePoint site scripts and site templates to provide custom configurations to apply when new si...

8. [Sharepoint Online Templates / Provisioning.](https://techcommunity.microsoft.com/discussions/sharepoint_general/sharepoint-online-templates--provisioning-/4468603) - Hello everyone,I have a SharePoint online site that is as close as possible to being a template for ...

9. [How SharePoint Permissions work (Best Practices) - YouTube](https://www.youtube.com/watch?v=kdv-aiswlmE) - ... Architecture first so that you can start managing permissions ... Instead, you can enable or dis...

10. [Top 10 SharePoint permissions best practices](https://sharepointmaven.com/top-10-sharepoint-permissions-best-practices/) - Here are, in my opinion, the top 10 best practices to be aware of when you work with security and pe...

11. [Get hooked on MyConnectWebhook, our latest sample app!](https://www.docusign.com/blog/developers/get-hooked-myconnectwebhook-our-latest-sample-app) - Discover how Docusign Connect can help you monitor and automate your business processes through real...

12. [PIPEDA Breach Notification Guidelines - Compliancy Group](https://compliancy-group.com/pipeda-breach-notification-guidelines/) - Read about PIPEDA breach notification guidelines ... Use this PIPEDA compliance checklist to see you...

13. [PIPA Alberta: Your Guide to Data Privacy in Alberta - YouTube](https://www.youtube.com/watch?v=Wa_abiQdd48) - ... PIPA's requirements so you can manage personal data responsibly and avoid compliance risks. What...

14. [Canada privacy laws - Azure Compliance | Microsoft Learn](https://learn.microsoft.com/en-us/azure/compliance/offerings/offering-canada-privacy-laws) - Canadian privacy laws were established to protect the privacy of individuals and give them the right...

15. [Alberta Occupational Health and Safety Regulations Guide](https://juriscorplaw.ca/alberta-occupational-health-and-safety-regulations-guide/) - Occupational Health and Safety Code- The code sets out the technical standards, rules, and best prac...

16. [OHS Workplace Safety Training Records – Know The Laws ...](https://hrinsider.ca/ohs-workplace-safety-training-records-know-the-laws-of-your-province/?print=print)

17. [[PDF] Record Keeping At-a-Glance - CVSE](https://www.cvse.ca/nsc-course/pdf/recording_keeping_at_glance.pdf) - Accident Records (separately or in the driver's file). 1. Accident reports. Within 15 days of incide...

18. [5 Common COR Audit Gaps in Construction](https://www.linkedin.com/pulse/5-common-cor-audit-gaps-construction-louise-green-chsc-nhsa-wjhde) - And How to Fix Them Before Your External Audit If you're approaching your 3-year recertification COR...

19. [Recent amendments to Alberta's Occupational Health and Safety ...](https://www.employmentandlabour.com/recent-amendments-to-albertas-occupational-health-and-safety-code-simplify-the-requirements-for-workplace-health-and-safety-policies/) - Recent amendments to Alberta's Occupational Health and Safety Code simplify the requirements for wor...

20. [Confined Space Pre-Entry Training | Alberta Legislation - Alert First Aid](https://www.alertfirstaid.com/onlinecourses_submenu/Alberta-Legislation-Confined-Space) - An employer must ensure that a worker assigned duties related to confined space or restricted space ...

21. [Confined Spaces | Occupational Health and Safety Legislation](https://search-ohs-laws.alberta.ca/legislation/occupational-health-and-safety-code/part-5-confined-spaces/)

22. [[PDF] Occupational Health and Safety Code Explanation Guide 2009](https://cdn2.hubspot.net/hubfs/2564336/Irwins-Safety-May-2017/PDF/WHS-LEG_ohsc_p05.pdf) - The entry permit must, at a minimum. (a) list the name of each worker who enters the confined space ...

23. [PIPEDA Compliance & Office 365 Compliance Center - VC3](https://www.vc3.com/blog/how-companies-in-alberta-can-ensure-compliance-for-office-365) - Learn how Office 365 Security Compliance Center can help you in complying with PIPEDA (Personal Info...

24. [Customize permissions for a SharePoint list or librarysupport.microsoft.com › en-us › office › customize-permissions-for-a-shar...](https://support.microsoft.com/en-us/office/customize-permissions-for-a-sharepoint-list-or-library-02d770f3-59eb-4910-a608-5f84cc297782) - Learn how to break permissions inheritance and grant, remove, or edit permissions to a SharePoint si...

25. [Report serious injuries, illnesses or incidents | Alberta.ca](https://www.alberta.ca/report-serious-injuries-incident) - Types of workplace incidents that must be reported directly to Alberta Occupational Health and Safet...

26. [Compliance Cheat Sheet: OHS Records Retention Requirements ...](https://ohsinsider.com/compliance-cheat-sheet-ohs-records-retention-requirements-across-canada/?print=print) - Technical records, e.g., air or soil testing results: 10 years; · Alberta: 2 years; · Federal: 1 yea...

27. [Webhook Payload limits - Questions - Make Community](https://community.make.com/t/webhook-payload-limits/48003) - 5MB might be the limit for the data that can be handled within a scenario, but the webhook itself ha...

28. [[PDF] RECERTIFICATION A Guide to Maintaining Your BCRSP ...](https://bcrsp.ca/sites/default/files/2024-05/Doc.133%20Continuous%20Professional%20Development%20Guide_Bilingual_V24_05-07.pdf)

29. [What Is CVIP? Why Commercial Vehicle Inspections Matter in Alberta](https://www.thatchwoodventuresltd.ca/cvip-inspection-alberta/) - It must be performed by a certified CVIP mechanic at a licensed inspection facility — like Thatchwoo...

30. [Alberta King's Printer subscriptions](https://www.alberta.ca/alberta-kings-printer-subscriptions) - Keep informed on changes to products, services and legislation.

31. [Subscribe to the CER's RSS Feeds - Canada Energy Regulator](https://www.cer-rec.gc.ca/en/rss/rss.html) - Web-based feed readers – usually involves creating an account and then subscribing to all your favor...

32. [AER Products and Services Catalogue – General Well Data](https://www1.aer.ca/productcatalogue/219.html)

33. [ACSA Audit Tool - yourACSA.ca](https://www.youracsa.ca/cor-secor/2023-audit-tool/) - The 2023 ACSA COR Audit Instrument is updated to address Bill 47: Ensuring Safety and Cutting Red Ta...

34. [OHS eNews | Alberta.ca](https://www.alberta.ca/health-safety-enews) - Receive a monthly e-newsletter with the latest Alberta Occupational Health and Safety news and event...

35. [[PDF] Responsibilities of a COR-Holder - Open Government program](https://open.alberta.ca/dataset/110b6586-1865-4a50-81cd-51be9de6cee7/resource/4036fc49-6ed1-454f-bbf0-fdc60b739e19/download/ohs-responsibilities-of-a-cor-holder.pdf) - When an employer is under review, any Workers' Compensation Board Alberta PIR rebates to which the e...

36. [How to Run Multiple Make.com Modules Simultaneously - One Scales](https://onescales.com/blogs/main/make-com-modules-simultaneously) - Create a new scenario for each route you want to run in parallel ... Running multiple scenarios simu...

37. [How to run multiple modules at same time in Make.com - YouTube](https://www.youtube.com/watch?v=YeZ39x6slow) - What You'll Learn: ✓ The limitation of standard router setups in Make.com ✓ How to use webhooks to t...

38. [Twilio Integration | Workflow Automation - Make](https://www.make.com/en/integrations/twilio) - Connect Twilio integrations. Personalize your customer engagement by automating Twilio to deliver co...

39. [250 runs of the same scenario at the same time (Webhook instant ...](https://community.make.com/t/250-runs-of-the-same-scenario-at-the-same-time-webhook-instant-scenario/32492) - A scenario can run at maximum 50 runs asynchronous. Every time you clear 1 run, a next one will take...

40. [Alternative signers - Docusign Community](https://community.docusign.com/esignature-111/alternative-signers-3530) - Yes, you can do that using the Signing Group option. As an Admin, you can create a Signing group, ad...

41. [Need help with capturing E-sign completion event using ...](https://community.docusign.com/esignature-api-63/need-help-with-capturing-e-sign-completion-event-using-webhooks-23027) - Things I have tried so far -Define the connect configuration at the Docusign Admin to list all the e...

42. [How to Change Signing Order in DocuSign After Sent - YouTube](https://www.youtube.com/watch?v=_tT6EaHf9js) - In this case, you may need to void the envelope and resend it with the corrected sequence. Always do...

43. [platform safety | Docusign](https://www.docusign.com/safety/platform-safety) - Utilize Docusign CLM to enforce version control and maintain an audit trail, protecting against frau...

44. [Company Audits - yourACSA.ca](https://www.youracsa.ca/cor-secor/company-audits/) - A COR maintenance audit, otherwise known as an internal audit, is conducted on the two calendar year...

45. [How to Pass Your Next CVIP Inspection Without Surprises](https://www.dmrdiesel.ca/blog/posts/how-to-pass-your-next-cvip-inspection-without-surprises/) - Only certified CVIP facilities and licensed inspectors can conduct these inspections. Non-compliance...

46. [The Alberta CVIP: What To Know And How To Pass | Overdrive HD](https://overdriveheavyduty.com/blog/alberta-cvip-what-to-know/) - The basics of the Alberta CVIP (Commercial Vehicle Inspection Program), and how your company can pas...

47. [Employer Requirement to keep supplier safety data sheets (SDS) up ...](https://www.canada.ca/en/employment-social-development/programs/laws-regulations/labour/interpretations-policies/employer-requirement-safety-data-sheets.html) - The Hazardous Products Regulations (HPR) require suppliers to provide updated SDS only if new inform...

48. [Keeping Safety Data Sheets Updated: 5 Steps for Success](https://sdsriskassist.ca/keeping-safety-data-sheets-updated-five-steps-for-success/) - WHMIS requires you to keep your Safety Data Sheets updated. Get our 5-step process to identify and u...

49. [[PDF] OCCUPATIONAL HEALTH AND SAFETY CODE](https://www.ulethbridge.ca/sites/default/files/2020/09/AB%20OHS%20Act,%20Regulation%20and%20Code.pdf)

50. [Safety Data Sheet Compliance Tool - WHMIS.org](https://whmis.org/sds/) - This tool provides an overview of common SDS non-compliances and includes tips and best practices to...

51. [Do you know how to meet your reporting obligations under Alberta’s Environmental regulations?](https://www.linkedin.com/pulse/do-you-know-how-meet-your-obligations-under-albertas-travis-kendel) - Regardless of who you are and where you work, you have obligations under Alberta’s Environmental Reg...

52. [[PDF] Alberta Tier 1 Soil and Groundwater Remediation Guidelines](https://aeic-iaac.gc.ca/050/documents/p65505/125771E.pdf) - Alberta Tier 1 Soil and Groundwater. Remediation Guidelines. Land Policy Branch, Policy and Planning...

53. [AER Products and Services Catalogue](https://www1.aer.ca/productcatalogue/699.html)

54. [AER Products and Services Catalogue – General Well Data File](https://www1.aer.ca/productcatalogue/237.html)

55. [Contaminant management – Industrial and municipal guidance](https://www.alberta.ca/contaminant-management-industrial-and-municipal-guidance) - Facilities must follow current operating requirements to protect soil and groundwater from contamina...

56. [Annual emissions inventory report standard and guidance ...](https://open.alberta.ca/publications/9781460140536)

57. [Audit Comments Guidelines | Your ACSA's COR - YouTube](https://www.youtube.com/watch?v=K6UBVhKhK7Y) - Audit Comments Guidelines | Your ACSA's COR. 478 views · 7 months ago ...more. Your ACSA Safety. 10....

58. [Scenario timeout (max 45 min) -> workarounds? - Make Community](https://community.make.com/t/scenario-timeout-max-45-min-workarounds/45073) - The maximum execution timeout is 40minutes, therefore you get 5 minutes extra which allows total max...

