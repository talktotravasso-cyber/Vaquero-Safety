# Document Type Registry — Scaffold Reference

**File:** `compliance/DOCUMENT_TYPE_REGISTRY.md`  
**Scaffold Layer:** 3 — `compliance/`  
**Version:** 1.0.0  
**Created:** 2026-05-26  
**Status:** Active — O&G scope seeded. Construction/Trucking/Forestry pending industry matrix sessions.

---

## Purpose

This file documents the queryable document type registry introduced in Supabase
migration 001/002. It is the **source of truth** for how document types are
defined, scoped, and queried across the platform.

Load this file alongside `COMPLIANCE.md` for any task involving:
- Stage 1 client onboarding (document type activation by client profile)
- Stage 2 document classification (mapping intake documents to registry types)
- Stage 3 regulatory monitoring (dependency mapping query targets)
- Stage 6 SOP propagation (identifying affected document types)
- Stage 9 COR audit evidence packaging (filtering by `cor_element`)

---

## Supabase Tables

| Table | Purpose |
|---|---|
| `document_categories` | 9 master groupings mapping to SharePoint folder roots |
| `document_types` | Core registry — one row per document type; FK target for dependency mapping |
| `document_type_industry_scope` | Which industries each document type applies to |
| `document_type_client_profile_triggers` | Which client profile flags activate/exclude each document type |

**Migration files:**
```
C:\Projects\Vaquero_Safety_Inc\supabase\migrations\001_create_document_type_registry.sql
C:\Projects\Vaquero_Safety_Inc\supabase\migrations\002_seed_document_type_registry.sql
```

---

## Categories (9)

| category_id | SharePoint Root | Primary COR Elements |
|---|---|---|
| `SOP` | `/03-Processes/SOPs/` | E3, E8 |
| `INSPECTION` | `/02-Assets/Inspections/` | E4 |
| `TRAINING` | `/01-People/Training/` | E5 |
| `PERMIT` | `/03-Processes/Permits/` | E3 |
| `POLICY` | `/01-Safety-Policy/` | E1, E8 |
| `ASSET_RECORD` | `/02-Assets/` | E4 |
| `SITE_REVIEW` | `/04-Site-Environmental/` | E2, E4, E7 |
| `CHEMICAL_RECORD` | `/09-WHMIS-SDS/` | E3, E5 |
| `LEGAL` | `/00-MSA-Legal/` | — |

---

## Document Types Seeded (O&G — v1.0.0)

### Policies (4)
| document_type_id | Regulatory Basis | DocuSign | Retention |
|---|---|---|---|
| `SAFETY_POLICY_STATEMENT` | MANDATORY | Yes | 5 yr |
| `HAZARD_ASSESSMENT_PROGRAM` | MANDATORY | Yes | 5 yr |
| `EMERGENCY_RESPONSE_PLAN` | MANDATORY | Yes | 5 yr |
| `INCIDENT_INVESTIGATION_PROGRAM` | MANDATORY | Yes | 5 yr |

### SOPs (7)
| document_type_id | Regulatory Basis | Legal Review | Retention |
|---|---|---|---|
| `SOP_CONFINED_SPACE` | MANDATORY | **Yes** | 5 yr |
| `SOP_FALL_PROTECTION` | MANDATORY | No | 5 yr |
| `SOP_H2S_RESPONSE` | MANDATORY | No | 5 yr |
| `SOP_GROUND_DISTURBANCE` | MANDATORY | No | 5 yr |
| `SOP_WHMIS` | MANDATORY | No | 5 yr |
| `SOP_TDG` | MANDATORY | No | 5 yr |
| `SOP_LOCKOUT_TAGOUT` | MANDATORY | No | 5 yr |

### Permits (3)
| document_type_id | Legal Review | Retention |
|---|---|---|
| `CONFINED_SPACE_ENTRY_PERMIT` | **Yes** | 1 yr |
| `HOT_WORK_PERMIT` | No | 1 yr |
| `GROUND_DISTURBANCE_PERMIT` | No | 1 yr |

### Training Records (7)
| document_type_id | Retention |
|---|---|
| `TRAINING_RECORD_H2S_ALIVE` | 3 yr |
| `TRAINING_RECORD_FALL_PROTECTION` | 3 yr |
| `TRAINING_RECORD_CONFINED_SPACE` | 1 yr / 2 yr (incident) |
| `TRAINING_RECORD_WHMIS` | 3 yr |
| `TRAINING_RECORD_FIRST_AID` | 3 yr |
| `TRAINING_RECORD_TDG` | 3 yr |
| `ORIENTATION_RECORD` | 5 yr |

### Inspection Records (5)
| document_type_id | Retention |
|---|---|
| `VEHICLE_PRE_TRIP_INSPECTION` | 3 months (0.25 yr) |
| `CVIP_CERTIFICATE` | 3 yr |
| `SITE_WALKAROUND_INSPECTION` | 5 yr |
| `LIFTING_DEVICE_INSPECTION` | 3 yr |
| `PRESSURE_VESSEL_INSPECTION` | 3 yr |

### Site Review / Environmental (3)
| document_type_id | Confidence | Notes |
|---|---|---|
| `JHA_RECORD` | 2 | Universal |
| `INCIDENT_INVESTIGATION_REPORT` | 2 | 2 yr retention |
| `ENVIRONMENTAL_MONITORING_RECORD` | **1** | TEMPORARY — legal review gate |

