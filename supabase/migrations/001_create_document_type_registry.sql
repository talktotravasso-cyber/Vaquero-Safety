-- ============================================================
-- PURPOSE:   Create queryable document type registry for
--            Vaquero Safety Inc. dependency mapping system
-- INPUTS:    None — DDL only
-- OUTPUTS:   Tables: document_categories, document_types,
--                    document_type_industry_scope,
--                    document_type_client_profile
-- DEPENDENCIES: Supabase PostgreSQL instance (Canada Central)
-- MIGRATION:    001
-- CREATED:      2026-05-26
-- PLACEMENT:    C:\Projects\Vaquero_Safety_Inc\supabase\migrations\
-- ============================================================


-- ============================================================
-- TABLE 1: document_categories
-- Master list of category groupings for document types.
-- Stable reference data — rarely changes.
-- ============================================================

CREATE TABLE IF NOT EXISTS document_categories (
    category_id         TEXT PRIMARY KEY,
    -- e.g. 'SOP', 'INSPECTION', 'TRAINING', 'PERMIT', 'POLICY',
    --      'ASSET_RECORD', 'SITE_REVIEW', 'CHEMICAL_RECORD', 'LEGAL'

    category_name       TEXT NOT NULL,
    -- Human-readable label

    description         TEXT,
    -- What document types belong in this category

    sharepoint_folder_root  TEXT,
    -- Root folder in SharePoint that holds this category
    -- e.g. '/03-Processes/SOPs/'
    -- Matches Stage 2 / Stage 9 SharePoint folder map

    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE document_categories IS
    'Master groupings for document types. Maps to SharePoint folder roots and Stage 2 classification logic.';


-- ============================================================
-- TABLE 2: document_types
-- Core registry. One row per distinct document type
-- managed, generated, or monitored by the platform.
-- This is the FK target for the dependency mapping table.
-- ============================================================

CREATE TABLE IF NOT EXISTS document_types (
    document_type_id        TEXT PRIMARY KEY,
    -- Stable snake_case identifier. NEVER rename after FK use.
    -- e.g. 'CONFINED_SPACE_ENTRY_PERMIT'
    --      'FALL_PROTECTION_RESCUE_PLAN'
    --      'VEHICLE_PRE_TRIP_INSPECTION'
    --      'WHMIS_SDS_RECORD'

    category_id             TEXT NOT NULL
                            REFERENCES document_categories(category_id),

    document_type_name      TEXT NOT NULL,
    -- Human-readable name

    description             TEXT,
    -- What this document captures or governs

    regulatory_basis        TEXT NOT NULL
                            CHECK (regulatory_basis IN (
                                'MANDATORY',    -- Regulation explicitly requires this document
                                'BEST_PRACTICE' -- Vaquero operational standard; no direct regulatory mandate
                            )),
    -- MANDATORY: document must exist to satisfy a specific regulation
    -- BEST_PRACTICE: Vaquero-created for operational quality; no single clause mandates it

    mandatory_citation      TEXT,
    -- If regulatory_basis = 'MANDATORY', the primary regulation citation
    -- that requires this document to exist.
    -- e.g. 'AB OHS Code Part 5 s.45'
    -- NULL allowed only when regulatory_basis = 'BEST_PRACTICE'

    master_template_id      TEXT,
    -- FK to Vaquero master template library (future table).
    -- NULL if no master template exists yet.

    is_client_configurable  BOOLEAN NOT NULL DEFAULT FALSE,
    -- TRUE = client-specific sections can differ from master template
    -- FALSE = document is identical across all clients

    requires_docusign       BOOLEAN NOT NULL DEFAULT FALSE,
    -- TRUE = this document type routes through Stage 5 DocuSign execution

    requires_legal_review   BOOLEAN NOT NULL DEFAULT FALSE,
    -- TRUE = legal review required before electronic signature is valid
    -- Flags documents noted in Stage 5 legal standing caveat:
    -- Confined Space Entry Permits, specific First Aid docs, Mine site entry

    retention_period_years  NUMERIC(4,1),
    -- Retention in years. Use 0.25 for 3 months.
    -- NULL = retention not yet confirmed; must be resolved before production use.

    retention_citation      TEXT,
    -- Regulatory citation that sets the retention period
    -- e.g. 'AB OHS Act s.33' for incident investigation records

    sharepoint_subfolder    TEXT,
    -- Specific subfolder within the category root
    -- e.g. '/JHAs/' within '/03-Processes/'

    capture_methods         TEXT[],
    -- Valid Stage 2 capture_method values for this document type
    -- Values: 'mobile_app_online' | 'mobile_app_offline_sync' |
    --         'paper_scan_upload' | 'docusign_completed' | 'admin_upload'

    applies_to_people       BOOLEAN NOT NULL DEFAULT FALSE,
    -- TRUE = document tracks a person (worker, supervisor)

    applies_to_assets       BOOLEAN NOT NULL DEFAULT FALSE,
    -- TRUE = document tracks a physical asset

    applies_to_site         BOOLEAN NOT NULL DEFAULT FALSE,
    -- TRUE = document is site/location-specific

    applies_to_chemicals    BOOLEAN NOT NULL DEFAULT FALSE,
    -- TRUE = document relates to chemical/SDS management

    cor_element             TEXT[],
    -- Which COR elements this document type supports as evidence
    -- Values: 'E1' through 'E8' matching Stage 9 COR element map
    -- NULL = document does not directly serve as COR evidence

    confidence_rating       SMALLINT NOT NULL DEFAULT 2
                            CHECK (confidence_rating IN (1, 2, 3)),
    -- 1 = Hypothetical (placeholder; verify before use)
    -- 2 = Probable (structurally sound; needs live verification)
    -- 3 = Verified (confirmed against official regulatory source)

    notes                   TEXT,
    -- Any VERIFY_REQUIRED flags, edge cases, or open questions

    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by              TEXT
    -- Advisor ID or system identifier that created this row
);

COMMENT ON TABLE document_types IS
    'Core queryable registry of all document types managed by the platform. '
    'Primary FK target for regulatory_dependency_map. '
    'document_type_id is immutable after first FK reference.';

COMMENT ON COLUMN document_types.regulatory_basis IS
    'MANDATORY = regulation explicitly requires this document. '
    'BEST_PRACTICE = Vaquero operational standard only.';

COMMENT ON COLUMN document_types.retention_period_years IS
    'Use 0.25 for 3-month retention (trip inspection records). '
    'NULL is not production-safe — must be resolved before client use.';


-- ============================================================
-- TABLE 3: document_type_industry_scope
-- Which industries each document type applies to.
-- Separate table — avoid comma-delimited arrays in core registry.
-- ============================================================

CREATE TABLE IF NOT EXISTS document_type_industry_scope (
    scope_id            BIGSERIAL PRIMARY KEY,
    document_type_id    TEXT NOT NULL
                        REFERENCES document_types(document_type_id),
    industry            TEXT NOT NULL
                        CHECK (industry IN (
                            'OIL_GAS',
                            'CONSTRUCTION',
                            'TRUCKING',
                            'FORESTRY',
                            'ALL'           -- Universal across all industries
                        )),
    notes               TEXT,
    -- If applicability is conditional or partial, explain here
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (document_type_id, industry)
);

COMMENT ON TABLE document_type_industry_scope IS
    'Maps document types to applicable industries. '
    'Use ''ALL'' for universal types. Join this table when '
    'querying which document types apply to a client by industry.';


-- ============================================================
-- TABLE 4: document_type_client_profile_triggers
-- Which client profile flags activate a given document type.
-- Populated from Stage 1 onboarding profile fields.
-- ============================================================

CREATE TABLE IF NOT EXISTS document_type_client_profile_triggers (
    trigger_id              BIGSERIAL PRIMARY KEY,
    document_type_id        TEXT NOT NULL
                            REFERENCES document_types(document_type_id),

    profile_flag            TEXT NOT NULL
                            CHECK (profile_flag IN (
                                'HAS_FEDERAL_WORKSITES',
                                'HAS_OFFSHORE_OPERATIONS',
                                'IS_COR_CERTIFIED',
                                'IS_COR_PURSUING',
                                'HAS_PRESSURE_EQUIPMENT',
                                'HAS_CONFINED_SPACES',
                                'HAS_DESIGNATED_SUBSTANCES',
                                'HAS_HEAVY_VEHICLES',
                                'HAS_LIFTING_DEVICES',
                                'HAS_EXPLOSIVES',
                                'OPERATES_IN_AB',
                                'OPERATES_IN_BC',
                                'OPERATES_IN_SK',
                                'OPERATES_IN_MB',
                                'OPERATES_IN_ON',
                                'OPERATES_IN_QC',
                                'OPERATES_IN_NB',
                                'OPERATES_IN_NS',
                                'OPERATES_IN_NL',
                                'OPERATES_IN_PE',
                                'OPERATES_IN_NT',
                                'OPERATES_IN_NU',
                                'OPERATES_IN_YT',
                                'ALL_CLIENTS'   -- Always required regardless of profile
                            )),

    trigger_type            TEXT NOT NULL DEFAULT 'ACTIVATES'
                            CHECK (trigger_type IN (
                                'ACTIVATES',    -- Flag being TRUE activates this document type
                                'EXCLUDES'      -- Flag being TRUE excludes this document type
                            )),

    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (document_type_id, profile_flag, trigger_type)
);

COMMENT ON TABLE document_type_client_profile_triggers IS
    'Defines which Stage 1 client profile flags activate or exclude '
    'a document type for a given client. Used by Make.com scenarios '
    'to determine which document types are in scope at onboarding '
    'and at dependency query time.';


-- ============================================================
-- INDEXES
-- Optimized for the primary query patterns:
-- 1. Lookup all document types for a given industry
-- 2. Lookup all document types triggered by a client profile flag
-- 3. Lookup document types by category
-- 4. Lookup document types that are MANDATORY (for gap assessments)
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_document_types_category
    ON document_types(category_id);

CREATE INDEX IF NOT EXISTS idx_document_types_regulatory_basis
    ON document_types(regulatory_basis);

CREATE INDEX IF NOT EXISTS idx_document_types_requires_docusign
    ON document_types(requires_docusign)
    WHERE requires_docusign = TRUE;

CREATE INDEX IF NOT EXISTS idx_document_types_cor_element
    ON document_types USING GIN(cor_element);

CREATE INDEX IF NOT EXISTS idx_industry_scope_document_type
    ON document_type_industry_scope(document_type_id);

CREATE INDEX IF NOT EXISTS idx_industry_scope_industry
    ON document_type_industry_scope(industry);

CREATE INDEX IF NOT EXISTS idx_profile_triggers_document_type
    ON document_type_client_profile_triggers(document_type_id);

CREATE INDEX IF NOT EXISTS idx_profile_triggers_flag
    ON document_type_client_profile_triggers(profile_flag);


-- ============================================================
-- ROW-LEVEL SECURITY
-- All tables locked to authenticated Supabase sessions.
-- Vaquero internal only — no client-facing read access.
-- ============================================================

ALTER TABLE document_categories              ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_types                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_type_industry_scope     ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_type_client_profile_triggers ENABLE ROW LEVEL SECURITY;

-- Read access: authenticated users only
CREATE POLICY "authenticated_read_document_categories"
    ON document_categories FOR SELECT
    TO authenticated USING (TRUE);

CREATE POLICY "authenticated_read_document_types"
    ON document_types FOR SELECT
    TO authenticated USING (TRUE);

CREATE POLICY "authenticated_read_industry_scope"
    ON document_type_industry_scope FOR SELECT
    TO authenticated USING (TRUE);

CREATE POLICY "authenticated_read_profile_triggers"
    ON document_type_client_profile_triggers FOR SELECT
    TO authenticated USING (TRUE);

-- Write access: service_role only (Make.com webhook context, advisor tools)
CREATE POLICY "service_role_write_document_categories"
    ON document_categories FOR ALL
    TO service_role USING (TRUE);

CREATE POLICY "service_role_write_document_types"
    ON document_types FOR ALL
    TO service_role USING (TRUE);

CREATE POLICY "service_role_write_industry_scope"
    ON document_type_industry_scope FOR ALL
    TO service_role USING (TRUE);

CREATE POLICY "service_role_write_profile_triggers"
    ON document_type_client_profile_triggers FOR ALL
    TO service_role USING (TRUE);


-- ============================================================
-- UPDATED_AT TRIGGER
-- Auto-maintain updated_at on document_types and
-- document_categories without application-layer enforcement.
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_document_categories_updated_at
    BEFORE UPDATE ON document_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_document_types_updated_at
    BEFORE UPDATE ON document_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
