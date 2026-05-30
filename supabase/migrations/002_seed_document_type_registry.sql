-- ============================================================
-- PURPOSE:   Seed document_categories and initial O&G document
--            types for Vaquero Safety Inc. registry.
--            Run AFTER 001_create_document_type_registry.sql
-- INPUTS:    None
-- OUTPUTS:   Populated seed rows — O&G industry scope at launch.
--            Construction/Trucking/Forestry types added per
--            MATRIX_INSTRUCTIONS_[INDUSTRY].md sessions.
-- DEPENDENCIES: Migration 001 applied
-- MIGRATION:    002
-- CREATED:      2026-05-26
-- PLACEMENT:    C:\Projects\Vaquero_Safety_Inc\supabase\migrations\
-- CONFIDENCE:   2 — document type list derived from Oil & Gas
--               matrix v1.7.0 and workflow reference. Retention
--               citations require advisor verification pass
--               before confidence_rating updated to 3.
-- ============================================================


-- ============================================================
-- SECTION 1 — CATEGORIES
-- 9 categories matching Stage 2 classification and
-- Stage 9 SharePoint folder map.
-- ============================================================

INSERT INTO document_categories
    (category_id, category_name, description, sharepoint_folder_root)
VALUES
    ('SOP',
     'Standard Operating Procedure',
     'Step-by-step procedural documents governing work activities. Primary COR evidence for Elements 3 and 8.',
     '/03-Processes/SOPs/'),

    ('INSPECTION',
     'Inspection Record',
     'Completed inspection checklists for assets, sites, and equipment. COR evidence for Element 4.',
     '/02-Assets/Inspections/'),

    ('TRAINING',
     'Training and Orientation Record',
     'Records of completed worker training, orientations, and certifications. COR evidence for Element 5.',
     '/01-People/Training/'),

    ('PERMIT',
     'Work Permit',
     'Permits required before high-risk work begins. Confined space, hot work, ground disturbance.',
     '/03-Processes/Permits/'),

    ('POLICY',
     'Safety Policy and Program Document',
     'Top-level safety policy statements and program administration documents. COR evidence for Element 1.',
     '/01-Safety-Policy/'),

    ('ASSET_RECORD',
     'Asset Registration and Compliance Record',
     'Vehicle, equipment, and asset registration, CVIP, and maintenance records.',
     '/02-Assets/'),

    ('SITE_REVIEW',
     'Site and Environmental Review',
     'Site walkaround records, environmental monitoring, hazard assessments, JHAs. COR elements 2 and 4.',
     '/04-Site-Environmental/'),

    ('CHEMICAL_RECORD',
     'Chemical and SDS Record',
     'WHMIS SDS records, chemical inventory, and exposure monitoring documents.',
     '/09-WHMIS-SDS/'),

    ('LEGAL',
     'Legal and Contractual Document',
     'MSA, client agreements, DocuSign-executed documents. 7-year retention.',
     '/00-MSA-Legal/')

ON CONFLICT (category_id) DO NOTHING;


-- ============================================================
-- SECTION 2 — DOCUMENT TYPES (Oil & Gas — Launch Scope)
-- Derived from:
--   - Vaquero_OilGas_Compliance_Matrix_v1.7.0.xlsx Sheet B
--   - Vaquero_Workflow_Compressed.md Stage 2, 7, 8
--   - AB OHS Code Part references
-- confidence_rating = 2 on all rows until advisor verification pass.
-- ============================================================

INSERT INTO document_types (
    document_type_id,
    category_id,
    document_type_name,
    description,
    regulatory_basis,
    mandatory_citation,
    is_client_configurable,
    requires_docusign,
    requires_legal_review,
    retention_period_years,
    retention_citation,
    sharepoint_subfolder,
    capture_methods,
    applies_to_people,
    applies_to_assets,
    applies_to_site,
    applies_to_chemicals,
    cor_element,
    confidence_rating,
    notes
)
VALUES

-- ── POLICIES ──────────────────────────────────────────────

('SAFETY_POLICY_STATEMENT',
 'POLICY', 'Safety Policy Statement',
 'Signed top-level organizational health and safety policy. Must be signed by executive. COR Element 1 primary evidence.',
 'MANDATORY', 'AB OHS Act s.2(1)(a)',
 FALSE, TRUE, FALSE, 5, 'AB OHS Act s.40',
 '/01-Safety-Policy/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, FALSE, FALSE, ARRAY['E1', 'E8'],
 2, 'VERIFY_REQUIRED — confirm exact OHS Act citation for signed policy obligation'),

