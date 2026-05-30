# Vaquero Safety Inc — Document & Template Registry
**Source:** Phase 2 End-to-End Workflow Specification  
**Purpose:** Master list of every internal document, legal agreement, system template, email template, and form that must be created, drafted, or standardized before go-live  
**Format:** Category | Document Name | Purpose | Owner | Status | Stage Reference

---

## CATEGORY 1 — LEGAL AGREEMENTS (DocuSign-executed)

| # | Document | Purpose | Owner | Status | Stage |
|---|----------|---------|-------|--------|-------|
| L1 | **Master Services Agreement (MSA)** | Governs the management-vs-advisory relationship between Vaquero and each client. Must include: OHS employer responsibility disclaimer, 5-day signatory change notification clause, authority verification timing clause, PIPA s.7 consent capture, liability scope for compliance advisory services. | Legal | 🔴 MUST DRAFT | S1.3 |
| L2 | **Data Processing Addendum (DPA)** | PIPA Alberta s.34 accountability document. Names designated data steward per client. Canada Central data residency confirmation. Governs personal information handling by Vaquero on behalf of clients. Must be DocuSign-executable alongside MSA. | Legal | 🔴 MUST DRAFT | S1.3 |
| L3 | **T+21 Formal Non-Response Notice Template** | DocuSign-executed formal legal notice issued when client has not responded after 21 days of notifications. Creates legal documentation of notification delivery and client non-response. Must be signed by named Vaquero compliance advisor + authorized officer. | Legal + Compliance Advisor | 🔴 MUST DRAFT | S4, T+21 |
| L4 | **Return-to-Service Authorization Template** | DocuSign or written authorization confirming compliance advisor has reviewed and approved an asset's return to service after a failed inspection. Creates audit trail for OHS duty-of-care compliance. | Compliance Advisor | 🟡 TEMPLATE NEEDED | S7.4 |

---

## CATEGORY 2 — SHAREPOINT LISTS (Must be built and schema-finalized)

| # | List Name | Purpose | Fields to Finalize | Stage |
|---|-----------|---------|-------------------|-------|
| SP1 | **Master Client Registry** | Central client database. Source of truth for all client-level metadata. Client_id is immutable anchor across all systems. | client_id, client_name, ABN, WCB_account, NAICS_code, COR_status, certifying_partner, workforce_size, active_sites, onboarding_status, client_status | S1.1 |
| SP2 | **Signatories List** | Role-based signing authority per client. Make.com reads this at DocuSign envelope creation time. Must survive staff turnover — role is the key, not the individual. | client_id, role (Safety Manager / Executive), current_holder_name, current_holder_email, channel_preference, signing_order, last_confirmed_date | S1.4, S5.1 |
| SP3 | **Contacts List** | All client contacts with per-contact notification channel preferences. Email is always primary for approval actions. | contact_id, client_id, name, role, primary_channel, secondary_channel, email_address, mobile_number, Teams_UPN | S1.5, S4.1 |
| SP4 | **Compliance Event Log (CEL)** per client site | Legal audit trail. Every compliance event written at moment of occurrence. Purview retention label applied. Make.com logs are NOT the audit trail — this is. | event_type, client_id, event_timestamp, actor_user_id, event_detail_json, linked_document_id, linked_envelope_id | All stages |
| SP5 | **Certification Tracker** | Tracks all individual certifications (NCSO, CRSP, COR auditor, worker tickets) and asset certifications (CVIP, lifting device) with expiry dates and alert status. | client_id, worker_id/asset_id, certification_type, certifying_body, issue_date, expiry_date, status, last_alert_sent, renewal_in_progress | S3, S5.5 |
| SP6 | **SOP Registry** | Version-controlled index of all active SOPs per client. Links each version to the regulatory change that triggered it. | client_id, sop_template_id, version_number, effective_date, approval_status, regulatory_change_id, customization_flag, superseded_by, docusign_envelope_id | S6, S9 |
| SP7 | **Regulatory Monitor List** | Tracks last-checked hash for each manually-monitored regulatory URL. Records change candidates and advisor classification outcomes. | regulatory_body, monitoring_url, last_checked_date, last_hash, hash_changed, change_candidate_id, advisor_classification, classification_date | S3 |
| SP8 | **SOP Propagation Tracker** | Stored in Vaquero internal SharePoint (NOT client sites). Tracks all 50+ clients' status through each SOP update event. Powers the operations dashboard. | propagation_id, client_id, sop_template_id, regulatory_change_id, client_status, amendment_cycle, last_activity_timestamp, days_since_notification | S6.6 |
| SP9 | **Asset Registry** | Per-asset inspection schedules, CVIP expiry dates, and operational status. Source of truth for Stage 7 monitoring. | client_id, asset_id, asset_type, make, model, year, VIN, registered_weight, assigned_site, inspection_schedules, last_inspection_date, next_inspection_due, CVIP_expiry_date, status | S7 |
| SP10 | **SDS Registry** | WHMIS 2015 SDS tracking per chemical per client. Weekly scan for records approaching 3-year mark. | client_id, chemical_name, supplier, CAS_number, intake_date, version_number, sds_expiry_flag_date, location_used_in_field, field_accessible | S8.1 |
| SP11 | **Action Items List** | Tracks open compliance gaps, pre-existing deficiencies, and remediation tasks. Each item linked to a client contact with deadline and response status. | client_id, action_item_id, gap_type, domain, severity, assigned_contact, deadline, status, created_at, resolved_at | S1.8, S7.4 |
| SP12 | **Amendment Records** | Full history of all amendment cycles for every notification workflow. Required for COR Element 8 audit evidence. | amendment_id, notification_id, amendment_cycle, amendment_notes, requested_by, request_timestamp, advisor_response, advisor_id, revised_notification_id | S4.5 |
| SP13 | **Notification Log** | Tracks every notification sent: channels used, delivery confirmations, response status, response timestamps. | notification_id, client_id, event_type, event_id, notification_timestamp, contacts_notified, channels_used, delivery_confirmations, response_status, response_timestamp | S4.1 |

