# Marketing Schema — Complete Table Map v4.1

**Date:** 2025-12-09  
**Schema:** marketing  
**Tables:** 24  
**Primary Key Standard:** UUIDv7 (time-ordered, globally unique)

---

## Schema Overview

The marketing schema manages content creation, campaigns, social media, calendars, segmentation, and attribution. This is the operational hub for BENSON AI (content generation) and AURA AI (social media). Handles both company-wide and property-level marketing activities.

**Key Integrations:**
- BENSON AI — Content generation
- AURA AI — Social media management
- Meta API — Instagram/Facebook
- TikTok API — TikTok posting
- Email Platform — Campaign sends
- Analytics — Attribution tracking

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
property.properties (external)
├─► marketing.content (property_id) [SET NULL]
├─► marketing.property_content (property_id) [CASCADE DELETE]
├─► marketing.content_strategy (property_id) [CASCADE DELETE]
├─► marketing.content_calendars (property_id) [SET NULL]
├─► marketing.campaigns (property_id) [SET NULL]
├─► marketing.social_accounts (property_id) [CASCADE DELETE]
└─► marketing.websites (property_id) [SET NULL]

directory.contacts (external)
├─► marketing.segment_members (contact_id) [CASCADE DELETE]
├─► marketing.calendar_items (owner_contact_id) [SET NULL]
└─► marketing.campaign_events (contact_id) [CASCADE DELETE]

reservations.reservations (external)
└─► marketing.attribution (reservation_id) [CASCADE DELETE]

marketing.content
├─► marketing.content (template_id) [SELF-REFERENCE - SET NULL]
├─► marketing.content_versions (content_id) [CASCADE DELETE]
├─► marketing.content_usage (content_id) [CASCADE DELETE]
├─► marketing.content_components (parent_content_id) [CASCADE DELETE]
├─► marketing.content_components (component_content_id) [SET NULL]
├─► marketing.social_posts (content_id) [SET NULL]
├─► marketing.calendar_items (content_id) [SET NULL]
└─► marketing.website_pages (content_id) [SET NULL]

marketing.content_library
├─► marketing.property_content (library_asset_id) [CASCADE DELETE]
├─► marketing.content_usage (library_asset_id) [CASCADE DELETE]
├─► marketing.content_components (component_asset_id) [SET NULL]
├─► marketing.calendar_items (library_asset_id) [SET NULL]
└─► property_listings.listing_photos (library_asset_id) [CASCADE DELETE]

marketing.content_strategy
└─► marketing.content_calendars (content_strategy_id) [SET NULL]

marketing.content_calendars
└─► marketing.calendar_items (calendar_id) [CASCADE DELETE]

marketing.campaigns
├─► marketing.campaign_events (campaign_id) [CASCADE DELETE]
├─► marketing.content_calendars (campaign_id) [SET NULL]
├─► marketing.social_posts (campaign_id) [SET NULL]
└─► marketing.attribution (first/last_touch_campaign_id) [SET NULL]

marketing.segments
├─► marketing.segment_members (segment_id) [CASCADE DELETE]
└─► marketing.campaigns (segment_id) [SET NULL]

marketing.social_accounts
├─► marketing.social_posts (account_id) [CASCADE DELETE]
└─► marketing.social_account_metrics (account_id) [CASCADE DELETE]

marketing.social_posts
├─► marketing.social_analytics (post_id) [CASCADE DELETE]
└─► marketing.calendar_items (published_post_id) [SET NULL]