('HAZARD_ASSESSMENT_PROGRAM',
 'POLICY', 'Hazard Assessment Program Document',
 'Written hazard assessment program required under OHS Code Part 2.',
 'MANDATORY', 'AB OHS Code Part 2 s.7',
 TRUE, TRUE, FALSE, 5, NULL,
 '/01-Safety-Policy/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, FALSE, FALSE, ARRAY['E2', 'E8'],
 2, 'VERIFY_REQUIRED — retention period citation to confirm'),

('EMERGENCY_RESPONSE_PLAN',
 'POLICY', 'Emergency Response Plan',
 'Site or organizational emergency response plan. COR Element 6.',
 'MANDATORY', 'AB OHS Code Part 7 s.115',
 TRUE, TRUE, FALSE, 5, NULL,
 '/03-Processes/ERP/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, TRUE, FALSE, ARRAY['E6', 'E8'],
 2, NULL),

('INCIDENT_INVESTIGATION_PROGRAM',
 'POLICY', 'Incident Investigation Program',
 'Written program describing incident reporting and investigation procedures.',
 'MANDATORY', 'AB OHS Act s.18',
 TRUE, TRUE, FALSE, 5, NULL,
 '/01-Safety-Policy/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, FALSE, FALSE, ARRAY['E7', 'E8'],
 2, NULL),


-- ── SOPs ──────────────────────────────────────────────────

('SOP_CONFINED_SPACE',
 'SOP', 'Confined Space Entry SOP',
 'Standard operating procedure for confined space entry. Governs Part 5 compliance.',
 'MANDATORY', 'AB OHS Code Part 5 s.44',
 TRUE, TRUE, TRUE, 5, NULL,
 '/SOPs/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, TRUE, FALSE, ARRAY['E3', 'E8'],
 2, 'requires_legal_review = TRUE — OHS Code Part 5 s.45 raises question on electronic signatures for entry permits. SOP itself may be electronic; entry permit reviewed separately.'),

('SOP_FALL_PROTECTION',
 'SOP', 'Fall Protection SOP',
 'Procedure for working at heights and fall protection equipment use. AB OHS Code Part 9.',
 'MANDATORY', 'AB OHS Code Part 9 s.139',
 TRUE, TRUE, FALSE, 5, NULL,
 '/SOPs/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, TRUE, FALSE, ARRAY['E3', 'E8'],
 2, NULL),

('SOP_H2S_RESPONSE',
 'SOP', 'H2S Response and Escape SOP',
 'Procedure for H2S hazard response, evacuation, and rescue in sour gas environments.',
 'MANDATORY', 'AB OHS Code Part 4 s.30',
 TRUE, TRUE, FALSE, 5, NULL,
 '/SOPs/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, TRUE, FALSE, ARRAY['E3', 'E6', 'E8'],
 2, 'VERIFY_REQUIRED — confirm specific OHS Code citation for written H2S response procedure'),

('SOP_GROUND_DISTURBANCE',
 'SOP', 'Ground Disturbance SOP',
 'Procedure for ground disturbance activities near buried facilities. Pipeline Act requirements.',
 'MANDATORY', 'AB Pipeline Act / AB OHS Code Part 32',
 TRUE, TRUE, FALSE, 5, NULL,
 '/SOPs/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, TRUE, FALSE, ARRAY['E3', 'E8'],
 2, 'VERIFY_REQUIRED — dual regulatory basis (Pipeline Act + OHS Code) requires advisor clarification on primary citation'),

('SOP_WHMIS',
 'SOP', 'WHMIS Program and Procedure SOP',
 'Written WHMIS program covering hazardous product identification, SDS, labels, and worker training. GHS Rev 7/8 current.',
 'MANDATORY', 'AB OHS Code Part 29',
 TRUE, TRUE, FALSE, 5, NULL,
 '/SOPs/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, FALSE, FALSE, TRUE, ARRAY['E3', 'E5', 'E8'],
 2, 'Note: WHMIS 2015 name retired December 14, 2025. Reference current GHS Rev 7/8 standard only.'),

