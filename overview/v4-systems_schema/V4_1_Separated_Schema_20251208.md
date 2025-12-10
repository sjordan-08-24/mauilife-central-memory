# Schema Structure V4.1: Final Separated Schema

**Version:** 4.1  
**Date:** December 8, 2025  
**Purpose:** Complete schema reorganization with service, team, and storage schemas. Fully aligned with Service_System_Final_Specification_v4, Inspection_and_Inventory_Systems, and Guest_Journey_System reference guides.

---

## Summary

| Metric | Value |
|--------|-------|
| **Total Schemas** | 23 |
| **Total Tables** | ~364 |
| **ops Schema** | ELIMINATED (all tables relocated) |
| **New Schemas** | service, team, storage, portal |

---

## Schema Inventory (23 Schemas)

| Schema | Purpose | Tables | Source |
|--------|---------|--------|--------|
| **directory** | Contacts, guests, homeowners, companies, vendors | 13 | ops + directory |
| **property** | Properties, resorts, rooms, cleans, inspections, physical assets | 28 | ops property/asset tables |
| **reservations** | Reservations, guest journeys, touchpoints, reviews, fees | 8 | ops + guest journey system |
| **service** | Tickets, projects, damage claims, time allocation joins | 30 | Service System v4 |
| **team** | Teams, team_directory, shifts, time_entries, verifications | 6 | Service System v4 |
| **storage** | Files, file context joins | 4 | Service System v4 |
| **inventory** | Inventory items, room/owner/company/storage inventory, purchasing | 15 | ops inventory tables |
| **ref** | Reference/lookup data | 39 | ref (expanded) |
| **geo** | Geographic hierarchy | 5 | geo |
| **ai** | AI agent infrastructure | 18 | ai |
| **comms** | Communications system | 12 | comms |
| **knowledge** | Documents, SOPs, embeddings | 28 | knowledge |
| **revenue** | Revenue management, dynamic pricing | 12 | pricing (renamed) |
| **concierge** | Guest experience system | 24 | concierge |
| **finance** | Accounting, trust, statements, payroll | 18 | finance |
| **brand_marketing** | Company brand + guest marketing campaigns | 24 | brand + marketing |
| **property_listings** | Listing content & distribution | 23 | property_listings |
| **external** | External market intelligence | 6 | external |
| **homeowner_acquisition** | Owner pipeline & onboarding | 10 | homeowner_acquisition |
| **secure** | Sensitive/encrypted data | 5 | secure |
| **analytics** | Materialized views & analytics | 5 | analytics |
| **staging** | ETL staging tables | 7 | staging |
| **portal** | User authentication, sessions, RBAC | 6 | portal |

---

# DETAILED SCHEMA BREAKDOWN

---

## 1. DIRECTORY Schema (13 tables)

**Purpose:** Central contact entities that other schemas reference.

| Table | Description | Key FKs |
|-------|-------------|---------|
| directory.contacts | Unified contact hub | — |
| directory.guests | Guest profiles | → contacts |
| directory.homeowners | Homeowner profiles | → contacts |
| directory.companies | Vendor/partner/company profiles | → contacts |
| directory.vendors | Vendor-specific details | → companies |
| directory.homeowner_property_relationship | Owner-property links | → homeowners, → property.properties |
| directory.vendor_assignments | Vendor-property links | → companies, → property.properties |
| directory.contact_groups | Contact groupings | — |
| directory.contact_group_members | Group membership | → contact_groups, → contacts |
| directory.contact_relationships | Contact links | → contacts |
| directory.contact_notes | Contact notes | → contacts |
| directory.contact_tags | Contact tagging | → contacts |
| directory.contact_merge_history | Dedup tracking | → contacts |

---

## 2. PROPERTY Schema (28 tables)

**Purpose:** All property and physical asset components including inspections.

### Core Property Tables

| Table | Description | Key FKs |
|-------|-------------|---------|
| property.resorts | Resort/complex data | — |
| property.properties | Property master | → geo.areas, → resorts |
| property.rooms | Property rooms | → properties |
| property.beds | Bed configurations | → rooms |

### Cleaning & Inspection Tables

| Table | Description | Key FKs |
|-------|-------------|---------|
| property.cleans | Cleaning events | → properties, → reservations.reservations, → team.team_directory |
| property.inspections | Inspection events | → properties, → cleans, → reservations.reservations, → team.team_directory, → service.tickets |
| property.inspection_questions | Master inspection question templates | → team.team_directory |
| property.inspection_room_questions | Per-room inspection answers | → inspections, → rooms, → inspection_questions, → inspection_issues, → service.tickets, → team.team_directory |
| property.inspection_question_inventory_links | Links questions to inventory items | → inspection_questions, → inventory.inventory_items |
| property.inspection_issues | Issues found during inspection | → inspections, → rooms, → service.tickets, → team.team_directory |
| property.inspection_room_scores | Calculated scores per room | → inspections, → rooms |

### Physical Asset Tables

