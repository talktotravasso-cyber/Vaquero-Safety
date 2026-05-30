# Vaquero Safety Inc — System Diagram
**Render at:** https://mermaid.live — paste the code block contents only  
**Version:** 1.1.0 | **Updated:** 2026-05-27  
**Changes from v1.0.0:** Integrated Contractor/Vendor Registry (S3 extension), COR Readiness Score, Compliance Posture Page, Financial Risk Translation Layer (all S9 extensions)

---

```mermaid
flowchart TD
    %% ============================================================
    %% GLOBAL STYLES
    %% ============================================================
    classDef human fill:#b45309,stroke:#92400e,color:#fff,font-weight:bold
    classDef auto fill:#1d4ed8,stroke:#1e40af,color:#fff
    classDef cel fill:#065f46,stroke:#064e3b,color:#fff,font-style:italic
    classDef decision fill:#7c3aed,stroke:#6d28d9,color:#fff
    classDef docusign fill:#0369a1,stroke:#075985,color:#fff
    classDef flag fill:#dc2626,stroke:#b91c1c,color:#fff,font-weight:bold
    classDef temp fill:#9a3412,stroke:#7c2d12,color:#fff,font-style:italic
    classDef new fill:#166534,stroke:#14532d,color:#fff,font-weight:bold

    %% ============================================================
    %% ENTRY POINT
    %% ============================================================
    START([Client Engagement Initiated])

    %% ============================================================
    %% STAGE 1 — ONBOARDING
    %% ============================================================
    subgraph S1["STAGE 1 — Client Onboarding"]
        direction TB
        S1_1[1.1 Client completes intake form\nwebhook → Client Registry\nclient_id assigned]
        S1_2[1.2 SharePoint site provisioned\nGraph API + PnP template\n13 libraries + metadata schemas]
        S1_3[1.3 MSA + DPA DocuSign envelope\nVaquero officer signs first\nClient executive signs second]
        S1_3w{envelope-completed?}
        S1_3a[Signed MSA + Cert → /00-MSA-Legal/\nCEL: MSA_executed]
        S1_3b[Escalate: not signed in 7 days\nOnboarding suspended]
        S1_4[1.4 Signatories List populated\nRole-based: Safety Manager + Executive\nSigning order by role]
        S1_5[1.5 Contact notification\npreferences set per contact\nEmail always primary channel]
        S1_6[1.6 Domain documentation intake\n4 domains: People / Assets /\nProcesses / Site & Environmental]
        S1_7{1.7 Gap Assessment\nHUMAN REQUIRED}
        S1_7a[Classify each gap:\nCritical / Major / Minor\nAdvisor sign-off mandatory]
        S1_8[1.8 Pre-existing gap handling\nCertification Tracker pre-populated\nAction Items list created]
        S1_9{1.9 Onboarding Completion Gate\nHUMAN REQUIRED}
        S1_9a[Client status = Active\nAll 4 domains confirmed by advisor]
        S1_CEL[[CEL: all onboarding events logged]]
    end

    START --> S1_1 --> S1_2 --> S1_3 --> S1_3w
    S1_3w -- Yes --> S1_3a --> S1_4
    S1_3w -- No / Timeout --> S1_3b
    S1_4 --> S1_5 --> S1_6 --> S1_7
    S1_7 --> S1_7a --> S1_8 --> S1_9
    S1_9 -- Advisor approves --> S1_9a
    S1_9a --> S1_CEL

    %% ============================================================
    %% STAGE 2 — INGESTION
    %% ============================================================
    subgraph S2["STAGE 2 — Document Ingestion & Indexing"]
        direction TB
        S2_src{Document Source?}
        S2_A[Source A: Intake Queue watch\nnative digital upload]
        S2_B[Source B: Field mobile app\nAPI push to SharePoint]
        S2_C[Source C: Office scan upload\npaper_scan_upload flag]
        S2_D[Source D: DocuSign webhook\nauto-archive on completion]
        S2_2{2.2 Auto-classification\nconfidence threshold?}
        S2_2a[Auto-classify:\ndomain + document_type\ntarget library path]
        S2_2b{Human classification\nrequired — advisor queue}
        S2_3[2.3 Metadata stamp\n18-field schema applied\nretention_end_date calculated]
        S2_4[2.4 SharePoint write\nmajor versioning enabled\nprevious_version_id linked]
        S2_5[2.5 Retention label applied\nPurview enforcement]
        S2_CEL[[CEL: document_ingested\nclassifier_type + timestamp]]
    end

    S1_9a --> S2_src
    S2_src --> S2_A & S2_B & S2_C & S2_D
    S2_A & S2_B & S2_C & S2_D --> S2_2
    S2_2 -- Above threshold --> S2_2a --> S2_3
    S2_2 -- Below threshold --> S2_2b --> S2_3
    S2_3 --> S2_4 --> S2_5 --> S2_CEL

    %% ============================================================
    %% STAGE 3 — MONITORING
    %% ============================================================
    subgraph S3["STAGE 3 — Regulatory & Certification Monitoring"]
        direction TB
        S3_cert[Certification Tracker scan\nscheduled daily\n90/60/30/7-day thresholds]
        S3_contractor[Contractor/Vendor Registry scan\nscheduled daily\nsame 90/60/30/7-day ladder\ncontractor_id + vendor_company]
        S3_contractor_alert{Contractor cert\nthreshold breached?}
        S3_reg{Regulatory source type?}
        S3_rss[RSS feed: Alberta King's Printer\nCER — polled daily]
        S3_scrape[Web scraper: AER, ACSA\nBCRSP, CSSE, Transport Canada\npage hash comparison]
        S3_email[Email newsletter: OHS eNews\nMonthly — inbox watch + parser]
        S3_change{Hash changed /\nnew item detected?}
        S3_candidate[Regulatory Change Candidate\ncreated in SharePoint]
        S3_human{HUMAN REQUIRED:\nAdvisor classifies\nwithin 48 hours}
        S3_A[Classification A:\nSOP Update Required\n→ trigger Stage 6]
        S3_B[Classification B:\nCertification renewal\nTracker updated]
        S3_C[Classification C:\nInformational only\n→ push notification]
        S3_alert[Threshold breach detected\non Certification Tracker]
        S3_CEL[[CEL: monitoring event + classification]]
    end

    S2_CEL --> S3_cert
    S3_cert --> S3_alert
    S3_cert --> S3_contractor --> S3_contractor_alert
    S3_contractor_alert -- Yes --> S3_CEL
    S3_contractor_alert -- No --> S3_CEL
    S3_reg --> S3_rss & S3_scrape & S3_email
    S3_rss & S3_scrape & S3_email --> S3_change
    S3_change -- No change --> S3_CEL
    S3_change -- Change detected --> S3_candidate --> S3_human
    S3_human --> S3_A & S3_B & S3_C
    S3_B --> S3_CEL
    S3_C --> S4_entry
    S3_alert --> S4_entry
    S3_contractor_alert -- Yes --> S4_entry

    %% ============================================================
    %% STAGE 4 — PUSH NOTIFICATION & APPROVAL LOOP
    %% ============================================================
    subgraph S4["STAGE 4 — Push Notification & Approval Loop"]
        direction TB
        S4_entry[4.1 Triggering event received\nclient_id → Contacts List lookup\nchannel preferences retrieved]
        S4_2[4.2 Multi-channel delivery\nEmail PRIMARY always\n+ SMS + Teams + App in parallel]
        S4_3{4.3 Response received?}
        S4_approve[APPROVE received\nwebhook: action=approve\ntimestamp + contact_id]
        S4_amend[AMEND received\nwebhook: action=amend\namendment form link sent]
        S4_amend2[Client submits amendment\nAmendment Record created\nRouted to advisor queue]
        S4_amend3{Advisor reviews\nRevised push issued\namendment_cycle+1}
        S4_norsp{No response\nT+48h reminder}
        S4_t7[T+7: Compliance advisor\nescalation — personal follow-up]
        S4_t14[T+14: Client executive\ndirect contact by account manager]
        S4_t21[T+21: Formal non-response notice\nvia DocuSign — authorized officer]
        S4_t30[T+30: COR-critical advisory\nin writing — logged to CEL]
        S4_CEL[[CEL: all notification + response events\ndelivery + amendment chain]]
    end

    S4_entry --> S4_2 --> S4_3
    S4_3 -- Approve --> S4_approve --> S5_entry
    S4_3 -- Amend --> S4_amend --> S4_amend2 --> S4_amend3
    S4_amend3 -- Revised push --> S4_entry
    S4_3 -- No response 48h --> S4_norsp
    S4_norsp -- Still no response --> S4_t7 --> S4_t14 --> S4_t21 --> S4_t30
    S4_t30 --> S4_CEL
    S4_approve --> S4_CEL

    %% ============================================================
    %% STAGE 5 — DOCUSIGN EXECUTION
    %% ============================================================
    subgraph S5["STAGE 5 — DocuSign Execution & Document Finalization"]
        direction TB
        S5_entry[5.1 Signatory lookup\nSignatories List → Safety Manager\n+ Executive current holders]
        S5_2[5.2 Envelope created\nSafety Manager: Order 1\nExecutive: Order 2\nExpiry: 30 days]
        S5_3{Envelope status?}
        S5_signed[5.5 envelope-completed webhook\nSigned PDF + Certificate downloaded]
        S5_archive[Auto-archive to SharePoint\n/Domain/DocumentType/\n+ /13-DocuSign-Completed/]
        S5_meta[Metadata stamped:\ndocusign_envelope_id\napproval_status = Active]
        S5_cert_update[Certification Tracker updated\nnew expiry date\nstatus = Renewed]
        S5_confirm[Client confirmation push\nDocument is now active]
        S5_declined[Envelope declined\nAdvisor alerted\nRoute to Amend or investigate]
        S5_d7[Day 7: Advisor check\nsigning group alert if unsigned]
        S5_d14[Day 14: Escalation\nalternate signing group activated]
        S5_d21[Day 21: Void + re-issue\nadvisor initiates]
        S5_change{Signatory change\nflagged?}
        S5_change_a[DocuSign Correct\nor void + re-issue\nSignatories List updated]
        S5_CEL[[CEL: envelope_created\ncompleted / declined / voided\nsignatory events]]
    end

    S5_entry --> S5_2 --> S5_3
    S5_3 -- Completed --> S5_signed --> S5_archive --> S5_meta --> S5_cert_update --> S5_confirm
    S5_3 -- Declined --> S5_declined --> S4_entry
    S5_3 -- Unsigned Day 7 --> S5_d7 --> S5_d14 --> S5_d21
    S5_3 -- Signatory change --> S5_change --> S5_change_a --> S5_2
    S5_confirm --> S5_CEL
    S5_confirm --> S3_cert

    %% ============================================================
    %% STAGE 6 — SOP PROPAGATION
    %% ============================================================
    subgraph S6["STAGE 6 — SOP & Safety Program Update Propagation"]
        direction TB
        S6_entry[6.1 Impact assessment\nAdvisor identifies affected\nSOP templates + client count]
        S6_human1{HUMAN REQUIRED:\nAdvisor approves\npropagation scope}
        S6_2[6.2 Base template updated\nMaster Template Library\nnew version + regulatory_change_id]
        S6_human2{HUMAN REQUIRED:\nSecond advisor/manager\nreviews template accuracy}
        S6_3{6.3 Per-client\ncustomization check}
        S6_3a[Customization flag = Y\nAdvisor reviews client-specific\nsections vs. base template]
        S6_3b[No customization\nproceed to build]
        S6_4[6.4 Client-specific SOP built\nBase + customizations merged]
        S6_5[6.5 Dispatcher pattern\nMaster → per-client\nchild scenarios via webhook]
        S6_track[SOP Propagation Tracker\nupdated per client\nPending → Notified → Active]
        S6_7[6.7 SOP activation\nOld: status = Superseded\nNew: status = Active\nregulatory_change_id linked]
        S6_CEL[[CEL: propagation events\nper-client activation timestamps]]
    end

    S3_A --> S6_entry
    S6_entry --> S6_human1 --> S6_2 --> S6_human2 --> S6_3
    S6_3 -- Customization = Y --> S6_3a --> S6_4
    S6_3 -- Customization = N --> S6_3b --> S6_4
    S6_4 --> S6_5 --> S4_entry
    S4_approve --> S6_track --> S5_entry
    S5_confirm --> S6_7 --> S6_CEL

    %% ============================================================
    %% STAGE 7 — ASSET & INSPECTION
    %% ============================================================
    subgraph S7["STAGE 7 — Asset & Inspection Compliance"]
        direction TB
        S7_1[Daily scan: Asset Registry\n06:00 client local time\ndays until inspection due]
        S7_2{Inspection path?}
        S7_mobile[Mobile app\nOffline-capable checklist\nGPS + worker signature]
        S7_scan[Office scan backup\nPaper → scan → Intake Queue\nStage 2 pipeline triggered]
        S7_3{Inspection result?}
        S7_pass[Pass: Asset Registry updated\nnext_inspection_due recalculated]
        S7_fail[Fail item detected\nasset_status = Non-Compliant\nOut-of-Service flag set]
        S7_remediate[Remediation workflow\nassigned contact + deadline\n48h reminder cycle]
        S7_rts{HUMAN REQUIRED:\nAdvisor authorizes\nReturn-to-Service}
        S7_cvip[CVIP tracking\n90/60/30/7-day ladder]
        S7_CEL[[CEL: inspection_completed\nor inspection_fail + remediation]]
    end

    S3_cert --> S7_1
    S7_1 --> S4_entry
    S7_1 --> S7_2
    S7_2 --> S7_mobile & S7_scan
    S7_mobile & S7_scan --> S7_3
    S7_3 -- Pass --> S7_pass --> S7_CEL
    S7_3 -- Fail --> S7_fail --> S7_remediate --> S7_rts
    S7_rts -- Authorized --> S7_pass
    S7_cvip --> S4_entry

    %% ============================================================
    %% STAGE 8 — CHEMICAL / SDS / ENVIRONMENTAL [TEMPORARY]
    %% ============================================================
    subgraph S8["STAGE 8 — Chemical, SDS & Environmental Records [TEMPORARY]"]
        direction TB
        S8_sds[SDS Library\nWeekly scan: records > 3 years\nAlert → Safety Manager]
        S8_chem[Chemical Inventory\nNew chemical → SDS intake\nrequired before use]
        S8_sample[Soil/Water Sampling\nCOC + Lab Results ingested\nthreshold_exceeded check]
        S8_env{Environmental threshold\nexceeded?}
        S8_env_a[Immediate push to advisor\n+ Safety Manager\nFLAG: REQUIRES_REVIEW]
        S8_env_b[EPEA verbal report\ncall Alberta Environment\n1-800-222-6514\ncall confirmation → CEL]
        S8_well[Well Tracking\nAER docs stored\nAdvisor confirms Petrinex submission]
        S8_note[[ALL STAGE 8 TEMPORARY\nPENDING ENVIRONMENTAL/LEGAL REVIEW\nNo automated gov submissions]]
    end

    S2_CEL --> S8_sds & S8_chem & S8_sample & S8_well
    S8_sample --> S8_env
    S8_env -- Yes --> S8_env_a --> S8_env_b
    S8_env -- No --> S8_note

    %% ============================================================
    %% STAGE 9 — AUDIT TRAIL, REPORTING & INTELLIGENCE
    %% ============================================================
    subgraph S9["STAGE 9 — Audit Trail, Reporting & Compliance Intelligence"]
        direction TB
        S9_cel_agg[CEL aggregates all stage events\ncontinuously\nretention labels enforced via Purview]

        S9_score[COR Readiness Score\nNightly Make.com calculation\nInputs: cert expiry status +\nSOP currency + inspection rate +\nopen approvals + CEL event density\nOutput: score → Client Registry]

        S9_posture[Compliance Posture Page\nPer-client SharePoint page\nLive data from existing lists\nNo new platform]

        S9_risk[Financial Risk Translation\nRule-based estimates only\nWCB premium impact\nCOR lapse penalty exposure\nInsurance eligibility risk\nOutput: dollar range estimates]

        S9_monthly[Monthly Compliance Status Report\nPushed to Safety Manager\n1st business day of each month]
        S9_quarterly[Quarterly Certification Dashboard\nPushed to Safety Manager + Executive\n12-month forward expiry view\n+ financial risk estimates]
        S9_annual[Annual SOP Version Log\nPushed to Safety Manager]

        S9_pkg{On-demand COR\nevidence package request}
        S9_compile[Compile per COR Element 1-8\nSharePoint query by date range\nCEL + DocuSign certs + documents]
        S9_gap[AI gap detection:\nmissing evidence types flagged\nadvisor alerted before finalization]
        S9_human{HUMAN REQUIRED:\nAdvisor certifies package\ncomplete before sharing with auditor}

        S9_ops[Vaquero Operations Dashboard\nreal-time: open escalations\nexpired certs, unsigned envelopes\nscenario failures]
        S9_CEL[[CEL: evidence package compiled\nadvisor certification timestamp]]
    end

    S5_CEL --> S9_cel_agg
    S7_CEL --> S9_cel_agg
    S6_CEL --> S9_cel_agg
    S4_CEL --> S9_cel_agg
    S2_CEL --> S9_cel_agg

    S9_cel_agg --> S9_score
    S9_score --> S9_posture
    S9_score --> S9_risk
    S9_score --> S9_monthly
    S9_risk --> S9_quarterly
    S9_cel_agg --> S9_annual
    S9_cel_agg --> S9_ops

    S9_pkg --> S9_compile --> S9_gap --> S9_human --> S9_CEL

    %% ============================================================
    %% CIRCULAR LOOPS
    %% ============================================================
    S5_confirm -. "Core compliance loop:\nnew expiry → Stage 3 watch" .-> S3_cert
    S6_7 -. "SOP update loop:\nnew version → Stage 3 watch" .-> S3_cert
    S4_amend3 -. "Amendment loop:\nrevised push resets cycle" .-> S4_entry
    S4_t30 -. "Escalation loop:\nterminates or documents non-compliance" .-> S9_cel_agg

    %% ============================================================
    %% STYLE ASSIGNMENTS
    %% ============================================================
    class S1_7,S1_9,S3_human,S6_human1,S6_human2,S7_rts,S9_human human
    class S1_1,S1_2,S1_4,S1_5,S1_6,S2_2a,S2_3,S2_4,S2_5,S3_cert,S3_rss,S3_scrape,S3_email,S4_2,S4_norsp,S6_4,S6_5,S6_track,S7_1,S7_mobile,S7_cvip,S9_compile,S9_gap auto
    class S1_CEL,S2_CEL,S3_CEL,S4_CEL,S5_CEL,S6_CEL,S7_CEL,S9_CEL cel
    class S1_3w,S2_2,S3_change,S3_reg,S3_contractor_alert,S4_3,S5_3,S5_change,S6_3,S7_2,S7_3,S8_env decision
    class S5_entry,S5_2,S5_signed,S5_archive,S5_meta,S5_cert_update docusign
    class S8_note,S8_env_a,S8_env_b temp
    class S3_contractor,S9_score,S9_posture,S9_risk new
```