('SOP_TDG',
 'SOP', 'Transportation of Dangerous Goods SOP',
 'Procedure for TDG documentation, placarding, and emergency response. SOR/2001-286.',
 'MANDATORY', 'TDG Regs SOR/2001-286',
 TRUE, TRUE, FALSE, 5, NULL,
 '/SOPs/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, TRUE, FALSE, FALSE, ARRAY['E3', 'E8'],
 2, NULL),

('SOP_LOCKOUT_TAGOUT',
 'SOP', 'Lockout/Tagout (Energy Isolation) SOP',
 'Energy control procedure for maintenance and servicing of equipment. AB OHS Code Part 15.',
 'MANDATORY', 'AB OHS Code Part 15 s.214',
 TRUE, TRUE, FALSE, 5, NULL,
 '/SOPs/', ARRAY['docusign_completed', 'admin_upload'],
 FALSE, TRUE, TRUE, FALSE, ARRAY['E3', 'E8'],
 2, NULL),


-- ── PERMITS ───────────────────────────────────────────────

('CONFINED_SPACE_ENTRY_PERMIT',
 'PERMIT', 'Confined Space Entry Permit',
 'Permit issued before each confined space entry. Captures atmospheric testing, rescue plan, and authorization.',
 'MANDATORY', 'AB OHS Code Part 5 s.45',
 TRUE, FALSE, TRUE, 1, 'AB OHS Code Part 5',
 '/03-Processes/Permits/', ARRAY['mobile_app_online', 'mobile_app_offline_sync', 'paper_scan_upload'],
 TRUE, FALSE, TRUE, FALSE, ARRAY['E3', 'E7'],
 2, 'requires_legal_review = TRUE — OHS Code Part 5 s.45 specifically referenced in Stage 5 legal caveat. Confirm with advisor whether electronic permit satisfies OHS Code before enabling DocuSign routing.'),

('HOT_WORK_PERMIT',
 'PERMIT', 'Hot Work Permit',
 'Permit required before welding, cutting, or other ignition-source activities.',
 'MANDATORY', 'AB OHS Code Part 10',
 TRUE, FALSE, FALSE, 1, NULL,
 '/03-Processes/Permits/', ARRAY['mobile_app_online', 'mobile_app_offline_sync', 'paper_scan_upload'],
 TRUE, FALSE, TRUE, FALSE, ARRAY['E3'],
 2, 'VERIFY_REQUIRED — confirm retention period and specific OHS Code Part 10 section citation'),

('GROUND_DISTURBANCE_PERMIT',
 'PERMIT', 'Ground Disturbance Permit / Locate Request Record',
 'Record of locate request and authorization before ground disturbance work begins.',
 'MANDATORY', 'AB Pipeline Act',
 TRUE, FALSE, FALSE, 1, NULL,
 '/03-Processes/Permits/', ARRAY['mobile_app_online', 'paper_scan_upload', 'admin_upload'],
 TRUE, FALSE, TRUE, FALSE, ARRAY['E3'],
 2, 'VERIFY_REQUIRED — confirm if Ground Disturbance Regulation (Alta Reg 221/2009) or Pipeline Act is primary citation'),


-- ── TRAINING RECORDS ──────────────────────────────────────

('TRAINING_RECORD_H2S_ALIVE',
 'TRAINING', 'H2S Alive Training Record',
 'Record of worker H2S Alive certification. Issuing body: Energy Safety Canada. No name-searchable public registry.',
 'MANDATORY', 'AB OHS Code Part 4',
 FALSE, FALSE, FALSE, 3, NULL,
 '/Training/', ARRAY['admin_upload', 'mobile_app_online'],
 TRUE, FALSE, FALSE, FALSE, ARRAY['E5'],
 2, 'Verification URL: https://www.energysafetycanada.com/Training/Registrations-Certificates/Certificate-Validation — certificate number required for lookup.'),

('TRAINING_RECORD_FALL_PROTECTION',
 'TRAINING', 'Fall Protection Training Record',
 'Record of fall protection training completion. AB OHS Code Part 9.',
 'MANDATORY', 'AB OHS Code Part 9 s.139',
 FALSE, FALSE, FALSE, 3, NULL,
 '/Training/', ARRAY['admin_upload', 'mobile_app_online'],
 TRUE, FALSE, FALSE, FALSE, ARRAY['E5'],
 2, NULL),

