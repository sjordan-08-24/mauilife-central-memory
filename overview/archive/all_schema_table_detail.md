# Complete Database Schema - All Tables Detail

**Date:** 20251209 (Updated)
**Total Tables:** ~306+ (including service, team, storage, concierge, portal, external, homeowner_acquisition schemas)
**Primary Key Standard:** UUIDv7 (time-ordered, globally unique)
**Business ID Pattern:** Human-readable text IDs with auto-generated sequences

---

# IMPORTANT: SCHEMA RESTRUCTURING NOTE

**The `ops` schema is NOT in the final architecture.** Tables previously under `ops.*` have been redistributed:

| New Schema | Purpose | Former ops.* Tables |
|------------|---------|---------------------|
| property | Property assets, rooms, amenities | ops.properties, ops.rooms, ops.beds, etc. |
| directory | Contacts, companies | ops.contacts → directory.contacts |
| reservation | Reservations, guests | ops.reservations, ops.guests |
| service | Tickets, claims, projects | ops.property_care_tickets → service.tickets |
| team | Team members, shifts, time | ops.team_directory → team.team_directory |
| storage | Files, attachments | New centralized file storage |
| concierge | Guest experience, itineraries | ops.guest_surveys → concierge.guest_surveys |

The ops.* references in this document are legacy references being migrated.

---

# QUICK REFERENCE - ALL TABLES BY SCHEMA

## AI Schema (18 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | ai.models | MDL-NNNN | Model registry |
| 2 | ai.prompts | PRM-NNNNNN | Prompt library |
| 3 | ai.tools | TOOL-NNNN | Tool registry |
| 4 | ai.agents | AGT-NNNN | Agent registry |
| 5 | ai.agent_configs | ACFG-NNNNNN | Agent configurations |
| 6 | ai.agent_skills | ASKL-NNNNNN | Agent skills |
| 7 | ai.skill_tools | UUID | Skill-tool junction |
| 8 | ai.conversation_logs | CONV-NNNNNNNN | Conversation tracking |
| 9 | ai.conversation_messages | UUID | Message history |
| 10 | ai.guardrails | GRD-NNNNNN | Safety guardrails |
| 11 | ai.handoff_rules | HND-NNNNNN | Agent handoffs |
| 12 | ai.performance_metrics | AMET-NNNNNN | Performance tracking |
| 13 | ai.action_logs | ALOG-NNNNNNNN | Action logging |
| 14 | ai.action_scores | ASCR-NNNNNNNN | Action scoring |
| 15 | ai.workflows | WFL-NNNNNN | Multi-agent workflows |
| 16 | ai.workflow_runs | WRUN-NNNNNNNN | Workflow executions |
| 17 | ai.api_calls | APIC-NNNNNNNN | API call tracking |
| 18 | ai.model_usage | MUSG-NNNNNNNN | Model usage metrics |

## Brand Schema (5 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | brand.brand_guidelines | BG-NNNNNN | Brand standards |
| 2 | brand.color_palettes | UUID | Brand colors |
| 3 | brand.logos | LOGO-NNNN | Logo assets |
| 4 | brand.typography | UUID | Font standards |
| 5 | brand.messaging_templates | TMPL-NNNNNN | Message templates |

## Comms Schema (12 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | comms.channels | CHAN-NNNN | Communication channels |
| 2 | comms.channel_configs | CHCF-NNNNNN | Channel settings |
| 3 | comms.templates | TMPL-NNNNNN | Message templates |
| 4 | comms.template_versions | TVER-NNNNNN | Template versioning |
| 5 | comms.template_channels | UUID | Template-channel junction |
| 6 | comms.threads | THR-NNNNNNNN | Conversation threads |
| 7 | comms.messages | MSG-NNNNNNNN | Messages |
| 8 | comms.calls | CALL-NNNNNNNN | Voice calls |
| 9 | comms.thread_participants | UUID | Thread participants |
| 10 | comms.message_recipients | UUID | Message recipients |
| 11 | comms.message_templates | UUID | Message-template junction |
| 12 | comms.call_participants | UUID | Call participants |

## Concierge Schema (24 tables) - COMPLETE INVENTORY

**Purpose:** AI-driven guest experience system powering pre-arrival surveys, interest/limitation tracking, venue recommendations, itinerary generation, and activity booking.

### Venue Tables (8 tables)
| # | Table | Business ID | Purpose | Key FKs |
|---|-------|-------------|---------|---------|
| 1 | concierge.beaches | BCH-NNNN | Beach locations with amenities/conditions | → geo.areas |
| 2 | concierge.hikes | HIK-NNNN | Hiking trails with difficulty levels | → geo.areas |
| 3 | concierge.activities | ACT-NNNNNN | Bookable activities and tours | → geo.areas, → ops.companies |
| 4 | concierge.restaurants | RST-NNNNNN | Restaurant recommendations | → geo.areas |
| 5 | concierge.attractions | ATT-NNNN | Points of interest (museums, gardens) | → geo.areas |
| 6 | concierge.shops | SHP-NNNN | Individual shop recommendations | → geo.areas, → shopping_locations |
| 7 | concierge.shopping_locations | SLOC-NNNN | Shopping centers and districts | → geo.areas |
| 8 | concierge.experience_spots | EXP-NNNN | Sunset spots, viewpoints, photo locations | → geo.areas |

### Service Tables (3 tables)
| # | Table | Business ID | Purpose | Key FKs |
|---|-------|-------------|---------|---------|
| 9 | concierge.services | SVC-NNNNNN | Bookable services (spa, chef, photo) | → ops.companies, → service_categories |
| 10 | concierge.service_categories | UUID | Service category codes (SPA, CHEF) | — |
| 11 | concierge.add_ons | UUID | Add-on options for services | → services [CASCADE] |

### Guest Profile Tables (4 tables)
| # | Table | Business ID | Purpose | Key FKs |
|---|-------|-------------|---------|---------|
| 12 | concierge.guest_travel_profiles | UUID | Extended guest profiles for personalization | → ops.guests [CASCADE], → ref.* |
| 13 | concierge.guest_interests | UUID | Guest interest selections with preference levels | → ops.guests [CASCADE], → ref.interest_types |
| 14 | concierge.guest_limitations | UUID | Guest limitations with severity levels | → ops.guests [CASCADE], → ref.limitation_types |
| 15 | concierge.guest_surveys | SRV-NNNNNN | Pre-arrival survey instances | → ops.reservations [CASCADE], → ops.guests |

### Survey & Itinerary Tables (7 tables)
| # | Table | Business ID | Purpose | Key FKs |
|---|-------|-------------|---------|---------|
| 16 | concierge.survey_responses | UUID | Individual survey question responses | → guest_surveys [CASCADE] |
| 17 | concierge.itinerary_themes | THM-NNNN | Predefined theme templates | → ref.activity_levels, → ref.budget_levels |
| 18 | concierge.theme_interest_weights | UUID | Interest weighting for theme matching | → itinerary_themes [CASCADE] |
| 19 | concierge.theme_limitations_excluded | UUID | Limitations that exclude a theme | → itinerary_themes [CASCADE] |
| 20 | concierge.itineraries | ITN-NNNNNN | AI-generated itineraries for guests | → ops.reservations [CASCADE], → itinerary_themes |
| 21 | concierge.itinerary_days | UUID | Days within an itinerary | → itineraries [CASCADE] |
| 22 | concierge.itinerary_items | UUID | Items/activities within each day | → itinerary_days [CASCADE] |