| Table | Description | Key FKs |
|-------|-------------|---------|
| property.appliances | Major appliances | → rooms |
| property.appliance_parts | Appliance components | → appliances |
| property.fixtures | Plumbing fixtures | → rooms |
| property.surfaces | Counters, floors | → rooms |
| property.lighting | Light fixtures | → rooms |
| property.window_coverings | Blinds, curtains | → rooms |
| property.room_features | Built-ins, closets | → rooms |
| property.ac_systems | HVAC systems | → properties |
| property.ac_units | Individual AC units | → ac_systems |
| property.property_doors | Doors inventory | → properties |
| property.property_locks | Lock details | → property_doors |
| property.key_checkouts | Key tracking | → property_locks, → team.team_directory |
| property.safety_items | Safety equipment | → properties |

### Property Configuration Tables

| Table | Description | Key FKs |
|-------|-------------|---------|
| property.property_amenities | Amenity flags | → properties |
| property.property_rules | House rules | → properties |
| property.property_access_codes | Access codes | → properties |

---

## 3. RESERVATIONS Schema (8 tables)

**Purpose:** All reservation-related tables including guest journey tracking.

| Table | Description | Key FKs |
|-------|-------------|---------|
| reservations.reservations | Reservation master | → property.properties, → directory.guests |
| reservations.guest_journeys | Guest journey state (1:1 with reservations) | → reservations, → ref.journey_stages, → ref.touchpoint_types, → reviews |
| reservations.guest_journey_touchpoints | Touchpoint event log | → guest_journeys, → ref.touchpoint_types, → ref.journey_stages, → service.tickets |
| reservations.reviews | Guest reviews | → reservations, → guest_journeys, → directory.guests, → property.properties, → property.cleans |
| reservations.reservation_fees | Actual fees charged | → reservations, → ref.fee_types, → team.team_directory |
| reservations.reservation_guests | Additional guests on reservation | → reservations, → directory.guests |
| reservations.reservation_financials | Financial summary per reservation | → reservations |
| reservations.damage_claims_legacy | Legacy damage documentation (deprecated) | → reservations, → property.properties |

**Guest Journey System:**
- `guest_journeys` — 1:1 with reservations. Stores current_stage_id, previous_stage_id, next_touchpoint_type_id, sentiment, VIP flags.
- `guest_journey_touchpoints` — Event log of all guest interactions. Links to service.tickets via linked_ticket_id.

**Note:** `linked_ticket_id` in `guest_journey_touchpoints` now references `service.tickets(id)` (unified ticket table).

---

## 4. SERVICE Schema (30 tables)

**Purpose:** Unified ticketing, projects, and damage claim lifecycle.

### Core Ticket Table

| Table | Description | Key FKs |
|-------|-------------|---------|
| service.tickets | Unified ticket table (PC, RSV, ADM, ACCT) | → property.properties, → reservations.reservations, → directory.homeowners, → directory.contacts, → team.team_directory, → team.teams |

### Time Allocation Joins

| Table | Description | Key FKs |
|-------|-------------|---------|
| service.ticket_time_entries | Ticket ↔ time entry allocation | → tickets, → team.time_entries |
| service.inspection_time_entries | Inspection ↔ time entry allocation | → property.inspections, → team.time_entries |

### Ticket Relationship Joins

| Table | Description | Key FKs |
|-------|-------------|---------|
| service.ticket_properties | Property links | → tickets, → property.properties, → property.resorts |
| service.ticket_reservations | Reservation links | → tickets, → reservations.reservations |
| service.ticket_homeowners | Homeowner links + billing | → tickets, → directory.homeowners |
| service.ticket_relationships | Related tickets (self-reference) | → tickets |

### Ticket Assignment Joins

| Table | Description | Key FKs |
|-------|-------------|---------|
| service.ticket_shifts | Shift assignments | → tickets, → team.shifts, → team.team_directory |
| service.ticket_contacts | People + notifications | → tickets, → directory.contacts, → team.team_directory, → directory.homeowners, → directory.guests |
| service.ticket_vendors | Vendor services + scoring | → tickets, → directory.companies, → directory.contacts |

### Ticket Tracking Joins

| Table | Description | Key FKs |
|-------|-------------|---------|
| service.ticket_misses | Miss history | → tickets, → team.shifts, → team.team_directory |
| service.ticket_costs | Cost allocations | → tickets, → directory.homeowners, → directory.companies, → ticket_purchases, → team.time_entries, → finance.transactions |
| service.ticket_purchases | Procurement | → tickets, → directory.companies, → storage.files |
| service.ticket_events | Activity log | → tickets, → team.team_directory, → directory.contacts |
| service.ticket_labels | Tagging | → tickets, → ref.label_key, → team.team_directory |

### Ticket Operation Joins

| Table | Description | Key FKs |
|-------|-------------|---------|
| service.ticket_inspections | Inspection links | → tickets, → property.inspections |
| service.ticket_cleans | Clean links | → tickets, → property.cleans |
| service.ticket_inventory_events | Inventory links | → tickets, → inventory.inventory_events |
| service.ticket_recurring | Recurring task links | → tickets, → service.recurring_tasks, → knowledge.articles |
| service.ticket_transactions | Finance links | → tickets, → finance.transactions |

### Projects

