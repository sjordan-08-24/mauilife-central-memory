# External Market Intelligence & Homeowner Acquisition - Complete Table Inventory

**Date:** 20251209  
**System:** External Market Intelligence & Homeowner Acquisition Pipeline  
**Schemas:** external, homeowner_acquisition  
**Tables:** 17 (6 external + 11 homeowner_acquisition)  
**Primary Key:** UUIDv7 (time-ordered, globally unique)

---

# TABLE OF CONTENTS

1. [Foreign Key Relationship Matrix](#foreign-key-relationship-matrix)
2. [Business ID Cross-Reference](#business-id-cross-reference)
3. [Index Coverage Summary](#index-coverage-summary)
4. [External Schema Tables](#external-schema-tables)
   - 4.1 [external.properties](#externalproperties)
   - 4.2 [external.property_managers](#externalproperty_managers)
   - 4.3 [external.property_sales](#externalproperty_sales)
   - 4.4 [external.property_reviews](#externalproperty_reviews)
   - 4.5 [external.property_pricing](#externalproperty_pricing)
   - 4.6 [external.competitive_sets](#externalcompetitive_sets)
5. [Homeowner Acquisition Schema Tables](#homeowner-acquisition-schema-tables)
   - 5.1 [homeowner_acquisition.prospects](#homeowner_acquisitionprospects)
   - 5.2 [homeowner_acquisition.prospect_properties](#homeowner_acquisitionprospect_properties)
   - 5.3 [homeowner_acquisition.lead_sources](#homeowner_acquisitionlead_sources)
   - 5.4 [homeowner_acquisition.lead_activities](#homeowner_acquisitionlead_activities)
   - 5.5 [homeowner_acquisition.proposals](#homeowner_acquisitionproposals)
   - 5.6 [homeowner_acquisition.proposal_versions](#homeowner_acquisitionproposal_versions)
   - 5.7 [homeowner_acquisition.contracts](#homeowner_acquisitioncontracts)
   - 5.8 [homeowner_acquisition.onboarding_tasks](#homeowner_acquisitiononboarding_tasks)
   - 5.9 [homeowner_acquisition.onboarding_progress](#homeowner_acquisitiononboarding_progress)
   - 5.10 [homeowner_acquisition.property_assessments](#homeowner_acquisitionproperty_assessments)
   - 5.11 [homeowner_acquisition.revenue_projections](#homeowner_acquisitionrevenue_projections)
6. [Business Logic](#business-logic)
7. [Common Usage Patterns](#common-usage-patterns)
8. [Sample Queries](#sample-queries)
9. [Migration Information](#migration-information)

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
external.properties (TMK-keyed Master Registry)
├─► external.property_managers (tmk) [CASCADE DELETE]
├─► external.property_sales (tmk) [CASCADE DELETE]
├─► external.property_reviews (tmk) [CASCADE DELETE]
├─► external.property_pricing (tmk) [CASCADE DELETE]
├─► external.competitive_sets (external_tmk) [CASCADE DELETE]
└─► homeowner_acquisition.prospect_properties (external_tmk) [SET NULL]

ops.properties (Managed Properties)
├─► external.properties (ops_property_id) [SET NULL]
└─► external.competitive_sets (ops_property_id) [CASCADE DELETE]

directory.contacts (Contact Hub)
└─► homeowner_acquisition.prospects (contact_id) [RESTRICT DELETE]

homeowner_acquisition.prospects (Prospect Person/Entity)
├─► homeowner_acquisition.prospect_properties (prospect_id) [CASCADE DELETE]
├─► homeowner_acquisition.lead_activities (prospect_id) [CASCADE DELETE]
├─► homeowner_acquisition.proposals (prospect_id) [CASCADE DELETE]
├─► homeowner_acquisition.contracts (prospect_id) [CASCADE DELETE]
└─► homeowner_acquisition.onboarding_progress (prospect_id) [CASCADE DELETE]

homeowner_acquisition.prospect_properties (Properties in Pipeline)
├─► homeowner_acquisition.property_assessments (prospect_property_id) [CASCADE DELETE]
└─► homeowner_acquisition.revenue_projections (prospect_property_id) [CASCADE DELETE]

homeowner_acquisition.proposals (Deal Proposals)
└─► homeowner_acquisition.proposal_versions (proposal_id) [CASCADE DELETE]

homeowner_acquisition.onboarding_tasks (Task Templates)
└─► homeowner_acquisition.onboarding_progress (task_id) [RESTRICT DELETE]

homeowner_acquisition.lead_sources
└─► [NO FOREIGN KEYS - REFERENCE TABLE]
```

**LEGEND:**
- [CASCADE DELETE] - Child records deleted when parent deleted
- [RESTRICT DELETE] - Cannot delete parent if children exist
- [SET NULL] - FK set to NULL when parent deleted
- TMK = Tax Map Key (county property identifier)

---

# BUSINESS ID CROSS-REFERENCE

## External Schema Business IDs

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| external.properties | {TMK} | 2-4-006-001-0023 | N/A (county) | County Records API, Airbnb Scraper, VRBO Scraper, Sales Outreach AI |
| external.property_managers | EXT-MGR-NNNNNN | EXT-MGR-010001 | 10001 | Manager Change AI Agent, Outreach Automation |
| external.property_sales | EXT-SALE-NNNNNN | EXT-SALE-010042 | 10001 | County Records API, Hot Lead Detection AI |
| external.property_reviews | EXT-REV-NNNNNN | EXT-REV-010523 | 10001 | Airbnb Scraper, VRBO Scraper, Sentiment Analysis AI |
| external.property_pricing | EXT-PRC-NNNNNN | EXT-PRC-010099 | 10001 | Airbnb Scraper, VRBO Scraper, Competitive Pricing Dashboard |
| external.competitive_sets | N/A (junction table) | N/A | N/A | Revenue Management AI, Pricing Dashboard |

## Homeowner Acquisition Schema Business IDs

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| homeowner_acquisition.prospects | HOP-NNNNNN | HOP-010042 | 10001 | CRM, Sales Dashboard, Outreach AI |
| homeowner_acquisition.prospect_properties | HOPP-NNNNNN | HOPP-010015 | 10001 | Property Assessment App, Revenue Projection AI |
| homeowner_acquisition.lead_sources | {SOURCE_CODE} | REFERRAL | N/A | Marketing Analytics |
| homeowner_acquisition.lead_activities | HOPA-NNNNNN | HOPA-010523 | 10001 | Activity Log Dashboard |
| homeowner_acquisition.proposals | PROP-NNNNNN | PROP-010008 | 10001 | Proposal Builder, DocuSign Integration |
| homeowner_acquisition.proposal_versions | N/A (version number) | v3 | 1 | Document Management |
| homeowner_acquisition.contracts | CONT-NNNNNN | CONT-010003 | 10001 | DocuSign, Legal System |
| homeowner_acquisition.onboarding_tasks | TASK-NNN | TASK-001 | 001 | Onboarding Checklist App |
| homeowner_acquisition.onboarding_progress | N/A (junction) | N/A | N/A | Onboarding Dashboard |
| homeowner_acquisition.property_assessments | ASMT-NNNNNN | ASMT-010012 | 10001 | Property Assessment App |
| homeowner_acquisition.revenue_projections | PROJ-NNNNNN | PROJ-010012 | 10001 | Revenue Projection AI |

## Cross-System Business ID Dependencies

| External System | References These Business IDs |
|----------------|-------------------------------|
| County Records API | TMK |
| Airbnb Scraper | TMK, airbnb_listing_id |
| VRBO Scraper | TMK, vrbo_listing_id |
| Sales Outreach AI | TMK, HOP-*, EXT-MGR-*, EXT-SALE-* |
| Hot Lead Detection AI | TMK, EXT-SALE-*, EXT-MGR-*, is_hot_lead |
| Sentiment Analysis AI | TMK, EXT-REV-*, pain_points[], opportunity_score |
| Manager Change AI | TMK, EXT-MGR-*, ended_at |
| Revenue Management AI | TMK, COMP-*, ops.property_id |
| CRM Dashboard | HOP-*, HOPP-*, PROP-*, CONT-* |
| Onboarding App | HOP-*, TASK-*, onboarding_progress |

---

# INDEX COVERAGE SUMMARY

## External Schema Indexes

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| external.properties | idx_ext_prop_tmk | tmk (UNIQUE) | Primary lookup by Tax Map Key |
| | idx_ext_prop_rental_status | rental_status | Filter by rental activity |
| | idx_ext_prop_ownership_status | ownership_status | Filter by ownership changes |
| | idx_ext_prop_our_status | our_status | Filter by relationship status |
| | idx_ext_prop_hot_lead | is_hot_lead WHERE is_hot_lead = TRUE | Hot lead queue processing |
| | idx_ext_prop_prospect | is_prospect WHERE is_prospect = TRUE | Prospect filtering |
| | idx_ext_prop_competitor | is_competitor WHERE is_competitor = TRUE | Competitor analysis |
| | idx_ext_prop_managed | is_managed_by_us WHERE is_managed_by_us = TRUE | Our properties cross-ref |
| | idx_ext_prop_manager | current_manager_name | Manager lookup |
| | idx_ext_prop_resort | resort_name | Resort-level analysis |
| | idx_ext_prop_area | area_id | Geographic filtering |
| external.property_managers | idx_ext_mgr_tmk | tmk | Property lookup |
| | idx_ext_mgr_current | tmk, ended_at WHERE ended_at IS NULL | Current manager lookup |
| | idx_ext_mgr_ended | ended_at WHERE ended_at IS NOT NULL | Manager change detection (HOT LEAD) |
| external.property_sales | idx_ext_sale_tmk | tmk | Property lookup |
| | idx_ext_sale_date | sale_date DESC | Chronological queries |
| | idx_ext_sale_recent | sale_date WHERE sale_date > NOW() - INTERVAL '12 months' | Recent sales (HOT LEAD) |
| external.property_reviews | idx_ext_rev_tmk | tmk | Property lookup |
| | idx_ext_rev_date | review_date DESC | Chronological queries |
| | idx_ext_rev_platform | platform, tmk | Platform-specific queries |
| | idx_ext_rev_negative | sentiment WHERE sentiment = 'negative' | Pain point analysis |
| | idx_ext_rev_opportunity | opportunity_score WHERE opportunity_score >= 70 | High opportunity filtering |
| | idx_ext_rev_pain_points | pain_points (GIN) | Array search on pain points |
| external.property_pricing | idx_ext_prc_tmk | tmk | Property lookup |
| | idx_ext_prc_captured | captured_at DESC | Latest pricing snapshots |
| | idx_ext_prc_dates | check_in_date, check_out_date | Date range queries |
| | idx_ext_prc_platform | platform, tmk | Platform-specific pricing |
| external.competitive_sets | idx_comp_ops_property | ops_property_id | Our property lookup |
| | idx_comp_external_tmk | external_tmk | Competitor lookup |
| | idx_comp_primary | ops_property_id, competition_level WHERE competition_level = 'primary' | Primary competitors |
| | idx_comp_unique | ops_property_id, external_tmk (UNIQUE) | One link per property pair |

## Homeowner Acquisition Schema Indexes

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| homeowner_acquisition.prospects | idx_prospect_contact | contact_id | Contact lookup |
| | idx_prospect_status | status | Pipeline filtering |
| | idx_prospect_source | source_id | Source analysis |
| | idx_prospect_assigned | assigned_to_member_id | Team workload |
| homeowner_acquisition.prospect_properties | idx_prosp_prop_prospect | prospect_id | Prospect's properties |
| | idx_prosp_prop_tmk | external_tmk | Property lookup |
| | idx_prosp_prop_status | status | Pipeline stage filtering |
| homeowner_acquisition.lead_activities | idx_lead_act_prospect | prospect_id | Activity history |
| | idx_lead_act_date | activity_date DESC | Chronological |
| | idx_lead_act_type | activity_type | Type filtering |
| homeowner_acquisition.proposals | idx_proposal_prospect | prospect_id | Prospect's proposals |
| | idx_proposal_status | status | Status filtering |
| homeowner_acquisition.contracts | idx_contract_prospect | prospect_id | Prospect's contracts |
| | idx_contract_status | status | Status filtering |
| homeowner_acquisition.onboarding_progress | idx_onboard_prospect | prospect_id | Prospect progress |
| | idx_onboard_task | task_id | Task tracking |
| | idx_onboard_incomplete | prospect_id, completed_at WHERE completed_at IS NULL | Incomplete tasks |

---

# EXTERNAL SCHEMA TABLES

## external.properties

**PURPOSE:** Master registry of ALL properties in the market (managed by us or not), uniquely keyed by TMK (Tax Map Key) from county records. Tracks prospects, competitors, rental pools, and converted properties with three-dimensional status tracking (rental_status, ownership_status, our_status) and boolean flags for quick filtering. Links to ops.properties when a property is acquired.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) |
| tmk | text | NOT NULL, UNIQUE | Tax Map Key - stable unique identifier from county records (e.g., 2-4-006-001-0023) |
| ops_property_id | uuid | FK → ops.properties(id) | Link to ops.properties when managed by us (NULL if not managed) |
| area_id | uuid | FK → geo.areas(id) | Geographic area for location-based queries |
| property_name | text | | Common name or unit designation |
| street_address | text | | Street address |
| city | text | | City |
| state | text | | State (HI, TN, UT) |
| zip | text | | ZIP code |
| county | text | | County name |
| latitude | numeric(10,7) | | GPS latitude |
| longitude | numeric(10,7) | | GPS longitude |
| resort_name | text | | Resort/complex name if applicable |
| building | text | | Building name or number |
| unit_number | text | | Unit number |
| bedrooms | integer | | Number of bedrooms |
| bathrooms | numeric(3,1) | | Number of bathrooms (allows 2.5) |
| square_feet | integer | | Interior square footage |
| property_type | text | | condo, house, townhouse, villa |
| view_type | text | | ocean_front, ocean_view, garden, mountain, partial_ocean |
| rental_status | text | NOT NULL, DEFAULT 'unknown' | How property is rented: active_str, rental_pool, long_term, owner_occupied, vacant, unknown |
| ownership_status | text | NOT NULL, DEFAULT 'stable' | Ownership changes: stable, recently_sold, for_sale, pending_sale |
| our_status | text | NOT NULL, DEFAULT 'watching' | Our relationship: watching, target, in_pursuit, proposal_sent, converted, declined, lost, not_pursuing |
| is_managed_by_us | boolean | NOT NULL, DEFAULT false | TRUE if property in our management portfolio |
| is_prospect | boolean | NOT NULL, DEFAULT false | TRUE if actively being pursued |
| is_competitor | boolean | NOT NULL, DEFAULT false | TRUE if identified as competitor property |
| is_hot_lead | boolean | NOT NULL, DEFAULT false | TRUE if recent sale OR manager change (auto-calculated) |
| rental_pool_name | text | | If rental_status='rental_pool': Outrigger, Aston, etc. |
| rental_pool_url | text | | URL to rental pool listing |
| airbnb_listing_id | text | | Airbnb listing ID if listed |
| airbnb_url | text | | Airbnb listing URL |
| airbnb_rating | numeric(2,1) | | Airbnb average rating (0.0-5.0) |
| airbnb_review_count | integer | | Number of Airbnb reviews |
| vrbo_listing_id | text | | VRBO listing ID if listed |
| vrbo_url | text | | VRBO listing URL |
| vrbo_rating | numeric(2,1) | | VRBO average rating (0.0-5.0) |
| vrbo_review_count | integer | | Number of VRBO reviews |
| owner_name | text | | Current owner name from county records |
| owner_mailing_address | text | | Owner mailing address (for direct mail) |
| owner_mailing_city | text | | Owner mailing city |
| owner_mailing_state | text | | Owner mailing state |
| owner_mailing_zip | text | | Owner mailing ZIP |
| last_sale_date | date | | Date of most recent sale |
| last_sale_price | numeric(12,2) | | Most recent sale price |
| assessed_value | numeric(12,2) | | Current county assessed value |
| current_manager_name | text | | Current property manager if known |
| estimated_annual_revenue | numeric(12,2) | | Estimated gross annual revenue |
| estimated_adr | numeric(8,2) | | Estimated average daily rate |
| estimated_occupancy | numeric(5,4) | | Estimated occupancy rate (0.7500 = 75%) |
| notes | text | | Internal notes |
| data_sources | text[] | | Array of data sources: county, airbnb, vrbo, manual |
| first_seen_at | timestamptz | DEFAULT now() | When property was first added |
| last_enriched_at | timestamptz | | When property data was last enriched |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- rental_status IN ('active_str', 'rental_pool', 'long_term', 'owner_occupied', 'vacant', 'unknown')
- ownership_status IN ('stable', 'recently_sold', 'for_sale', 'pending_sale')
- our_status IN ('watching', 'target', 'in_pursuit', 'proposal_sent', 'converted', 'declined', 'lost', 'not_pursuing')

**FK CASCADE ACTIONS:**
- ops_property_id: ON DELETE SET NULL (keep external record if ops property deleted)
- area_id: ON DELETE SET NULL (keep record if area deleted)

**SAMPLE DATA:**
```sql
-- Active STR competitor at Kapalua Bay Villas
INSERT INTO external.properties (
    tmk, property_name, street_address, city, state, zip, county,
    latitude, longitude, resort_name, building, unit_number,
    bedrooms, bathrooms, square_feet, property_type, view_type,
    rental_status, ownership_status, our_status,
    is_managed_by_us, is_prospect, is_competitor, is_hot_lead,
    airbnb_listing_id, airbnb_url, airbnb_rating, airbnb_review_count,
    owner_name, last_sale_date, last_sale_price, assessed_value,
    current_manager_name, estimated_annual_revenue, estimated_adr, estimated_occupancy,
    data_sources
) VALUES (
    '2-4-006-001-0023',
    'Kapalua Bay Villa 15B3',
    '500 Bay Drive',
    'Lahaina', 'HI', '96761', 'Maui',
    20.9987, -156.6619,
    'Kapalua Bay Villas', '15B', '3',
    2, 2.0, 1250, 'condo', 'ocean_view',
    'active_str', 'stable', 'watching',
    false, false, true, false,
    '12345678', 'https://airbnb.com/rooms/12345678', 4.8, 127,
    'Smith Family Trust', '2021-03-15', 1850000.00, 1650000.00,
    'Sullivan Properties', 185000.00, 450.00, 0.7200,
    ARRAY['county', 'airbnb']
);
-- This is a competitor property we're watching at Kapalua Bay Villas

-- Recently sold property - HOT LEAD
INSERT INTO external.properties (
    tmk, property_name, street_address, city, state, zip, county,
    bedrooms, bathrooms, property_type, view_type,
    rental_status, ownership_status, our_status,
    is_managed_by_us, is_prospect, is_competitor, is_hot_lead,
    owner_name, last_sale_date, last_sale_price, assessed_value,
    data_sources
) VALUES (
    '2-4-006-002-0045',
    'Kapalua Ridge Villa 2304',
    '100 Ridge Road',
    'Lahaina', 'HI', '96761', 'Maui',
    3, 2.5, 'condo', 'ocean_view',
    'unknown', 'recently_sold', 'target',
    false, true, false, true,
    'Johnson Investment LLC', '2025-11-20', 2100000.00, 1900000.00,
    ARRAY['county']
);
-- New owner likely needs property manager - flagged as hot lead for immediate outreach

-- Rental pool property (Outrigger managed)
INSERT INTO external.properties (
    tmk, property_name, street_address, city, state, zip, county,
    resort_name, bedrooms, bathrooms, property_type, view_type,
    rental_status, ownership_status, our_status,
    is_managed_by_us, is_prospect, is_competitor, is_hot_lead,
    rental_pool_name, rental_pool_url,
    owner_name, assessed_value,
    data_sources
) VALUES (
    '2-4-008-015-0102',
    'Honua Kai Hokulani 842',
    '130 Kai Malina Parkway',
    'Lahaina', 'HI', '96761', 'Maui',
    'Honua Kai Resort', 2, 2.0, 'condo', 'partial_ocean',
    'rental_pool', 'stable', 'not_pursuing',
    false, false, false, false,
    'Outrigger', 'https://www.outrigger.com/honua-kai',
    'Pacific Holdings LLC', 1450000.00,
    ARRAY['county', 'manual']
);
-- In Outrigger rental pool, not pursuing (locked into pool contract)
```

---

## external.property_managers

**PURPOSE:** Tracks property management history over time for each external property. When ended_at is populated, it indicates the owner terminated the management relationship - a key HOT LEAD trigger since they're now seeking new management.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| manager_id | text | NOT NULL, UNIQUE | Business ID: EXT-MGR-NNNNNN |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property this manager record belongs to |
| manager_name | text | NOT NULL | Property management company name |
| started_at | date | | When management began (if known) |
| ended_at | date | | When management ended (NULL = current manager) |
| source | text | | How we learned this: scrape, county, manual, referral |
| notes | text | | Additional context |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**FK CASCADE ACTIONS:**
- tmk: ON DELETE CASCADE (delete manager records when property deleted)

**SAMPLE DATA:**
```sql
-- Current manager for a property
INSERT INTO external.property_managers (
    manager_id, tmk, manager_name, started_at, source
) VALUES (
    'EXT-MGR-010001',
    '2-4-006-001-0023',
    'Sullivan Properties',
    '2022-06-01',
    'scrape'
);
-- Sullivan Properties currently manages this Kapalua Bay Villa

-- Manager that was fired - HOT LEAD trigger
INSERT INTO external.property_managers (
    manager_id, tmk, manager_name, started_at, ended_at, source, notes
) VALUES (
    'EXT-MGR-010002',
    '2-4-006-003-0089',
    'Island Getaways LLC',
    '2020-01-15',
    '2025-11-30',
    'manual',
    'Owner unhappy with communication and maintenance response times'
);
-- Owner fired Island Getaways - immediately reach out with our pitch

-- Historical manager record
INSERT INTO external.property_managers (
    manager_id, tmk, manager_name, started_at, ended_at, source
) VALUES (
    'EXT-MGR-010003',
    '2-4-006-003-0089',
    'Maui Premier Rentals',
    '2017-03-01',
    '2019-12-31',
    'county'
);
-- Previous manager before Island Getaways
```

---

## external.property_sales

**PURPOSE:** Tracks sale transactions from county records. Properties sold within the last 12 months are flagged as HOT LEADS because new owners often need property management services. Captures buyer/seller info for outreach targeting.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| sale_id | text | NOT NULL, UNIQUE | Business ID: EXT-SALE-NNNNNN |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property that was sold |
| sale_date | date | NOT NULL | Date of sale closing |
| sale_price | numeric(12,2) | | Sale price in dollars |
| buyer_name | text | | Buyer name (new owner) |
| buyer_mailing_address | text | | Buyer mailing address |
| buyer_mailing_city | text | | Buyer mailing city |
| buyer_mailing_state | text | | Buyer mailing state |
| buyer_mailing_zip | text | | Buyer mailing ZIP |
| seller_name | text | | Seller name (previous owner) |
| document_number | text | | County document/deed number |
| source | text | | Data source: county_api, county_scrape, manual |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**FK CASCADE ACTIONS:**
- tmk: ON DELETE CASCADE (delete sale records when property deleted)

**SAMPLE DATA:**
```sql
-- Recent sale - triggers HOT LEAD status
INSERT INTO external.property_sales (
    sale_id, tmk, sale_date, sale_price,
    buyer_name, buyer_mailing_address, buyer_mailing_city, buyer_mailing_state, buyer_mailing_zip,
    seller_name, document_number, source
) VALUES (
    'EXT-SALE-010042',
    '2-4-006-002-0045',
    '2025-11-20',
    2100000.00,
    'Johnson Investment LLC',
    '456 Main Street Suite 200',
    'San Francisco', 'CA', '94102',
    'Roberts Family Trust',
    'DOC-2025-123456',
    'county_api'
);
-- New buyer from California - likely needs local property manager

-- Historical sale
INSERT INTO external.property_sales (
    sale_id, tmk, sale_date, sale_price,
    buyer_name, seller_name, document_number, source
) VALUES (
    'EXT-SALE-010043',
    '2-4-006-001-0023',
    '2021-03-15',
    1850000.00,
    'Smith Family Trust',
    'Original Developer LLC',
    'DOC-2021-789012',
    'county_scrape'
);
-- Historical record for market analysis
```

---

## external.property_reviews

**PURPOSE:** Scraped reviews from Airbnb and VRBO with AI-powered sentiment analysis. Extracts pain_points array and calculates opportunity_score (1-100) to identify properties with unhappy guests whose owners might be receptive to switching management companies.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| review_id | text | NOT NULL, UNIQUE | Business ID: EXT-REV-NNNNNN |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property this review belongs to |
| platform | text | NOT NULL | Source platform: airbnb, vrbo |
| external_review_id | text | | Platform's review ID |
| review_date | date | NOT NULL | Date review was posted |
| rating | integer | | Star rating (1-5) |
| review_text | text | | Full review text |
| reviewer_name | text | | Reviewer display name |
| host_response | text | | Host/manager response text |
| host_response_date | date | | When host responded |
| sentiment | text | | AI-classified: positive, neutral, negative |
| pain_points | text[] | | AI-extracted issues: cleanliness, communication, maintenance, amenities, etc. |
| opportunity_score | integer | | AI-calculated 1-100 (higher = better outreach opportunity) |
| processed_at | timestamptz | | When AI analysis was run |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- platform IN ('airbnb', 'vrbo')
- sentiment IN ('positive', 'neutral', 'negative')
- rating BETWEEN 1 AND 5
- opportunity_score BETWEEN 1 AND 100

**FK CASCADE ACTIONS:**
- tmk: ON DELETE CASCADE (delete reviews when property deleted)

**SAMPLE DATA:**
```sql
-- Negative review with high opportunity score - sales talking point
INSERT INTO external.property_reviews (
    review_id, tmk, platform, external_review_id,
    review_date, rating, review_text, reviewer_name,
    host_response, host_response_date,
    sentiment, pain_points, opportunity_score, processed_at
) VALUES (
    'EXT-REV-010523',
    '2-4-006-001-0023',
    'airbnb',
    'R123456789',
    '2025-10-15',
    2,
    'Beautiful condo but management was terrible. AC broke on day 2 and took 3 days to fix. Multiple calls went unanswered. Would not book again despite loving the location.',
    'Sarah M.',
    'We apologize for the inconvenience.',
    '2025-10-18',
    'negative',
    ARRAY['maintenance', 'communication', 'response_time'],
    87,
    '2025-10-16 08:00:00'
);
-- High opportunity: specific complaints about current manager we can address in pitch

-- Positive review - low opportunity
INSERT INTO external.property_reviews (
    review_id, tmk, platform, external_review_id,
    review_date, rating, review_text, reviewer_name,
    sentiment, pain_points, opportunity_score, processed_at
) VALUES (
    'EXT-REV-010524',
    '2-4-006-001-0023',
    'airbnb',
    'R123456790',
    '2025-09-20',
    5,
    'Perfect stay! Everything was spotless, communication was excellent, and the view was amazing. Will definitely return!',
    'Mike T.',
    'positive',
    ARRAY[]::text[],
    12,
    '2025-09-21 08:00:00'
);
-- Low opportunity: guest is happy with current management
```

---

## external.property_pricing

**PURPOSE:** Pricing snapshots captured over time for competitive market intelligence. Tracks nightly rates, fees, availability, and minimum stays across platforms. Used for dynamic pricing recommendations and identifying underperforming competitors.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| pricing_id | text | NOT NULL, UNIQUE | Business ID: EXT-PRC-NNNNNN |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property this pricing belongs to |
| captured_at | timestamptz | NOT NULL, DEFAULT now() | When this snapshot was captured |
| platform | text | NOT NULL | Source: airbnb, vrbo, direct |
| check_in_date | date | NOT NULL | Stay check-in date |
| check_out_date | date | NOT NULL | Stay check-out date |
| nightly_rate | numeric(8,2) | | Base nightly rate |
| cleaning_fee | numeric(8,2) | | Cleaning fee |
| service_fee | numeric(8,2) | | Platform service fee |
| total_price | numeric(10,2) | | Total price for stay |
| minimum_nights | integer | | Minimum night requirement |
| is_available | boolean | | Was the property available for these dates? |
| source_url | text | | URL where pricing was captured |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |

**CHECK CONSTRAINTS:**
- platform IN ('airbnb', 'vrbo', 'direct')
- check_out_date > check_in_date

**FK CASCADE ACTIONS:**
- tmk: ON DELETE CASCADE (delete pricing when property deleted)

**SAMPLE DATA:**
```sql
-- Competitor pricing snapshot for peak season
INSERT INTO external.property_pricing (
    pricing_id, tmk, captured_at, platform,
    check_in_date, check_out_date,
    nightly_rate, cleaning_fee, service_fee, total_price,
    minimum_nights, is_available, source_url
) VALUES (
    'EXT-PRC-010099',
    '2-4-006-001-0023',
    '2025-12-01 14:30:00',
    'airbnb',
    '2025-12-20',
    '2025-12-27',
    650.00,
    350.00,
    485.00,
    5385.00,
    7,
    true,
    'https://airbnb.com/rooms/12345678?check_in=2025-12-20&check_out=2025-12-27'
);
-- Christmas week pricing at competitor - they're at $650/night

-- Same property, different dates (shoulder season)
INSERT INTO external.property_pricing (
    pricing_id, tmk, captured_at, platform,
    check_in_date, check_out_date,
    nightly_rate, cleaning_fee, service_fee, total_price,
    minimum_nights, is_available, source_url
) VALUES (
    'EXT-PRC-010100',
    '2-4-006-001-0023',
    '2025-12-01 14:30:00',
    'airbnb',
    '2026-04-15',
    '2026-04-22',
    425.00,
    350.00,
    320.00,
    3645.00,
    5,
    true,
    'https://airbnb.com/rooms/12345678?check_in=2026-04-15&check_out=2026-04-22'
);
-- Spring shoulder season pricing - 35% lower than peak
```

---

## external.competitive_sets

**PURPOSE:** Junction table linking YOUR managed properties (ops.properties) to their competitor properties (external.properties). Enables market position analysis with similarity scoring and competition level classification (primary/secondary/tertiary).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| ops_property_id | uuid | FK → ops.properties(id), NOT NULL | Your managed property |
| external_tmk | text | FK → external.properties(tmk), NOT NULL | Competitor property |
| similarity_score | integer | | 1-100 how similar the properties are |
| same_resort | boolean | DEFAULT false | Are they in the same resort/complex? |
| same_area | boolean | DEFAULT false | Are they in the same geo area? |
| same_bedrooms | boolean | DEFAULT false | Same bedroom count? |
| same_view_type | boolean | DEFAULT false | Same view type? |
| competition_level | text | NOT NULL, DEFAULT 'secondary' | primary, secondary, tertiary |
| notes | text | | Why this is a competitor |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**UNIQUE CONSTRAINT:** (ops_property_id, external_tmk) - One competitive relationship per property pair

**CHECK CONSTRAINTS:**
- competition_level IN ('primary', 'secondary', 'tertiary')
- similarity_score BETWEEN 1 AND 100

**FK CASCADE ACTIONS:**
- ops_property_id: ON DELETE CASCADE (delete comp sets when our property deleted)
- external_tmk: ON DELETE CASCADE (delete comp sets when external property deleted)

**SAMPLE DATA:**
```sql
-- Primary competitor - same resort, same bedrooms, same view
INSERT INTO external.competitive_sets (
    ops_property_id, external_tmk,
    similarity_score, same_resort, same_area, same_bedrooms, same_view_type,
    competition_level, notes
) VALUES (
    (SELECT id FROM ops.properties WHERE property_id = 'PRP-MLVR-010045'),
    '2-4-006-001-0023',
    92,
    true,
    true,
    true,
    true,
    'primary',
    'Same building, 2BR ocean view, directly competes for same guests'
);
-- This is our most direct competitor for our Kapalua Bay Villa

-- Secondary competitor - same area, different resort
INSERT INTO external.competitive_sets (
    ops_property_id, external_tmk,
    similarity_score, same_resort, same_area, same_bedrooms, same_view_type,
    competition_level, notes
) VALUES (
    (SELECT id FROM ops.properties WHERE property_id = 'PRP-MLVR-010045'),
    '2-4-008-015-0102',
    68,
    false,
    true,
    true,
    false,
    'secondary',
    'Honua Kai 2BR, different resort but same Kaanapali area'
);
-- Competes for guests searching "Kaanapali 2BR" but not direct competitor
```

---

# HOMEOWNER ACQUISITION SCHEMA TABLES

## homeowner_acquisition.prospects

**PURPOSE:** The person or entity being pursued as a potential property owner client. Links to directory.contacts for unified contact management. Tracks pipeline stage, assigned team member, and lead source.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| prospect_id | text | NOT NULL, UNIQUE | Business ID: HOP-NNNNNN |
| contact_id | uuid | FK → directory.contacts(id), NOT NULL | Link to unified contact record |
| source_id | uuid | FK → homeowner_acquisition.lead_sources(id) | How we found this prospect |
| assigned_to_member_id | uuid | FK → ops.team_directory(id) | Team member working this prospect |
| status | text | NOT NULL, DEFAULT 'new' | Pipeline stage: new, contacted, qualified, proposal_sent, negotiating, won, lost |
| priority | text | DEFAULT 'medium' | Outreach priority: hot, high, medium, low |
| estimated_close_date | date | | Expected close date |
| lost_reason | text | | If status=lost, why? |
| notes | text | | Internal notes |
| first_contact_date | date | | When we first reached out |
| last_contact_date | date | | Most recent contact |
| next_follow_up_date | date | | Scheduled follow-up |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- status IN ('new', 'contacted', 'qualified', 'proposal_sent', 'negotiating', 'won', 'lost')
- priority IN ('hot', 'high', 'medium', 'low')

**FK CASCADE ACTIONS:**
- contact_id: ON DELETE RESTRICT (cannot delete contact if prospect exists)
- source_id: ON DELETE SET NULL
- assigned_to_member_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Hot lead from recent property sale
INSERT INTO homeowner_acquisition.prospects (
    prospect_id, contact_id, source_id, assigned_to_member_id,
    status, priority, estimated_close_date,
    first_contact_date, next_follow_up_date, notes
) VALUES (
    'HOP-010042',
    (SELECT id FROM directory.contacts WHERE email = 'johnson@investmentllc.com'),
    (SELECT id FROM homeowner_acquisition.lead_sources WHERE source_code = 'COUNTY_SALE'),
    (SELECT id FROM ops.team_directory WHERE email = 'scott@mauiife.com'),
    'contacted',
    'hot',
    '2026-01-15',
    '2025-12-01',
    '2025-12-10',
    'New buyer from SF, purchased Kapalua Ridge Villa. Sent intro email, awaiting response.'
);
-- High priority prospect from county sale records

-- Referral lead
INSERT INTO homeowner_acquisition.prospects (
    prospect_id, contact_id, source_id, assigned_to_member_id,
    status, priority, first_contact_date, notes
) VALUES (
    'HOP-010043',
    (SELECT id FROM directory.contacts WHERE email = 'mary.smith@gmail.com'),
    (SELECT id FROM homeowner_acquisition.lead_sources WHERE source_code = 'REFERRAL'),
    (SELECT id FROM ops.team_directory WHERE email = 'sales@mauiife.com'),
    'qualified',
    'high',
    '2025-11-15',
    'Referred by existing owner Bob Johnson. Has 2 properties in Wailea, unhappy with current PM.'
);
-- Warm referral lead - already qualified
```

---

## homeowner_acquisition.prospect_properties

**PURPOSE:** Properties associated with a prospect. Links to external.properties via TMK for property details. Stores deal-specific fields like estimated value, revenue projections, and pipeline status separate from the external property record.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| prospect_property_id | text | NOT NULL, UNIQUE | Business ID: HOPP-NNNNNN |
| prospect_id | uuid | FK → homeowner_acquisition.prospects(id), NOT NULL | Parent prospect |
| external_tmk | text | FK → external.properties(tmk) | Link to external property data (property details live here) |
| status | text | NOT NULL, DEFAULT 'identified' | Deal stage: identified, evaluating, proposed, negotiating, won, lost |
| estimated_value | numeric(12,2) | | Our estimate of property value |
| estimated_annual_revenue | numeric(12,2) | | Projected gross annual revenue |
| current_rental_income | numeric(12,2) | | Owner's reported current income (if shared) |
| management_fee_proposed | numeric(5,4) | | Proposed management fee (0.2000 = 20%) |
| onboarded_property_id | uuid | FK → ops.properties(id) | Link to ops.properties after conversion |
| won_date | date | | Date deal was won |
| lost_date | date | | Date deal was lost |
| lost_reason | text | | Why we lost this property |
| notes | text | | Deal-specific notes |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- status IN ('identified', 'evaluating', 'proposed', 'negotiating', 'won', 'lost')

**FK CASCADE ACTIONS:**
- prospect_id: ON DELETE CASCADE (delete property records when prospect deleted)
- external_tmk: ON DELETE SET NULL (keep deal record if external property deleted)
- onboarded_property_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Property in active negotiation
INSERT INTO homeowner_acquisition.prospect_properties (
    prospect_property_id, prospect_id, external_tmk,
    status, estimated_value, estimated_annual_revenue,
    current_rental_income, management_fee_proposed, notes
) VALUES (
    'HOPP-010015',
    (SELECT id FROM homeowner_acquisition.prospects WHERE prospect_id = 'HOP-010042'),
    '2-4-006-002-0045',
    'negotiating',
    2100000.00,
    165000.00,
    NULL,
    0.2000,
    'New owner, no rental history. Projecting $165K based on comps.'
);
-- Negotiating management agreement with new buyer

-- Won property - now onboarded
INSERT INTO homeowner_acquisition.prospect_properties (
    prospect_property_id, prospect_id, external_tmk,
    status, estimated_value, estimated_annual_revenue,
    management_fee_proposed, onboarded_property_id, won_date
) VALUES (
    'HOPP-010016',
    (SELECT id FROM homeowner_acquisition.prospects WHERE prospect_id = 'HOP-010043'),
    '2-4-012-008-0033',
    'won',
    3200000.00,
    240000.00,
    0.2200,
    (SELECT id FROM ops.properties WHERE property_id = 'PRP-MLVR-010089'),
    '2025-11-01'
);
-- Successfully converted - now in ops.properties
```

---

## homeowner_acquisition.lead_sources

**PURPOSE:** Reference table of lead source channels for tracking marketing ROI and optimizing acquisition spend. Stores source codes used in reporting and attribution.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| source_code | text | NOT NULL, UNIQUE | Short code: REFERRAL, COUNTY_SALE, MANAGER_CHANGE, COLD_OUTREACH, etc. |
| source_name | text | NOT NULL | Display name |
| source_category | text | | Category: organic, paid, referral, data_driven |
| is_active | boolean | DEFAULT true | Is this source currently being tracked? |
| notes | text | | Description of source |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |

**NO FOREIGN KEYS** - This is a reference table

**SAMPLE DATA:**
```sql
-- Data-driven lead sources
INSERT INTO homeowner_acquisition.lead_sources (source_code, source_name, source_category, notes)
VALUES 
    ('COUNTY_SALE', 'County Sale Records', 'data_driven', 'Properties sold within last 12 months'),
    ('MANAGER_CHANGE', 'Manager Change Detected', 'data_driven', 'Owner fired previous PM'),
    ('NEGATIVE_REVIEWS', 'Negative Review Analysis', 'data_driven', 'High opportunity score from review sentiment');

-- Organic/referral sources
INSERT INTO homeowner_acquisition.lead_sources (source_code, source_name, source_category, notes)
VALUES 
    ('REFERRAL', 'Owner Referral', 'referral', 'Referred by existing client'),
    ('REALTOR', 'Realtor Referral', 'referral', 'Referred by real estate agent'),
    ('WEBSITE', 'Website Inquiry', 'organic', 'Inbound from mauiife.com');

-- Paid sources
INSERT INTO homeowner_acquisition.lead_sources (source_code, source_name, source_category, notes)
VALUES 
    ('GOOGLE_ADS', 'Google Ads', 'paid', 'PPC campaigns'),
    ('DIRECT_MAIL', 'Direct Mail', 'paid', 'Mailer campaigns to property owners');
```

---

## homeowner_acquisition.lead_activities

**PURPOSE:** Activity log tracking all interactions with prospects. Captures calls, emails, meetings, and follow-ups for pipeline management and team accountability.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| activity_id | text | NOT NULL, UNIQUE | Business ID: HOPA-NNNNNN |
| prospect_id | uuid | FK → homeowner_acquisition.prospects(id), NOT NULL | Related prospect |
| activity_type | text | NOT NULL | Type: call, email, meeting, site_visit, proposal_sent, contract_sent, note |
| activity_date | timestamptz | NOT NULL, DEFAULT now() | When activity occurred |
| performed_by_member_id | uuid | FK → ops.team_directory(id) | Team member who performed |
| subject | text | | Brief subject/title |
| description | text | | Detailed notes |
| outcome | text | | Result: connected, voicemail, no_answer, scheduled_followup, etc. |
| next_action | text | | Recommended next step |
| next_action_date | date | | When to take next action |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |

**CHECK CONSTRAINTS:**
- activity_type IN ('call', 'email', 'meeting', 'site_visit', 'proposal_sent', 'contract_sent', 'note')

**FK CASCADE ACTIONS:**
- prospect_id: ON DELETE CASCADE
- performed_by_member_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Initial outreach call
INSERT INTO homeowner_acquisition.lead_activities (
    activity_id, prospect_id, activity_type, activity_date,
    performed_by_member_id, subject, description, outcome, next_action, next_action_date
) VALUES (
    'HOPA-010523',
    (SELECT id FROM homeowner_acquisition.prospects WHERE prospect_id = 'HOP-010042'),
    'call',
    '2025-12-01 10:30:00',
    (SELECT id FROM ops.team_directory WHERE email = 'scott@mauiife.com'),
    'Initial outreach - new property purchase',
    'Called Johnson Investment LLC re: recent Kapalua Ridge purchase. Spoke with Tom Johnson, CFO. Very interested in PM services. Currently interviewing 3 companies.',
    'connected',
    'Send proposal and comp analysis',
    '2025-12-03'
);

-- Follow-up email
INSERT INTO homeowner_acquisition.lead_activities (
    activity_id, prospect_id, activity_type, activity_date,
    performed_by_member_id, subject, description, outcome
) VALUES (
    'HOPA-010524',
    (SELECT id FROM homeowner_acquisition.prospects WHERE prospect_id = 'HOP-010042'),
    'email',
    '2025-12-03 14:00:00',
    (SELECT id FROM ops.team_directory WHERE email = 'scott@mauiife.com'),
    'Proposal sent - Kapalua Ridge Villa management',
    'Sent full proposal with revenue projections, comp analysis, and management agreement draft.',
    'scheduled_followup'
);
```

---

## homeowner_acquisition.proposals

**PURPOSE:** Management proposals sent to prospects. Tracks proposal status, key terms, and links to version history for iterative negotiations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| proposal_id | text | NOT NULL, UNIQUE | Business ID: PROP-NNNNNN |
| prospect_id | uuid | FK → homeowner_acquisition.prospects(id), NOT NULL | Related prospect |
| prospect_property_id | uuid | FK → homeowner_acquisition.prospect_properties(id) | Specific property if multi-property prospect |
| status | text | NOT NULL, DEFAULT 'draft' | Status: draft, sent, viewed, under_review, accepted, rejected, expired |
| sent_date | date | | When proposal was sent |
| expires_date | date | | Proposal expiration date |
| management_fee_percent | numeric(5,4) | | Proposed fee (0.2000 = 20%) |
| minimum_term_months | integer | | Minimum contract term |
| projected_annual_revenue | numeric(12,2) | | Revenue projection in proposal |
| projected_owner_net | numeric(12,2) | | Projected net to owner |
| key_differentiators | text[] | | Array of selling points highlighted |
| notes | text | | Internal notes on proposal |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- status IN ('draft', 'sent', 'viewed', 'under_review', 'accepted', 'rejected', 'expired')

**FK CASCADE ACTIONS:**
- prospect_id: ON DELETE CASCADE
- prospect_property_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Active proposal under review
INSERT INTO homeowner_acquisition.proposals (
    proposal_id, prospect_id, prospect_property_id,
    status, sent_date, expires_date,
    management_fee_percent, minimum_term_months,
    projected_annual_revenue, projected_owner_net,
    key_differentiators
) VALUES (
    'PROP-010008',
    (SELECT id FROM homeowner_acquisition.prospects WHERE prospect_id = 'HOP-010042'),
    (SELECT id FROM homeowner_acquisition.prospect_properties WHERE prospect_property_id = 'HOPP-010015'),
    'under_review',
    '2025-12-03',
    '2025-12-17',
    0.2000,
    12,
    165000.00,
    132000.00,
    ARRAY['Local presence', '24/7 guest support', 'Dynamic pricing technology', 'Owner portal with real-time reporting']
);
-- Proposal out for review, expires in 2 weeks
```

---

## homeowner_acquisition.proposal_versions

**PURPOSE:** Version history for proposals showing iterative changes during negotiation. Captures what changed between versions for audit trail.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| proposal_id | uuid | FK → homeowner_acquisition.proposals(id), NOT NULL | Parent proposal |
| version_number | integer | NOT NULL | Version: 1, 2, 3... |
| created_at | timestamptz | DEFAULT now() | When version was created |
| created_by_member_id | uuid | FK → ops.team_directory(id) | Who created this version |
| management_fee_percent | numeric(5,4) | | Fee in this version |
| minimum_term_months | integer | | Term in this version |
| projected_annual_revenue | numeric(12,2) | | Revenue projection |
| changes_summary | text | | What changed from previous version |
| document_url | text | | Link to PDF/document |

**UNIQUE CONSTRAINT:** (proposal_id, version_number) - One version number per proposal

**FK CASCADE ACTIONS:**
- proposal_id: ON DELETE CASCADE
- created_by_member_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Version 1 - initial proposal
INSERT INTO homeowner_acquisition.proposal_versions (
    proposal_id, version_number, created_by_member_id,
    management_fee_percent, minimum_term_months, projected_annual_revenue,
    changes_summary, document_url
) VALUES (
    (SELECT id FROM homeowner_acquisition.proposals WHERE proposal_id = 'PROP-010008'),
    1,
    (SELECT id FROM ops.team_directory WHERE email = 'scott@mauiife.com'),
    0.2200,
    24,
    165000.00,
    'Initial proposal',
    'https://drive.google.com/file/proposal_010008_v1.pdf'
);

-- Version 2 - negotiated terms
INSERT INTO homeowner_acquisition.proposal_versions (
    proposal_id, version_number, created_by_member_id,
    management_fee_percent, minimum_term_months, projected_annual_revenue,
    changes_summary, document_url
) VALUES (
    (SELECT id FROM homeowner_acquisition.proposals WHERE proposal_id = 'PROP-010008'),
    2,
    (SELECT id FROM ops.team_directory WHERE email = 'scott@mauiife.com'),
    0.2000,
    12,
    165000.00,
    'Reduced fee from 22% to 20%, reduced term from 24 to 12 months per owner request',
    'https://drive.google.com/file/proposal_010008_v2.pdf'
);
```

---

## homeowner_acquisition.contracts

**PURPOSE:** Signed management contracts with property owners. Links to DocuSign for e-signature tracking. Stores key contract terms and dates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| contract_id | text | NOT NULL, UNIQUE | Business ID: CONT-NNNNNN |
| prospect_id | uuid | FK → homeowner_acquisition.prospects(id), NOT NULL | Related prospect |
| prospect_property_id | uuid | FK → homeowner_acquisition.prospect_properties(id) | Related property |
| proposal_id | uuid | FK → homeowner_acquisition.proposals(id) | Source proposal |
| status | text | NOT NULL, DEFAULT 'draft' | Status: draft, sent, signed, active, terminated, expired |
| docusign_envelope_id | text | | DocuSign envelope ID for tracking |
| sent_date | date | | When sent for signature |
| signed_date | date | | When fully executed |
| effective_date | date | | When management begins |
| expiration_date | date | | When contract expires |
| management_fee_percent | numeric(5,4) | | Agreed management fee |
| term_months | integer | | Contract term length |
| auto_renew | boolean | DEFAULT true | Does contract auto-renew? |
| termination_notice_days | integer | DEFAULT 30 | Days notice required to terminate |
| document_url | text | | Link to signed contract |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- status IN ('draft', 'sent', 'signed', 'active', 'terminated', 'expired')

**FK CASCADE ACTIONS:**
- prospect_id: ON DELETE CASCADE
- prospect_property_id: ON DELETE SET NULL
- proposal_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Active contract
INSERT INTO homeowner_acquisition.contracts (
    contract_id, prospect_id, prospect_property_id, proposal_id,
    status, docusign_envelope_id,
    sent_date, signed_date, effective_date, expiration_date,
    management_fee_percent, term_months, auto_renew, termination_notice_days,
    document_url
) VALUES (
    'CONT-010003',
    (SELECT id FROM homeowner_acquisition.prospects WHERE prospect_id = 'HOP-010043'),
    (SELECT id FROM homeowner_acquisition.prospect_properties WHERE prospect_property_id = 'HOPP-010016'),
    (SELECT id FROM homeowner_acquisition.proposals WHERE proposal_id = 'PROP-010005'),
    'active',
    'ENVELOPE-ABC123XYZ',
    '2025-10-20',
    '2025-10-25',
    '2025-11-01',
    '2026-10-31',
    0.2200,
    12,
    true,
    30,
    'https://drive.google.com/file/contract_010003_signed.pdf'
);
-- Active management contract, auto-renews annually
```

---

## homeowner_acquisition.onboarding_tasks

**PURPOSE:** Template checklist of onboarding tasks required to bring a new property into management. Used to generate onboarding_progress records for each new property.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| task_code | text | NOT NULL, UNIQUE | Business ID: TASK-NNN |
| task_name | text | NOT NULL | Task display name |
| description | text | | Detailed instructions |
| category | text | | Category: legal, financial, operational, listing, access |
| sort_order | integer | NOT NULL | Display order |
| estimated_days | integer | | Typical days to complete |
| required | boolean | DEFAULT true | Is this task mandatory? |
| depends_on_task_id | uuid | FK → homeowner_acquisition.onboarding_tasks(id) | Must complete this task first |
| is_active | boolean | DEFAULT true | Is task currently in use? |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |

**FK CASCADE ACTIONS:**
- depends_on_task_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Legal/Contract tasks
INSERT INTO homeowner_acquisition.onboarding_tasks (task_code, task_name, description, category, sort_order, estimated_days, required)
VALUES 
    ('TASK-001', 'Execute Management Agreement', 'Get signed management contract via DocuSign', 'legal', 1, 3, true),
    ('TASK-002', 'Collect W-9', 'Obtain W-9 from property owner for tax reporting', 'legal', 2, 5, true),
    ('TASK-003', 'Setup Direct Deposit', 'Configure owner bank account for distributions', 'financial', 3, 5, true);

-- Operational tasks
INSERT INTO homeowner_acquisition.onboarding_tasks (task_code, task_name, description, category, sort_order, estimated_days, required)
VALUES 
    ('TASK-004', 'Property Walkthrough', 'Conduct detailed property inspection and inventory', 'operational', 4, 2, true),
    ('TASK-005', 'Collect Keys/Access Codes', 'Obtain all keys, fobs, and access codes', 'access', 5, 1, true),
    ('TASK-006', 'Setup Smart Lock', 'Install or configure remote access system', 'access', 6, 3, false);

-- Listing tasks
INSERT INTO homeowner_acquisition.onboarding_tasks (task_code, task_name, description, category, sort_order, estimated_days, required)
VALUES 
    ('TASK-007', 'Professional Photography', 'Schedule and complete property photo shoot', 'listing', 7, 7, true),
    ('TASK-008', 'Create Listing Content', 'Write property descriptions and amenity list', 'listing', 8, 3, true),
    ('TASK-009', 'Publish Airbnb Listing', 'Create and publish Airbnb listing', 'listing', 9, 2, true),
    ('TASK-010', 'Publish VRBO Listing', 'Create and publish VRBO listing', 'listing', 10, 2, true);
```

---

## homeowner_acquisition.onboarding_progress

**PURPOSE:** Tracks completion status of onboarding tasks for each prospect. Junction table between prospects and onboarding_tasks with completion timestamps and notes.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| prospect_id | uuid | FK → homeowner_acquisition.prospects(id), NOT NULL | Prospect being onboarded |
| task_id | uuid | FK → homeowner_acquisition.onboarding_tasks(id), NOT NULL | Task from template |
| status | text | NOT NULL, DEFAULT 'pending' | Status: pending, in_progress, completed, skipped, blocked |
| assigned_to_member_id | uuid | FK → ops.team_directory(id) | Team member responsible |
| started_at | timestamptz | | When work began |
| completed_at | timestamptz | | When task was completed |
| due_date | date | | Target completion date |
| notes | text | | Task-specific notes |
| blocker_reason | text | | If blocked, why? |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**UNIQUE CONSTRAINT:** (prospect_id, task_id) - One progress record per prospect-task pair

**CHECK CONSTRAINTS:**
- status IN ('pending', 'in_progress', 'completed', 'skipped', 'blocked')

**FK CASCADE ACTIONS:**
- prospect_id: ON DELETE CASCADE
- task_id: ON DELETE RESTRICT (cannot delete task template if progress records exist)
- assigned_to_member_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Generate onboarding checklist for new prospect
INSERT INTO homeowner_acquisition.onboarding_progress (prospect_id, task_id, status, assigned_to_member_id, due_date)
SELECT 
    (SELECT id FROM homeowner_acquisition.prospects WHERE prospect_id = 'HOP-010043'),
    t.id,
    'pending',
    (SELECT id FROM ops.team_directory WHERE email = 'ops@mauiife.com'),
    '2025-11-15'::date + (t.sort_order * 2)  -- Stagger due dates
FROM homeowner_acquisition.onboarding_tasks t
WHERE t.is_active = true
ORDER BY t.sort_order;

-- Mark task completed
UPDATE homeowner_acquisition.onboarding_progress
SET status = 'completed', completed_at = now()
WHERE prospect_id = (SELECT id FROM homeowner_acquisition.prospects WHERE prospect_id = 'HOP-010043')
  AND task_id = (SELECT id FROM homeowner_acquisition.onboarding_tasks WHERE task_code = 'TASK-001');
```

---

## homeowner_acquisition.property_assessments

**PURPOSE:** Detailed property evaluations conducted during the acquisition process. Documents property condition, needed improvements, and readiness for rental. Links to prospect_properties.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| assessment_id | text | NOT NULL, UNIQUE | Business ID: ASMT-NNNNNN |
| prospect_property_id | uuid | FK → homeowner_acquisition.prospect_properties(id), NOT NULL | Property being assessed |
| assessed_by_member_id | uuid | FK → ops.team_directory(id) | Who conducted assessment |
| assessment_date | date | NOT NULL | When assessment was conducted |
| overall_condition | text | | Condition: excellent, good, fair, poor |
| rental_ready | boolean | | Is property ready to rent as-is? |
| estimated_prep_cost | numeric(10,2) | | Cost to prepare for rental |
| estimated_prep_days | integer | | Days needed to prepare |
| furnishing_status | text | | fully_furnished, partially_furnished, unfurnished |
| recommended_improvements | text[] | | Array of suggested improvements |
| strengths | text[] | | Array of property strengths |
| concerns | text[] | | Array of concerns or issues |
| comp_analysis_notes | text | | How property compares to competitors |
| photos_url | text | | Link to assessment photos |
| notes | text | | Detailed assessment notes |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- overall_condition IN ('excellent', 'good', 'fair', 'poor')
- furnishing_status IN ('fully_furnished', 'partially_furnished', 'unfurnished')

**FK CASCADE ACTIONS:**
- prospect_property_id: ON DELETE CASCADE
- assessed_by_member_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
INSERT INTO homeowner_acquisition.property_assessments (
    assessment_id, prospect_property_id, assessed_by_member_id,
    assessment_date, overall_condition, rental_ready,
    estimated_prep_cost, estimated_prep_days, furnishing_status,
    recommended_improvements, strengths, concerns,
    comp_analysis_notes, photos_url
) VALUES (
    'ASMT-010012',
    (SELECT id FROM homeowner_acquisition.prospect_properties WHERE prospect_property_id = 'HOPP-010015'),
    (SELECT id FROM ops.team_directory WHERE email = 'ops@mauiife.com'),
    '2025-12-05',
    'good',
    false,
    8500.00,
    14,
    'fully_furnished',
    ARRAY['Update master bath fixtures', 'Replace lanai furniture', 'Deep clean AC ducts', 'Professional staging'],
    ARRAY['Premium ocean view', 'Recently renovated kitchen', 'Covered parking', 'Strong resort amenities'],
    ARRAY['Dated bathroom fixtures', 'Worn lanai furniture', 'Minor wall touch-ups needed'],
    'Comparable to Sullivan managed unit in same building. Their unit gets $50/night more but has updated baths. With recommended improvements, should match or exceed.',
    'https://drive.google.com/folder/assessment_010012_photos'
);
-- Good property with some needed improvements before listing
```

---

## homeowner_acquisition.revenue_projections

**PURPOSE:** Revenue forecasts for prospect properties showing monthly/annual projections with assumptions. Used in proposals and owner conversations to set realistic expectations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| projection_id | text | NOT NULL, UNIQUE | Business ID: PROJ-NNNNNN |
| prospect_property_id | uuid | FK → homeowner_acquisition.prospect_properties(id), NOT NULL | Property being projected |
| created_by_member_id | uuid | FK → ops.team_directory(id) | Who created projection |
| projection_date | date | NOT NULL, DEFAULT CURRENT_DATE | When projection was created |
| scenario | text | NOT NULL, DEFAULT 'base' | Scenario: conservative, base, optimistic |
| projection_year | integer | NOT NULL | Year being projected |
| projected_occupancy | numeric(5,4) | | Annual occupancy rate (0.7200 = 72%) |
| projected_adr | numeric(8,2) | | Average daily rate |
| projected_gross_revenue | numeric(12,2) | | Gross booking revenue |
| projected_expenses | numeric(12,2) | | Operating expenses |
| projected_management_fee | numeric(12,2) | | Management fee amount |
| projected_owner_net | numeric(12,2) | | Net to owner |
| assumptions | text | | Key assumptions documented |
| comp_properties_used | text[] | | TMKs of comparable properties used |
| notes | text | | Additional notes |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- scenario IN ('conservative', 'base', 'optimistic')

**FK CASCADE ACTIONS:**
- prospect_property_id: ON DELETE CASCADE
- created_by_member_id: ON DELETE SET NULL

**SAMPLE DATA:**
```sql
-- Base case projection
INSERT INTO homeowner_acquisition.revenue_projections (
    projection_id, prospect_property_id, created_by_member_id,
    projection_date, scenario, projection_year,
    projected_occupancy, projected_adr,
    projected_gross_revenue, projected_expenses, projected_management_fee, projected_owner_net,
    assumptions, comp_properties_used
) VALUES (
    'PROJ-010012',
    (SELECT id FROM homeowner_acquisition.prospect_properties WHERE prospect_property_id = 'HOPP-010015'),
    (SELECT id FROM ops.team_directory WHERE email = 'scott@mauiife.com'),
    '2025-12-05',
    'base',
    2026,
    0.7200,
    425.00,
    111690.00,  -- 365 * 0.72 * 425
    28000.00,   -- Cleaning, supplies, repairs, etc.
    22338.00,   -- 20% of gross
    61352.00,   -- Net to owner
    'Based on 2024-2025 performance of comparable units in Kapalua Ridge. Assumes property improvements completed. Peak season Dec-Mar, shoulder Apr-May and Sep-Nov.',
    ARRAY['2-4-006-002-0044', '2-4-006-002-0046', '2-4-006-002-0047']
);

-- Conservative projection (same property)
INSERT INTO homeowner_acquisition.revenue_projections (
    projection_id, prospect_property_id, created_by_member_id,
    projection_date, scenario, projection_year,
    projected_occupancy, projected_adr,
    projected_gross_revenue, projected_expenses, projected_management_fee, projected_owner_net,
    assumptions
) VALUES (
    'PROJ-010013',
    (SELECT id FROM homeowner_acquisition.prospect_properties WHERE prospect_property_id = 'HOPP-010015'),
    (SELECT id FROM ops.team_directory WHERE email = 'scott@mauiife.com'),
    '2025-12-05',
    'conservative',
    2026,
    0.6500,
    395.00,
    93706.00,
    26000.00,
    18741.00,
    48965.00,
    'Conservative case assumes slower ramp-up, lower ADR until reviews established. First-year property typically runs 10-15% below mature listings.'
);
```

---

# BUSINESS LOGIC

## Hot Lead Detection

Properties are flagged as `is_hot_lead = TRUE` when:

1. **Recent Sale**: `last_sale_date` is within 12 months of today
2. **Manager Change**: Any record in `property_managers` where `ended_at` is within 6 months

```sql
-- Auto-update hot lead status (run daily)
UPDATE external.properties ep
SET is_hot_lead = (
    -- Recent sale within 12 months
    (ep.last_sale_date > CURRENT_DATE - INTERVAL '12 months')
    OR
    -- Manager fired within 6 months
    EXISTS (
        SELECT 1 FROM external.property_managers pm
        WHERE pm.tmk = ep.tmk
          AND pm.ended_at > CURRENT_DATE - INTERVAL '6 months'
    )
),
updated_at = now()
WHERE ep.is_managed_by_us = false;
```

## Opportunity Score Calculation

Reviews are scored 1-100 based on:
- **Base score**: 50
- **Rating penalty**: -10 per star below 4 (1-star = -30, 2-star = -20, 3-star = -10)
- **Pain point bonus**: +10 per actionable pain point (max +40)
- **No host response bonus**: +10 if complaint with no response
- **Recency bonus**: +10 if within 3 months

```sql
-- Example scoring logic
SELECT 
    review_id,
    50  -- base
    - (GREATEST(0, (4 - rating)) * 10)  -- rating penalty
    + (LEAST(4, array_length(pain_points, 1)) * 10)  -- pain points
    + (CASE WHEN host_response IS NULL AND rating <= 3 THEN 10 ELSE 0 END)  -- no response
    + (CASE WHEN review_date > CURRENT_DATE - INTERVAL '3 months' THEN 10 ELSE 0 END)  -- recency
    AS calculated_opportunity_score
FROM external.property_reviews
WHERE sentiment = 'negative';
```

## Status Progression Flow

```
external.properties.our_status:
watching → target → in_pursuit → proposal_sent → converted/declined/lost

homeowner_acquisition.prospects.status:
new → contacted → qualified → proposal_sent → negotiating → won/lost

homeowner_acquisition.prospect_properties.status:
identified → evaluating → proposed → negotiating → won/lost
```

---

# COMMON USAGE PATTERNS

## Pattern 1: Find Hot Leads for Outreach

```sql
-- Get hot leads prioritized by opportunity
SELECT 
    ep.tmk,
    ep.property_name,
    ep.owner_name,
    ep.owner_mailing_address || ', ' || ep.owner_mailing_city || ' ' || ep.owner_mailing_state || ' ' || ep.owner_mailing_zip AS owner_address,
    ep.last_sale_date,
    ep.last_sale_price,
    pm.manager_name AS former_manager,
    pm.ended_at AS manager_left_date,
    CASE 
        WHEN pm.ended_at IS NOT NULL THEN 'Manager Change'
        WHEN ep.last_sale_date > CURRENT_DATE - INTERVAL '12 months' THEN 'Recent Sale'
    END AS hot_lead_reason
FROM external.properties ep
LEFT JOIN external.property_managers pm ON pm.tmk = ep.tmk 
    AND pm.ended_at > CURRENT_DATE - INTERVAL '6 months'
WHERE ep.is_hot_lead = true
  AND ep.is_managed_by_us = false
  AND ep.our_status IN ('watching', 'target')
ORDER BY 
    CASE WHEN pm.ended_at IS NOT NULL THEN 0 ELSE 1 END,  -- Manager changes first
    ep.last_sale_date DESC NULLS LAST;
```

## Pattern 2: Competitor Analysis for Pricing

```sql
-- Get competitor pricing for a specific property
WITH our_property AS (
    SELECT p.id, p.property_id, ep.tmk
    FROM ops.properties p
    JOIN external.properties ep ON ep.ops_property_id = p.id
    WHERE p.property_id = 'PRP-MLVR-010045'
)
SELECT 
    cs.competition_level,
    ep.property_name,
    ep.bedrooms,
    ep.view_type,
    epp.nightly_rate,
    epp.cleaning_fee,
    epp.check_in_date,
    epp.captured_at
FROM our_property op
JOIN external.competitive_sets cs ON cs.ops_property_id = op.id
JOIN external.properties ep ON ep.tmk = cs.external_tmk
LEFT JOIN LATERAL (
    SELECT * FROM external.property_pricing 
    WHERE tmk = ep.tmk 
    ORDER BY captured_at DESC 
    LIMIT 1
) epp ON true
WHERE cs.competition_level = 'primary'
ORDER BY epp.nightly_rate DESC;
```

## Pattern 3: Review Sentiment Analysis for Sales

```sql
-- Get properties with negative reviews and high opportunity scores
SELECT 
    ep.tmk,
    ep.property_name,
    ep.current_manager_name,
    COUNT(*) AS negative_review_count,
    AVG(er.opportunity_score) AS avg_opportunity_score,
    array_agg(DISTINCT unnest_pain) AS all_pain_points
FROM external.properties ep
JOIN external.property_reviews er ON er.tmk = ep.tmk
CROSS JOIN LATERAL unnest(er.pain_points) AS unnest_pain
WHERE er.sentiment = 'negative'
  AND er.review_date > CURRENT_DATE - INTERVAL '12 months'
  AND ep.is_managed_by_us = false
GROUP BY ep.tmk, ep.property_name, ep.current_manager_name
HAVING AVG(er.opportunity_score) >= 70
ORDER BY avg_opportunity_score DESC, negative_review_count DESC;
```

## Pattern 4: Pipeline Status Dashboard

```sql
-- Prospect pipeline by stage
SELECT 
    p.status,
    COUNT(*) AS prospect_count,
    SUM(pp.estimated_annual_revenue) AS total_projected_revenue,
    AVG(pp.management_fee_proposed * pp.estimated_annual_revenue) AS avg_fee_revenue
FROM homeowner_acquisition.prospects p
LEFT JOIN homeowner_acquisition.prospect_properties pp ON pp.prospect_id = p.id
WHERE p.status NOT IN ('won', 'lost')
GROUP BY p.status
ORDER BY 
    CASE p.status 
        WHEN 'new' THEN 1
        WHEN 'contacted' THEN 2
        WHEN 'qualified' THEN 3
        WHEN 'proposal_sent' THEN 4
        WHEN 'negotiating' THEN 5
    END;
```

## Pattern 5: Onboarding Progress Tracking

```sql
-- Get onboarding completion status for active prospects
SELECT 
    p.prospect_id,
    c.full_name AS owner_name,
    COUNT(*) FILTER (WHERE op.status = 'completed') AS completed_tasks,
    COUNT(*) AS total_tasks,
    ROUND(100.0 * COUNT(*) FILTER (WHERE op.status = 'completed') / COUNT(*), 1) AS completion_percent,
    MIN(CASE WHEN op.status IN ('pending', 'in_progress') THEN op.due_date END) AS next_due_date
FROM homeowner_acquisition.prospects p
JOIN directory.contacts c ON c.id = p.contact_id
JOIN homeowner_acquisition.onboarding_progress op ON op.prospect_id = p.id
WHERE p.status = 'won'
GROUP BY p.prospect_id, c.full_name
ORDER BY completion_percent ASC;
```

---

# SAMPLE QUERIES

## Query 1: Full Property Intelligence Report

```sql
-- Complete market intelligence for a single TMK
WITH property_info AS (
    SELECT * FROM external.properties WHERE tmk = '2-4-006-001-0023'
),
manager_history AS (
    SELECT 
        manager_name, 
        started_at, 
        ended_at,
        ROW_NUMBER() OVER (ORDER BY COALESCE(ended_at, '9999-12-31') DESC) as rn
    FROM external.property_managers 
    WHERE tmk = '2-4-006-001-0023'
),
sale_history AS (
    SELECT sale_date, sale_price, buyer_name
    FROM external.property_sales 
    WHERE tmk = '2-4-006-001-0023'
    ORDER BY sale_date DESC
    LIMIT 3
),
review_summary AS (
    SELECT 
        COUNT(*) as total_reviews,
        AVG(rating) as avg_rating,
        COUNT(*) FILTER (WHERE sentiment = 'negative') as negative_count,
        AVG(opportunity_score) FILTER (WHERE sentiment = 'negative') as avg_opportunity
    FROM external.property_reviews 
    WHERE tmk = '2-4-006-001-0023'
),
recent_pricing AS (
    SELECT nightly_rate, cleaning_fee, captured_at
    FROM external.property_pricing 
    WHERE tmk = '2-4-006-001-0023'
    ORDER BY captured_at DESC
    LIMIT 1
)
SELECT 
    pi.*,
    mh.manager_name AS current_manager,
    rs.total_reviews,
    rs.avg_rating,
    rs.negative_count,
    rs.avg_opportunity,
    rp.nightly_rate AS latest_rate,
    rp.cleaning_fee AS latest_cleaning
FROM property_info pi
LEFT JOIN manager_history mh ON mh.rn = 1 AND mh.ended_at IS NULL
CROSS JOIN review_summary rs
LEFT JOIN recent_pricing rp ON true;
```

## Query 2: Acquisition Pipeline Value

```sql
-- Total pipeline value by stage with weighted probability
SELECT 
    pp.status,
    COUNT(DISTINCT p.id) AS prospect_count,
    COUNT(pp.id) AS property_count,
    SUM(pp.estimated_annual_revenue) AS total_annual_revenue,
    SUM(pp.estimated_annual_revenue * pp.management_fee_proposed) AS total_fee_revenue,
    -- Weighted by stage probability
    SUM(pp.estimated_annual_revenue * pp.management_fee_proposed * 
        CASE pp.status
            WHEN 'identified' THEN 0.10
            WHEN 'evaluating' THEN 0.25
            WHEN 'proposed' THEN 0.40
            WHEN 'negotiating' THEN 0.70
            ELSE 0
        END
    ) AS weighted_fee_revenue
FROM homeowner_acquisition.prospects p
JOIN homeowner_acquisition.prospect_properties pp ON pp.prospect_id = p.id
WHERE pp.status NOT IN ('won', 'lost')
GROUP BY pp.status
ORDER BY 
    CASE pp.status 
        WHEN 'identified' THEN 1
        WHEN 'evaluating' THEN 2
        WHEN 'proposed' THEN 3
        WHEN 'negotiating' THEN 4
    END;
```

## Query 3: Competitor Pricing Trends

```sql
-- Monthly average competitor pricing trends
SELECT 
    DATE_TRUNC('month', epp.captured_at) AS month,
    ep.resort_name,
    ep.bedrooms,
    COUNT(DISTINCT ep.tmk) AS property_count,
    ROUND(AVG(epp.nightly_rate), 2) AS avg_nightly_rate,
    ROUND(AVG(epp.cleaning_fee), 2) AS avg_cleaning_fee,
    ROUND(MIN(epp.nightly_rate), 2) AS min_rate,
    ROUND(MAX(epp.nightly_rate), 2) AS max_rate
FROM external.property_pricing epp
JOIN external.properties ep ON ep.tmk = epp.tmk
WHERE ep.is_competitor = true
  AND epp.captured_at > CURRENT_DATE - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', epp.captured_at), ep.resort_name, ep.bedrooms
ORDER BY month DESC, ep.resort_name, ep.bedrooms;
```

## Query 4: Lead Source ROI

```sql
-- Lead source performance analysis
SELECT 
    ls.source_code,
    ls.source_name,
    ls.source_category,
    COUNT(p.id) AS total_leads,
    COUNT(*) FILTER (WHERE p.status = 'won') AS won,
    COUNT(*) FILTER (WHERE p.status = 'lost') AS lost,
    COUNT(*) FILTER (WHERE p.status NOT IN ('won', 'lost')) AS active,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.status = 'won') / NULLIF(COUNT(*), 0), 1) AS win_rate_pct,
    COALESCE(SUM(pp.estimated_annual_revenue) FILTER (WHERE pp.status = 'won'), 0) AS revenue_won
FROM homeowner_acquisition.lead_sources ls
LEFT JOIN homeowner_acquisition.prospects p ON p.source_id = ls.id
LEFT JOIN homeowner_acquisition.prospect_properties pp ON pp.prospect_id = p.id
GROUP BY ls.source_code, ls.source_name, ls.source_category
ORDER BY revenue_won DESC;
```

## Query 5: Stale Prospects Needing Follow-up

```sql
-- Prospects with no activity in 14+ days
SELECT 
    p.prospect_id,
    c.full_name AS owner_name,
    c.email,
    p.status,
    p.priority,
    p.last_contact_date,
    CURRENT_DATE - p.last_contact_date AS days_since_contact,
    la.activity_type AS last_activity_type,
    la.outcome AS last_outcome,
    tm.full_name AS assigned_to
FROM homeowner_acquisition.prospects p
JOIN directory.contacts c ON c.id = p.contact_id
LEFT JOIN ops.team_directory tm ON tm.id = p.assigned_to_member_id
LEFT JOIN LATERAL (
    SELECT activity_type, outcome 
    FROM homeowner_acquisition.lead_activities 
    WHERE prospect_id = p.id 
    ORDER BY activity_date DESC 
    LIMIT 1
) la ON true
WHERE p.status NOT IN ('won', 'lost')
  AND (p.last_contact_date < CURRENT_DATE - INTERVAL '14 days' 
       OR p.last_contact_date IS NULL)
ORDER BY p.priority DESC, p.last_contact_date NULLS FIRST;
```

---

# MIGRATION INFORMATION

**Migration File:** `V2025.12.09.120000__001_external_homeowner_acquisition_schema.sql`  
**Date:** December 9, 2025  
**Author:** Central Memory Team

## What This Migration Creates:

- ✅ 17 tables (6 external + 11 homeowner_acquisition)
- ✅ 6 sequences for Business IDs
- ✅ 35 indexes for query performance
- ✅ 2 trigger functions (hot_lead_update, updated_at_timestamp)
- ✅ 17 triggers (updated_at on all tables)

## Dependencies:

**Required Tables (Must Exist):**
- ops.properties
- ops.team_directory
- directory.contacts
- geo.areas

## Post-Migration Steps:

1. **Seed lead_sources** - Insert reference data for lead source tracking
2. **Seed onboarding_tasks** - Insert standard onboarding checklist template
3. **Initial data load** - Import existing market data from county records and scrapers
4. **Configure scrapers** - Set up Airbnb/VRBO scraping jobs to populate reviews and pricing

---

**Document Version:** 1.0  
**Last Updated:** December 9, 2025  
**Total Tables:** 17 (6 external + 11 homeowner_acquisition)  
**Migration:** V2025.12.09.120000__001_external_homeowner_acquisition_schema.sql