### Chemical Records (2)
| document_type_id | Notes |
|---|---|
| `SDS_RECORD` | 3-year review scan active |
| `CHEMICAL_INVENTORY` | New chemical blocks use until SDS ingested |

### Asset Records (2)
| document_type_id | Notes |
|---|---|
| `ASSET_REGISTRATION_RECORD` | Best practice — no mandatory citation |
| `VEHICLE_MAINTENANCE_RECORD` | NSC Standard 13 — 3 yr |

### Legal (1)
| document_type_id | Retention | Confidence |
|---|---|---|
| `MASTER_SERVICE_AGREEMENT` | 7 yr | 3 — verified |

---

## Open VERIFY_REQUIRED Items

These must be resolved before confidence_rating is updated to 3.
Assign to compliance advisor verification pass.

| document_type_id | Open Item |
|---|---|
| `SAFETY_POLICY_STATEMENT` | Confirm exact OHS Act citation for signed policy obligation |
| `HAZARD_ASSESSMENT_PROGRAM` | Confirm retention period regulatory citation |
| `SOP_H2S_RESPONSE` | Confirm specific OHS Code citation for written H2S response procedure |
| `SOP_GROUND_DISTURBANCE` | Clarify primary citation: Pipeline Act vs OHS Code Part 32 |
| `HOT_WORK_PERMIT` | Confirm retention period and specific OHS Code Part 10 section |
| `GROUND_DISTURBANCE_PERMIT` | Confirm primary citation: Ground Disturbance Regulation vs Pipeline Act |
| `CONFINED_SPACE_ENTRY_PERMIT` | Advisor to confirm electronic permit satisfies OHS Code Part 5 s.45 before DocuSign enabled |
| `ENVIRONMENTAL_MONITORING_RECORD` | Full legal review required — Stage 8 TEMPORARY status active |

---

## Key Query Patterns

### 1. Which document types apply to a new client?

```sql
-- Returns all document types active for an O&G client
-- that has confined spaces and heavy vehicles in Alberta

SELECT dt.document_type_id, dt.document_type_name, dt.category_id
FROM document_types dt
JOIN document_type_industry_scope dis
    ON dt.document_type_id = dis.document_type_id
JOIN document_type_client_profile_triggers cpt
    ON dt.document_type_id = cpt.document_type_id
WHERE dis.industry IN ('OIL_GAS', 'ALL')
  AND cpt.profile_flag IN (
      'ALL_CLIENTS',
      'HAS_CONFINED_SPACES',
      'HAS_HEAVY_VEHICLES',
      'OPERATES_IN_AB'
  )
  AND cpt.trigger_type = 'ACTIVATES'
  AND dt.is_active = TRUE
GROUP BY dt.document_type_id, dt.document_type_name, dt.category_id;
```

### 2. Which document types support COR Element 5?

```sql
SELECT document_type_id, document_type_name
FROM document_types
WHERE 'E5' = ANY(cor_element)
  AND is_active = TRUE;
```

### 3. Which document types require legal review before DocuSign?

```sql
SELECT document_type_id, document_type_name, mandatory_citation
FROM document_types
WHERE requires_legal_review = TRUE
  AND is_active = TRUE;
```

### 4. Which document types are MANDATORY for gap assessment?

```sql
SELECT dt.document_type_id, dt.document_type_name,
       dt.mandatory_citation, dt.category_id
FROM document_types dt
WHERE dt.regulatory_basis = 'MANDATORY'
  AND dt.is_active = TRUE
ORDER BY dt.category_id, dt.document_type_name;
```

---

## Operational Rules

1. **`document_type_id` is immutable** after first use as a FK in
   `regulatory_dependency_map`. Rename = migration + FK cascade. Never rename casually.

2. **New document types require advisor sign-off** before `is_active = TRUE`.
   Minimum fields required: `regulatory_basis`, `mandatory_citation` (if MANDATORY),
   `retention_period_years`, `retention_citation`.

3. **`confidence_rating = 1`** means the document type is a placeholder.
   It must not be used in client-facing workflows until upgraded to 2 or 3.

4. **`ENVIRONMENTAL_MONITORING_RECORD`** remains at confidence 1 and
   `compliance_flag = REQUIRES_REVIEW` until Stage 8 legal review is complete.
   Do not activate automated workflows against this type.

5. **`TRAINING_RECORD_CONFINED_SPACE`** retention is variable. The document-level
   record in Stage 2 metadata must carry an `incident_flag` boolean so the
   Purview retention label applies the correct period (1 yr vs 2 yr).

6. **Adding new industries:** Run industry matrix session first. After XLSX and
   seed `.md` are complete, add document types via new migration file
   `00N_seed_document_type_registry_[industry].sql`. Never modify migration 002.

---

## Scaffold Update Triggers for This File

Update this file when:
- A new document type is added to the registry
- A VERIFY_REQUIRED item is resolved (update the open items table)
- A new industry scope is seeded
- A `confidence_rating` is updated after advisor verification
- A legal review conclusion changes `requires_legal_review` status

Does NOT require update for:
- Changes to client profile trigger mappings (those live in Supabase only)
- Individual client document instances
- Regulatory dependency mapping rows (separate table, separate reference doc)

---

*Compliance: PIPEDA/PIPA (Alberta) | Canada Central data residency.*  
*No client data, credentials, or personal information in this file.*