('TRAINING_RECORD_CONFINED_SPACE',
 'TRAINING', 'Confined Space Training Record',
 'Record of confined space worker, supervisor, and rescue training. Retention varies by incident history.',
 'MANDATORY', 'AB OHS Code Part 5',
 FALSE, FALSE, FALSE, 1, 'AB OHS Code Part 5 / OHS Act s.33',
 '/Training/', ARRAY['admin_upload', 'mobile_app_online'],
 TRUE, FALSE, FALSE, FALSE, ARRAY['E5'],
 2, 'Retention: 1 year (no incident) or 2 years (incident involved). Supabase must store incident_flag to determine applicable retention at document level.'),

('TRAINING_RECORD_WHMIS',
 'TRAINING', 'WHMIS Training Record',
 'Record of worker WHMIS training. Annual retraining required when new hazardous products introduced.',
 'MANDATORY', 'AB OHS Code Part 29',
 FALSE, FALSE, FALSE, 3, NULL,
 '/Training/', ARRAY['admin_upload', 'mobile_app_online'],
 TRUE, FALSE, FALSE, FALSE, ARRAY['E5'],
 2, NULL),

('TRAINING_RECORD_FIRST_AID',
 'TRAINING', 'First Aid Certification Record',
 'Record of worker first aid certification. Level varies by worksite size and remoteness under OHS Code Part 11.',
 'MANDATORY', 'AB OHS Code Part 11',
 FALSE, FALSE, FALSE, 3, NULL,
 '/Training/', ARRAY['admin_upload', 'mobile_app_online'],
 TRUE, FALSE, FALSE, FALSE, ARRAY['E5'],
 2, NULL),

('TRAINING_RECORD_TDG',
 'TRAINING', 'TDG Training Record',
 'Record of Transportation of Dangerous Goods training. Required for all handlers.',
 'MANDATORY', 'TDG Regs SOR/2001-286 s.6.1',
 FALSE, FALSE, FALSE, 3, NULL,
 '/Training/', ARRAY['admin_upload', 'mobile_app_online'],
 TRUE, FALSE, FALSE, FALSE, ARRAY['E5'],
 2, NULL),

('ORIENTATION_RECORD',
 'TRAINING', 'Worker Orientation Record',
 'Record of site-specific and organizational safety orientation. COR Element 5.',
 'MANDATORY', 'AB OHS Act s.2',
 TRUE, FALSE, FALSE, 5, NULL,
 '/Orientations/', ARRAY['mobile_app_online', 'mobile_app_offline_sync', 'paper_scan_upload'],
 TRUE, FALSE, TRUE, FALSE, ARRAY['E5'],
 2, NULL),


-- ── INSPECTION RECORDS ────────────────────────────────────

('VEHICLE_PRE_TRIP_INSPECTION',
 'INSPECTION', 'Vehicle Pre-Trip Inspection Record',
 'Daily vehicle inspection record. NSC Standard 13 compliance.',
 'MANDATORY', 'AB Traffic Safety Act / NSC Standard 13',
 FALSE, FALSE, FALSE, 0.25, 'NSC Standard 13',
 '/Vehicles/', ARRAY['mobile_app_online', 'mobile_app_offline_sync', 'paper_scan_upload'],
 FALSE, TRUE, FALSE, FALSE, ARRAY['E4'],
 2, 'Retention: 3 months per NSC Standard 13. Use 0.25 years in system.'),

('CVIP_CERTIFICATE',
 'ASSET_RECORD', 'CVIP Certificate',
 'Commercial Vehicle Inspection Program certificate. Physical copy required in vehicle and operator office.',
 'MANDATORY', 'AB Traffic Safety Act / NSC Standard 11B',
 FALSE, FALSE, FALSE, 3, 'NSC Standard 11B',
 '/Vehicles/CVIP/', ARRAY['admin_upload', 'paper_scan_upload'],
 FALSE, TRUE, FALSE, FALSE, ARRAY['E4'],
 2, 'Physical copy required in vehicle AND operator office per NSC. Digital copy in SharePoint is supplementary only.'),

('SITE_WALKAROUND_INSPECTION',
 'SITE_REVIEW', 'Site Safety Walkaround Record',
 'Periodic site inspection record. Frequency varies by site classification.',
 'MANDATORY', 'AB OHS Code Part 2',
 TRUE, FALSE, FALSE, 5, NULL,
 '/Walkarounds/', ARRAY['mobile_app_online', 'mobile_app_offline_sync', 'paper_scan_upload'],
 FALSE, FALSE, TRUE, FALSE, ARRAY['E4'],
 2, NULL),