### Booking Tables (2 tables)
| # | Table | Business ID | Purpose | Key FKs |
|---|-------|-------------|---------|---------|
| 23 | concierge.bookings | BKG-NNNNNN | Activity/service/restaurant bookings | → ops.reservations [CASCADE], → activities |
| 24 | concierge.booking_confirmations | UUID | Confirmation communications | → bookings [CASCADE] |

## Directory Schema (2 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | directory.contacts | CON-{TYPE}-NNNNNN | Central contact repository |
| 2 | directory.companies | CMP-NNNNNN | Company registry |

## External Schema (6 tables) - COMPLETE INVENTORY

**Purpose:** Market intelligence system tracking ALL properties in the market (managed or not), keyed by TMK (Tax Map Key). Powers hot lead detection, competitor analysis, and acquisition pipeline.

| # | Table | Business ID | Purpose | Key Features |
|---|-------|-------------|---------|--------------|
| 1 | external.properties | TMK (county) | Master property registry | 3-dimensional status (rental/ownership/our), hot lead flags |
| 2 | external.property_managers | EXT-MGR-NNNNNN | PM history tracking | ended_at triggers HOT LEAD |
| 3 | external.property_sales | EXT-SALE-NNNNNN | County sale records | Recent sale = HOT LEAD trigger |
| 4 | external.property_reviews | EXT-REV-NNNNNN | Scraped OTA reviews | sentiment, pain_points[], opportunity_score |
| 5 | external.property_pricing | EXT-PRC-NNNNNN | Competitor pricing snapshots | nightly_rate, cleaning_fee, availability |
| 6 | external.competitive_sets | UUID (junction) | Our properties vs competitors | similarity_score, competition_level |

### Hot Lead Detection Logic
- **Recent Sale**: `last_sale_date` within 12 months → `is_hot_lead = TRUE`
- **Manager Change**: `property_managers.ended_at` within 6 months → `is_hot_lead = TRUE`

## Homeowner Acquisition Schema (11 tables) - NEW

**Purpose:** Full acquisition pipeline from lead detection through contract signing and onboarding. Tracks prospects, proposals, contracts, and revenue projections.

| # | Table | Business ID | Purpose | Key FKs |
|---|-------|-------------|---------|---------|
| 1 | homeowner_acquisition.prospects | HOP-NNNNNN | Lead/prospect persons/entities | → directory.contacts, → lead_sources |
| 2 | homeowner_acquisition.prospect_properties | HOPP-NNNNNN | Properties in acquisition pipeline | → prospects, → external.properties (TMK) |
| 3 | homeowner_acquisition.lead_sources | {CODE} | Reference: REFERRAL, COUNTY_SALE, etc. | — (reference table) |
| 4 | homeowner_acquisition.lead_activities | HOPA-NNNNNN | Call/email/meeting activity log | → prospects, → team_directory |
| 5 | homeowner_acquisition.proposals | PROP-NNNNNN | Management proposals sent | → prospects, → prospect_properties |
| 6 | homeowner_acquisition.proposal_versions | v{N} | Proposal version history | → proposals [CASCADE] |
| 7 | homeowner_acquisition.contracts | CONT-NNNNNN | Signed management contracts | → prospects, → proposals, DocuSign |
| 8 | homeowner_acquisition.onboarding_tasks | TASK-NNN | Onboarding task templates | — (reference table) |
| 9 | homeowner_acquisition.onboarding_progress | UUID (junction) | Task completion tracking | → prospects, → onboarding_tasks |
| 10 | homeowner_acquisition.property_assessments | ASMT-NNNNNN | Property condition assessments | → prospect_properties [CASCADE] |
| 11 | homeowner_acquisition.revenue_projections | PROJ-NNNNNN | Revenue forecasts for prospects | → prospect_properties [CASCADE] |

### Pipeline Status Flow
```
prospects.status: new → contacted → qualified → proposal_sent → negotiating → won/lost
prospect_properties.status: identified → evaluating → proposed → negotiating → won/lost
external.properties.our_status: watching → target → in_pursuit → proposal_sent → converted/declined/lost
```

## Finance Schema (12 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | finance.trust_accounts | TRUST-NNNNNN | Trust accounts |
| 2 | finance.trust_transactions | TTXN-NNNNNN | Trust transactions |
| 3 | finance.owner_statements | STMT-NNNNNN | Owner statements |
| 4 | finance.statement_line_items | UUID | Statement details |
| 5 | finance.invoices | INV-NNNNNN | Invoices |
| 6 | finance.invoice_items | UUID | Invoice details |
| 7 | finance.payments | PMT-NNNNNN | Payments |
| 8 | finance.payables | PAY-NNNNNN | Accounts payable |
| 9 | finance.tax_records | TAX-NNNNNN | Tax records |
| 10 | finance.reconciliations | REC-NNNNNN | Bank reconciliations |
| 11 | finance.reserve_accounts | RES-NNNNNN | Reserve accounts |
| 12 | finance.reserve_transactions | RTXN-NNNNNN | Reserve transactions |

## Geo Schema (5 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | geo.zones | ZN-NNNN | Top-level regions |
| 2 | geo.cities | CTY-NNNN | Cities within zones |
| 3 | geo.areas | AREA-NNNN | Property location areas |
| 4 | geo.neighborhoods | NBH-NNNNN | Sub-areas |
| 5 | geo.points_of_interest | POI-NNNNNN | POIs for concierge |

## Knowledge Schema (15+ tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | knowledge.departments | DEPT-NN | Knowledge departments |
| 2 | knowledge.sections | SEC-{dept}-NNN | Department sections |
| 3 | knowledge.master_library_assets | MLA-{type}-NNNNNN | SOPs, guides, templates |
| 4 | knowledge.asset_versions | UUID | Asset versioning |
| 5 | knowledge.asset_steps | UUID | Step-by-step content |
| 6 | knowledge.documents | DOC-{type}-NNNNNN | Document storage |
| 7 | knowledge.document_entity_links | UUID | Document links |
| 8 | knowledge.document_impacts | UUID | Document impact tracking |
| 9 | knowledge.embeddings | EMB-NNNNNN | Vector embeddings |
| 10 | knowledge.embedding_chunks | UUID | Chunked embeddings |
| 11 | knowledge.search_logs | UUID | Search analytics |
| 12 | knowledge.property_guides | PGD-{property} | Property guidebooks |
| 13 | knowledge.property_guide_sections | UUID | Guidebook sections |