| Table | Description | Key FKs |
|-------|-------------|---------|
| service.projects | Umbrella tasks | → property.resorts, → team.team_directory |
| service.project_properties | Per-property checklist | → projects, → property.properties, → property.resorts, → team.team_directory |
| service.project_tickets | Tickets linked to projects | → projects, → tickets, → property.properties |

### Damage Claims

| Table | Description | Key FKs |
|-------|-------------|---------|
| service.ticket_damage | Damage flags on tickets | → tickets, → ref.damage_category_key, → team.team_directory, → damage_claims |
| service.ticket_claims | Ticket-to-claim links | → tickets, → damage_claims |
| service.damage_claims | Damage claim master | → tickets, → reservations.reservations, → ref.damage_category_key, → team.team_directory |
| service.damage_claim_submissions | Recovery attempts | → damage_claims, → ref.claim_submission_type_key, → directory.companies, → directory.contacts, → team.team_directory |
| service.damage_claim_approvals | Approvals + payments | → damage_claims, → damage_claim_submissions, → finance.transactions |
| service.damage_claim_denials | Denials + reasons | → damage_claims, → damage_claim_submissions, → storage.files |
| service.damage_claim_appeals | Appeals | → damage_claims, → damage_claim_submissions, → damage_claim_denials |

---

## 5. TEAM Schema (6 tables)

**Purpose:** People, scheduling, and labor tracking.

| Table | Description | Key FKs |
|-------|-------------|---------|
| team.teams | Team definitions | — |
| team.team_directory | Team members | → directory.contacts, → teams, → team_directory (manager) |
| team.shifts | Shift scheduling | → team_directory |
| team.time_entries | Time tracking | → team_directory, → property.properties, → ref.activity_types |
| team.time_entry_verifications | Verification history | → time_entries, → team_directory |
| team.shift_time_entries | Shift ↔ time allocation (HR) | → shifts, → time_entries |

**Time Entry Flow:**
1. `team.time_entries` — Canonical time record (HR/payroll)
2. `team.shift_time_entries` — HR allocation to shifts
3. `service.ticket_time_entries` — Service allocation to tickets
4. `service.inspection_time_entries` — Service allocation to inspections

---

## 6. STORAGE Schema (4 tables)

**Purpose:** Central file management with context joins.

| Table | Description | Key FKs |
|-------|-------------|---------|
| storage.files | Central file registry | → property.properties, → property.rooms, → team.team_directory |
| storage.ticket_files | Ticket ↔ file links | → service.tickets, → files |
| storage.inspection_files | Inspection ↔ file links | → property.inspections, → files, → property.rooms |
| storage.room_files | Room ↔ file links (reference photos) | → property.rooms, → files |

**Note:** Replaces `ops.inspection_photos`. Same photo can be linked to multiple contexts (ticket, inspection, room).

---

## 7. INVENTORY Schema (15 tables)

**Purpose:** Inventory tracking across rooms, owners, company assets, and warehouse.

### Core Inventory Tables

| Table | Description | Key FKs |
|-------|-------------|---------|
| inventory.inventory_items | Universal product catalog | → ref.inventory_item_types, → directory.companies, → inventory_items (replacement) |
| inventory.room_inventory | Guest room item tracking | → property.rooms, → inventory_items, → property.inspections |
| inventory.owner_inventory | Owner personal property | → directory.homeowners, → property.properties, → inventory_items |
| inventory.company_inventory | Company equipment/assets | → inventory_items, → team.team_directory, → property.properties |
| inventory.storage_inventory | Warehouse bulk stock | → inventory_items, → storage_locations, → team.team_directory |
| inventory.storage_locations | Warehouse location hierarchy | → storage_locations (self-reference) |
| inventory.inventory_purchases | Purchase order tracking | → inventory_items, → directory.companies, → property.properties, → team.team_directory |
| inventory.inventory_events | Inventory transactions/movements | → inventory_items, → property.properties, → team.team_directory |

### Linen-Specific Tables

| Table | Description | Key FKs |
|-------|-------------|---------|
| inventory.linen_types | Linen type definitions | — |
| inventory.linen_items | Individual linen tracking | → linen_types |
| inventory.linen_pars | Par levels per property/room | → property.properties, → property.rooms, → linen_types |
| inventory.linen_deliveries | Linen service deliveries | → property.properties, → directory.companies |
| inventory.linen_counts | Linen count records | → property.properties, → team.team_directory |
| inventory.linen_issues | Linen damage/loss tracking | → linen_items, → property.properties |
| inventory.linen_orders | Linen purchase orders | → linen_types, → directory.companies |

---

## 8. REF Schema (39 tables)

**Purpose:** Reference/lookup data for all schemas.

### Ticket System Reference Tables

| Table | Description |
|-------|-------------|
| ref.ticket_type_key | Ticket types: PC, RSV, ADM, ACCT |
| ref.ticket_category_key | Compound categories: PC-PLUMBING, RSV-LATE_CHECKOUT, etc. |
| ref.ticket_priority_key | Priority codes + SLA hours |
| ref.activity_types | Time entry activity classification |
| ref.label_key | Ticket label definitions |

### Damage Claim Reference Tables

