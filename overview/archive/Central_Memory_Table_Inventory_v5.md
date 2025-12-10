# Central Memory — Complete Table Inventory v5

**Last Updated:** November 30, 2025  
**Schemas:** ops, ref, geo, concierge, staging  
**Total Tables:** 120+  
**Built Tables:** 9 (with ~24,000 records)

---

## Quick Reference — All Tables by Schema (PK/FK Summary)

### OPS Schema (46 Tables)

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| **ops.contacts** ✅ | `contact_id` | — |
| **ops.guests** ✅ | `guest_id` | `contact_id` → contacts |
| **ops.reservations** ✅ | `reservation_id` | `property_id` → properties, `primary_guest_id` → guests |
| **ops.resorts** ✅ | `resort_id` | — |
| **ops.properties** ✅ | `property_id` | `resort_id` → resorts, `area_id` → geo.areas, `closest_beach_id` → concierge.beaches |
| **ops.homeowners** ✅ | `homeowner_id` | `contact_id` → contacts |
| **ops.homeowner_property_relationship** ✅ | `hprx_id` | `homeowner_id` → homeowners, `property_id` → properties |
| **ops.property_care_tickets** ✅ | `ticket_id` | `property_id` → properties, `reservation_id` → reservations, `homeowner_id` → homeowners, `requestor_contact_id` → contacts, `assigned_company_id` → companies, `primary_assignee_member_id` → team_directory, `shift_id` → team_shifts, `inspection_id` → inspections |
| **ops.reservation_tickets** ✅ | `ticket_id` | `reservation_id` → reservations, `property_id` → properties, `homeowner_id` → homeowners, `requestor_contact_id` → contacts |
| ops.companies 🔵 | `company_id` | `primary_contact_id` → contacts, `billing_contact_id` → contacts, `scheduling_contact_id` → contacts, `technician_contact_id` → contacts, `area_id` → geo.areas |
| ops.team_directory 🔵 | `member_id` | `contact_id` → contacts, `team_id` → teams, `manager_id` → team_directory |
| ops.teams 🔵 | `team_id` | `team_lead_id` → team_directory |
| ops.team_shifts 🔵 | `shift_id` | `member_id` → team_directory |
| ops.admin_tickets 🔵 | `ticket_id` | `property_id` → properties, `reservation_id` → reservations, `requestor_contact_id` → contacts, `assigned_to_member_id` → team_directory |
| ops.accounting_tickets 🔵 | `ticket_id` | `homeowner_id` → homeowners, `property_id` → properties, `requestor_contact_id` → contacts, `related_ticket_id` → property_care_tickets, `assigned_to_member_id` → team_directory |
| ops.ai_agents 🔵 | `agent_id` | — |
| ops.rooms 🔵 | `room_id` | `property_id` → properties |
| ops.beds 🔵 | `bed_id` | `room_id` → rooms |
| ops.appliances 🔵 | `appliance_id` | `room_id` → rooms |
| ops.appliance_parts 🔵 | `part_id` | `appliance_id` → appliances |
| ops.fixtures 🔵 | `fixture_id` | `room_id` → rooms |
| ops.surfaces 🔵 | `surface_id` | `room_id` → rooms |
| ops.lighting 🔵 | `lighting_id` | `room_id` → rooms |
| ops.window_coverings 🔵 | `covering_id` | `room_id` → rooms |
| ops.room_features 🔵 | `feature_id` | `room_id` → rooms |
| ops.ac_systems 🔵 | `system_id` | `property_id` → properties |
| ops.ac_units 🔵 | `unit_id` | `system_id` → ac_systems, `room_id` → rooms |
| ops.property_doors 🔵 | `door_id` | `property_id` → properties, `room_id` → rooms |
| ops.property_locks 🔵 | `lock_id` | `door_id` → property_doors |
| ops.key_checkouts 🔵 | `checkout_id` | `lock_id` → property_locks, `checked_out_to_contact_id` → contacts |
| ops.cleans 🔵 | `clean_id` | `property_id` → properties, `checkout_reservation_id` → reservations, `checkin_reservation_id` → reservations, `performed_by_member_id` → team_directory, `inspection_id` → inspections |
| ops.inspections 🔵 | `inspection_id` | `property_id` → properties, `clean_id` → cleans, `checkin_reservation_id` → reservations, `performed_by_member_id` → team_directory |
| ops.inspection_questions 🔵 | `question_id` | — |
| ops.inspection_room_questions 🔵 | `room_question_id` | `inspection_id` → inspections, `room_id` → rooms, `question_id` → inspection_questions |
| ops.reviews 🔵 | `review_id` | `reservation_id` → reservations, `property_id` → properties, `guest_id` → guests, `clean_id` → cleans |
| ops.storage_locations 🔵 | `location_id` | `parent_location_id` → storage_locations |
| ops.inventory_items 🔵 | `item_id` | `supplier_company_id` → companies |
| ops.inventory_stock 🔵 | `stock_id` | `item_id` → inventory_items, `location_id` → storage_locations |
| ops.inventory_events 🔵 | `event_id` | `item_id` → inventory_items, `from_location_id` → storage_locations, `to_location_id` → storage_locations, `property_id` → properties, `performed_by_member_id` → team_directory |
| ops.linen_items 🔵 | `linen_item_id` | `supplier_company_id` → companies |
| ops.linen_lots 🔵 | `lot_id` | `linen_item_id` → linen_items, `purchase_order_id` → purchase_orders |
| ops.linen_movements 🔵 | `movement_id` | `lot_id` → linen_lots, `property_id` → properties, `performed_by_member_id` → team_directory |
| ops.guest_supplies 🔵 | `supply_id` | `supplier_company_id` → companies |
| ops.guest_supply_usage 🔵 | `usage_id` | `supply_id` → guest_supplies, `property_id` → properties, `reservation_id` → reservations, `stocked_by_member_id` → team_directory |
| ops.purchase_orders 🔵 | `po_id` | `company_id` → companies, `ticket_id` → property_care_tickets, `ordered_by_member_id` → team_directory |
| ops.po_items 🔵 | `po_item_id` | `po_id` → purchase_orders, `inventory_item_id` → inventory_items, `linen_item_id` → linen_items, `guest_supply_id` → guest_supplies |
| ops.receipts 🔵 | `receipt_id` | `submitted_by_member_id` → team_directory, `po_item_id` → po_items, `property_id` → properties, `ticket_id` → property_care_tickets |
| ops.purchases 🔵 | `purchase_id` | `po_id` → purchase_orders, `company_id` → companies, `property_id` → properties |
| ops.cost_history 🔵 | `cost_id` | `supplier_company_id` → companies |
| ops.transactions 🔵 | `transaction_id` | `property_id` → properties, `reservation_id` → reservations, `homeowner_id` → homeowners |
| ops.payroll 🔵 | `payroll_id` | `member_id` → team_directory |
| ops.financial_reports 🔵 | `report_id` | `property_id` → properties, `homeowner_id` → homeowners |
| ops.communication_threads 🔵 | `thread_id` | — |
| ops.communication_messages 🔵 | `message_id` | `thread_id` → communication_threads, `sender_contact_id` → contacts, `sender_ai_agent_id` → ai_agents |
| ops.calls_log 🔵 | `call_id` | `contact_id` → contacts, `thread_id` → communication_threads |

---

### REF Schema (10 Tables)

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| ref.activity_levels 🔵 | `activity_level_id` | — |
| ref.limitation_types 🔵 | `limitation_type_id` | — |
| ref.interest_categories 🔵 | `category_id` | — |
| ref.interest_types 🔵 | `interest_type_id` | `category_id` → interest_categories, `activity_level_id` → activity_levels |
| ref.schedule_density_levels 🔵 | `density_level_id` | — |
| ref.driving_tolerance_levels 🔵 | `tolerance_level_id` | — |
| ref.budget_levels 🔵 | `budget_level_id` | — |
| ref.status_master 🔵 | `status_name` | — |
| ref.status_applies_to 🔵 | `id` | `status_name` → status_master |
| ref.status_transitions 🔵 | `id` | `from_status` → status_master, `to_status` → status_master |

---

### GEO Schema (3 Tables)

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| geo.zones 🔵 | `zone_id` | — |
| geo.cities 🔵 | `city_id` | `zone_id` → zones |
| geo.areas 🔵 | `area_id` | `city_id` → cities |

---

### CONCIERGE Schema (17 Tables)

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| concierge.beaches 🔵 | `beach_id` | `area_id` → geo.areas |
| concierge.hikes 🔵 | `hike_id` | `area_id` → geo.areas |
| concierge.activities 🔵 | `activity_id` | `area_id` → geo.areas, `company_id` → ops.companies, `activity_level_id` → ref.activity_levels |
| concierge.restaurants 🔵 | `restaurant_id` | `area_id` → geo.areas, `company_id` → ops.companies, `shopping_location_id` → shopping_locations, `resort_id` → ops.resorts |
| concierge.attractions 🔵 | `attraction_id` | `area_id` → geo.areas, `company_id` → ops.companies |
| concierge.shops 🔵 | `shop_id` | `area_id` → geo.areas, `company_id` → ops.companies, `shopping_location_id` → shopping_locations, `resort_id` → ops.resorts |
| concierge.shopping_locations 🔵 | `location_id` | `area_id` → geo.areas |
| concierge.experience_spots 🔵 | `spot_id` | `area_id` → geo.areas |
| concierge.guest_travel_profiles 🔵 | `profile_id` | `guest_id` → ops.guests, `activity_level_id` → ref.activity_levels, `schedule_density_id` → ref.schedule_density_levels, `driving_tolerance_id` → ref.driving_tolerance_levels, `budget_level_id` → ref.budget_levels |
| concierge.guest_interests 🔵 | `id` | `guest_id` → ops.guests, `interest_type_id` → ref.interest_types |
| concierge.guest_limitations 🔵 | `id` | `guest_id` → ops.guests, `limitation_type_id` → ref.limitation_types |
| concierge.itinerary_themes 🔵 | `theme_id` | `ideal_activity_level_id` → ref.activity_levels, `ideal_schedule_density_id` → ref.schedule_density_levels, `ideal_driving_tolerance_id` → ref.driving_tolerance_levels, `ideal_budget_level_id` → ref.budget_levels |
| concierge.theme_interest_weights 🔵 | `id` | `theme_id` → itinerary_themes, `interest_type_id` → ref.interest_types |
| concierge.theme_limitations_excluded 🔵 | `id` | `theme_id` → itinerary_themes, `limitation_type_id` → ref.limitation_types |
| concierge.itineraries 🔵 | `itinerary_id` | `reservation_id` → ops.reservations, `guest_id` → ops.guests, `property_id` → ops.properties, `theme_id` → itinerary_themes, `profile_id` → guest_travel_profiles |
| concierge.itinerary_days 🔵 | `day_id` | `itinerary_id` → itineraries |
| concierge.itinerary_items 🔵 | `item_id` | `day_id` → itinerary_days, `beach_id` → beaches, `restaurant_id` → restaurants, `activity_id` → activities, `hike_id` → hikes, `attraction_id` → attractions, `shop_id` → shops, `experience_spot_id` → experience_spots |

---

### STAGING Schema (7 Tables)

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| staging.properties ✅ | `property_id` | — |
| staging.resorts ✅ | `database_id` | — |
| staging.guests ✅ | `guest_id` | — |
| staging.reservations ✅ | `reservation_id` | — |
| staging.homeowners ✅ | `homeowner_id` | — |
| staging.homeowner_property_relationships ✅ | `hprx_id` | — |
| staging.internal_team ✅ | `database_id` | — |

---

### Legend