## Marketing Schema (22 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | marketing.content | CON-NNNNNN | All content pieces |
| 2 | marketing.content_versions | UUID | Content versioning |
| 3 | marketing.content_library | ASSET-NNNNNN | Media assets |
| 4 | marketing.property_content | UUID | Property-asset junction |
| 5 | marketing.content_strategy | STRAT-NNNNNN | Content strategies |
| 6 | marketing.content_calendars | CAL-NNNNNN | Content calendars |
| 7 | marketing.calendar_items | UUID | Calendar entries |
| 8 | marketing.campaigns | CMP-NNNNNN | Marketing campaigns |
| 9 | marketing.campaign_events | CEVT-NNNNNN | Campaign events |
| 10 | marketing.segments | SEG-NNNNNN | Audience segments |
| 11 | marketing.segment_members | UUID | Segment membership |
| 12 | marketing.social_accounts | SA-NNNNNN | Social accounts |
| 13 | marketing.social_posts | SP-NNNNNN | Social posts |
| 14 | marketing.social_analytics | UUID | Post analytics |
| 15 | marketing.social_account_metrics | UUID | Account metrics |
| 16 | marketing.websites | WEB-NNNNNN | Websites |
| 17 | marketing.website_pages | UUID | Website pages |
| 18 | marketing.attribution | UUID | Booking attribution |

## Ops Schema (60+ tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | ops.properties | PRP-NNNN | Properties |
| 2 | ops.resorts | RST-NNNN | Resort complexes |
| 3 | ops.rooms | RM-{PROP}-NNN | Property rooms |
| 4 | ops.beds | BED-{PROP}-NNN | Room beds |
| 5 | ops.appliances | APPL-{PROP}-NNN | Room appliances |
| 6 | ops.appliance_parts | APRT-{PROP}-NNNN | Appliance parts |
| 7 | ops.fixtures | FXTR-{PROP}-NNN | Room fixtures |
| 8 | ops.surfaces | SURF-{PROP}-NNN | Room surfaces |
| 9 | ops.lighting | LGHT-{PROP}-NNN | Room lighting |
| 10 | ops.window_coverings | WCVR-{PROP}-NNN | Window coverings |
| 11 | ops.room_features | RMFT-{PROP}-NNN | Room features |
| 12 | ops.ac_systems | ACST-{PROP}-NN | AC systems |
| 13 | ops.ac_units | ACU-{PROP}-NNN | AC units |
| 14 | ops.property_doors | DOOR-{PROP}-NN | Property doors |
| 15 | ops.property_locks | LOCK-{PROP}-NNN | Door locks |
| 16 | ops.key_checkouts | KEYC-{PROP}-NNNN | Key management |
| 17 | ops.property_fees | FEE-{PROP}-NN | Property fees |
| 18 | ops.safety_items | SAFE-{PROP}-NNN | Safety equipment |
| 19 | ops.property_amenities | AMTY-{PROP}-NNN | Property amenities |
| 20 | ops.property_rules | RULE-{PROP}-NN | House rules |
| 21 | ops.property_access_codes | PACC-{PROP}-NN | Access codes |
| 22 | ops.vendor_assignments | VASS-{PROP}-NN | Vendor assignments |
| 23 | ops.guests | GST-NNNNNN | Guest profiles |
| 24 | ops.homeowners | OWN-NNNNNN | Homeowner profiles |
| 25 | ops.reservations | RSV-{CO}-NNNNNN | Reservations |
| 26 | ops.homeowner_properties | UUID | Owner-property junction |
| 27 | ops.reservation_guests | UUID | Multi-guest reservations |
| 28 | ops.resort_contacts | UUID | Resort contacts |
| 29 | ops.property_vendors | UUID | Property vendors |
| 30 | ops.teams | TM-NNNNNN | Teams |
| 31 | ops.team_directory | TMD-NNNNNN | Team members |
| 32 | ops.team_shifts | SHF-NNNNNN | Work shifts |
| 33 | ops.shift_swaps | SWP-NNNNNN | Shift swaps |
| 34 | ops.shift_coverage_requests | COV-NNNNNN | Coverage requests |
| 35 | ops.timesheets | TS-NNNNNN | Timesheets |
| 36 | ops.time_entries | TIME-NNNNNN | Time entries |
| 37 | ops.cleans | CLN-NNNNNN | Cleaning events |
| 38 | ops.inspections | INS-NNNNNN | Inspection events |
| 39 | ops.inspection_questions | INSPQ-{cat}-NNNN | Inspection checklist |
| 40 | ops.inspection_room_questions | UUID | Room-question junction |
| 41 | ops.inspection_question_inventory_links | UUID | Question-inventory links |
| 42 | ops.inspection_issues | ISS-{insp}-NNN | Inspection issues |
| 43 | ops.inspection_photos | PHOTO-{insp}-NNN | Inspection photos |
| 44 | ops.inspection_room_scores | UUID | Room scores |
| 45 | ops.inventory_items | ITEM-{type}-NNNN | Inventory items |
| 46 | ops.room_inventory | UUID | Room inventory |
| 47 | ops.owner_inventory | UUID | Owner inventory |
| 48 | ops.company_inventory | UUID | Company inventory |
| 49 | ops.storage_inventory | UUID | Storage inventory |
| 50 | ops.storage_locations | UUID | Storage locations |
| 51 | ops.inventory_purchases | PO-NNNNNN | Purchase orders |
| 52 | ops.inventory_actions | INVACT-{type}-NNNNNN | Inventory actions |
| 53 | ops.property_care_tickets | TKT-PC-NNNNNN | Property care tickets |
| 54 | ops.reservation_tickets | TKT-RSV-NNNNNN | Reservation tickets |
| 55 | ops.admin_tickets | TKT-ADM-NNNNNN | Admin tickets |
| 56 | ops.accounting_tickets | TKT-ACCT-NNNNNN | Accounting tickets |
| 57 | ops.damage_claims | CLM-{type}-NNNNNN | Damage claims |
| 58 | ops.damage_claim_appeals | APL-{claim}-NN | Claim appeals |
| 59 | ops.form_submissions | FORM-{src}-NNNNNN | Form submissions |
| 60 | ops.missed_services | MISS-{type}-NNNNNN | Missed services |
| 61 | ops.missed_due_dates | MDD-NNNNNN | Missed due dates |
| 62 | ops.recurring_tasks | RCT-NNNNNN | Recurring tasks |
| 63 | ops.recurring_task_instances | RCTI-NNNNNN | Task instances |
| 64 | ops.guest_journeys | JRN-NNNNNN | Guest journeys |
| 65 | ops.guest_journey_touchpoints | TP-NNNNNN | Journey touchpoints |
| 66 | ops.reviews | REV-NNNNNN | Guest reviews |
| 67 | ops.reservation_fees | UUID | Reservation fees |

## Portal Schema (6 tables) - COMPLETE INVENTORY

**Purpose:** Portal access and authentication system. Supports multiple user types (guest, homeowner, team, admin) with RBAC permissions.

| # | Table | Business ID | Purpose | Key Columns |
|---|-------|-------------|---------|-------------|
| 1 | portal.users | USR-NNNNNN | Master user accounts | email, password_hash, user_type, status, mfa_enabled |
| 2 | portal.sessions | UUID | Active/historical sessions | session_token, refresh_token, expires_at, device_type |
| 3 | portal.roles | role_code | Role definitions | role_code (GUEST, HOMEOWNER, TEAM_MEMBER, etc.), is_system_role |
| 4 | portal.permissions | UUID | Role permissions | resource, action (CRUD), scope (own/team/all) |
| 5 | portal.user_roles | UUID | User-role junction | granted_by, granted_at, expires_at, is_active |
| 6 | portal.preferences | UUID | User preferences | preference_key, preference_value, preference_type |