('LIFTING_DEVICE_INSPECTION',
 'INSPECTION', 'Lifting Device Inspection Record',
 'Inspection record for cranes, hoists, and lifting devices. ABSA regulated.',
 'MANDATORY', 'AB Safety Codes Act / ABSA',
 FALSE, FALSE, FALSE, 3, NULL,
 '/Equipment/', ARRAY['admin_upload', 'paper_scan_upload'],
 FALSE, TRUE, FALSE, FALSE, ARRAY['E4'],
 2, 'ABSA scope confirmed: ABSA does NOT issue crane operator certificates — that is a separate credential. ABSA scope here is equipment inspection certification only.'),

('PRESSURE_VESSEL_INSPECTION',
 'INSPECTION', 'Pressure Vessel Inspection Record',
 'Inspection record for pressure vessels and pressure equipment. ABSA regulated.',
 'MANDATORY', 'AB Safety Codes Act / ABSA',
 FALSE, FALSE, FALSE, 3, NULL,
 '/Equipment/', ARRAY['admin_upload', 'paper_scan_upload'],
 FALSE, TRUE, FALSE, FALSE, ARRAY['E4'],
 2, NULL),


-- ── SITE REVIEW / ENVIRONMENTAL ───────────────────────────

('JHA_RECORD',
 'SITE_REVIEW', 'Job Hazard Assessment (JHA) Record',
 'Task-specific hazard assessment completed before non-routine or high-risk work.',
 'MANDATORY', 'AB OHS Code Part 2 s.7',
 TRUE, FALSE, FALSE, 5, NULL,
 '/JHAs/', ARRAY['mobile_app_online', 'mobile_app_offline_sync', 'paper_scan_upload'],
 TRUE, FALSE, TRUE, FALSE, ARRAY['E2', 'E4'],
 2, NULL),

('INCIDENT_INVESTIGATION_REPORT',
 'SITE_REVIEW', 'Incident Investigation Report',
 'Formal investigation report for incidents, near misses, and dangerous occurrences.',
 'MANDATORY', 'AB OHS Act s.18',
 TRUE, FALSE, FALSE, 2, 'AB OHS Act s.33',
 '/Incidents/', ARRAY['admin_upload', 'mobile_app_online', 'paper_scan_upload'],
 TRUE, FALSE, TRUE, FALSE, ARRAY['E7'],
 2, NULL),

('ENVIRONMENTAL_MONITORING_RECORD',
 'SITE_REVIEW', 'Environmental Monitoring Record',
 'Soil, water, and air quality monitoring records. Stage 8 TEMPORARY status applies.',
 'MANDATORY', 'AB EPEA / AER Directives',
 TRUE, FALSE, FALSE, 5, NULL,
 '/04-Site-Environmental/', ARRAY['admin_upload', 'paper_scan_upload'],
 FALSE, FALSE, TRUE, FALSE, NULL,
 1, 'TEMPORARY — all Stage 8 environmental records flagged compliance_flag = REQUIRES_REVIEW. No automated government submissions until legal review complete. confidence_rating = 1 until legal review concludes.'),


-- ── CHEMICAL / SDS ────────────────────────────────────────

('SDS_RECORD',
 'CHEMICAL_RECORD', 'Safety Data Sheet (SDS)',
 'Current SDS for each hazardous product on site. GHS Rev 7/8. Reviewed every 3 years minimum.',
 'MANDATORY', 'AB OHS Code Part 29 / WHMIS HPR SOR/2015-17',
 FALSE, FALSE, FALSE, 5, NULL,
 '/09-WHMIS-SDS/', ARRAY['admin_upload'],
 FALSE, FALSE, TRUE, TRUE, ARRAY['E3', 'E5'],
 2, 'Weekly Make.com scan flags SDS older than 3 years. Mobile app pre-caches SDS offline for assigned site chemicals.'),

('CHEMICAL_INVENTORY',
 'CHEMICAL_RECORD', 'Chemical Inventory Register',
 'Complete inventory of hazardous products on site. New chemicals require SDS ingestion before use.',
 'MANDATORY', 'AB OHS Code Part 29',
 TRUE, FALSE, FALSE, 5, NULL,
 '/09-WHMIS-SDS/', ARRAY['admin_upload', 'mobile_app_online'],
 FALSE, FALSE, TRUE, TRUE, ARRAY['E3'],
 2, NULL),


