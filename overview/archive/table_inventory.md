# Central Memory Table Inventory v6 — Audit Report
**Generated:** 2025-12-06
**Source:** Central_Memory_Table_Inventory_v5.md (updated to v6)

---

## Executive Summary

| Metric | Count | % |
|--------|-------|---|
| **Total Tables** | 213 | 100% |
| **Tables WITH column specs** | 39 | 18% |
| **Tables WITHOUT column specs** | 174 | 82% |
| **Built tables (in migrations)** | 12 | 5.6% |
| **Built tables (marked in doc)** | 16 | 7.5% |
| **Tables still to build** | 197 | 92.5% |

---

## Schema Overview — 16 Schemas

| Schema | Tables | Built | Missing | Has Specs |
|--------|--------|-------|---------|-----------|
| ops | 55 | 12 | 43 | 14 |
| ref | 15 | 0 | 15 | 0 |
| geo | 5 | 0 | 5 | 0 |
| ai | 8 | 0 | 8 | 3 |
| comms | 6 | 0 | 6 | 0 |
| knowledge | 15 | 0 | 15 | 3 |
| observability | 5 | 0 | 5 | 0 |
| pricing | 6 | 0 | 6 | 0 |
| portal | 6 | 0 | 6 | 0 |
| concierge | 24 | 0 | 24 | 2 |
| finance | 12 | 0 | 12 | 2 |
| company | 12 | 0 | 12 | 2 |
| guest_marketing | 12 | 0 | 12 | 2 |
| homeowner_acquisition | 10 | 0 | 10 | 2 |
| property_listings | 23 | 0 | 23 | 4 |
| staging | 7 | 0* | 7 | 7 |
| **TOTAL** | **213** | **12** | **201** | **39** |

*staging tables marked as built in inventory doc but migrations not in db-migrations folder

---

## Tables WITH Column Specifications (39 tables)

### OPS Schema — Built (9 tables with full specs)

| Table | Status | Records | Key Columns |
|-------|--------|---------|-------------|
| ops.contacts | ✅ Built | ~4,735 | contact_id, contact_type, full_name, email, phone |
| ops.guests | ✅ Built | ~4,735 | guest_id, contact_id, total_bookings, is_vip |
| ops.reservations | ✅ Built | ~19,000 | reservation_id, property_id, arrival_date, total_amount |
| ops.resorts | ✅ Built | ~20 | resort_id, resort_code, resort_name |
| ops.properties | ✅ Built | Loading | property_id, resort_id, bedrooms, status |
| ops.homeowners | ✅ Built | — | homeowner_id, contact_id, legal_name |
| ops.homeowner_property_relationship | ✅ Built | — | hprx_id, homeowner_id, property_id, ownership_type |
| ops.property_care_tickets | ✅ Built | — | ticket_id, property_id, ticket_status, ticket_priority |
| ops.reservation_tickets | ✅ Built | — | ticket_id, reservation_id, ticket_status |

### OPS Schema — To Build (5 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| ops.companies | 🔵 To Build | company_id, company_name, company_type, primary_contact_id |
| ops.team_directory | 🔵 To Build | member_id, contact_id, team_id, role, status |
| ops.cleans | 🔵 To Build | clean_id, property_id, clean_type, performed_by_member_id |
| ops.inspections | 🔵 To Build | inspection_id, property_id, inspection_type, performed_by_member_id |
| ops.reviews | 🔵 To Build | review_id, reservation_id, platform, rating, review_text |

### AI Schema (3 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| ai.agents | 🔵 To Build | agent_id, agent_name, agent_role, model_id, status |
| ai.conversation_logs | 🔵 To Build | log_id, agent_id, contact_id, started_at, token_count |
| ai.guardrails | 🔵 To Build | guardrail_id, agent_id, rule_type, rule_definition |

### Knowledge Schema (3 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| knowledge.departments | 🔵 To Build | department_id, department_code, department_name |
| knowledge.documents | 🔵 To Build | document_id, department_id, document_type, title, content |
| knowledge.embeddings | 🔵 To Build | embedding_id, document_id, chunk_index, embedding_vector |

### Finance Schema (2 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| finance.trust_accounts | 🔵 To Build | account_id, homeowner_id, account_type, balance |
| finance.owner_statements | 🔵 To Build | statement_id, homeowner_id, period_start, period_end |

### Concierge Schema (2 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| concierge.guest_surveys | 🔵 To Build | survey_id, reservation_id, guest_id, survey_type |
| concierge.itineraries | 🔵 To Build | itinerary_id, reservation_id, guest_id, theme_id |

### Company Schema (2 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| company.brand_guidelines | 🔵 To Build | guideline_id, brand_name, voice_description |
| company.websites | 🔵 To Build | website_id, domain, site_type, cms_platform |

### Guest Marketing Schema (2 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| guest_marketing.campaigns | 🔵 To Build | campaign_id, campaign_name, campaign_type, status |
| guest_marketing.attribution | 🔵 To Build | attribution_id, reservation_id, source, medium |

