# Concierge Schema — Complete Table Map v4.1

**Date:** 2025-12-09  
**Schema:** concierge  
**Tables:** 24  
**Primary Key Standard:** UUIDv7 (time-ordered, globally unique)

---

## Schema Overview

The concierge schema powers the guest experience system including pre-arrival surveys, AI-generated itineraries, activity recommendations, and booking management. This is the operational hub for CAPRI AI (guest concierge). Venue data (beaches, restaurants, activities) are stored as Points of Interest in geo.points_of_interest.

**Key Integrations:**
- CAPRI AI — Guest concierge and itinerary generation
- geo.points_of_interest — All venue/activity data
- Guest Survey System — Pre-arrival questionnaires
- Booking Partners — Activity/tour booking

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
reservations.reservations (external)
├─► concierge.guest_surveys (reservation_id) [CASCADE DELETE]
├─► concierge.itineraries (reservation_id) [CASCADE DELETE]
└─► concierge.bookings (reservation_id) [CASCADE DELETE]

directory.guests (external)
├─► concierge.guest_travel_profiles (guest_id) [CASCADE DELETE]
├─► concierge.guest_interests (guest_id) [CASCADE DELETE]
├─► concierge.guest_limitations (guest_id) [CASCADE DELETE]
├─► concierge.guest_dietary_restrictions (guest_id) [CASCADE DELETE]
└─► concierge.guest_surveys (guest_id) [SET NULL]

geo.points_of_interest (external)
└─► concierge.itinerary_items (poi_id) [SET NULL]

concierge.guest_surveys
└─► concierge.survey_responses (survey_id) [CASCADE DELETE]

concierge.itinerary_themes
├─► concierge.theme_interest_weights (theme_id) [CASCADE DELETE]
├─► concierge.theme_limitations_excluded (theme_id) [CASCADE DELETE]
└─► concierge.itineraries (theme_id) [SET NULL]

concierge.itineraries
└─► concierge.itinerary_days (itinerary_id) [CASCADE DELETE]

concierge.itinerary_days
└─► concierge.itinerary_items (day_id) [CASCADE DELETE]

concierge.bookings
└─► concierge.booking_confirmations (booking_id) [CASCADE DELETE]

