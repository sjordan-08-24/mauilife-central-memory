# Concierge System - Reference Guide

**Date:** 20251206  
**System:** Concierge System  
**Schemas:** concierge, ref, geo, ops  
**Tables:** 24 (24 concierge) + external dependencies  
**Primary Key:** UUIDv7 (time-ordered, globally unique)

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
ops.guests
├─► concierge.guest_travel_profiles (guest_id) [CASCADE DELETE]
├─► concierge.guest_interests (guest_id) [CASCADE DELETE]
├─► concierge.guest_limitations (guest_id) [CASCADE DELETE]
├─► concierge.guest_surveys (guest_id) [SET NULL]
├─► concierge.itineraries (guest_id) [SET NULL]
└─► concierge.bookings (guest_id) [SET NULL]

ops.reservations
├─► concierge.guest_surveys (reservation_id) [CASCADE DELETE]
├─► concierge.itineraries (reservation_id) [CASCADE DELETE]
└─► concierge.bookings (reservation_id) [CASCADE DELETE]

ops.properties
└─► concierge.itineraries (property_id) [SET NULL]

ops.companies
├─► concierge.activities (company_id) [SET NULL]
├─► concierge.services (company_id) [SET NULL]
└─► concierge.bookings (company_id) [SET NULL]

geo.areas
├─► concierge.beaches (area_id) [SET NULL]
├─► concierge.hikes (area_id) [SET NULL]
├─► concierge.activities (area_id) [SET NULL]
├─► concierge.restaurants (area_id) [SET NULL]
├─► concierge.attractions (area_id) [SET NULL]
├─► concierge.shops (area_id) [SET NULL]
├─► concierge.shopping_locations (area_id) [SET NULL]
└─► concierge.experience_spots (area_id) [SET NULL]

ref.activity_levels
├─► concierge.guest_travel_profiles (activity_level_code) [RESTRICT DELETE]
├─► concierge.activities (activity_level) [RESTRICT DELETE]
└─► concierge.itinerary_themes (ideal_activity_level) [RESTRICT DELETE]

ref.budget_levels
├─► concierge.guest_travel_profiles (budget_level_code) [RESTRICT DELETE]
└─► concierge.itinerary_themes (ideal_budget_level) [RESTRICT DELETE]

ref.schedule_density_levels
├─► concierge.guest_travel_profiles (schedule_density_code) [RESTRICT DELETE]
└─► concierge.itinerary_themes (ideal_schedule_density) [RESTRICT DELETE]

ref.driving_tolerance_levels
├─► concierge.guest_travel_profiles (driving_tolerance_code) [RESTRICT DELETE]
└─► concierge.itinerary_themes (ideal_driving_tolerance) [RESTRICT DELETE]

ref.interest_types
├─► concierge.guest_interests (interest_code) [RESTRICT DELETE]
├─► concierge.theme_interest_weights (interest_code) [RESTRICT DELETE]
└─► concierge.itinerary_items (interest_code) [SET NULL]

ref.interest_categories
└─► concierge.guest_interests (interest_category_code) [SET NULL]

ref.limitation_types
├─► concierge.guest_limitations (limitation_code) [RESTRICT DELETE]
└─► concierge.theme_limitations_excluded (limitation_code) [RESTRICT DELETE]

concierge.shopping_locations
└─► concierge.shops (shopping_location_id) [SET NULL]

concierge.service_categories
└─► concierge.services (category_id) [RESTRICT DELETE]

concierge.services
└─► concierge.add_ons (service_id) [CASCADE DELETE]

concierge.guest_surveys
├─► concierge.survey_responses (survey_id) [CASCADE DELETE]
└─► concierge.itineraries (survey_id) [SET NULL]

concierge.itinerary_themes
├─► concierge.theme_interest_weights (theme_id) [CASCADE DELETE]
├─► concierge.theme_limitations_excluded (theme_id) [CASCADE DELETE]
└─► concierge.itineraries (theme_id) [SET NULL]

concierge.itineraries
└─► concierge.itinerary_days (itinerary_id) [CASCADE DELETE]

concierge.itinerary_days
└─► concierge.itinerary_items (day_id) [CASCADE DELETE]

concierge.itinerary_items
└─► concierge.bookings (itinerary_item_id) [SET NULL]

concierge.activities
├─► concierge.bookings (activity_id) [SET NULL]
└─► concierge.itinerary_items (venue_id - polymorphic)