### System Roles
- GUEST - Basic access for vacation renters (own reservations)
- HOMEOWNER - Property owner access (own properties, statements)
- TEAM_MEMBER - Staff access (assigned tasks, properties)
- TEAM_LEAD - Supervisory access (task assignment, time approval)
- MANAGER - Department access (financial reports, owner comms)
- ADMIN - Administrative access (user management)
- SUPER_ADMIN - Full system access (system configuration)

## Pricing Schema (12 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | pricing.base_rates | BRT-NNNNNN | Base pricing rates |
| 2 | pricing.listing_performance_snapshots | UUID | Performance snapshots |
| 3 | pricing.seasonal_adjustments | SEA-NNNNNN | Seasonal pricing |
| 4 | pricing.market_events | EVT-NNNNNN | Market events |
| 5 | pricing.competitor_rates | CMP-NNNNNN | Competitor rates |
| 6 | pricing.dynamic_adjustments | DYN-NNNNNN | Dynamic pricing |
| 7 | pricing.rate_history | RTH-NNNNNN | Rate history |
| 8 | pricing.guest_value_intelligence | GVI-NNNNNN | Guest value scoring |
| 9 | pricing.segment_pricing_insights | SPI-NNNNNN | Segment insights |
| 10 | pricing.website_sessions | WSS-NNNNNN | Website sessions |
| 11 | pricing.rate_impressions | IMP-NNNNNN | Rate impressions |
| 12 | pricing.pricing_experiments | EXP-NNNNNN | A/B testing |

## Property Listings Schema (13 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | property_listings.listing_content | LC-NNNNNN | Listing content |
| 2 | property_listings.listing_content_versions | UUID | Content versions |
| 3 | property_listings.listing_photos | LPH-NNNNNN | Listing photos |
| 4 | property_listings.listing_photo_tags | UUID | Photo tags |
| 5 | property_listings.channel_listings | CL-NNNNNN | OTA listings |
| 6 | property_listings.channel_sync_log | UUID | Sync history |
| 7 | property_listings.performance_metrics | UUID | Listing metrics |
| 8 | property_listings.search_rankings | UUID | Search rankings |
| 9 | property_listings.competitor_sets | CSET-NNNNNN | Competitor sets |
| 10 | property_listings.competitor_listings | COMP-NNNNNN | Competitor listings |
| 11 | property_listings.listing_audits | AUD-NNNNNN | Listing audits |
| 12 | property_listings.ref_listing_audit_checklist | UUID | Audit checklist |
| 13 | property_listings.ref_content_types | UUID | Content types |

## Ref Schema (40+ tables) - Lookup/Reference Tables

### Fee & Finance Reference
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | ref.fee_types | UUID | Fee type reference |
| 2 | ref.property_fees | UUID | Property fee rates |
| 3 | ref.resort_fees | UUID | Resort fee rates |
| 4 | ref.reservation_type_fees | UUID | Reservation type fees |
| 5 | ref.fee_rate_history | UUID | Fee rate history |
| 6 | ref.qbo_classes | UUID | QuickBooks classes |
| 7 | ref.qbo_products | UUID | QuickBooks products |
| 8 | ref.qbo_accounts | UUID | QuickBooks accounts |
| 9 | ref.tax_jurisdictions | UUID | Tax jurisdictions |

### Inventory & Operations Reference
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 10 | ref.inventory_item_types | UUID | Inventory types |
| 11 | ref.journey_stages | UUID | Journey stages |
| 12 | ref.touchpoint_types | UUID | Touchpoint types |
| 13 | ref.stage_required_touchpoints | UUID | Stage-touchpoint junction |
| 14 | ref.timesheet_type_key | UUID | Timesheet types |
| 15 | ref.recurring_task_type_key | UUID | Recurring task types |

### Damage & Claims Reference
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 16 | ref.damage_claim_status_type_key | UUID | Claim statuses |
| 17 | ref.damage_claim_type_key | UUID | Claim types |
| 18 | ref.damage_category_key | UUID | Damage categories |

### Knowledge & Content Reference
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 19 | ref.time_activity_type_key | UUID | Time activity types |
| 20 | ref.master_library_asset_type_key | UUID | Asset types |
| 21 | ref.document_type_key | UUID | Document types |
| 22 | ref.communication_type_key | UUID | Communication types |
| 23 | ref.document_source_type_key | UUID | Document sources |
| 24 | ref.content_status_type_key | UUID | Content statuses |
| 25 | ref.audience_type_key | UUID | Audience types |

### Pricing Reference
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 26 | ref.season_types | UUID | Season types |
| 27 | ref.adjustment_types | UUID | Adjustment types |
| 28 | ref.guest_segments | UUID | Guest segments |
| 29 | ref.price_sensitivity_levels | UUID | Price sensitivity |
| 30 | ref.booking_channels | UUID | Booking channels |
| 31 | ref.competitor_types | UUID | Competitor types |

### Concierge Reference (NEW - from Concierge Inventory)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 32 | ref.activity_levels | UUID | Activity intensity (relaxed → adventurous) |
| 33 | ref.budget_levels | UUID | Budget preferences (budget → luxury) |
| 34 | ref.schedule_density_levels | UUID | Pace preferences (relaxed → packed) |
| 35 | ref.driving_tolerance_levels | UUID | Willingness to drive distances |
| 36 | ref.interest_types | UUID | Interest categories (beaches, hiking, dining) |
| 37 | ref.interest_categories | UUID | Higher-level interest groupings |
| 38 | ref.limitation_types | UUID | Guest limitations (mobility, dietary, allergies) |

## Secure Schema (2 tables)
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | secure.users | USR-NNNNNN | System users |
| 2 | secure.contact_entities | UUID | Contact-entity links |