| Table | Description |
|-------|-------------|
| ref.damage_category_key | Damage categories: APPLIANCE, FURNITURE, etc. |
| ref.claim_submission_type_key | Submission types: DAMAGE_WAIVER, AIRBNB, VRBO, etc. |
| ref.denial_category_key | Denial categories: DOCUMENTATION, TIMING, etc. |

### Guest Journey Reference Tables

| Table | Description |
|-------|-------------|
| ref.fee_types | Fee type definitions |
| ref.fee_rates | Fee rate configurations with scope hierarchy |
| ref.journey_stages | 14 guest journey stages |
| ref.touchpoint_types | Guest interaction types |
| ref.stage_required_touchpoints | Stage-touchpoint mappings |

### Inventory Reference Tables

| Table | Description |
|-------|-------------|
| ref.inventory_item_types | Item type codes: TWLB, VACU, LPTP, etc. |

### Property Reference Tables

| Table | Description |
|-------|-------------|
| ref.room_types | Room type definitions |
| ref.bed_types | Bed type definitions |
| ref.amenity_types | Amenity definitions |
| ref.appliance_types | Appliance type definitions |
| ref.fixture_types | Fixture type definitions |
| ref.surface_types | Surface type definitions |

### General Reference Tables

| Table | Description |
|-------|-------------|
| ref.status_types | Generic status definitions |
| ref.country_codes | Country reference |
| ref.state_codes | State/province reference |
| ref.currency_codes | Currency reference |
| ref.language_codes | Language reference |
| ref.timezone_codes | Timezone reference |
| ref.platform_types | OTA platform definitions |
| ref.channel_types | Communication channel definitions |
| ref.document_types | Document type definitions |
| ref.relationship_types | Contact relationship types |
| ref.vendor_categories | Vendor category definitions |
| ref.expense_categories | Expense category definitions |
| ref.revenue_categories | Revenue category definitions |
| ref.tax_types | Tax type definitions |
| ref.inspection_categories | Inspection question categories |
| ref.issue_severity_types | Issue severity levels |
| ref.cleaning_types | Clean type definitions |

---

## 9. GEO Schema (5 tables)

**Purpose:** Geographic hierarchy.

| Table | Description | Key FKs |
|-------|-------------|---------|
| geo.countries | Country data | — |
| geo.states | State/province data | → countries |
| geo.cities | City data | → states |
| geo.areas | Neighborhoods/zones | → cities |
| geo.poi | Points of interest | → areas |

---

## 10. AI Schema (18 tables)

**Purpose:** AI agent infrastructure.

| Table | Description | Key FKs |
|-------|-------------|---------|
| ai.agents | Agent definitions | — |
| ai.agent_capabilities | Agent capability mappings | → agents |
| ai.agent_configs | Agent configuration | → agents |
| ai.agent_prompts | Prompt templates | → agents |
| ai.agent_tools | Tool definitions | → agents |
| ai.agent_tool_calls | Tool call logs | → agents, → agent_tools |
| ai.agent_conversations | Conversation sessions | → agents |
| ai.agent_messages | Message history | → agent_conversations |
| ai.agent_memory | Agent memory/context | → agents |
| ai.agent_tasks | Task queue | → agents |
| ai.agent_task_results | Task outcomes | → agent_tasks |
| ai.agent_evaluations | Performance metrics | → agents |
| ai.agent_feedback | Human feedback | → agents, → agent_messages |
| ai.agent_handoffs | Agent-to-agent handoffs | → agents |
| ai.agent_escalations | Escalation to humans | → agents, → team.team_directory |
| ai.model_configs | LLM configurations | — |
| ai.embedding_configs | Embedding configurations | — |
| ai.usage_logs | API usage tracking | → agents |

---

## 11. COMMS Schema (12 tables)

**Purpose:** Communications system.

| Table | Description | Key FKs |
|-------|-------------|---------|
| comms.templates | Message templates | — |
| comms.template_versions | Template version history | → templates |
| comms.channels | Communication channels | — |
| comms.channel_configs | Channel configurations | → channels |
| comms.messages | Message records | → templates, → channels |
| comms.message_recipients | Message recipient tracking | → messages, → directory.contacts |
| comms.message_attachments | Message attachments | → messages, → storage.files |
| comms.message_events | Delivery/open/click tracking | → messages |
| comms.campaigns | Marketing campaigns | — |
| comms.campaign_messages | Campaign message links | → campaigns, → messages |
| comms.automations | Automation rules | — |
| comms.automation_triggers | Automation trigger configs | → automations |

---

## 12. KNOWLEDGE Schema (28 tables)

**Purpose:** Documents, SOPs, embeddings for AI.

