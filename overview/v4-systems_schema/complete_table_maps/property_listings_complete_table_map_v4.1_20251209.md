# Property Listings Schema — Complete Table Map v4.1

**Date:** 2025-12-09  
**Schema:** property_listings  
**Tables:** 14  
**Primary Key Standard:** UUIDv7 (time-ordered, globally unique)

---

## Schema Overview

The property_listings schema manages OTA (Online Travel Agency) listing content, distribution, and performance tracking. This includes listing descriptions, photos, channel integrations (Airbnb, VRBO), reviews, competitor analysis, and listing audits. Powers the SCOUT AI agent for listing optimization.

**Key Integrations:**
- Airbnb API — Listing sync, reviews, performance
- VRBO/Expedia API — Listing sync, reviews
- Booking.com — Listing content
- Channel Manager — Multi-platform distribution
- SCOUT AI — Listing optimization and competitor analysis

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
property.properties (external reference)
├─► property_listings.listing_content (property_id) [CASCADE DELETE]
├─► property_listings.listing_photos (property_id) [CASCADE DELETE]
├─► property_listings.channel_listings (property_id) [CASCADE DELETE]
├─► property_listings.performance_metrics (property_id) [CASCADE DELETE]
├─► property_listings.competitor_sets (property_id) [CASCADE DELETE]
├─► property_listings.listing_audits (property_id) [CASCADE DELETE]
└─► property_listings.reviews (property_id) [CASCADE DELETE]

property_listings.listing_content
└─► property_listings.listing_content_versions (listing_content_id) [CASCADE DELETE]

property_listings.listing_photos
└─► property_listings.listing_photo_tags (listing_photo_id) [CASCADE DELETE]

property_listings.channel_listings
├─► property_listings.channel_sync_log (channel_listing_id) [CASCADE DELETE]
├─► property_listings.search_rankings (channel_listing_id) [CASCADE DELETE]
└─► property_listings.reviews (channel_listing_id) [SET NULL]