- ✅ = Built and operational
- 🔵 = To be built

---

## Summary Statistics

| Schema | Built | To Build | Total |
|--------|-------|----------|-------|
| ops | 9 | 46 | 55 |
| ref | 0 | 10 | 10 |
| geo | 0 | 3 | 3 |
| concierge | 0 | 17 | 17 |
| staging | 7 | 0 | 7 |
| **TOTAL** | **16** | **76** | **92** |

---

## Table of Contents

1. [OPS Schema — Built Tables](#1-ops-schema--built-tables)
2. [OPS Schema — To Build Tables](#2-ops-schema--to-build-tables)
3. [REF Schema — Reference/Lookup Tables](#3-ref-schema--referencelookup-tables)
4. [GEO Schema — Spatial/Geographic Tables](#4-geo-schema--spatialgeographic-tables)
5. [CONCIERGE Schema — Guest Experience Tables](#5-concierge-schema--guest-experience-tables)
6. [STAGING Schema — Staging Tables](#6-staging-schema--staging-tables)

---

## 1. OPS Schema — Built Tables

### 1.1 ops.contacts ✅ (~4,735 records)
*Unified contact hub for all person entities*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| contact_type | text | NOT NULL, CHECK | guest, homeowner, vendor, internal_team, other |
| contact_id | text | NOT NULL, UNIQUE | Business ID: CON-{TYPE}-NNNNNN |
| entity_id | text | | Link to entity-specific table |
| status | text | | Active status |
| full_name | text | | Full display name |
| first_name | text | | First name |
| middle_name | text | | Middle name |
| last_name | text | | Last name |
| preferred_name | text | | Nickname/preferred name |
| preferred_contact_method | text | | email, phone, text, etc. |
| response_rate | numeric(5,2) | | Response rate percentage |
| communication_tone | text | | formal, casual, etc. |
| email | text | | Primary email |
| phone | text | | Primary phone |
| phone2 | text | | Secondary phone |
| phone3 | text | | Tertiary phone |
| birth_date | date | | Date of birth |
| age | integer | | Calculated age |
| gender | text | | Gender |
| language_preference | text | | Preferred language |
| home_state | text | | Home state |
| home_zip_code | text | | Home ZIP |
| home_country | text | | Home country |
| physical_address | text | | Physical address line 1 |
| physical_address_2 | text | | Physical address line 2 |
| physical_city | text | | Physical city |
| physical_state | text | | Physical state |
| physical_zip | text | | Physical ZIP |
| physical_country | text | | Physical country |
| mailing_address | text | | Mailing address line 1 |
| mailing_address_2 | text | | Mailing address line 2 |
| mailing_city | text | | Mailing city |
| mailing_state | text | | Mailing state |
| mailing_zip | text | | Mailing ZIP |
| mailing_country | text | | Mailing country |
| raw_phone | text | | Unformatted phone |
| raw_phone2 | text | | Unformatted phone 2 |
| raw_phone3 | text | | Unformatted phone 3 |
| source_system | text | | Source system name |
| source_record_id | text | | ID in source system |
| household_id | text | | Household grouping ID |
| is_primary_household_contact | boolean | | Primary contact flag |
| linked_documents | jsonb | | Document links |
| linked_communication_docs | jsonb | | Communication doc links |
| linked_communication_threads | jsonb | | Thread links |
| linked_communication_messages | jsonb | | Message links |
| source_id | text | | Additional source ID |
| last_contact_date | date | | Last interaction date |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 1.2 ops.guests ✅ (~4,735 records)
*Guest profiles with behavioral and preference data*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | Internal UUID |
| guest_id | text | NOT NULL, UNIQUE | Business ID: GST-NNNNNN |
| contact_id | text | FK→contacts | Link to contacts table |
| reservations_group_id | text | | Group booking ID |
| reservations | jsonb | | Reservation history |
| properties | jsonb | | Properties stayed at |
| transactions | jsonb | | Transaction history |
| rsv_folios | jsonb | | Reservation folios |
| total_amount_spent | numeric(12,2) | | Lifetime spend |
| avg_spend_per_night | numeric(12,2) | | Average nightly spend |
| avg_spend_per_trip | numeric(12,2) | | Average trip spend |
| avg_spend_per_guest | numeric(12,2) | | Per-guest spend |
| highest_rsv_amount | numeric(12,2) | | Highest booking amount |
| repeat_book_flag | boolean | | Repeat guest indicator |
| promo | text | | Promo code used |
| preferred_property_features | text[] | | Preferred amenities |
| interests | text[] | | Guest interests |
| restaurant_preferences | text[] | | Dining preferences |
| favorite_restaurants | text[] | | Favorite restaurants |
| discount_eligible_restaurants | text[] | | Discount-eligible venues |
| arrival_times | timestamptz[] | | Historical arrival times |
| departure_times | timestamptz[] | | Historical departure times |
| frequent_arrival_time_window | text | | Typical arrival window |
| airlines_used | text[] | | Airlines flown |
| airports_used | text[] | | Airports used |
| travel_styles | text[] | | Travel style tags |
| expectation_level | numeric(5,2) | | Expectation score |
| is_vip | boolean | | VIP flag |
| activity_suggestions_sent | integer | | Suggestions sent count |
| additional_services_purchased | integer | | Add-on purchases |
| activities_booked | integer | | Activities booked |
| return_guest_probability | numeric(5,4) | | Return probability |
| personality_tags | text[] | | Personality indicators |
| sentiment_score | numeric(5,2) | | Overall sentiment |
| total_bookings | integer | | Total reservation count |
| first_booking_date | date | | First booking date |
| most_recent_booking_date | date | | Most recent booking |
| avg_length_of_stay | numeric(6,2) | | Average stay length |
| service_sensitivity | text | | Service sensitivity level |
| feedback_submissions | integer | | Feedback count |
| feedback_score | numeric(5,2) | | Feedback score |
| private_feedback | text | | Private feedback notes |
| reviews | jsonb | | Review data |
| no_reviews | integer | | Review count |
| review_rating | numeric(4,2) | | Average review rating |
| latest_review | text | | Most recent review |
| latest_review_rating | numeric(4,2) | | Latest review rating |
| group_review_rating | numeric(4,2) | | Group rating |
| first_review_date | date | | First review date |
| gave_negative_review | boolean | | Negative review flag |
| csat_score | numeric(4,2) | | CSAT score |
| csat_surveys | integer | | Survey count |
| travel_style | text | | Primary travel style |
| total_additional_services_spend | numeric(12,2) | | Add-on spend |
| total_activities_spend | numeric(12,2) | | Activities spend |
| source_system | text | | Source system |
| source_record_id | text | | Source record ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 1.3 ops.reservations ✅ (~19,000 records)
*Reservation master with full financial and status tracking*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| streamline_confirmation_id | text | NOT NULL | Streamline confirmation # |
| reservation_id | text | NOT NULL, UNIQUE | Business ID: RSV-{TYPE}-NNNNNN |
| primary_guest_id | text | FK→guests | Primary guest |
| guest_stage | text | | Guest journey stage |
| reservation_status | text | | Current status |
| review_status | text | | Review collection status |
| guest_registration_status | text | | Registration status |
| primary_phone | text | | Guest phone |
| primary_email | text | | Guest email |
| property_id | text | FK→properties | Property booked |
| resort_id | text | | Resort ID |
| guest_experience_agent_id | text | | Assigned agent |
| property_status | text | | Property status at booking |
| additional_services | text | | Add-on services |
| arrival_date | date | | Check-in date |
| arrival_time | time | | Expected arrival time |
| departure_date | date | | Check-out date |
| guest_count | integer | | Total guests |
| adult_count | integer | | Adult count |
| child_count | integer | | Child count |
| infant_count | integer | | Infant count |
| departure_time | time | | Departure time |
| inspection_time | timestamptz | | Scheduled inspection |
| reservation_type | text | | Booking type |
| next_followup_date | timestamptz | | Next follow-up |
| add_ons_offered | boolean | | Add-ons offered flag |
| add_nights_offered | boolean | | Extended stay offered |
| action_date | timestamptz | | Action required date |
| booking_platform | text | | OTA or direct |
| booked_at | timestamptz | | Booking timestamp |
| booked_days_in_advance | integer | | Days before arrival |
| booked_on_holiday | boolean | | Holiday booking flag |
| booked_day_of_week | text | | Day booked |
| revenue_amount | numeric(12,2) | | Net revenue |
| total_amount | numeric(12,2) | | Gross total |
| balance_amount | numeric(12,2) | | Amount due |
| additional_services_amount | numeric(12,2) | | Add-on revenue |
| additional_nights | integer | | Extended nights |
| guest_comments | text | | Guest notes |
| reservation_tags | text[] | | Tags/labels |
| summarized_updates | text | | AI summary |
| service_recommendations | text | | AI recommendations |
| sentiment | text | | Overall sentiment |
| people | integer | | Total people |
| guest_request | text | | Special requests |
| request_status | text | | Request status |
| call_status | text | | Call status |
| promotion_code | text | | Promo code |
| last_sl_update | timestamptz | | Last Streamline sync |
| streamline_reservation_id | text | | Streamline res ID |
| booking_sentiment | text | | Booking sentiment |
| management_commission_rate | numeric(6,3) | | Commission rate |
| management_commission_amount | numeric(12,2) | | Commission amount |
| owner_revenue_share_rate | numeric(6,3) | | Owner share rate |
| owner_revenue_share_amount | numeric(12,2) | | Owner share amount |
| damage_waiver | numeric(12,2) | | Damage waiver fee |
| booking_fee | numeric(12,2) | | Booking fee |
| cleaning_fee | numeric(12,2) | | Cleaning fee charged |
| cleaning_cost | numeric(12,2) | | Cleaning cost |
| processing_fee | numeric(12,2) | | Processing fee |
| airbnb_service_fee | numeric(12,2) | | Airbnb fee |
| vrbo_service_fee | numeric(12,2) | | VRBO fee |
| hometogo_fee | numeric(12,2) | | HomeToGo fee |
| direct_booking_fee | numeric(12,2) | | Direct booking fee |
| transient_accommodations_tax_amount | numeric(12,2) | | TAT |
| general_excise_tax_amount | numeric(12,2) | | GET |
| maui_transient_tax_amount | numeric(12,2) | | Maui transient tax |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 1.4 ops.resorts ✅ (~20 records)
*Resort/complex master with amenities and contacts*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| resort_id | text | NOT NULL, UNIQUE | Business ID: RST-{CODE}-NNNN |
| resort_code | text | | Short code (e.g., HK, MKV) |
| resort_name | text | | Full resort name |
| street_address | text | | Street address |
| city | text | | City |
| state | text | | State |
| postal_code | text | | ZIP code |
| country | text | | Country |
| front_desk_phone | text | | Front desk phone |
| front_desk_email | text | | Front desk email |
| housekeeping_contact_id | text | | Housekeeping contact |
| association_contact_id | text | | HOA contact |
| engineering_contact_id | text | | Engineering contact |
| security_contact_id | text | | Security contact |
| general_manager_contact_id | text | | GM contact |
| package_pickup_location | text | | Package pickup info |
| service_request_process | text | | Service request process |
| internet_info | text | | Internet details |
| internet_provider | text | | ISP |
| cable_provider | text | | Cable provider |
| pest_control_vendor | text | | Pest control vendor |
| guest_registration_required | boolean | | Registration required |
| guest_registration_process | text | | Registration process |
| resort_fee_description | text | | Fee description |
| resort_fee_daily_amount | numeric(12,2) | | Daily resort fee |
| resort_fee_reservation_amount | numeric(12,2) | | Per-stay resort fee |
| resort_fee_pay_due | text | | When fee is due |
| bills_through_pm | boolean | | Bills through PM |
| has_air_conditioning | boolean | | AC available |
| has_fitness_center | boolean | | Fitness center |
| has_tennis_courts | boolean | | Tennis courts |
| has_jacuzzi | boolean | | Jacuzzi |
| jacuzzi_details | text | | Jacuzzi info |
| has_pool | boolean | | Pool |
| pool_details | text | | Pool info |
| pool_hours | text | | Pool hours |
| has_day_spa | boolean | | Day spa |
| has_beach_access | boolean | | Beach access |
| has_bbq | boolean | | BBQ |
| has_designated_parking | boolean | | Designated parking |
| has_free_parking | boolean | | Free parking |
| provides_beach_towels | boolean | | Beach towels |
| provides_pool_towels | boolean | | Pool towels |
| has_outdoor_games | boolean | | Outdoor games |
| trash_notes | text | | Trash instructions |
| parking_details | text | | Parking details |
| construction_form_required | boolean | | Construction form |
| construction_advance_notice_required | boolean | | Advance notice |
| construction_restrictions | text | | Restrictions |
| insurance_required | boolean | | Insurance required |
| notes | text | | General notes |
| is_ai_visible | boolean | | AI visibility flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 1.5 ops.properties ✅ (Schema Only - Loading)
*Property master with 140+ columns*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| property_id | text | NOT NULL, UNIQUE | Business ID: PRP-{CODE}-NNNN |
| property_code_name | text | | Internal code name |
| legacy_name | text | | Legacy system name |
| property_short_name | text | | Short display name |
| full_property_name | text | | Full name |
| property_type | text | | Condo, house, etc. |
| bedrooms | numeric(4,1) | | Bedroom count |
| bathrooms | numeric(4,1) | | Bathroom count |
| view | text | | View type |
| resort_id | text | FK→resorts | Resort FK |
| area_id | text | FK→geo.areas | Geographic area FK |
| geom | geometry(Point) | | PostGIS point |
| tmk_number | text | | Tax map key |
| rental_permit_number | text | | Rental permit |
| latitude | numeric(10,7) | | Latitude |
| longitude | numeric(10,7) | | Longitude |
| square_feet | integer | | Square footage |
| street_number | text | | Street number |
| street_name | text | | Street name |
| unit_number | text | | Unit number |
| building_floor | text | | Floor |
| building | text | | Building name |
| street_address | text | | Full street address |
| street_address_2 | text | | Address line 2 |
| city | text | | City |
| state | text | | State |
| zip | text | | ZIP code |
| country | text | | Country |
| wifi_password | text | | WiFi password |
| wifi_network | text | | WiFi network name |
| wifi_speed | text | | WiFi speed |
| status | text | | Property status |
| clean_status | text | | Cleaning status |
| inspection_status | text | | Inspection status |
| homeowner | text | | Homeowner name |
| spend_approval_amount | numeric(12,2) | | Spend approval limit |
| has_replacement_approval | boolean | | Replacement approved |
| reviews | jsonb | | Review data |
| image_count | integer | | Image count |
| default_image_path | text | | Default image URL |
| thumbnail_path | text | | Thumbnail URL |
| floorplan_path | text | | Floorplan URL |
| property_video_path | text | | Video URL |
| property_photo_paths | jsonb | | Photo URLs |
| web_link | text | | Website link |
| web_name | text | | Website display name |
| web_ribbon | text | | Website ribbon text |
| description | text | | Full description |
| short_description | text | | Short description |
| seo_title | text | | SEO title |
| seo_description | text | | SEO description |
| seo_keywords | text | | SEO keywords |
| property_photos | jsonb | | Photo metadata |
| vrbo_id | text | | VRBO listing ID |
| vrbo_link | text | | VRBO URL |
| vrbo_description | text | | VRBO description |
| vrbo_headline | text | | VRBO headline |
| airbnb_id | text | | Airbnb listing ID |
| airbnb_link | text | | Airbnb URL |
| airbnb_headline | text | | Airbnb headline |
| airbnb_description | text | | Airbnb description |
| airbnb_guest_favorite | boolean | | Guest favorite badge |
| airbnb_guest_interactions | text | | Interaction notes |
| airbnb_arrival_guide | text | | Arrival guide |
| house_rules | text | | House rules |
| access_instructions | text | | Access instructions |
| has_beach_access | boolean | | Beach access |
| beach_items_detail | text | | Beach items info |
| closest_beach_id | text | FK→concierge.beaches | Nearest beach |
| has_parking | boolean | | Parking available |
| parking_cost | numeric(12,2) | | Parking cost |
| amenities | jsonb | | Amenity list |
| check_in_time | time | | Check-in time |
| check_out_time | time | | Check-out time |
| early_checkin_allowed | boolean | | Early check-in |
| late_checkout_allowed | boolean | | Late check-out |
| coupons_enabled | boolean | | Coupons enabled |
| discounts_enabled | boolean | | Discounts enabled |
| pricing_group | text | | Pricing group |
| pricing_base_rate | numeric(12,2) | | Base nightly rate |
| pricing_minimum_rate | numeric(12,2) | | Minimum rate |
| has_early_bird_discount | boolean | | Early bird discount |
| has_length_of_stay_discount | boolean | | LOS discount |
| has_last_minute_discount | boolean | | Last minute discount |
| max_occupancy | integer | | Max occupancy |
| minimum_nights | integer | | Minimum nights |
| projects | integer | | Active projects |
| last_audit_date | date | | Last audit |
| next_audit_date | date | | Next audit |
| trash_location | text | | Trash location |
| trash_instructions | text | | Trash instructions |
| trash_day | text | | Trash day |
| preferred_vendor | text | | Preferred vendor |
| preferred_vendor_types | text | | Vendor types |
| pest_control_schedule | text | | Pest schedule |
| pest_control_vendor | text | | Pest vendor |
| cleaning_fee | numeric(12,2) | | Cleaning fee |
| cleaning_cost | numeric(12,2) | | Cleaning cost |
| special_instructions | text | | Special instructions |
| owner_notes | text | | Owner notes |
| sales_notes | text | | Sales notes |
| onboarding_notes | text | | Onboarding notes |
| cleaning_notes | text | | Cleaning notes |
| pricing_notes | text | | Pricing notes |
| guest_notes | text | | Guest notes |
| maintenance_notes | text | | Maintenance notes |
| rooms | jsonb | | Room data (DEPRECATED→ops.rooms) |
| hoa_due_amount | numeric(12,2) | | HOA dues |
| last_purchase_price | numeric(14,2) | | Purchase price |
| last_sale_date | date | | Sale date |
| mortgage | text | | Mortgage info |
| insurance_provider | text | | Insurance provider |
| insurance_policy_number | text | | Policy number |
| payment_gateway | text | | Payment gateway |
| quickbooks_class | text | | QB class |
| general_excise_tax_id | text | | GE tax ID |
| general_excise_tax_letter_number | text | | GE letter # |
| transient_accommodations_tax_id | text | | TA tax ID |
| transient_accommodations_tax_letter_number | text | | TA letter # |
| property_tax_assessed_value | numeric(14,2) | | Assessed value |
| property_tax_annual_amount | numeric(14,2) | | Annual tax |
| tax_rate | numeric(7,4) | | Tax rate |
| payout_schedule | text | | Payout schedule |
| contract_start_date | date | | Contract start |
| contract_initial_period_end | date | | Initial period end |
| contract_renewal_terms | text | | Renewal terms |
| streamline_created_at | timestamptz | | SL created date |
| streamline_content_updated_at | timestamptz | | SL content update |
| streamline_price_updated_at | timestamptz | | SL price update |
| streamline_reservations_updated_at | timestamptz | | SL reservations update |
| streamline_status | text | | SL status |
| streamline_property_id | text | | SL property ID |
| streamline_resort_id | text | | SL resort ID |
| streamline_homeowner_id | text | | SL homeowner ID |
| streamline_property_group_id | text | | SL group ID |
| last_updated | timestamptz | | Last update |
| airtable_bases | jsonb | | Airtable links |
| monday_item_id | text | | Monday.com ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 1.6 ops.homeowners ✅ (Schema Only)
*Homeowner profiles with personality and preference data*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| homeowner_id | text | NOT NULL, UNIQUE | Business ID: HO-NNNNNN |
| contact_id | text | FK→contacts | Link to contacts |
| legal_name | text | | Legal entity name |
| external_homeowner_code | text | | External code |
| external_homeowner_id | text | | External ID |
| full_name | text | | Display name |
| preferred_name | text | | Preferred name |
| status | text | | Active status |
| account_created | timestamptz | | Account creation |
| last_updated | timestamptz | | Last update |
| business_entity | text | | Business entity type |
| language_preference | text | | Preferred language |
| communication_tone | text | | Tone preference |
| ai_personality_profile | text | | AI personality |
| engagement_level | text | | Engagement level |
| decision_involvement_style | text | | Decision style |
| spending_sensitivity | text | | Spending sensitivity |
| preferred_point_of_contact | text | | Preferred POC |
| control_style | text | | Control preference |
| trust_threshold_level | text | | Trust level |
| privacy_needs | text | | Privacy needs |
| legacy_alignment | text | | Legacy alignment |
| top_priority_focus | text | | Top priority |
| network_sensitivity | text | | Network sensitivity |
| sensitivity_to_maintenance_costs | text | | Maintenance sensitivity |
| avg_days_per_year | integer | | Days at property/year |
| avg_months_per_year | integer | | Months at property/year |
| uses_owner_portal | boolean | | Portal user |
| portal_familiarity_level | text | | Portal familiarity |
| ease_of_change | text | | Change tolerance |
| prior_pain_points | text | | Pain points |
| years_traveling_to_maui | integer | | Years visiting Maui |
| real_estate_interest_notes | text | | RE interest notes |
| preferred_agent_id | text | | Preferred agent |
| status_sensitivity | text | | Status sensitivity |
| reactivity_to_friction | text | | Friction reactivity |
| family_use_flag | boolean | | Family use |
| friends_or_other_use_flag | boolean | | Friends use |
| payment_terms | text | | Payment terms |
| preferred_payment_method | text | | Payment method |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 1.7 ops.homeowner_property_relationship ✅ (Schema Only)
*Many-to-many junction: homeowners ↔ properties*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| homeowner_id | text | FK→homeowners | Homeowner FK |
| property_id | text | FK→properties | Property FK |
| linked_property_ids | jsonb | | Related properties |
| ownership_type | text | | Ownership type |
| ownership_start_date | date | | Ownership start |
| management_start_date | date | | Management start |
| initial_commitment_end_date | date | | Commitment end |
| contract_renewal_date | date | | Renewal date |
| property_purchase_date | date | | Purchase date |
| previous_manager_name | text | | Previous manager |
| management_companies_number | integer | | # of prior managers |
| previous_management_company_id | text | | Previous company ID |
| property_management_notes | text | | Management notes |
| service_flags | jsonb | | Service flags |
| family_use_pattern_notes | text | | Family use notes |
| friends_use_pattern_notes | text | | Friends use notes |
| expansion_opportunity_score | integer | | Expansion score |
| selling_intent_flag | boolean | | Selling intent |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 1.8 ops.property_care_tickets ✅ (Schema Only - 646+ Monday rows)
*Property maintenance and care tickets (90+ columns)*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| ticket_id | text | UNIQUE | Business ID: TIK-PC-NNNNNN |
| ticket_code | text | | Ticket code |
| property_id | text | FK→properties | Property FK |
| reservation_id | text | FK→reservations | Related reservation |
| homeowner_id | text | FK→homeowners | Homeowner FK |
| requestor_contact_id | text | FK→contacts | Who reported |
| assigned_company_id | text | FK→companies | External vendor |
| primary_assignee_member_id | text | FK→team_directory | Internal assignee |
| shift_id | text | FK→team_shifts | Assigned shift |
| inspection_id | text | FK→inspections | Originating inspection |
| ticket_name | text | | Ticket title |
| ticket_created_at | timestamptz | | Creation timestamp |
| ticket_priority | text | | Priority level |
| ticket_status | text | | Current status |
| ticket_type | text | | Ticket type |
| ticket_category | text | | Category |
| backup_ticket_status | text | | Backup status |
| guest_comments | text | | Guest comments |
| internal_comments | text | | Internal notes |
| ticket_instructions | text | | Instructions |
| ticket_source | text | | Source |
| service_date | date | | Service date |
| resolved_by | text | | Resolver |
| address | text | | Property address |
| resort_id | text | | Resort ID |
| phone | text | | Contact phone |
| parts_cost_allocation | text | | Parts allocation |
| supplies_cost_allocation | text | | Supplies allocation |
| labor_cost_allocation | text | | Labor allocation |
| last_updated_at | timestamptz | | Last update |
| comments | text | | General comments |
| receipt_paths | jsonb | | Receipt URLs |
| ticket_photo_paths | jsonb | | Ticket photos |
| completion_photo_paths | jsonb | | Completion photos |
| labor_time | interval | | Labor time |
| labor_cost | numeric(12,2) | | Labor cost |
| backup_field_labor_time | interval | | Backup labor time |
| backup_labor_cost | numeric(12,2) | | Backup labor cost |
| work_order_number | text | | Work order # |
| supplies_cost | numeric(12,2) | | Supplies cost |
| parts_cost | numeric(12,2) | | Parts cost |
| work_completion_date | date | | Completion date |
| work_notes | text | | Work notes |
| vendor_category | text | | Vendor category |
| response_time | interval | | Response time |
| resolution_time | interval | | Resolution time |
| owner_comments | text | | Owner comments |
| owner_instructions | text | | Owner instructions |
| vendor_id | text | | Legacy vendor ID |
| vendor_type | text | | Vendor type |
| damage_claim_id | text | | Damage claim ID |
| accounting_status | text | | Accounting status |
| completion_timeline | text | | Timeline |
| inventory_action_id | text | | Inventory action |
| transaction_id | text | | Transaction ID |
| inventory_management | text | | Inventory mgmt |
| ticket_paused_at | timestamptz | | Paused timestamp |
| ticket_resumed_at | timestamptz | | Resumed timestamp |
| vendor_requested_at | timestamptz | | Vendor requested |
| vendor_scheduled_at | timestamptz | | Vendor scheduled |
| order_requested_at | timestamptz | | Order requested |
| ordered_at | timestamptz | | Ordered timestamp |
| order_date | date | | Order date |
| original_delivery_date | date | | Original delivery |
| delivered_date | date | | Delivered date |
| supplier_id | text | | Supplier ID |
| brand_id | text | | Brand ID |
| manufacturer_id | text | | Manufacturer ID |
| ordering_platform_id | text | | Platform ID |
| external_order_number | text | | External order # |
| shipping_carrier_tracking_number | text | | Tracking # |
| shipping_carrier_id | text | | Carrier ID |
| ticket_submission_id | text | | Submission ID |
| monday_item_id | text | | Monday.com ID |
| work_started_at | timestamptz | | Work started |
| labor_verification_requested_at | timestamptz | | Verification requested |
| count_of_service_dates_missed | integer | | Missed dates count |
| days_since_missed_service_date | integer | | Days since missed |
| count_of_labor_verification_requests | integer | | Verification count |
| missed_service_id | text | | Missed service ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 1.9 ops.reservation_tickets ✅ (Schema Only - 105+ Monday rows)
*Guest service request tickets*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| ticket_id | text | UNIQUE | Business ID: TIK-RSV-NNNNNN |
| ticket_code | text | | Ticket code |
| reservation_id | text | NOT NULL, FK→reservations | Reservation FK |
| property_id | text | FK→properties | Property FK |
| requestor_contact_id | text | FK→contacts | Who reported |
| ticket_name | text | | Ticket title |
| ticket_created_at | timestamptz | | Creation timestamp |
| ticket_priority | text | | Priority level |
| ticket_status | text | | Current status |
| ticket_type | text | | Ticket type |
| ticket_category | text | | Category |
| backup_ticket_status | text | | Backup status |
| guest_comments | text | | Guest comments |
| internal_comments | text | | Internal notes |
| ticket_instructions | text | | Instructions |
| ticket_source | text | | Source |
| due_at | timestamptz | | Due timestamp |
| resolved_by | text | | Resolver |
| resort_id | text | | Resort ID |
| phone | text | | Contact phone |
| cost_allocation | text | | Cost allocation |
| last_updated_at | timestamptz | | Last update |
| comments | text | | General comments |
| receipt_paths | jsonb | | Receipt URLs |
| ticket_photo_paths | jsonb | | Ticket photos |
| completion_photo_paths | jsonb | | Completion photos |
| labor_time | interval | | Labor time |
| labor_cost | numeric(12,2) | | Labor cost |
| work_order_number | text | | Work order # |
| supplies_cost | numeric(12,2) | | Supplies cost |
| parts_cost | numeric(12,2) | | Parts cost |
| work_completion_date | date | | Completion date |
| work_notes | text | | Work notes |
| vendor_category | text | | Vendor category |
| homeowner_id | text | FK→homeowners | Homeowner FK |
| response_time | interval | | Response time |
| resolution_time | interval | | Resolution time |
| owner_comments | text | | Owner comments |
| owner_instructions | text | | Owner instructions |
| vendor_id | text | | Vendor ID |
| vendor_type | text | | Vendor type |
| damage_claim_id | text | | Damage claim ID |
| accounting_status | text | | Accounting status |
| completion_timeline | text | | Timeline |
| inventory_action_id | text | | Inventory action |
| transaction_id | text | | Transaction ID |
| ticket_paused_at | timestamptz | | Paused timestamp |
| ticket_resumed_at | timestamptz | | Resumed timestamp |
| ticket_submission_id | text | | Submission ID |
| monday_item_id | text | | Monday.com ID |
| work_started_at | timestamptz | | Work started |
| labor_verification_requested_at | timestamptz | | Verification requested |
| count_of_due_dates_missed | integer | | Missed dates count |
| days_since_missed_due_date | integer | | Days since missed |
| count_of_labor_verification_requests | integer | | Verification count |
| missed_due_date_id | text | | Missed date ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

## 2. OPS Schema — To Build Tables

### 2.1 ops.companies 🔵 (Replaces ops.vendors)
*All third-party organizations: vendors, partners, activity operators*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| company_id | text | NOT NULL, UNIQUE | Business ID: CMP-{TYPE}-NNNNNN |
| company_name | text | NOT NULL | Company name |
| company_slug | text | UNIQUE | URL-safe slug |
| company_type | text | NOT NULL | maintenance, activity, restaurant, attraction, retail, homeowner_service, guest_service, aoao, other |
| primary_contact_id | text | FK→contacts | Main POC |
| billing_contact_id | text | FK→contacts | AP/invoicing contact |
| scheduling_contact_id | text | FK→contacts | Scheduling contact |
| technician_contact_id | text | FK→contacts | Field tech |
| geom | geometry(Point) | | PostGIS location |
| area_id | text | FK→geo.areas | Geographic area |
| is_payables_vendor | boolean | DEFAULT false | You pay them (AP) |
| is_experience_partner | boolean | DEFAULT false | Shows in itineraries |
| is_affiliate_partner | boolean | DEFAULT false | You earn commissions |
| accounting_vendor_id | text | | QB vendor ID |
| commission_rate | decimal(5,4) | | Commission rate |
| license_number | text | | License # |
| insurance_policy_number | text | | Insurance policy |
| insurance_expiration | date | | Insurance expiration |
| payment_terms | text | | Payment terms |
| status | text | | active, inactive, onboarding |
| notes | text | | General notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.2 ops.team_directory 🔵
*Unified team member master*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| member_id | text | NOT NULL, UNIQUE | Business ID: TM-NNNNNN |
| contact_id | text | FK→contacts | Link to contacts |
| name | text | NOT NULL | Full name |
| monday_id | text | | Monday.com ID |
| slack_id | text | | Slack user ID |
| proservice_id | text | | ProService ID |
| status | text | | Active, Inactive, etc. |
| team | text | | Team name |
| team_id | text | FK→teams | Team FK |
| team_roles | text | | Role(s) |
| manager_id | text | FK→team_directory | Manager FK |
| work_email | text | | Work email |
| phone | text | | Phone |
| employment_type | text | | W2, 1099, etc. |
| compensation_type | text | | Hourly, salary |
| hourly_rate | decimal(8,2) | | Hourly rate |
| geom | geometry(Point) | | Current location |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.3 ops.teams 🔵
*Team definitions*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| team_id | text | NOT NULL, UNIQUE | Business ID: TEAM-NNNN |
| team_name | text | NOT NULL | Team name |
| team_lead_id | text | FK→team_directory | Team lead |
| status | text | | active, inactive |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.4 ops.team_shifts 🔵
*Shift tracking for availability/routing*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| shift_id | text | NOT NULL, UNIQUE | Business ID: SFT-NNNNNN |
| member_id | text | FK→team_directory | Team member |
| shift_date | date | NOT NULL | Shift date |
| shift_start_at | timestamptz | | Start time |
| shift_end_at | timestamptz | | End time |
| shift_type | text | | Regular, overtime, etc. |
| status | text | | scheduled, in_progress, completed |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.5 ops.admin_tickets 🔵 (62+ Monday rows)
*Administrative task tickets*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| ticket_id | text | NOT NULL, UNIQUE | Business ID: TIK-ADM-NNNNNN |
| property_id | text | FK→properties | Property FK |
| reservation_id | text | FK→reservations | Reservation FK |
| requestor_contact_id | text | FK→contacts | Who reported |
| linked_ticket_ids | jsonb | | Related tickets |
| ticket_name | text | | Ticket title |
| ticket_status | text | | Status |
| ticket_priority | text | | Priority |
| ticket_type | text | | Type |
| ticket_category | text | | Category |
| due_at | timestamptz | | Due date |
| assigned_to_member_id | text | FK→team_directory | Assignee |
| comments | text | | Comments |
| monday_item_id | text | | Monday.com ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.6 ops.accounting_tickets 🔵 (22+ Monday rows)
*Financial/accounting task tickets*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| ticket_id | text | NOT NULL, UNIQUE | Business ID: TIK-ACC-NNNNNN |
| homeowner_id | text | FK→homeowners | Homeowner FK |
| property_id | text | FK→properties | Property FK |
| requestor_contact_id | text | FK→contacts | Who reported |
| related_ticket_id | text | FK→property_care_tickets | Related ticket |
| ticket_name | text | | Ticket title |
| ticket_status | text | | Status |
| ticket_priority | text | | Priority |
| ticket_type | text | | Type |
| amount | decimal(12,2) | | Amount |
| due_at | timestamptz | | Due date |
| assigned_to_member_id | text | FK→team_directory | Assignee |
| comments | text | | Comments |
| monday_item_id | text | | Monday.com ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.7 ops.ai_agents 🔵
*AI agents as contact type for communications*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| agent_id | text | NOT NULL, UNIQUE | Business ID: AI-NNNN |
| agent_name | text | NOT NULL | Agent name |
| agent_type | text | | Chatbot, assistant, etc. |
| status | text | | active, inactive |
| capabilities | jsonb | | Agent capabilities |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.8 ops.rooms 🔵
*Room inventory per property*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| room_id | text | NOT NULL, UNIQUE | Business ID: RM-{PROP}-NNN |
| property_id | text | FK→properties | Property FK |
| room_name | text | NOT NULL | Room name |
| room_type | text | | bedroom, bathroom, kitchen, living, lanai, etc. |
| floor | text | | Floor level |
| square_feet | integer | | Room size |
| status | text | | active, inactive |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.9 ops.beds 🔵
*Bed inventory per room*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| bed_id | text | NOT NULL, UNIQUE | Business ID: BED-NNNNNN |
| room_id | text | FK→rooms | Room FK |
| bed_type | text | | king, queen, twin, sofa_bed, etc. |
| bed_size | text | | Size details |
| brand | text | | Brand |
| model | text | | Model |
| purchase_date | date | | Purchase date |
| warranty_expiration | date | | Warranty end |
| status | text | | active, damaged, retired |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.10 ops.appliances 🔵
*Appliance inventory per room*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| appliance_id | text | NOT NULL, UNIQUE | Business ID: APL-NNNNNN |
| room_id | text | FK→rooms | Room FK |
| appliance_type | text | | refrigerator, dishwasher, microwave, etc. |
| brand | text | | Brand |
| model | text | | Model |
| serial_number | text | | Serial # |
| purchase_date | date | | Purchase date |
| warranty_expiration | date | | Warranty end |
| last_service_date | date | | Last service |
| next_service_date | date | | Next service |
| status | text | | active, inactive, damaged |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.11 ops.appliance_parts 🔵
*Parts inventory for appliances*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| part_id | text | NOT NULL, UNIQUE | Business ID: PRT-NNNNNN |
| appliance_id | text | FK→appliances | Appliance FK |
| part_name | text | | Part name |
| part_number | text | | Manufacturer part # |
| brand | text | | Brand |
| purchase_date | date | | Purchase date |
| warranty_expiration | date | | Warranty end |
| status | text | | installed, spare, replaced |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.12 ops.fixtures 🔵
*Bathroom/kitchen fixtures per room*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| fixture_id | text | NOT NULL, UNIQUE | Business ID: FIX-NNNNNN |
| room_id | text | FK→rooms | Room FK |
| fixture_type | text | | sink, toilet, shower, tub, faucet, etc. |
| brand | text | | Brand |
| model | text | | Model |
| status | text | | active, inactive, damaged |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.13 ops.surfaces 🔵
*Flooring and countertops per room*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| surface_id | text | NOT NULL, UNIQUE | Business ID: SRF-NNNNNN |
| room_id | text | FK→rooms | Room FK |
| surface_type | text | | flooring, countertop, backsplash, etc. |
| material | text | | tile, hardwood, granite, etc. |
| brand | text | | Brand |
| install_date | date | | Installation date |
| status | text | | active, damaged |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.14 ops.lighting 🔵
*Light fixtures per room*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| lighting_id | text | NOT NULL, UNIQUE | Business ID: LGT-NNNNNN |
| room_id | text | FK→rooms | Room FK |
| lighting_type | text | | ceiling, lamp, sconce, etc. |
| is_smart | boolean | | Smart bulb/switch |
| brand | text | | Brand |
| status | text | | active, inactive |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.15 ops.window_coverings 🔵
*Blinds, drapes per room*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| covering_id | text | NOT NULL, UNIQUE | Business ID: WCV-NNNNNN |
| room_id | text | FK→rooms | Room FK |
| covering_type | text | | blinds, drapes, shutters, etc. |
| brand | text | | Brand |
| install_date | date | | Installation date |
| status | text | | active, damaged |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.16 ops.room_features 🔵
*Special features per room*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| feature_id | text | NOT NULL, UNIQUE | Business ID: RFT-NNNNNN |
| room_id | text | FK→rooms | Room FK |
| feature_type | text | | fireplace, ocean_view, balcony, etc. |
| description | text | | Description |
| is_ai_visible | boolean | | Include in AI descriptions |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.17 ops.ac_systems 🔵
*HVAC systems per property*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| system_id | text | NOT NULL, UNIQUE | Business ID: ACS-NNNNNN |
| property_id | text | FK→properties | Property FK |
| system_type | text | | central, split, window, etc. |
| brand | text | | Brand |
| model | text | | Model |
| serial_number | text | | Serial # |
| install_date | date | | Installation date |
| warranty_expiration | date | | Warranty end |
| last_service_date | date | | Last service |
| next_service_date | date | | Next service |
| status | text | | active, maintenance_hold |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.18 ops.ac_units 🔵
*Individual AC units per system*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| unit_id | text | NOT NULL, UNIQUE | Business ID: ACU-NNNNNN |
| system_id | text | FK→ac_systems | AC system FK |
| room_id | text | FK→rooms | Room served |
| unit_type | text | | indoor, outdoor, etc. |
| brand | text | | Brand |
| model | text | | Model |
| serial_number | text | | Serial # |
| filter_size | text | | Filter size |
| last_filter_change | date | | Last filter change |
| status | text | | active, inactive, maintenance_hold |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.19 ops.property_doors 🔵
*Door inventory per property*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| door_id | text | NOT NULL, UNIQUE | Business ID: DR-NNNNNN |
| property_id | text | FK→properties | Property FK |
| room_id | text | FK→rooms | Room FK (where door leads) |
| door_type | text | | entry, interior, sliding, etc. |
| door_location | text | | Location description |
| has_lock | boolean | | Lock present |
| status | text | | active, damaged |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.20 ops.property_locks 🔵
*Lock inventory per door*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| lock_id | text | NOT NULL, UNIQUE | Business ID: LCK-NNNNNN |
| door_id | text | FK→property_doors | Door FK |
| lock_type | text | | deadbolt, smart, keypad, etc. |
| brand | text | | Brand |
| model | text | | Model |
| serial_number | text | | Serial # |
| code | text | | Current code |
| install_date | date | | Installation date |
| battery_last_replaced | date | | Battery replaced |
| status | text | | active, inactive, damaged |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.21 ops.key_checkouts 🔵
*Key checkout tracking*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| checkout_id | text | NOT NULL, UNIQUE | Business ID: KEY-NNNNNN |
| lock_id | text | FK→property_locks | Lock FK |
| checked_out_to_contact_id | text | FK→contacts | Who has key |
| checked_out_at | timestamptz | | Checkout time |
| expected_return_at | timestamptz | | Expected return |
| returned_at | timestamptz | | Actual return |
| status | text | | checked_out, returned, lost |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.22 ops.cleans 🔵 (~4,000+ Monday rows)
*Cleaning records*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| clean_id | text | NOT NULL, UNIQUE | Business ID: CLN-NNNNNN |
| property_id | text | FK→properties | Property FK |
| checkout_reservation_id | text | FK→reservations | Departing guest pays |
| checkin_reservation_id | text | FK→reservations | Arriving guest benefits |
| performed_by_member_id | text | FK→team_directory | Cleaner |
| scheduled_date | date | | Scheduled date |
| scheduled_time | time | | Scheduled time |
| actual_start_time | timestamptz | | Actual start |
| actual_end_time | timestamptz | | Actual end |
| status | text | | scheduled, in_progress, completed |
| clean_type | text | | turnover, deep, touch_up, etc. |
| notes | text | | Notes |
| inspection_id | text | FK→inspections | Related inspection |
| monday_item_id | text | | Monday.com ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.23 ops.inspections 🔵
*Pre-arrival and periodic inspections*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| inspection_id | text | NOT NULL, UNIQUE | Business ID: INS-NNNNNN |
| property_id | text | FK→properties | Property FK |
| clean_id | text | FK→cleans | Related clean |
| checkin_reservation_id | text | FK→reservations | Incoming guest |
| performed_by_member_id | text | FK→team_directory | Inspector |
| inspection_type | text | | pre_arrival, periodic, post_stay |
| scheduled_date | date | | Scheduled date |
| scheduled_time | time | | Scheduled time |
| actual_time | timestamptz | | Actual time |
| status | text | | scheduled, in_progress, inspected, failed |
| passed | boolean | | Pass/fail |
| notes | text | | Notes |
| photo_paths | jsonb | | Inspection photos |
| monday_item_id | text | | Monday.com ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.24 ops.inspection_questions 🔵
*Question bank for inspections*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| question_id | text | NOT NULL, UNIQUE | Business ID: IQ-NNNNNN |
| question_text | text | NOT NULL | Question text |
| category | text | | cleanliness, safety, amenities, etc. |
| is_required | boolean | DEFAULT true | Required flag |
| sort_order | integer | | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.25 ops.inspection_room_questions 🔵
*Room-specific inspection items*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| room_question_id | text | NOT NULL, UNIQUE | Business ID |
| inspection_id | text | FK→inspections | Inspection FK |
| room_id | text | FK→rooms | Room FK |
| question_id | text | FK→inspection_questions | Question FK |
| answer | text | | Answer |
| passed | boolean | | Pass/fail |
| notes | text | | Notes |
| photo_path | text | | Photo URL |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.26 ops.reviews 🔵
*Guest reviews with cleaner accountability*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| review_id | text | NOT NULL, UNIQUE | Business ID: REV-NNNNNN |
| reservation_id | text | FK→reservations | Reservation FK |
| property_id | text | FK→properties | Property FK |
| guest_id | text | FK→guests | Guest FK |
| clean_id | text | FK→cleans | Clean for accountability |
| platform | text | | airbnb, vrbo, direct, google |
| overall_rating | decimal(3,2) | | Overall score |
| cleanliness_rating | decimal(3,2) | | Cleanliness score |
| communication_rating | decimal(3,2) | | Communication score |
| accuracy_rating | decimal(3,2) | | Accuracy score |
| checkin_rating | decimal(3,2) | | Check-in score |
| location_rating | decimal(3,2) | | Location score |
| value_rating | decimal(3,2) | | Value score |
| review_text | text | | Review content |
| response_text | text | | Our response |
| review_date | date | | Review date |
| status | text | | received, pending_approval, approved |
| monday_item_id | text | | Monday.com ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.27 ops.storage_locations 🔵
*Warehouse zones/shelves*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| location_id | text | NOT NULL, UNIQUE | Business ID: LOC-NNNNNN |
| location_name | text | NOT NULL | Location name |
| location_type | text | | warehouse, shelf, bin, etc. |
| parent_location_id | text | FK→storage_locations | Parent location |
| address | text | | Physical address |
| status | text | | active, inactive |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.28 ops.inventory_items 🔵
*Central inventory master*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| item_id | text | NOT NULL, UNIQUE | Business ID: INV-NNNNNN |
| item_name | text | NOT NULL | Item name |
| item_category | text | | Category |
| sku | text | | SKU |
| brand | text | | Brand |
| supplier_company_id | text | FK→companies | Primary supplier |
| unit_of_measure | text | | each, box, case, etc. |
| unit_cost | decimal(12,2) | | Unit cost |
| reorder_point | integer | | Min stock level |
| reorder_quantity | integer | | Reorder qty |
| status | text | | active, discontinued |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.29 ops.inventory_stock 🔵
*Stock levels by location*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| stock_id | text | NOT NULL, UNIQUE | Business ID |
| item_id | text | FK→inventory_items | Item FK |
| location_id | text | FK→storage_locations | Location FK |
| quantity_on_hand | integer | | Current qty |
| quantity_allocated | integer | | Reserved qty |
| last_count_date | date | | Last count |
| status | text | | in_stock, low_stock, out_of_stock |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.30 ops.inventory_events 🔵
*Inventory movement tracking*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| event_id | text | NOT NULL, UNIQUE | Business ID |
| item_id | text | FK→inventory_items | Item FK |
| from_location_id | text | FK→storage_locations | From location |
| to_location_id | text | FK→storage_locations | To location |
| property_id | text | FK→properties | Property if deployed |
| event_type | text | | receive, transfer, deploy, adjust, count |
| quantity | integer | | Quantity |
| performed_by_member_id | text | FK→team_directory | Who performed |
| notes | text | | Notes |
| event_at | timestamptz | DEFAULT now() | Event time |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 2.31 ops.linen_items 🔵
*Linen master*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| linen_item_id | text | NOT NULL, UNIQUE | Business ID: LIN-NNNNNN |
| linen_type | text | | sheet, towel, pillowcase, etc. |
| size | text | | Size |
| color | text | | Color |
| brand | text | | Brand |
| supplier_company_id | text | FK→companies | Supplier |
| unit_cost | decimal(12,2) | | Unit cost |
| status | text | | active, damaged, retired |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.32 ops.linen_lots 🔵
*Batch tracking for linens*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| lot_id | text | NOT NULL, UNIQUE | Business ID: LOT-NNNNNN |
| linen_item_id | text | FK→linen_items | Linen type |
| quantity | integer | | Batch qty |
| purchase_date | date | | Purchase date |
| purchase_order_id | text | FK→purchase_orders | PO FK |
| status | text | | active, retired |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.33 ops.linen_movements 🔵
*Linen movement tracking*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| movement_id | text | NOT NULL, UNIQUE | Business ID |
| lot_id | text | FK→linen_lots | Lot FK |
| property_id | text | FK→properties | Property FK |
| event_type | text | | deploy, return, wash, retire |
| quantity | integer | | Quantity |
| performed_by_member_id | text | FK→team_directory | Who performed |
| movement_at | timestamptz | DEFAULT now() | Movement time |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 2.34 ops.guest_supplies 🔵
*Guest amenities master*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| supply_id | text | NOT NULL, UNIQUE | Business ID: GS-NNNNNN |
| supply_name | text | NOT NULL | Supply name |
| supply_category | text | | toiletry, kitchen, etc. |
| brand | text | | Brand |
| supplier_company_id | text | FK→companies | Supplier |
| unit_cost | decimal(12,2) | | Unit cost |
| par_level | integer | | Standard qty per property |
| is_consumable | boolean | | Consumable flag |
| status | text | | active, discontinued |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.35 ops.guest_supply_usage 🔵
*Guest supply consumption tracking*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| usage_id | text | NOT NULL, UNIQUE | Business ID |
| supply_id | text | FK→guest_supplies | Supply FK |
| property_id | text | FK→properties | Property FK |
| reservation_id | text | FK→reservations | Reservation FK |
| quantity_used | integer | | Quantity |
| stocked_by_member_id | text | FK→team_directory | Who stocked |
| usage_date | date | | Usage date |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 2.36 ops.purchase_orders 🔵
*Purchase order header*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| po_id | text | NOT NULL, UNIQUE | Business ID: PO-NNNNNN |
| company_id | text | FK→companies | Vendor FK |
| ticket_id | text | FK→property_care_tickets | Originating ticket |
| ordered_by_member_id | text | FK→team_directory | Who ordered |
| order_date | date | | Order date |
| expected_delivery_date | date | | Expected delivery |
| actual_delivery_date | date | | Actual delivery |
| total_amount | decimal(12,2) | | Total amount |
| status | text | | draft, submitted, approved, ordered, received |
| shipping_address | text | | Ship to |
| notes | text | | Notes |
| monday_item_id | text | | Monday.com ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.37 ops.po_items 🔵
*Purchase order line items*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| po_item_id | text | NOT NULL, UNIQUE | Business ID |
| po_id | text | FK→purchase_orders | PO FK |
| inventory_item_id | text | FK→inventory_items | For inventory |
| linen_item_id | text | FK→linen_items | For linen |
| guest_supply_id | text | FK→guest_supplies | For guest supply |
| description | text | | Item description |
| quantity | integer | | Quantity |
| unit_cost | decimal(12,2) | | Unit cost |
| line_total | decimal(12,2) | | Line total |
| received_quantity | integer | | Qty received |
| status | text | | ordered, partial, received |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.38 ops.receipts 🔵
*General operational receipts*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| receipt_id | text | NOT NULL, UNIQUE | Business ID: RCT-NNNNNN |
| submitted_by_member_id | text | FK→team_directory | Who submitted |
| po_item_id | text | FK→po_items | Optional PO link |
| property_id | text | FK→properties | Property if applicable |
| ticket_id | text | FK→property_care_tickets | Related ticket |
| vendor_name | text | | Vendor name |
| receipt_date | date | | Receipt date |
| amount | decimal(12,2) | | Amount |
| receipt_type | text | | gas, meals, supplies, etc. |
| description | text | | Description |
| image_path | text | | Receipt image URL |
| status | text | | submitted, approved, paid, void |
| accounting_status | text | | Accounting status |
| notes | text | | Notes |
| monday_item_id | text | | Monday.com ID |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.39 ops.purchases 🔵
*Purchase tracking*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| purchase_id | text | NOT NULL, UNIQUE | Business ID: PUR-NNNNNN |
| po_id | text | FK→purchase_orders | PO FK |
| company_id | text | FK→companies | Vendor FK |
| property_id | text | FK→properties | Property FK |
| purchase_date | date | | Purchase date |
| amount | decimal(12,2) | | Amount |
| status | text | | Status |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.40 ops.cost_history 🔵
*Cost tracking over time*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| cost_id | text | NOT NULL, UNIQUE | Business ID |
| entity_type | text | | inventory, linen, guest_supply |
| entity_id | text | | Entity FK |
| cost | decimal(12,2) | | Cost |
| effective_date | date | | Effective date |
| supplier_company_id | text | FK→companies | Supplier |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 2.41 ops.transactions 🔵
*Financial transactions*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| transaction_id | text | NOT NULL, UNIQUE | Business ID: TXN-NNNNNN |
| property_id | text | FK→properties | Property FK |
| reservation_id | text | FK→reservations | Reservation FK |
| homeowner_id | text | FK→homeowners | Homeowner FK |
| transaction_type | text | | revenue, expense, payout, etc. |
| amount | decimal(12,2) | | Amount |
| transaction_date | date | | Date |
| description | text | | Description |
| quickbooks_id | text | | QB ID |
| status | text | | Status |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.42 ops.payroll 🔵
*Payroll records*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| payroll_id | text | NOT NULL, UNIQUE | Business ID: PAY-NNNNNN |
| member_id | text | FK→team_directory | Team member |
| pay_period_start | date | | Period start |
| pay_period_end | date | | Period end |
| hours_worked | decimal(8,2) | | Hours |
| gross_pay | decimal(12,2) | | Gross pay |
| net_pay | decimal(12,2) | | Net pay |
| status | text | | draft, submitted, approved, paid |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.43 ops.financial_reports 🔵
*Generated financial reports*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| report_id | text | NOT NULL, UNIQUE | Business ID: FRR-NNNNNN |
| report_type | text | | owner_statement, P&L, etc. |
| property_id | text | FK→properties | Property FK |
| homeowner_id | text | FK→homeowners | Homeowner FK |
| period_start | date | | Period start |
| period_end | date | | Period end |
| generated_at | timestamptz | | Generation time |
| report_data | jsonb | | Report data |
| file_path | text | | PDF path |
| status | text | | draft, final, sent |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.44 ops.communication_threads 🔵
*Message thread master*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| thread_id | text | NOT NULL, UNIQUE | Business ID: THR-NNNNNN |
| thread_type | text | | guest, homeowner, team, vendor |
| entity_type | text | | reservation, property, homeowner, ticket |
| entity_id | text | | FK to entity |
| subject | text | | Thread subject |
| status | text | | open, closed, archived |
| created_at | timestamptz | DEFAULT now() | Record creation |
| last_message_at | timestamptz | | Last message time |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 2.45 ops.communication_messages 🔵
*Individual messages*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| message_id | text | NOT NULL, UNIQUE | Business ID: MSG-NNNNNN |
| thread_id | text | FK→communication_threads | Thread FK |
| sender_contact_id | text | FK→contacts | Sender |
| sender_ai_agent_id | text | FK→ai_agents | AI sender |
| message_body | text | | Message content |
| channel | text | | email, sms, slack, etc. |
| direction | text | | inbound, outbound |
| sent_at | timestamptz | | Send time |
| delivered_at | timestamptz | | Delivery time |
| read_at | timestamptz | | Read time |
| status | text | | sent, delivered, read, failed |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 2.46 ops.calls_log 🔵
*RingCentral call log*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| call_id | text | NOT NULL, UNIQUE | Business ID: CALL-NNNNNN |
| contact_id | text | FK→contacts | Contact FK |
| thread_id | text | FK→communication_threads | Thread FK |
| direction | text | | inbound, outbound |
| from_number | text | | From phone |
| to_number | text | | To phone |
| call_start_at | timestamptz | | Call start |
| call_end_at | timestamptz | | Call end |
| duration_seconds | integer | | Duration |
| recording_url | text | | Recording URL |
| transcript | text | | Transcription |
| ringcentral_id | text | | RC call ID |
| status | text | | completed, missed, voicemail |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

## 3. REF Schema — Reference/Lookup Tables

### 3.1 ref.activity_levels 🔵
*Activity level options for guest profiles*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| database_id | uuid | DEFAULT gen_random_uuid() | UUID |
| activity_level_id | text | NOT NULL, UNIQUE | Business ID: ACT-{CODE}-NNN |
| activity_code | text | NOT NULL, UNIQUE | 4-char code (VACT, ACTV, SEMI, RELX, LMTD) |
| activity_name | text | NOT NULL | Display name |
| description | text | | Description |
| sort_order | integer | | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 3.2 ref.limitation_types 🔵
*Physical/mobility limitation types*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| database_id | uuid | DEFAULT gen_random_uuid() | UUID |
| limitation_type_id | text | NOT NULL, UNIQUE | Business ID: LIM-{CODE}-NNN |
| limitation_code | text | NOT NULL, UNIQUE | 4-char code (WCHR, WLKR, STRS, etc.) |
| limitation_name | text | NOT NULL | Display name |
| description | text | | Description |
| affects_mobility | boolean | DEFAULT false | Mobility impact flag |
| sort_order | integer | | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 3.3 ref.interest_categories 🔵
*Interest category groupings*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| database_id | uuid | DEFAULT gen_random_uuid() | UUID |
| category_id | text | NOT NULL, UNIQUE | Business ID: ICAT-{CODE}-NNN |
| category_code | text | NOT NULL, UNIQUE | 4-char code (WATR, OUTD, GOLF, FOOD, etc.) |
| category_name | text | NOT NULL | Display name |
| description | text | | Description |
| sort_order | integer | | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 3.4 ref.interest_types 🔵 (75+ specific activities)
*Specific interest/activity types*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| database_id | uuid | DEFAULT gen_random_uuid() | UUID |
| interest_type_id | text | NOT NULL, UNIQUE | Business ID: INT-{CODE}-NNN |
| interest_code | text | NOT NULL, UNIQUE | 4-char code (SNRK, SCBA, SURF, HKEZ, etc.) |
| interest_name | text | NOT NULL | Display name |
| category_id | text | FK→interest_categories | Category FK |
| description | text | | Description |
| activity_level_id | text | FK→activity_levels | Typical activity level |
| sort_order | integer | | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 3.5 ref.schedule_density_levels 🔵
*Schedule density preferences*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| database_id | uuid | DEFAULT gen_random_uuid() | UUID |
| density_level_id | text | NOT NULL, UNIQUE | Business ID: DEN-{CODE}-NNN |
| density_code | text | NOT NULL, UNIQUE | 4-char code (PACK, FULL, MODR, LEIS, MINL) |
| density_name | text | NOT NULL | Display name |
| activities_per_day_min | integer | | Min activities/day |
| activities_per_day_max | integer | | Max activities/day |
| description | text | | Description |
| sort_order | integer | | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 3.6 ref.driving_tolerance_levels 🔵
*Driving distance tolerance*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| database_id | uuid | DEFAULT gen_random_uuid() | UUID |
| tolerance_level_id | text | NOT NULL, UNIQUE | Business ID: DRV-{CODE}-NNN |
| tolerance_code | text | NOT NULL, UNIQUE | 4-char code (LOCL, NEAR, MODR, ROAD, ANYW) |
| tolerance_name | text | NOT NULL | Display name |
| max_drive_minutes | integer | | Max drive time |
| description | text | | Description |
| sort_order | integer | | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 3.7 ref.budget_levels 🔵
*Daily budget ranges*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| database_id | uuid | DEFAULT gen_random_uuid() | UUID |
| budget_level_id | text | NOT NULL, UNIQUE | Business ID: BUD-{CODE}-NNN |
| budget_code | text | NOT NULL, UNIQUE | 4-char code (BUDG, MODR, PREM, LUXR, ULTR) |
| budget_name | text | NOT NULL | Display name |
| daily_range_min | decimal(12,2) | | Min daily spend |
| daily_range_max | decimal(12,2) | | Max daily spend |
| description | text | | Description |
| sort_order | integer | | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 3.8 ref.status_master 🔵
*Master status definitions*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| status_name | text | NOT NULL | Status name |
| status_display | text | | Display name |
| status_color | text | | UI color |
| status_icon | text | | UI icon |
| description | text | | Description |
| is_terminal | boolean | DEFAULT false | Terminal state |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 3.9 ref.status_applies_to 🔵
*Status-to-table mappings*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| status_name | text | FK→status_master | Status FK |
| table_name | text | NOT NULL | Table name |
| status_column | text | NOT NULL | Column name |
| is_default | boolean | DEFAULT false | Default status |
| sort_order | integer | | Display order |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 3.10 ref.status_transitions 🔵
*Valid status workflow transitions*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigserial | PK | Internal numeric ID |
| table_name | text | NOT NULL | Table name |
| from_status | text | FK→status_master | From status |
| to_status | text | FK→status_master | To status |
| requires_approval | boolean | DEFAULT false | Approval required |
| trigger_action | text | | Action to trigger |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

## 4. GEO Schema — Spatial/Geographic Tables

### 4.1 geo.zones 🔵
*Top-level geographic zones*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| zone_id | text | NOT NULL, UNIQUE | Business ID: ZN-{CODE}-NNN |
| zone_code | text | NOT NULL, UNIQUE | Short code (WEST, SOUTH, CENTRAL, etc.) |
| zone_name | text | NOT NULL | Zone name |
| zone_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(MultiPolygon, 4326) | | Zone boundary |
| bbox | geometry(Polygon, 4326) | | Bounding box |
| centroid | geometry(Point, 4326) | | Centroid |
| area_m2 | numeric | | Area in sq meters |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 4.2 geo.cities 🔵
*Cities within zones*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| city_id | text | NOT NULL, UNIQUE | Business ID: CTY-{CODE}-NNN |
| zone_id | text | FK→geo.zones | Zone FK |
| city_code | text | NOT NULL, UNIQUE | Short code |
| city_name | text | NOT NULL | City name |
| city_slug | text | UNIQUE | URL-safe slug |
| postal_codes | text[] | | ZIP codes in city |
| geom | geometry(MultiPolygon, 4326) | | City boundary |
| bbox | geometry(Polygon, 4326) | | Bounding box |
| centroid | geometry(Point, 4326) | | Centroid |
| area_m2 | numeric | | Area |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 4.3 geo.areas 🔵
*Neighborhood/area level*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| area_id | text | NOT NULL, UNIQUE | Business ID: AREA-{CODE}-NNN |
| city_id | text | FK→geo.cities | City FK |
| area_code | text | NOT NULL, UNIQUE | Short code |
| area_name | text | NOT NULL | Area name |
| area_slug | text | UNIQUE | URL-safe slug |
| area_type | text | | beach, town, resort, etc. |
| vibe_tags | text[] | | Vibe descriptors |
| geom | geometry(MultiPolygon, 4326) | | Area boundary |
| bbox | geometry(Polygon, 4326) | | Bounding box |
| centroid | geometry(Point, 4326) | | Centroid |
| area_m2 | numeric | | Area |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

## 5. CONCIERGE Schema — Guest Experience Tables

### 5.1 concierge.beaches 🔵
*Beach locations*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| beach_id | text | NOT NULL, UNIQUE | Business ID: BCH-NNNNNN |
| area_id | text | FK→geo.areas | Area FK |
| beach_name | text | NOT NULL | Beach name |
| beach_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(Point, 4326) | | Location point |
| description | text | | Description |
| beach_type | text | | sandy, rocky, cove, etc. |
| snorkeling_quality | text | | Snorkeling rating |
| swimming_safety | text | | Swimming safety |
| crowd_level | text | | Typical crowd level |
| facilities | text[] | | Restrooms, showers, etc. |
| parking_available | boolean | | Parking flag |
| lifeguard_present | boolean | | Lifeguard flag |
| vibe_tags | text[] | | Vibe descriptors |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.2 concierge.hikes 🔵
*Hiking trails*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| hike_id | text | NOT NULL, UNIQUE | Business ID: HIK-NNNNNN |
| area_id | text | FK→geo.areas | Area FK |
| hike_name | text | NOT NULL | Hike name |
| hike_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(Point, 4326) | | Trailhead point |
| description | text | | Description |
| difficulty | text | | easy, moderate, difficult |
| distance_miles | decimal(4,1) | | Distance |
| duration_hours | decimal(3,1) | | Duration |
| elevation_gain_ft | integer | | Elevation gain |
| trail_type | text | | out_and_back, loop, etc. |
| features | text[] | | Waterfall, views, etc. |
| vibe_tags | text[] | | Vibe descriptors |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.3 concierge.activities 🔵
*Bookable activities (company-operated)*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| activity_id | text | NOT NULL, UNIQUE | Business ID: ACT-NNNNNN |
| area_id | text | FK→geo.areas | Area FK |
| company_id | text | FK→ops.companies | Operator FK |
| activity_name | text | NOT NULL | Activity name |
| activity_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(Point, 4326) | | Location point |
| description | text | | Description |
| activity_type | text | | snorkel_tour, helicopter, etc. |
| duration_hours | decimal(3,1) | | Duration |
| price_range | text | | $, $$, $$$, $$$$ |
| price_min | decimal(12,2) | | Min price |
| price_max | decimal(12,2) | | Max price |
| booking_url | text | | Booking link |
| commission_rate | decimal(5,4) | | Affiliate commission |
| vibe_tags | text[] | | Vibe descriptors |
| activity_level_id | text | FK→ref.activity_levels | Activity level |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.4 concierge.restaurants 🔵
*Restaurant locations*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| restaurant_id | text | NOT NULL, UNIQUE | Business ID: RST-NNNNNN |
| area_id | text | FK→geo.areas | Area FK |
| company_id | text | FK→ops.companies | Partner FK |
| shopping_location_id | text | FK→shopping_locations | If in shopping center |
| resort_id | text | FK→ops.resorts | If at resort |
| restaurant_name | text | NOT NULL | Restaurant name |
| restaurant_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(Point, 4326) | | Location point |
| description | text | | Description |
| cuisine_types | text[] | | Cuisine types |
| price_level | text | | $, $$, $$$, $$$$ |
| reservation_required | boolean | | Reservation needed |
| reservation_url | text | | Booking link |
| dress_code | text | | Dress code |
| has_happy_hour | boolean | | Happy hour flag |
| has_ocean_view | boolean | | Ocean view flag |
| is_partner | boolean | DEFAULT false | Partner discount |
| discount_percentage | decimal(5,2) | | Discount % |
| vibe_tags | text[] | | Vibe descriptors |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.5 concierge.attractions 🔵
*Tourist attractions*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| attraction_id | text | NOT NULL, UNIQUE | Business ID: ATR-NNNNNN |
| area_id | text | FK→geo.areas | Area FK |
| company_id | text | FK→ops.companies | Operator FK |
| attraction_name | text | NOT NULL | Attraction name |
| attraction_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(Point, 4326) | | Location point |
| description | text | | Description |
| attraction_type | text | | museum, garden, historic, etc. |
| admission_price | decimal(12,2) | | Admission price |
| duration_hours | decimal(3,1) | | Typical visit duration |
| vibe_tags | text[] | | Vibe descriptors |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.6 concierge.shops 🔵
*Retail/shopping locations*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| shop_id | text | NOT NULL, UNIQUE | Business ID: SHP-NNNNNN |
| area_id | text | FK→geo.areas | Area FK |
| company_id | text | FK→ops.companies | Partner FK |
| shopping_location_id | text | FK→shopping_locations | If in shopping center |
| resort_id | text | FK→ops.resorts | If at resort |
| shop_name | text | NOT NULL | Shop name |
| shop_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(Point, 4326) | | Location point |
| description | text | | Description |
| shop_type | text | | clothing, souvenir, grocery, etc. |
| price_level | text | | $, $$, $$$, $$$$ |
| is_partner | boolean | DEFAULT false | Partner flag |
| discount_percentage | decimal(5,2) | | Discount % |
| vibe_tags | text[] | | Vibe descriptors |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.7 concierge.shopping_locations 🔵
*Shopping centers/malls*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| location_id | text | NOT NULL, UNIQUE | Business ID: SHPL-NNNNNN |
| area_id | text | FK→geo.areas | Area FK |
| location_name | text | NOT NULL | Location name |
| location_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(Point, 4326) | | Location point |
| description | text | | Description |
| location_type | text | | mall, plaza, outlet, etc. |
| parking_available | boolean | | Parking flag |
| vibe_tags | text[] | | Vibe descriptors |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.8 concierge.experience_spots 🔵
*General experience/viewpoint locations*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| spot_id | text | NOT NULL, UNIQUE | Business ID: EXP-NNNNNN |
| area_id | text | FK→geo.areas | Area FK |
| spot_name | text | NOT NULL | Spot name |
| spot_slug | text | UNIQUE | URL-safe slug |
| geom | geometry(Point, 4326) | | Location point |
| description | text | | Description |
| spot_type | text | | viewpoint, sunset, sunrise, etc. |
| best_time | text | | Best time to visit |
| vibe_tags | text[] | | Vibe descriptors |
| is_ai_visible | boolean | DEFAULT true | AI visibility |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.9 concierge.guest_travel_profiles 🔵
*Guest travel preference profiles*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| profile_id | text | NOT NULL, UNIQUE | Business ID: GTP-NNNNNN |
| guest_id | text | FK→ops.guests | Guest FK |
| activity_level_id | text | FK→ref.activity_levels | Activity level |
| schedule_density_id | text | FK→ref.schedule_density_levels | Schedule density |
| driving_tolerance_id | text | FK→ref.driving_tolerance_levels | Driving tolerance |
| budget_level_id | text | FK→ref.budget_levels | Budget level |
| traveling_with_children | boolean | DEFAULT false | Children flag |
| traveling_with_elderly | boolean | DEFAULT false | Elderly flag |
| notes | text | | Additional notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.10 concierge.guest_interests 🔵
*Guest interest selections*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| guest_id | text | FK→ops.guests | Guest FK |
| interest_type_id | text | FK→ref.interest_types | Interest FK |
| priority | integer | | Priority ranking |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 5.11 concierge.guest_limitations 🔵
*Guest limitation flags*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| guest_id | text | FK→ops.guests | Guest FK |
| limitation_type_id | text | FK→ref.limitation_types | Limitation FK |
| notes | text | | Additional notes |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 5.12 concierge.itinerary_themes 🔵
*Pre-built itinerary themes*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| theme_id | text | NOT NULL, UNIQUE | Business ID: THM-NNNNNN |
| theme_name | text | NOT NULL | Theme name |
| theme_slug | text | UNIQUE | URL-safe slug |
| description | text | | Description |
| ideal_activity_level_id | text | FK→ref.activity_levels | Best activity level |
| ideal_schedule_density_id | text | FK→ref.schedule_density_levels | Best schedule density |
| ideal_driving_tolerance_id | text | FK→ref.driving_tolerance_levels | Best driving tolerance |
| ideal_budget_level_id | text | FK→ref.budget_levels | Best budget level |
| suitable_for_children | boolean | DEFAULT true | Children suitable |
| suitable_for_elderly | boolean | DEFAULT true | Elderly suitable |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.13 concierge.theme_interest_weights 🔵
*Interest weights per theme (for AI scoring)*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| theme_id | text | FK→itinerary_themes | Theme FK |
| interest_type_id | text | FK→ref.interest_types | Interest FK |
| weight | decimal(3,2) | | Weight (0-1) |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 5.14 concierge.theme_limitations_excluded 🔵
*Limitations that exclude themes*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| theme_id | text | FK→itinerary_themes | Theme FK |
| limitation_type_id | text | FK→ref.limitation_types | Limitation FK |
| reason | text | | Exclusion reason |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 5.15 concierge.itineraries 🔵
*Generated guest itineraries*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| itinerary_id | text | NOT NULL, UNIQUE | Business ID: ITN-NNNNNN |
| reservation_id | text | FK→ops.reservations | Reservation FK |
| guest_id | text | FK→ops.guests | Guest FK |
| property_id | text | FK→ops.properties | Starting property |
| theme_id | text | FK→itinerary_themes | Theme used |
| profile_id | text | FK→guest_travel_profiles | Profile used |
| start_date | date | | Itinerary start |
| end_date | date | | Itinerary end |
| status | text | | draft, sent, confirmed |
| generated_at | timestamptz | | Generation time |
| sent_at | timestamptz | | Sent to guest |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

### 5.16 concierge.itinerary_days 🔵
*Day-level itinerary structure*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| day_id | text | NOT NULL, UNIQUE | Business ID |
| itinerary_id | text | FK→itineraries | Itinerary FK |
| day_number | integer | NOT NULL | Day number |
| day_date | date | | Actual date |
| day_theme | text | | Day theme/focus |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record creation |

---

### 5.17 concierge.itinerary_items 🔵
*Individual itinerary items*

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUID |
| item_id | text | NOT NULL, UNIQUE | Business ID |
| day_id | text | FK→itinerary_days | Day FK |
| sort_order | integer | | Display order |
| item_type | text | | beach, restaurant, activity, hike, etc. |
| venue_type | text | | Entity type |
| venue_id | text | | Entity FK |
| beach_id | text | FK→beaches | Beach FK |
| restaurant_id | text | FK→restaurants | Restaurant FK |
| activity_id | text | FK→activities | Activity FK |
| hike_id | text | FK→hikes | Hike FK |
| attraction_id | text | FK→attractions | Attraction FK |
| shop_id | text | FK→shops | Shop FK |
| experience_spot_id | text | FK→experience_spots | Spot FK |
| start_time | time | | Start time |
| end_time | time | | End time |
| notes | text | | Notes |
| booking_status | text | | pending, booked, confirmed |
| booking_confirmation | text | | Confirmation # |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

## 6. STAGING Schema — Staging Tables

### 6.1 staging.properties ✅
*Staging for property data from Google Sheet*

| Column | Type | Description |
|--------|------|-------------|
| property_id | text PK | Property ID |
| property_name | text | Property name |
| resort_id | text | Resort ID |
| property_number | text | Property # |
| property_short_name | text | Short name |
| status | text | Status |
| airbnb_id | text | Airbnb ID |
| vrbo_id | text | VRBO ID |
| tmk_number | text | TMK |
| homeowner | text | Homeowner |
| ge_tax_id | text | GE tax ID |
| ge_tax_letter_id_number | text | GE letter # |
| ta_tax_id | text | TA tax ID |
| ta_tax_letter_id_number | text | TA letter # |
| checkin_time | text | Check-in time |
| checkout_time | text | Check-out time |
| early_checkin_allowed | text | Early check-in |
| late_checkout_allowed | text | Late check-out |
| guest_registration_required | text | Registration required |
| wifi_speed | text | WiFi speed |
| property_type | text | Type |
| latitude | text | Latitude |
| longitude | text | Longitude |
| square_feet | text | Sq ft |
| street_number | text | Street # |
| street_name | text | Street name |
| unit_number | text | Unit # |
| city | text | City |
| state | text | State |
| zip_code | text | ZIP |
| building_floor | text | Floor |
| building | text | Building |
| wifi_network | text | WiFi network |
| wifi_password | text | WiFi password |
| internet_speed_mbps | text | Speed |
| beach_access | text | Beach access |
| beach_items | text | Beach items |
| closest_beach | text | Closest beach |
| private_parking | text | Parking |
| lanai | text | Lanai |
| bed | text | Beds |
| bath | text | Baths |
| sl_property_id | text | SL ID |
| rental_permit_number | text | Permit # |
| max_occupancy | text | Max occupancy |
| airbnb_guest_interactions | text | Airbnb interactions |
| airbnb_arrival_guide | text | Arrival guide |
| house_rules | text | House rules |
| access_instructions | text | Access instructions |
| floorplan_url | text | Floorplan URL |
| view | text | View |
| vrbo_title | text | VRBO title |
| property_description | text | Description |
| airbnb_headline | text | Airbnb headline |
| airbnb_short_description | text | Short description |
| airbnb_about_the_space | text | About space |
| link_to_web_page | text | Web link |
| web_name | text | Web name |
| pricing_group | text | Pricing group |
| loaded_at | timestamptz | Load timestamp |
| source_payload | jsonb | Raw payload |

---

### 6.2 staging.resorts ✅
*Staging for resort data*

| Column | Type | Description |
|--------|------|-------------|
| database_id | text PK | Resort ID |
| resort_name | text | Resort name |
| resort_code | text | Resort code |
| id | text | Legacy ID |
| street_address | text | Address |
| city | text | City |
| state | text | State |
| zip_code | text | ZIP |
| front_desk_phone | text | Phone |
| front_desk_email | text | Email |
| association_contact | text | HOA contact |
| engineering_contact | text | Engineering |
| security_contact_name | text | Security |
| general_manager | text | GM |
| package_pickup_location | text | Packages |
| service_request_process | text | Service process |
| ai_visible | text | AI visible |
| ac_available | text | AC |
| fitness_center | text | Fitness |
| tennis_courts | text | Tennis |
| provides_beach_towels | text | Beach towels |
| bbq | text | BBQ |
| pool | text | Pool |
| parking_designated_space | text | Parking |
| parking_free | text | Free parking |
| internet_info | text | Internet |
| resort_fee | text | Resort fee |
| key_cards | text | Key cards |
| internet_provider | text | ISP |
| cable_provider | text | Cable |
| pest_control_vendor | text | Pest control |
| guest_registration | text | Registration |
| guest_reg_process | text | Reg process |
| resort_fee_daily_amount | text | Daily fee |
| resort_fee_res_amount | text | Res fee |
| resort_fee_pay_due | text | Fee due |
| bill_pm | text | Bill PM |
| jacuzzi | text | Jacuzzi |
| day_spa | text | Day spa |
| beach_access | text | Beach |
| bell_service | text | Bell service |
| resort_outdoor_games | text | Games |
| pool_hours | text | Pool hours |
| construction_form_required | text | Construction form |
| construction_advance_notice_required | text | Advance notice |
| construction_restrictions | text | Restrictions |
| insurance_required | text | Insurance |
| notes | text | Notes |
| jacuzzi_details | text | Jacuzzi details |
| pool_details | text | Pool details |
| fitness_center_details | text | Fitness details |
| trash | text | Trash |
| tennis_courts_1 | text | Tennis 1 |
| pool_towels | text | Pool towels |
| parking_details | text | Parking details |
| loaded_at | timestamptz | Load timestamp |

---

### 6.3 staging.guests ✅
*Staging for guest data*

| Column | Type | Description |
|--------|------|-------------|
| guest_id | text PK | Guest ID |
| first_name | text | First name |
| last_name | text | Last name |
| full_name | text | Full name |
| phone | text | Phone |
| email | text | Email |
| address | text | Address |
| city | text | City |
| state | text | State |
| postal_code | text | ZIP |
| country | text | Country |
| loaded_at | timestamptz | Load timestamp |
| source_payload | jsonb | Raw payload |

---

### 6.4 staging.reservations ✅
*Staging for reservation data*

| Column | Type | Description |
|--------|------|-------------|
| reservation_id | text PK | Reservation ID |
| guest_id | text | Guest ID |
| property_id | text | Property ID |
| booked_at | timestamptz | Booked time |
| arrive_date | date | Arrival |
| depart_date | date | Departure |
| nights | integer | Nights |
| occupants | integer | Occupants |
| gross_total | numeric | Gross total |
| net_revenue | numeric | Net revenue |
| currency | text | Currency |
| status | text | Status |
| loaded_at | timestamptz | Load timestamp |
| source_payload | jsonb | Raw payload |

---

### 6.5 staging.homeowners ✅
*Staging for homeowner data*

| Column | Type | Description |
|--------|------|-------------|
| homeowner_id | text PK | Homeowner ID |
| full_name | text | Full name |
| first_name | text | First name |
| last_name | text | Last name |
| prefix | text | Prefix |
| email | text | Email |
| phone | text | Phone |
| loaded_at | timestamptz | Load timestamp |
| source_payload | jsonb | Raw payload |

---

### 6.6 staging.homeowner_property_relationships ✅
*Staging for homeowner-property links*

| Column | Type | Description |
|--------|------|-------------|
| hprx_id | text PK | Relationship ID |
| homeowner_id | text | Homeowner ID |
| property_id | text | Property ID |
| property_short_name | text | Short name |
| resort_id | text | Resort ID |
| bedrooms | numeric | Bedrooms |
| bathrooms | numeric | Bathrooms |
| loaded_at | timestamptz | Load timestamp |
| source_payload | jsonb | Raw payload |

---

### 6.7 staging.internal_team ✅
*Staging for internal team data*

| Column | Type | Description |
|--------|------|-------------|
| database_id | text PK | Team member ID |
| first_name | text | First name |
| last_name | text | Last name |
| team_name | text | Team |
| role | text | Role |
| internal_role_id | text | Role ID |
| email | text | Email |
| phone | text | Phone |
| status | text | Status |
| employment_type | text | Employment type |
| compensation_type | text | Compensation type |
| loaded_at | timestamptz | Load timestamp |
| source_payload | jsonb | Raw payload |

---

**Document Version:** v5  
**Last Updated:** November 30, 2025  
**Source:** ERD v3 HTML + Migration Files + Past Conversations