| Table | Description | Key FKs |
|-------|-------------|---------|
| knowledge.articles | Knowledge base articles | — |
| knowledge.article_versions | Article version history | → articles |
| knowledge.article_categories | Article categorization | → articles |
| knowledge.article_tags | Article tagging | → articles |
| knowledge.article_embeddings | Vector embeddings | → articles |
| knowledge.sops | Standard operating procedures | — |
| knowledge.sop_steps | SOP step definitions | → sops |
| knowledge.sop_checklists | SOP checklist items | → sops |
| knowledge.guidebooks | Property guidebooks | → property.properties |
| knowledge.guidebook_sections | Guidebook sections | → guidebooks |
| knowledge.faqs | FAQ entries | — |
| knowledge.faq_categories | FAQ categorization | → faqs |
| knowledge.documents | Document storage | → storage.files |
| knowledge.document_embeddings | Document vector embeddings | → documents |
| knowledge.training_materials | Training content | — |
| knowledge.training_modules | Training module definitions | → training_materials |
| knowledge.training_completions | Training completion tracking | → training_modules, → team.team_directory |
| knowledge.policies | Company policies | — |
| knowledge.policy_versions | Policy version history | → policies |
| knowledge.policy_acknowledgments | Policy acknowledgment tracking | → policies, → team.team_directory |
| knowledge.checklists | Checklist templates | — |
| knowledge.checklist_items | Checklist item definitions | → checklists |
| knowledge.checklist_instances | Checklist usage instances | → checklists |
| knowledge.checklist_responses | Checklist item responses | → checklist_instances, → checklist_items |
| knowledge.search_logs | Search query logging | — |
| knowledge.feedback | Knowledge feedback | → articles |
| knowledge.suggestions | Content suggestions | — |
| knowledge.glossary | Term definitions | — |

---

## 13. REVENUE Schema (12 tables)

**Purpose:** Revenue management and dynamic pricing.

| Table | Description | Key FKs |
|-------|-------------|---------|
| revenue.pricing_rules | Pricing rule definitions | → property.properties |
| revenue.pricing_adjustments | Manual price adjustments | → property.properties |
| revenue.seasonal_rates | Seasonal rate configurations | → property.properties |
| revenue.event_pricing | Event-based pricing | → property.properties |
| revenue.competitor_rates | Competitor rate tracking | → property.properties |
| revenue.market_data | Market intelligence | → geo.areas |
| revenue.occupancy_forecasts | Occupancy predictions | → property.properties |
| revenue.revenue_forecasts | Revenue predictions | → property.properties |
| revenue.pricing_recommendations | AI pricing suggestions | → property.properties |
| revenue.rate_history | Historical rate tracking | → property.properties |
| revenue.yield_metrics | Yield management metrics | → property.properties |
| revenue.pricing_logs | Pricing decision logs | → property.properties |

---

## 14. CONCIERGE Schema (24 tables)

**Purpose:** Guest experience and concierge services.

| Table | Description | Key FKs |
|-------|-------------|---------|
| concierge.guest_preferences | Guest preference profiles | → directory.guests |
| concierge.guest_surveys | Survey responses | → reservations.reservations, → directory.guests |
| concierge.survey_questions | Survey question definitions | — |
| concierge.survey_responses | Individual survey answers | → guest_surveys, → survey_questions |
| concierge.itineraries | Guest itinerary plans | → reservations.reservations |
| concierge.itinerary_items | Itinerary activities | → itineraries |
| concierge.recommendations | AI recommendations | → reservations.reservations |
| concierge.recommendation_feedback | Recommendation ratings | → recommendations |
| concierge.bookings | Activity/service bookings | → reservations.reservations |
| concierge.booking_confirmations | Booking confirmation tracking | → bookings |
| concierge.service_providers | Local service providers | → directory.companies |
| concierge.service_offerings | Available services | → service_providers |
| concierge.service_requests | Guest service requests | → reservations.reservations |
| concierge.request_fulfillments | Request completion tracking | → service_requests |
| concierge.local_tips | Local area tips | → geo.areas |
| concierge.attractions | Local attractions | → geo.areas |
| concierge.restaurants | Restaurant recommendations | → geo.areas |
| concierge.activities | Activity recommendations | → geo.areas |
| concierge.special_occasions | Guest special events | → reservations.reservations |
| concierge.welcome_packages | Welcome package configs | → property.properties |
| concierge.amenity_requests | Amenity request tracking | → reservations.reservations |
| concierge.transportation | Transportation arrangements | → reservations.reservations |
| concierge.grocery_orders | Grocery stocking orders | → reservations.reservations |
| concierge.experience_ratings | Experience feedback | → reservations.reservations |

---

## 15. FINANCE Schema (18 tables)

**Purpose:** Accounting, trust accounts, statements, payroll.

| Table | Description | Key FKs |
|-------|-------------|---------|
| finance.transactions | Financial transaction log | → property.properties, → reservations.reservations |
| finance.transaction_lines | Transaction line items | → transactions |
| finance.accounts | Chart of accounts | — |
| finance.account_balances | Account balance tracking | → accounts |
| finance.trust_accounts | Trust account management | — |
| finance.trust_transactions | Trust account movements | → trust_accounts |
| finance.owner_statements | Owner statement headers | → directory.homeowners, → property.properties |
| finance.owner_statement_lines | Statement line items | → owner_statements |
| finance.owner_payouts | Owner payout tracking | → directory.homeowners |
| finance.vendor_payments | Vendor payment tracking | → directory.companies |
| finance.invoices | Invoice management | → directory.contacts |
| finance.invoice_lines | Invoice line items | → invoices |
| finance.expenses | Expense tracking | → property.properties, → team.team_directory |
| finance.expense_receipts | Expense receipt links | → expenses, → storage.files |
| finance.budgets | Budget definitions | → property.properties |
| finance.budget_lines | Budget line items | → budgets |
| finance.payroll_runs | Payroll processing | — |
| finance.payroll_items | Payroll line items | → payroll_runs, → team.team_directory |