## Service Schema (30 tables) - NEW
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | service.tickets | TIK-{TYPE}-NNNNNN | Unified tickets |
| 2 | service.ticket_time_entries | UUID | Ticket time allocation |
| 3 | service.inspection_time_entries | UUID | Inspection time allocation |
| 4 | service.ticket_properties | UUID | Ticket-property links |
| 5 | service.ticket_reservations | UUID | Ticket-reservation links |
| 6 | service.ticket_homeowners | UUID | Ticket-homeowner links |
| 7 | service.ticket_relationships | UUID | Related tickets |
| 8 | service.ticket_shifts | UUID | Ticket-shift assignments |
| 9 | service.ticket_contacts | UUID | Ticket contacts |
| 10 | service.ticket_vendors | UUID | Ticket vendors |
| 11 | service.ticket_misses | UUID | Missed service tracking |
| 12 | service.ticket_costs | UUID | Cost allocation |
| 13 | service.ticket_purchases | UUID | Purchase tracking |
| 14 | service.ticket_events | EVT-NNNNNNNN | Activity log |
| 15 | service.ticket_labels | UUID | Ticket labels |
| 16 | service.ticket_inspections | UUID | Inspection links |
| 17 | service.ticket_cleans | UUID | Clean links |
| 18 | service.ticket_inventory_events | UUID | Inventory links |
| 19 | service.ticket_recurring | UUID | Recurring task links |
| 20 | service.ticket_transactions | UUID | Finance links |
| 21 | service.projects | PRJ-NNNNNN | Projects |
| 22 | service.project_properties | UUID | Project properties |
| 23 | service.project_tickets | UUID | Project tickets |
| 24 | service.ticket_damage | UUID | Damage flags |
| 25 | service.ticket_claims | UUID | Ticket-claim links |
| 26 | service.damage_claims | CLM-NNNNNN | Damage claims |
| 27 | service.damage_claim_submissions | SUB-{claim}-NN | Claim submissions |
| 28 | service.damage_claim_approvals | APV-{sub}-NN | Claim approvals |
| 29 | service.damage_claim_denials | DNL-{sub}-NN | Claim denials |
| 30 | service.damage_claim_appeals | APL-{sub}-NN | Claim appeals |

## Storage Schema (4 tables) - NEW
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | storage.files | FILE-NNNNNNNN | Central file registry |
| 2 | storage.ticket_files | UUID | Ticket-file links |
| 3 | storage.inspection_files | UUID | Inspection-file links |
| 4 | storage.room_files | UUID | Room-file links |

## Team Schema (6 tables) - NEW
| # | Table | Business ID | Purpose |
|---|-------|-------------|---------|
| 1 | team.teams | TEAM-NNNN | Team definitions |
| 2 | team.team_directory | MBR-NNNNNN | Team members |
| 3 | team.shifts | SHFT-NNNNNN | Shift scheduling |
| 4 | team.time_entries | TIME-NNNNNNNN | Time tracking |
| 5 | team.time_entry_verifications | UUID | Time verification |
| 6 | team.shift_time_entries | UUID | Shift-time allocation |

---

# DETAILED TABLE SPECIFICATIONS

## 1. AI Schema Tables

### ai.models

**PURPOSE:** Model registry storing all AI models with capabilities and pricing.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| model_id | text | NOT NULL, UNIQUE | Business ID: MDL-NNNN |
| provider | text | NOT NULL | Provider: anthropic, openai, google, local |
| model_name | text | NOT NULL, UNIQUE | Full model name (claude-sonnet-4-20250514) |
| display_name | text | | Friendly name (Claude Sonnet 4) |
| context_window | integer | | Maximum context window tokens |
| max_output_tokens | integer | | Maximum output tokens |
| supports_tools | boolean | DEFAULT true | Supports function calling |
| supports_vision | boolean | DEFAULT false | Supports image input |
| supports_streaming | boolean | DEFAULT true | Supports streaming output |
| input_cost_per_mtok | numeric(10,4) | | Cost per 1M input tokens (USD) |
| output_cost_per_mtok | numeric(10,4) | | Cost per 1M output tokens (USD) |
| is_active | boolean | DEFAULT true | Available for use |
| notes | text | | Model notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### ai.agents

**PURPOSE:** Agent registry for all AI agents (CAPRI, SCOUT, etc.).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| agent_id | text | NOT NULL, UNIQUE | Business ID: AGT-NNNN |
| agent_code | text | NOT NULL, UNIQUE | Agent code (CAPRI, SCOUT) |
| agent_name | text | NOT NULL | Display name |
| agent_description | text | | Agent description |
| default_model_id | uuid | FK → ai.models | Default model |
| system_prompt_id | uuid | FK → ai.prompts | System prompt |
| temperature | numeric(3,2) | DEFAULT 0.7 | Default temperature |
| max_tokens | integer | DEFAULT 4096 | Default max tokens |
| is_active | boolean | DEFAULT true | Active flag |
| version | text | | Agent version |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### ai.conversation_logs

**PURPOSE:** Tracks all AI conversations with context and metadata.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| conversation_id | text | NOT NULL, UNIQUE | Business ID: CONV-NNNNNNNN |
| agent_id | uuid | FK → ai.agents, NOT NULL | Agent handling conversation |
| contact_id | uuid | FK → directory.contacts | Contact involved |
| reservation_id | uuid | FK → ops.reservations | Reservation context |
| property_id | uuid | FK → ops.properties | Property context |
| channel | text | | chat, sms, email, voice |
| started_at | timestamptz | DEFAULT now() | Conversation start |
| ended_at | timestamptz | | Conversation end |
| status | text | DEFAULT 'active' | active, completed, abandoned, handed_off |
| handoff_to_human | boolean | DEFAULT false | Was handed off |
| handoff_reason | text | | Why handed off |
| satisfaction_score | integer | | 1-5 satisfaction rating |
| total_messages | integer | DEFAULT 0 | Message count |
| total_tokens_used | integer | | Total tokens consumed |
| total_cost | numeric(10,4) | | Total cost |
| metadata | jsonb | | Additional metadata |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

## 2. Brand Schema Tables

### brand.brand_guidelines

**PURPOSE:** Master brand standards including voice, naming, and style rules.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | Internal UUID |
| guideline_id | text | NOT NULL, UNIQUE | Business ID: BG-NNNNNN |
| title | text | NOT NULL | Guideline title |
| category | text | NOT NULL | mission, values, positioning, voice, visual, naming, response |
| content | text | | Guideline content |
| tone_attributes | text[] | | warm, professional, knowledgeable, approachable |
| personality_traits | text[] | | Brand personality words |
| do_examples | text[] | | Good examples |
| dont_examples | text[] | | What to avoid |
| key_phrases | text[] | | Signature phrases |
| words_to_use | text[] | | Preferred vocabulary |
| words_to_avoid | text[] | | Words to never use |
| sample_copy | text | | Example paragraph |
| naming_pattern | text | | Pattern: "{Location} {Feature} {Type}" |
| naming_examples | text[] | | "Kapalua Bay Oceanfront Retreat" |
| naming_rules | text | | Rules for property naming |
| response_context | text | | guest_complaint, inquiry, review_positive, review_negative |
| response_timeframe | text | | "Within 4 hours", "Same day" |
| response_template | text | | Template for this response type |
| version | text | | Version number |
| status | text | DEFAULT 'active' | active, archived |
| effective_date | date | | When effective |
| approved_by | text | | Approver |
| file_url | text | | PDF/document URL |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

## 3. Geo Schema Tables

### geo.zones

**PURPOSE:** Top-level geographic regions (islands, states, metros).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| zone_id | text | NOT NULL, UNIQUE | Business ID: ZN-NNNN |
| zone_code | text | NOT NULL, UNIQUE | Short code (MAUI, TN, SLC) |
| zone_name | text | NOT NULL | Display name |
| zone_type | text | NOT NULL | island, state, metro |
| country | text | DEFAULT 'USA' | Country code |
| timezone | text | NOT NULL | Timezone (Pacific/Honolulu) |
| latitude | numeric(10,7) | | Center latitude |
| longitude | numeric(10,7) | | Center longitude |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### geo.areas