-- ── ASSET RECORDS ─────────────────────────────────────────

('ASSET_REGISTRATION_RECORD',
 'ASSET_RECORD', 'Asset Registration Record',
 'Master registration record for vehicles, equipment, and assets in the asset registry.',
 'BEST_PRACTICE', NULL,
 FALSE, FALSE, FALSE, 5, NULL,
 '/02-Assets/', ARRAY['admin_upload'],
 FALSE, TRUE, FALSE, FALSE, ARRAY['E4'],
 2, NULL),

('VEHICLE_MAINTENANCE_RECORD',
 'ASSET_RECORD', 'Vehicle Maintenance Record',
 'Maintenance and repair history for commercial vehicles. NSC Standard 13.',
 'MANDATORY', 'NSC Standard 13',
 FALSE, FALSE, FALSE, 3, 'NSC Standard 13',
 '/Vehicles/', ARRAY['admin_upload', 'paper_scan_upload'],
 FALSE, TRUE, FALSE, FALSE, ARRAY['E4'],
 2, NULL),


-- ── LEGAL ─────────────────────────────────────────────────

('MASTER_SERVICE_AGREEMENT',
 'LEGAL', 'Master Service Agreement (MSA)',
 'Executed MSA between Vaquero Safety Inc. and client. DocuSign executed at onboarding.',
 'BEST_PRACTICE', NULL,
 FALSE, TRUE, FALSE, 7, NULL,
 '/00-MSA-Legal/', ARRAY['docusign_completed'],
 FALSE, FALSE, FALSE, FALSE, NULL,
 3, 'Retention 7 years — legal/contractual standard. confidence_rating = 3: well-established practice confirmed.')

ON CONFLICT (document_type_id) DO NOTHING;


-- ============================================================
-- SECTION 3 — INDUSTRY SCOPE (O&G — All types above)
-- All document types seeded above are scoped to OIL_GAS.
-- Universal types additionally tagged ALL_CLIENTS where applicable.
-- ============================================================

INSERT INTO document_type_industry_scope (document_type_id, industry)
SELECT document_type_id, 'OIL_GAS'
FROM document_types
WHERE document_type_id IN (
    'SAFETY_POLICY_STATEMENT', 'HAZARD_ASSESSMENT_PROGRAM',
    'EMERGENCY_RESPONSE_PLAN', 'INCIDENT_INVESTIGATION_PROGRAM',
    'SOP_CONFINED_SPACE', 'SOP_FALL_PROTECTION', 'SOP_H2S_RESPONSE',
    'SOP_GROUND_DISTURBANCE', 'SOP_WHMIS', 'SOP_TDG', 'SOP_LOCKOUT_TAGOUT',
    'CONFINED_SPACE_ENTRY_PERMIT', 'HOT_WORK_PERMIT', 'GROUND_DISTURBANCE_PERMIT',
    'TRAINING_RECORD_H2S_ALIVE', 'TRAINING_RECORD_FALL_PROTECTION',
    'TRAINING_RECORD_CONFINED_SPACE', 'TRAINING_RECORD_WHMIS',
    'TRAINING_RECORD_FIRST_AID', 'TRAINING_RECORD_TDG', 'ORIENTATION_RECORD',
    'VEHICLE_PRE_TRIP_INSPECTION', 'CVIP_CERTIFICATE', 'SITE_WALKAROUND_INSPECTION',
    'LIFTING_DEVICE_INSPECTION', 'PRESSURE_VESSEL_INSPECTION',
    'JHA_RECORD', 'INCIDENT_INVESTIGATION_REPORT', 'ENVIRONMENTAL_MONITORING_RECORD',
    'SDS_RECORD', 'CHEMICAL_INVENTORY',
    'ASSET_REGISTRATION_RECORD', 'VEHICLE_MAINTENANCE_RECORD',
    'MASTER_SERVICE_AGREEMENT'
)
ON CONFLICT (document_type_id, industry) DO NOTHING;


-- ============================================================
-- SECTION 4 — CLIENT PROFILE TRIGGERS (O&G launch scope)
-- Maps profile flags to document types that activate on them.
-- ALL_CLIENTS = required regardless of profile.
-- ============================================================

INSERT INTO document_type_client_profile_triggers
    (document_type_id, profile_flag, trigger_type)