concierge.services
└─► concierge.add_ons (service_id) [CASCADE DELETE]
```

---

# BUSINESS ID CROSS-REFERENCE

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| guest_surveys | SRV-NNNNNN | SRV-010001 | 10001 | Survey Platform, CAPRI AI |
| guest_travel_profiles | GTP-NNNNNN | GTP-010001 | 10001 | CAPRI AI, Guest Portal |
| itinerary_themes | THM-NNNN | THM-0001 | 0001 | CAPRI AI |
| itineraries | ITN-NNNNNN | ITN-010001 | 10001 | Guest Portal, CAPRI AI |
| bookings | BKG-NNNNNN | BKG-010001 | 10001 | Booking Partners |
| services | SVC-NNNNNN | SVC-010001 | 10001 | Partner Portal |
| service_categories | — | — | — | — |

---

# INDEX COVERAGE SUMMARY

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| concierge.guest_surveys | idx_survey_id | survey_id (UNIQUE) | Business ID |
| | idx_survey_reservation | reservation_id | Reservation surveys |
| | idx_survey_guest | guest_id | Guest surveys |
| | idx_survey_status | status | Filter by status |
| concierge.guest_travel_profiles | idx_gtp_id | profile_id (UNIQUE) | Business ID |
| | idx_gtp_guest | guest_id (UNIQUE) | One per guest |
| concierge.guest_interests | idx_gi_guest | guest_id | Guest interests |
| | idx_gi_interest | interest_code | Interest lookup |
| concierge.itineraries | idx_itn_id | itinerary_id (UNIQUE) | Business ID |
| | idx_itn_reservation | reservation_id | Reservation itineraries |
| | idx_itn_status | status | Filter by status |
| concierge.itinerary_items | idx_ii_day | day_id | Day items |
| | idx_ii_poi | poi_id | POI lookup |
| concierge.bookings | idx_bkg_id | booking_id (UNIQUE) | Business ID |
| | idx_bkg_reservation | reservation_id | Reservation bookings |
| | idx_bkg_status | status | Filter by status |

---

# TABLE SPECIFICATIONS

---

## 1. concierge.guest_surveys

**PURPOSE:** Pre-arrival guest surveys to capture preferences, interests, and limitations. Powers CAPRI AI itinerary generation.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| survey_id | text | NOT NULL, UNIQUE | Business ID: SRV-NNNNNN | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL | Reservation | ON DELETE: CASCADE |
| guest_id | uuid | FK → directory.guests(id) | Guest | ON DELETE: SET NULL |
| survey_version | integer | DEFAULT 1 | Survey version | |
| status | text | DEFAULT 'sent' | Status: sent, started, completed, expired | |
| sent_at | timestamptz | | When sent | |
| started_at | timestamptz | | When started | |
| completed_at | timestamptz | | When completed | |
| completion_pct | numeric(5,2) | DEFAULT 0 | Completion percentage | |
| current_section | integer | DEFAULT 1 | Current section | |
| travel_party_composition | jsonb | | {"adults": 2, "children": 2, "ages": [38,36,10,7]} | |
| trip_purpose | text | | vacation, celebration, honeymoon, business | |
| celebration_type | text | | birthday, anniversary, wedding, graduation | |
| celebration_date | date | | Date of celebration | |
| celebration_person | text | | Who is being celebrated | |
| maui_visit_count | integer | DEFAULT 0 | Previous visits to Maui | |
| previous_favorites | text | | What they loved before | |
| previous_experiences | text[] | | Activity codes they've done | |
| activity_level_code | text | | FK to ref.activity_levels | |
| budget_level_code | text | | FK to ref.budget_levels | |
| schedule_density_code | text | | FK to ref.schedule_density_levels | |
| driving_tolerance_code | text | | FK to ref.driving_tolerance_levels | |
| wake_time_preference | text | | early_bird, normal, late_riser | |
| early_morning_count | integer | | How many early mornings | |
| dinner_time_preference | text | | early, normal, late | |
| special_requests | text | | Free text requests | |
| parsed_signals | jsonb | | AI-extracted signals | |
| reminder_sent_count | integer | DEFAULT 0 | Reminders sent | |
| last_reminder_at | timestamptz | | Last reminder | |
| abandon_reason | text | | If abandoned | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- status IN ('sent', 'started', 'completed', 'expired', 'abandoned')
- trip_purpose IN ('vacation', 'celebration', 'honeymoon', 'anniversary', 'business', 'relocation', 'other')

---

## 2. concierge.survey_responses

**PURPOSE:** Individual question responses from surveys.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| survey_id | uuid | FK → guest_surveys(id), NOT NULL | Survey | ON DELETE: CASCADE |
| question_code | text | NOT NULL | Question identifier | |
| section_number | integer | | Section number | |
| response_value | text | | Single value response | |
| response_values | text[] | | Multi-select response | |
| response_json | jsonb | | Complex response | |
| response_rank | integer | | Rank if ranking question | |
| responded_at | timestamptz | DEFAULT now() | When answered | |

**UNIQUE CONSTRAINT:** (survey_id, question_code)

---

## 3. concierge.guest_travel_profiles

**PURPOSE:** Persistent guest travel preferences accumulated across surveys and stays.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| profile_id | text | NOT NULL, UNIQUE | Business ID: GTP-NNNNNN | N/A |
| guest_id | uuid | FK → directory.guests(id), NOT NULL, UNIQUE | Guest | ON DELETE: CASCADE |
| activity_level_code | text | | Activity level preference | |
| budget_level_code | text | | Budget level preference | |
| dining_budget_code | text | | Dining budget | |
| dining_budget_per_person | numeric(8,2) | | Per person dining budget | |
| schedule_density_code | text | | Schedule preference | |
| driving_tolerance_code | text | | Driving tolerance | |
| wake_preference | text | | early_bird, normal, late_riser | |
| dinner_preference | text | | early, normal, late | |
| has_rental_car | boolean | | Usually has rental car | |
| rental_car_type | text | | sedan, 4wd, none | |
| travel_style | text | | adventure, relaxed, mixed | |
| preferred_group_size | text | | solo, couple, family, group | |
| typical_trip_length | integer | | Average nights | |
| visit_count | integer | DEFAULT 0 | Total visits | |
| first_visit_date | date | | First visit | |
| last_visit_date | date | | Most recent visit | |
| favorite_areas | text[] | | Favorite area codes | |
| favorite_activities | text[] | | Favorite activity codes | |
| favorite_restaurants | text[] | | Favorite restaurant POI IDs | |
| disliked_activities | text[] | | Activities to avoid | |
| ai_personality_tags | text[] | | AI-derived personality | |
| ai_preferences_summary | text | | AI summary of preferences | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

---

## 4. concierge.guest_interests

**PURPOSE:** Guest interest tracking with preference levels.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| guest_id | uuid | FK → directory.guests(id), NOT NULL | Guest | ON DELETE: CASCADE |
| interest_category_code | text | | Category: water, land, food, culture | |
| interest_code | text | NOT NULL | Specific interest: SNRK, HIKE, LUAU | |
| preference_level | text | NOT NULL | MUST_DO, INTERESTED, IF_TIME, SKIP | |
| rank_position | integer | | Rank within category (1-5) | |
| source | text | | Source: stated, inferred, behavior | |
| confidence_score | numeric(5,4) | | AI confidence for inferred | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**UNIQUE CONSTRAINT:** (guest_id, interest_code)

**CHECK CONSTRAINTS:**
- preference_level IN ('MUST_DO', 'INTERESTED', 'IF_TIME', 'SKIP')
- source IN ('stated', 'inferred', 'behavior', 'review')

---

## 5. concierge.guest_limitations

**PURPOSE:** Guest accessibility needs and limitations.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| guest_id | uuid | FK → directory.guests(id), NOT NULL | Guest | ON DELETE: CASCADE |
| limitation_code | text | NOT NULL | Code: MOBW, MOBM, NWTR, HGHT | |
| severity | text | NOT NULL | NONE, MILD, MODERATE, SEVERE | |
| applies_to | text | | Who: self, partner, child, group_member | |
| equipment_needed | text[] | | Equipment needs | |
| notes | text | | Additional notes | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**UNIQUE CONSTRAINT:** (guest_id, limitation_code, applies_to)

---

## 6. concierge.guest_dietary_restrictions

**PURPOSE:** Guest dietary restrictions and allergies.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| guest_id | uuid | FK → directory.guests(id), NOT NULL | Guest | ON DELETE: CASCADE |
| restriction_code | text | NOT NULL | VEGT, VEGN, GLTN, DARY, etc. | |
| severity | text | NOT NULL | PREFERENCE, ALLERGY, MEDICAL | |
| applies_to | text | | Who in party | |
| notes | text | | Additional notes | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**UNIQUE CONSTRAINT:** (guest_id, restriction_code, applies_to)

---

## 7. concierge.guest_capabilities

**PURPOSE:** Guest certifications and qualifications (scuba, etc.).

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| guest_id | uuid | FK → directory.guests(id), NOT NULL | Guest | ON DELETE: CASCADE |
| capability_code | text | NOT NULL | SCBA, SWIM, HIKE_ADV | |
| certification_level | text | | Certification level | |
| certification_agency | text | | Certifying agency | |
| expiration_date | date | | If certification expires | |
| verified | boolean | DEFAULT false | Verified by us | |
| notes | text | | Notes | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

---

## 8. concierge.itinerary_themes

**PURPOSE:** Pre-defined itinerary themes for different guest types.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| theme_id | text | NOT NULL, UNIQUE | Business ID: THM-NNNN | N/A |
| theme_name | text | NOT NULL | Theme name | |
| theme_code | text | NOT NULL, UNIQUE | Code: ADVENTURE, ROMANCE, FAMILY | |
| description | text | | Theme description | |
| target_guest_profile | jsonb | | Ideal guest profile | |
| included_activities | text[] | | Activity codes typically included | |
| excluded_activities | text[] | | Activities to avoid | |
| daily_structure | jsonb | | Typical day structure | |
| suggested_pace | text | | packed, moderate, relaxed | |
| icon | text | | Theme icon | |
| color | text | | Theme color hex | |
| is_active | boolean | DEFAULT true | Currently active | |
| sort_order | integer | | Display order | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

---

## 9. concierge.theme_interest_weights

**PURPOSE:** Interest weighting for theme matching.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| theme_id | uuid | FK → itinerary_themes(id), NOT NULL | Theme | ON DELETE: CASCADE |
| interest_code | text | NOT NULL | Interest code | |
| weight | numeric(5,2) | NOT NULL | Weight (0-100) | |
| is_required | boolean | DEFAULT false | Must have this interest | |

**UNIQUE CONSTRAINT:** (theme_id, interest_code)

---

## 10. concierge.theme_limitations_excluded

**PURPOSE:** Limitations that exclude certain themes.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| theme_id | uuid | FK → itinerary_themes(id), NOT NULL | Theme | ON DELETE: CASCADE |
| limitation_code | text | NOT NULL | Limitation that excludes | |
| min_severity | text | NOT NULL | Minimum severity to exclude | |

**UNIQUE CONSTRAINT:** (theme_id, limitation_code)

---

## 11. concierge.itineraries

**PURPOSE:** AI-generated itineraries for guests.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| itinerary_id | text | NOT NULL, UNIQUE | Business ID: ITN-NNNNNN | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL | Reservation | ON DELETE: CASCADE |
| guest_id | uuid | FK → directory.guests(id) | Guest | ON DELETE: SET NULL |
| property_id | uuid | FK → property.properties(id) | Property | ON DELETE: SET NULL |
| survey_id | uuid | FK → guest_surveys(id) | Source survey | ON DELETE: SET NULL |
| theme_id | uuid | FK → itinerary_themes(id) | Theme used | ON DELETE: SET NULL |
| title | text | NOT NULL | Itinerary title | |
| introduction | text | | Personalized intro message | |
| trip_start_date | date | NOT NULL | Trip start | |
| trip_end_date | date | NOT NULL | Trip end | |
| total_days | integer | | Number of days | |
| version | integer | DEFAULT 1 | Version number | |
| compatibility_score | numeric(5,2) | | Theme match score | |
| status | text | DEFAULT 'draft' | Status: draft, sent, accepted, revised | |
| generated_at | timestamptz | | When generated | |
| generated_by_agent | text | | CAPRI, etc. | |
| generation_params | jsonb | | Parameters used | |
| sent_at | timestamptz | | When sent to guest | |
| opened_at | timestamptz | | When guest opened | |
| guest_rating | integer | | Guest rating (1-5) | |
| guest_feedback | text | | Guest feedback | |
| share_url | text | | Shareable URL | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- status IN ('draft', 'sent', 'opened', 'accepted', 'revised', 'expired')

---

## 12. concierge.itinerary_days

**PURPOSE:** Individual days within an itinerary.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| itinerary_id | uuid | FK → itineraries(id), NOT NULL | Itinerary | ON DELETE: CASCADE |
| day_number | integer | NOT NULL | Day number (1, 2, 3...) | |
| day_date | date | NOT NULL | Actual date | |
| day_title | text | | Day title/theme | |
| day_description | text | | Day overview | |
| weather_forecast | jsonb | | Weather at generation | |
| special_notes | text | | Special notes | |
| is_arrival_day | boolean | DEFAULT false | Arrival day | |
| is_departure_day | boolean | DEFAULT false | Departure day | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

**UNIQUE CONSTRAINT:** (itinerary_id, day_number)

---

## 13. concierge.itinerary_items

**PURPOSE:** Individual activities/items within itinerary days.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| day_id | uuid | FK → itinerary_days(id), NOT NULL | Day | ON DELETE: CASCADE |
| poi_id | uuid | FK → geo.points_of_interest(id) | POI reference | ON DELETE: SET NULL |
| item_order | integer | NOT NULL | Order in day | |
| time_slot | text | | Time slot: morning, midday, afternoon, evening | |
| suggested_time | time | | Suggested time | |
| duration_minutes | integer | | Expected duration | |
| activity_type | text | | Type: activity, meal, beach, rest | |
| interest_code | text | | Interest satisfied | |
| title | text | NOT NULL | Item title | |
| description | text | | Description | |
| why_recommended | text | | AI explanation | |
| tips | text | | Insider tips | |
| booking_required | boolean | DEFAULT false | Needs booking | |
| booking_url | text | | Booking link | |
| booking_status | text | | booked, pending, not_required | |
| estimated_cost | numeric(8,2) | | Estimated cost | |
| cost_per_person | numeric(8,2) | | Per person cost | |
| drive_time_minutes | integer | | Drive time from previous | |
| alternatives | jsonb | | Alternative suggestions | |
| guest_modified | boolean | DEFAULT false | Guest changed this | |
| guest_removed | boolean | DEFAULT false | Guest removed | |
| created_at | timestamptz | DEFAULT now() | Record creation | |

---

## 14. concierge.bookings

**PURPOSE:** Service/activity bookings made through concierge.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| booking_id | text | NOT NULL, UNIQUE | Business ID: BKG-NNNNNN | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL | Reservation | ON DELETE: CASCADE |
| guest_id | uuid | FK → directory.guests(id) | Guest | ON DELETE: SET NULL |
| itinerary_item_id | uuid | FK → itinerary_items(id) | Itinerary item | ON DELETE: SET NULL |
| poi_id | uuid | FK → geo.points_of_interest(id) | POI | ON DELETE: SET NULL |
| service_id | uuid | FK → services(id) | Service | ON DELETE: SET NULL |
| booking_type | text | NOT NULL | Type: activity, tour, dining, spa, transport | |
| provider_name | text | | Provider name | |
| booking_date | date | NOT NULL | Date of activity | |
| booking_time | time | | Start time | |
| party_size | integer | NOT NULL | Number of people | |
| total_price | numeric(12,2) | | Total price | |
| deposit_amount | numeric(12,2) | | Deposit paid | |
| currency | text | DEFAULT 'USD' | Currency | |
| external_confirmation | text | | Provider confirmation # | |
| status | text | DEFAULT 'pending' | Status | |
| booked_at | timestamptz | | When booked | |
| booked_by | text | | Who booked | |
| cancelled_at | timestamptz | | If cancelled | |
| cancellation_reason | text | | Cancellation reason | |
| notes | text | | Notes | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- status IN ('pending', 'confirmed', 'cancelled', 'completed', 'no_show')
- booking_type IN ('activity', 'tour', 'dining', 'spa', 'transport', 'rental', 'other')

---

## 15. concierge.booking_confirmations

**PURPOSE:** Confirmation details and communications for bookings.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| booking_id | uuid | FK → bookings(id), NOT NULL | Booking | ON DELETE: CASCADE |
| confirmation_type | text | NOT NULL | Type: initial, reminder, updated, cancelled | |
| sent_at | timestamptz | DEFAULT now() | When sent | |
| sent_via | text | | Channel: email, sms, app | |
| sent_to | text | | Recipient | |
| confirmation_number | text | | Confirmation number | |
| confirmation_details | jsonb | | Full details | |
| attachment_url | text | | Confirmation attachment | |

---

## 16. concierge.services

**PURPOSE:** Bookable services offered by partners.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| service_id | text | NOT NULL, UNIQUE | Business ID: SVC-NNNNNN | N/A |
| company_id | uuid | FK → directory.companies(id) | Provider company | ON DELETE: SET NULL |
| poi_id | uuid | FK → geo.points_of_interest(id) | POI if location-based | ON DELETE: SET NULL |
| category_id | uuid | FK → service_categories(id) | Category | ON DELETE: SET NULL |
| service_name | text | NOT NULL | Service name | |
| description | text | | Description | |
| duration_minutes | integer | | Duration | |
| price | numeric(12,2) | | Base price | |
| price_type | text | | per_person, per_group, per_hour | |
| min_participants | integer | DEFAULT 1 | Minimum participants | |
| max_participants | integer | | Maximum participants | |
| advance_booking_days | integer | | Days advance notice needed | |
| cancellation_policy | text | | Cancellation terms | |
| included | text[] | | What's included | |
| requirements | text[] | | Guest requirements | |
| restrictions | text[] | | Activity restrictions | |
| meeting_location | text | | Where to meet | |
| what_to_bring | text[] | | What guests should bring | |
| commission_rate | numeric(5,4) | | Our commission | |
| is_active | boolean | DEFAULT true | Currently offered | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

---

## 17. concierge.service_categories

**PURPOSE:** Categories for services.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| category_code | text | NOT NULL, UNIQUE | Category code | N/A |
| category_name | text | NOT NULL | Category name | |
| parent_category_id | uuid | FK → service_categories(id) | Parent | ON DELETE: SET NULL |
| description | text | | Description | |
| icon | text | | Icon | |
| sort_order | integer | | Display order | |
| is_active | boolean | DEFAULT true | Active | |

---

## 18. concierge.add_ons

**PURPOSE:** Add-on options for services.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| service_id | uuid | FK → services(id), NOT NULL | Service | ON DELETE: CASCADE |
| add_on_name | text | NOT NULL | Add-on name | |
| description | text | | Description | |
| price | numeric(12,2) | | Price | |
| price_type | text | | per_person, flat | |
| is_active | boolean | DEFAULT true | Active | |

---

## 19-24. Reference Tables

### 19. concierge.ref_activity_levels
Activity level definitions (sedentary to extreme).

### 20. concierge.ref_budget_levels  
Budget level definitions with ranges.

### 21. concierge.ref_schedule_density_levels
Schedule pace preferences.

### 22. concierge.ref_driving_tolerance_levels
Driving distance comfort levels.

### 23. concierge.ref_interest_categories
Interest category definitions.

### 24. concierge.ref_interest_types
Specific interest/activity types.

---

# KEY WORKFLOWS

## 1. Survey to Itinerary Flow

```
1. Booking confirmed → trigger survey send
2. Guest completes survey → guest_surveys, survey_responses
3. Extract profile → guest_travel_profiles, guest_interests, guest_limitations
4. CAPRI AI matches theme → itinerary_themes scoring
5. Generate itinerary → itineraries, itinerary_days, itinerary_items
6. Send to guest → status = 'sent'
7. Track engagement → opened_at, guest_rating
```

## 2. Booking Flow

```
1. Guest selects activity from itinerary
2. Create booking record → bookings
3. Contact provider → external_confirmation
4. Send confirmation → booking_confirmations
5. Pre-activity reminder
6. Post-activity: update status = 'completed'
```

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-09  
**Total Tables:** 24