### Homeowner Acquisition Schema (2 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| homeowner_acquisition.prospects | 🔵 To Build | prospect_id, contact_id, property_address, status |
| homeowner_acquisition.pipeline_stages | 🔵 To Build | stage_id, stage_name, stage_order, is_active |

### Property Listings Schema (4 tables with specs)

| Table | Status | Key Columns |
|-------|--------|-------------|
| property_listings.content | 🔵 To Build | content_id, property_id, content_type, title |
| property_listings.channel_listings | 🔵 To Build | listing_id, property_id, channel, external_id |
| property_listings.brand_identities | 🔵 To Build | brand_id, property_id, brand_name, tagline |
| property_listings.social_accounts | 🔵 To Build | account_id, property_id, platform, handle |

### Staging Schema (7 tables with specs — marked built in doc)

| Table | Status | Key Columns |
|-------|--------|-------------|
| staging.properties | ✅ Marked Built | property_id (from source) |
| staging.resorts | ✅ Marked Built | database_id (from source) |
| staging.guests | ✅ Marked Built | guest_id (from source) |
| staging.reservations | ✅ Marked Built | reservation_id (from source) |
| staging.homeowners | ✅ Marked Built | homeowner_id (from source) |
| staging.homeowner_property_relationships | ✅ Marked Built | hprx_id (from source) |
| staging.internal_team | ✅ Marked Built | database_id (from source) |

---

## Tables WITHOUT Column Specifications (174 tables)

### OPS Schema — 41 tables missing specs

**Teams & Organization:**
- ops.teams
- ops.team_shifts
- ops.admin_tickets
- ops.accounting_tickets

**Property Physical Assets:**
- ops.rooms
- ops.beds
- ops.appliances
- ops.appliance_parts
- ops.fixtures
- ops.surfaces
- ops.lighting
- ops.window_coverings
- ops.room_features
- ops.ac_systems
- ops.ac_units
- ops.property_doors
- ops.property_locks
- ops.key_checkouts
- ops.property_amenities
- ops.property_rules
- ops.property_access_codes

**Inspections:**
- ops.inspection_questions
- ops.inspection_room_questions

**Inventory:**
- ops.storage_locations
- ops.inventory_items
- ops.inventory_stock
- ops.inventory_events

**Linens & Supplies:**
- ops.linen_items
- ops.linen_lots
- ops.linen_movements
- ops.guest_supplies
- ops.guest_supply_usage

**Purchasing:**
- ops.purchase_orders
- ops.po_items
- ops.receipts
- ops.purchases
- ops.cost_history

**Financial:**
- ops.transactions
- ops.payroll
- ops.financial_reports

**Vendors:**
- ops.vendor_assignments

### REF Schema — 15 tables missing specs

- ref.status_master
- ref.status_applies_to
- ref.status_transitions
- ref.activity_levels
- ref.limitation_types
- ref.interest_categories
- ref.interest_types
- ref.schedule_density_levels
- ref.driving_tolerance_levels
- ref.budget_levels
- ref.ticket_categories
- ref.ticket_priorities
- ref.sla_definitions
- ref.property_types
- ref.room_types

### GEO Schema — 5 tables missing specs

- geo.zones
- geo.cities
- geo.areas
- geo.neighborhoods
- geo.points_of_interest

### AI Schema — 5 tables missing specs

- ai.agent_configs
- ai.agent_capabilities
- ai.conversation_messages
- ai.handoff_rules
- ai.performance_metrics

### COMMS Schema — 6 tables missing specs

- comms.threads
- comms.messages
- comms.templates
- comms.template_versions
- comms.channels
- comms.channel_configs

### Knowledge Schema — 12 tables missing specs

- knowledge.sections
- knowledge.document_versions
- knowledge.sops
- knowledge.sop_steps
- knowledge.faqs
- knowledge.embedding_chunks
- knowledge.search_logs
- knowledge.property_guides
- knowledge.property_guide_sections
- knowledge.training_materials
- knowledge.policies
- knowledge.checklists

### Observability Schema — 5 tables missing specs

- observability.etl_runs
- observability.etl_errors
- observability.data_quality_issues
- observability.system_alerts
- observability.audit_log

### Pricing Schema — 6 tables missing specs

- pricing.base_rates
- pricing.seasonal_adjustments
- pricing.competitor_rates
- pricing.market_events
- pricing.dynamic_adjustments
- pricing.rate_history

### Portal Schema — 6 tables missing specs

- portal.users
- portal.sessions
- portal.roles
- portal.permissions
- portal.user_roles
- portal.preferences

### Concierge Schema — 22 tables missing specs

**Locations:**
- concierge.beaches
- concierge.hikes
- concierge.activities
- concierge.restaurants
- concierge.attractions
- concierge.shops
- concierge.shopping_locations
- concierge.experience_spots

**Services:**
- concierge.services
- concierge.service_categories
- concierge.add_ons

