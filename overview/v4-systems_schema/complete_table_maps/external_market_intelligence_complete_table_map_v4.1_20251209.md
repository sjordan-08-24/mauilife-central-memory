# External Market Intelligence System - Reference Guide

**Date:** 20251206  
**System:** External Market Intelligence System  
**Schemas:** external, ops, homeowner_acquisition  
**Tables:** 6 (6 external + cross-schema FKs to ops, homeowner_acquisition)  
**Primary Key:** UUIDv7 (time-ordered, globally unique)

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
external.properties
├─► external.property_managers (tmk) [CASCADE DELETE]
├─► external.property_sales (tmk) [CASCADE DELETE]
├─► external.property_reviews (tmk) [CASCADE DELETE]
├─► external.property_pricing (tmk) [CASCADE DELETE]
├─► external.competitive_sets (external_tmk) [CASCADE DELETE]
└─► homeowner_acquisition.prospect_properties (external_tmk) [SET NULL]

ops.properties
├─► external.properties (ops_property_id) [SET NULL]
└─► external.competitive_sets (ops_property_id) [CASCADE DELETE]

external.competitive_sets
├─► ops.properties (ops_property_id) [CASCADE DELETE]
└─► external.properties (external_tmk) [CASCADE DELETE]

homeowner_acquisition.prospect_properties
└─► external.properties (external_tmk) [SET NULL]
```

**LEGEND:**
- [CASCADE DELETE] - Child records deleted when parent deleted
- [SET NULL] - FK set to NULL when parent deleted
- TMK (Tax Map Key) - Stable unique identifier from county records

---

# BUSINESS ID CROSS-REFERENCE

## External Schema Business IDs

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| external.properties | {TMK} | 2-4-006-001-0023 | N/A (county-sourced) | County Records API, Airbnb Scraper, VRBO Scraper, Sales Outreach AI |
| external.property_managers | EXT-MGR-NNNNNN | EXT-MGR-010001 | 10001 | Manager Change AI Agent, Outreach Automation |
| external.property_sales | EXT-SALE-NNNNNN | EXT-SALE-010042 | 10001 | County Records API, Hot Lead Detection AI |
| external.property_reviews | EXT-REV-NNNNNN | EXT-REV-010523 | 10001 | Airbnb Scraper, VRBO Scraper, Sentiment Analysis AI |
| external.property_pricing | EXT-PRC-NNNNNN | EXT-PRC-010099 | 10001 | Airbnb Scraper, VRBO Scraper, Competitive Pricing Dashboard |
| external.competitive_sets | COMP-{ops_property_id_suffix}-{tmk_suffix} | COMP-PRP0042-TMK0023 | N/A | Revenue Management AI, Pricing Dashboard |

## Cross-Schema Business ID Dependencies

| External System | References These Business IDs |
|----------------|-------------------------------|
| County Records API | TMK, EXT-SALE-* |
| Airbnb Scraper | TMK, EXT-REV-*, EXT-PRC-*, airbnb_listing_id |
| VRBO Scraper | TMK, EXT-REV-*, EXT-PRC-*, vrbo_listing_id |
| Sales Outreach AI Agent | TMK, EXT-MGR-*, EXT-SALE-*, prospect_id |
| Hot Lead Detection AI | TMK, EXT-SALE-*, EXT-MGR-*, is_hot_lead |
| Sentiment Analysis AI | TMK, EXT-REV-*, pain_points[], opportunity_score |
| Manager Change AI Agent | TMK, EXT-MGR-*, ended_at |
| Revenue Management AI | TMK, COMP-*, ops.property_id, EXT-PRC-* |
| Competitive Pricing Dashboard | TMK, COMP-*, EXT-PRC-*, ops.property_id |
| Owner Portal | TMK (competitor view only) |

---

# INDEX COVERAGE SUMMARY

## External Schema Indexes

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| external.properties | idx_ext_prop_tmk | tmk (UNIQUE) | Primary lookup by Tax Map Key |
| | idx_ext_prop_rental_status | rental_status | Filter by rental activity |
| | idx_ext_prop_our_status | our_status | Filter by relationship status |
| | idx_ext_prop_hot_lead | is_hot_lead WHERE is_hot_lead = TRUE | Hot lead queue processing |
| | idx_ext_prop_prospect | is_prospect WHERE is_prospect = TRUE | Prospect filtering |
| | idx_ext_prop_competitor | is_competitor WHERE is_competitor = TRUE | Competitor analysis |
| | idx_ext_prop_manager | current_manager_name | Manager lookup |
| | idx_ext_prop_resort | resort_name | Resort-level analysis |
| external.property_managers | idx_ext_mgr_tmk | tmk | Property lookup |
| | idx_ext_mgr_current | tmk, ended_at WHERE ended_at IS NULL | Current manager lookup |
| | idx_ext_mgr_ended | ended_at WHERE ended_at IS NOT NULL | Manager change detection |
| external.property_sales | idx_ext_sale_tmk | tmk | Property lookup |
| | idx_ext_sale_date | sale_date DESC | Chronological queries |
| | idx_ext_sale_recent | sale_date WHERE sale_date > NOW() - INTERVAL '12 months' | Recent sales (hot leads) |
| external.property_reviews | idx_ext_rev_tmk | tmk | Property lookup |
| | idx_ext_rev_date | review_date DESC | Chronological queries |
| | idx_ext_rev_negative | sentiment WHERE sentiment = 'negative' | Pain point analysis |
| | idx_ext_rev_opportunity | opportunity_score WHERE opportunity_score >= 70 | High opportunity filtering |
| external.property_pricing | idx_ext_prc_tmk | tmk | Property lookup |
| | idx_ext_prc_captured | captured_at DESC | Latest pricing snapshots |
| | idx_ext_prc_dates | check_in_date, check_out_date | Date range queries |
| external.competitive_sets | idx_comp_ops_property | ops_property_id | Our property lookup |
| | idx_comp_external_tmk | external_tmk | Competitor lookup |
| | idx_comp_primary | ops_property_id, competition_level WHERE competition_level = 'primary' | Primary competitor filtering |
| | idx_comp_unique | ops_property_id, external_tmk (UNIQUE) | One link per property pair |

---

# TABLE SPECIFICATIONS

## external.properties

**PURPOSE:** Master registry of ALL properties in the market (managed or not), keyed by TMK (Tax Map Key). Tracks prospects, competitors, rental pools, and converted properties. Links to ops.properties when property is acquired.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| tmk | text | NOT NULL, UNIQUE | Tax Map Key - stable unique identifier from county records (e.g., 2-4-006-001-0023) | N/A |
| ops_property_id | uuid | FK → ops.properties(id) | Link to ops.properties when property is acquired/managed by us | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## external.property_managers

**PURPOSE:** Tracks property management changes over time. When ended_at is set, it indicates the owner fired the PM, triggering HOT LEAD status for AI outreach agents.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| manager_id | text | NOT NULL, UNIQUE | Business ID: EXT-MGR-NNNNNN (auto-generated from external.manager_seq starting at 10001) | N/A |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property this manager record belongs to (delete manager records when property deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

---

## external.property_sales

**PURPOSE:** Tracks sale events from county records. New sale within 12 months triggers HOT LEAD status (new owner likely needs property management).

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| sale_id | text | NOT NULL, UNIQUE | Business ID: EXT-SALE-NNNNNN (auto-generated from external.sale_seq starting at 10001) | N/A |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property this sale belongs to (delete sale records when property deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

---

## external.property_reviews

**PURPOSE:** Scraped reviews from Airbnb/VRBO. AI classifies sentiment, extracts pain_points array, and calculates opportunity_score (1-100). Low ratings with specific complaints become sales talking points.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| review_id | text | NOT NULL, UNIQUE | Business ID: EXT-REV-NNNNNN (auto-generated from external.review_seq starting at 10001) | N/A |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property this review belongs to (delete reviews when property deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

---

## external.property_pricing

**PURPOSE:** Pricing snapshots over time for market intelligence. Captures competitor rates, availability, and fees for dynamic pricing recommendations and trend analysis.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| pricing_id | text | NOT NULL, UNIQUE | Business ID: EXT-PRC-NNNNNN (auto-generated from external.pricing_seq starting at 10001) | N/A |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property this pricing snapshot belongs to (delete pricing when property deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

---

## external.competitive_sets

**PURPOSE:** Junction table linking YOUR managed properties (ops.properties) to competitor properties (external.properties). Enables market position analysis with similarity scoring and competition level classification.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| ops_property_id | uuid | FK → ops.properties(id), NOT NULL | Your managed property (delete comp sets when property deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| external_tmk | text | FK → external.properties(tmk), NOT NULL | Competitor property (delete comp sets when external property deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

**UNIQUE CONSTRAINT:** (ops_property_id, external_tmk) - One competitive set link per property pair

---

**Document Version:** 1.0  
**Last Updated:** December 6, 2025  
**UUIDv7 Migration:** V2025.12.06__external_schema.sql  
**Total Tables:** 6 (6 external schema tables with cross-schema FKs to ops and homeowner_acquisition)