**PURPOSE:** Primary property location reference. Properties are assigned to areas.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| area_id | text | NOT NULL, UNIQUE | Business ID: AREA-NNNN |
| city_id | uuid | FK → geo.cities, NOT NULL | Parent city |
| area_code | text | NOT NULL, UNIQUE | Short code |
| area_name | text | NOT NULL | Display name |
| area_type | text | | beach, town, resort, upcountry |
| description | text | | Area description |
| latitude | numeric(10,7) | | Center latitude |
| longitude | numeric(10,7) | | Center longitude |
| highlights | text[] | | ["Sunset views", "Walking beaches"] |
| best_for | text[] | | ["Families", "Romance", "Adventure"] |
| drive_to_airport_minutes | integer | | Airport proximity |
| walkability_score | integer | | 1-10 walkability |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### geo.points_of_interest

**PURPOSE:** Concierge POIs including beaches, restaurants, activities.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| poi_id | text | NOT NULL, UNIQUE | Business ID: POI-NNNNNN |
| area_id | uuid | FK → geo.areas, NOT NULL | Area containing POI |
| neighborhood_id | uuid | FK → geo.neighborhoods | Optional neighborhood |
| poi_name | text | NOT NULL | POI name |
| poi_type | text | NOT NULL | beach, restaurant, activity, attraction, shop, service |
| poi_category | text | | Category within type |
| description | text | | Full description |
| address | text | | Street address |
| latitude | numeric(10,7) | | Latitude |
| longitude | numeric(10,7) | | Longitude |
| phone | text | | Phone number |
| website | text | | Website URL |
| google_place_id | text | | Google Places ID |
| hours | jsonb | | Operating hours |
| price_range | text | | $, $$, $$$, $$$$ |
| cost_level | integer | | 1-5 cost level |
| rating | numeric(2,1) | | Average rating |
| review_count | integer | | Number of reviews |
| highlights | text[] | | Key highlights |
| cuisines | text[] | | For restaurants |
| is_family_friendly | boolean | DEFAULT true | Family appropriate |
| is_romantic | boolean | DEFAULT false | Romantic setting |
| is_accessible | boolean | | Wheelchair accessible |
| is_ai_visible | boolean | DEFAULT true | Show to AI concierge |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

## 4. Finance Schema Tables

### finance.trust_accounts

**PURPOSE:** Trust bank accounts holding guest/owner funds.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| trust_account_id | text | NOT NULL, UNIQUE | Business ID: TRUST-NNNNNN |
| account_name | text | NOT NULL | Account display name |
| account_number | text | NOT NULL, UNIQUE | Bank account number |
| bank_name | text | | Bank name |
| routing_number | text | | Bank routing number |
| account_type | text | NOT NULL | operating, security_deposit, reserve |
| qbo_account_id | text | FK → ref.qbo_accounts | QuickBooks mapping |
| current_balance | numeric(12,2) | DEFAULT 0 | Current balance |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### finance.owner_statements

**PURPOSE:** Monthly owner statements with line items.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| statement_id | text | NOT NULL, UNIQUE | Business ID: STMT-NNNNNN |
| homeowner_id | uuid | FK → ops.homeowners, NOT NULL | Homeowner |
| property_id | uuid | FK → ops.properties, NOT NULL | Property |
| trust_account_id | uuid | FK → finance.trust_accounts | Trust account |
| statement_period_start | date | NOT NULL | Period start |
| statement_period_end | date | NOT NULL | Period end |
| opening_balance | numeric(12,2) | DEFAULT 0 | Opening balance |
| total_revenue | numeric(12,2) | DEFAULT 0 | Gross revenue |
| total_expenses | numeric(12,2) | DEFAULT 0 | Total expenses |
| management_fee | numeric(12,2) | DEFAULT 0 | Management fee |
| net_to_owner | numeric(12,2) | DEFAULT 0 | Net payout |
| closing_balance | numeric(12,2) | DEFAULT 0 | Closing balance |
| status | text | DEFAULT 'draft' | draft, pending_approval, approved, sent |
| sent_at | timestamptz | | When sent to owner |
| qbo_invoice_id | text | | QuickBooks invoice ID |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

**UNIQUE CONSTRAINT:** (homeowner_id, property_id, statement_period_start)

---

## 5. Service Schema Tables (NEW)

### service.tickets

**PURPOSE:** Unified ticket table for all ticket types (PC, RSV, ADM, ACCT).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| ticket_id | text | NOT NULL, UNIQUE | Business ID: TIK-{TYPE}-NNNNNN |
| ticket_type_code | text | NOT NULL | PC, RSV, ADM, ACCT |
| category_code | text | | Compound: PC-PLUMBING, RSV-LATE_CHECKOUT |
| title | text | NOT NULL | Ticket title |
| description | text | | Main description |
| work_notes | text | | Internal work notes |
| guest_comments | text | | Guest-facing comments |
| status | text | DEFAULT 'OPEN' | OPEN, IN_PROGRESS, ON_HOLD, RESOLVED, CANCELLED |
| priority | text | DEFAULT 'MEDIUM' | LOW, MEDIUM, HIGH, CRITICAL |
| source | text | | OWNER, GUEST, INTERNAL, SYSTEM, INSPECTION |
| property_id | uuid | FK → property.properties | Primary property |
| reservation_id | uuid | FK → reservations.reservations | Reservation context |
| homeowner_id | uuid | FK → property.homeowners | Property owner |
| requestor_contact_id | uuid | FK → directory.contacts | Who requested |
| current_agent_id | uuid | FK → team.team_directory | Current assignee |
| current_team_id | uuid | FK → team.teams | Assigned team |
| scheduled_date | date | | When work should happen |
| first_response_at | timestamptz | | First response time |
| started_at | timestamptz | | When work began |
| resolved_at | timestamptz | | When resolved |
| is_archived | boolean | DEFAULT false | Soft delete |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### service.damage_claims

**PURPOSE:** Damage claim lifecycle tracking with full recovery workflow.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| claim_id | text | NOT NULL, UNIQUE | Business ID: CLM-NNNNNN |
| ticket_id | uuid | FK → service.tickets | Origin ticket |
| reservation_id | uuid | FK → reservations.reservations | Related reservation |
| damage_category_code | text | FK → ref.damage_category_key | Damage category |
| incident_date | date | | When damage occurred |
| discovery_source | text | | INSPECTION, CLEAN, GUEST, OWNER, SYSTEM |
| status_code | text | DEFAULT 'OPEN' | OPEN, SUBMITTED, PARTIAL, CLOSED, DENIED |
| priority | text | DEFAULT 'MEDIUM' | LOW, MEDIUM, HIGH, URGENT |
| claim_name | text | NOT NULL | Short description |
| description | text | | Detailed description |
| work_notes | text | | Internal notes |
| discovered_by_id | uuid | FK → team.team_directory | Who found damage |
| claim_owner_id | uuid | FK → team.team_directory | Managing claim |
| total_damage_cost | numeric(10,2) | | Full cost of damage |
| total_recovered | numeric(10,2) | DEFAULT 0 | Sum of recoveries |
| total_denied | numeric(10,2) | DEFAULT 0 | Sum of denials |
| outstanding | numeric(10,2) | | Amount still owed |
| responsible_party | text | | GUEST, OWNER, COMPANY, OTA, INSURER, MIXED, WRITTEN_OFF |
| homeowner_charged | boolean | DEFAULT false | Owner charged? |
| homeowner_charge_date | date | | When charged |
| homeowner_charge_amount | numeric(10,2) | | Amount charged |
| discovery_date | date | | When found |
| resolved_at | timestamptz | | When resolved |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