marketing.websites
└─► marketing.website_pages (website_id) [CASCADE DELETE]
```

---

# BUSINESS ID CROSS-REFERENCE

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| content | CON-NNNNNN | CON-010001 | 10001 | BENSON AI, CMS |
| content_library | ASSET-NNNNNN | ASSET-010001 | 10001 | S3, DAM System |
| content_strategy | STRAT-NNNNNN | STRAT-010001 | 10001 | AURA AI |
| content_calendars | CAL-NNNNNN | CAL-010001 | 10001 | Social Scheduler |
| calendar_items | CI-NNNNNN | CI-010001 | 10001 | Monday.com |
| campaigns | CMP-NNNNNN | CMP-010001 | 10001 | Email Platform |
| campaign_events | CEVT-NNNNNN | CEVT-010001 | 10001 | Email Platform |
| segments | SEG-NNNNNN | SEG-010001 | 10001 | Email Platform |
| social_accounts | SA-NNNNNN | SA-010001 | 10001 | Meta API, TikTok |
| social_posts | SP-NNNNNN | SP-010001 | 10001 | Meta API, TikTok |
| websites | WEB-NNNNNN | WEB-010001 | 10001 | CMS |

---

# INDEX COVERAGE SUMMARY

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| marketing.content | idx_content_id | content_id (UNIQUE) | Business ID |
| | idx_content_property | property_id | Property content |
| | idx_content_type | content_type | Filter by type |
| | idx_content_template | is_template WHERE true | Templates only |
| marketing.content_library | idx_asset_id | asset_id (UNIQUE) | Business ID |
| | idx_asset_type | asset_type | Filter by type |
| | idx_asset_tags | tags USING GIN | Tag search |
| marketing.content_calendars | idx_cal_id | calendar_id (UNIQUE) | Business ID |
| | idx_cal_property | property_id | Property calendars |
| marketing.calendar_items | idx_ci_id | calendar_item_id (UNIQUE) | Business ID |
| | idx_ci_calendar | calendar_id | Calendar items |
| | idx_ci_scheduled | scheduled_date | Date filtering |
| marketing.campaigns | idx_cmp_id | campaign_id (UNIQUE) | Business ID |
| | idx_cmp_status | status | Active campaigns |
| | idx_cmp_dates | start_date, end_date | Date range |
| marketing.segments | idx_seg_id | segment_id (UNIQUE) | Business ID |
| marketing.social_accounts | idx_sa_id | social_account_id (UNIQUE) | Business ID |
| | idx_sa_property | property_id | Property accounts |
| | idx_sa_platform | platform | Platform filter |
| marketing.social_posts | idx_sp_id | social_post_id (UNIQUE) | Business ID |
| | idx_sp_account | account_id | Account posts |
| | idx_sp_scheduled | scheduled_at | Scheduling |
| marketing.websites | idx_web_id | website_id (UNIQUE) | Business ID |

---

# TABLE SPECIFICATIONS

---

## 1. marketing.content

**PURPOSE:** All content pieces and templates. Templates (is_template=true) can be referenced by other content. Property-level content has property_id set; company-wide content has NULL.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| content_id | text | NOT NULL, UNIQUE | Business ID: CON-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id) | Property (NULL = company-wide) | ON DELETE: SET NULL |
| template_id | uuid | FK → marketing.content(id) | Template used | ON DELETE: SET NULL |
| title | text | NOT NULL | Content title | |
| content_type | text | NOT NULL | Type: blog, social, email, landing, description | |
| content_body | text | | Content text/markdown | |
| content_html | text | | HTML version | |
| excerpt | text | | Short excerpt/summary | |
| meta_title | text | | SEO title | |
| meta_description | text | | SEO description | |
| keywords | text[] | | SEO keywords | |
| is_template | boolean | DEFAULT false | Is this a template | |
| version | integer | DEFAULT 1 | Version number | |
| status | text | DEFAULT 'draft' | Status: draft, review, approved, published | |
| published_at | timestamptz | | When published | |
| author | text | | Author name | |
| ai_generated | boolean | DEFAULT false | Generated by AI | |
| ai_model | text | | AI model used | |
| tone | text | | Content tone | |
| target_audience | text | | Target audience | |
| word_count | integer | | Word count | |
| reading_time_min | integer | | Estimated read time | |
| performance_score | numeric(5,2) | | Performance score | |
| tags | text[] | | Searchable tags | |
| created_by | text | | Who created | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- content_type IN ('blog', 'social', 'email', 'landing', 'description', 'ad_copy', 'newsletter', 'guide')
- status IN ('draft', 'review', 'approved', 'published', 'archived')

---

## 2. marketing.content_versions

**PURPOSE:** Version history for content. Each edit creates new version preserving content at that point.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| content_id | uuid | FK → content(id), NOT NULL | Parent content | ON DELETE: CASCADE |
| version_number | integer | NOT NULL | Version number | |
| content_snapshot | jsonb | NOT NULL | Full content at version | |
| changed_by | text | | Who changed | |
| changed_at | timestamptz | DEFAULT now() | When changed | |
| change_summary | text | | Summary of changes | |

**UNIQUE CONSTRAINT:** (content_id, version_number)

---

## 3. marketing.content_library

**PURPOSE:** Central file/asset repository for all media. Referenced by property_content for property associations.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| asset_id | text | NOT NULL, UNIQUE | Business ID: ASSET-NNNNNN | N/A |
| filename | text | NOT NULL | Original filename | |
| asset_type | text | NOT NULL | Type: image, video, document, audio | |
| mime_type | text | | MIME type | |
| file_url | text | NOT NULL | Storage URL | |
| thumbnail_url | text | | Thumbnail URL | |
| file_size_bytes | bigint | | File size | |
| dimensions | jsonb | | {"width": 1920, "height": 1080} | |
| duration_seconds | integer | | Video/audio duration | |
| alt_text | text | | Accessibility alt text | |
| caption | text | | Default caption | |
| tags | text[] | | Searchable tags | |
| ai_tags | text[] | | AI-generated tags | |
| ai_description | text | | AI-generated description | |
| color_palette | jsonb | | Extracted colors | |
| focal_point | jsonb | | {"x": 0.5, "y": 0.3} | |
| orientation | text | | landscape, portrait, square | |
| license_type | text | | License info | |
| source | text | | Where asset came from | |
| photographer | text | | Photographer credit | |
| status | text | DEFAULT 'active' | Status | |
| created_by | text | | Who uploaded | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- asset_type IN ('image', 'video', 'document', 'audio', 'pdf', '3d_tour')
- orientation IN ('landscape', 'portrait', 'square')
- status IN ('active', 'archived', 'processing', 'error')

**NO FOREIGN KEYS** — Central repository

---

## 4. marketing.property_content

**PURPOSE:** Join table linking properties to content assets with display order and hero flags.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property | ON DELETE: CASCADE |
| library_asset_id | uuid | FK → content_library(id), NOT NULL | Asset | ON DELETE: CASCADE |
| display_order | integer | DEFAULT 0 | Display order | |
| is_hero | boolean | DEFAULT false | Hero image | |
| channel_orders | jsonb | | {"airbnb": 1, "vrbo": 3} | |
| room_type | text | | Room association | |
| status | text | DEFAULT 'active' | Status | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**UNIQUE CONSTRAINT:** (property_id, library_asset_id)

---

## 5. marketing.content_usage

**PURPOSE:** Tracks where content/assets are used (campaigns, posts, pages).

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| content_id | uuid | FK → content(id) | Content piece | ON DELETE: CASCADE |
| library_asset_id | uuid | FK → content_library(id) | Asset | ON DELETE: CASCADE |
| usage_type | text | NOT NULL | Type: campaign, social_post, website, email | |
| usage_id | uuid | NOT NULL | ID of where used | |
| usage_context | text | | Additional context | |
| used_at | timestamptz | DEFAULT now() | When used | |

**CHECK:** At least one of content_id or library_asset_id must be NOT NULL

---

## 6. marketing.content_components

**PURPOSE:** Tracks content composition (which pieces/assets make up larger content).

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| parent_content_id | uuid | FK → content(id), NOT NULL | Parent content | ON DELETE: CASCADE |
| component_content_id | uuid | FK → content(id) | Child content | ON DELETE: SET NULL |
| component_asset_id | uuid | FK → content_library(id) | Child asset | ON DELETE: SET NULL |
| component_type | text | | Type: header, body, image, cta | |
| position | integer | | Position in parent | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

---

## 7. marketing.content_strategy

**PURPOSE:** Content strategy per property defining themes, frequency, and goals.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| strategy_id | text | NOT NULL, UNIQUE | Business ID: STRAT-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property | ON DELETE: CASCADE |
| strategy_name | text | NOT NULL | Strategy name | |
| goals | jsonb | | Goals and KPIs | |
| themes | text[] | | Content themes | |
| posting_frequency | jsonb | | {"instagram": "3/week", "facebook": "2/week"} | |
| target_audience | text | | Target audience | |
| tone_guidelines | text | | Tone notes | |
| status | text | DEFAULT 'draft' | Status | |
| effective_date | date | | Start date | |
| review_date | date | | Next review | |
| created_by | text | | Who created | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

---

## 8. marketing.content_calendars

**PURPOSE:** Content calendars for planning and scheduling.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| calendar_id | text | NOT NULL, UNIQUE | Business ID: CAL-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id) | Property (NULL = company) | ON DELETE: SET NULL |
| content_strategy_id | uuid | FK → content_strategy(id) | Strategy | ON DELETE: SET NULL |
| campaign_id | uuid | FK → campaigns(id) | Campaign | ON DELETE: SET NULL |
| calendar_name | text | NOT NULL | Calendar name | |
| calendar_type | text | | Type: social, blog, email | |
| start_date | date | | Calendar start | |
| end_date | date | | Calendar end | |
| status | text | DEFAULT 'active' | Status | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

---

## 9. marketing.calendar_items

**PURPOSE:** Individual items on content calendars.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| calendar_item_id | text | NOT NULL, UNIQUE | Business ID: CI-NNNNNN | N/A |
| calendar_id | uuid | FK → content_calendars(id), NOT NULL | Calendar | ON DELETE: CASCADE |
| content_id | uuid | FK → content(id) | Content piece | ON DELETE: SET NULL |
| library_asset_id | uuid | FK → content_library(id) | Asset | ON DELETE: SET NULL |
| published_post_id | uuid | FK → social_posts(id) | Published post | ON DELETE: SET NULL |
| owner_contact_id | uuid | FK → directory.contacts(id) | Owner | ON DELETE: SET NULL |
| title | text | NOT NULL | Item title | |
| description | text | | Description | |
| content_type | text | | Type: post, story, reel, blog | |
| platform | text | | Target platform | |
| scheduled_date | date | NOT NULL | Scheduled date | |
| scheduled_time | time | | Scheduled time | |
| status | text | DEFAULT 'planned' | Status: planned, created, scheduled, published | |
| priority | text | DEFAULT 'normal' | Priority | |
| tags | text[] | | Tags | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

---

## 10. marketing.campaigns

**PURPOSE:** Marketing campaign definitions.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| campaign_id | text | NOT NULL, UNIQUE | Business ID: CMP-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id) | Property (NULL = company) | ON DELETE: SET NULL |
| segment_id | uuid | FK → segments(id) | Target segment | ON DELETE: SET NULL |
| campaign_name | text | NOT NULL | Campaign name | |
| campaign_type | text | NOT NULL | Type: email, social, paid, retargeting | |
| goal | text | | Campaign goal | |
| budget | numeric(12,2) | | Budget | |
| start_date | date | | Start date | |
| end_date | date | | End date | |
| status | text | DEFAULT 'draft' | Status | |
| target_metrics | jsonb | | Target KPIs | |
| actual_metrics | jsonb | | Actual results | |
| created_by | text | | Who created | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- campaign_type IN ('email', 'social', 'paid', 'retargeting', 'sms', 'multi_channel')
- status IN ('draft', 'scheduled', 'active', 'paused', 'completed', 'cancelled')

---

## 11. marketing.campaign_events

**PURPOSE:** Individual events/interactions in campaigns.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| campaign_event_id | text | NOT NULL, UNIQUE | Business ID: CEVT-NNNNNN | N/A |
| campaign_id | uuid | FK → campaigns(id), NOT NULL | Campaign | ON DELETE: CASCADE |
| contact_id | uuid | FK → directory.contacts(id), NOT NULL | Contact | ON DELETE: CASCADE |
| event_type | text | NOT NULL | Type: sent, delivered, opened, clicked, converted | |
| event_timestamp | timestamptz | DEFAULT now() | When occurred | |
| event_data | jsonb | | Event details | |
| channel | text | | Channel | |
| device_type | text | | Device | |
| location | text | | Location | |

**CHECK CONSTRAINTS:**
- event_type IN ('sent', 'delivered', 'opened', 'clicked', 'converted', 'bounced', 'unsubscribed', 'complained')

---

## 12. marketing.segments

**PURPOSE:** Guest/contact segments for targeting.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| segment_id | text | NOT NULL, UNIQUE | Business ID: SEG-NNNNNN | N/A |
| segment_name | text | NOT NULL | Segment name | |
| segment_type | text | | Type: static, dynamic | |
| description | text | | Description | |
| criteria | jsonb | | Filter criteria | |
| member_count | integer | DEFAULT 0 | Current count | |
| last_calculated_at | timestamptz | | Last refresh | |
| auto_refresh | boolean | DEFAULT false | Auto-refresh | |
| status | text | DEFAULT 'active' | Status | |
| created_by | text | | Who created | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

---

## 13. marketing.segment_members

**PURPOSE:** Members of segments.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| segment_id | uuid | FK → segments(id), NOT NULL | Segment | ON DELETE: CASCADE |
| contact_id | uuid | FK → directory.contacts(id), NOT NULL | Contact | ON DELETE: CASCADE |
| added_at | timestamptz | DEFAULT now() | When added | |
| added_by | text | | How added: manual, rule, import | |
| removed_at | timestamptz | | When removed | |

**UNIQUE CONSTRAINT:** (segment_id, contact_id)

---

## 14. marketing.social_accounts

**PURPOSE:** Social media accounts (company and property level).

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| social_account_id | text | NOT NULL, UNIQUE | Business ID: SA-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id) | Property (NULL = company) | ON DELETE: CASCADE |
| platform | text | NOT NULL | Platform: instagram, facebook, tiktok, youtube | |
| account_name | text | NOT NULL | Account name | |
| handle | text | | @handle | |
| profile_url | text | | Profile URL | |
| external_account_id | text | | Platform's account ID | |
| access_token | text | | Encrypted access token | |
| token_expires_at | timestamptz | | Token expiration | |
| follower_count | integer | DEFAULT 0 | Followers | |
| following_count | integer | DEFAULT 0 | Following | |
| post_count | integer | DEFAULT 0 | Total posts | |
| status | text | DEFAULT 'active' | Status | |
| last_synced_at | timestamptz | | Last sync | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**UNIQUE CONSTRAINT:** (property_id, platform) WHERE property_id IS NOT NULL

**CHECK CONSTRAINTS:**
- platform IN ('instagram', 'facebook', 'tiktok', 'youtube', 'twitter', 'linkedin', 'pinterest')

---

## 15. marketing.social_posts

**PURPOSE:** Social media posts (scheduled and published).

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| social_post_id | text | NOT NULL, UNIQUE | Business ID: SP-NNNNNN | N/A |
| account_id | uuid | FK → social_accounts(id), NOT NULL | Account | ON DELETE: CASCADE |
| campaign_id | uuid | FK → campaigns(id) | Campaign | ON DELETE: SET NULL |
| content_id | uuid | FK → content(id) | Content | ON DELETE: SET NULL |
| post_type | text | NOT NULL | Type: post, story, reel, video | |
| caption | text | | Post caption | |
| media_urls | text[] | | Media URLs | |
| hashtags | text[] | | Hashtags | |
| mentions | text[] | | @mentions | |
| link_url | text | | Link in post | |
| location_tag | text | | Location tag | |
| scheduled_at | timestamptz | | Scheduled time | |
| published_at | timestamptz | | Actual publish time | |
| external_post_id | text | | Platform's post ID | |
| external_url | text | | Post URL | |
| status | text | DEFAULT 'draft' | Status | |
| ai_generated | boolean | DEFAULT false | AI generated | |
| approval_status | text | | Approval status | |
| approved_by | text | | Who approved | |
| created_by | text | | Who created | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- post_type IN ('post', 'story', 'reel', 'video', 'carousel', 'live')
- status IN ('draft', 'scheduled', 'publishing', 'published', 'failed', 'deleted')

---

## 16. marketing.social_analytics

**PURPOSE:** Performance metrics for social posts.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| post_id | uuid | FK → social_posts(id), NOT NULL | Post | ON DELETE: CASCADE |
| metric_date | date | NOT NULL | Metric date | |
| impressions | integer | DEFAULT 0 | Impressions | |
| reach | integer | DEFAULT 0 | Reach | |
| engagement | integer | DEFAULT 0 | Total engagement | |
| likes | integer | DEFAULT 0 | Likes | |
| comments | integer | DEFAULT 0 | Comments | |
| shares | integer | DEFAULT 0 | Shares | |
| saves | integer | DEFAULT 0 | Saves | |
| clicks | integer | DEFAULT 0 | Link clicks | |
| video_views | integer | DEFAULT 0 | Video views | |
| watch_time_seconds | integer | DEFAULT 0 | Watch time | |
| engagement_rate | numeric(5,4) | | Engagement rate | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**UNIQUE CONSTRAINT:** (post_id, metric_date)

---

## 17. marketing.social_account_metrics

**PURPOSE:** Account-level social metrics over time.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| account_id | uuid | FK → social_accounts(id), NOT NULL | Account | ON DELETE: CASCADE |
| metric_date | date | NOT NULL | Metric date | |
| follower_count | integer | DEFAULT 0 | Followers | |
| follower_change | integer | DEFAULT 0 | Change | |
| following_count | integer | DEFAULT 0 | Following | |
| post_count | integer | DEFAULT 0 | Posts | |
| impressions | integer | DEFAULT 0 | Impressions | |
| reach | integer | DEFAULT 0 | Reach | |
| profile_views | integer | DEFAULT 0 | Profile views | |
| website_clicks | integer | DEFAULT 0 | Website clicks | |
| engagement_rate | numeric(5,4) | | Avg engagement | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**UNIQUE CONSTRAINT:** (account_id, metric_date)

---

## 18. marketing.websites

**PURPOSE:** Company and property websites.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| website_id | text | NOT NULL, UNIQUE | Business ID: WEB-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id) | Property (NULL = company) | ON DELETE: SET NULL |
| website_name | text | NOT NULL | Website name | |
| domain | text | | Domain | |
| platform | text | | Platform: wordpress, webflow, custom | |
| analytics_id | text | | GA tracking ID | |
| status | text | DEFAULT 'active' | Status | |
| ssl_status | text | | SSL status | |
| last_updated_at | timestamptz | | Content last updated | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

---

## 19. marketing.website_pages

**PURPOSE:** Individual pages on websites.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| website_id | uuid | FK → websites(id), NOT NULL | Website | ON DELETE: CASCADE |
| content_id | uuid | FK → content(id) | Content | ON DELETE: SET NULL |
| page_path | text | NOT NULL | URL path | |
| page_title | text | NOT NULL | Page title | |
| meta_description | text | | Meta description | |
| meta_keywords | text[] | | Keywords | |
| page_type | text | | Type: landing, blog, property, about | |
| status | text | DEFAULT 'draft' | Status | |
| published_at | timestamptz | | Published | |
| page_views | integer | DEFAULT 0 | Total views | |
| conversions | integer | DEFAULT 0 | Conversions | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**UNIQUE CONSTRAINT:** (website_id, page_path)

---

## 20. marketing.attribution

**PURPOSE:** Booking attribution tracking. Links reservations to marketing touchpoints.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL | Reservation | ON DELETE: CASCADE |
| first_touch_campaign_id | uuid | FK → campaigns(id) | First touch campaign | ON DELETE: SET NULL |
| last_touch_campaign_id | uuid | FK → campaigns(id) | Last touch campaign | ON DELETE: SET NULL |
| first_touch_channel | text | | First touch channel | |
| first_touch_source | text | | First touch source | |
| first_touch_date | timestamptz | | First touch date | |
| last_touch_channel | text | | Last touch channel | |
| last_touch_source | text | | Last touch source | |
| last_touch_date | timestamptz | | Last touch date | |
| touchpoints | jsonb | | All touchpoints | |
| attribution_model | text | | Model used | |
| revenue_attributed | numeric(12,2) | | Revenue attributed | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

---

## 21-24. Reference Tables

### 21. marketing.ref_content_types
Content type definitions with guidelines.

### 22. marketing.ref_social_platforms  
Social platform configurations.

### 23. marketing.ref_campaign_types
Campaign type definitions and templates.

### 24. marketing.ref_segment_criteria
Available segment filter criteria.

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-09  
**Total Tables:** 24