VALUES
-- Universal — every client
('SAFETY_POLICY_STATEMENT',         'ALL_CLIENTS', 'ACTIVATES'),
('HAZARD_ASSESSMENT_PROGRAM',       'ALL_CLIENTS', 'ACTIVATES'),
('EMERGENCY_RESPONSE_PLAN',         'ALL_CLIENTS', 'ACTIVATES'),
('INCIDENT_INVESTIGATION_PROGRAM',  'ALL_CLIENTS', 'ACTIVATES'),
('SOP_WHMIS',                       'ALL_CLIENTS', 'ACTIVATES'),
('ORIENTATION_RECORD',              'ALL_CLIENTS', 'ACTIVATES'),
('JHA_RECORD',                      'ALL_CLIENTS', 'ACTIVATES'),
('INCIDENT_INVESTIGATION_REPORT',   'ALL_CLIENTS', 'ACTIVATES'),
('SDS_RECORD',                      'ALL_CLIENTS', 'ACTIVATES'),
('CHEMICAL_INVENTORY',              'ALL_CLIENTS', 'ACTIVATES'),
('ASSET_REGISTRATION_RECORD',       'ALL_CLIENTS', 'ACTIVATES'),
('MASTER_SERVICE_AGREEMENT',        'ALL_CLIENTS', 'ACTIVATES'),
('SITE_WALKAROUND_INSPECTION',      'ALL_CLIENTS', 'ACTIVATES'),
('TRAINING_RECORD_WHMIS',           'ALL_CLIENTS', 'ACTIVATES'),
('TRAINING_RECORD_FIRST_AID',       'ALL_CLIENTS', 'ACTIVATES'),
('SOP_FALL_PROTECTION',             'ALL_CLIENTS', 'ACTIVATES'),
('TRAINING_RECORD_FALL_PROTECTION', 'ALL_CLIENTS', 'ACTIVATES'),
('SOP_LOCKOUT_TAGOUT',              'ALL_CLIENTS', 'ACTIVATES'),

-- Confined space — triggered by site flag
('SOP_CONFINED_SPACE',              'HAS_CONFINED_SPACES', 'ACTIVATES'),
('CONFINED_SPACE_ENTRY_PERMIT',     'HAS_CONFINED_SPACES', 'ACTIVATES'),
('TRAINING_RECORD_CONFINED_SPACE',  'HAS_CONFINED_SPACES', 'ACTIVATES'),

-- H2S — O&G environments
('SOP_H2S_RESPONSE',                'OPERATES_IN_AB', 'ACTIVATES'),
('TRAINING_RECORD_H2S_ALIVE',       'OPERATES_IN_AB', 'ACTIVATES'),

-- Ground disturbance — O&G / pipeline proximity
('SOP_GROUND_DISTURBANCE',          'OPERATES_IN_AB', 'ACTIVATES'),
('GROUND_DISTURBANCE_PERMIT',       'OPERATES_IN_AB', 'ACTIVATES'),

-- Hot work — site-based
('HOT_WORK_PERMIT',                 'ALL_CLIENTS', 'ACTIVATES'),

-- TDG — any client moving dangerous goods
('SOP_TDG',                         'HAS_HEAVY_VEHICLES', 'ACTIVATES'),
('TRAINING_RECORD_TDG',             'HAS_HEAVY_VEHICLES', 'ACTIVATES'),

-- Vehicles and assets
('VEHICLE_PRE_TRIP_INSPECTION',     'HAS_HEAVY_VEHICLES', 'ACTIVATES'),
('VEHICLE_MAINTENANCE_RECORD',      'HAS_HEAVY_VEHICLES', 'ACTIVATES'),
('CVIP_CERTIFICATE',                'HAS_HEAVY_VEHICLES', 'ACTIVATES'),

-- Pressure equipment — ABSA scope
('PRESSURE_VESSEL_INSPECTION',      'HAS_PRESSURE_EQUIPMENT', 'ACTIVATES'),

-- Lifting devices
('LIFTING_DEVICE_INSPECTION',       'HAS_LIFTING_DEVICES', 'ACTIVATES'),

-- Environmental — O&G only, TEMPORARY status
('ENVIRONMENTAL_MONITORING_RECORD', 'OPERATES_IN_AB', 'ACTIVATES')

ON CONFLICT (document_type_id, profile_flag, trigger_type) DO NOTHING;