## 6. Team Schema Tables (NEW)

### team.time_entries

**PURPOSE:** Canonical time tracking record for all labor.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| time_entry_id | text | NOT NULL, UNIQUE | Business ID: TIME-NNNNNNNN |
| member_id | uuid | FK → team.team_directory, NOT NULL | Team member |
| property_id | uuid | FK → property.properties | Where work happened |
| work_date | date | NOT NULL | Date of work |
| started_at | timestamptz | NOT NULL | Start time |
| ended_at | timestamptz | | End time |
| duration_seconds | integer | | Total duration |
| activity_type_code | text | FK → ref.activity_types | Activity category |
| hourly_rate | numeric(10,2) | | Rate at time of work |
| labor_cost | numeric(10,2) | | Calculated cost |
| is_billable | boolean | DEFAULT true | Billable? |
| billable_to | text | | owner, company, guest |
| timesheet_status | text | DEFAULT 'START' | START, STOP, VERIFY, APPROVED, RECORDED |
| requires_verification | boolean | DEFAULT false | Needs verification? |
| notes | text | | Work notes |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

## 7. Storage Schema Tables (NEW)

### storage.files

**PURPOSE:** Central file registry for all uploads.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| file_id | text | NOT NULL, UNIQUE | Business ID: FILE-NNNNNNNN |
| file_url | text | NOT NULL | S3/Supabase Storage URL |
| thumbnail_url | text | | Smaller version |
| file_type | text | NOT NULL | image, document, video |
| mime_type | text | | image/jpeg, application/pdf |
| file_size_bytes | integer | | File size |
| original_filename | text | | Original name when uploaded |
| property_id | uuid | FK → property.properties | Where taken |
| room_id | uuid | FK → property.rooms | Room context |
| uploaded_by_id | uuid | FK → team.team_directory | Who uploaded |
| uploaded_at | timestamptz | DEFAULT now() | When uploaded |
| created_at | timestamptz | DEFAULT now() | Created |

---

## 8. External Schema Tables (NEW)

### external.properties

**PURPOSE:** Master registry of ALL properties in the market, uniquely keyed by TMK (Tax Map Key). Tracks prospects, competitors, rental pools, and conversion status with three-dimensional status tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| tmk | text | NOT NULL, UNIQUE | Tax Map Key - county property identifier |
| ops_property_id | uuid | FK → ops.properties | Link when managed by us |
| area_id | uuid | FK → geo.areas | Geographic area |
| property_name | text | | Common name or unit |
| street_address | text | | Street address |
| city | text | | City |
| state | text | | State (HI, TN, UT) |
| resort_name | text | | Resort/complex name |
| bedrooms | integer | | Number of bedrooms |
| bathrooms | numeric(3,1) | | Number of bathrooms |
| property_type | text | | condo, house, townhouse, villa |
| view_type | text | | ocean_front, ocean_view, garden, mountain |
| rental_status | text | NOT NULL, DEFAULT 'unknown' | active_str, rental_pool, long_term, owner_occupied, vacant |
| ownership_status | text | NOT NULL, DEFAULT 'stable' | stable, recently_sold, for_sale, pending_sale |
| our_status | text | NOT NULL, DEFAULT 'watching' | watching, target, in_pursuit, proposal_sent, converted |
| is_managed_by_us | boolean | DEFAULT false | In our portfolio? |
| is_prospect | boolean | DEFAULT false | Being pursued? |
| is_competitor | boolean | DEFAULT false | Identified competitor? |
| is_hot_lead | boolean | DEFAULT false | Recent sale OR manager change |
| airbnb_listing_id | text | | Airbnb listing ID |
| airbnb_rating | numeric(2,1) | | Airbnb average rating |
| vrbo_listing_id | text | | VRBO listing ID |
| owner_name | text | | Current owner from county |
| owner_mailing_address | text | | Owner mailing address |
| last_sale_date | date | | Most recent sale date |
| last_sale_price | numeric(12,2) | | Sale price |
| current_manager_name | text | | Current PM if known |
| estimated_annual_revenue | numeric(12,2) | | Estimated gross revenue |
| estimated_adr | numeric(8,2) | | Estimated ADR |
| estimated_occupancy | numeric(5,4) | | Occupancy rate (0.7500 = 75%) |
| data_sources | text[] | | Array: county, airbnb, vrbo, manual |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### external.property_reviews

**PURPOSE:** Scraped reviews from Airbnb/VRBO with AI-powered sentiment analysis and opportunity scoring.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| review_id | text | NOT NULL, UNIQUE | Business ID: EXT-REV-NNNNNN |
| tmk | text | FK → external.properties(tmk), NOT NULL | Property reviewed |
| platform | text | NOT NULL | Source: airbnb, vrbo |
| review_date | date | NOT NULL | When posted |
| rating | integer | | Star rating (1-5) |
| review_text | text | | Full review text |
| reviewer_name | text | | Reviewer name |
| host_response | text | | Manager response |
| sentiment | text | | AI: positive, neutral, negative |
| pain_points | text[] | | AI-extracted: cleanliness, communication, maintenance |
| opportunity_score | integer | | 1-100 (higher = better outreach opportunity) |
| processed_at | timestamptz | | When AI analysis ran |
| created_at | timestamptz | DEFAULT now() | Created |

---

## 9. Homeowner Acquisition Schema Tables (NEW)

### homeowner_acquisition.prospects

**PURPOSE:** Lead/prospect persons being pursued. Links to directory.contacts for unified contact management.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| prospect_id | text | NOT NULL, UNIQUE | Business ID: HOP-NNNNNN |
| contact_id | uuid | FK → directory.contacts, NOT NULL | Unified contact record |
| source_id | uuid | FK → lead_sources | Lead source |
| assigned_to_member_id | uuid | FK → team_directory | Assigned team member |
| status | text | NOT NULL, DEFAULT 'new' | new, contacted, qualified, proposal_sent, negotiating, won, lost |
| priority | text | DEFAULT 'medium' | hot, high, medium, low |
| estimated_close_date | date | | Expected close |
| lost_reason | text | | Why lost |
| first_contact_date | date | | Initial outreach |
| last_contact_date | date | | Most recent contact |
| next_follow_up_date | date | | Scheduled follow-up |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### homeowner_acquisition.prospect_properties

