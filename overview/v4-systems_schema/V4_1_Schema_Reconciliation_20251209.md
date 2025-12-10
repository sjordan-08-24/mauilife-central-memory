# Schema Reconciliation: Original Structure → V4.1

**Version:** 1.0
**Date:** December 9, 2025
**Purpose:** Map all data fields from original table inventory to V4.1 separated schema structure, ensuring no data requirements are lost in the migration.

---

## Document Overview

This reconciliation ensures that:
1. All data fields from the Complete Table Inventory documents are preserved
2. Fields are properly mapped to V4.1 schema locations
3. New tables/fields in V4.1 are identified
4. Migration path is clear for each data element

**Source Documents:**
- `all_schema_table_detail.md` (306+ tables from 17 inventory documents)
- `V4_1_Separated_Schema_20251208.md` (364 tables across 22 schemas, excluding staging)

---

## Schema Count Comparison

| Schema | Original | V4.1 | Status |
|--------|----------|------|--------|
| ai | 18 | 18 | RESTRUCTURE - different table organization |
| brand | 5 | — | MERGED → brand_marketing |
| brand_marketing | — | 24 | NEW (merged brand + marketing) |
| comms | 12 | 12 | RECONCILE - some table differences |
| concierge | 24 | 24 | RECONCILE - table name differences |
| directory | 2 | 13 | EXPANDED - more granular |
| external | 6 | 6 | RESTRUCTURE - completely different tables |
| finance | 12 | 18 | EXPANDED - more tables |
| geo | 5 | 5 | RESTRUCTURE - hierarchy differences |
| homeowner_acquisition | 11 | 10 | RECONCILE - minor differences |
| inventory | — | 15 | NEW schema (from ops) |
| knowledge | 15+ | 28 | EXPANDED - more tables |
| marketing | 22 | — | MERGED → brand_marketing |
| ops | 67 | — | ELIMINATED - redistributed |
| portal | 6 | 6 | ALIGNED |
| pricing | 12 | — | RENAMED → revenue |
| property | ~25 | 28 | EXPANDED (includes inspections) |
| property_listings | 13 | 23 | EXPANDED |
| ref | 40+ | 39 | RECONCILE - different organization |
| reservations | ~10 | 8 | RECONCILE - renamed from reservation |
| revenue | — | 12 | NEW (renamed from pricing) |
| secure | 2 | 5 | EXPANDED |
| service | 30 | 30 | ALIGNED |
| storage | 4 | 4 | ALIGNED |
| team | 6 | 6 | ALIGNED |
| analytics | — | 5 | NEW (materialized views) |

---

# SECTION 1: FULLY ALIGNED SCHEMAS

These schemas require minimal changes - structure matches between documents.

## 1.1 SERVICE Schema (30 tables) ✓ ALIGNED

Both documents agree on service schema structure. All fields preserved.

## 1.2 TEAM Schema (6 tables) ✓ ALIGNED

Both documents agree on team schema structure. All fields preserved.

## 1.3 STORAGE Schema (4 tables) ✓ ALIGNED

Both documents agree on storage schema structure. All fields preserved.

## 1.4 PORTAL Schema (6 tables) ✓ ALIGNED

Both documents agree on portal schema structure. All fields preserved.

---

# SECTION 2: AI SCHEMA RECONCILIATION

## Original AI Tables (18) → V4.1 AI Tables (18)

The original inventory has specific table names with business IDs. V4.1 uses agent-centric naming.

### Field Mapping

| Original Table | Original Fields | V4.1 Target | Notes |
|---------------|-----------------|-------------|-------|
| **ai.models** | id, model_id (MDL-NNNN), provider, model_name, display_name, context_window, max_output_tokens, supports_tools, supports_vision, supports_streaming, input_cost_per_mtok, output_cost_per_mtok, is_active, notes | **ai.model_configs** | Rename table; preserve all fields |
| **ai.prompts** | id, prompt_id (PRM-NNNNNN), prompt_name, prompt_type, system_prompt, user_template, version, is_active | **ai.agent_prompts** | Map to agent-specific prompts |
| **ai.tools** | id, tool_id (TOOL-NNNN), tool_name, tool_description, parameters_schema, is_active | **ai.agent_tools** | Rename; preserve all fields |
| **ai.agents** | id, agent_id (AGT-NNNN), agent_code, agent_name, agent_description, default_model_id, system_prompt_id, temperature, max_tokens, is_active, version | **ai.agents** | DIRECT MAP - add capabilities FK |
| **ai.agent_configs** | id, config_id (ACFG-NNNNNN), agent_id, config_key, config_value, is_active | **ai.agent_configs** | DIRECT MAP |
| **ai.agent_skills** | id, skill_id (ASKL-NNNNNN), agent_id, skill_name, skill_description | **ai.agent_capabilities** | Rename skills → capabilities |
| **ai.skill_tools** | id, skill_id, tool_id | **ai.agent_tools** | Merge into agent_tools with skill reference |
| **ai.conversation_logs** | id, conversation_id (CONV-NNNNNNNN), agent_id, contact_id, reservation_id, property_id, channel, started_at, ended_at, status, handoff_to_human, handoff_reason, satisfaction_score, total_messages, total_tokens_used, total_cost, metadata | **ai.agent_conversations** | Rename; preserve all fields including cost tracking |
| **ai.conversation_messages** | id, conversation_id, role, content, tokens_used, created_at | **ai.agent_messages** | Rename; preserve all fields |
| **ai.guardrails** | id, guardrail_id (GRD-NNNNNN), guardrail_name, guardrail_type, condition, action, is_active | **ai.agent_configs** | Move to config as guardrail entries OR create new table |
| **ai.handoff_rules** | id, rule_id (HND-NNNNNN), from_agent_id, to_agent_id, condition, priority | **ai.agent_handoffs** | Rename; preserve all fields |
| **ai.performance_metrics** | id, metric_id (AMET-NNNNNN), agent_id, metric_name, metric_value, period_start, period_end | **ai.agent_evaluations** | Rename; preserve all fields |
| **ai.action_logs** | id, action_id (ALOG-NNNNNNNN), agent_id, action_type, action_data, result, created_at | **ai.agent_tool_calls** | Rename; expand to include all action types |
| **ai.action_scores** | id, score_id (ASCR-NNNNNNNN), action_id, score_type, score_value | **ai.agent_evaluations** | Merge into evaluations |
| **ai.workflows** | id, workflow_id (WFL-NNNNNN), workflow_name, workflow_description, steps_json, is_active | **ai.agent_tasks** | Map workflows to task definitions |
| **ai.workflow_runs** | id, run_id (WRUN-NNNNNNNN), workflow_id, status, started_at, completed_at, result | **ai.agent_task_results** | Map runs to task results |
| **ai.api_calls** | id, call_id (APIC-NNNNNNNN), agent_id, provider, model, tokens_in, tokens_out, cost, latency_ms, created_at | **ai.usage_logs** | Rename; preserve all cost/usage fields |
| **ai.model_usage** | id, usage_id (MUSG-NNNNNNNN), model_id, period, total_calls, total_tokens, total_cost | **ai.usage_logs** | Merge into usage_logs with aggregation |

### New V4.1 Tables to Add