---

## 16. BRAND_MARKETING Schema (24 tables)

**Purpose:** Company brand and guest marketing campaigns.

| Table | Description | Key FKs |
|-------|-------------|---------|
| brand_marketing.brand_assets | Brand asset library | → storage.files |
| brand_marketing.brand_guidelines | Brand style guides | — |
| brand_marketing.brand_colors | Brand color palettes | — |
| brand_marketing.brand_fonts | Brand typography | — |
| brand_marketing.brand_templates | Branded templates | — |
| brand_marketing.campaigns | Marketing campaigns | — |
| brand_marketing.campaign_audiences | Campaign targeting | → campaigns |
| brand_marketing.campaign_content | Campaign creative | → campaigns |
| brand_marketing.campaign_channels | Campaign distribution | → campaigns |
| brand_marketing.campaign_metrics | Campaign performance | → campaigns |
| brand_marketing.email_lists | Email list management | — |
| brand_marketing.email_subscribers | Subscriber tracking | → email_lists, → directory.contacts |
| brand_marketing.social_accounts | Social media accounts | — |
| brand_marketing.social_posts | Social media content | → social_accounts |
| brand_marketing.social_metrics | Social media analytics | → social_posts |
| brand_marketing.content_calendar | Content planning | — |
| brand_marketing.content_pieces | Content library | → storage.files |
| brand_marketing.seo_keywords | SEO keyword tracking | — |
| brand_marketing.seo_rankings | SEO rank tracking | → seo_keywords |
| brand_marketing.ad_campaigns | Paid advertising | — |
| brand_marketing.ad_creatives | Ad creative assets | → ad_campaigns |
| brand_marketing.ad_performance | Ad performance metrics | → ad_campaigns |
| brand_marketing.referral_programs | Referral program configs | — |
| brand_marketing.referrals | Referral tracking | → referral_programs, → directory.contacts |

---

## 17. PROPERTY_LISTINGS Schema (23 tables)

**Purpose:** Listing content and distribution.

| Table | Description | Key FKs |
|-------|-------------|---------|
| property_listings.listings | Listing master | → property.properties |
| property_listings.listing_titles | Title variations | → listings |
| property_listings.listing_descriptions | Description variations | → listings |
| property_listings.listing_photos | Photo management | → listings, → storage.files |
| property_listings.listing_amenities | Amenity mappings | → listings |
| property_listings.listing_rules | House rule mappings | → listings |
| property_listings.listing_pricing | Pricing configurations | → listings |
| property_listings.listing_availability | Availability rules | → listings |
| property_listings.listing_minimum_stays | Min stay rules | → listings |
| property_listings.channel_listings | Channel-specific listings | → listings |
| property_listings.channel_mappings | Field mappings per channel | → channel_listings |
| property_listings.channel_sync_logs | Sync status tracking | → channel_listings |
| property_listings.channel_errors | Sync error tracking | → channel_listings |
| property_listings.listing_scores | Listing quality scores | → listings |
| property_listings.listing_performance | Listing performance metrics | → listings |
| property_listings.listing_reviews_summary | Review aggregations | → listings |
| property_listings.seo_content | SEO-optimized content | → listings |
| property_listings.virtual_tours | Virtual tour links | → listings |
| property_listings.floor_plans | Floor plan assets | → listings, → storage.files |
| property_listings.neighborhood_content | Neighborhood descriptions | → listings |
| property_listings.listing_promotions | Promotional content | → listings |
| property_listings.listing_badges | Badge/certification tracking | → listings |
| property_listings.competitor_listings | Competitor tracking | → listings |

---

## 18. EXTERNAL Schema (6 tables)

**Purpose:** External market intelligence.

| Table | Description | Key FKs |
|-------|-------------|---------|
| external.market_listings | External listing data | → geo.areas |
| external.market_rates | External rate data | → geo.areas |
| external.market_occupancy | External occupancy data | → geo.areas |
| external.market_trends | Market trend analysis | → geo.areas |
| external.competitor_properties | Competitor property tracking | → geo.areas |
| external.data_sources | Data source configurations | — |

---

## 19. HOMEOWNER_ACQUISITION Schema (10 tables)

**Purpose:** Owner pipeline and onboarding.

| Table | Description | Key FKs |
|-------|-------------|---------|
| homeowner_acquisition.leads | Lead tracking | → directory.contacts |
| homeowner_acquisition.lead_sources | Lead source tracking | — |
| homeowner_acquisition.lead_activities | Lead activity log | → leads |
| homeowner_acquisition.proposals | Proposal management | → leads |
| homeowner_acquisition.proposal_versions | Proposal version history | → proposals |
| homeowner_acquisition.contracts | Contract management | → leads |
| homeowner_acquisition.onboarding_tasks | Onboarding checklist | → leads |
| homeowner_acquisition.onboarding_progress | Onboarding tracking | → leads, → onboarding_tasks |
| homeowner_acquisition.property_assessments | Property evaluation | → leads |
| homeowner_acquisition.revenue_projections | Revenue estimates | → leads |