**PURPOSE:** Properties associated with prospects. Links to external.properties via TMK.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| prospect_property_id | text | NOT NULL, UNIQUE | Business ID: HOPP-NNNNNN |
| prospect_id | uuid | FK → prospects, NOT NULL | Parent prospect |
| external_tmk | text | FK → external.properties(tmk) | Property details |
| status | text | NOT NULL, DEFAULT 'identified' | identified, evaluating, proposed, negotiating, won, lost |
| estimated_value | numeric(12,2) | | Property value estimate |
| estimated_annual_revenue | numeric(12,2) | | Projected gross revenue |
| management_fee_proposed | numeric(5,4) | | Proposed fee (0.2000 = 20%) |
| onboarded_property_id | uuid | FK → ops.properties | Link after conversion |
| won_date | date | | When won |
| lost_date | date | | When lost |
| lost_reason | text | | Why lost |
| notes | text | | Deal notes |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### homeowner_acquisition.proposals

**PURPOSE:** Management proposals sent to prospects with terms and projections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| proposal_id | text | NOT NULL, UNIQUE | Business ID: PROP-NNNNNN |
| prospect_id | uuid | FK → prospects, NOT NULL | Related prospect |
| prospect_property_id | uuid | FK → prospect_properties | Specific property |
| status | text | NOT NULL, DEFAULT 'draft' | draft, sent, viewed, under_review, accepted, rejected, expired |
| sent_date | date | | When sent |
| expires_date | date | | Expiration date |
| management_fee_percent | numeric(5,4) | | Proposed fee |
| minimum_term_months | integer | | Contract term |
| projected_annual_revenue | numeric(12,2) | | Revenue projection |
| projected_owner_net | numeric(12,2) | | Net to owner |
| key_differentiators | text[] | | Selling points |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### homeowner_acquisition.contracts

**PURPOSE:** Signed management contracts with DocuSign integration.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| contract_id | text | NOT NULL, UNIQUE | Business ID: CONT-NNNNNN |
| prospect_id | uuid | FK → prospects, NOT NULL | Related prospect |
| proposal_id | uuid | FK → proposals | Source proposal |
| status | text | NOT NULL, DEFAULT 'draft' | draft, sent, signed, active, terminated, expired |
| docusign_envelope_id | text | | DocuSign envelope |
| sent_date | date | | When sent |
| signed_date | date | | When executed |
| effective_date | date | | Management start |
| expiration_date | date | | Contract expiration |
| management_fee_percent | numeric(5,4) | | Agreed fee |
| term_months | integer | | Contract term |
| auto_renew | boolean | DEFAULT true | Auto-renewal |
| termination_notice_days | integer | DEFAULT 30 | Notice required |
| document_url | text | | Signed contract URL |
| created_at | timestamptz | DEFAULT now() | Created |
| updated_at | timestamptz | DEFAULT now() | Updated |

---

### homeowner_acquisition.revenue_projections

**PURPOSE:** Revenue forecasts for prospect properties with assumptions and scenarios.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| projection_id | text | NOT NULL, UNIQUE | Business ID: PROJ-NNNNNN |
| prospect_property_id | uuid | FK → prospect_properties, NOT NULL | Property projected |
| created_by_member_id | uuid | FK → team_directory | Creator |
| projection_date | date | DEFAULT CURRENT_DATE | When created |
| scenario | text | NOT NULL, DEFAULT 'base' | conservative, base, optimistic |
| projection_year | integer | NOT NULL | Year projected |
| projected_occupancy | numeric(5,4) | | Annual occupancy (0.7200 = 72%) |
| projected_adr | numeric(8,2) | | Average daily rate |
| projected_gross_revenue | numeric(12,2) | | Gross revenue |
| projected_expenses | numeric(12,2) | | Operating expenses |
| projected_management_fee | numeric(12,2) | | Management fee |
| projected_owner_net | numeric(12,2) | | Net to owner |
| assumptions | text | | Key assumptions |
| comp_properties_used | text[] | | TMKs of comps |
| created_at | timestamptz | DEFAULT now() | Created |

---

# KEY PATTERNS ACROSS ALL SCHEMAS

## Primary Key Strategy

| Type | Description | Example |
|------|-------------|---------|
| **UUIDv7** | Time-ordered, globally unique | `id uuid DEFAULT generate_uuid_v7()` |
| **Business ID** | Human-readable text with sequence | `RSV-MLVR-010001`, `TIK-PC-010001` |

## Foreign Key Actions

| Action | Meaning | Use Case |
|--------|---------|----------|
| **CASCADE DELETE** | Child records deleted when parent deleted | Parent-child hierarchies, junction tables |
| **RESTRICT DELETE** | Cannot delete parent if children exist | Reference/lookup tables, critical data |
| **SET NULL** | FK set to NULL when parent deleted | Optional relationships, soft dependencies |

## Common Index Types

| Index Type | Purpose | Example |
|------------|---------|---------|
| **UNIQUE on business_id** | Fast lookup by human-readable ID | `UNIQUE(property_id)` |
| **FK indexes** | Join performance | `idx_rooms_property_id` |
| **Partial indexes** | Filtered queries | `WHERE is_active = true` |
| **GIN indexes** | Array/JSONB columns | `tags`, `highlights`, `best_for` |
| **Vector indexes** | Embedding similarity search | `ivfflat (vector_cosine_ops)` |

## Summary by Schema

| Schema | Table Count | Purpose | Inventory Status |
|--------|-------------|---------|------------------|
| `ai` | 18 | AI agents, models, prompts, conversations, workflows | Complete |
| `brand` | 5 | Brand guidelines, logos, colors, typography | Complete |
| `comms` | 12 | Omni-channel messaging, calls, templates, threads | Complete |
| `concierge` | 24 | Beaches, activities, restaurants, itineraries, bookings | **Complete** |
| `directory` | 2 | Contacts, companies | Complete |
| `external` | 6 | Market intelligence, competitor data | **Complete** |
| `homeowner_acquisition` | 11 | Acquisition pipeline, prospects, contracts | **Complete** (new) |
| `finance` | 12 | Trust accounts, statements, invoices, payments | Complete |
| `geo` | 5 | Zones, cities, areas, neighborhoods, POIs | Complete |
| `knowledge` | 15+ | Documents, Master Library assets, embeddings | Complete |
| `marketing` | 22 | Content, campaigns, social, calendars | Complete |
| `ops` | — | **DEPRECATED** - See property, directory, reservation, service, team | Legacy |
| `portal` | 6 | User authentication, roles, permissions, sessions | **Complete** |
| `pricing` | 12 | Rates, competitors, adjustments, experiments | Complete |
| `property` | ~25 | Property assets, rooms, amenities (former ops.*) | Complete |
| `property_listings` | 13 | OTA listings, photos, reviews, performance | Complete |
| `ref` | 40+ | Reference/lookup tables across systems | Complete |
| `reservation` | ~10 | Reservations, guests, fees | Complete |
| `secure` | 2 | Users, contact entity links | Complete |
| `service` | 30 | Unified ticketing, projects, damage claims | **Complete** |
| `storage` | 4 | Central file management | **Complete** |
| `team` | 6 | Team directory, shifts, time tracking | **Complete** |

---

**Document Version:** 4.0
**Last Updated:** 20251209
**Source Documents:** 17 Reference Guide files + 17 Complete Table Inventory files
**Total Tables:** ~306+
**Remaining Gaps:** None - all schemas complete