| V4.1 Table | Purpose | Source |
|------------|---------|--------|
| ai.agent_memory | Agent memory/context | NEW - implement |
| ai.agent_feedback | Human feedback | NEW - implement |
| ai.agent_escalations | Escalation to humans | NEW - implement |
| ai.embedding_configs | Embedding configurations | NEW - implement |

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in ai schema:
- Business IDs: MDL-NNNN, AGT-NNNN, CONV-NNNNNNNN patterns
- Cost tracking: input_cost_per_mtok, output_cost_per_mtok, total_cost
- Token tracking: tokens_in, tokens_out, total_tokens_used
- Satisfaction scoring: satisfaction_score
- Handoff tracking: handoff_to_human, handoff_reason
- Context linking: contact_id, reservation_id, property_id
```

---

# SECTION 3: BRAND + MARKETING → BRAND_MARKETING RECONCILIATION

## Original Brand Schema (5 tables) + Marketing Schema (22 tables) → V4.1 brand_marketing (24 tables)

### Brand Tables Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **brand.brand_guidelines** | guideline_id (BG-NNNNNN), title, category, content, tone_attributes[], personality_traits[], do_examples[], dont_examples[], key_phrases[], words_to_use[], words_to_avoid[], sample_copy, naming_pattern, naming_examples[], naming_rules, response_context, response_timeframe, response_template, version, status, effective_date, approved_by, file_url | **brand_marketing.brand_guidelines** | DIRECT MAP |
| **brand.color_palettes** | id, guideline_id, color_name, hex_value, rgb_value, usage_context | **brand_marketing.brand_colors** | Rename |
| **brand.logos** | id, logo_id (LOGO-NNNN), logo_name, logo_type, file_url, usage_guidelines | **brand_marketing.brand_assets** | Merge into brand_assets |
| **brand.typography** | id, font_name, font_family, font_weight, usage_context | **brand_marketing.brand_fonts** | Rename |
| **brand.messaging_templates** | id, template_id (TMPL-NNNNNN), template_name, template_type, content, variables | **brand_marketing.brand_templates** | Rename |

### Marketing Tables Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **marketing.content** | content_id (CON-NNNNNN), title, content_type, body, status, author_id | **brand_marketing.content_pieces** | Rename |
| **marketing.content_versions** | id, content_id, version, body, created_at | **brand_marketing.content_pieces** | Add version tracking to content_pieces |
| **marketing.content_library** | asset_id (ASSET-NNNNNN), asset_type, file_url, metadata | **brand_marketing.brand_assets** | Merge |
| **marketing.property_content** | id, property_id, content_id | **brand_marketing.content_pieces** | Add property_id FK |
| **marketing.content_strategy** | strategy_id (STRAT-NNNNNN), strategy_name, goals, target_audience | **brand_marketing.campaigns** | Merge into campaign planning |
| **marketing.content_calendars** | calendar_id (CAL-NNNNNN), calendar_name, start_date, end_date | **brand_marketing.content_calendar** | Rename (singular) |
| **marketing.calendar_items** | id, calendar_id, content_id, scheduled_date, status | **brand_marketing.content_calendar** | Merge as calendar entries |
| **marketing.campaigns** | campaign_id (CMP-NNNNNN), campaign_name, campaign_type, start_date, end_date, budget, status | **brand_marketing.campaigns** | DIRECT MAP |
| **marketing.campaign_events** | event_id (CEVT-NNNNNN), campaign_id, event_type, event_date, details | **brand_marketing.campaign_metrics** | Merge into metrics |
| **marketing.segments** | segment_id (SEG-NNNNNN), segment_name, criteria_json, member_count | **brand_marketing.campaign_audiences** | Rename |
| **marketing.segment_members** | id, segment_id, contact_id | **brand_marketing.campaign_audiences** | Merge |
| **marketing.social_accounts** | account_id (SA-NNNNNN), platform, account_name, credentials_encrypted | **brand_marketing.social_accounts** | DIRECT MAP |
| **marketing.social_posts** | post_id (SP-NNNNNN), account_id, content, scheduled_at, published_at, status | **brand_marketing.social_posts** | DIRECT MAP |
| **marketing.social_analytics** | id, post_id, metric_type, metric_value, captured_at | **brand_marketing.social_metrics** | Rename |
| **marketing.social_account_metrics** | id, account_id, followers, engagement_rate, captured_at | **brand_marketing.social_metrics** | Merge |
| **marketing.websites** | website_id (WEB-NNNNNN), domain, platform, status | **brand_marketing.seo_keywords** | Track via SEO tables |
| **marketing.website_pages** | id, website_id, page_path, title, meta_description | **brand_marketing.seo_keywords** | Merge |
| **marketing.attribution** | id, reservation_id, source, medium, campaign, first_touch, last_touch | **brand_marketing.referrals** | Track attribution via referrals |

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in brand_marketing schema:
- Business IDs: BG-NNNNNN, LOGO-NNNN, TMPL-NNNNNN, CON-NNNNNN, CMP-NNNNNN, SA-NNNNNN, SP-NNNNNN
- Brand voice arrays: tone_attributes[], personality_traits[], do_examples[], dont_examples[]
- Naming system: naming_pattern, naming_examples[], naming_rules
- Response templates: response_context, response_timeframe, response_template
- Attribution tracking: source, medium, campaign, first_touch, last_touch
- Social metrics: followers, engagement_rate, impressions, clicks
```

---

# SECTION 4: CONCIERGE SCHEMA RECONCILIATION

## Original Concierge (24 tables) → V4.1 Concierge (24 tables)

Table count matches but names differ significantly.

### Venue Tables Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **concierge.beaches** | id, beach_id (BCH-NNNN), area_id, beach_name, description, amenities[], parking_type, restrooms, showers, lifeguard, swimming_conditions, snorkeling_quality, family_friendly, romantic, accessibility | **concierge.attractions** | Merge into attractions with type='beach' |
| **concierge.hikes** | id, hike_id (HIK-NNNN), area_id, trail_name, difficulty, distance_miles, elevation_gain, duration_hours, highlights[], permits_required | **concierge.activities** | Merge into activities with type='hike' |
| **concierge.activities** | id, activity_id (ACT-NNNNNN), area_id, company_id, activity_name, activity_type, description, duration, price_range, booking_url | **concierge.activities** | DIRECT MAP |
| **concierge.restaurants** | id, restaurant_id (RST-NNNNNN), area_id, restaurant_name, cuisine_types[], price_range, reservation_required, dress_code, highlights[] | **concierge.restaurants** | DIRECT MAP |
| **concierge.attractions** | id, attraction_id (ATT-NNNN), area_id, attraction_name, attraction_type, description, hours, admission_fee | **concierge.attractions** | DIRECT MAP |
| **concierge.shops** | id, shop_id (SHP-NNNN), area_id, shopping_location_id, shop_name, shop_type, specialties[] | **concierge.attractions** | Merge into attractions with type='shop' |
| **concierge.shopping_locations** | id, location_id (SLOC-NNNN), area_id, location_name, location_type, stores_count | **concierge.attractions** | Merge into attractions with type='shopping_center' |
| **concierge.experience_spots** | id, spot_id (EXP-NNNN), area_id, spot_name, spot_type, best_time, description | **concierge.local_tips** | Merge into local_tips |