---

## 20. SECURE Schema (5 tables)

**Purpose:** Sensitive/encrypted data.

| Table | Description | Key FKs |
|-------|-------------|---------|
| secure.payment_methods | Encrypted payment data | → directory.contacts |
| secure.bank_accounts | Encrypted bank data | → directory.contacts |
| secure.ssn_data | Encrypted SSN data | → directory.contacts |
| secure.access_credentials | Encrypted credentials | → property.properties |
| secure.audit_logs | Security audit trail | — |

---

## 21. ANALYTICS Schema (5 tables)

**Purpose:** Materialized views and analytics.

| Table | Description | Key FKs |
|-------|-------------|---------|
| analytics.property_performance_mv | Property metrics | → property.properties |
| analytics.guest_lifetime_value_mv | Guest LTV | → directory.guests |
| analytics.revenue_summary_mv | Revenue rollups | — |
| analytics.occupancy_trends_mv | Occupancy analysis | — |
| analytics.operational_kpis_mv | KPI dashboards | — |

---

## 22. STAGING Schema (7 tables)

**Purpose:** ETL staging tables.

| Table | Description |
|-------|-------------|
| staging.properties | Property imports |
| staging.resorts | Resort imports |
| staging.guests | Guest imports |
| staging.reservations | Reservation imports |
| staging.homeowners | Homeowner imports |
| staging.homeowner_property_relationships | Relationship imports |
| staging.internal_team | Team imports |

---

## 23. PORTAL Schema (6 tables)

**Purpose:** User authentication, sessions, and role-based access control (RBAC) for all portals (Guest, Owner, Team).

| Table | Description | Key FKs |
|-------|-------------|---------|
| portal.users | Central user accounts for all portals | → directory.contacts |
| portal.sessions | JWT session tracking | → users |
| portal.roles | Role definitions (GUEST, HOMEOWNER, TEAM_MEMBER, ADMIN, etc.) | — |
| portal.permissions | Granular permissions per role | → roles |
| portal.user_roles | User ↔ role assignments (junction) | → users, → roles |
| portal.preferences | User settings as key-value pairs | → users |

**System Roles:** GUEST, HOMEOWNER, TEAM_MEMBER, TEAM_LEAD, MANAGER, ADMIN, SUPER_ADMIN

**Permission Model:** `{resource}.{action}` with scope (own/team/all)
- Example: `reservations.read`, `tickets.write`, `reports.view`

**Session Management:**
- Multiple concurrent sessions per user (web + mobile)
- JWT-based authentication
- Automatic session expiration and cleanup

---

# TABLE COUNT SUMMARY

| Schema | Tables |
|--------|--------|
| directory | 13 |
| property | 28 |
| reservations | 8 |
| service | 30 |
| team | 6 |
| storage | 4 |
| inventory | 15 |
| ref | 39 |
| geo | 5 |
| ai | 18 |
| comms | 12 |
| knowledge | 28 |
| revenue | 12 |
| concierge | 24 |
| finance | 18 |
| brand_marketing | 24 |
| property_listings | 23 |
| external | 6 |
| homeowner_acquisition | 10 |
| secure | 5 |
| analytics | 5 |
| staging | 7 |
| portal | 6 |
| **TOTAL** | **~364** |

---

# CROSS-SCHEMA DEPENDENCY MAP

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ref.* (39 tables)                               │
│              All schemas reference ref for type definitions                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              geo.* (5 tables)                                │
│                    Geographic hierarchy for all locations                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          directory.* (13 tables)                             │
│                                                                              │
│  contacts ──┬── guests ────────────────────────────────────────┐            │
│             │                                                   │            │
│             ├── homeowners ──────────────────────────────────┐ │            │
│             │                                                 │ │            │
│             ├── companies ──► vendors                        │ │            │
│             │       │                                        │ │            │
│             │       └── vendor_assignments ──────────────────┼─┼────┐       │
│             │                                                │ │    │       │
│             └── homeowner_property_relationship ─────────────┼─┼────┤       │
│                                                              │ │    │       │
└──────────────────────────────────────────────────────────────┼─┼────┼───────┘
                                                               │ │    │
                                      ┌────────────────────────┘ │    │
                                      │    ┌─────────────────────┘    │
                                      ▼    ▼                          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          property.* (28 tables)                              │
│                                                                              │
│  resorts ──► properties ──┬── rooms ──┬── beds, appliances, fixtures, etc.  │
│                           │           │                                      │
│                           │           └── room_inventory ◄── inventory.*    │
│                           │                                                  │
│                           ├── cleans ◄───────────────────────────┐          │
│                           │                                       │          │
│                           ├── inspections ◄──────────────────────┼──┐       │
│                           │       │                               │  │       │
│                           │       ├── inspection_questions        │  │       │
│                           │       ├── inspection_room_questions ──┼──┼──┐    │
│                           │       ├── inspection_issues ──────────┼──┼──┤    │
│                           │       └── inspection_room_scores      │  │  │    │
│                           │                                       │  │  │    │
└───────────────────────────┼───────────────────────────────────────┼──┼──┼────┘
                            │                                       │  │  │
                            ▼                                       │  │  │