concierge.services
└─► concierge.bookings (service_id) [SET NULL]

concierge.restaurants
└─► concierge.bookings (restaurant_id) [SET NULL]

concierge.bookings
└─► concierge.booking_confirmations (booking_id) [CASCADE DELETE]

concierge.service_categories
└─► [NO FOREIGN KEYS - REFERENCE TABLE]

concierge.itinerary_themes
└─► [NO OUTBOUND FKs - ROOT REFERENCE TABLE]
```

**LEGEND:**
- [CASCADE DELETE] - Child records deleted when parent deleted
- [RESTRICT DELETE] - Cannot delete parent if children exist
- [SET NULL] - FK set to NULL when parent deleted
- [NO FOREIGN KEYS] - Reference/lookup table with no dependencies

---

# BUSINESS ID CROSS-REFERENCE

## CONCIERGE Schema Business IDs - Venue Tables

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| concierge.beaches | BCH-NNNN | BCH-0001 | 0001 | Guest App, Itinerary Engine, CAPRI Agent |
| concierge.hikes | HIK-NNNN | HIK-0042 | 0001 | Guest App, Itinerary Engine, CAPRI Agent |
| concierge.activities | ACT-NNNNNN | ACT-010001 | 10001 | Guest App, Booking System, Vendor Portal |
| concierge.restaurants | RST-NNNNNN | RST-010023 | 10001 | Guest App, Reservation System, OpenTable API |
| concierge.attractions | ATT-NNNN | ATT-0015 | 0001 | Guest App, Itinerary Engine |
| concierge.shops | SHP-NNNN | SHP-0088 | 0001 | Guest App, Partner Portal |
| concierge.shopping_locations | SLOC-NNNN | SLOC-0005 | 0001 | Guest App, Itinerary Engine |
| concierge.experience_spots | EXP-NNNN | EXP-0033 | 0001 | Guest App, Itinerary Engine, CAPRI Agent |

## CONCIERGE Schema Business IDs - Service Tables

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| concierge.services | SVC-NNNNNN | SVC-010001 | 10001 | Guest App, Booking System, Vendor Portal |
| concierge.service_categories | {CATEGORY_CODE} | SPA, CHEF | N/A | Guest App, Service Catalog |
| concierge.add_ons | ADDON-{service_id}-NNN | ADDON-SVC010001-001 | 001 | Booking System |

## CONCIERGE Schema Business IDs - Guest Profile Tables

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| concierge.guest_travel_profiles | N/A (guest_id link) | N/A | N/A | Itinerary Engine, CAPRI Agent, Guest CRM |
| concierge.guest_interests | N/A (composite key) | N/A | N/A | Itinerary Engine, Theme Matching |
| concierge.guest_limitations | N/A (composite key) | N/A | N/A | Itinerary Engine, Theme Matching, Safety System |
| concierge.guest_surveys | SRV-NNNNNN | SRV-050123 | 10001 | Survey System, Guest App, Email Automation |

## CONCIERGE Schema Business IDs - Itinerary Tables

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| concierge.itinerary_themes | THM-NNNN | THM-0001 | 0001 | Itinerary Engine, CAPRI Agent |
| concierge.theme_interest_weights | N/A (composite key) | N/A | N/A | Itinerary Engine Scoring |
| concierge.theme_limitations_excluded | N/A (composite key) | N/A | N/A | Itinerary Engine Exclusions |
| concierge.itineraries | ITN-NNNNNN | ITN-060001 | 10001 | Guest App, PDF Generator, Email System |
| concierge.itinerary_days | N/A (itinerary child) | N/A | N/A | Itinerary Engine |
| concierge.itinerary_items | N/A (day child) | N/A | N/A | Itinerary Engine |
| concierge.survey_responses | N/A (survey child) | N/A | N/A | Survey System |

## CONCIERGE Schema Business IDs - Booking Tables

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| concierge.bookings | BKG-NNNNNN | BKG-070001 | 10001 | Guest App, Vendor Portal, Accounting System |
| concierge.booking_confirmations | N/A (booking child) | N/A | N/A | Email/SMS System |

## Cross-System Business ID Dependencies

| External System | References These Business IDs |
|----------------|-------------------------------|
| Guest Mobile App | BCH-*, HIK-*, ACT-*, RST-*, ATT-*, SHP-*, EXP-*, SVC-*, ITN-*, BKG-* |
| CAPRI AI Agent | BCH-*, HIK-*, ACT-*, RST-*, EXP-*, THM-*, ITN-* |
| Itinerary Engine | All venue IDs, THM-*, guest_interests, guest_limitations |
| Booking System | ACT-*, SVC-*, RST-*, BKG-*, ADDON-* |
| Survey System | SRV-*, survey_responses |
| Vendor Portal | ACT-*, SVC-*, BKG-* |
| Email Automation | SRV-*, ITN-*, BKG-* |
| PDF Generator | ITN-*, itinerary_days, itinerary_items |
| OpenTable API | RST-* |
| Accounting System | BKG-* |
| Partner Portal | SHP-*, RST-* |

---

# INDEX COVERAGE SUMMARY

## CONCIERGE Schema Indexes - Venue Tables

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| concierge.beaches | idx_beaches_area | area_id | Geographic filtering |
| | idx_beaches_active | is_active WHERE is_active = true | Active venues only |
| concierge.hikes | idx_hikes_area | area_id | Geographic filtering |
| | idx_hikes_difficulty | difficulty | Difficulty filtering |
| concierge.activities | idx_activities_company | company_id | Vendor lookup |
| | idx_activities_area | area_id | Geographic filtering |
| | idx_activities_category | category | Category filtering |
| | idx_activities_active | is_active WHERE is_active = true | Active venues only |
| concierge.restaurants | idx_restaurants_area | area_id | Geographic filtering |
| | idx_restaurants_price | price_level | Budget matching |
| | idx_restaurants_cuisine | cuisine_types (GIN) | Cuisine array search |

## CONCIERGE Schema Indexes - Guest Profile Tables

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| concierge.guest_travel_profiles | idx_travel_profiles_guest | guest_id | Guest lookup |
| | idx_travel_profiles_activity | activity_level_code | Activity level filtering |
| | idx_travel_profiles_budget | budget_level_code | Budget filtering |
| concierge.guest_interests | idx_guest_interests_guest | guest_id | Guest lookup |
| | idx_guest_interests_code | interest_code | Interest filtering |
| | idx_guest_interests_pref | preference_level | Preference filtering |
| | idx_guest_interests_composite | guest_id, interest_code (UNIQUE) | One interest per guest |
| concierge.guest_limitations | idx_guest_limitations_guest | guest_id | Guest lookup |
| | idx_guest_limitations_code | limitation_code | Limitation filtering |
| | idx_guest_limitations_composite | guest_id, limitation_code (UNIQUE) | One limitation record per guest |
| concierge.guest_surveys | idx_surveys_reservation | reservation_id | Reservation lookup |
| | idx_surveys_guest | guest_id | Guest lookup |
| | idx_surveys_status | status | Status filtering |

## CONCIERGE Schema Indexes - Itinerary Tables

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| concierge.theme_interest_weights | idx_theme_weights_composite | theme_id, interest_code (UNIQUE) | One weight per theme-interest |
| concierge.theme_limitations_excluded | idx_theme_limits_composite | theme_id, limitation_code (UNIQUE) | One exclusion per theme-limitation |
| concierge.itineraries | idx_itineraries_reservation | reservation_id | Reservation lookup |
| | idx_itineraries_guest | guest_id | Guest lookup |
| | idx_itineraries_status | status | Status filtering |
| concierge.itinerary_days | idx_itin_days_composite | itinerary_id, day_number (UNIQUE) | One day per position |
| concierge.survey_responses | idx_responses_survey | survey_id | Survey lookup |
| | idx_responses_question | question_code | Question lookup |

## CONCIERGE Schema Indexes - Booking Tables

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| concierge.bookings | idx_bookings_reservation | reservation_id | Reservation lookup |
| | idx_bookings_date | booking_date | Date filtering |
| | idx_bookings_status | status | Status filtering |

---

# TABLE SPECIFICATIONS

## concierge.beaches

**PURPOSE:** Beach locations with amenities, conditions, and ratings for guest recommendations. Drives beach suggestions in itineraries based on guest interests (snorkeling, swimming, sunset) and limitations (accessibility).

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| beach_id | text | NOT NULL, UNIQUE | Business ID: BCH-NNNN (auto-generated from concierge.beach_seq starting at 0001) | N/A |
| area_id | uuid | FK → geo.areas(id) | Geographic area for location-based recommendations | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.hikes

**PURPOSE:** Hiking trails with difficulty levels, distance, and physical requirements. Used by itinerary engine to match guest fitness levels and activity preferences.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| hike_id | text | NOT NULL, UNIQUE | Business ID: HIK-NNNN (auto-generated from concierge.hike_seq starting at 0001) | N/A |
| area_id | uuid | FK → geo.areas(id) | Geographic area for location-based recommendations | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.activities

**PURPOSE:** Bookable activities and tours offered by vendor companies. Core table for activity recommendations, booking flow, and commission tracking.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| activity_id | text | NOT NULL, UNIQUE | Business ID: ACT-NNNNNN (auto-generated from concierge.activity_seq starting at 10001) | N/A |
| company_id | uuid | FK → ops.companies(id) | Vendor company providing activity | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| area_id | uuid | FK → geo.areas(id) | Primary geographic area | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| activity_level | text | FK → ref.activity_levels(level_code) | Required activity level for matching | ON DELETE: RESTRICT, ON UPDATE: CASCADE |

---

## concierge.restaurants

**PURPOSE:** Restaurant recommendations with cuisine types, pricing, and atmosphere. Supports meal planning in itineraries with budget and dietary matching.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| restaurant_id | text | NOT NULL, UNIQUE | Business ID: RST-NNNNNN (auto-generated from concierge.restaurant_seq starting at 10001) | N/A |
| area_id | uuid | FK → geo.areas(id) | Geographic area for location-based recommendations | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.attractions

**PURPOSE:** Points of interest including museums, gardens, historic sites, and viewpoints. Used for cultural and sightseeing recommendations in itineraries.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| attraction_id | text | NOT NULL, UNIQUE | Business ID: ATT-NNNN (auto-generated from concierge.attraction_seq starting at 0001) | N/A |
| area_id | uuid | FK → geo.areas(id) | Geographic area for location-based recommendations | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.shops

**PURPOSE:** Individual shop recommendations including boutiques, galleries, and local stores. Can be linked to shopping locations for district grouping.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| shop_id | text | NOT NULL, UNIQUE | Business ID: SHP-NNNN (auto-generated from concierge.shop_seq starting at 0001) | N/A |
| area_id | uuid | FK → geo.areas(id) | Geographic area for location-based recommendations | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| shopping_location_id | uuid | FK → concierge.shopping_locations(id) | Parent shopping district/mall if applicable | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.shopping_locations

**PURPOSE:** Shopping centers, malls, and districts that contain multiple shops. Used for grouping shop recommendations by area.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| location_id | text | NOT NULL, UNIQUE | Business ID: SLOC-NNNN (auto-generated from concierge.shopping_location_seq starting at 0001) | N/A |
| area_id | uuid | FK → geo.areas(id) | Geographic area for location-based recommendations | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.experience_spots

**PURPOSE:** Sunset spots, sunrise viewpoints, and photo opportunity locations. Essential for time-of-day planning in itineraries.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| spot_id | text | NOT NULL, UNIQUE | Business ID: EXP-NNNN (auto-generated from concierge.experience_spot_seq starting at 0001) | N/A |
| area_id | uuid | FK → geo.areas(id) | Geographic area for location-based recommendations | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.services

**PURPOSE:** Bookable services like spa, private chef, and photography. Linked to vendor companies for fulfillment and commission tracking.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| service_id | text | NOT NULL, UNIQUE | Business ID: SVC-NNNNNN (auto-generated from concierge.service_seq starting at 10001) | N/A |
| company_id | uuid | FK → ops.companies(id) | Vendor company providing service | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| category_id | bigint | FK → concierge.service_categories(id), NOT NULL | Service category (cannot delete category if services exist) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |

---

## concierge.service_categories

**PURPOSE:** Categories for services (SPA, CHEF, PHOTO, etc.). Reference table for service classification.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | bigserial | PK, NOT NULL, UNIQUE | Internal bigserial ID (exception to UUIDv7 for simple reference table) | N/A |
| category_code | text | NOT NULL, UNIQUE | Category code (SPA, CHEF, PHOTO, GROC, CHLD, TRANS, FLOR, CATER) | N/A |

**NO FOREIGN KEYS** - This is a reference table

---

## concierge.add_ons

**PURPOSE:** Add-on options that can be added to services (extra treatments, extended time, etc.). Child records deleted when parent service deleted.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| addon_id | text | NOT NULL, UNIQUE | Business ID: ADDON-{service_id}-NNN | N/A |
| service_id | uuid | FK → concierge.services(id), NOT NULL | Parent service (delete add-ons when service deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

---

## concierge.guest_travel_profiles

**PURPOSE:** Extended guest profile for concierge personalization including activity level, budget, schedule density, and travel party composition. One profile per guest, linked to ops.guests.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| guest_id | uuid | FK → ops.guests(id), NOT NULL, UNIQUE | Guest link (one profile per guest, delete profile when guest deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| activity_level_code | text | FK → ref.activity_levels(level_code) | Activity preference (cannot delete activity level if profiles reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| driving_tolerance_code | text | FK → ref.driving_tolerance_levels(level_code) | Driving preference (cannot delete level if referenced) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| schedule_density_code | text | FK → ref.schedule_density_levels(level_code) | Pace preference (cannot delete level if referenced) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| budget_level_code | text | FK → ref.budget_levels(level_code) | Budget level (cannot delete level if referenced) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |

---

## concierge.guest_interests

**PURPOSE:** Guest interest selections from surveys with preference levels (MUST_DO, INTERESTED, IF_TIME, SKIP). Used by itinerary engine for interest matching scores.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| guest_id | uuid | FK → ops.guests(id), NOT NULL | Guest (delete interests when guest deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| interest_code | text | FK → ref.interest_types(interest_code), NOT NULL | Interest type (cannot delete interest type if guest interests reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| interest_category_code | text | FK → ref.interest_categories(category_code) | Category grouping | ON DELETE: SET NULL, ON UPDATE: CASCADE |

**UNIQUE CONSTRAINT:** (guest_id, interest_code) - One interest record per guest-interest combination

---

## concierge.guest_limitations

**PURPOSE:** Guest limitations and restrictions with severity levels (NONE, MILD, MODERATE, SEVERE). Used by itinerary engine for theme exclusions and activity filtering.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| guest_id | uuid | FK → ops.guests(id), NOT NULL | Guest (delete limitations when guest deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| limitation_code | text | FK → ref.limitation_types(limitation_code), NOT NULL | Limitation type (cannot delete limitation type if guest limitations reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |

**UNIQUE CONSTRAINT:** (guest_id, limitation_code) - One limitation record per guest-limitation combination

---

## concierge.guest_surveys

**PURPOSE:** Pre-arrival survey instances linked to reservations. Tracks survey status, completion progress, and reminders for follow-up automation.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| survey_id | text | NOT NULL, UNIQUE | Business ID: SRV-NNNNNN (auto-generated from concierge.survey_seq starting at 10001) | N/A |
| reservation_id | uuid | FK → ops.reservations(id), NOT NULL | Reservation (delete survey when reservation deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| guest_id | uuid | FK → ops.guests(id) | Guest who completed survey | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.survey_responses

**PURPOSE:** Individual survey question responses. Stores answers by section and question code with support for single, multi-select, and complex JSON responses.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| survey_id | uuid | FK → concierge.guest_surveys(id), NOT NULL | Parent survey (delete responses when survey deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

---

## concierge.itinerary_themes

**PURPOSE:** Predefined itinerary theme templates (Ocean Explorer, Adventure Seeker, Family Adventure, etc.). Contains ideal guest attribute targets for theme matching algorithm.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| theme_id | text | NOT NULL, UNIQUE | Business ID: THM-NNNN (auto-generated from concierge.theme_seq starting at 0001) | N/A |
| theme_code | text | NOT NULL, UNIQUE | Short code: OCEX, ADVN, ULRL, FMAD, RMNT, CULT, WELL, GOLF, LUXE | N/A |
| ideal_activity_level | text | FK → ref.activity_levels(level_code) | Target activity level (cannot delete if themes reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| ideal_schedule_density | text | FK → ref.schedule_density_levels(level_code) | Target schedule density (cannot delete if themes reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| ideal_driving_tolerance | text | FK → ref.driving_tolerance_levels(level_code) | Target driving tolerance (cannot delete if themes reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| ideal_budget_level | text | FK → ref.budget_levels(level_code) | Target budget level (cannot delete if themes reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |

---

## concierge.theme_interest_weights

**PURPOSE:** Interest weighting for each theme. Defines which interests are primary (define the theme) and their weights (0.0-1.0) for interest matching score calculation.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| theme_id | uuid | FK → concierge.itinerary_themes(id), NOT NULL | Theme (delete weights when theme deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| interest_code | text | FK → ref.interest_types(interest_code), NOT NULL | Interest type (cannot delete interest type if weights reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |

**UNIQUE CONSTRAINT:** (theme_id, interest_code) - One weight per theme-interest combination

---

## concierge.theme_limitations_excluded

**PURPOSE:** Limitations that exclude a theme from consideration. Defines minimum severity threshold (MILD, MODERATE, SEVERE) at which a guest limitation disqualifies the theme.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| theme_id | uuid | FK → concierge.itinerary_themes(id), NOT NULL | Theme (delete exclusions when theme deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| limitation_code | text | FK → ref.limitation_types(limitation_code), NOT NULL | Limitation type (cannot delete limitation type if exclusions reference it) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |

**UNIQUE CONSTRAINT:** (theme_id, limitation_code) - One exclusion rule per theme-limitation combination

---

## concierge.itineraries

**PURPOSE:** AI-generated itineraries for guests. Links reservation, guest, property, survey, and theme. Tracks generation method, version, delivery status, and guest feedback.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| itinerary_id | text | NOT NULL, UNIQUE | Business ID: ITN-NNNNNN (auto-generated from concierge.itinerary_seq starting at 10001) | N/A |
| reservation_id | uuid | FK → ops.reservations(id), NOT NULL | Reservation (delete itinerary when reservation deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| guest_id | uuid | FK → ops.guests(id) | Guest | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| property_id | uuid | FK → ops.properties(id) | Property for location-based planning | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| survey_id | uuid | FK → concierge.guest_surveys(id) | Source survey for preferences | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| theme_id | uuid | FK → concierge.itinerary_themes(id) | Primary theme selected | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.itinerary_days

**PURPOSE:** Days within an itinerary. Contains day number, date, title, and primary region focus for geographic clustering of activities.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| itinerary_id | uuid | FK → concierge.itineraries(id), NOT NULL | Parent itinerary (delete days when itinerary deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

**UNIQUE CONSTRAINT:** (itinerary_id, day_number) - One day per position in itinerary

---

## concierge.itinerary_items

**PURPOSE:** Individual items/activities within each day. Contains time slots, venue references (polymorphic), booking status, and insider tips.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| day_id | uuid | FK → concierge.itinerary_days(id), NOT NULL | Parent day (delete items when day deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| interest_code | text | FK → ref.interest_types(interest_code) | Activity type for categorization | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| venue_id | uuid | | Polymorphic FK to venue table (beach, restaurant, activity) | N/A |

---

## concierge.bookings

**PURPOSE:** Activity/service/restaurant bookings for guests. Links to itinerary items when generated from itinerary. Tracks booking status, pricing, and commission.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| booking_id | text | NOT NULL, UNIQUE | Business ID: BKG-NNNNNN (auto-generated from concierge.booking_seq starting at 10001) | N/A |
| reservation_id | uuid | FK → ops.reservations(id), NOT NULL | Reservation (delete booking when reservation deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| guest_id | uuid | FK → ops.guests(id) | Guest | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| itinerary_item_id | uuid | FK → concierge.itinerary_items(id) | Source itinerary item if from itinerary | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| activity_id | uuid | FK → concierge.activities(id) | If booking an activity | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| service_id | uuid | FK → concierge.services(id) | If booking a service | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| restaurant_id | uuid | FK → concierge.restaurants(id) | If booking a restaurant | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| company_id | uuid | FK → ops.companies(id) | Provider company | ON DELETE: SET NULL, ON UPDATE: CASCADE |

---

## concierge.booking_confirmations

**PURPOSE:** Confirmation communications sent for bookings. Tracks delivery and open status for email/SMS confirmations.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|-----------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT generate_uuid_v7() | UUIDv7 primary key (time-ordered) | N/A |
| booking_id | uuid | FK → concierge.bookings(id), NOT NULL | Parent booking (delete confirmations when booking deleted) | ON DELETE: CASCADE, ON UPDATE: CASCADE |

---

**Document Version:** 1.0  
**Last Updated:** December 6, 2025  
**UUIDv7 Migration:** V2025.12.05.153155__uuidv7.sql  
**Total Tables:** 24 (8 venue + 3 service + 4 guest profile + 7 itinerary + 2 booking)