### Service Tables Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **concierge.services** | id, service_id (SVC-NNNNNN), company_id, category_id, service_name, description, price, duration, booking_lead_time | **concierge.service_offerings** | Rename |
| **concierge.service_categories** | id, category_code, category_name, description | **ref.vendor_categories** | Move to ref schema |
| **concierge.add_ons** | id, service_id, add_on_name, add_on_price | **concierge.service_offerings** | Add add_ons as JSONB field |

### Guest Profile Tables Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **concierge.guest_travel_profiles** | id, guest_id, activity_level_id, budget_level_id, schedule_density_id, driving_tolerance_id, travel_style, special_occasions[] | **concierge.guest_preferences** | Rename; preserve all preference fields |
| **concierge.guest_interests** | id, guest_id, interest_type_id, preference_level, notes | **concierge.guest_preferences** | Merge as interests JSONB |
| **concierge.guest_limitations** | id, guest_id, limitation_type_id, severity, notes | **concierge.guest_preferences** | Merge as limitations JSONB |
| **concierge.guest_surveys** | id, survey_id (SRV-NNNNNN), reservation_id, guest_id, survey_type, status, completed_at | **concierge.guest_surveys** | DIRECT MAP |

### Survey & Itinerary Tables Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **concierge.survey_responses** | id, survey_id, question_key, response_value | **concierge.survey_responses** | DIRECT MAP |
| **concierge.itinerary_themes** | id, theme_id (THM-NNNN), theme_name, description, activity_level_id, budget_level_id, default_density | **concierge.itineraries** | Merge theme concept into itinerary metadata |
| **concierge.theme_interest_weights** | id, theme_id, interest_type_id, weight | **concierge.recommendations** | Use for AI recommendation weighting |
| **concierge.theme_limitations_excluded** | id, theme_id, limitation_type_id | **concierge.recommendations** | Use for AI filtering |
| **concierge.itineraries** | id, itinerary_id (ITN-NNNNNN), reservation_id, theme_id, status, generated_at, approved_at | **concierge.itineraries** | DIRECT MAP |
| **concierge.itinerary_days** | id, itinerary_id, day_number, date, day_theme | **concierge.itinerary_items** | Merge day concept into items |
| **concierge.itinerary_items** | id, day_id, sequence, item_type, reference_id, start_time, end_time, notes | **concierge.itinerary_items** | DIRECT MAP; add day_number |

### Booking Tables Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **concierge.bookings** | id, booking_id (BKG-NNNNNN), reservation_id, booking_type, reference_id, status, booked_at, confirmation_number | **concierge.bookings** | DIRECT MAP |
| **concierge.booking_confirmations** | id, booking_id, confirmation_type, sent_at, confirmed_at | **concierge.booking_confirmations** | DIRECT MAP |

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in concierge schema:
- Business IDs: BCH-NNNN, HIK-NNNN, ACT-NNNNNN, RST-NNNNNN, ATT-NNNN, SVC-NNNNNN, ITN-NNNNNN, BKG-NNNNNN
- Venue detail arrays: amenities[], highlights[], cuisine_types[], specialties[]
- Hike specifics: difficulty, distance_miles, elevation_gain, duration_hours, permits_required
- Beach specifics: swimming_conditions, snorkeling_quality, lifeguard
- Guest preferences: activity_level, budget_level, schedule_density, driving_tolerance
- Interest/Limitation tracking: preference_level, severity
- Theme weighting: interest weights for AI recommendations
```

---

# SECTION 5: EXTERNAL SCHEMA RECONCILIATION

## Original External (6 tables) → V4.1 External (6 tables)

**MAJOR RESTRUCTURE REQUIRED** - V4.1 has completely different table design.

### Original Tables → V4.1 Mapping

| Original Table | Original Key Fields | V4.1 Target | Action Required |
|---------------|---------------------|-------------|-----------------|
| **external.properties** | tmk (UNIQUE), ops_property_id, area_id, property_name, address fields, resort_name, bedrooms, bathrooms, property_type, view_type, rental_status, ownership_status, our_status, is_managed_by_us, is_prospect, is_competitor, is_hot_lead, airbnb_listing_id, airbnb_rating, vrbo_listing_id, owner_name, owner_mailing_*, last_sale_date, last_sale_price, current_manager_name, estimated_annual_revenue, estimated_adr, estimated_occupancy, data_sources[] | **external.competitor_properties** | EXPAND V4.1 table to include all fields |
| **external.property_managers** | manager_id (EXT-MGR-NNNNNN), tmk, manager_name, started_at, ended_at, source, notes | **external.competitor_properties** | Add manager tracking fields OR create subtable |
| **external.property_sales** | sale_id (EXT-SALE-NNNNNN), tmk, sale_date, sale_price, buyer_name, buyer_mailing_*, seller_name, document_number, source | **external.market_data** | Create sale_history tracking |
| **external.property_reviews** | review_id (EXT-REV-NNNNNN), tmk, platform, external_review_id, review_date, rating, review_text, reviewer_name, host_response, host_response_date, sentiment, pain_points[], opportunity_score, processed_at | **NEW: external.competitor_reviews** | CREATE NEW TABLE |
| **external.property_pricing** | pricing_id (EXT-PRC-NNNNNN), tmk, captured_at, platform, check_in_date, check_out_date, nightly_rate, cleaning_fee, service_fee, total_price, minimum_nights, is_available, source_url | **external.market_rates** | Map to market_rates; add property-level detail |
| **external.competitive_sets** | id, ops_property_id, external_tmk, similarity_score, same_resort, same_area, same_bedrooms, same_view_type, competition_level, notes | **external.competitor_properties** | Add competitive set relationship fields |

### Recommended V4.1 External Schema Update

```sql
-- EXPAND external.competitor_properties to include original fields
ALTER TABLE external.competitor_properties ADD COLUMN:
  tmk text UNIQUE,
  property_name text,
  street_address text,
  city text,
  state text,
  resort_name text,
  bedrooms integer,
  bathrooms numeric(3,1),
  property_type text,
  view_type text,
  rental_status text DEFAULT 'unknown',
  ownership_status text DEFAULT 'stable',
  our_status text DEFAULT 'watching',
  is_managed_by_us boolean DEFAULT false,
  is_prospect boolean DEFAULT false,
  is_competitor boolean DEFAULT false,
  is_hot_lead boolean DEFAULT false,
  airbnb_listing_id text,
  airbnb_url text,
  airbnb_rating numeric(2,1),
  vrbo_listing_id text,
  vrbo_url text,
  vrbo_rating numeric(2,1),
  owner_name text,
  owner_mailing_address text,
  last_sale_date date,
  last_sale_price numeric(12,2),
  current_manager_name text,
  estimated_annual_revenue numeric(12,2),
  estimated_adr numeric(8,2),
  estimated_occupancy numeric(5,4),
  data_sources text[],
  opportunity_score integer;

-- CREATE NEW TABLE for manager history
CREATE TABLE external.property_managers (
  id uuid PRIMARY KEY DEFAULT generate_uuid_v7(),
  manager_id text NOT NULL UNIQUE,
  property_id uuid REFERENCES external.competitor_properties(id),
  manager_name text NOT NULL,
  started_at date,
  ended_at date,
  source text,
  notes text,
  created_at timestamptz DEFAULT now()
);