property_listings.competitor_sets
└─► property_listings.competitor_listings (competitor_set_id) [CASCADE DELETE]
```

**LEGEND:**
- [CASCADE DELETE] — Child records deleted when parent deleted
- [SET NULL] — FK set to NULL when parent deleted

**External References TO property_listings:**
```
reservations.reservations → property_listings.reviews (reservation_id) [SET NULL]
directory.guests → property_listings.reviews (guest_id) [SET NULL]
marketing.content_library → property_listings.listing_photos (library_asset_id) [CASCADE DELETE]
marketing.content → property_listings.listing_content (template_id) [SET NULL]
```

---

# BUSINESS ID CROSS-REFERENCE

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| listing_content | LC-NNNNNN | LC-010001 | 10001 | Airbnb API, VRBO API, Booking.com |
| listing_photos | LPH-NNNNNN | LPH-010001 | 10001 | OTA APIs, Property Portal |
| channel_listings | CL-NNNNNN | CL-010001 | 10001 | Airbnb API, VRBO API, Channel Manager |
| competitor_sets | CSET-NNNNNN | CSET-010001 | 10001 | SCOUT AI, Pricing System |
| competitor_listings | COMP-NNNNNN | COMP-010001 | 10001 | SCOUT AI, Pricing System |
| listing_audits | AUD-NNNNNN | AUD-010001 | 10001 | SCOUT AI, Quality Dashboard |
| reviews | REV-NNNNNN | REV-010001 | 10001 | OTA APIs, Guest Dashboard, Owner Portal |
| listing_content_versions | — | — | — | OTA Sync |
| listing_photo_tags | — | — | — | AI Vision, DAM |
| channel_sync_log | — | — | — | Channel Manager |
| performance_metrics | — | — | — | Analytics Dashboard |
| search_rankings | — | — | — | SCOUT AI |
| ref_listing_audit_checklist | (code) | PHOTO_COUNT | — | SCOUT AI |
| ref_content_types | (code) | HEADLINE | — | Content System |

---

# INDEX COVERAGE SUMMARY

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| property_listings.listing_content | idx_lc_id | listing_content_id (UNIQUE) | Business ID lookup |
| | idx_lc_property | property_id | Property content |
| | idx_lc_channel_type | property_id, channel, content_type (UNIQUE) | One per combo |
| | idx_lc_status | status WHERE status = 'active' | Active content |
| property_listings.listing_content_versions | idx_lcv_content | listing_content_id | Content versions |
| | idx_lcv_version | listing_content_id, version_number | Version lookup |
| property_listings.listing_photos | idx_lph_id | listing_photo_id (UNIQUE) | Business ID lookup |
| | idx_lph_property | property_id | Property photos |
| | idx_lph_asset | library_asset_id | Asset lookup |
| | idx_lph_order | property_id, display_order | Ordered photos |
| | idx_lph_hero | property_id WHERE is_hero = true | Hero images |
| property_listings.listing_photo_tags | idx_lpt_photo | listing_photo_id | Photo tags |
| | idx_lpt_tag | tag | Tag search |
| property_listings.channel_listings | idx_cl_id | channel_listing_id (UNIQUE) | Business ID lookup |
| | idx_cl_property | property_id | Property listings |
| | idx_cl_property_channel | property_id, channel (UNIQUE) | One per combo |
| | idx_cl_external | channel, external_listing_id | External ID lookup |
| | idx_cl_status | status WHERE status = 'active' | Active listings |
| | idx_cl_sync | sync_status WHERE sync_status = 'pending' | Pending syncs |
| property_listings.channel_sync_log | idx_sync_listing | channel_listing_id | Listing sync history |
| | idx_sync_time | synced_at DESC | Chronological |
| | idx_sync_status | status WHERE status = 'error' | Failed syncs |
| property_listings.performance_metrics | idx_perf_property | property_id | Property metrics |
| | idx_perf_composite | property_id, metric_date, channel (UNIQUE) | One per combo |
| | idx_perf_date | metric_date DESC | Date range queries |
| property_listings.search_rankings | idx_rank_listing | channel_listing_id | Listing rankings |
| | idx_rank_checked | checked_at DESC | Chronological |
| property_listings.competitor_sets | idx_cset_id | competitor_set_id (UNIQUE) | Business ID lookup |
| | idx_cset_property | property_id | Property comp sets |
| | idx_cset_active | status WHERE status = 'active' | Active sets |
| property_listings.competitor_listings | idx_comp_id | competitor_listing_id (UNIQUE) | Business ID lookup |
| | idx_comp_set | competitor_set_id | Set listings |
| | idx_comp_external | channel, external_listing_id | External lookup |
| property_listings.listing_audits | idx_aud_id | audit_id (UNIQUE) | Business ID lookup |
| | idx_aud_property | property_id | Property audits |
| | idx_aud_date | audit_date DESC | Chronological |
| | idx_aud_score | overall_score | Score filtering |
| property_listings.reviews | idx_rev_id | review_id (UNIQUE) | Business ID lookup |
| | idx_rev_property | property_id | Property reviews |
| | idx_rev_channel | channel_listing_id | Channel reviews |
| | idx_rev_reservation | reservation_id | Reservation reviews |
| | idx_rev_date | review_date DESC | Chronological |
| | idx_rev_response | response_status WHERE response_status = 'pending' | Pending responses |
| | idx_rev_rating | overall_rating | Rating filtering |

---

# TABLE SPECIFICATIONS

---

## 1. property_listings.listing_content

**PURPOSE:** OTA listing content (descriptions, headlines) per channel. Separate content per platform allows A/B testing and channel-specific optimization. Powers SCOUT AI content recommendations.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| listing_content_id | text | NOT NULL, UNIQUE | Business ID: LC-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property reference | ON DELETE: CASCADE |
| template_id | uuid | FK → marketing.content(id) | Content template used | ON DELETE: SET NULL |
| channel | text | NOT NULL | Channel: airbnb, vrbo, booking, direct, all | |
| content_type | text | NOT NULL | Type: headline, description, space, neighborhood, access, rules | |
| headline | text | | Listing headline/title | |
| description | text | | Main description | |
| space_description | text | | Space/property description | |
| neighborhood_description | text | | Neighborhood/area description | |
| access_description | text | | Guest access instructions | |
| rules_description | text | | House rules text | |
| language | text | DEFAULT 'en' | Content language code | |
| status | text | DEFAULT 'draft' | Status: draft, active, archived | |
| version | integer | DEFAULT 1 | Content version number | |
| performance_score | numeric(5,2) | | AI-calculated performance score | |
| a_b_test_group | text | | A/B test variant | |
| word_count | integer | | Word count for character limits | |
| seo_score | numeric(5,2) | | SEO optimization score | |
| readability_score | numeric(5,2) | | Readability score | |
| last_synced_at | timestamptz | | Last sync to channel | |
| created_by | text | | Who created | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**UNIQUE CONSTRAINT:** (property_id, channel, content_type)

**CHECK CONSTRAINTS:**
- channel IN ('airbnb', 'vrbo', 'booking', 'direct', 'all')
- content_type IN ('headline', 'description', 'space', 'neighborhood', 'access', 'rules', 'summary')
- status IN ('draft', 'active', 'archived', 'pending_review')

---

## 2. property_listings.listing_content_versions

**PURPOSE:** Version history for listing content. Preserves previous versions for rollback and audit. Enables tracking content changes over time.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| listing_content_id | uuid | FK → listing_content(id), NOT NULL | Parent content | ON DELETE: CASCADE |
| version_number | integer | NOT NULL | Version number | |
| content_snapshot | jsonb | NOT NULL | Full content at this version | |
| changed_by | text | | Who made the change | |
| changed_at | timestamptz | DEFAULT now() | When changed | |
| change_reason | text | | Reason for change | |
| change_summary | text | | Summary of changes | |
| performance_at_version | numeric(5,2) | | Performance score at this version | |

**UNIQUE CONSTRAINT:** (listing_content_id, version_number)

---

## 3. property_listings.listing_photos

**PURPOSE:** Photo ordering and metadata for OTA listings. References content_library assets with channel-specific sort order and captions. Supports hero image designation.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| listing_photo_id | text | NOT NULL, UNIQUE | Business ID: LPH-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property reference | ON DELETE: CASCADE |
| library_asset_id | uuid | FK → marketing.content_library(id), NOT NULL | Asset in content library | ON DELETE: CASCADE |
| display_order | integer | NOT NULL | Display order (1 = first) | |
| caption | text | | Photo caption | |
| room_type | text | | Room/space type: bedroom, bathroom, kitchen, living, exterior, pool, view | |
| is_hero | boolean | DEFAULT false | Hero/cover image | |
| channel_orders | jsonb | | Channel-specific ordering: {"airbnb": 1, "vrbo": 3} | |
| ai_description | text | | AI-generated description | |
| ai_quality_score | numeric(5,2) | | AI quality assessment | |
| status | text | DEFAULT 'active' | Status: active, hidden, pending | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- room_type IN ('bedroom', 'bathroom', 'kitchen', 'living', 'dining', 'exterior', 'pool', 'view', 'amenity', 'other')
- status IN ('active', 'hidden', 'pending', 'rejected')

---

## 4. property_listings.listing_photo_tags

**PURPOSE:** Tags for listing photos. Supports both manual and AI-generated tags with confidence scores for auto-tagging. Enables photo search and categorization.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| listing_photo_id | uuid | FK → listing_photos(id), NOT NULL | Parent photo | ON DELETE: CASCADE |
| tag | text | NOT NULL | Tag value | |
| tag_source | text | NOT NULL | Source: manual, ai_vision, ai_caption | |
| confidence_score | numeric(5,4) | | AI confidence (0-1) | |
| created_at | timestamptz | DEFAULT now() | When tagged | |

**UNIQUE CONSTRAINT:** (listing_photo_id, tag)

**CHECK CONSTRAINTS:**
- tag_source IN ('manual', 'ai_vision', 'ai_caption', 'imported')

---

## 5. property_listings.channel_listings

**PURPOSE:** Listings per OTA channel. Tracks external listing IDs, URLs, sync status, and channel-specific badges (Superhost, Guest Favorite). Central record for channel distribution.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| channel_listing_id | text | NOT NULL, UNIQUE | Business ID: CL-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property reference | ON DELETE: CASCADE |
| channel | text | NOT NULL | Channel: airbnb, vrbo, booking, direct | |
| external_listing_id | text | | Channel's listing ID | |
| listing_url | text | | Public listing URL | |
| status | text | DEFAULT 'pending' | Status: active, paused, pending, suspended | |
| sync_status | text | DEFAULT 'pending' | Sync: synced, pending, error, disabled | |
| last_synced_at | timestamptz | | Last successful sync | |
| sync_error_message | text | | Last sync error | |
| badges | jsonb | | Channel badges: {"superhost": true, "guest_favorite": true} | |
| rating | numeric(3,2) | | Current rating (1-5) | |
| review_count | integer | DEFAULT 0 | Number of reviews | |
| response_rate | numeric(5,2) | | Response rate percentage | |
| response_time_hours | numeric(5,2) | | Average response time | |
| acceptance_rate | numeric(5,2) | | Booking acceptance rate | |
| performance_score | numeric(5,2) | | Channel performance score | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**UNIQUE CONSTRAINT:** (property_id, channel)

**CHECK CONSTRAINTS:**
- channel IN ('airbnb', 'vrbo', 'booking', 'direct', 'google', 'tripadvisor')
- status IN ('active', 'paused', 'pending', 'suspended', 'delisted')
- sync_status IN ('synced', 'pending', 'error', 'disabled')

---

## 6. property_listings.channel_sync_log

**PURPOSE:** Sync history between Central Memory and OTA channels. Tracks what changed, sync direction, success/failure, and error messages. Essential for debugging sync issues.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| channel_listing_id | uuid | FK → channel_listings(id), NOT NULL | Channel listing | ON DELETE: CASCADE |
| sync_type | text | NOT NULL | Type: full, partial, content_only, photos_only, pricing, availability | |
| sync_direction | text | NOT NULL | Direction: push, pull, bidirectional | |
| synced_at | timestamptz | DEFAULT now() | When sync occurred | |
| status | text | NOT NULL | Status: success, error, partial | |
| changes | jsonb | | What changed: {"headline": true, "photos": [1,2,3]} | |
| error_message | text | | Error details if failed | |
| error_code | text | | Error code from channel | |
| request_payload | jsonb | | Request sent (for debugging) | |
| response_payload | jsonb | | Response received | |
| duration_ms | integer | | Sync duration | |
| triggered_by | text | | Who/what triggered: user, scheduled, webhook | |

**CHECK CONSTRAINTS:**
- sync_type IN ('full', 'partial', 'content_only', 'photos_only', 'pricing', 'availability', 'calendar')
- sync_direction IN ('push', 'pull', 'bidirectional')
- status IN ('success', 'error', 'partial', 'skipped')

---

## 7. property_listings.performance_metrics

**PURPOSE:** Property listing performance by day by channel. Tracks visibility (impressions, views), conversion (inquiries, bookings), and revenue metrics. Powers SCOUT AI recommendations.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property reference | ON DELETE: CASCADE |
| metric_date | date | NOT NULL | Date of metrics | |
| channel | text | NOT NULL | Channel source | |
| impressions | integer | DEFAULT 0 | Search impressions | |
| page_views | integer | DEFAULT 0 | Listing page views | |
| unique_visitors | integer | DEFAULT 0 | Unique visitors | |
| saved_count | integer | DEFAULT 0 | Times saved/wishlisted | |
| share_count | integer | DEFAULT 0 | Times shared | |
| inquiries | integer | DEFAULT 0 | Booking inquiries | |
| instant_books | integer | DEFAULT 0 | Instant bookings | |
| request_to_books | integer | DEFAULT 0 | Request to book | |
| bookings | integer | DEFAULT 0 | Confirmed bookings | |
| booking_value | numeric(12,2) | | Total booking revenue | |
| cancellations | integer | DEFAULT 0 | Cancellations | |
| view_to_inquiry_rate | numeric(5,4) | | Conversion rate | |
| inquiry_to_book_rate | numeric(5,4) | | Conversion rate | |
| avg_daily_rate | numeric(12,2) | | ADR for bookings | |
| search_rank_avg | numeric(5,2) | | Average search position | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**UNIQUE CONSTRAINT:** (property_id, metric_date, channel)

---

## 8. property_listings.search_rankings

**PURPOSE:** Search ranking history. Tracks where listings appear in search results for various search criteria (location, dates, guests). Powers ranking optimization.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| channel_listing_id | uuid | FK → channel_listings(id), NOT NULL | Channel listing | ON DELETE: CASCADE |
| search_criteria | jsonb | NOT NULL | Search params: {"location": "Kaanapali", "dates": "2025-03-15/2025-03-22", "guests": 4} | |
| position | integer | NOT NULL | Rank position (1 = top) | |
| page_number | integer | | Page in results | |
| total_results | integer | | Total listings in search | |
| above_fold | boolean | | Visible without scrolling | |
| checked_at | timestamptz | DEFAULT now() | When checked | |
| competitor_positions | jsonb | | Nearby competitors: {"COMP-010001": 3, "COMP-010002": 7} | |

---

## 9. property_listings.competitor_sets

**PURPOSE:** Competitor sets for each property. Groups competitor listings for comparison and pricing intelligence. Defines the competitive landscape per property.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| competitor_set_id | text | NOT NULL, UNIQUE | Business ID: CSET-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Our property | ON DELETE: CASCADE |
| set_name | text | NOT NULL | Set name: "Primary Competitors", "Premium Segment" | |
| set_type | text | | Type: primary, secondary, aspirational | |
| criteria | jsonb | | Selection criteria: {"bedrooms": 3, "area": "Kaanapali", "rating_min": 4.5} | |
| auto_refresh | boolean | DEFAULT false | Auto-refresh competitor list | |
| refresh_frequency_days | integer | | Days between auto-refresh | |
| last_refreshed_at | timestamptz | | Last refresh date | |
| status | text | DEFAULT 'active' | Status: active, archived | |
| notes | text | | Internal notes | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- set_type IN ('primary', 'secondary', 'aspirational', 'budget')
- status IN ('active', 'archived')

---

## 10. property_listings.competitor_listings

**PURPOSE:** Individual competitor listings. Tracks competitor property details, pricing, performance estimates, and AI analysis for competitive positioning.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| competitor_listing_id | text | NOT NULL, UNIQUE | Business ID: COMP-NNNNNN | N/A |
| competitor_set_id | uuid | FK → competitor_sets(id), NOT NULL | Parent set | ON DELETE: CASCADE |
| channel | text | NOT NULL | Source channel | |
| external_listing_id | text | NOT NULL | Channel's listing ID | |
| listing_url | text | | Public URL | |
| property_name | text | | Listing title | |
| host_name | text | | Host/PM name | |
| bedrooms | integer | | Bedroom count | |
| bathrooms | numeric(3,1) | | Bathroom count | |
| max_guests | integer | | Max occupancy | |
| property_type | text | | condo, house, villa | |
| rating | numeric(3,2) | | Current rating | |
| review_count | integer | | Review count | |
| superhost | boolean | | Superhost/Premier status | |
| instant_book | boolean | | Instant book enabled | |
| avg_nightly_rate | numeric(12,2) | | Average nightly rate | |
| min_nightly_rate | numeric(12,2) | | Minimum rate observed | |
| max_nightly_rate | numeric(12,2) | | Maximum rate observed | |
| cleaning_fee | numeric(12,2) | | Cleaning fee | |
| estimated_occupancy | numeric(5,2) | | Estimated occupancy % | |
| estimated_revenue | numeric(12,2) | | Estimated monthly revenue | |
| amenities | text[] | | Key amenities | |
| photos_count | integer | | Number of photos | |
| response_rate | numeric(5,2) | | Response rate | |
| ai_analysis | jsonb | | SCOUT AI analysis: strengths, weaknesses, opportunities | |
| ai_price_position | text | | Price position: underpriced, competitive, premium | |
| last_scraped_at | timestamptz | | Last data refresh | |
| is_active | boolean | DEFAULT true | Still active listing | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**UNIQUE CONSTRAINT:** (competitor_set_id, channel, external_listing_id)

---

## 11. property_listings.listing_audits

**PURPOSE:** Listing quality audits. Comprehensive scoring across photos, content, pricing, reviews, and calendar. Includes AI recommendations and estimated revenue impact.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| audit_id | text | NOT NULL, UNIQUE | Business ID: AUD-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property reference | ON DELETE: CASCADE |
| audit_date | date | NOT NULL | Audit date | |
| audit_type | text | NOT NULL | Type: scheduled, manual, triggered | |
| audited_by | text | | Who/what performed audit | |
| overall_score | numeric(5,2) | NOT NULL | Overall score (0-100) | |
| photo_score | numeric(5,2) | | Photo quality score | |
| photo_issues | jsonb | | Photo issues found | |
| content_score | numeric(5,2) | | Content quality score | |
| content_issues | jsonb | | Content issues found | |
| pricing_score | numeric(5,2) | | Pricing competitiveness | |
| pricing_issues | jsonb | | Pricing issues found | |
| review_score | numeric(5,2) | | Review health score | |
| review_issues | jsonb | | Review issues found | |
| calendar_score | numeric(5,2) | | Calendar optimization | |
| calendar_issues | jsonb | | Calendar issues found | |
| response_score | numeric(5,2) | | Response rate/time score | |
| issues | jsonb | | All issues combined | |
| recommendations | jsonb | | AI recommendations with priority | |
| estimated_revenue_impact | numeric(12,2) | | Potential revenue if fixed | |
| compared_to_competitors | jsonb | | Competitor comparison | |
| previous_audit_id | uuid | | Previous audit for trending | |
| score_change | numeric(5,2) | | Change from previous | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**CHECK CONSTRAINTS:**
- audit_type IN ('scheduled', 'manual', 'triggered', 'onboarding')
- overall_score BETWEEN 0 AND 100

---

## 12. property_listings.reviews

**PURPOSE:** Guest reviews from OTA channels. Tracks ratings across all dimensions, review text, our responses, and AI sentiment analysis. Links to reservations and channel listings.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| review_id | text | NOT NULL, UNIQUE | Business ID: REV-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property reference | ON DELETE: CASCADE |
| channel_listing_id | uuid | FK → channel_listings(id) | Channel listing | ON DELETE: SET NULL |
| reservation_id | uuid | FK → reservations.reservations(id) | Related reservation | ON DELETE: SET NULL |
| guest_id | uuid | FK → directory.guests(id) | Reviewing guest | ON DELETE: SET NULL |
| channel | text | NOT NULL | Source channel | |
| external_review_id | text | | Channel's review ID | |
| review_date | date | NOT NULL | When review posted | |
| overall_rating | numeric(3,2) | NOT NULL | Overall rating (1-5) | |
| cleanliness_rating | numeric(3,2) | | Cleanliness (1-5) | |
| accuracy_rating | numeric(3,2) | | Accuracy (1-5) | |
| checkin_rating | numeric(3,2) | | Check-in (1-5) | |
| communication_rating | numeric(3,2) | | Communication (1-5) | |
| location_rating | numeric(3,2) | | Location (1-5) | |
| value_rating | numeric(3,2) | | Value (1-5) | |
| public_review | text | | Public review text | |
| private_feedback | text | | Private feedback to host | |
| reviewer_name | text | | Guest name | |
| reviewer_photo_url | text | | Guest photo | |
| our_response | text | | Our public response | |
| response_status | text | DEFAULT 'pending' | Status: pending, drafted, published, skipped | |
| responded_at | timestamptz | | When we responded | |
| responded_by | text | | Who responded | |
| ai_sentiment | text | | AI sentiment: positive, neutral, negative, mixed | |
| ai_sentiment_score | numeric(5,4) | | Sentiment score (-1 to 1) | |
| ai_themes | text[] | | AI-extracted themes | |
| ai_suggested_response | text | | AI draft response | |
| requires_attention | boolean | DEFAULT false | Needs team attention | |
| attention_reason | text | | Why needs attention | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- overall_rating BETWEEN 1 AND 5
- response_status IN ('pending', 'drafted', 'published', 'skipped', 'not_required')
- ai_sentiment IN ('positive', 'neutral', 'negative', 'mixed')

---

## 13. property_listings.ref_listing_audit_checklist

**PURPOSE:** Standard audit checklist items. Defines what gets checked during listing audits, severity if failed, and scoring weights. Reference table for SCOUT AI.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| checklist_code | text | NOT NULL, UNIQUE | Unique code | N/A |
| category | text | NOT NULL | Category: photos, content, pricing, reviews, calendar | |
| item_name | text | NOT NULL | Check item name | |
| description | text | | What is checked | |
| severity | text | NOT NULL | Severity if failed: critical, high, medium, low | |
| weight | numeric(5,2) | NOT NULL | Scoring weight | |
| auto_check | boolean | DEFAULT true | Can be auto-checked | |
| check_logic | jsonb | | Auto-check logic | |
| recommendation_template | text | | Template for recommendations | |
| is_active | boolean | DEFAULT true | Currently active | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**CHECK CONSTRAINTS:**
- category IN ('photos', 'content', 'pricing', 'reviews', 'calendar', 'response')
- severity IN ('critical', 'high', 'medium', 'low')

**NO FOREIGN KEYS** — Reference table

---

## 14. property_listings.ref_content_types

**PURPOSE:** Valid content types for listings. Defines content categories with channel requirements, character limits, and examples.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| content_type_code | text | NOT NULL, UNIQUE | Unique code | N/A |
| content_type_name | text | NOT NULL | Display name | |
| description | text | | What this content is for | |
| channel | text | | Specific channel or 'all' | |
| min_length | integer | | Minimum character count | |
| max_length | integer | | Maximum character count | |
| required | boolean | DEFAULT false | Required for channel | |
| example | text | | Example content | |
| best_practices | text | | Writing guidelines | |
| is_active | boolean | DEFAULT true | Currently active | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**NO FOREIGN KEYS** — Reference table

---

# CROSS-SCHEMA DEPENDENCIES

## Property Listings → Other Schemas

| Target Schema.Table | FK Column | Purpose |
|---------------------|-----------|---------|
| property.properties | property_id | Property being listed |
| reservations.reservations | reservation_id | Reservation for review |
| directory.guests | guest_id | Guest who reviewed |
| marketing.content_library | library_asset_id | Photo assets |
| marketing.content | template_id | Content templates |

## Other Schemas → Property Listings

| Source Schema.Table | References | Purpose |
|---------------------|------------|---------|
| revenue.pricing_rules | channel_listings | Channel-specific pricing |
| ai.agents (SCOUT) | all tables | Listing optimization |
| analytics.listing_performance_mv | performance_metrics | Dashboard views |

---

# KEY WORKFLOWS

## 1. Listing Content Creation

```
1. Create listing_content record (draft)
2. Generate content via BENSON AI or manual
3. Review and edit content
4. Set status = 'active'
5. Sync to channel via channel_sync_log
6. Track performance in performance_metrics
```

## 2. Photo Management

```
1. Upload photo to marketing.content_library
2. Create listing_photos record linking asset
3. AI generates tags → listing_photo_tags
4. Set display_order and is_hero
5. Set channel_orders for platform-specific ordering
6. Sync to channels
```

## 3. Review Response Workflow

```
1. Review imported from OTA → reviews table
2. AI generates sentiment + suggested response
3. If requires_attention = true, alert team
4. Draft response (ai_suggested_response or manual)
5. Set response_status = 'drafted'
6. Approve and publish → response_status = 'published'
7. Sync response to channel
```

## 4. Competitor Analysis

```
1. Create competitor_sets with criteria
2. SCOUT AI identifies competitors → competitor_listings
3. Periodic refresh of competitor data
4. AI analysis populates ai_analysis, ai_price_position
5. Compare in listing_audits
6. Generate recommendations
```

## 5. Listing Audit Cycle

```
1. Scheduled or triggered audit
2. Check all ref_listing_audit_checklist items
3. Calculate scores per category
4. Generate issues and recommendations
5. Estimate revenue_impact
6. Compare to previous_audit_id for trending
7. Alert if critical issues found
```

---

# REF TABLE SAMPLE DATA

## ref_listing_audit_checklist

| checklist_code | category | item_name | severity | weight |
|----------------|----------|-----------|----------|--------|
| PHOTO_COUNT | photos | Minimum Photo Count | critical | 15 |
| PHOTO_QUALITY | photos | Photo Resolution/Quality | high | 10 |
| HERO_IMAGE | photos | Hero Image Quality | high | 10 |
| HEADLINE_LENGTH | content | Headline Character Count | medium | 5 |
| DESCRIPTION_COMPLETENESS | content | Full Description | high | 10 |
| RESPONSE_RATE | response | Response Rate >90% | critical | 15 |
| RESPONSE_TIME | response | Response Time <1hr | high | 10 |
| REVIEW_RATING | reviews | Rating Above 4.5 | high | 10 |
| CALENDAR_ACCURACY | calendar | Calendar Up to Date | critical | 15 |

## ref_content_types

| content_type_code | channel | min_length | max_length | required |
|-------------------|---------|------------|------------|----------|
| HEADLINE | airbnb | 20 | 50 | true |
| HEADLINE | vrbo | 20 | 80 | true |
| DESCRIPTION | airbnb | 500 | 2000 | true |
| DESCRIPTION | vrbo | 400 | 5000 | true |
| SPACE | airbnb | 100 | 1000 | false |
| NEIGHBORHOOD | airbnb | 100 | 1000 | false |
| ACCESS | airbnb | 50 | 500 | false |
| RULES | all | 50 | 1000 | true |

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-09  
**UUIDv7 Migration:** V4.1 Schema Specification  
**Total Tables:** 14