---

## CATEGORY 3 — SHAREPOINT DOCUMENT LIBRARIES (PnP Template — 13 Libraries)

| # | Library Path | Content | Retention Label |
|---|-------------|---------|-----------------|
| DL1 | `/00-MSA-Legal/` | Executed MSA + DPA + Certificate of Completion | 7 years (commercial standard) |
| DL2 | `/00-Intake-Queue/` | Staging queue for all incoming documents pending ingestion | No label — transient |
| DL3 | `/00-Pending-Approval/` | Documents built and staged for client approval | No label — transient until approved |
| DL4 | `/01-People/` (with subfolders: Training, Orientations, Certifications) | All People domain records — training, tickets, certs, orientation sign-offs | Per document type (1–10 years) |
| DL5 | `/02-Assets/` (subfolders: Vehicles/CVIP, Equipment, Inspections) | All Assets domain records — inspections, CVIP certs, maintenance logs | 3 years (CVIP), 5 years (default) |
| DL6 | `/03-Processes/` (subfolders: SOPs, JHAs, ERP, Safety-Policy) | All Processes domain records — SOPs with full version history, JHAs, ERP | 5 years default |
| DL7 | `/04-Site-Environmental/` (subfolders: Incidents, Walkarounds, Sampling, Well-Tracking, Environmental-Monitoring) | All Site & Environmental records | 2 years (incidents), 10 years (environmental) |
| DL8 | `/09-WHMIS-SDS/` | SDS library — one subfolder per chemical name | Duration of use + 3 years |
| DL9 | `/11-Audit-Reports/` (subfolders: Onboarding, Interview-Records, COR-Evidence-Packages) | All audit-facing reports and evidence packages | 7 years |
| DL10 | `/13-DocuSign-Completed/` | Certificates of Completion for all DocuSign envelopes — organized by document type | Mirrors primary document retention |

---

## CATEGORY 4 — DOCUSIGN TEMPLATES (Must be built in DocuSign account)

| # | Template Name | Document Type | Signatories | Routing Order | Stage |
|---|--------------|--------------|-------------|---------------|-------|
| DS1 | **MSA Template** | Master Services Agreement | Vaquero Authorized Officer (1) → Client Executive (2) | Sequential | S1.3 |
| DS2 | **Safety Policy Statement Template** | Signed safety policy — COR Element 1 | Safety Manager (1) → Executive (2) | Sequential | S5, S6 |
| DS3 | **SOP Authorization Template** | Safe Work Procedure approval | Safety Manager (1) → Executive (2) | Sequential | S5, S6 |
| DS4 | **Worker Orientation Sign-Off Template** | New worker orientation acknowledgement | Worker (1) → Safety Manager (2) | Sequential | S5 |
| DS5 | **Training Acknowledgement Template** | Formal training completion acknowledgement | Worker (1) → Safety Manager (2) | Sequential | S5 |
| DS6 | **Emergency Response Plan Approval Template** | ERP annual review and authorization | Safety Manager (1) → Executive (2) | Sequential | S5, S6 |
| DS7 | **CVIP Placement Acknowledgement Template** | Confirms physical CVIP certificate placed in vehicle | Safety Manager (1) | Single signer | S7.5 |
| DS8 | **T+21 Formal Non-Response Notice Template** | Legal notice of client non-response | Vaquero Compliance Advisor (1) → Vaquero Authorized Officer (2) | Sequential | S4, T+21 |
| DS9 | **Return-to-Service Authorization Template** | Asset cleared for return to service post-failed inspection | Compliance Advisor (1) | Single signer | S7.4 |