-- CREATE NEW TABLE for reviews with sentiment
CREATE TABLE external.competitor_reviews (
  id uuid PRIMARY KEY DEFAULT generate_uuid_v7(),
  review_id text NOT NULL UNIQUE,
  property_id uuid REFERENCES external.competitor_properties(id),
  platform text NOT NULL,
  external_review_id text,
  review_date date NOT NULL,
  rating integer,
  review_text text,
  reviewer_name text,
  host_response text,
  host_response_date date,
  sentiment text,
  pain_points text[],
  opportunity_score integer,
  processed_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- CREATE NEW TABLE for competitive set relationships
CREATE TABLE external.competitive_sets (
  id uuid PRIMARY KEY DEFAULT generate_uuid_v7(),
  our_property_id uuid REFERENCES property.properties(id),
  competitor_property_id uuid REFERENCES external.competitor_properties(id),
  similarity_score integer,
  same_resort boolean DEFAULT false,
  same_area boolean DEFAULT false,
  same_bedrooms boolean DEFAULT false,
  same_view_type boolean DEFAULT false,
  competition_level text DEFAULT 'secondary',
  notes text,
  created_at timestamptz DEFAULT now(),
  UNIQUE(our_property_id, competitor_property_id)
);
```

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in external schema:
- TMK as unique property identifier
- Business IDs: EXT-MGR-NNNNNN, EXT-SALE-NNNNNN, EXT-REV-NNNNNN, EXT-PRC-NNNNNN
- Three-dimensional status: rental_status, ownership_status, our_status
- Boolean flags: is_managed_by_us, is_prospect, is_competitor, is_hot_lead
- Hot lead detection: manager ended_at, last_sale_date triggers
- Review sentiment: sentiment, pain_points[], opportunity_score
- Competitive analysis: similarity_score, competition_level
- Owner contact: owner_name, owner_mailing_* for outreach
```

---

# SECTION 6: HOMEOWNER_ACQUISITION SCHEMA RECONCILIATION

## Original (11 tables) → V4.1 (10 tables)

### Table Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **homeowner_acquisition.prospects** | prospect_id (HOP-NNNNNN), contact_id, source_id, assigned_to_member_id, status, priority, estimated_close_date, lost_reason, first_contact_date, last_contact_date, next_follow_up_date, notes | **homeowner_acquisition.leads** | Rename prospects → leads; preserve all fields |
| **homeowner_acquisition.prospect_properties** | prospect_property_id (HOPP-NNNNNN), prospect_id, external_tmk, status, estimated_value, estimated_annual_revenue, current_rental_income, management_fee_proposed, onboarded_property_id, won_date, lost_date, lost_reason, notes | **homeowner_acquisition.property_assessments** | MERGE into property_assessments OR create new table |
| **homeowner_acquisition.lead_sources** | source_code, source_name, source_category, is_active, notes | **homeowner_acquisition.lead_sources** | DIRECT MAP |
| **homeowner_acquisition.lead_activities** | activity_id (HOPA-NNNNNN), prospect_id, activity_type, activity_date, performed_by_member_id, subject, description, outcome, next_action, next_action_date | **homeowner_acquisition.lead_activities** | DIRECT MAP; update FK to leads |
| **homeowner_acquisition.proposals** | proposal_id (PROP-NNNNNN), prospect_id, prospect_property_id, status, sent_date, expires_date, management_fee_percent, minimum_term_months, projected_annual_revenue, projected_owner_net, key_differentiators[], notes | **homeowner_acquisition.proposals** | DIRECT MAP; update FK to leads |
| **homeowner_acquisition.proposal_versions** | id, proposal_id, version_number, created_by_member_id, management_fee_percent, minimum_term_months, projected_annual_revenue, changes_summary, document_url | **homeowner_acquisition.proposal_versions** | DIRECT MAP |
| **homeowner_acquisition.contracts** | contract_id (CONT-NNNNNN), prospect_id, prospect_property_id, proposal_id, status, docusign_envelope_id, sent_date, signed_date, effective_date, expiration_date, management_fee_percent, term_months, auto_renew, termination_notice_days, document_url, notes | **homeowner_acquisition.contracts** | DIRECT MAP; update FK to leads |
| **homeowner_acquisition.onboarding_tasks** | task_code (TASK-NNN), task_name, description, category, sort_order, estimated_days, required, depends_on_task_id, is_active | **homeowner_acquisition.onboarding_tasks** | DIRECT MAP |
| **homeowner_acquisition.onboarding_progress** | id, prospect_id, task_id, status, assigned_to_member_id, started_at, completed_at, due_date, notes, blocker_reason | **homeowner_acquisition.onboarding_progress** | DIRECT MAP; update FK to leads |
| **homeowner_acquisition.property_assessments** | assessment_id (ASMT-NNNNNN), prospect_property_id, assessed_by_member_id, assessment_date, overall_condition, rental_ready, estimated_prep_cost, estimated_prep_days, furnishing_status, recommended_improvements[], strengths[], concerns[], comp_analysis_notes, photos_url, notes | **homeowner_acquisition.property_assessments** | DIRECT MAP |
| **homeowner_acquisition.revenue_projections** | projection_id (PROJ-NNNNNN), prospect_property_id, created_by_member_id, projection_date, scenario, projection_year, projected_occupancy, projected_adr, projected_gross_revenue, projected_expenses, projected_management_fee, projected_owner_net, assumptions, comp_properties_used[], notes | **homeowner_acquisition.revenue_projections** | DIRECT MAP |

### Missing Table in V4.1: prospect_properties

**RECOMMENDATION:** Add prospect_properties table to V4.1 OR expand property_assessments:

```sql
CREATE TABLE homeowner_acquisition.prospect_properties (
  id uuid PRIMARY KEY DEFAULT generate_uuid_v7(),
  prospect_property_id text NOT NULL UNIQUE,
  lead_id uuid REFERENCES homeowner_acquisition.leads(id) ON DELETE CASCADE,
  external_tmk text REFERENCES external.competitor_properties(tmk),
  status text NOT NULL DEFAULT 'identified',
  estimated_value numeric(12,2),
  estimated_annual_revenue numeric(12,2),
  current_rental_income numeric(12,2),
  management_fee_proposed numeric(5,4),
  onboarded_property_id uuid REFERENCES property.properties(id),
  won_date date,
  lost_date date,
  lost_reason text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in homeowner_acquisition schema:
- Business IDs: HOP-NNNNNN, HOPP-NNNNNN, HOPA-NNNNNN, PROP-NNNNNN, CONT-NNNNNN, ASMT-NNNNNN, PROJ-NNNNNN
- Pipeline tracking: status progressions, priority (hot/high/medium/low)
- Deal values: estimated_value, estimated_annual_revenue, management_fee_proposed
- Proposal versioning: version_number, changes_summary
- Contract details: docusign_envelope_id, auto_renew, termination_notice_days
- Assessment arrays: recommended_improvements[], strengths[], concerns[]
- Projection scenarios: conservative, base, optimistic with comp_properties_used[]
```

---

# SECTION 7: PRICING → REVENUE SCHEMA RECONCILIATION

## Original Pricing (12 tables) → V4.1 Revenue (12 tables)

### Table Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **pricing.base_rates** | id, rate_id (BRT-NNNNNN), property_id, rate_type, base_nightly, weekend_adjustment, min_stay, max_stay, effective_from, effective_to | **revenue.pricing_rules** | Merge into pricing_rules |
| **pricing.listing_performance_snapshots** | id, property_id, captured_at, occupancy_30d, occupancy_90d, adr_30d, adr_90d, revpar_30d, revpar_90d | **revenue.yield_metrics** | Merge into yield_metrics |
| **pricing.seasonal_adjustments** | id, adjustment_id (SEA-NNNNNN), property_id, season_type_id, adjustment_percent, start_date, end_date | **revenue.seasonal_rates** | Rename |
| **pricing.market_events** | id, event_id (EVT-NNNNNN), event_name, event_type, start_date, end_date, impact_percent, affected_areas[] | **revenue.event_pricing** | Rename |
| **pricing.competitor_rates** | id, rate_id (CMP-NNNNNN), property_id, competitor_tmk, captured_at, nightly_rate, source | **revenue.competitor_rates** | DIRECT MAP |
| **pricing.dynamic_adjustments** | id, adjustment_id (DYN-NNNNNN), property_id, adjustment_type, adjustment_value, reason, applied_at | **revenue.pricing_adjustments** | Rename |
| **pricing.rate_history** | id, history_id (RTH-NNNNNN), property_id, date, rate, source, reason | **revenue.rate_history** | DIRECT MAP |
| **pricing.guest_value_intelligence** | id, gvi_id (GVI-NNNNNN), guest_id, lifetime_value, booking_frequency, avg_booking_value, price_sensitivity, preferred_seasons[] | **revenue.yield_metrics** | Move to guest analytics OR create new table |
| **pricing.segment_pricing_insights** | id, insight_id (SPI-NNNNNN), segment_id, avg_rate_tolerance, booking_lead_time_avg, length_of_stay_avg | **revenue.market_data** | Merge into market_data |
| **pricing.website_sessions** | id, session_id (WSS-NNNNNN), visitor_id, property_id, session_start, pages_viewed, rate_viewed, converted | **revenue.pricing_logs** | Move to analytics OR pricing_logs |
| **pricing.rate_impressions** | id, impression_id (IMP-NNNNNN), property_id, platform, rate_shown, date, impressions, clicks, bookings | **revenue.pricing_logs** | Merge into pricing_logs |
| **pricing.pricing_experiments** | id, experiment_id (EXP-NNNNNN), property_id, variant_a_rate, variant_b_rate, start_date, end_date, winner, lift_percent | **revenue.pricing_recommendations** | Track experiments in recommendations |

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in revenue schema:
- Business IDs: BRT-NNNNNN, SEA-NNNNNN, EVT-NNNNNN, DYN-NNNNNN, RTH-NNNNNN, GVI-NNNNNN
- Performance metrics: occupancy_30d/90d, adr_30d/90d, revpar_30d/90d
- Guest intelligence: lifetime_value, booking_frequency, price_sensitivity
- Experiment tracking: variant rates, winner, lift_percent
- Event impact: impact_percent, affected_areas[]
```

---

# SECTION 8: GEO SCHEMA RECONCILIATION

## Original Geo (5 tables) → V4.1 Geo (5 tables)

Different hierarchy structure.

### Table Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **geo.zones** | zone_id (ZN-NNNN), zone_code, zone_name, zone_type (island/state/metro), country, timezone, latitude, longitude, is_active | **geo.countries** + **geo.states** | Split zones into country/state hierarchy |
| **geo.cities** | city_id (CTY-NNNN), zone_id, city_code, city_name, latitude, longitude | **geo.cities** | DIRECT MAP; update zone_id → state_id |
| **geo.areas** | area_id (AREA-NNNN), city_id, area_code, area_name, area_type, description, latitude, longitude, highlights[], best_for[], drive_to_airport_minutes, walkability_score, is_active | **geo.areas** | DIRECT MAP |
| **geo.neighborhoods** | neighborhood_id (NBH-NNNNN), area_id, neighborhood_code, neighborhood_name, description, latitude, longitude | **geo.areas** | Merge as sub-areas OR keep separate |
| **geo.points_of_interest** | poi_id (POI-NNNNNN), area_id, neighborhood_id, poi_name, poi_type, poi_category, description, address, latitude, longitude, phone, website, google_place_id, hours, price_range, cost_level, rating, review_count, highlights[], cuisines[], is_family_friendly, is_romantic, is_accessible, is_ai_visible, is_active | **geo.poi** | Rename; preserve ALL fields |

### Recommended V4.1 Geo Schema Update

```sql
-- ADD zones table back for multi-market support
CREATE TABLE geo.zones (
  id uuid PRIMARY KEY DEFAULT generate_uuid_v7(),
  zone_id text NOT NULL UNIQUE,
  zone_code text NOT NULL UNIQUE,
  zone_name text NOT NULL,
  zone_type text NOT NULL, -- island, state, metro
  country_id uuid REFERENCES geo.countries(id),
  timezone text NOT NULL,
  latitude numeric(10,7),
  longitude numeric(10,7),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- ADD neighborhoods table
CREATE TABLE geo.neighborhoods (
  id uuid PRIMARY KEY DEFAULT generate_uuid_v7(),
  neighborhood_id text NOT NULL UNIQUE,
  area_id uuid REFERENCES geo.areas(id) ON DELETE RESTRICT,
  neighborhood_code text NOT NULL,
  neighborhood_name text NOT NULL,
  description text,
  latitude numeric(10,7),
  longitude numeric(10,7),
  created_at timestamptz DEFAULT now(),
  UNIQUE(area_id, neighborhood_code)
);

-- EXPAND geo.poi to include all original fields
ALTER TABLE geo.poi ADD COLUMN:
  poi_id text UNIQUE,
  neighborhood_id uuid REFERENCES geo.neighborhoods(id),
  poi_category text,
  google_place_id text,
  hours jsonb,
  price_range text,
  cost_level integer,
  rating numeric(2,1),
  review_count integer,
  highlights text[],
  cuisines text[],
  is_family_friendly boolean DEFAULT true,
  is_romantic boolean DEFAULT false,
  is_accessible boolean,
  is_ai_visible boolean DEFAULT true;
```

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in geo schema:
- Business IDs: ZN-NNNN, CTY-NNNN, AREA-NNNN, NBH-NNNNN, POI-NNNNNN
- Zone concept: zone_type (island/state/metro) for multi-market
- Area arrays: highlights[], best_for[]
- Area metrics: drive_to_airport_minutes, walkability_score
- POI detail: google_place_id, hours (jsonb), cuisines[]
- POI flags: is_family_friendly, is_romantic, is_accessible, is_ai_visible
- Neighborhood hierarchy: neighborhoods as sub-areas
```

---

# SECTION 9: FINANCE SCHEMA RECONCILIATION

## Original Finance (12 tables) → V4.1 Finance (18 tables)

V4.1 has more tables but some original functionality may be split differently.

### Table Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **finance.trust_accounts** | trust_account_id (TRUST-NNNNNN), account_name, account_number, bank_name, routing_number, account_type, qbo_account_id, current_balance, is_active | **finance.trust_accounts** | DIRECT MAP |
| **finance.trust_transactions** | transaction_id (TTXN-NNNNNN), trust_account_id, transaction_type, amount, description, reference_id, reference_type, posted_at | **finance.trust_transactions** | DIRECT MAP |
| **finance.owner_statements** | statement_id (STMT-NNNNNN), homeowner_id, property_id, trust_account_id, statement_period_start, statement_period_end, opening_balance, total_revenue, total_expenses, management_fee, net_to_owner, closing_balance, status, sent_at, qbo_invoice_id | **finance.owner_statements** | DIRECT MAP |
| **finance.statement_line_items** | id, statement_id, line_type, description, amount, category, reservation_id | **finance.owner_statement_lines** | Rename |
| **finance.invoices** | invoice_id (INV-NNNNNN), contact_id, invoice_type, invoice_date, due_date, subtotal, tax, total, status, qbo_invoice_id | **finance.invoices** | DIRECT MAP |
| **finance.invoice_items** | id, invoice_id, description, quantity, unit_price, amount, category | **finance.invoice_lines** | Rename |
| **finance.payments** | payment_id (PMT-NNNNNN), invoice_id, payment_method, amount, payment_date, reference_number, status | **finance.transactions** | Merge into transactions with type='payment' |
| **finance.payables** | payable_id (PAY-NNNNNN), vendor_id, invoice_number, amount, due_date, status, paid_at, payment_reference | **finance.vendor_payments** | Rename/merge |
| **finance.tax_records** | tax_id (TAX-NNNNNN), property_id, tax_type, tax_year, amount, jurisdiction, due_date, paid_at, status | **finance.transactions** | Track as transaction with type='tax' OR create tax_records |
| **finance.reconciliations** | reconciliation_id (REC-NNNNNN), trust_account_id, statement_date, statement_balance, book_balance, difference, status, reconciled_by, reconciled_at | **finance.account_balances** | Track reconciliation status in account_balances |
| **finance.reserve_accounts** | reserve_id (RES-NNNNNN), property_id, homeowner_id, reserve_type, target_balance, current_balance, is_active | **finance.accounts** | Track as account with type='reserve' |
| **finance.reserve_transactions** | transaction_id (RTXN-NNNNNN), reserve_id, transaction_type, amount, description, created_at | **finance.transactions** | Merge into transactions |

### New Tables in V4.1 to Implement

| V4.1 Table | Purpose | Source Data |
|------------|---------|-------------|
| finance.transaction_lines | Line item detail | From statement/invoice lines |
| finance.expenses | Expense tracking | NEW - implement |
| finance.expense_receipts | Receipt links | NEW - implement |
| finance.budgets | Budget definitions | NEW - implement |
| finance.budget_lines | Budget line items | NEW - implement |
| finance.payroll_runs | Payroll processing | NEW - implement |
| finance.payroll_items | Payroll line items | NEW - implement |

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in finance schema:
- Business IDs: TRUST-NNNNNN, TTXN-NNNNNN, STMT-NNNNNN, INV-NNNNNN, PMT-NNNNNN, PAY-NNNNNN, TAX-NNNNNN, REC-NNNNNN, RES-NNNNNN, RTXN-NNNNNN
- Trust accounting: current_balance, statement periods, net_to_owner
- QuickBooks integration: qbo_account_id, qbo_invoice_id
- Reconciliation: statement_balance, book_balance, difference, reconciled_by
- Reserve tracking: target_balance, reserve_type
- Tax records: tax_year, jurisdiction, due_date
```

---

# SECTION 10: REF SCHEMA RECONCILIATION

## Original Ref (40+ tables) → V4.1 Ref (39 tables)

Both have similar count but different organization.

### Tables to ADD to V4.1 Ref Schema

| Original Table | Purpose | Action |
|---------------|---------|--------|
| ref.property_fees | Property fee rates | ADD |
| ref.resort_fees | Resort fee rates | ADD |
| ref.reservation_type_fees | Reservation type fees | ADD |
| ref.fee_rate_history | Fee rate history | ADD |
| ref.qbo_classes | QuickBooks classes | ADD |
| ref.qbo_products | QuickBooks products | ADD |
| ref.qbo_accounts | QuickBooks accounts | ADD |
| ref.tax_jurisdictions | Tax jurisdictions | ADD |
| ref.timesheet_type_key | Timesheet types | MERGE into activity_types |
| ref.recurring_task_type_key | Recurring task types | ADD |
| ref.damage_claim_status_type_key | Claim statuses | MERGE into status_types |
| ref.damage_claim_type_key | Claim types | ADD to damage_category_key |
| ref.time_activity_type_key | Time activity types | MERGE into activity_types |
| ref.master_library_asset_type_key | Asset types | ADD |
| ref.document_type_key | Document types | EXISTS as document_types |
| ref.communication_type_key | Communication types | ADD |
| ref.document_source_type_key | Document sources | ADD |
| ref.content_status_type_key | Content statuses | ADD |
| ref.audience_type_key | Audience types | ADD |
| ref.season_types | Season types | ADD |
| ref.adjustment_types | Adjustment types | ADD |
| ref.guest_segments | Guest segments | ADD |
| ref.price_sensitivity_levels | Price sensitivity | ADD |
| ref.booking_channels | Booking channels | ADD |
| ref.competitor_types | Competitor types | ADD |
| ref.activity_levels | Activity intensity (concierge) | ADD |
| ref.budget_levels | Budget preferences (concierge) | ADD |
| ref.schedule_density_levels | Pace preferences (concierge) | ADD |
| ref.driving_tolerance_levels | Driving tolerance (concierge) | ADD |
| ref.interest_types | Interest categories (concierge) | ADD |
| ref.interest_categories | Interest groupings (concierge) | ADD |
| ref.limitation_types | Guest limitations (concierge) | ADD |

---

# SECTION 11: DIRECTORY SCHEMA RECONCILIATION

## Original Directory (2 tables) → V4.1 Directory (13 tables)

V4.1 significantly expands directory schema with tables from ops.

### Table Mapping

| Original Table | V4.1 Target | Notes |
|---------------|-------------|-------|
| **directory.contacts** | **directory.contacts** | DIRECT MAP |
| **directory.companies** | **directory.companies** | DIRECT MAP |
| — | **directory.guests** | FROM ops.guests |
| — | **directory.homeowners** | FROM ops.homeowners |
| — | **directory.vendors** | FROM ops.vendors (via companies) |
| — | **directory.homeowner_property_relationship** | FROM ops.homeowner_properties |
| — | **directory.vendor_assignments** | FROM ops.vendor_assignments |
| — | **directory.contact_groups** | NEW |
| — | **directory.contact_group_members** | NEW |
| — | **directory.contact_relationships** | NEW |
| — | **directory.contact_notes** | NEW |
| — | **directory.contact_tags** | NEW |
| — | **directory.contact_merge_history** | NEW |

### Fields from Original ops Tables to Preserve

```
FROM ops.guests:
- guest_id (GST-NNNNNN), contact_id, first_stay_date, last_stay_date,
  total_stays, total_nights, lifetime_value, vip_status, preferences_json,
  dietary_restrictions[], special_requests[], notes

FROM ops.homeowners:
- homeowner_id (OWN-NNNNNN), contact_id, owner_since, contract_type,
  management_fee_percent, distribution_method, tax_id_encrypted,
  w9_on_file, is_active, notes

FROM ops.homeowner_properties:
- homeowner_id, property_id, ownership_percent, start_date, end_date,
  is_primary_contact, distribution_split
```

---

# SECTION 12: KNOWLEDGE SCHEMA RECONCILIATION

## Original Knowledge (15+ tables) → V4.1 Knowledge (28 tables)

V4.1 significantly expands knowledge schema.

### Table Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **knowledge.departments** | dept_id (DEPT-NN), dept_name, dept_code | **knowledge.article_categories** | Map departments to top-level categories |
| **knowledge.sections** | section_id (SEC-{dept}-NNN), dept_id, section_name | **knowledge.article_categories** | Map sections to sub-categories |
| **knowledge.master_library_assets** | asset_id (MLA-{type}-NNNNNN), dept_id, section_id, asset_type, title, description, content, version, status, owner_id | **knowledge.articles** + **knowledge.sops** | Split by type: SOP → sops, others → articles |
| **knowledge.asset_versions** | id, asset_id, version, content, created_by, created_at | **knowledge.article_versions** + **knowledge.sop_steps** | Map versioning |
| **knowledge.asset_steps** | id, asset_id, step_number, instruction, expected_duration | **knowledge.sop_steps** | DIRECT MAP for SOPs |
| **knowledge.documents** | doc_id (DOC-{type}-NNNNNN), document_type, title, file_url, metadata | **knowledge.documents** | DIRECT MAP |
| **knowledge.document_entity_links** | id, document_id, entity_type, entity_id | **knowledge.documents** | Add entity linking fields |
| **knowledge.document_impacts** | id, document_id, impact_type, impact_description | **knowledge.feedback** | Track as feedback/impact |
| **knowledge.embeddings** | embedding_id (EMB-NNNNNN), source_type, source_id, chunk_index, vector, metadata | **knowledge.article_embeddings** + **knowledge.document_embeddings** | Split by source type |
| **knowledge.embedding_chunks** | id, embedding_id, chunk_text, token_count | **knowledge.article_embeddings** | Include chunk data in embeddings |
| **knowledge.search_logs** | id, query, results_count, clicked_result_id, user_id, searched_at | **knowledge.search_logs** | DIRECT MAP |
| **knowledge.property_guides** | guide_id (PGD-{property}), property_id, title, status | **knowledge.guidebooks** | Rename |
| **knowledge.property_guide_sections** | id, guide_id, section_type, title, content, sort_order | **knowledge.guidebook_sections** | Rename |

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in knowledge schema:
- Business IDs: DEPT-NN, SEC-{dept}-NNN, MLA-{type}-NNNNNN, DOC-{type}-NNNNNN, EMB-NNNNNN, PGD-{property}
- Department/Section hierarchy for organization
- Asset versioning: version, created_by, change log
- SOP steps: step_number, instruction, expected_duration
- Embeddings: vector, chunk_text, token_count, metadata
- Entity linking: entity_type, entity_id for cross-references
```

---

# SECTION 13: PROPERTY_LISTINGS SCHEMA RECONCILIATION

## Original Property Listings (13 tables) → V4.1 Property Listings (23 tables)

V4.1 significantly expands this schema.

### Table Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **property_listings.listing_content** | content_id (LC-NNNNNN), property_id, title, description, highlights | **property_listings.listings** + **listing_titles** + **listing_descriptions** | Split into multiple tables |
| **property_listings.listing_content_versions** | id, content_id, version, title, description | **property_listings.listing_titles** + **listing_descriptions** | Track versions per field |
| **property_listings.listing_photos** | photo_id (LPH-NNNNNN), property_id, file_url, caption, sort_order, is_primary | **property_listings.listing_photos** | DIRECT MAP |
| **property_listings.listing_photo_tags** | id, photo_id, tag, confidence | **property_listings.listing_photos** | Add tags[] array |
| **property_listings.channel_listings** | channel_listing_id (CL-NNNNNN), property_id, channel, external_listing_id, status | **property_listings.channel_listings** | DIRECT MAP |
| **property_listings.channel_sync_log** | id, channel_listing_id, sync_type, status, synced_at, error_message | **property_listings.channel_sync_logs** | Rename (plural) |
| **property_listings.performance_metrics** | id, property_id, period, views, inquiries, bookings, revenue | **property_listings.listing_performance** | Rename |
| **property_listings.search_rankings** | id, property_id, channel, search_term, rank, captured_at | **property_listings.listing_scores** | Merge into scores |
| **property_listings.competitor_sets** | set_id (CSET-NNNNNN), property_id, set_name | **property_listings.competitor_listings** | Merge |
| **property_listings.competitor_listings** | listing_id (COMP-NNNNNN), set_id, external_url, property_name | **property_listings.competitor_listings** | DIRECT MAP |
| **property_listings.listing_audits** | audit_id (AUD-NNNNNN), property_id, audit_date, auditor_id, score, issues | **property_listings.listing_scores** | Track audits in scores |
| **property_listings.ref_listing_audit_checklist** | id, category, item, weight | **ref.inspection_categories** | Move to ref schema |
| **property_listings.ref_content_types** | id, type_code, type_name | **ref.document_types** | Move to ref schema |

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in property_listings schema:
- Business IDs: LC-NNNNNN, LPH-NNNNNN, CL-NNNNNN, CSET-NNNNNN, COMP-NNNNNN, AUD-NNNNNN
- Photo metadata: caption, sort_order, is_primary, tags
- Channel sync: external_listing_id, sync status, error tracking
- Performance: views, inquiries, bookings, conversion rates
- Search rankings: rank by channel and search term
- Audit tracking: score, issues, auditor
```

---

# SECTION 14: SECURE SCHEMA RECONCILIATION

## Original Secure (2 tables) → V4.1 Secure (5 tables)

V4.1 expands secure schema.

### Table Mapping

| Original Table | V4.1 Target | Notes |
|---------------|-------------|-------|
| **secure.users** | **portal.users** | MOVED to portal schema |
| **secure.contact_entities** | **directory.contacts** | Contact-entity links moved to directory |
| — | **secure.payment_methods** | NEW - encrypted payment data |
| — | **secure.bank_accounts** | NEW - encrypted bank data |
| — | **secure.ssn_data** | NEW - encrypted SSN |
| — | **secure.access_credentials** | NEW - encrypted credentials |
| — | **secure.audit_logs** | NEW - security audit trail |

### Fields to Preserve (CRITICAL)

```
FROM secure.users (→ portal.users):
- user_id (USR-NNNNNN), email, password_hash, user_type, status,
  mfa_enabled, mfa_secret_encrypted, last_login, failed_attempts

FROM secure.contact_entities:
- contact_id, entity_type, entity_id, is_primary
```

---

# SECTION 15: INVENTORY SCHEMA (NEW IN V4.1)

## Source: Original ops.* inventory tables

V4.1 creates a new inventory schema from ops tables.

### Table Mapping from ops

| Original ops Table | V4.1 inventory Target | Notes |
|-------------------|----------------------|-------|
| ops.inventory_items | inventory.inventory_items | DIRECT MAP |
| ops.room_inventory | inventory.room_inventory | DIRECT MAP |
| ops.owner_inventory | inventory.owner_inventory | DIRECT MAP |
| ops.company_inventory | inventory.company_inventory | DIRECT MAP |
| ops.storage_inventory | inventory.storage_inventory | DIRECT MAP |
| ops.storage_locations | inventory.storage_locations | DIRECT MAP |
| ops.inventory_purchases | inventory.inventory_purchases | DIRECT MAP |
| ops.inventory_actions | inventory.inventory_events | Rename actions → events |

### Fields to Preserve from ops

```
FROM ops.inventory_items:
- item_id (ITEM-{type}-NNNN), item_type_id, item_name, sku, brand,
  model_number, default_vendor_id, replacement_item_id, unit_cost,
  par_level, reorder_point, is_active

FROM ops.room_inventory:
- room_id, item_id, quantity, condition, last_inspected_at, inspection_id

FROM ops.storage_inventory:
- item_id, location_id, quantity, last_count_at, counted_by

FROM ops.inventory_purchases:
- po_id (PO-NNNNNN), vendor_id, property_id, ordered_by,
  ordered_at, expected_delivery, received_at, status, total_cost
```

---

# SECTION 16: ANALYTICS SCHEMA (NEW IN V4.1)

V4.1 introduces analytics schema for materialized views.

### Tables to Implement

| V4.1 Table | Purpose | Source Data |
|------------|---------|-------------|
| analytics.property_performance_mv | Property metrics | reservations, finance, service |
| analytics.guest_lifetime_value_mv | Guest LTV | directory.guests, reservations |
| analytics.revenue_summary_mv | Revenue rollups | finance.transactions |
| analytics.occupancy_trends_mv | Occupancy analysis | reservations, pricing |
| analytics.operational_kpis_mv | KPI dashboards | service, team, property |

---

# SECTION 17: COMMS SCHEMA RECONCILIATION

## Original Comms (12 tables) → V4.1 Comms (12 tables)

### Table Mapping

| Original Table | Original Key Fields | V4.1 Target | Notes |
|---------------|---------------------|-------------|-------|
| **comms.channels** | channel_id (CHAN-NNNN), channel_type, channel_name, is_active | **comms.channels** | DIRECT MAP |
| **comms.channel_configs** | config_id (CHCF-NNNNNN), channel_id, config_key, config_value | **comms.channel_configs** | DIRECT MAP |
| **comms.templates** | template_id (TMPL-NNNNNN), template_name, template_type, subject, body | **comms.templates** | DIRECT MAP |
| **comms.template_versions** | id, template_id, version, subject, body, created_at | **comms.template_versions** | DIRECT MAP |
| **comms.template_channels** | id, template_id, channel_id | **comms.templates** | Add channel_ids[] array |
| **comms.threads** | thread_id (THR-NNNNNNNN), contact_id, subject, status, created_at | **comms.messages** | Merge thread concept into messages with thread_id |
| **comms.messages** | message_id (MSG-NNNNNNNN), thread_id, channel_id, direction, content, sent_at | **comms.messages** | DIRECT MAP |
| **comms.calls** | call_id (CALL-NNNNNNNN), contact_id, direction, duration, recording_url, status | **comms.messages** | Track calls as message type='call' |
| **comms.thread_participants** | id, thread_id, contact_id, role | **comms.message_recipients** | Merge |
| **comms.message_recipients** | id, message_id, contact_id, status, delivered_at, read_at | **comms.message_recipients** | DIRECT MAP |
| **comms.message_templates** | id, message_id, template_id | **comms.messages** | Add template_id FK |
| **comms.call_participants** | id, call_id, contact_id, role | **comms.message_recipients** | Merge with type='call' |

### Fields to Preserve (CRITICAL)

```
MUST PRESERVE in comms schema:
- Business IDs: CHAN-NNNN, CHCF-NNNNNN, TMPL-NNNNNN, THR-NNNNNNNN, MSG-NNNNNNNN, CALL-NNNNNNNN
- Thread tracking: thread_id for conversation grouping
- Call data: duration, recording_url, direction
- Delivery tracking: delivered_at, read_at, opened_at, clicked_at
- Template versioning: version history with subject/body changes
```

---

# SUMMARY: ACTIONS REQUIRED

## High Priority (Structure Changes)

| Schema | Action | Tables Affected |
|--------|--------|-----------------|
| external | RESTRUCTURE - use original table design | 6 → 9 tables |
| ai | RENAME tables to preserve business IDs | 18 tables |
| geo | ADD zones, neighborhoods tables | +2 tables |
| homeowner_acquisition | ADD prospect_properties table | +1 table |
| ref | ADD 32 reference tables | +32 tables |

## Medium Priority (Field Additions)

| Schema | Action | Fields |
|--------|--------|--------|
| brand_marketing | Preserve brand voice arrays | tone_attributes[], naming_*, response_* |
| concierge | Preserve venue detail fields | hiking difficulty, beach conditions, etc. |
| revenue | Preserve guest intelligence | lifetime_value, price_sensitivity |
| property_listings | Preserve audit/ranking fields | audit scores, search rankings |

## Low Priority (New Implementation)

| Schema | Action | Tables |
|--------|--------|--------|
| analytics | CREATE materialized views | 5 new tables |
| finance | ADD payroll, budget tables | 6 new tables |
| knowledge | ADD training, policy tables | 10 new tables |

---

# BUSINESS ID PATTERNS TO PRESERVE

All business IDs from original structure must be maintained:

| Schema | Pattern | Examples |
|--------|---------|----------|
| ai | MDL-NNNN, AGT-NNNN, CONV-NNNNNNNN | MDL-0001, AGT-0042 |
| brand | BG-NNNNNN, LOGO-NNNN | BG-010001, LOGO-0005 |
| comms | CHAN-NNNN, MSG-NNNNNNNN | CHAN-0001, MSG-01000042 |
| concierge | BCH-NNNN, RST-NNNNNN, ITN-NNNNNN | BCH-0012, ITN-010042 |
| external | EXT-MGR-NNNNNN, EXT-REV-NNNNNN | EXT-MGR-010001 |
| finance | TRUST-NNNNNN, STMT-NNNNNN | TRUST-010001 |
| geo | ZN-NNNN, AREA-NNNN, POI-NNNNNN | ZN-0001, POI-000042 |
| homeowner_acquisition | HOP-NNNNNN, PROP-NNNNNN | HOP-010042 |
| knowledge | MLA-{type}-NNNNNN, EMB-NNNNNN | MLA-SOP-010001 |
| marketing | CMP-NNNNNN, SP-NNNNNN | CMP-010001 |
| pricing/revenue | BRT-NNNNNN, DYN-NNNNNN | BRT-010001 |
| property_listings | LC-NNNNNN, CL-NNNNNN | LC-010001 |

---

**Document Version:** 1.0
**Created:** December 9, 2025
**Purpose:** Ensure no data requirements lost in V4.1 migration
**Next Steps:** Review with stakeholders, create migration scripts
