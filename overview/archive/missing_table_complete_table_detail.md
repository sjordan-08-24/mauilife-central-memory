# Missing Tables - Cross-Reference Analysis

**Date:** 20251209 (Updated)
**Purpose:** Tables identified in Reference Guides but NOT fully specified in Complete Table Inventory documents
**Status:** Most gaps resolved - remaining items noted below

---

# ANALYSIS SUMMARY

This document identifies tables that appear in the Reference Guide documents (folder 1) but are not fully specified with complete column details in the Complete Table Inventory documents (folder 2).

## Cross-Reference Methodology

**Source 1 (Reference Guides):** 17 documents in `1 System_Schema_Reference_Guides/`
- High-level table structure, FK relationships, indexes
- ~239 tables mentioned across all schemas

**Source 2 (Table Inventories):** 16 documents in `2 Complete Table Inventory/`
- Detailed column specifications with types, constraints
- Complete field-level documentation

---

# RESOLVED GAPS (Previously Missing, Now Complete)

## Concierge Schema - RESOLVED
**Inventory Document:** `CONCIERGE_Schema_Table_Inventory_20251209.md`
- 24 tables now fully specified
- Includes venue tables (8), service tables (3), guest profile tables (4), survey tables (1), itinerary tables (6), booking tables (2)

## Portal Schema - RESOLVED
**Inventory Document:** `Portal_System_portal_Complete_Table_Inventory_20251206.md`
- 6 tables now fully specified with complete column details
- portal.users, portal.sessions, portal.roles, portal.permissions, portal.user_roles, portal.preferences
- Includes business logic documentation and sample queries

## Service/Team/Storage Schemas - RESOLVED
**Inventory Document:** `Service_System_Final_Specification_v4_20251208.md`
- 30 service tables, 6 team tables, 4 storage tables
- New unified architecture replacing ops.* ticket tables

---

# TABLES STILL REQUIRING SPECIFICATION

## 1. External Schema - RESOLVED

**Inventory Document:** `External_Homeowner_Acquisition_external_homeowner_acquisition_Complete_Table_Inventory_20251209.md`

The External schema (6 tables) is now fully documented along with a NEW `homeowner_acquisition` schema (11 tables):

### External Schema (6 tables)
| Table | Status | Purpose |
|-------|--------|---------|
| external.properties | **Complete** | TMK-keyed market property registry |
| external.property_managers | **Complete** | PM history (manager change = hot lead) |
| external.property_sales | **Complete** | County sale records (sale = hot lead) |
| external.property_reviews | **Complete** | Scraped reviews with sentiment/opportunity scoring |
| external.property_pricing | **Complete** | Competitor pricing snapshots |
| external.competitive_sets | **Complete** | Our properties vs competitors |

### Homeowner Acquisition Schema (11 tables) - NEW
| Table | Status | Purpose |
|-------|--------|---------|
| homeowner_acquisition.prospects | **Complete** | Lead/prospect persons/entities |
| homeowner_acquisition.prospect_properties | **Complete** | Properties in acquisition pipeline |
| homeowner_acquisition.lead_sources | **Complete** | Lead source reference (REFERRAL, COUNTY_SALE) |
| homeowner_acquisition.lead_activities | **Complete** | Call/email/meeting activity log |
| homeowner_acquisition.proposals | **Complete** | Management proposals sent |
| homeowner_acquisition.proposal_versions | **Complete** | Proposal version history |
| homeowner_acquisition.contracts | **Complete** | Signed management contracts |
| homeowner_acquisition.onboarding_tasks | **Complete** | Onboarding task templates |
| homeowner_acquisition.onboarding_progress | **Complete** | Task completion tracking |
| homeowner_acquisition.property_assessments | **Complete** | Property condition assessments |
| homeowner_acquisition.revenue_projections | **Complete** | Revenue forecasts for prospects |

---

## 2. Guest Journey System (`ops`, `ref`) - Partial

Some Guest Journey tables need full column specifications:

| Table | Status | Notes |
|-------|--------|-------|
| ref.journey_stages | Needs full columns | Journey stage reference |
| ref.touchpoint_types | Needs full columns | Touchpoint type reference |
| ref.stage_required_touchpoints | Needs full columns | Stage-touchpoint requirements |
| ops.guest_journeys | Needs full columns | Guest journey tracking |
| ops.guest_journey_touchpoints | Needs full columns | Journey touchpoint events |
| ops.reviews | Needs full columns | Guest reviews |

**Note:** These may be included in Service System v4 specification - needs verification.

---

# SCHEMA ARCHITECTURE CLARIFICATIONS

## Important: ops Schema Restructuring

Per user clarification: **ops is NOT a schema in the final structure**. The tables previously documented under `ops.*` are distributed across:

| New Schema | Purpose | Migrated Tables |
|------------|---------|-----------------|
| property | Property assets, rooms, amenities | ops.properties, ops.rooms, ops.beds, etc. |
| directory | Contacts, companies | ops.contacts → directory.contacts |
| reservation | Reservations, guests | ops.reservations, ops.guests |
| service | Tickets, claims, projects | ops.property_care_tickets → service.tickets |
| team | Team members, shifts, time | ops.team_directory → team.team_directory |
| storage | Files, attachments | New centralized file storage |

## New Ref Tables from Concierge

The Concierge inventory revealed additional ref tables needed:

| ref Table | Purpose |
|-----------|---------|
| ref.activity_levels | Activity intensity levels for guest profiles |
| ref.budget_levels | Budget preferences for guests |
| ref.schedule_density_levels | Pace preferences (relaxed → packed) |
| ref.driving_tolerance_levels | Willingness to drive distances |
| ref.interest_types | Interest categories (beaches, hiking, dining) |
| ref.interest_categories | Higher-level interest groupings |
| ref.limitation_types | Guest limitations (mobility, dietary, allergies) |

---

# DUPLICATE/CONFLICTING SPECIFICATIONS - RESOLVED

## Ticket System Architecture - RESOLVED
**Canonical Version:** `service.tickets` (Service System v4)
- Unified ticket table with ticket_type_code (PC, RSV, ADM, ACCT)
- ops.* ticket tables are deprecated/migrated

## Time Entry Architecture - RESOLVED
**Canonical Version:** `team.time_entries` (Service System v4)
- Centralized time tracking with verification workflow
- ops.timesheets → team.time_entries

## Damage Claims Architecture - RESOLVED
**Canonical Version:** `service.damage_claims` (Service System v4)
- Full lifecycle: submissions, approvals, denials, appeals
- ops.damage_claims → service.damage_claims

---

# REMAINING ACTIONS

## Priority 1: Create Missing Inventory
1. `External_Market_Intelligence_external_Complete_Table_Inventory.md` - 6 tables

## Priority 2: Verify Guest Journey Tables
1. Confirm if guest journey tables are in Service System v4
2. If not, create `Guest_Journey_System_Complete_Table_Inventory.md`

## Priority 3: Update Reference Guides
1. Update ops → new schema mappings in Reference Guides
2. Mark deprecated tables in all_schema_table_detail.md
3. Add new ref tables from Concierge system

---

# FINAL TABLE COUNT BY SCHEMA

| Schema | Tables | Inventory Status |
|--------|--------|------------------|
| ai | 18 | Complete |
| brand | 5 | Complete |
| comms | 12 | Complete |
| concierge | 24 | **Complete** (new) |
| directory | 2 | Complete |
| external | 6 | **Missing** |
| finance | 12 | Complete |
| geo | 5 | Complete |
| knowledge | 15+ | Complete |
| marketing | 22 | Complete |
| portal | 6 | **Complete** (new) |
| pricing | 12 | Complete |
| property | ~25 | Complete (via Property Asset Tables) |
| property_listings | 13 | Complete |
| ref | 40+ | Complete |
| reservation | ~10 | Needs consolidation |
| secure | 2 | Complete |
| service | 30 | **Complete** (new) |
| storage | 4 | **Complete** (new) |
| team | 6 | **Complete** (new) |

**Total Estimated Tables:** ~295+

---

**Document Version:** 2.0
**Created:** 20251209
**Last Updated:** 20251209
**Analysis Based On:** 17 Reference Guide files + 16 Complete Table Inventory files