---

## CATEGORY 5 — NOTIFICATION & EMAIL TEMPLATES (Make.com / Plain-Language)

| # | Template Name | Trigger | Key Content | Action Buttons | Stage |
|---|--------------|---------|-------------|----------------|-------|
| N1 | **Certification Expiry — 90 Day Notice** | Certification Tracker threshold | Cert name, expiry date, renewal recommendation | None (informational) | S3, S4 |
| N2 | **Certification Expiry — 60 Day Action Request** | Certification Tracker threshold | Cert name, expiry date, renewal urgency | Approve (confirm renewal in progress) / Amend (request modified timeline) | S3, S4 |
| N3 | **Certification Expiry — 30 Day Critical Alert** | Certification Tracker threshold | Cert name, expiry date, advisor alerted | Approve / Amend | S3, S4 |
| N4 | **Certification Expiry — 7 Day Emergency** | Certification Tracker threshold | Cert name, expiry date, all channels fired | Approve / Amend | S3, S4 |
| N5 | **Certification Expired (T+0)** | Status update: Expired | Cert expired, COR risk flag if applicable | Immediate renewal action link | S3, S4 |
| N6 | **SOP Update Required — Client Review** | Stage 6 build completion | Change summary in plain language, link to view updated SOP | Approve / Amend | S4, S6 |
| N7 | **Regulatory Change — Informational Notice** | Classification C | Summary of regulatory change, no client action required | None | S3, S4 |
| N8 | **Inspection Due Reminder** | Asset Registry threshold | Asset ID, inspection type, due date, instructions | None (informational) for standard; Approve/Amend for CVIP | S7, S4 |
| N9 | **Asset Inspection Fail Alert** | Fail item in inspection record | Asset ID, fail items list, out-of-service instruction | None (auto-action) | S7 |
| N10 | **New Compliance Gap — Onboarding** | Gap assessment classification | Gap domain, severity, remediation timeline | Approve (acknowledge + commit to date) / Amend (request modified deadline) | S1.8, S4 |
| N11 | **DocuSign Document Active Confirmation** | envelope-completed webhook | Document type, effective date, version number | View document link | S5.5 |
| N12 | **48-Hour Reminder** | No response T+48h | Same content as original notification | Approve / Amend | S4, recurring |
| N13 | **SDS 3-Year Renewal Alert** | SDS Registry weekly scan | Chemical name, supplier, intake date, request updated SDS from supplier | None (informational) | S8.1 |
| N14 | **Monthly Compliance Status Report** | Scheduled: 1st business day/month | Cert counts by status, inspection completion rates, open action items, SOP updates, paper scan ratio | Dashboard link | S9 |
| N15 | **Quarterly Certification Expiry Dashboard** | Scheduled: quarterly | 12-month forward expiry calendar, COR audit cycle position, CRSP CPD status | Dashboard link | S9 |
| N16 | **Annual SOP Version Log** | Scheduled: annually | All SOPs updated in 12 months: old vs. new version, regulatory trigger, execution date | Full log link | S9 |
| N17 | **Documentation Intake Checklist Push** | Stage 1.6 — onboarding | 4-domain checklist request to client for document upload | Upload link | S1.6 |
| N18 | **Signatory Change Notification** | Signatories List update detected | Confirmation to compliance advisor of role holder change; request to verify | Confirm / Review | S1.4, S5.4 |

---

## CATEGORY 6 — INTAKE FORMS & FIELD FORMS