**Guest Profiles:**
- concierge.guest_travel_profiles
- concierge.guest_interests
- concierge.guest_limitations
- concierge.survey_responses

**Itineraries:**
- concierge.itinerary_themes
- concierge.theme_interest_weights
- concierge.theme_limitations_excluded
- concierge.itinerary_days
- concierge.itinerary_items

**Bookings:**
- concierge.bookings
- concierge.booking_confirmations

### Finance Schema — 10 tables missing specs

- finance.trust_transactions
- finance.statement_line_items
- finance.invoices
- finance.invoice_items
- finance.payments
- finance.payables
- finance.tax_records
- finance.reconciliations
- finance.reserve_accounts
- finance.reserve_transactions

### Company Schema — 10 tables missing specs

- company.voice_guidelines
- company.logos
- company.color_palettes
- company.typography
- company.website_pages
- company.seo_content
- company.newsletters
- company.newsletter_editions
- company.awareness_campaigns
- company.content_library

### Guest Marketing Schema — 10 tables missing specs

- guest_marketing.campaign_properties
- guest_marketing.media_accounts
- guest_marketing.media_posts
- guest_marketing.segments
- guest_marketing.segment_members
- guest_marketing.email_sends
- guest_marketing.email_events
- guest_marketing.touchpoints
- guest_marketing.landing_pages
- guest_marketing.retargeting_audiences

### Homeowner Acquisition Schema — 8 tables missing specs

- homeowner_acquisition.prospect_properties
- homeowner_acquisition.campaigns
- homeowner_acquisition.media_accounts
- homeowner_acquisition.outreach_sequences
- homeowner_acquisition.sequence_steps
- homeowner_acquisition.outreach_events
- homeowner_acquisition.pipeline_history
- homeowner_acquisition.onboarding_tasks

### Property Listings Schema — 19 tables missing specs

**Content:**
- property_listings.content_versions
- property_listings.photos
- property_listings.photo_tags
- property_listings.videos
- property_listings.virtual_tours

**Channels:**
- property_listings.channel_sync_log
- property_listings.performance_metrics
- property_listings.search_rankings

**Branding:**
- property_listings.color_palettes
- property_listings.typography
- property_listings.voice_guidelines
- property_listings.messaging_templates

**Social:**
- property_listings.social_posts
- property_listings.social_analytics

**Content Planning:**
- property_listings.content_calendars
- property_listings.calendar_items
- property_listings.content_assets

**Competitive:**
- property_listings.competitor_analysis
- property_listings.brand_audits

---

## Migration Status

### Applied Migrations (8 files)

| # | Migration | Tables/Objects Created |
|---|-----------|------------------------|
| 1 | V2025.12.05.153155__uuidv7.sql | generate_uuid_v7() function |
| 2 | V2025.12.05.161924__create_users_table.sql | users table |
| 3 | V2025.12.06.032706__001_ops_schemas.sql | ops, analytics schemas |
| 4 | V2025.12.06.032826__002_ops_core_tables.sql | contacts, guests, homeowners, resorts, properties, reservations |
| 5 | V2025.12.06.032942__003_ops_join_tables.sql | homeowner_properties, reservation_guests, resort_contacts, property_vendors |
| 6 | V2025.12.06.033022__004_ops_ticket_tables.sql | property_care_tickets, reservation_tickets |
| 7 | V2025.12.06.033058__005_ops_indexes.sql | Indexes |
| 8 | V2025.12.06.033131__006_analytics_views.sql | 5 analytics views |

### Analytics Views Created

| View | Description |
|------|-------------|
| analytics.guest_metrics | Guest behavior from reservation history |
| analytics.property_performance | Revenue and occupancy metrics |
| analytics.homeowner_portfolio | Portfolio aggregations |
| analytics.reservation_insights | Enriched reservation data |
| analytics.ticket_metrics | Ticket metrics by property |

---

## Priority Recommendations

### Immediate: Define Missing Column Specs

**174 tables** lack column definitions. Priority order for spec creation:

1. **ref schema** (15 tables) — Foundation for status/category lookups
2. **ops remaining** (41 tables) — Core operations
3. **geo schema** (5 tables) — Location foundation
4. **ai schema** (5 tables) — Agent infrastructure
5. **concierge schema** (22 tables) — Guest experience

### Next Migrations to Create

1. Create schemas: ref, geo, ai, comms, knowledge, observability, pricing, portal, concierge, finance, company, guest_marketing, homeowner_acquisition, property_listings, staging
2. Create ref.status_master and status tables
3. Create geo.zones, geo.cities, geo.areas
4. Create ops.companies, ops.teams, ops.team_directory
5. Create ops.rooms and property asset tables
6. Create staging tables for ETL

---

## Legend

- ✅ Built — Table exists in database via migrations
- 🔵 To Build — Table defined but not yet created
- **Has Specs** — Table has full column definitions in inventory doc
- **Missing Specs** — Table only has PK/FK summary, needs column definitions