---

## Diagram Key

| Color | Meaning |
|-------|---------|
| 🟠 Orange | **Human Required** — cannot be automated |
| 🔵 Blue | **Automated** — Make.com |
| 🟢 Dark Green | **CEL Write** — legal audit trail event |
| 🟣 Purple | **Decision Point** — branching logic |
| 💙 Steel Blue | **DocuSign** — envelope lifecycle |
| 🔴 Dark Red | **Temporary / Flagged** — pending legal or environmental review |
| 🌿 Forest Green | **New** — added from strategic analysis 2026-05-27 |

## Four Circular Loops

1. **Core Compliance Loop** — Stage 5 activation → Stage 3 watches new expiry → Stage 4 alert → Stage 5 → repeat
2. **SOP Update Loop** — Stage 3 Class A → Stage 6 propagates → Stage 4 per client → Stage 5 signs → Stage 3 monitors new version → repeat
3. **Amendment Loop** — Stage 4 Amend → advisor revision → revised push → repeat until Approve
4. **Escalation Loop** — Stage 4 no-response → T+7 → T+14 → T+21 → terminates on response or documents non-compliance in Stage 9 CEL

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-05-27 | Initial diagram — all 9 stages |
| 1.1.0 | 2026-05-27 | Integrated: Contractor/Vendor Registry (S3), COR Readiness Score (S9), Compliance Posture Page (S9), Financial Risk Translation (S9) |