| # | Form Name | Purpose | Channel | Fields Required | Stage |
|---|----------|---------|---------|-----------------|-------|
| F1 | **Client Intake Form** | Captures all client onboarding data to seed Client Registry | Web form or Vaquero-completed | Client name, ABN, WCB account number, NAICS code, COR status, certifying partner, workforce size, active work sites | S1.1 |
| F2 | **Gap Assessment Checklist** | 4-domain compliance gap assessment tool | SharePoint list (advisor-populated) | Domain, gap_type, document_missing, certification_expired, expiry_date, severity | S1.7 |
| F3 | **Pre-Use Inspection Checklist** (per asset type) | Daily mobile app inspection — offline-capable | Mobile app | Asset ID, each checklist item (Pass/Fail/N/A), notes, photo capture, GPS stamp, device_timestamp, worker signature | S7.2 |
| F4 | **Amendment Form** | Captures client amendment details when Amend action is taken | Web form (link in notification) | amendment_notes, requested_change, requested_deadline, contact_id, notification_id | S4.5 |
| F5 | **Office Scan Upload Metadata Form** | Required at upload for all paper_scan_upload documents | SharePoint upload form | paper_record_date, uploading_user_id, site_location, reason_paper_used, form_type, asset_id (if applicable) | S2.1C, S7.3 |
| F6 | **Soil/Water Sample Chain of Custody Form** | COC documentation for environmental sampling | Paper / digital | sample_id, sample_type, collection_date, collector_id, GPS_location, lab_name, lab_accreditation_number | S8.3 |
| F7 | **Signatory Change Flag Form** | Used when a signatory is no longer in role and a live envelope must be corrected | Embedded link in DocuSign envelope body | Departing_individual_name, role, new_individual_name, new_individual_email, reason, flagging_contact_id | S5.4 |

---

## CATEGORY 7 — INTERNAL OPERATIONAL DOCUMENTS

| # | Document | Purpose | Owner | Stage |
|---|----------|---------|-------|-------|
| O1 | **Regulatory Monitoring Schedule** | Documents monitoring cadence, named accountable advisor, and method per regulatory body (RSS/scraper/email). Required for PIPA accountability and compliance audit. | Compliance Advisor + Operations | S3 |
| O2 | **Paper Backup Protocol Document** | Documents the accepted procedure when mobile app is unavailable. Required for COR audit packages where paper_scan records appear. Explains GPS/timestamp absence. | Compliance Advisor | S2.6, S7.3 |
| O3 | **CVIP Applicability Matrix per Client** | Per-client vehicle fleet assessment confirming CVIP applicability, weight thresholds, and inspection cadence. Must be completed at onboarding before CVIP alert automation is enabled. | Compliance Advisor (per client) | S7.5 |
| O4 | **Weekly Advisor Queue Report Template** | Pushed every Monday to all compliance advisors. Open items by client, sorted by age, items due within 7 days, upcoming COR audit deadlines. | Operations / Make.com auto-generated | S9 |
| O5 | **COR Evidence Package Index Template** | PDF table of contents generated on demand for auditor-facing evidence packages. Lists document names, versions, dates, SharePoint locations, and DocuSign certificate links per COR element. | Make.com auto-generated + Advisor certified | S9.1 |
| O6 | **PIPA DSAR Procedure Document** | Operational procedure for responding to data subject access requests under PIPA s.7/24. Must be drafted before any personal worker data is held on the platform. | Legal + Compliance Advisor | S9 |
| O7 | **SOP Master Template Library Index** | Index of all base SOP templates in Vaquero's internal library. Each entry includes template_id, document type, regulation linked, current version, and last update date. | Compliance Advisor | S6 |
| O8 | **Onboarding Completion Checklist** | Advisor-facing checklist confirming all 5 gates are met before client status is set to Active. Doubles as CEL audit entry for onboarding gate. | Compliance Advisor | S1.9 |
| O9 | **COR Audit Risk Advisory Template** | Written advisory issued to clients whose existing COR was obtained while holding documentation gaps identified at onboarding. Must be issued and logged to CEL per spec. | Compliance Advisor + Legal | S1.8 |

---

## SUMMARY: TOTAL DELIVERABLES BY CATEGORY

| Category | Count | Status |
|----------|-------|--------|
| Legal Agreements | 4 | 🔴 2 must draft before any client onboarding |
| SharePoint Lists | 13 | 🟡 Schema must be finalized in PnP template |
| Document Libraries | 10 | 🟡 Part of PnP template build |
| DocuSign Templates | 9 | 🟡 Must be built in DocuSign account |
| Notification Templates | 18 | 🟡 Must be built in Make.com scenario logic |
| Forms | 7 | 🟡 2 must be live before first client (Intake + Gap) |
| Internal Operational Docs | 9 | 🟡 O6 (DSAR procedure) before personal data ingested |
| **TOTAL** | **70** | |

---

*Document version: 1.0 | Generated from Phase 2 Workflow Specification*