┌─────────────────────────────────────────────────────────────────────────────┐
│                        reservations.* (8 tables)                             │
│                                                                              │
│  reservations ──┬── guest_journeys ──► guest_journey_touchpoints            │
│                 │         │                      │                           │
│                 │         └── reviews ◄──────────┘                           │
│                 │                                                            │
│                 └── reservation_fees, reservation_guests, etc.              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                            │                                       │  │  │
                            │         ┌─────────────────────────────┘  │  │
                            │         │    ┌───────────────────────────┘  │
                            ▼         ▼    ▼                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           service.* (30 tables)                              │
│                                                                              │
│  tickets ──┬── ticket_properties, ticket_reservations, ticket_homeowners    │
│            │                                                                 │
│            ├── ticket_shifts, ticket_contacts, ticket_vendors               │
│            │                                                                 │
│            ├── ticket_misses, ticket_costs, ticket_events, ticket_labels    │
│            │                                                                 │
│            ├── ticket_inspections ◄── property.inspections                  │
│            ├── ticket_cleans ◄── property.cleans                            │
│            │                                                                 │
│            ├── ticket_time_entries ──► team.time_entries                    │
│            ├── inspection_time_entries ──► team.time_entries                │
│            │                                                                 │
│            ├── projects ──► project_properties, project_tickets             │
│            │                                                                 │
│            └── damage_claims ──► submissions ──► approvals/denials/appeals  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            team.* (6 tables)                                 │
│                                                                              │
│  teams ──► team_directory ──► shifts                                        │
│                   │              │                                           │
│                   └── time_entries ◄── shift_time_entries                   │
│                            │                                                 │
│                            └── time_entry_verifications                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          storage.* (4 tables)                                │
│                                                                              │
│  files ──┬── ticket_files ──► service.tickets                               │
│          ├── inspection_files ──► property.inspections                      │
│          └── room_files ──► property.rooms                                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         inventory.* (15 tables)                              │
│                                                                              │
│  inventory_items ──┬── room_inventory ──► property.rooms                    │
│                    ├── owner_inventory ──► directory.homeowners             │
│                    ├── company_inventory ──► team.team_directory            │
│                    └── storage_inventory ──► storage_locations              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          portal.* (6 tables)                                 │
│                                                                              │
│  users ──┬── sessions (JWT authentication)                                  │
│    │     ├── user_roles ──► roles ──► permissions                           │
│    │     └── preferences (user settings)                                    │
│    │                                                                         │
│    └── → directory.contacts (unified contact link)                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

# KEY FOREIGN KEY UPDATES

All references to old ticket tables now point to `service.tickets`:

| Table | Column | Old Reference | New Reference |
|-------|--------|---------------|---------------|
| property.inspections | follow_up_ticket_id | ops.property_care_tickets | service.tickets |
| property.inspection_room_questions | generated_ticket_id | ops.property_care_tickets | service.tickets |
| property.inspection_issues | generated_ticket_id | ops.property_care_tickets | service.tickets |
| reservations.guest_journey_touchpoints | linked_ticket_id | ops.property_care_tickets OR ops.reservation_tickets | service.tickets |

Portal schema references `directory.contacts` (was `ops.contacts`):

| Table | Column | Old Reference | New Reference |
|-------|--------|---------------|---------------|
| portal.users | contact_id | ops.contacts | directory.contacts |

**Benefit:** Unified ticket table = ONE FK target instead of multiple.

---

# DESIGN PRINCIPLES

## From Service System v4

1. **Single Ticket Table** — All ticket types in service.tickets, differentiated by type_code and category_code
2. **Join Table Pattern** — Every relationship gets its own join table for flexibility
3. **Compound Category Codes** — Format: {TYPE}-{CATEGORY} (e.g., PC-PLUMBING)
4. **Priority-Driven SLA** — No due_at field; priority determines urgency via ref.ticket_priority_key
5. **Time in Team, Allocation in Service** — Canonical time in team.time_entries, allocation in service.*_time_entries
6. **Central File Storage** — storage.files master registry with context joins
7. **Damage Claims as Full Lifecycle** — Separate from tickets, full recovery workflow with submissions/approvals/denials/appeals

## From Inspection System

8. **Inspection → Ticket Flow** — Inspections can generate tickets via follow_up_ticket_id and generated_ticket_id
9. **Room-Level Tracking** — Inspection questions, scores, and inventory tracked per room
10. **Photo → Storage** — Inspection photos moved to storage.inspection_files for unified file management

## From Guest Journey System

11. **Journey = 1:1 with Reservation** — Each reservation has exactly one guest_journey record
12. **Touchpoints = Event Log** — Historical record of all guest interactions
13. **Touchpoint → Ticket Link** — Touchpoints can link to tickets via linked_ticket_id → service.tickets

---

**Document Version:** 4.1  
**Generated:** December 8, 2025  
**Total Schemas:** 23  
**Total Tables:** ~364  
**Based On:**
- Service_System_Final_Specification_v4_20251208.md
- Inspection_and_Inventory_Systems_ops_ref_Reference_Guide_20251206.md
- Guest_Journey_System_ops_ref_Reference_Guide_20251206.md
- Portal_System_portal_Reference_Guide_20251206.md
