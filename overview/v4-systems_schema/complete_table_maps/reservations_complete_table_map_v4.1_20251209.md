# Reservations System - Reference Guide

**Date:** 20251209  
**System:** Reservations (Bookings, Guest Journeys, Reviews, Fees)  
**Schema:** reservations  
**Tables:** 8  
**Primary Key:** UUIDv7 (time-ordered, globally unique)

---

# SCHEMA OVERVIEW

The reservations schema contains all booking and guest journey data. It bridges property (what's booked) with directory (who booked) and tracks the complete guest experience lifecycle.

**Core Principle:** Each reservation has exactly ONE guest journey (1:1 relationship). The journey tracks state, while touchpoints track history.

```
                    ┌──────────────────┐
                    │   reservations   │  ← The booking
                    └────────┬─────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
          ▼                  ▼                  ▼
   ┌──────────────┐   ┌─────────────┐    ┌──────────────┐
   │guest_journeys│   │reservation_ │    │reservation_  │
   │   (1:1)      │   │   fees      │    │   guests     │
   └──────┬───────┘   └─────────────┘    └──────────────┘
          │
          ├── guest_journey_touchpoints (event log)
          │
          └── reviews (bidirectional)
```

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
reservations.reservations (Core Booking)
├─► reservations.guest_journeys (reservation_id) [CASCADE DELETE]
├─► reservations.guest_journey_touchpoints (via guest_journeys) [CASCADE DELETE]
├─► reservations.reviews (reservation_id) [SET NULL]
├─► reservations.reservation_fees (reservation_id) [CASCADE DELETE]
├─► reservations.reservation_guests (reservation_id) [CASCADE DELETE]
├─► reservations.reservation_financials (reservation_id) [CASCADE DELETE]
├─► reservations.damage_claims_legacy (reservation_id) [CASCADE DELETE]
├─► property.cleans (checkout_reservation_id, checkin_reservation_id) [SET NULL]
├─► property.inspections (checkout_reservation_id, checkin_reservation_id) [SET NULL]
├─► service.tickets (reservation_id via ticket_reservations) [CASCADE DELETE]
└─► service.damage_claims (reservation_id) [SET NULL]

reservations.guest_journeys (Journey State - 1:1 with Reservations)
├─► reservations.guest_journey_touchpoints (journey_id) [CASCADE DELETE]
├─► reservations.reviews (journey_id) [SET NULL]
└─► [CIRCULAR] reservations.reviews (review_id) [SET NULL]

reservations.guest_journey_touchpoints (Event Log)
└─► service.tickets (linked_ticket_id) [SET NULL]

reservations.reviews (Guest Feedback)
├─► reservations.reservations (reservation_id) [SET NULL]
├─► reservations.guest_journeys (journey_id) [SET NULL]
├─► [CIRCULAR] reservations.guest_journeys (review_id) [SET NULL]
├─► directory.guests (guest_id) [SET NULL]
├─► property.properties (property_id) [SET NULL]
└─► property.cleans (clean_id) [SET NULL]

reservations.reservation_fees
├─► reservations.reservations (reservation_id) [CASCADE DELETE]
└─► ref.fee_types (fee_type_code) [RESTRICT DELETE]

reservations.reservation_guests (Additional Guests)
├─► reservations.reservations (reservation_id) [CASCADE DELETE]
└─► directory.guests (guest_id) [SET NULL]

reservations.reservation_financials (Financial Summary)
└─► reservations.reservations (reservation_id) [CASCADE DELETE]

reservations.damage_claims_legacy (Deprecated)
├─► reservations.reservations (reservation_id) [CASCADE DELETE]
└─► property.properties (property_id) [SET NULL]
```

**LEGEND:**
- [CASCADE DELETE] - Child records deleted when parent deleted
- [SET NULL] - FK set to NULL when parent deleted
- [RESTRICT DELETE] - Cannot delete parent if children exist
- [CIRCULAR] - Bidirectional nullable relationship

---

# BUSINESS ID CROSS-REFERENCE

## Reservations Business IDs

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| reservations.reservations | RSV-{CO}-NNNNNN | RSV-MLVR-010001 | 10001 | Streamline VRS, OTA APIs, Guest Portal, Monday.com |
| reservations.guest_journeys | JRN-NNNNNN | JRN-010001 | 10001 | EVE AI Agent, Monday.com, Guest Portal, Team Dashboard |
| reservations.guest_journey_touchpoints | TP-NNNNNN | TP-010001 | 10001 | EVE AI Agent, Communication APIs, Analytics Dashboard |
| reservations.reviews | REV-NNNNNN | REV-010001 | 10001 | Review APIs (Airbnb, VRBO), Analytics Dashboard, Owner Portal |
| reservations.reservation_fees | N/A (junction) | N/A | N/A | Finance System |
| reservations.reservation_guests | N/A (junction) | N/A | N/A | Guest Portal |
| reservations.reservation_financials | N/A (1:1) | N/A | N/A | Finance System |
| reservations.damage_claims_legacy | DCL-NNNNNN | DCL-010001 | 10001 | Deprecated - use service.damage_claims |

## Cross-System Business ID Dependencies

| External System | References These Business IDs |
|----------------|-------------------------------|
| EVE AI Agent (Guest Experience) | JRN-*, TP-*, RSV-*, REV-* |
| Monday.com Workflow Automation | JRN-*, RSV-* |
| Streamline VRS | RSV-* |
| OTA APIs (Airbnb, VRBO, Booking.com) | RSV-*, REV-* |
| Guest Portal | JRN-*, TP-*, RSV-* |
| Communication APIs (SendGrid, Twilio) | TP-* |
| Analytics Dashboard | JRN-*, TP-*, REV-*, RSV-* |
| Owner Portal | REV-*, RSV-* |
| Team Dashboard | JRN-*, TP-* |
| Finance System | RSV-*, fee_type_code |
| Service Tickets | RSV-* |

---

# INDEX COVERAGE SUMMARY

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| **reservations** | pk_reservations | id (PK) | Primary key lookup |
| | idx_reservations_reservation_id | reservation_id (UNIQUE) | Business ID lookup |
| | idx_reservations_property | property_id | Property reservations |
| | idx_reservations_guest | guest_id | Guest history |
| | idx_reservations_dates | check_in_date, check_out_date | Date range queries |
| | idx_reservations_status | status | Status filtering |
| | idx_reservations_company | company_code | Entity filtering |
| | idx_reservations_platform | booking_platform | Platform analytics |
| | idx_reservations_checkin | check_in_date | Arrivals lookup |
| | idx_reservations_checkout | check_out_date | Departures lookup |
| | idx_reservations_upcoming | check_in_date WHERE status = 'confirmed' AND check_in_date > now() | Upcoming arrivals |
| | idx_reservations_streamline | streamline_reservation_id | Streamline sync |
| | idx_reservations_airbnb | airbnb_reservation_id | Airbnb sync |
| | idx_reservations_vrbo | vrbo_reservation_id | VRBO sync |
| **guest_journeys** | pk_guest_journeys | id (PK) | Primary key lookup |
| | idx_journeys_journey_id | journey_id (UNIQUE) | Business ID lookup |
| | idx_journeys_reservation | reservation_id (UNIQUE) | 1:1 reservation lookup |
| | idx_journeys_stage | current_stage_id | Current stage queries |
| | idx_journeys_status | journey_status | Status filtering |
| | idx_journeys_sentiment | current_sentiment | Sentiment analysis |
| | idx_journeys_assigned_agent | assigned_agent_code WHERE assigned_type = 'ai_agent' | AI agent workload |
| | idx_journeys_assigned_member | assigned_member_id WHERE assigned_type = 'team_member' | Team member workload |
| | idx_journeys_needs_attention | needs_attention WHERE needs_attention = true | Attention queue |
| | idx_journeys_next_touchpoint | next_touchpoint_scheduled_at | Scheduling queue |
| | idx_journeys_monday | monday_item_id | Monday.com sync |
| | idx_journeys_survey_pending | survey_sent_at WHERE survey_completed_at IS NULL | Survey follow-up |
| | idx_journeys_review_pending | review_requested_at WHERE review_received_at IS NULL | Review follow-up |
| **guest_journey_touchpoints** | pk_touchpoints | id (PK) | Primary key lookup |
| | idx_touchpoints_touchpoint_id | touchpoint_id (UNIQUE) | Business ID lookup |
| | idx_touchpoints_journey | journey_id | Journey event log |
| | idx_touchpoints_type | touchpoint_type_id | Type filtering |
| | idx_touchpoints_stage | stage_id | Stage filtering |
| | idx_touchpoints_status | status | Status filtering |
| | idx_touchpoints_scheduled | scheduled_at WHERE status = 'pending' | Scheduled queue |
| | idx_touchpoints_sent | sent_at | Sent timestamp queries |
| | idx_touchpoints_actor | actor_type, actor_agent_code | Actor tracking |
| | idx_touchpoints_channel | channel | Channel analytics |
| | idx_touchpoints_response | response_received WHERE response_received = true | Response tracking |
| | idx_touchpoints_outcome | outcome | Outcome analytics |
| | idx_touchpoints_ticket | linked_ticket_id | Ticket links |
| **reviews** | pk_reviews | id (PK) | Primary key lookup |
| | idx_reviews_review_id | review_id (UNIQUE) | Business ID lookup |
| | idx_reviews_reservation | reservation_id | Reservation lookup |
| | idx_reviews_property | property_id | Property analytics |
| | idx_reviews_guest | guest_id | Guest history |
| | idx_reviews_journey | journey_id | Journey link |
| | idx_reviews_clean | clean_id | Cleaner accountability |
| | idx_reviews_platform | platform | Platform filtering |
| | idx_reviews_date | review_date DESC | Chronological queries |
| | idx_reviews_rating | overall_rating | Rating analysis |
| | idx_reviews_sentiment | sentiment_score | Sentiment analysis |
| | idx_reviews_needs_response | needs_response WHERE needs_response = true | Response queue |
| **reservation_fees** | pk_reservation_fees | id (PK) | Primary key lookup |
| | idx_rf_reservation | reservation_id | Reservation's fees |
| | idx_rf_fee_type | fee_type_code | Fee type lookup |
| | idx_rf_unique | reservation_id, fee_type_code (UNIQUE) | One fee per type |
| **reservation_guests** | pk_reservation_guests | id (PK) | Primary key lookup |
| | idx_rg_reservation | reservation_id | Reservation's guests |
| | idx_rg_guest | guest_id | Guest's reservations |
| | idx_rg_unique | reservation_id, guest_id (UNIQUE) | Prevent duplicates |
| **reservation_financials** | pk_reservation_financials | id (PK) | Primary key lookup |
| | idx_rfi_reservation | reservation_id (UNIQUE) | 1:1 with reservation |
| **damage_claims_legacy** | pk_damage_claims_legacy | id (PK) | Primary key lookup |
| | idx_dcl_claim_id | claim_id (UNIQUE) | Business ID lookup |
| | idx_dcl_reservation | reservation_id | Reservation's claims |
| | idx_dcl_property | property_id | Property's claims |

---

# TABLE SPECIFICATIONS

---

## reservations.reservations

**PURPOSE:** Core reservation/booking data. Contains dates, guests, pricing, and links to properties. Source of truth from OTA platforms and direct bookings via Streamline VRS.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| reservation_id | text | NOT NULL, UNIQUE | Business ID: RSV-{CO}-NNNNNN | N/A |
| company_code | text | NOT NULL | Entity: MLVR, NASH, UVH | N/A |
| **Property & Guest** |
| property_id | uuid | FK → property.properties(id), NOT NULL | Booked property | ON DELETE: RESTRICT |
| guest_id | uuid | FK → directory.guests(id), NOT NULL | Primary guest | ON DELETE: RESTRICT |
| **Dates** |
| check_in_date | date | NOT NULL | Arrival date | N/A |
| check_out_date | date | NOT NULL | Departure date | N/A |
| nights | integer | NOT NULL | Number of nights (calculated) | N/A |
| **Times** |
| expected_arrival_time | time | | Guest expected arrival | N/A |
| actual_arrival_time | timestamptz | | Actual arrival timestamp | N/A |
| expected_departure_time | time | | Guest expected departure | N/A |
| actual_departure_time | timestamptz | | Actual departure timestamp | N/A |
| **Travel Details** |
| arrival_flight_number | text | | Inbound flight | N/A |
| arrival_flight_time | timestamptz | | Flight arrival time | N/A |
| departure_flight_number | text | | Outbound flight | N/A |
| departure_flight_time | timestamptz | | Flight departure time | N/A |
| transportation_method | text | | car, rental, shuttle, rideshare, other | N/A |
| **Occupancy** |
| adults | integer | NOT NULL, DEFAULT 1 | Number of adults | N/A |
| children | integer | DEFAULT 0 | Number of children | N/A |
| infants | integer | DEFAULT 0 | Number of infants | N/A |
| pets | integer | DEFAULT 0 | Number of pets | N/A |
| total_guests | integer | NOT NULL | Total occupancy | N/A |
| **Booking Details** |
| booking_platform | text | NOT NULL | direct, airbnb, vrbo, booking_com, expedia | N/A |
| booking_date | timestamptz | | When booking was made | N/A |
| confirmation_code | text | | Our confirmation code | N/A |
| **Pricing** |
| base_rate | numeric(12,2) | | Base accommodation rate | N/A |
| cleaning_fee | numeric(10,2) | | Cleaning fee charged | N/A |
| service_fee | numeric(10,2) | | Platform service fee | N/A |
| taxes | numeric(10,2) | | Total taxes | N/A |
| total_price | numeric(12,2) | | Total booking amount | N/A |
| currency_code | text | DEFAULT 'USD' | Currency | N/A |
| **Payments** |
| payment_status | text | DEFAULT 'pending' | pending, partial, paid, refunded | N/A |
| amount_paid | numeric(12,2) | DEFAULT 0 | Amount received | N/A |
| amount_due | numeric(12,2) | | Amount still owed | N/A |
| payout_amount | numeric(12,2) | | Amount to owner | N/A |
| **Late Checkout** |
| late_checkout_requested | boolean | DEFAULT false | Late checkout requested | N/A |
| late_checkout_approved | boolean | DEFAULT false | Late checkout approved | N/A |
| late_checkout_time | time | | Approved late checkout time | N/A |
| late_checkout_fee | numeric(10,2) | | Fee charged | N/A |
| **Status** |
| status | text | NOT NULL, DEFAULT 'confirmed' | confirmed, checked_in, checked_out, cancelled, no_show | N/A |
| cancellation_date | timestamptz | | When cancelled | N/A |
| cancellation_reason | text | | Why cancelled | N/A |
| cancellation_fee | numeric(10,2) | | Cancellation fee charged | N/A |
| **External IDs** |
| streamline_reservation_id | integer | UNIQUE | Streamline VRS ID | N/A |
| streamline_confirmation_id | text | | Streamline confirmation | N/A |
| airbnb_reservation_id | text | UNIQUE | Airbnb confirmation code | N/A |
| vrbo_reservation_id | text | UNIQUE | VRBO confirmation code | N/A |
| **Guest Communication** |
| special_requests | text | | Guest special requests | N/A |
| internal_notes | text | | Staff notes | N/A |
| **Sync** |
| last_sync_at | timestamptz | | Last external sync | N/A |
| sync_source | text | | Which system synced | N/A |
| **Audit** |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Record created | N/A |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Record updated | N/A |

**CHECK CONSTRAINT:** check_out_date > check_in_date

---

## reservations.guest_journeys

**PURPOSE:** Tracks the guest journey state for each reservation (1:1). Stores current stage, next touchpoint, sentiment, completion tracking, VIP flags, and assignment. This is a STATE table — see touchpoints for history.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| journey_id | text | NOT NULL, UNIQUE | Business ID: JRN-NNNNNN | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL, UNIQUE | 1:1 with reservation | ON DELETE: CASCADE |
| **Current State** |
| current_stage_id | uuid | FK → ref.journey_stages(id) | Current journey stage | ON DELETE: SET NULL |
| previous_stage_id | uuid | FK → ref.journey_stages(id) | Previous stage | ON DELETE: SET NULL |
| stage_entered_at | timestamptz | | When entered current stage | N/A |
| **Journey Status** |
| journey_status | text | NOT NULL, DEFAULT 'active' | active, completed, cancelled, on_hold | N/A |
| **Next Action** |
| next_touchpoint_type_id | uuid | FK → ref.touchpoint_types(id) | Next scheduled touchpoint | ON DELETE: SET NULL |
| next_touchpoint_scheduled_at | timestamptz | | When next touchpoint due | N/A |
| **Assignment** |
| assigned_type | text | | ai_agent, team_member | N/A |
| assigned_agent_code | text | | AI agent code (EVE, etc.) | N/A |
| assigned_member_id | uuid | FK → team.team_directory(id) | Assigned team member | ON DELETE: SET NULL |
| **Sentiment & Attention** |
| current_sentiment | text | | positive, neutral, negative, unknown | N/A |
| sentiment_score | numeric(3,2) | | -1.00 to 1.00 | N/A |
| needs_attention | boolean | DEFAULT false | Flagged for attention | N/A |
| attention_reason | text | | Why flagged | N/A |
| **VIP & Special** |
| is_vip | boolean | DEFAULT false | VIP guest | N/A |
| vip_reason | text | | Why VIP | N/A |
| is_repeat_guest | boolean | DEFAULT false | Returning guest | N/A |
| previous_stay_count | integer | DEFAULT 0 | Prior stays | N/A |
| **Completion Tracking** |
| touchpoints_completed | integer | DEFAULT 0 | Completed touchpoints | N/A |
| touchpoints_total | integer | DEFAULT 0 | Total touchpoints | N/A |
| completion_percentage | numeric(5,2) | DEFAULT 0 | % complete | N/A |
| **Survey** |
| survey_sent_at | timestamptz | | When survey sent | N/A |
| survey_completed_at | timestamptz | | When survey done | N/A |
| survey_score | integer | | Survey NPS score | N/A |
| **Review** |
| review_requested_at | timestamptz | | When review requested | N/A |
| review_received_at | timestamptz | | When review received | N/A |
| review_id | uuid | FK → reservations.reviews(id) | Linked review | ON DELETE: SET NULL |
| **External** |
| monday_item_id | text | | Monday.com item ID | N/A |
| **Audit** |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Record created | N/A |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Record updated | N/A |

**UNIQUE CONSTRAINT:** (reservation_id) — Enforces 1:1 relationship

---

## reservations.guest_journey_touchpoints

**PURPOSE:** Event log of all guest interactions (HISTORY table). Each row is one touchpoint with full lifecycle tracking. Links to surveys, reviews, tickets via nullable UUIDs.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| touchpoint_id | text | NOT NULL, UNIQUE | Business ID: TP-NNNNNN | N/A |
| journey_id | uuid | FK → reservations.guest_journeys(id), NOT NULL | Parent journey | ON DELETE: CASCADE |
| **Type & Stage** |
| touchpoint_type_id | uuid | FK → ref.touchpoint_types(id), NOT NULL | Type of touchpoint | ON DELETE: RESTRICT |
| stage_id | uuid | FK → ref.journey_stages(id) | Stage when occurred | ON DELETE: SET NULL |
| **Scheduling** |
| scheduled_at | timestamptz | | When scheduled | N/A |
| due_at | timestamptz | | When due | N/A |
| **Status** |
| status | text | NOT NULL, DEFAULT 'pending' | pending, sent, delivered, opened, completed, failed, skipped | N/A |
| **Execution** |
| sent_at | timestamptz | | When sent | N/A |
| delivered_at | timestamptz | | When delivered | N/A |
| opened_at | timestamptz | | When opened | N/A |
| completed_at | timestamptz | | When completed | N/A |
| failed_at | timestamptz | | When failed | N/A |
| failure_reason | text | | Why failed | N/A |
| **Channel** |
| channel | text | | email, sms, push, in_app, phone, whatsapp | N/A |
| **Actor** |
| actor_type | text | | ai_agent, team_member, system | N/A |
| actor_agent_code | text | | AI agent code | N/A |
| actor_member_id | uuid | FK → team.team_directory(id) | Team member | ON DELETE: SET NULL |
| **Content** |
| subject | text | | Message subject | N/A |
| content_preview | text | | Content preview | N/A |
| template_used | text | | Template ID | N/A |
| **Response** |
| response_received | boolean | DEFAULT false | Got response | N/A |
| response_at | timestamptz | | When responded | N/A |
| response_content | text | | Response text | N/A |
| response_sentiment | text | | positive, neutral, negative | N/A |
| **Outcome** |
| outcome | text | | success, partial, no_response, negative | N/A |
| outcome_notes | text | | Outcome details | N/A |
| **Links** |
| linked_survey_id | uuid | | concierge.guest_surveys(id) | N/A |
| linked_itinerary_id | uuid | | concierge.itineraries(id) | N/A |
| linked_review_id | uuid | FK → reservations.reviews(id) | Linked review | ON DELETE: SET NULL |
| linked_ticket_id | uuid | FK → service.tickets(id) | Linked ticket | ON DELETE: SET NULL |
| linked_offer_id | uuid | | Future offers table | N/A |
| **Metadata** |
| metadata | jsonb | | Additional data | N/A |
| **Audit** |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Record created | N/A |

---

## reservations.reviews

**PURPOSE:** Guest reviews from all platforms. Links to clean for cleaner accountability. AI extracts sentiment, themes, issues, and compliments for automated routing and analysis.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| review_id | text | NOT NULL, UNIQUE | Business ID: REV-NNNNNN | N/A |
| **Links** |
| reservation_id | uuid | FK → reservations.reservations(id) | Which reservation | ON DELETE: SET NULL |
| journey_id | uuid | FK → reservations.guest_journeys(id) | Journey link | ON DELETE: SET NULL |
| property_id | uuid | FK → property.properties(id) | Property reviewed | ON DELETE: SET NULL |
| guest_id | uuid | FK → directory.guests(id) | Reviewer | ON DELETE: SET NULL |
| clean_id | uuid | FK → property.cleans(id) | Related clean (accountability) | ON DELETE: SET NULL |
| **Review Source** |
| platform | text | NOT NULL | airbnb, vrbo, google, direct, booking_com | N/A |
| platform_review_id | text | | Platform's review ID | N/A |
| review_url | text | | URL to review | N/A |
| **Timing** |
| review_date | date | NOT NULL | When reviewed | N/A |
| stay_check_in_date | date | | Stay check-in (denormalized) | N/A |
| stay_check_out_date | date | | Stay check-out (denormalized) | N/A |
| **Rating** |
| overall_rating | numeric(3,2) | | Overall score (platform scale) | N/A |
| rating_max | numeric(3,2) | DEFAULT 5.00 | Max possible score | N/A |
| normalized_rating | numeric(3,2) | | Normalized 0-5 scale | N/A |
| **Category Ratings** |
| cleanliness_rating | numeric(3,2) | | Cleanliness score | N/A |
| communication_rating | numeric(3,2) | | Communication score | N/A |
| checkin_rating | numeric(3,2) | | Check-in score | N/A |
| accuracy_rating | numeric(3,2) | | Accuracy score | N/A |
| location_rating | numeric(3,2) | | Location score | N/A |
| value_rating | numeric(3,2) | | Value score | N/A |
| **Review Content** |
| title | text | | Review title | N/A |
| public_review | text | | Public review text | N/A |
| private_feedback | text | | Private feedback | N/A |
| **AI Analysis** |
| sentiment_score | numeric(3,2) | | -1.00 to 1.00 | N/A |
| sentiment_label | text | | positive, neutral, negative | N/A |
| ai_summary | text | | AI-generated summary | N/A |
| extracted_themes | text[] | | Key themes | N/A |
| extracted_issues | text[] | | Issues mentioned | N/A |
| extracted_compliments | text[] | | Compliments mentioned | N/A |
| **Response** |
| needs_response | boolean | DEFAULT false | Response needed | N/A |
| response_priority | text | | high, medium, low | N/A |
| responded_at | timestamptz | | When responded | N/A |
| response_text | text | | Our response | N/A |
| responded_by_member_id | uuid | FK → team.team_directory(id) | Who responded | ON DELETE: SET NULL |
| **Visibility** |
| is_public | boolean | DEFAULT true | Publicly visible | N/A |
| is_verified | boolean | DEFAULT false | Verified stay | N/A |
| **Owner Sharing** |
| shared_with_owner | boolean | DEFAULT false | Shared with homeowner | N/A |
| shared_at | timestamptz | | When shared | N/A |
| owner_notified | boolean | DEFAULT false | Owner notified | N/A |
| **Status** |
| status | text | DEFAULT 'active' | active, hidden, disputed | N/A |
| **Audit** |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Record created | N/A |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Record updated | N/A |

---

## reservations.reservation_fees

**PURPOSE:** Tracks actual fees charged on a reservation. Links to ref.fee_types for fee definitions. Supports adjustments and audit trail.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL | Parent reservation | ON DELETE: CASCADE |
| **Fee Info** |
| fee_type_code | text | FK → ref.fee_types(fee_code), NOT NULL | Fee type | ON DELETE: RESTRICT |
| fee_name | text | NOT NULL | Display name | N/A |
| **Amount** |
| original_amount | numeric(10,2) | NOT NULL | Original amount | N/A |
| adjusted_amount | numeric(10,2) | | Adjusted amount (if changed) | N/A |
| final_amount | numeric(10,2) | NOT NULL | Final charged amount | N/A |
| **Calculation** |
| calculation_type | text | NOT NULL | flat, percent, per_night, per_guest | N/A |
| calculation_basis | numeric(12,2) | | Basis for calculation | N/A |
| calculation_rate | numeric(10,4) | | Rate used | N/A |
| **Adjustment** |
| is_adjusted | boolean | DEFAULT false | Was adjusted | N/A |
| adjustment_reason | text | | Why adjusted | N/A |
| adjusted_by_member_id | uuid | FK → team.team_directory(id) | Who adjusted | ON DELETE: SET NULL |
| adjusted_at | timestamptz | | When adjusted | N/A |
| **Tax** |
| is_taxable | boolean | DEFAULT false | Subject to tax | N/A |
| tax_amount | numeric(10,2) | | Tax on this fee | N/A |
| **Billing** |
| billable_to | text | DEFAULT 'guest' | guest, owner, company | N/A |
| is_refundable | boolean | DEFAULT false | Refundable | N/A |
| **Audit** |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Record created | N/A |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Record updated | N/A |

**UNIQUE CONSTRAINT:** (reservation_id, fee_type_code) — One fee per type per reservation

---

## reservations.reservation_guests

**PURPOSE:** Additional guests on a reservation beyond the primary guest. Supports guest manifests and contact tracking.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL | Parent reservation | ON DELETE: CASCADE |
| guest_id | uuid | FK → directory.guests(id) | Guest record (if exists) | ON DELETE: SET NULL |
| **Guest Info (if no guest record)** |
| first_name | text | | First name | N/A |
| last_name | text | | Last name | N/A |
| email | text | | Email | N/A |
| phone | text | | Phone | N/A |
| **Demographics** |
| guest_type | text | NOT NULL, DEFAULT 'adult' | adult, child, infant | N/A |
| age | integer | | Age if provided | N/A |
| **Role** |
| is_primary | boolean | DEFAULT false | Primary guest (redundant check) | N/A |
| relationship_to_primary | text | | spouse, family, friend, colleague | N/A |
| **Audit** |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Record created | N/A |

**UNIQUE CONSTRAINT:** (reservation_id, guest_id) WHERE guest_id IS NOT NULL — Prevent duplicate guest links

---

## reservations.reservation_financials

**PURPOSE:** Aggregated financial summary for a reservation. 1:1 with reservation. Calculated/denormalized for reporting performance.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL, UNIQUE | 1:1 with reservation | ON DELETE: CASCADE |
| **Revenue** |
| gross_booking_value | numeric(12,2) | | Total guest paid | N/A |
| net_booking_value | numeric(12,2) | | After platform fees | N/A |
| accommodation_revenue | numeric(12,2) | | Room revenue | N/A |
| fees_revenue | numeric(12,2) | | Fees revenue | N/A |
| taxes_collected | numeric(12,2) | | Taxes collected | N/A |
| **Costs** |
| platform_fees | numeric(10,2) | | OTA/platform fees | N/A |
| payment_processing_fees | numeric(10,2) | | Credit card fees | N/A |
| cleaning_cost | numeric(10,2) | | Cleaning expense | N/A |
| management_fee | numeric(10,2) | | Our management fee | N/A |
| other_costs | numeric(10,2) | | Other costs | N/A |
| **Owner** |
| owner_payout | numeric(12,2) | | Amount to owner | N/A |
| owner_payout_status | text | | pending, paid, held | N/A |
| owner_payout_date | date | | When paid to owner | N/A |
| **Company** |
| company_revenue | numeric(12,2) | | Our revenue | N/A |
| company_margin | numeric(5,2) | | Margin percentage | N/A |
| **Metrics** |
| adr | numeric(10,2) | | Average daily rate | N/A |
| revpar | numeric(10,2) | | RevPAR contribution | N/A |
| **Calculated** |
| calculated_at | timestamptz | NOT NULL, DEFAULT now() | When calculated | N/A |
| **Audit** |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Record created | N/A |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Record updated | N/A |

**UNIQUE CONSTRAINT:** (reservation_id) — 1:1 relationship

---

## reservations.damage_claims_legacy

**PURPOSE:** DEPRECATED — Legacy damage claim storage. New damage claims should use service.damage_claims. Kept for historical data only.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| claim_id | text | NOT NULL, UNIQUE | Business ID: DCL-NNNNNN | N/A |
| reservation_id | uuid | FK → reservations.reservations(id), NOT NULL | Related reservation | ON DELETE: CASCADE |
| property_id | uuid | FK → property.properties(id) | Property | ON DELETE: SET NULL |
| **Claim Info** |
| claim_date | date | NOT NULL | When claimed | N/A |
| description | text | NOT NULL | Damage description | N/A |
| estimated_cost | numeric(10,2) | | Estimated repair cost | N/A |
| actual_cost | numeric(10,2) | | Actual repair cost | N/A |
| **Resolution** |
| status | text | DEFAULT 'open' | open, submitted, approved, denied, paid, closed | N/A |
| resolution_notes | text | | Resolution details | N/A |
| amount_recovered | numeric(10,2) | | Amount recovered | N/A |
| recovered_from | text | | guest, insurance, platform | N/A |
| **Audit** |
| created_at | timestamptz | NOT NULL, DEFAULT now() | Record created | N/A |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | Record updated | N/A |

**NOTE:** This table is deprecated. Use service.damage_claims for new damage tracking.

---

# REF TABLES REQUIRED

The reservations schema requires these reference tables:

| Ref Table | Used By | Description |
|-----------|---------|-------------|
| ref.journey_stages | guest_journeys | 14 journey stages |
| ref.touchpoint_types | guest_journeys, guest_journey_touchpoints | Touchpoint definitions |
| ref.stage_required_touchpoints | (junction) | Stage → touchpoint mappings |
| ref.fee_types | reservation_fees | Fee type definitions |
| ref.fee_rates | (configuration) | Fee rate scoping |

## ref.journey_stages

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | PK |
| stage_code | text | UNIQUE — booking_new, days_30, days_14, days_7, days_3, day_1, check_in_day, in_stay, check_out_day, post_stay_1, post_stay_3, post_stay_7, post_stay_30, completed |
| stage_name | text | Display name |
| description | text | Stage description |
| sequence_order | integer | Stage sequence |
| trigger_type | text | days_before_arrival, days_after_departure, event |
| trigger_days_before_arrival | integer | Days relative to check-in |
| trigger_days_after_departure | integer | Days relative to check-out |
| is_active | boolean | Active flag |

## ref.touchpoint_types

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | PK |
| type_code | text | UNIQUE — booking_confirmation, welcome_email, pre_arrival_survey, check_in_instructions, mid_stay_check, check_out_reminder, post_stay_survey, review_request, etc. |
| type_name | text | Display name |
| category | text | confirmation, information, survey, marketing, service |
| default_channel | text | email, sms, push, in_app |
| template_id | text | Default template |
| is_automated | boolean | Automated or manual |
| requires_response | boolean | Expects response |
| is_active | boolean | Active flag |

## ref.stage_required_touchpoints

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | PK |
| stage_id | uuid | FK → journey_stages |
| touchpoint_type_id | uuid | FK → touchpoint_types |
| is_required | boolean | Must complete for stage |
| sequence_in_stage | integer | Order within stage |
| hours_into_stage | integer | When to trigger |
| is_active | boolean | Active flag |

## ref.fee_types

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | PK |
| fee_code | text | UNIQUE — cleaning_fee, pet_fee, late_checkout_fee, resort_fee, tat, get, airbnb_service, vrbo_service, etc. |
| fee_name | text | Display name |
| fee_category | text | mandatory, optional, tax, platform |
| calculation_type | text | flat, percent, per_night, per_guest, per_pet |
| description | text | Fee description |
| is_taxable | boolean | Subject to tax |
| is_refundable | boolean | Refundable |
| is_active | boolean | Active flag |

## ref.fee_rates

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | PK |
| fee_type_id | uuid | FK → fee_types |
| scope_level | text | global, company, platform, property |
| scope_company_code | text | Company if scoped |
| scope_platform | text | Platform if scoped |
| scope_property_id | uuid | Property if scoped |
| rate_value | numeric(10,4) | Rate amount |
| rate_type | text | amount, percentage |
| effective_from | date | Rate start |
| effective_to | date | Rate end |
| is_active | boolean | Active flag |

---

# CROSS-SCHEMA DEPENDENCIES

## Schemas That Reference Reservations

| Schema | Tables | FK Target |
|--------|--------|-----------|
| property | cleans, inspections | reservations.reservations |
| service | tickets, ticket_reservations, damage_claims | reservations.reservations |
| finance | transactions, owner_statements | reservations.reservations |
| concierge | itineraries, guest_surveys | reservations.reservations, reservations.guest_journeys |
| comms | messages | reservations.reservations |

## Reservations References Other Schemas

| Target Schema | Target Table | From Reservations Table |
|---------------|--------------|------------------------|
| property | properties | reservations, reviews, damage_claims_legacy |
| property | cleans | reviews |
| directory | guests | reservations, reservation_guests, reviews |
| team | team_directory | guest_journeys, guest_journey_touchpoints, reservation_fees, reviews |
| service | tickets | guest_journey_touchpoints |
| ref | journey_stages | guest_journeys |
| ref | touchpoint_types | guest_journeys, guest_journey_touchpoints |
| ref | fee_types | reservation_fees |

---

# KEY WORKFLOWS

## Guest Journey Flow

```
1. Reservation created → guest_journey created (1:1)
2. Journey enters "booking_new" stage
3. Touchpoints generated based on ref.stage_required_touchpoints
4. As touchpoints complete → log in guest_journey_touchpoints
5. When all required touchpoints done → advance stage
6. Repeat until "completed" stage
7. Reviews captured → linked to journey
```

## Review Accountability Flow

```
1. Guest submits review
2. Review linked to reservation → journey → property → clean
3. AI analyzes sentiment, extracts themes
4. If cleanliness issue detected → flag clean_id
5. Cleaner accountability tracked via clean_id link
```

---

**Document Version:** 1.0  
**Last Updated:** December 9, 2025  
**Total Tables:** 8  
**Ref Tables Required:** 5 (journey_stages, touchpoint_types, stage_required_touchpoints, fee_types, fee_rates)
