# Central Memory Schema V4.2 — Complete Table Inventory

**Version:** 4.2
**Date:** December 9, 2025
**Purpose:** Comprehensive schema specification with complete field definitions for all tables. Consolidates V4.1 structure with detailed field specifications from all Complete Table Inventory documents.

---

## Document Summary

| Metric | Value |
|--------|-------|
| **Total Schemas** | 22 (excluding staging) |
| **Total Tables** | ~332 |
| **Primary Key Standard** | UUIDv7 (time-ordered, globally unique) |
| **ops Schema** | ELIMINATED (all tables relocated) |
| **Source Documents** | V4.1 Separated Schema + 17 Complete Table Inventory files |

---

## Schema Inventory (22 Schemas)

| Schema | Purpose | Tables |
|--------|---------|--------|
| **directory** | Contacts, guests, homeowners, companies, vendors | 13 |
| **property** | Properties, resorts, rooms, cleans, inspections, physical assets | 28 |
| **reservations** | Reservations, guest journeys, touchpoints, reviews, fees, journey/touchpoint config | 11 |
| **service** | Tickets, projects, damage claims, time allocation joins | 30 |
| **team** | Teams, team_directory, shifts, time_entries, verifications | 6 |
| **storage** | Files, file context joins | 4 |
| **inventory** | Inventory items, room/owner/company/storage inventory, purchasing | 15 |
| **ref** | Reference/lookup data (hybrid design) | 8 |
| **geo** | Geographic hierarchy | 5 |
| **ai** | AI agent infrastructure | 18 |
| **comms** | Communications system | 12 |
| **knowledge** | Documents, SOPs, embeddings | 28 |
| **revenue** | Revenue management, dynamic pricing | 12 |
| **concierge** | Guest experience system + interest/preference config | 27 |
| **finance** | Accounting, trust, statements, payroll | 18 |
| **brand_marketing** | Company brand + guest marketing campaigns | 24 |
| **property_listings** | Listing content & distribution | 23 |
| **external** | External market intelligence | 6 |
| **homeowner_acquisition** | Owner pipeline & onboarding | 11 |
| **secure** | Sensitive/encrypted data | 5 |
| **analytics** | Materialized views & analytics | 5 |
| **portal** | User authentication, sessions, RBAC | 6 |

---

## Business ID Patterns

| Entity | Pattern | Example | Seq Start |
|--------|---------|---------|-----------|
| Contact | CON-NNNNNN | CON-000001 | 1 |
| Guest | GST-NNNNNN | GST-100001 | 100001 |
| Homeowner | HOP-NNNNNN | HOP-200001 | 200001 |
| Company | CMP-NNNNNN | CMP-300001 | 300001 |
| Vendor | VND-NNNNNN | VND-400001 | 400001 |
| Property | PROP-NNNN | PROP-0001 | 0001 |
| Resort | RST-NNNN | RST-0001 | 0001 |
| Room | RM-NNNNN | RM-00001 | 00001 |
| Reservation | RES-YYYY-NNNNNN | RES-2025-000001 | 1/year |
| Ticket | TIK-{TYPE}-NNNNNN | TIK-PC-000001 | 1/type |
| Team Member | MBR-NNNNNN | MBR-000001 | 1 |
| Shift | SHFT-NNNNNN | SHFT-000001 | 1 |
| Time Entry | TIME-NNNNNNNN | TIME-00000001 | 1 |
| File | FILE-NNNNNNNN | FILE-00000001 | 1 |
| Damage Claim | CLM-NNNNNN | CLM-000001 | 1 |
| Project | PRJ-NNNNNN | PRJ-000001 | 1 |
| Agent | AGT-NNNN | AGT-0001 | 1 |
| Conversation | CONV-NNNNNNNN | CONV-00000001 | 1 |
| Thread | THR-NNNNNNNN | THR-01000001 | 10000001 |
| Message | MSG-NNNNNNNN | MSG-01000001 | 10000001 |
| Template | TMPL-NNNNNN | TMPL-010001 | 10001 |
| Document | DOC-NNNNNN | DOC-000001 | 1 |
| Article | ART-NNNNNN | ART-000001 | 1 |
| Beach | BCH-NNNN | BCH-0001 | 0001 |
| Hike | HIK-NNNN | HIK-0042 | 0001 |
| Activity | ACT-NNNNNN | ACT-010001 | 10001 |
| Restaurant | RST-NNNNNN | RST-010023 | 10001 |
| Itinerary | ITN-NNNNNN | ITN-060001 | 10001 |
| Booking | BKG-NNNNNN | BKG-070001 | 10001 |
| Transaction | TXN-NNNNNNNN | TXN-00000001 | 1 |
| Invoice | INV-NNNNNN | INV-000001 | 1 |
| Lead | LEAD-NNNNNN | LEAD-000001 | 1 |
| Proposal | PROP-NNNNNN | PROP-000001 | 1 |

---

# PART 1: CORE OPERATIONAL SCHEMAS

---

## 1. DIRECTORY Schema (13 tables)

**Purpose:** Central contact entities that other schemas reference. All people and organizations are contacts first, with role-specific extensions for guests, homeowners, companies, and vendors.

### 1.1 directory.contacts

**PURPOSE:** Unified contact hub for all people and organizations. Every guest, homeowner, vendor contact, and team member links here.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| contact_id | text | NOT NULL, UNIQUE | Business ID: CON-NNNNNN |
| contact_type | text | NOT NULL | person, company, trust, estate |
| status | text | DEFAULT 'active' | active, inactive, merged, deceased |
| first_name | text | | First name (persons) |
| last_name | text | | Last name (persons) |
| full_name | text | | Full display name |
| company_name | text | | Company/org name (if company type) |
| email | text | | Primary email |
| email_secondary | text | | Secondary email |
| email_verified | boolean | DEFAULT false | Email verified? |
| phone | text | | Primary phone (E.164 format) |
| phone_secondary | text | | Secondary phone |
| phone_type | text | | mobile, home, work |
| sms_capable | boolean | DEFAULT true | Can receive SMS? |
| sms_opt_in | boolean | DEFAULT true | Opted into SMS? |
| address_line1 | text | | Street address |
| address_line2 | text | | Apt/Suite |
| city | text | | City |
| state | text | | State/Province |
| postal_code | text | | ZIP/Postal code |
| country_code | text | DEFAULT 'US' | ISO country code |
| timezone | text | DEFAULT 'Pacific/Honolulu' | Contact timezone |
| preferred_language | text | DEFAULT 'en' | ISO language code |
| preferred_contact_method | text | DEFAULT 'email' | email, phone, sms |
| do_not_contact | boolean | DEFAULT false | DNC flag |
| do_not_email | boolean | DEFAULT false | No email flag |
| do_not_sms | boolean | DEFAULT false | No SMS flag |
| do_not_call | boolean | DEFAULT false | No call flag |
| notes | text | | Internal notes |
| external_source | text | | streamline, airbnb, vrbo, manual |
| external_id | text | | External system ID |
| last_contact_at | timestamptz | | Last interaction |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Indexes:**
- `idx_contacts_email` ON (email) WHERE email IS NOT NULL
- `idx_contacts_phone` ON (phone) WHERE phone IS NOT NULL
- `idx_contacts_type` ON (contact_type)
- `idx_contacts_status` ON (status)
- `idx_contacts_external` ON (external_source, external_id)

---

### 1.2 directory.guests

**PURPOSE:** Guest-specific profile extending contacts. Stores loyalty status, stay history, preferences, and VIP indicators.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| guest_id | text | NOT NULL, UNIQUE | Business ID: GST-NNNNNN |
| contact_id | uuid | FK → contacts, NOT NULL, UNIQUE | Contact reference |
| guest_status | text | DEFAULT 'active' | active, inactive, blocked |
| is_vip | boolean | DEFAULT false | VIP flag |
| vip_reason | text | | Why VIP |
| vip_notes | text | | VIP handling notes |
| loyalty_tier | text | | bronze, silver, gold, platinum |
| lifetime_stays | integer | DEFAULT 0 | Total stays |
| lifetime_nights | integer | DEFAULT 0 | Total nights |
| lifetime_revenue | numeric(12,2) | DEFAULT 0 | Total revenue |
| first_stay_date | date | | First stay |
| last_stay_date | date | | Most recent stay |
| average_rating_given | numeric(3,2) | | Avg review score |
| booking_source_primary | text | | Most common source |
| preferred_properties | text[] | | Preferred property IDs |
| dietary_restrictions | text[] | | Dietary needs |
| special_requests_default | text | | Default requests |
| notes | text | | Guest-specific notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**FK Actions:**
- contact_id: ON DELETE CASCADE

---

### 1.3 directory.homeowners

**PURPOSE:** Homeowner-specific profile extending contacts. Stores communication preferences, trust levels, and financial relationship data.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| homeowner_id | text | NOT NULL, UNIQUE | Business ID: HOP-NNNNNN |
| contact_id | uuid | FK → contacts, NOT NULL, UNIQUE | Contact reference |
| owner_status | text | DEFAULT 'active' | active, onboarding, inactive, churned |
| owner_type | text | | individual, trust, llc, partnership |
| contract_start_date | date | | Management contract start |
| contract_end_date | date | | Contract end (if terminated) |
| commission_rate | numeric(5,2) | | Override commission % |
| communication_preference | text | DEFAULT 'email' | email, phone, portal |
| communication_frequency | text | DEFAULT 'standard' | minimal, standard, detailed |
| approval_required_threshold | numeric(10,2) | DEFAULT 500 | $ above which needs approval |
| auto_approve_categories | text[] | | Categories auto-approved |
| trust_level | text | DEFAULT 'standard' | new, standard, trusted, vip |
| escalation_priority | text | DEFAULT 'standard' | standard, high, urgent |
| notes | text | | Owner-specific notes |
| qbo_customer_id | text | | QuickBooks customer ID |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**FK Actions:**
- contact_id: ON DELETE CASCADE

---

### 1.4 directory.companies

**PURPOSE:** Company/organization records for vendors, partners, and other businesses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| company_id | text | NOT NULL, UNIQUE | Business ID: CMP-NNNNNN |
| contact_id | uuid | FK → contacts | Contact reference (optional) |
| company_name | text | NOT NULL | Company name |
| dba_name | text | | Doing business as |
| company_type | text | | vendor, supplier, partner, ota, insurance |
| tax_id | text | | EIN/Tax ID |
| business_license | text | | License number |
| website | text | | Website URL |
| primary_contact_id | uuid | FK → contacts | Main contact person |
| billing_contact_id | uuid | FK → contacts | Billing contact |
| billing_email | text | | Billing email |
| payment_terms | text | DEFAULT 'net30' | net15, net30, net60, due_on_receipt |
| credit_limit | numeric(10,2) | | Credit limit |
| vendor_category | text | | Primary category |
| service_areas | text[] | | Geographic service areas |
| is_preferred | boolean | DEFAULT false | Preferred vendor? |
| is_emergency_capable | boolean | DEFAULT false | 24/7 available? |
| insurance_verified | boolean | DEFAULT false | Insurance verified? |
| insurance_expiry | date | | Insurance expiration |
| internal_rating | integer | | 1-5 internal rating |
| rating_notes | text | | Rating explanation |
| status | text | DEFAULT 'active' | active, inactive, suspended |
| notes | text | | Internal notes |
| qbo_vendor_id | text | | QuickBooks vendor ID |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 1.5 directory.vendors

**PURPOSE:** Vendor-specific details extending companies with service capabilities and pricing.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| vendor_id | text | NOT NULL, UNIQUE | Business ID: VND-NNNNNN |
| company_id | uuid | FK → companies, NOT NULL | Company reference |
| vendor_type | text | NOT NULL | service, supplier, contractor |
| service_categories | text[] | | plumbing, electrical, hvac, etc. |
| hourly_rate | numeric(10,2) | | Standard hourly rate |
| minimum_charge | numeric(10,2) | | Minimum service charge |
| emergency_rate_multiplier | numeric(3,2) | DEFAULT 1.5 | Emergency rate multiplier |
| response_time_hours | integer | | Typical response time |
| service_area_miles | integer | | Service radius |
| certifications | text[] | | Professional certifications |
| specialties | text[] | | Specialization areas |
| availability | jsonb | | Availability schedule |
| performance_score | numeric(3,2) | | Calculated performance |
| total_jobs_completed | integer | DEFAULT 0 | Jobs completed |
| on_time_percentage | numeric(5,2) | | On-time completion % |
| average_job_rating | numeric(3,2) | | Average job rating |
| notes | text | | Vendor-specific notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**FK Actions:**
- company_id: ON DELETE CASCADE

---

### 1.6 directory.homeowner_property_relationship

**PURPOSE:** Links homeowners to properties with ownership details and effective dates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| homeowner_id | uuid | FK → homeowners, NOT NULL | Homeowner reference |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| ownership_type | text | NOT NULL | primary, secondary, trust, llc |
| ownership_percentage | numeric(5,2) | DEFAULT 100 | Ownership % |
| is_primary_contact | boolean | DEFAULT true | Primary contact for property |
| role | text | DEFAULT 'owner' | owner, trustee, manager |
| effective_date | date | NOT NULL | Relationship start |
| end_date | date | | Relationship end |
| notes | text | | Relationship notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (homeowner_id, property_id) WHERE end_date IS NULL

---

### 1.7 directory.vendor_assignments

**PURPOSE:** Links vendors to properties for service assignments.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| company_id | uuid | FK → companies, NOT NULL | Vendor company |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| service_category | text | NOT NULL | plumbing, electrical, etc. |
| is_preferred | boolean | DEFAULT false | Preferred for this service |
| is_primary | boolean | DEFAULT false | Primary vendor |
| assignment_notes | text | | Assignment-specific notes |
| effective_date | date | DEFAULT CURRENT_DATE | Assignment start |
| end_date | date | | Assignment end |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (company_id, property_id, service_category) WHERE end_date IS NULL

---

### 1.8 directory.contact_groups

**PURPOSE:** Contact groupings for communications and operations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| group_id | text | NOT NULL, UNIQUE | Business ID: GRP-NNNNNN |
| group_name | text | NOT NULL | Group name |
| group_type | text | | distribution, segment, team |
| description | text | | Group description |
| is_dynamic | boolean | DEFAULT false | Auto-populated by rules? |
| dynamic_rules | jsonb | | Rules for auto-population |
| created_by_id | uuid | FK → team.team_directory | Creator |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 1.9 directory.contact_group_members

**PURPOSE:** Junction table for group membership.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| group_id | uuid | FK → contact_groups, NOT NULL | Group reference |
| contact_id | uuid | FK → contacts, NOT NULL | Contact reference |
| role | text | DEFAULT 'member' | member, admin |
| added_at | timestamptz | DEFAULT now() | When added |
| added_by_id | uuid | FK → team.team_directory | Who added |
| removed_at | timestamptz | | When removed |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (group_id, contact_id) WHERE removed_at IS NULL

---

### 1.10 directory.contact_relationships

**PURPOSE:** Links between contacts (spouse, assistant, etc.).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| contact_id | uuid | FK → contacts, NOT NULL | Primary contact |
| related_contact_id | uuid | FK → contacts, NOT NULL | Related contact |
| relationship_type | text | NOT NULL | spouse, assistant, emergency_contact, etc. |
| is_bidirectional | boolean | DEFAULT false | Applies both ways? |
| notes | text | | Relationship notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (contact_id, related_contact_id, relationship_type)

---

### 1.11 directory.contact_notes

**PURPOSE:** Time-stamped notes on contacts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| contact_id | uuid | FK → contacts, NOT NULL | Contact reference |
| note_type | text | DEFAULT 'general' | general, communication, complaint, preference |
| note_text | text | NOT NULL | Note content |
| is_pinned | boolean | DEFAULT false | Pinned/important |
| is_internal | boolean | DEFAULT true | Internal only |
| created_by_id | uuid | FK → team.team_directory | Note author |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 1.12 directory.contact_tags

**PURPOSE:** Tag associations for contacts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| contact_id | uuid | FK → contacts, NOT NULL | Contact reference |
| tag | text | NOT NULL | Tag value |
| tag_category | text | | Tag category |
| applied_by_id | uuid | FK → team.team_directory | Who applied |
| applied_at | timestamptz | DEFAULT now() | When applied |
| removed_at | timestamptz | | When removed |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (contact_id, tag) WHERE removed_at IS NULL

---

### 1.13 directory.contact_merge_history

**PURPOSE:** Tracks contact deduplication/merges for audit.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| surviving_contact_id | uuid | FK → contacts, NOT NULL | Kept contact |
| merged_contact_id | uuid | NOT NULL | Contact that was merged |
| merged_contact_data | jsonb | | Snapshot of merged contact |
| merge_reason | text | | Why merged |
| merged_by_id | uuid | FK → team.team_directory | Who merged |
| merged_at | timestamptz | DEFAULT now() | When merged |
| created_at | timestamptz | DEFAULT now() | Record created |

---

## 2. PROPERTY Schema (28 tables)

**Purpose:** All property and physical asset components including resorts, rooms, cleaning, inspections, and physical asset tracking.

### Core Property Tables

---

### 2.1 property.resorts

**PURPOSE:** Resort/complex master data. Properties belong to resorts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| resort_id | text | NOT NULL, UNIQUE | Business ID: RST-NNNN |
| resort_name | text | NOT NULL | Resort name |
| resort_code | text | NOT NULL, UNIQUE | Short code |
| address_line1 | text | | Street address |
| address_line2 | text | | Address line 2 |
| city | text | | City |
| state | text | DEFAULT 'HI' | State |
| postal_code | text | | ZIP code |
| country_code | text | DEFAULT 'US' | Country |
| area_id | uuid | FK → geo.areas | Geographic area |
| latitude | numeric(10,7) | | Latitude |
| longitude | numeric(10,7) | | Longitude |
| total_units | integer | | Total units in resort |
| managed_units | integer | | Units we manage |
| property_type | text | | condo, townhouse, resort, hotel |
| amenities | text[] | | Resort-level amenities |
| check_in_location | text | | Check-in instructions |
| parking_info | text | | Parking details |
| wifi_network | text | | Default WiFi network |
| wifi_password | text | | Default WiFi password |
| front_desk_phone | text | | Front desk number |
| emergency_contact | text | | Emergency contact |
| hoa_contact | text | | HOA contact |
| hoa_phone | text | | HOA phone |
| hoa_email | text | | HOA email |
| notes | text | | Internal notes |
| status | text | DEFAULT 'active' | active, inactive |
| streamline_id | text | | Streamline complex ID |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.2 property.properties

**PURPOSE:** Property master record. Central to most operations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| property_id | text | NOT NULL, UNIQUE | Business ID: PROP-NNNN |
| property_name | text | NOT NULL | Display name |
| property_code | text | NOT NULL, UNIQUE | Short code |
| resort_id | uuid | FK → resorts | Resort reference |
| area_id | uuid | FK → geo.areas | Geographic area |
| address_line1 | text | | Unit address |
| address_line2 | text | | Address line 2 |
| city | text | | City |
| state | text | DEFAULT 'HI' | State |
| postal_code | text | | ZIP code |
| country_code | text | DEFAULT 'US' | Country |
| latitude | numeric(10,7) | | Latitude |
| longitude | numeric(10,7) | | Longitude |
| property_type | text | | condo, house, townhouse, villa |
| bedrooms | integer | | Bedroom count |
| bathrooms | numeric(3,1) | | Bathroom count |
| sleeps | integer | | Max occupancy |
| square_feet | integer | | Square footage |
| floor_level | integer | | Floor number |
| unit_number | text | | Unit number |
| building | text | | Building name/number |
| view_type | text | | ocean, garden, mountain, pool |
| has_ac | boolean | DEFAULT true | Has A/C |
| has_pool | boolean | DEFAULT false | Has pool |
| has_hot_tub | boolean | DEFAULT false | Has hot tub |
| has_lanai | boolean | DEFAULT true | Has lanai/balcony |
| has_washer_dryer | boolean | DEFAULT true | Has W/D |
| has_garage | boolean | DEFAULT false | Has garage |
| parking_spaces | integer | DEFAULT 1 | Parking spaces |
| parking_type | text | | covered, uncovered, garage |
| parking_stall_numbers | text[] | | Assigned stalls |
| pet_policy | text | DEFAULT 'no_pets' | no_pets, small_dogs, cats_ok |
| smoking_policy | text | DEFAULT 'no_smoking' | no_smoking, lanai_only |
| check_in_time | time | DEFAULT '15:00' | Standard check-in |
| check_out_time | time | DEFAULT '10:00' | Standard check-out |
| early_check_in_available | boolean | DEFAULT true | Early check-in possible? |
| late_check_out_available | boolean | DEFAULT true | Late check-out possible? |
| min_stay_nights | integer | DEFAULT 3 | Minimum stay |
| wifi_network | text | | WiFi network name |
| wifi_password | text | | WiFi password |
| door_code | text | | Door code |
| gate_code | text | | Gate code |
| lockbox_location | text | | Key lockbox location |
| lockbox_code | text | | Lockbox code |
| notes | text | | Internal notes |
| owner_notes | text | | Owner-specific notes |
| guest_notes | text | | Guest-facing notes |
| status | text | DEFAULT 'active' | active, inactive, onboarding, churned |
| management_status | text | DEFAULT 'managed' | managed, owner_hold, off_market |
| onboarding_date | date | | When added to management |
| offboarding_date | date | | When removed from management |
| streamline_id | text | | Streamline property ID |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.3 property.rooms

**PURPOSE:** Individual rooms within properties for detailed tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| room_id | text | NOT NULL, UNIQUE | Business ID: RM-NNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_type_code | text | FK → ref.room_types | Room type |
| room_name | text | NOT NULL | Room name (Master Bedroom) |
| room_number | integer | | Room sequence |
| floor_level | integer | | Which floor |
| square_feet | integer | | Room size |
| has_bathroom | boolean | DEFAULT false | En-suite bathroom? |
| has_closet | boolean | DEFAULT true | Has closet? |
| has_tv | boolean | DEFAULT true | Has TV? |
| has_ac | boolean | DEFAULT true | Individual A/C? |
| window_count | integer | | Number of windows |
| notes | text | | Room notes |
| sort_order | integer | DEFAULT 0 | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.4 property.beds

**PURPOSE:** Bed configurations per room.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| room_id | uuid | FK → rooms, NOT NULL | Room reference |
| bed_type_code | text | FK → ref.bed_types, NOT NULL | Bed type |
| bed_number | integer | DEFAULT 1 | Bed sequence in room |
| bed_brand | text | | Brand |
| bed_model | text | | Model |
| purchase_date | date | | When purchased |
| mattress_size | text | | twin, full, queen, king, cal_king |
| is_adjustable | boolean | DEFAULT false | Adjustable base? |
| notes | text | | Bed notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (room_id, bed_number)

---

### Cleaning & Inspection Tables

---

### 2.5 property.cleans

**PURPOSE:** Cleaning events for properties.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| clean_id | text | NOT NULL, UNIQUE | Business ID: CLN-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| reservation_id | uuid | FK → reservations.reservations | Related reservation |
| clean_type | text | NOT NULL | turnover, deep, mid_stay, refresh, pre_arrival |
| scheduled_date | date | NOT NULL | Scheduled date |
| scheduled_time | time | | Scheduled time |
| actual_start_at | timestamptz | | Actual start |
| actual_end_at | timestamptz | | Actual end |
| duration_minutes | integer | | Total duration |
| status | text | DEFAULT 'scheduled' | scheduled, in_progress, completed, cancelled, rescheduled |
| assigned_to_id | uuid | FK → team.team_directory | Assigned cleaner |
| secondary_cleaner_id | uuid | FK → team.team_directory | Second cleaner |
| supervisor_id | uuid | FK → team.team_directory | Supervisor |
| supplies_used | jsonb | | Supplies consumed |
| special_requests | text | | Special instructions |
| notes | text | | Clean notes |
| issues_found | text | | Issues discovered |
| completed_by_id | uuid | FK → team.team_directory | Who completed |
| verified_by_id | uuid | FK → team.team_directory | Who verified |
| verified_at | timestamptz | | Verification time |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.6 property.inspections

**PURPOSE:** Property inspection events.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| inspection_id | text | NOT NULL, UNIQUE | Business ID: INS-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| clean_id | uuid | FK → cleans | Related clean |
| reservation_id | uuid | FK → reservations.reservations | Related reservation |
| inspection_type | text | NOT NULL | post_clean, pre_arrival, departure, monthly, quarterly, annual |
| scheduled_date | date | NOT NULL | Scheduled date |
| scheduled_time | time | | Scheduled time |
| actual_start_at | timestamptz | | Actual start |
| actual_end_at | timestamptz | | Actual end |
| duration_minutes | integer | | Total duration |
| status | text | DEFAULT 'scheduled' | scheduled, in_progress, completed, cancelled |
| inspector_id | uuid | FK → team.team_directory, NOT NULL | Inspector |
| overall_score | numeric(5,2) | | Calculated overall score |
| cleanliness_score | numeric(5,2) | | Cleanliness score |
| maintenance_score | numeric(5,2) | | Maintenance score |
| inventory_score | numeric(5,2) | | Inventory score |
| pass_fail | text | | pass, fail, conditional |
| issues_count | integer | DEFAULT 0 | Total issues found |
| critical_issues_count | integer | DEFAULT 0 | Critical issues |
| follow_up_required | boolean | DEFAULT false | Needs follow-up? |
| follow_up_ticket_id | uuid | FK → service.tickets | Generated ticket |
| notes | text | | Inspection notes |
| completed_at | timestamptz | | When completed |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.7 property.inspection_questions

**PURPOSE:** Master inspection question templates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| question_code | text | NOT NULL, UNIQUE | Question code |
| category | text | NOT NULL | cleanliness, maintenance, safety, inventory |
| room_type_code | text | FK → ref.room_types | Room type (null = all rooms) |
| question_text | text | NOT NULL | Question text |
| question_type | text | NOT NULL | yes_no, rating, count, text |
| options | text[] | | Options if multiple choice |
| is_required | boolean | DEFAULT true | Required? |
| is_critical | boolean | DEFAULT false | Critical issue if failed? |
| weight | numeric(3,2) | DEFAULT 1.0 | Score weight |
| guidance_text | text | | Helper text |
| photo_required | boolean | DEFAULT false | Photo required? |
| sort_order | integer | DEFAULT 0 | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_by_id | uuid | FK → team.team_directory | Creator |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.8 property.inspection_room_questions

**PURPOSE:** Answers to inspection questions per room.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| inspection_id | uuid | FK → inspections, NOT NULL | Inspection reference |
| room_id | uuid | FK → rooms | Room reference |
| question_id | uuid | FK → inspection_questions, NOT NULL | Question reference |
| response_value | text | | Text response |
| response_bool | boolean | | Boolean response |
| response_number | numeric(10,2) | | Numeric response |
| response_rating | integer | | Rating (1-5) |
| is_issue | boolean | DEFAULT false | Flagged as issue? |
| issue_severity | text | | minor, moderate, major, critical |
| issue_id | uuid | FK → inspection_issues | Generated issue |
| generated_ticket_id | uuid | FK → service.tickets | Generated ticket |
| photo_file_ids | uuid[] | | Photo references |
| notes | text | | Response notes |
| answered_by_id | uuid | FK → team.team_directory | Who answered |
| answered_at | timestamptz | | When answered |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 2.9 property.inspection_question_inventory_links

**PURPOSE:** Links inspection questions to inventory items.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| question_id | uuid | FK → inspection_questions, NOT NULL | Question reference |
| inventory_item_id | uuid | FK → inventory.inventory_items, NOT NULL | Item reference |
| expected_quantity | integer | | Expected count |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 2.10 property.inspection_issues

**PURPOSE:** Issues found during inspections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| issue_id | text | NOT NULL, UNIQUE | Business ID: ISS-NNNNNN |
| inspection_id | uuid | FK → inspections, NOT NULL | Inspection reference |
| room_id | uuid | FK → rooms | Room where found |
| category | text | NOT NULL | cleanliness, maintenance, safety, inventory |
| severity | text | NOT NULL | minor, moderate, major, critical |
| description | text | NOT NULL | Issue description |
| location_detail | text | | Specific location |
| photo_file_ids | uuid[] | | Photo references |
| status | text | DEFAULT 'open' | open, assigned, in_progress, resolved |
| generated_ticket_id | uuid | FK → service.tickets | Generated ticket |
| resolution | text | | How resolved |
| resolved_by_id | uuid | FK → team.team_directory | Who resolved |
| resolved_at | timestamptz | | When resolved |
| reported_by_id | uuid | FK → team.team_directory | Who reported |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.11 property.inspection_room_scores

**PURPOSE:** Calculated scores per room per inspection.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| inspection_id | uuid | FK → inspections, NOT NULL | Inspection reference |
| room_id | uuid | FK → rooms, NOT NULL | Room reference |
| cleanliness_score | numeric(5,2) | | Cleanliness score |
| maintenance_score | numeric(5,2) | | Maintenance score |
| inventory_score | numeric(5,2) | | Inventory score |
| overall_score | numeric(5,2) | | Overall score |
| issues_count | integer | DEFAULT 0 | Issues in room |
| notes | text | | Score notes |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (inspection_id, room_id)

---

### Physical Asset Tables

---

### 2.12 property.appliances

**PURPOSE:** Major appliances in properties.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| appliance_id | text | NOT NULL, UNIQUE | Business ID: APL-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_id | uuid | FK → rooms | Room location |
| appliance_type_code | text | FK → ref.appliance_types, NOT NULL | Appliance type |
| brand | text | | Brand |
| model | text | | Model |
| model_number | text | | Model number |
| serial_number | text | | Serial number |
| color | text | | Color/finish |
| purchase_date | date | | When purchased |
| purchase_price | numeric(10,2) | | Purchase price |
| warranty_expiry | date | | Warranty expiration |
| expected_lifespan_years | integer | | Expected lifespan |
| condition | text | DEFAULT 'good' | excellent, good, fair, poor |
| last_service_date | date | | Last serviced |
| next_service_date | date | | Next service due |
| service_interval_months | integer | | Service interval |
| notes | text | | Appliance notes |
| is_active | boolean | DEFAULT true | Active/in use |
| replaced_by_id | uuid | FK → appliances | Replacement |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.13 property.appliance_parts

**PURPOSE:** Replaceable parts for appliances.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| appliance_id | uuid | FK → appliances, NOT NULL | Appliance reference |
| part_name | text | NOT NULL | Part name |
| part_number | text | | Part number |
| manufacturer | text | | Part manufacturer |
| last_replaced | date | | Last replacement date |
| replacement_interval_months | integer | | Replacement interval |
| next_replacement_due | date | | Next replacement |
| cost | numeric(10,2) | | Part cost |
| notes | text | | Part notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.14 property.fixtures

**PURPOSE:** Plumbing and bathroom fixtures.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| fixture_id | text | NOT NULL, UNIQUE | Business ID: FIX-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_id | uuid | FK → rooms, NOT NULL | Room location |
| fixture_type_code | text | FK → ref.fixture_types, NOT NULL | Fixture type |
| brand | text | | Brand |
| model | text | | Model |
| color | text | | Color/finish |
| install_date | date | | Installation date |
| condition | text | DEFAULT 'good' | excellent, good, fair, poor |
| notes | text | | Fixture notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.15 property.surfaces

**PURPOSE:** Counters, floors, and other surfaces.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| surface_id | text | NOT NULL, UNIQUE | Business ID: SRF-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_id | uuid | FK → rooms, NOT NULL | Room location |
| surface_type_code | text | FK → ref.surface_types, NOT NULL | Surface type |
| material | text | | granite, quartz, tile, hardwood, etc. |
| color | text | | Color |
| square_feet | numeric(8,2) | | Area |
| install_date | date | | Installation date |
| condition | text | DEFAULT 'good' | excellent, good, fair, poor |
| last_refinished | date | | Last refinishing |
| notes | text | | Surface notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.16 property.lighting

**PURPOSE:** Light fixtures in properties.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| lighting_id | text | NOT NULL, UNIQUE | Business ID: LGT-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_id | uuid | FK → rooms, NOT NULL | Room location |
| fixture_type | text | NOT NULL | ceiling, recessed, pendant, sconce, lamp, under_cabinet |
| location_detail | text | | Specific location |
| bulb_type | text | | led, incandescent, fluorescent, halogen |
| bulb_count | integer | DEFAULT 1 | Number of bulbs |
| wattage | integer | | Total wattage |
| is_dimmable | boolean | DEFAULT false | Dimmable? |
| is_smart | boolean | DEFAULT false | Smart lighting? |
| switch_location | text | | Switch location |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.17 property.window_coverings

**PURPOSE:** Blinds, curtains, and shades.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| covering_id | text | NOT NULL, UNIQUE | Business ID: WCV-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_id | uuid | FK → rooms, NOT NULL | Room location |
| covering_type | text | NOT NULL | blinds, curtains, shades, shutters, drapes |
| material | text | | Material type |
| color | text | | Color |
| width_inches | numeric(6,2) | | Width |
| height_inches | numeric(6,2) | | Height |
| is_blackout | boolean | DEFAULT false | Blackout capability |
| is_motorized | boolean | DEFAULT false | Motorized? |
| install_date | date | | Installation date |
| condition | text | DEFAULT 'good' | excellent, good, fair, poor |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.18 property.room_features

**PURPOSE:** Built-in features like closets, cabinets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| feature_id | text | NOT NULL, UNIQUE | Business ID: RMF-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_id | uuid | FK → rooms, NOT NULL | Room location |
| feature_type | text | NOT NULL | closet, cabinet, shelf, built_in, storage |
| feature_name | text | | Feature name |
| location_detail | text | | Specific location |
| dimensions | text | | Dimensions |
| material | text | | Material |
| has_doors | boolean | DEFAULT true | Has doors? |
| door_type | text | | sliding, hinged, folding |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.19 property.ac_systems

**PURPOSE:** HVAC systems at property level.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ac_system_id | text | NOT NULL, UNIQUE | Business ID: ACS-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| system_type | text | NOT NULL | central, split, mini_split, window, portable |
| brand | text | | Brand |
| model | text | | Model |
| capacity_btu | integer | | BTU capacity |
| install_date | date | | Installation date |
| last_service_date | date | | Last service |
| next_service_date | date | | Next service due |
| filter_size | text | | Filter dimensions |
| filter_last_changed | date | | Last filter change |
| refrigerant_type | text | | R-22, R-410A, etc. |
| condition | text | DEFAULT 'good' | excellent, good, fair, poor |
| warranty_expiry | date | | Warranty expiration |
| notes | text | | System notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.20 property.ac_units

**PURPOSE:** Individual A/C units within systems.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ac_unit_id | text | NOT NULL, UNIQUE | Business ID: ACU-NNNNNN |
| ac_system_id | uuid | FK → ac_systems, NOT NULL | System reference |
| room_id | uuid | FK → rooms | Room served |
| unit_type | text | | indoor, outdoor, window |
| location | text | | Physical location |
| serial_number | text | | Serial number |
| has_remote | boolean | DEFAULT true | Has remote? |
| remote_model | text | | Remote model |
| notes | text | | Unit notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.21 property.property_doors

**PURPOSE:** Door inventory for properties.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| door_id | text | NOT NULL, UNIQUE | Business ID: DOR-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_id | uuid | FK → rooms | Room location |
| door_type | text | NOT NULL | entry, interior, sliding, closet, garage |
| location | text | NOT NULL | Door location |
| material | text | | wood, metal, glass, fiberglass |
| color | text | | Color |
| has_lock | boolean | DEFAULT false | Has lock? |
| has_screen | boolean | DEFAULT false | Has screen? |
| is_exterior | boolean | DEFAULT false | Exterior door? |
| notes | text | | Door notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.22 property.property_locks

**PURPOSE:** Lock details for doors.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| lock_id | text | NOT NULL, UNIQUE | Business ID: LCK-NNNNNN |
| door_id | uuid | FK → property_doors, NOT NULL | Door reference |
| lock_type | text | NOT NULL | deadbolt, knob, smart, keypad, biometric |
| brand | text | | Brand |
| model | text | | Model |
| is_smart | boolean | DEFAULT false | Smart lock? |
| smart_platform | text | | Integration platform |
| has_keypad | boolean | DEFAULT false | Has keypad? |
| key_quantity | integer | | Number of physical keys |
| code_current | text | | Current code |
| code_master | text | | Master code |
| battery_type | text | | Battery type |
| battery_last_changed | date | | Last battery change |
| install_date | date | | Installation date |
| notes | text | | Lock notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.23 property.key_checkouts

**PURPOSE:** Physical key checkout tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| checkout_id | text | NOT NULL, UNIQUE | Business ID: KEY-NNNNNN |
| lock_id | uuid | FK → property_locks, NOT NULL | Lock reference |
| key_number | text | | Key identifier |
| checked_out_to_id | uuid | FK → team.team_directory, NOT NULL | Who has key |
| checked_out_at | timestamptz | NOT NULL | Checkout time |
| expected_return_at | timestamptz | | Expected return |
| returned_at | timestamptz | | Actual return |
| returned_to_id | uuid | FK → team.team_directory | Who received return |
| purpose | text | | Reason for checkout |
| notes | text | | Checkout notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 2.24 property.safety_items

**PURPOSE:** Safety equipment tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| safety_item_id | text | NOT NULL, UNIQUE | Business ID: SAF-NNNNNN |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| room_id | uuid | FK → rooms | Room location |
| item_type | text | NOT NULL | smoke_detector, co_detector, fire_extinguisher, first_aid, flashlight |
| location | text | | Specific location |
| brand | text | | Brand |
| model | text | | Model |
| install_date | date | | Installation date |
| expiry_date | date | | Expiration date |
| last_tested_date | date | | Last tested |
| last_tested_by_id | uuid | FK → team.team_directory | Who tested |
| battery_type | text | | Battery type |
| battery_last_changed | date | | Last battery change |
| certification | text | | Certification info |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### Property Configuration Tables

---

### 2.25 property.property_amenities

**PURPOSE:** Amenity flags per property.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| amenity_type_code | text | FK → ref.amenity_types, NOT NULL | Amenity type |
| is_available | boolean | DEFAULT true | Currently available? |
| quantity | integer | DEFAULT 1 | Quantity if applicable |
| location | text | | Where located |
| notes | text | | Amenity notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (property_id, amenity_type_code)

---

### 2.26 property.property_rules

**PURPOSE:** House rules per property.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| rule_category | text | NOT NULL | check_in, noise, parking, pool, pets, smoking, general |
| rule_text | text | NOT NULL | Rule text |
| is_enforceable | boolean | DEFAULT true | Strictly enforced? |
| violation_fee | numeric(10,2) | | Fee if violated |
| display_order | integer | DEFAULT 0 | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.27 property.property_access_codes

**PURPOSE:** Access codes for property entry.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| property_id | uuid | FK → properties, NOT NULL | Property reference |
| code_type | text | NOT NULL | door, gate, garage, lockbox, wifi, alarm |
| code_location | text | | Which door/gate |
| code_value | text | NOT NULL | The code |
| is_current | boolean | DEFAULT true | Currently valid? |
| effective_date | date | | When code starts |
| expiry_date | date | | When code expires |
| notes | text | | Code notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 2.28 property.recurring_tasks (NEW)

**PURPOSE:** Recurring maintenance task definitions for properties.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| task_id | text | NOT NULL, UNIQUE | Business ID: RCT-NNNNNN |
| property_id | uuid | FK → properties | Property (null = all) |
| task_name | text | NOT NULL | Task name |
| task_description | text | | Description |
| category_code | text | | Ticket category |
| frequency | text | NOT NULL | daily, weekly, monthly, quarterly, annual |
| frequency_interval | integer | DEFAULT 1 | Every N periods |
| day_of_week | integer | | 0-6 for weekly |
| day_of_month | integer | | 1-31 for monthly |
| month_of_year | integer | | 1-12 for annual |
| start_date | date | NOT NULL | When schedule starts |
| end_date | date | | When schedule ends |
| last_generated_date | date | | Last ticket generated |
| next_due_date | date | | Next due date |
| default_priority | text | DEFAULT 'MEDIUM' | Default priority |
| default_team_id | uuid | FK → team.teams | Default team |
| estimated_duration_minutes | integer | | Estimated time |
| checklist_template_id | uuid | | Checklist to use |
| knowledge_article_id | uuid | FK → knowledge.articles | SOP reference |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

## 3. RESERVATIONS Schema (11 tables)

**Purpose:** All reservation-related tables including guest journey tracking, reviews, fees, and journey/touchpoint configuration.

---

### 3.1 reservations.reservations

**PURPOSE:** Reservation master record.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| reservation_id | text | NOT NULL, UNIQUE | Business ID: RES-YYYY-NNNNNN |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| guest_id | uuid | FK → directory.guests | Primary guest |
| status | text | NOT NULL | pending, confirmed, checked_in, checked_out, cancelled, no_show |
| booking_source | text | NOT NULL | direct, airbnb, vrbo, booking, expedia |
| channel_reservation_id | text | | OTA confirmation number |
| check_in_date | date | NOT NULL | Check-in date |
| check_out_date | date | NOT NULL | Check-out date |
| nights | integer | GENERATED | Calculated nights |
| adults | integer | DEFAULT 2 | Adult count |
| children | integer | DEFAULT 0 | Child count |
| infants | integer | DEFAULT 0 | Infant count |
| pets | integer | DEFAULT 0 | Pet count |
| total_guests | integer | GENERATED | Total guest count |
| nightly_rate | numeric(10,2) | | Average nightly rate |
| accommodation_total | numeric(10,2) | | Room revenue |
| fees_total | numeric(10,2) | | Total fees |
| taxes_total | numeric(10,2) | | Total taxes |
| gross_total | numeric(10,2) | | Gross booking total |
| discount_total | numeric(10,2) | DEFAULT 0 | Discounts applied |
| refund_total | numeric(10,2) | DEFAULT 0 | Refunds issued |
| net_total | numeric(10,2) | | Net after discounts/refunds |
| deposit_amount | numeric(10,2) | | Security deposit |
| deposit_status | text | | held, released, partial_charge, charged |
| currency_code | text | DEFAULT 'USD' | Currency |
| booked_at | timestamptz | | When booked |
| confirmed_at | timestamptz | | When confirmed |
| cancelled_at | timestamptz | | When cancelled |
| cancellation_reason | text | | Why cancelled |
| actual_check_in_at | timestamptz | | Actual check-in time |
| actual_check_out_at | timestamptz | | Actual check-out time |
| early_check_in | boolean | DEFAULT false | Early check-in? |
| late_check_out | boolean | DEFAULT false | Late check-out? |
| special_requests | text | | Guest requests |
| internal_notes | text | | Internal notes |
| guest_notes | text | | Notes for guest |
| is_repeat_guest | boolean | DEFAULT false | Returning guest? |
| previous_reservation_id | uuid | FK → reservations | Previous stay |
| streamline_id | text | | Streamline reservation ID |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 3.2 reservations.guest_journeys

**PURPOSE:** Guest journey state tracking (1:1 with reservations).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| reservation_id | uuid | FK → reservations, NOT NULL, UNIQUE | Reservation reference |
| current_stage_id | uuid | FK → reservations.journey_stages | Current stage |
| previous_stage_id | uuid | FK → reservations.journey_stages | Previous stage |
| stage_entered_at | timestamptz | | When entered current stage |
| next_touchpoint_id | uuid | FK → reservations.touchpoints | Next expected touchpoint |
| next_touchpoint_due_at | timestamptz | | When next touchpoint due |
| journey_health | text | DEFAULT 'on_track' | on_track, at_risk, off_track |
| sentiment_score | numeric(3,2) | | Current sentiment (-1 to 1) |
| sentiment_trend | text | | improving, stable, declining |
| is_vip | boolean | DEFAULT false | VIP journey |
| vip_reason | text | | Why VIP |
| touchpoint_count | integer | DEFAULT 0 | Total touchpoints |
| issue_count | integer | DEFAULT 0 | Issues during journey |
| open_issues_count | integer | DEFAULT 0 | Unresolved issues |
| review_id | uuid | FK → reviews | Linked review |
| review_requested | boolean | DEFAULT false | Review requested? |
| review_requested_at | timestamptz | | When requested |
| notes | text | | Journey notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 3.3 reservations.guest_journey_touchpoints

**PURPOSE:** Event log of all guest interactions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| touchpoint_event_id | text | NOT NULL, UNIQUE | Business ID: TP-NNNNNNNN |
| journey_id | uuid | FK → guest_journeys, NOT NULL | Journey reference |
| touchpoint_id | uuid | FK → reservations.touchpoints, NOT NULL | Touchpoint reference |
| stage_id | uuid | FK → reservations.journey_stages | Stage at time of touchpoint |
| occurred_at | timestamptz | NOT NULL | When occurred |
| direction | text | NOT NULL | inbound, outbound |
| channel | text | NOT NULL | sms, email, phone, in_person, system |
| initiated_by | text | NOT NULL | guest, system, team |
| team_member_id | uuid | FK → team.team_directory | Team member involved |
| subject | text | | Touchpoint subject |
| summary | text | | Brief summary |
| sentiment | text | | positive, neutral, negative |
| sentiment_score | numeric(3,2) | | Sentiment score |
| linked_ticket_id | uuid | FK → service.tickets | Related ticket |
| linked_message_id | uuid | FK → comms.messages | Related message |
| outcome | text | | resolved, pending, escalated |
| follow_up_required | boolean | DEFAULT false | Needs follow-up? |
| follow_up_due_at | timestamptz | | When follow-up due |
| metadata | jsonb | | Additional data |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 3.4 reservations.reviews

**PURPOSE:** Guest reviews.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| review_id | text | NOT NULL, UNIQUE | Business ID: REV-NNNNNN |
| reservation_id | uuid | FK → reservations, NOT NULL | Reservation reference |
| journey_id | uuid | FK → guest_journeys | Journey reference |
| guest_id | uuid | FK → directory.guests, NOT NULL | Guest reference |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| clean_id | uuid | FK → property.cleans | Related clean |
| source | text | NOT NULL | internal, airbnb, vrbo, google, tripadvisor |
| external_review_id | text | | External review ID |
| overall_rating | integer | NOT NULL | 1-5 overall |
| cleanliness_rating | integer | | 1-5 cleanliness |
| communication_rating | integer | | 1-5 communication |
| check_in_rating | integer | | 1-5 check-in |
| accuracy_rating | integer | | 1-5 accuracy |
| location_rating | integer | | 1-5 location |
| value_rating | integer | | 1-5 value |
| review_text | text | | Review content |
| review_title | text | | Review title |
| guest_name_public | text | | Public guest name |
| is_anonymous | boolean | DEFAULT false | Anonymous review? |
| submitted_at | timestamptz | | When submitted |
| is_published | boolean | DEFAULT false | Published? |
| published_at | timestamptz | | When published |
| response_text | text | | Our response |
| responded_by_id | uuid | FK → team.team_directory | Who responded |
| responded_at | timestamptz | | When responded |
| sentiment | text | | positive, neutral, negative |
| key_themes | text[] | | Extracted themes |
| requires_follow_up | boolean | DEFAULT false | Needs follow-up? |
| follow_up_notes | text | | Follow-up notes |
| is_featured | boolean | DEFAULT false | Featured review? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 3.5 reservations.reservation_fees

**PURPOSE:** Fees charged on reservations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| reservation_id | uuid | FK → reservations, NOT NULL | Reservation reference |
| fee_type_id | uuid | FK → ref.fee_types, NOT NULL | Fee type |
| fee_name | text | NOT NULL | Fee name |
| amount | numeric(10,2) | NOT NULL | Fee amount |
| quantity | integer | DEFAULT 1 | Quantity |
| total_amount | numeric(10,2) | GENERATED | amount * quantity |
| is_taxable | boolean | DEFAULT false | Taxable? |
| tax_amount | numeric(10,2) | | Tax on fee |
| is_refundable | boolean | DEFAULT true | Refundable? |
| is_optional | boolean | DEFAULT false | Optional fee? |
| added_by_id | uuid | FK → team.team_directory | Who added |
| added_at | timestamptz | DEFAULT now() | When added |
| waived | boolean | DEFAULT false | Waived? |
| waived_by_id | uuid | FK → team.team_directory | Who waived |
| waived_at | timestamptz | | When waived |
| waived_reason | text | | Why waived |
| notes | text | | Fee notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 3.6 reservations.reservation_guests

**PURPOSE:** Additional guests on a reservation.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| reservation_id | uuid | FK → reservations, NOT NULL | Reservation reference |
| guest_id | uuid | FK → directory.guests | Guest reference |
| guest_type | text | NOT NULL | adult, child, infant |
| first_name | text | | First name |
| last_name | text | | Last name |
| age | integer | | Age at stay |
| is_primary | boolean | DEFAULT false | Primary guest? |
| notes | text | | Guest notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 3.7 reservations.reservation_financials

**PURPOSE:** Financial summary per reservation.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| reservation_id | uuid | FK → reservations, NOT NULL, UNIQUE | Reservation reference |
| accommodation_revenue | numeric(10,2) | DEFAULT 0 | Room revenue |
| cleaning_fee | numeric(10,2) | DEFAULT 0 | Cleaning fee |
| resort_fee | numeric(10,2) | DEFAULT 0 | Resort fee |
| other_fees | numeric(10,2) | DEFAULT 0 | Other fees |
| taxes | numeric(10,2) | DEFAULT 0 | Total taxes |
| gross_revenue | numeric(10,2) | DEFAULT 0 | Gross total |
| discounts | numeric(10,2) | DEFAULT 0 | Discounts |
| refunds | numeric(10,2) | DEFAULT 0 | Refunds |
| net_revenue | numeric(10,2) | DEFAULT 0 | Net revenue |
| commission | numeric(10,2) | DEFAULT 0 | Our commission |
| owner_payout | numeric(10,2) | DEFAULT 0 | Owner payout |
| channel_commission | numeric(10,2) | DEFAULT 0 | OTA commission |
| payment_processing_fee | numeric(10,2) | DEFAULT 0 | CC fees |
| damage_deposit_held | numeric(10,2) | DEFAULT 0 | Deposit held |
| damage_charges | numeric(10,2) | DEFAULT 0 | Damage charges |
| calculated_at | timestamptz | | Last calculated |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 3.8 reservations.damage_claims_legacy

**PURPOSE:** Legacy damage documentation (deprecated - use service.damage_claims).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| reservation_id | uuid | FK → reservations, NOT NULL | Reservation reference |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| description | text | | Damage description |
| estimated_cost | numeric(10,2) | | Estimated cost |
| actual_cost | numeric(10,2) | | Actual cost |
| recovered_amount | numeric(10,2) | DEFAULT 0 | Amount recovered |
| status | text | | open, submitted, paid, denied, written_off |
| notes | text | | Notes |
| migrated_to_claim_id | uuid | | New claim ID if migrated |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 3.9 reservations.journey_stages

**PURPOSE:** Guest journey stage definitions. Moved from ref schema for domain cohesion.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| stage_code | text | NOT NULL, UNIQUE | Stage code |
| stage_name | text | NOT NULL | Display name |
| stage_description | text | | Description |
| stage_order | integer | NOT NULL | Sequence |
| typical_duration_hours | integer | | Duration |
| is_terminal | boolean | DEFAULT false | End state? |
| next_stage_id | uuid | FK → journey_stages | Default next stage |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Example Stages:** inquiry, booked, pre_arrival, checked_in, mid_stay, checkout_day, post_stay, review_phase

---

### 3.10 reservations.touchpoints

**PURPOSE:** Guest touchpoint definitions. Renamed from ref.touchpoint_types for clarity.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| touchpoint_code | text | NOT NULL, UNIQUE | Touchpoint code |
| touchpoint_name | text | NOT NULL | Display name |
| description | text | | Description |
| channel | text | | sms, email, phone, system |
| direction | text | | inbound, outbound |
| is_automated | boolean | DEFAULT false | System generated? |
| template_id | uuid | FK → comms.templates | Message template |
| sort_order | integer | DEFAULT 0 | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Example Touchpoints:** booking_confirmation, pre_arrival_info, check_in_instructions, mid_stay_check, checkout_reminder, review_request

---

### 3.11 reservations.stage_touchpoints

**PURPOSE:** Junction table linking stages to required touchpoints. Renamed from ref.stage_required_touchpoints.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| stage_id | uuid | FK → journey_stages, NOT NULL | Stage reference |
| touchpoint_id | uuid | FK → touchpoints, NOT NULL | Touchpoint reference |
| is_required | boolean | DEFAULT true | Required? |
| timing_rule | text | | When to trigger |
| timing_offset_hours | integer | | Hours before/after |
| sort_order | integer | DEFAULT 0 | Order in stage |

**Unique Constraint:** (stage_id, touchpoint_id)

---

## 4. SERVICE Schema (30 tables)

**Purpose:** Unified ticketing, projects, and damage claim lifecycle. Based on Service System Final Specification v4.

---

### 4.1 service.tickets

**PURPOSE:** Unified ticket table for all ticket types (PC, RSV, ADM, ACCT).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | text | NOT NULL, UNIQUE | Business ID: TIK-{TYPE}-NNNNNN |
| ticket_type_code | text | NOT NULL | PC, RSV, ADM, ACCT |
| category_code | text | NOT NULL | Compound: PC-PLUMBING, RSV-LATE_CHECKOUT |
| title | text | NOT NULL | Ticket name/subject |
| description | text | | Main description |
| work_notes | text | | Internal work notes |
| guest_comments | text | | Guest-facing comments |
| status | text | NOT NULL DEFAULT 'OPEN' | OPEN, IN_PROGRESS, ON_HOLD, RESOLVED, CANCELLED |
| priority | text | NOT NULL DEFAULT 'MEDIUM' | LOW, MEDIUM, HIGH, CRITICAL |
| source | text | | OWNER, GUEST, INTERNAL, SYSTEM, INSPECTION |
| property_id | uuid | FK → property.properties | Primary property |
| reservation_id | uuid | FK → reservations.reservations | Related reservation |
| homeowner_id | uuid | FK → directory.homeowners | Primary owner |
| requestor_contact_id | uuid | FK → directory.contacts | Who requested |
| current_agent_id | uuid | FK → team.team_directory | Assigned agent |
| current_team_id | uuid | FK → team.teams | Assigned team |
| scheduled_date | date | | When work should happen |
| first_response_at | timestamptz | | First response time |
| started_at | timestamptz | | When work began |
| resolved_at | timestamptz | | When resolved |
| is_archived | boolean | DEFAULT false | Soft delete |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Type Rules:**
- PC: property_id required
- RSV: reservation_id required
- ADM/ACCT: property_id optional

---

### 4.2 service.ticket_time_entries

**PURPOSE:** Allocate time entries to tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| time_entry_id | uuid | FK → team.time_entries, NOT NULL | Time entry reference |
| allocated_seconds | integer | NOT NULL | Seconds allocated |
| allocation_percentage | numeric(5,2) | | Percentage of entry |
| role | text | | onsite, remote, travel, reporting |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.3 service.inspection_time_entries

**PURPOSE:** Allocate time entries to inspections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| inspection_id | uuid | FK → property.inspections, NOT NULL | Inspection reference |
| time_entry_id | uuid | FK → team.time_entries, NOT NULL | Time entry reference |
| allocated_seconds | integer | NOT NULL | Seconds allocated |
| role | text | | inspection, followup, report |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.4 service.ticket_properties

**PURPOSE:** Link tickets to properties.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| resort_id | uuid | FK → property.resorts | Resort snapshot |
| address_snapshot | text | | Address at creation |
| role | text | DEFAULT 'PRIMARY' | PRIMARY, SECONDARY, AFFECTED |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.5 service.ticket_reservations

**PURPOSE:** Link tickets to reservations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| reservation_id | uuid | FK → reservations.reservations, NOT NULL | Reservation reference |
| reservation_number | text | | Res # snapshot |
| guest_name_snapshot | text | | Guest name snapshot |
| check_in_date | date | | Check-in snapshot |
| check_out_date | date | | Check-out snapshot |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.6 service.ticket_homeowners

**PURPOSE:** Link tickets to homeowners with billing info.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| homeowner_id | uuid | FK → directory.homeowners, NOT NULL | Homeowner reference |
| role | text | DEFAULT 'PRIMARY' | PRIMARY, CC, ESCALATION |
| is_requestor | boolean | DEFAULT false | Did they request? |
| is_billable | boolean | DEFAULT false | Bill them? |
| billing_notes | text | | Billing instructions |
| communication_notes | text | | Communication prefs |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.7 service.ticket_relationships

**PURPOSE:** Related tickets (self-reference).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Source ticket |
| related_ticket_id | uuid | FK → tickets, NOT NULL | Related ticket |
| relationship_type | text | NOT NULL | parent, child, related, duplicate, follow_up |
| notes | text | | Relationship notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.8 service.ticket_shifts

**PURPOSE:** Assign tickets to shifts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| shift_id | uuid | FK → team.shifts, NOT NULL | Shift reference |
| shift_agent_id | uuid | FK → team.team_directory | Agent on shift |
| shift_date | date | | Shift date |
| role | text | DEFAULT 'PRIMARY' | PRIMARY, BACKUP, REVIEWER |
| assignment_notes | text | | Assignment notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 4.9 service.ticket_contacts

**PURPOSE:** People involved with tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| contact_id | uuid | FK → directory.contacts | External contact |
| team_member_id | uuid | FK → team.team_directory | Internal team member |
| homeowner_id | uuid | FK → directory.homeowners | If homeowner |
| guest_id | uuid | FK → directory.guests | If guest |
| role | text | NOT NULL | requestor, resolved_by, escalated_to, guest, homeowner, vendor_contact |
| notify | boolean | DEFAULT false | Send notifications? |
| assigned_at | timestamptz | | When assigned |
| completed_at | timestamptz | | When completed role |
| notes | text | | Role notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.10 service.ticket_vendors

**PURPOSE:** Vendor services on tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| vendor_id | uuid | FK → directory.companies, NOT NULL | Vendor company |
| vendor_contact_id | uuid | FK → directory.contacts | Vendor contact |
| role | text | DEFAULT 'PRIMARY' | PRIMARY, SECONDARY, QUOTE_ONLY |
| vendor_category | text | | Service category |
| vendor_type | text | | Third Party, Preferred, Emergency |
| scheduled_date | date | | When scheduled |
| actual_date | date | | When completed |
| status | text | DEFAULT 'Scheduled' | Scheduled, Confirmed, Completed, Cancelled |
| cost_estimate | numeric(10,2) | | Quoted cost |
| actual_cost | numeric(10,2) | | Final cost |
| invoice_number | text | | Invoice reference |
| internal_score | integer | | 1-5 rating |
| score_notes | text | | Rating notes |
| notes | text | | Vendor notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 4.11 service.ticket_misses

**PURPOSE:** Track missed service dates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| scheduled_date | date | NOT NULL | Date missed |
| miss_date | date | NOT NULL | When recorded |
| shift_id | uuid | FK → team.shifts | Shift that missed |
| member_id | uuid | FK → team.team_directory | Member responsible |
| miss_reason_code | text | | NO_SHOW, SCHEDULING_ERROR, ACCESS_ISSUE |
| rescheduled_date | date | | New date |
| notes | text | | Miss notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.12 service.ticket_costs

**PURPOSE:** Cost allocations on tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| cost_type | text | NOT NULL | labor, supplies, parts, vendor_service, adjustment |
| description | text | | Cost description |
| amount | numeric(10,2) | NOT NULL | Dollar amount |
| quantity | numeric(10,2) | | Quantity |
| unit_cost | numeric(10,2) | | Per-unit cost |
| allocation | text | DEFAULT 'company' | owner, company, guest, split |
| allocation_percentage | numeric(5,2) | | If split |
| homeowner_id | uuid | FK → directory.homeowners | If owner allocated |
| vendor_id | uuid | FK → directory.companies | If vendor cost |
| purchase_id | uuid | FK → ticket_purchases | Purchase reference |
| time_entry_id | uuid | FK → team.time_entries | Time reference |
| transaction_id | uuid | FK → finance.transactions | Finance reference |
| is_posted | boolean | DEFAULT false | Posted to accounting? |
| notes | text | | Cost notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.13 service.ticket_purchases

**PURPOSE:** Purchase orders for tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| supplier_id | uuid | FK → directory.companies | Supplier |
| brand_manufacturer | text | | Brand |
| order_platform | text | | Amazon, Home Depot, etc. |
| order_number | text | | Order number |
| order_date | date | | When ordered |
| expected_delivery_date | date | | Expected delivery |
| actual_delivery_date | date | | Actual delivery |
| shipping_carrier | text | | Carrier |
| tracking_number | text | | Tracking |
| item_description | text | | What ordered |
| quantity | integer | DEFAULT 1 | How many |
| unit_cost | numeric(10,2) | | Per unit |
| total_cost | numeric(10,2) | | Total |
| receipt_file_id | uuid | FK → storage.files | Receipt |
| status | text | DEFAULT 'Ordered' | Ordered, Shipped, Delivered, Returned |
| notes | text | | Purchase notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.14 service.ticket_events

**PURPOSE:** Activity log for tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| event_id | text | NOT NULL, UNIQUE | Business ID: EVT-NNNNNNNN |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| event_type | text | NOT NULL | STATUS_CHANGE, ASSIGNED, COMMENT, FIELD_UPDATE, SYSTEM |
| event_subtype | text | | More specific type |
| actor_member_id | uuid | FK → team.team_directory | Team member actor |
| actor_contact_id | uuid | FK → directory.contacts | External actor |
| field_name | text | | Field changed |
| old_value | text | | Previous value |
| new_value | text | | New value |
| old_status | text | | For status changes |
| new_status | text | | For status changes |
| old_assignee_id | uuid | FK → team.team_directory | Previous assignee |
| new_assignee_id | uuid | FK → team.team_directory | New assignee |
| comment_body | text | | Comment content |
| is_internal | boolean | DEFAULT true | Internal only? |
| is_automated | boolean | DEFAULT false | System generated? |
| automation_source | text | | Which system |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.15 service.ticket_labels

**PURPOSE:** Tags on tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| label_id | uuid | FK → ref.label_key | Label reference |
| freeform_label | text | | Custom label |
| applied_by_id | uuid | FK → team.team_directory | Who applied |
| applied_at | timestamptz | DEFAULT now() | When applied |
| removed_at | timestamptz | | When removed |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (ticket_id, label_id) WHERE removed_at IS NULL

---

### 4.16 service.ticket_inspections

**PURPOSE:** Link tickets to inspections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| inspection_id | uuid | FK → property.inspections, NOT NULL | Inspection reference |
| relationship | text | NOT NULL | ROOT_CAUSE, FOLLOWUP, FOUND_BY, VERIFICATION |
| notes | text | | Link notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.17 service.ticket_cleans

**PURPOSE:** Link tickets to cleans.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| clean_id | uuid | FK → property.cleans, NOT NULL | Clean reference |
| relationship | text | NOT NULL | FOUND_DURING_CLEAN, CAUSED_RECLEAN, VERIFIED_BY_CLEAN |
| notes | text | | Link notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.18 service.ticket_inventory_events

**PURPOSE:** Link tickets to inventory events.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| inventory_event_id | uuid | FK → inventory.inventory_events, NOT NULL | Inventory event |
| quantity | integer | | Quantity affected |
| notes | text | | Link notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.19 service.ticket_recurring

**PURPOSE:** Link tickets to recurring tasks.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| recurring_task_id | uuid | FK → property.recurring_tasks | Recurring task |
| scheduled_date | date | | Instance due date |
| knowledge_article_id | uuid | FK → knowledge.articles | SOP reference |
| checklist_template_id | uuid | | Checklist template |
| is_on_schedule | boolean | | Completed on time? |
| notes | text | | Instance notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.20 service.ticket_transactions

**PURPOSE:** Link tickets to finance transactions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| transaction_id | uuid | FK → finance.transactions, NOT NULL | Transaction reference |
| role | text | NOT NULL | EXPENSE, OWNER_CHARGE, ADJUSTMENT, REFUND, CLAIM_RECOVERY |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### Projects (4.21-4.23)

---

### 4.21 service.projects

**PURPOSE:** Project/initiative management.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| project_id | text | NOT NULL, UNIQUE | Business ID: PRJ-NNNNNN |
| project_name | text | NOT NULL | Project name |
| project_description | text | | Description |
| project_type | text | | LISTING_UPDATE, INVENTORY_ROLLOUT, POLICY_CHANGE |
| scope_type | text | | PROPERTY, RESORT, PORTFOLIO, GLOBAL |
| resort_id | uuid | FK → property.resorts | Resort scope |
| status | text | DEFAULT 'DRAFT' | DRAFT, ACTIVE, PAUSED, COMPLETED, CANCELLED |
| priority | text | DEFAULT 'MEDIUM' | LOW, MEDIUM, HIGH, CRITICAL |
| target_start_date | date | | Target start |
| target_end_date | date | | Target end |
| actual_start_date | date | | Actual start |
| actual_end_date | date | | Actual end |
| owner_member_id | uuid | FK → team.team_directory | Project owner |
| notes | text | | Project notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 4.22 service.project_properties

**PURPOSE:** Per-property project checklist.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| project_id | uuid | FK → projects, NOT NULL | Project reference |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| resort_id | uuid | FK → property.resorts | Resort reference |
| status | text | DEFAULT 'PENDING' | PENDING, IN_PROGRESS, DONE, SKIPPED, BLOCKED |
| assigned_member_id | uuid | FK → team.team_directory | Assignee |
| assigned_at | timestamptz | | When assigned |
| started_at | timestamptz | | When started |
| completed_at | timestamptz | | When completed |
| notes | text | | Property notes |
| skip_reason | text | | If skipped |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (project_id, property_id)

---

### 4.23 service.project_tickets

**PURPOSE:** Link tickets to projects.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| project_id | uuid | FK → projects, NOT NULL | Project reference |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| property_id | uuid | FK → property.properties | Property for this ticket |
| role | text | DEFAULT 'PRIMARY' | PRIMARY, SUBTASK, FOLLOWUP |
| sequence_order | integer | | Order in project |
| is_required | boolean | DEFAULT true | Required for completion? |
| notes | text | | Link notes |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (project_id, ticket_id)

---

### Damage Claims (4.24-4.30)

---

### 4.24 service.ticket_damage

**PURPOSE:** Flag damage on tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| damage_category_code | text | FK → ref.damage_category_key | Damage category |
| description | text | | Damage description |
| estimated_cost | numeric(10,2) | | Cost estimate |
| discovered_at | timestamptz | | When discovered |
| discovered_by_id | uuid | FK → team.team_directory | Who discovered |
| damage_claim_id | uuid | FK → damage_claims | Linked claim |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.25 service.ticket_claims

**PURPOSE:** Link tickets to damage claims.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → tickets, NOT NULL | Ticket reference |
| damage_claim_id | uuid | FK → damage_claims, NOT NULL | Claim reference |
| allocated_cost | numeric(10,2) | | Cost from this ticket |
| is_recovery_blocking | boolean | DEFAULT false | Blocks claim? |
| link_type | text | | repair, replacement, assessment |
| notes | text | | Link notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 4.26 service.damage_claims

**PURPOSE:** Damage claim master.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| claim_id | text | NOT NULL, UNIQUE | Business ID: CLM-NNNNNN |
| ticket_id | uuid | FK → tickets | Origin ticket |
| reservation_id | uuid | FK → reservations.reservations | Reservation |
| damage_category_code | text | FK → ref.damage_category_key | Category |
| incident_date | date | | When occurred |
| discovery_source | text | | INSPECTION, CLEAN, GUEST, OWNER |
| status_code | text | DEFAULT 'OPEN' | OPEN, SUBMITTED, PARTIAL, CLOSED, DENIED |
| priority | text | DEFAULT 'MEDIUM' | LOW, MEDIUM, HIGH, URGENT |
| claim_name | text | | Short description |
| description | text | | Full description |
| work_notes | text | | Internal notes |
| discovered_by_id | uuid | FK → team.team_directory | Who found |
| claim_owner_id | uuid | FK → team.team_directory | Who manages |
| total_damage_cost | numeric(10,2) | DEFAULT 0 | Full damage cost |
| total_recovered | numeric(10,2) | DEFAULT 0 | Total recovered |
| total_denied | numeric(10,2) | DEFAULT 0 | Total denied |
| outstanding | numeric(10,2) | DEFAULT 0 | Still owed |
| responsible_party | text | | GUEST, OWNER, COMPANY, OTA, WRITTEN_OFF |
| homeowner_charged | boolean | DEFAULT false | Owner charged? |
| homeowner_charge_date | date | | When charged |
| homeowner_charge_amount | numeric(10,2) | | Amount charged |
| discovery_date | date | | When found |
| resolved_at | timestamptz | | When resolved |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 4.27 service.damage_claim_submissions

**PURPOSE:** Recovery attempt submissions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| submission_id | text | NOT NULL, UNIQUE | Business ID: SUB-{claim}-NN |
| damage_claim_id | uuid | FK → damage_claims, NOT NULL | Claim reference |
| submission_number | integer | NOT NULL | Sequence number |
| submission_type_code | text | FK → ref.claim_submission_type_key | Submission type |
| submitted_to_company_id | uuid | FK → directory.companies | Submitted to |
| submitted_to_contact_id | uuid | FK → directory.contacts | Contact there |
| external_claim_number | text | | Their reference |
| submitted_by_id | uuid | FK → team.team_directory | Who submitted |
| submission_deadline | date | | Deadline |
| submitted_at | timestamptz | | When submitted |
| response_due_at | date | | Expected response |
| response_at | timestamptz | | When responded |
| amount_requested | numeric(10,2) | | What we asked |
| amount_approved | numeric(10,2) | DEFAULT 0 | Approved amount |
| amount_denied | numeric(10,2) | DEFAULT 0 | Denied amount |
| amount_received | numeric(10,2) | DEFAULT 0 | Received amount |
| status_code | text | DEFAULT 'DRAFT' | DRAFT, SUBMITTED, PENDING, APPROVED, DENIED |
| outcome | text | | FULL_APPROVAL, PARTIAL_APPROVAL, FULL_DENIAL |
| notes | text | | Submission notes |
| lessons_learned | text | | What to do better |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (damage_claim_id, submission_number)

---

### 4.28 service.damage_claim_approvals

**PURPOSE:** Approval records for claims.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| approval_id | text | NOT NULL, UNIQUE | Business ID: APV-{sub}-NN |
| damage_claim_id | uuid | FK → damage_claims, NOT NULL | Claim reference |
| submission_id | uuid | FK → damage_claim_submissions, NOT NULL | Submission reference |
| approval_number | integer | NOT NULL | Sequence |
| item_description | text | | What was approved |
| amount_claimed | numeric(10,2) | | What we asked |
| amount_approved | numeric(10,2) | | What approved |
| is_partial | boolean | DEFAULT false | Less than claimed? |
| variance_reason | text | | Why different |
| expected_payment_date | date | | When expected |
| payment_method | text | | CHECK, ACH, CREDIT |
| payment_terms | text | | Conditions |
| transaction_id | uuid | FK → finance.transactions | Payment record |
| amount_received | numeric(10,2) | | Actual received |
| payment_date | date | | When received |
| payment_reference | text | | Check #, etc. |
| is_reconciled | boolean | DEFAULT false | Payment matched? |
| reconciliation_variance | numeric(10,2) | | Difference |
| reconciliation_notes | text | | Variance explanation |
| approved_at | timestamptz | | When approved |
| notes | text | | Approval notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (submission_id, approval_number)

---

### 4.29 service.damage_claim_denials

**PURPOSE:** Denial records for claims.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| denial_id | text | NOT NULL, UNIQUE | Business ID: DNL-{sub}-NN |
| damage_claim_id | uuid | FK → damage_claims, NOT NULL | Claim reference |
| submission_id | uuid | FK → damage_claim_submissions, NOT NULL | Submission reference |
| denial_number | integer | NOT NULL | Sequence |
| item_description | text | | What was denied |
| amount_denied | numeric(10,2) | | Amount denied |
| denial_code | text | | Their code |
| denial_reason | text | | Why denied |
| denial_letter_file_id | uuid | FK → storage.files | Their letter |
| preventable | boolean | | Could prevent? |
| prevention_notes | text | | How to prevent |
| denied_at | timestamptz | | When denied |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (submission_id, denial_number)

---

### 4.30 service.damage_claim_appeals

**PURPOSE:** Appeal records for denied claims.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| appeal_id | text | NOT NULL, UNIQUE | Business ID: APL-{sub}-NN |
| damage_claim_id | uuid | FK → damage_claims, NOT NULL | Claim reference |
| submission_id | uuid | FK → damage_claim_submissions, NOT NULL | Submission reference |
| denial_id | uuid | FK → damage_claim_denials | Denial appealed |
| appeal_number | integer | NOT NULL | Sequence |
| appeal_submitted_at | timestamptz | | When submitted |
| appeal_reason | text | | Why appealing |
| appeal_status_code | text | DEFAULT 'PENDING' | PENDING, UPHELD, OVERTURNED, PARTIAL |
| is_partial | boolean | DEFAULT false | Partial success? |
| outcome_notes | text | | Their response |
| additional_recovered | numeric(10,2) | | Extra recovered |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (submission_id, appeal_number)

---

# PART 2: TEAM, STORAGE, INVENTORY, REF SCHEMAS

---

## 5. TEAM Schema (6 tables)

**Purpose:** People, scheduling, and labor tracking.

---

### 5.1 team.teams

**PURPOSE:** Team/department definitions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| team_id | text | NOT NULL, UNIQUE | Business ID: TEAM-NNNN |
| name | text | NOT NULL | Team name |
| description | text | | Description |
| manager_id | uuid | FK → team_directory | Team manager |
| parent_team_id | uuid | FK → teams | Parent team |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 5.2 team.team_directory

**PURPOSE:** Team member records.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| member_id | text | NOT NULL, UNIQUE | Business ID: MBR-NNNNNN |
| contact_id | uuid | FK → directory.contacts, NOT NULL | Contact reference |
| team_id | uuid | FK → teams | Primary team |
| manager_id | uuid | FK → team_directory | Direct manager |
| role | text | | Job title/role |
| department | text | | Department |
| employment_type | text | DEFAULT 'employee' | employee, contractor, intern |
| hourly_rate | numeric(10,2) | | Hourly rate |
| salary | numeric(12,2) | | Annual salary |
| hire_date | date | | Hire date |
| termination_date | date | | If terminated |
| termination_reason | text | | Why terminated |
| can_approve_expenses | boolean | DEFAULT false | Expense approval |
| expense_limit | numeric(10,2) | | Approval limit |
| skills | text[] | | Skills list |
| certifications | text[] | | Certifications |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 5.3 team.shifts

**PURPOSE:** Shift scheduling.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| shift_id | text | NOT NULL, UNIQUE | Business ID: SHFT-NNNNNN |
| member_id | uuid | FK → team_directory, NOT NULL | Team member |
| shift_date | date | NOT NULL | Shift date |
| starts_at | timestamptz | NOT NULL | Start time |
| ends_at | timestamptz | NOT NULL | End time |
| scheduled_hours | numeric(5,2) | | Planned hours |
| actual_hours | numeric(5,2) | | Actual hours |
| status | text | DEFAULT 'SCHEDULED' | SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED, NO_SHOW |
| shift_type | text | | regular, overtime, on_call |
| notes | text | | Shift notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 5.4 team.time_entries

**PURPOSE:** Time tracking records.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| time_entry_id | text | NOT NULL, UNIQUE | Business ID: TIME-NNNNNNNN |
| member_id | uuid | FK → team_directory, NOT NULL | Team member |
| property_id | uuid | FK → property.properties | Where worked |
| work_date | date | NOT NULL | Date of work |
| started_at | timestamptz | | Start time |
| ended_at | timestamptz | | End time |
| duration_seconds | integer | | Total duration |
| activity_type_code | text | FK → ref.activity_types | Activity type |
| hourly_rate | numeric(10,2) | | Rate at work time |
| labor_cost | numeric(10,2) | | Calculated cost |
| is_billable | boolean | DEFAULT false | Billable? |
| billable_to | text | | owner, company, guest |
| timesheet_status | text | DEFAULT 'START' | START, STOP, VERIFY, APPROVED, RECORDED |
| requires_verification | boolean | DEFAULT false | Needs verify? |
| notes | text | | Work notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 5.5 team.time_entry_verifications

**PURPOSE:** Time entry verification history.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| time_entry_id | uuid | FK → time_entries, NOT NULL | Time entry |
| verification_number | integer | NOT NULL | Sequence |
| verification_status | text | NOT NULL | PENDING, VERIFIED, REJECTED, ADJUSTED |
| verified_by_id | uuid | FK → team_directory | Verifier |
| verified_at | timestamptz | | When verified |
| original_duration_seconds | integer | | Before adjustment |
| adjusted_duration_seconds | integer | | After adjustment |
| adjustment_reason | text | | Why adjusted |
| notes | text | | Verification notes |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (time_entry_id, verification_number)

---

### 5.6 team.shift_time_entries

**PURPOSE:** HR allocation of time to shifts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| shift_id | uuid | FK → shifts, NOT NULL | Shift reference |
| time_entry_id | uuid | FK → time_entries, NOT NULL | Time entry |
| allocated_seconds | integer | NOT NULL | Seconds allocated |
| notes | text | | Allocation notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

## 6. STORAGE Schema (4 tables)

**Purpose:** Central file management with context joins.

---

### 6.1 storage.files

**PURPOSE:** Central file registry.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| file_id | text | NOT NULL, UNIQUE | Business ID: FILE-NNNNNNNN |
| file_url | text | NOT NULL | Storage URL |
| thumbnail_url | text | | Thumbnail URL |
| file_type | text | NOT NULL | image, document, video, audio |
| mime_type | text | | MIME type |
| file_size_bytes | integer | | File size |
| original_filename | text | | Original name |
| property_id | uuid | FK → property.properties | Property context |
| room_id | uuid | FK → property.rooms | Room context |
| uploaded_by_id | uuid | FK → team.team_directory | Uploader |
| uploaded_at | timestamptz | DEFAULT now() | Upload time |
| description | text | | File description |
| tags | text[] | | Tags |
| is_archived | boolean | DEFAULT false | Archived? |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 6.2 storage.ticket_files

**PURPOSE:** Link files to tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| ticket_id | uuid | FK → service.tickets, NOT NULL | Ticket reference |
| file_id | uuid | FK → files, NOT NULL | File reference |
| context_type | text | | before, after, damage, receipt, completion |
| caption | text | | Description |
| is_owner_visible | boolean | DEFAULT false | Show to owner? |
| is_guest_visible | boolean | DEFAULT false | Show to guest? |
| sort_order | integer | DEFAULT 0 | Display order |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 6.3 storage.inspection_files

**PURPOSE:** Link files to inspections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| inspection_id | uuid | FK → property.inspections, NOT NULL | Inspection reference |
| file_id | uuid | FK → files, NOT NULL | File reference |
| context_type | text | | issue, room, completion, checklist_item |
| room_id | uuid | FK → property.rooms | Room context |
| caption | text | | Description |
| sort_order | integer | DEFAULT 0 | Display order |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 6.4 storage.room_files

**PURPOSE:** Link files to rooms (reference photos).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| room_id | uuid | FK → property.rooms, NOT NULL | Room reference |
| file_id | uuid | FK → files, NOT NULL | File reference |
| context_type | text | | reference, current, issue |
| is_reference | boolean | DEFAULT false | Baseline reference? |
| caption | text | | Description |
| sort_order | integer | DEFAULT 0 | Display order |
| created_at | timestamptz | DEFAULT now() | Record created |

---

## 7. INVENTORY Schema (15 tables)

**Purpose:** Inventory tracking across rooms, owners, company assets, and warehouse storage.

---

### 7.1 inventory.inventory_items

**PURPOSE:** Universal product catalog for all inventory types.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| item_id | text | NOT NULL, UNIQUE | Business ID: ITEM-NNNNNN |
| item_type_code | text | FK → ref.inventory_item_types | Item type |
| sku | text | | SKU code |
| upc | text | | UPC barcode |
| item_name | text | NOT NULL | Item name |
| item_description | text | | Description |
| category | text | | linen, kitchen, bathroom, cleaning, electronics |
| subcategory | text | | Subcategory |
| brand | text | | Brand |
| model | text | | Model |
| color | text | | Color |
| size | text | | Size |
| unit_of_measure | text | DEFAULT 'each' | each, set, pack |
| standard_cost | numeric(10,2) | | Standard cost |
| replacement_cost | numeric(10,2) | | Replacement cost |
| preferred_supplier_id | uuid | FK → directory.companies | Preferred supplier |
| reorder_point | integer | | When to reorder |
| reorder_quantity | integer | | How much to order |
| lead_time_days | integer | | Supplier lead time |
| is_trackable | boolean | DEFAULT true | Track individually? |
| is_consumable | boolean | DEFAULT false | Consumable item? |
| replacement_item_id | uuid | FK → inventory_items | Replacement item |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 7.2 inventory.room_inventory

**PURPOSE:** Guest room item tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| room_id | uuid | FK → property.rooms, NOT NULL | Room reference |
| item_id | uuid | FK → inventory_items, NOT NULL | Item reference |
| par_quantity | integer | NOT NULL | Target quantity |
| current_quantity | integer | NOT NULL | Current count |
| last_count_at | timestamptz | | Last counted |
| last_counted_by_id | uuid | FK → team.team_directory | Who counted |
| last_inspection_id | uuid | FK → property.inspections | Last inspection |
| location_detail | text | | Where in room |
| condition | text | DEFAULT 'good' | excellent, good, fair, poor |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (room_id, item_id)

---

### 7.3 inventory.owner_inventory

**PURPOSE:** Owner personal property tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| homeowner_id | uuid | FK → directory.homeowners, NOT NULL | Owner reference |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| item_id | uuid | FK → inventory_items | Catalog item (if exists) |
| custom_item_name | text | | Custom item name |
| description | text | | Description |
| quantity | integer | DEFAULT 1 | Quantity |
| estimated_value | numeric(10,2) | | Estimated value |
| purchase_date | date | | When purchased |
| location | text | | Where stored |
| is_restricted | boolean | DEFAULT false | Guest can't use? |
| restriction_notes | text | | Usage restrictions |
| photo_file_ids | uuid[] | | Photo references |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Still present? |
| removed_date | date | | If removed |
| removed_reason | text | | Why removed |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 7.4 inventory.company_inventory

**PURPOSE:** Company equipment and assets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| asset_id | text | NOT NULL, UNIQUE | Business ID: AST-NNNNNN |
| item_id | uuid | FK → inventory_items, NOT NULL | Item reference |
| serial_number | text | | Serial number |
| asset_tag | text | | Asset tag |
| assigned_to_id | uuid | FK → team.team_directory | Assigned to |
| assigned_property_id | uuid | FK → property.properties | At property |
| storage_location_id | uuid | FK → storage_locations | In warehouse |
| status | text | DEFAULT 'available' | available, in_use, maintenance, retired |
| condition | text | DEFAULT 'good' | excellent, good, fair, poor |
| purchase_date | date | | When purchased |
| purchase_price | numeric(10,2) | | Purchase price |
| warranty_expiry | date | | Warranty end |
| last_service_date | date | | Last serviced |
| next_service_date | date | | Next service |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Active flag |
| retired_date | date | | If retired |
| retired_reason | text | | Why retired |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 7.5 inventory.storage_inventory

**PURPOSE:** Warehouse bulk stock tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| item_id | uuid | FK → inventory_items, NOT NULL | Item reference |
| location_id | uuid | FK → storage_locations, NOT NULL | Storage location |
| quantity | integer | NOT NULL | Current quantity |
| lot_number | text | | Lot number |
| expiry_date | date | | If applicable |
| last_count_at | timestamptz | | Last counted |
| last_counted_by_id | uuid | FK → team.team_directory | Who counted |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (item_id, location_id, lot_number)

---

### 7.6 inventory.storage_locations

**PURPOSE:** Warehouse location hierarchy.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| location_id | text | NOT NULL, UNIQUE | Business ID: LOC-NNNNNN |
| location_name | text | NOT NULL | Location name |
| location_type | text | NOT NULL | warehouse, shelf, bin, zone |
| parent_location_id | uuid | FK → storage_locations | Parent location |
| address | text | | Physical address |
| capacity | integer | | Max capacity |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 7.7 inventory.inventory_purchases

**PURPOSE:** Purchase order tracking for inventory.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| purchase_id | text | NOT NULL, UNIQUE | Business ID: PO-NNNNNN |
| item_id | uuid | FK → inventory_items, NOT NULL | Item reference |
| supplier_id | uuid | FK → directory.companies | Supplier |
| property_id | uuid | FK → property.properties | For property |
| quantity | integer | NOT NULL | Quantity ordered |
| unit_cost | numeric(10,2) | | Per-unit cost |
| total_cost | numeric(10,2) | | Total cost |
| order_date | date | NOT NULL | Order date |
| expected_date | date | | Expected delivery |
| received_date | date | | Actual delivery |
| received_quantity | integer | | Quantity received |
| status | text | DEFAULT 'ordered' | ordered, shipped, partial, received, cancelled |
| order_number | text | | PO number |
| tracking_number | text | | Tracking |
| ordered_by_id | uuid | FK → team.team_directory | Who ordered |
| received_by_id | uuid | FK → team.team_directory | Who received |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 7.8 inventory.inventory_events

**PURPOSE:** Inventory transaction/movement log.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| event_id | text | NOT NULL, UNIQUE | Business ID: IEVT-NNNNNNNN |
| item_id | uuid | FK → inventory_items, NOT NULL | Item reference |
| event_type | text | NOT NULL | receipt, issue, transfer, adjustment, count, damage, loss |
| quantity | integer | NOT NULL | Quantity (signed) |
| from_location_id | uuid | FK → storage_locations | Source location |
| to_location_id | uuid | FK → storage_locations | Destination |
| from_property_id | uuid | FK → property.properties | From property |
| to_property_id | uuid | FK → property.properties | To property |
| reference_type | text | | ticket, purchase, inspection, clean |
| reference_id | uuid | | Reference record ID |
| reason | text | | Event reason |
| performed_by_id | uuid | FK → team.team_directory | Who performed |
| performed_at | timestamptz | DEFAULT now() | When performed |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### Linen-Specific Tables (7.9-7.15)

---

### 7.9 inventory.linen_types

**PURPOSE:** Linen type definitions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| type_code | text | NOT NULL, UNIQUE | Type code |
| type_name | text | NOT NULL | Type name |
| category | text | | bed, bath, kitchen, pool |
| standard_size | text | | Standard size |
| wash_cycle | text | | Wash requirements |
| replacement_frequency_months | integer | | How often to replace |
| unit_cost | numeric(10,2) | | Cost each |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 7.10 inventory.linen_items

**PURPOSE:** Individual linen tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| linen_id | text | NOT NULL, UNIQUE | Business ID: LIN-NNNNNN |
| linen_type_id | uuid | FK → linen_types, NOT NULL | Type reference |
| property_id | uuid | FK → property.properties | Assigned property |
| barcode | text | | Barcode if tracked |
| status | text | DEFAULT 'in_service' | in_service, laundry, damaged, retired |
| condition | text | DEFAULT 'good' | excellent, good, fair, poor |
| purchase_date | date | | When purchased |
| wash_count | integer | DEFAULT 0 | Times washed |
| last_washed | date | | Last wash date |
| notes | text | | Notes |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 7.11 inventory.linen_pars

**PURPOSE:** Par levels per property/room.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| property_id | uuid | FK → property.properties, NOT NULL | Property reference |
| room_id | uuid | FK → property.rooms | Room (null = property) |
| linen_type_id | uuid | FK → linen_types, NOT NULL | Linen type |
| par_quantity | integer | NOT NULL | Target quantity |
| minimum_quantity | integer | | Minimum acceptable |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (property_id, room_id, linen_type_id)

---

### 7.12 inventory.linen_deliveries

**PURPOSE:** Linen service deliveries.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| delivery_id | text | NOT NULL, UNIQUE | Business ID: LDEL-NNNNNN |
| property_id | uuid | FK → property.properties, NOT NULL | Property |
| service_company_id | uuid | FK → directory.companies | Linen service |
| delivery_date | date | NOT NULL | Delivery date |
| delivery_type | text | | scheduled, emergency, exchange |
| items_delivered | jsonb | | Items and quantities |
| items_picked_up | jsonb | | Items picked up |
| received_by_id | uuid | FK → team.team_directory | Who received |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 7.13 inventory.linen_counts

**PURPOSE:** Linen count records.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| count_id | text | NOT NULL, UNIQUE | Business ID: LCNT-NNNNNN |
| property_id | uuid | FK → property.properties, NOT NULL | Property |
| count_date | date | NOT NULL | Count date |
| count_type | text | | full, spot, monthly |
| counted_by_id | uuid | FK → team.team_directory, NOT NULL | Who counted |
| counts | jsonb | NOT NULL | Linen counts by type |
| discrepancies | jsonb | | Variances from par |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 7.14 inventory.linen_issues

**PURPOSE:** Linen damage/loss tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| issue_id | text | NOT NULL, UNIQUE | Business ID: LISS-NNNNNN |
| linen_item_id | uuid | FK → linen_items | Specific item |
| linen_type_id | uuid | FK → linen_types, NOT NULL | Type if not specific |
| property_id | uuid | FK → property.properties, NOT NULL | Property |
| issue_type | text | NOT NULL | damage, loss, stain, wear |
| quantity | integer | DEFAULT 1 | Quantity affected |
| description | text | | Description |
| discovered_at | timestamptz | DEFAULT now() | When found |
| discovered_by_id | uuid | FK → team.team_directory | Who found |
| reservation_id | uuid | FK → reservations.reservations | Related stay |
| is_billable | boolean | DEFAULT false | Bill to guest? |
| replacement_cost | numeric(10,2) | | Replacement cost |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 7.15 inventory.linen_orders

**PURPOSE:** Linen purchase orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| order_id | text | NOT NULL, UNIQUE | Business ID: LORD-NNNNNN |
| supplier_id | uuid | FK → directory.companies | Supplier |
| order_date | date | NOT NULL | Order date |
| expected_date | date | | Expected delivery |
| received_date | date | | Actual delivery |
| status | text | DEFAULT 'ordered' | ordered, shipped, received, cancelled |
| items | jsonb | NOT NULL | Items and quantities |
| total_cost | numeric(10,2) | | Total cost |
| ordered_by_id | uuid | FK → team.team_directory | Who ordered |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

## 8. REF Schema (8 tables + views) — HYBRID DESIGN

**Purpose:** Cross-schema reference/lookup data using a unified lookup system for simple types, fee configuration, and centralized status management.

**Design Philosophy:** Rather than 39+ nearly-identical tables, we use:
1. **Unified Lookup System** (2 tables) — For simple code/name/description types
2. **Fee Configuration** (2 tables) — Cross-schema fee type definitions
3. **Status System** (4 tables) — For centralized status management and audit trail

**Domain-specific configuration moved to domain schemas:**
- Journey/touchpoint config → `reservations` schema (3 tables)
- Interest/preference config → `concierge` schema (3 tables)

This reduces REF table count from ~42 to **8** while maintaining type safety via CHECK constraints.

---

### PART A: UNIFIED LOOKUP SYSTEM

---

### 8.1 ref.lookup_domains

**PURPOSE:** Registry of all lookup domains with schema bindings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| domain_code | text | NOT NULL, UNIQUE | Domain identifier (TICKET_TYPE, ROOM_TYPE) |
| domain_name | text | NOT NULL | Human-readable name |
| description | text | | Domain description |
| bound_schema | text | | Target schema name |
| bound_table | text | | Target table name |
| bound_column | text | | Target column name |
| attribute_schema | jsonb | | JSON Schema for domain-specific attributes |
| allow_hierarchy | boolean | DEFAULT false | Can values have parent-child? |
| allow_user_created | boolean | DEFAULT true | Can users add values? |
| requires_parent | boolean | DEFAULT false | Must values have parent? |
| parent_domain_code | text | | Parent domain for hierarchies |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Registered Domains (31):**

| Domain Code | Bound To | Has Hierarchy |
|-------------|----------|---------------|
| TICKET_TYPE | service.tickets.ticket_type_code | No |
| TICKET_CATEGORY | service.tickets.category_code | Yes (→ TICKET_TYPE) |
| TICKET_PRIORITY | service.tickets.priority | No |
| TICKET_STATUS | service.tickets.status | No |
| ACTIVITY_TYPE | team.time_entries.activity_type_code | No |
| LABEL | service.ticket_labels.label_code | No |
| DAMAGE_CATEGORY | service.damage_claims.damage_category_code | No |
| CLAIM_SUBMISSION_TYPE | service.damage_claim_submissions.submission_type_code | No |
| DENIAL_CATEGORY | service.damage_claim_denials.denial_code | No |
| ROOM_TYPE | property.rooms.room_type_code | No |
| BED_TYPE | property.beds.bed_type_code | No |
| AMENITY_TYPE | property.property_amenities.amenity_type_code | No |
| APPLIANCE_TYPE | property.appliances.appliance_type_code | No |
| FIXTURE_TYPE | property.fixtures.fixture_type_code | No |
| SURFACE_TYPE | property.surfaces.surface_type_code | No |
| CLEAN_TYPE | property.cleans.clean_type | No |
| INSPECTION_CATEGORY | property.inspection_questions.category | No |
| ISSUE_SEVERITY | property.inspection_issues.severity | No |
| INVENTORY_ITEM_TYPE | inventory.inventory_items.item_type_code | No |
| COUNTRY | directory.contacts.country_code | No |
| STATE | directory.contacts.state | Yes (→ COUNTRY) |
| CURRENCY | finance.transactions.currency_code | No |
| LANGUAGE | directory.contacts.preferred_language | No |
| TIMEZONE | — | No |
| PLATFORM_TYPE | reservations.reservations.booking_source | No |
| CHANNEL_TYPE | comms.channels.channel_code | No |
| DOCUMENT_TYPE | knowledge.documents.document_type | No |
| RELATIONSHIP_TYPE | directory.contact_relationships.relationship_type | No |
| CONTACT_TYPE | directory.contacts.contact_type | No |
| VENDOR_CATEGORY | directory.vendors.vendor_type | No |
| EXPENSE_CATEGORY | finance.expenses.category_code | No |

---

### 8.2 ref.lookup_values

**PURPOSE:** All simple lookup values across all domains in a single table.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| domain_code | text | FK → lookup_domains, NOT NULL | Domain reference |
| value_code | text | NOT NULL | Business code (PC, KING, PLUMBING) |
| value_name | text | NOT NULL | Display name |
| description | text | | Value description |
| parent_id | uuid | FK → lookup_values | Parent value (for hierarchies) |
| parent_domain_code | text | | Parent's domain (denormalized) |
| parent_value_code | text | | Parent's code (denormalized) |
| attributes | jsonb | DEFAULT '{}' | Domain-specific extended attributes |
| sort_order | integer | DEFAULT 0 | Display ordering |
| is_default | boolean | DEFAULT false | Default value for domain? |
| is_active | boolean | DEFAULT true | Value active flag |
| is_system | boolean | DEFAULT false | System-managed? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (domain_code, value_code)

**Indexes:**
- `idx_lookup_values_domain` ON (domain_code)
- `idx_lookup_values_parent` ON (parent_id) WHERE parent_id IS NOT NULL
- `idx_lookup_values_active` ON (domain_code, is_active) WHERE is_active = true
- `idx_lookup_values_attributes` USING gin(attributes)

**Example Attributes by Domain:**

| Domain | Attributes |
|--------|------------|
| TICKET_TYPE | `{"default_sla_hours": 24, "requires_property": true}` |
| TICKET_PRIORITY | `{"sla_hours": 4}` |
| BED_TYPE | `{"sleeps": 2}` |
| APPLIANCE_TYPE | `{"category": "kitchen", "typical_lifespan_years": 15}` |
| CLEAN_TYPE | `{"default_duration_minutes": 180}` |
| PLATFORM_TYPE | `{"is_ota": true, "commission_rate": 3}` |
| COUNTRY | `{"currency_code": "USD", "calling_code": "+1"}` |

---

### 8.3 Validation Function

```sql
-- Validates lookup references (used in CHECK constraints)
CREATE FUNCTION ref.is_valid_lookup(p_domain text, p_code text, p_allow_null boolean DEFAULT true)
RETURNS boolean AS $$
BEGIN
    IF p_code IS NULL THEN RETURN p_allow_null; END IF;
    RETURN EXISTS(SELECT 1 FROM ref.lookup_values
                  WHERE domain_code = p_domain AND value_code = p_code AND is_active = true);
END;
$$ LANGUAGE plpgsql STABLE;
```

**Usage in Target Tables:**
```sql
ALTER TABLE service.tickets
ADD CONSTRAINT chk_ticket_type_valid CHECK (ref.is_valid_lookup('TICKET_TYPE', ticket_type_code, false));

ALTER TABLE property.rooms
ADD CONSTRAINT chk_room_type_valid CHECK (ref.is_valid_lookup('ROOM_TYPE', room_type_code));
```

---

### PART B: COMPLEX REFERENCE TABLES

These tables remain separate because they have unique relationships or complex business logic.

---

### 8.4 ref.fee_types

**PURPOSE:** Fee type definitions with calculation methods.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| fee_type_code | text | NOT NULL, UNIQUE | Fee code |
| fee_type_name | text | NOT NULL | Display name |
| description | text | | Description |
| is_taxable | boolean | DEFAULT false | Taxable? |
| is_refundable | boolean | DEFAULT true | Refundable? |
| default_amount | numeric(10,2) | | Default amount |
| calculation_method | text | | flat, per_night, per_guest, percentage |
| sort_order | integer | DEFAULT 0 | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 8.5 ref.fee_rates

**PURPOSE:** Fee rates by scope (global, resort, property) with effective dates.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| fee_type_id | uuid | FK → fee_types, NOT NULL | Fee type |
| scope_type | text | NOT NULL | global, resort, property |
| scope_id | uuid | | Resort or property ID |
| rate | numeric(10,2) | NOT NULL | Rate amount |
| rate_type | text | NOT NULL | flat, per_night, per_guest, percentage |
| effective_date | date | NOT NULL | Start date |
| end_date | date | | End date |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (fee_type_id, scope_type, scope_id, effective_date)

---

> **NOTE:** Journey/touchpoint tables moved to `reservations` schema (3.9-3.11). Concierge interest/preference tables moved to `concierge` schema (14.2-14.4).

---

### PART B2: STATUS SYSTEM TABLES

These tables provide centralized status management with domain applicability, state machine transitions, and audit trail.

---

### 8.6 ref.status_types

**PURPOSE:** Master list of all statuses with terminal and approval flags.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| status_code | text | NOT NULL, UNIQUE | Status identifier (active, approved, cancelled) |
| status_name | text | NOT NULL | Display name |
| description | text | | Status meaning |
| is_terminal | boolean | DEFAULT false | No further transitions allowed? |
| requires_approval | boolean | DEFAULT false | Approval needed to enter? |
| sort_order | integer | DEFAULT 0 | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Example Values:**

| status_code | is_terminal | requires_approval |
|-------------|-------------|-------------------|
| draft | false | false |
| pending_approval | false | true |
| approved | false | true |
| executed | true | true |
| archived | true | false |
| open | false | false |
| scheduled | false | true |
| completed | false | false |
| closed | true | false |
| active | false | false |
| inactive | false | false |
| confirmed | false | false |
| arrived | false | false |
| departed | true | false |
| cancelled | true | false |
| terminated | true | true |
| blocked | true | true |

---

### 8.7 ref.status_domains

**PURPOSE:** Maps statuses to entity domains (RSV, TIK, PRP, etc.).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| status_id | uuid | FK → status_types, NOT NULL | Status reference |
| domain_code | text | NOT NULL | Entity domain (RSV, TIK, PRP, DOC, GST, HO, INT) |
| domain_name | text | | Human-readable domain name |

**Unique Constraint:** (status_id, domain_code)

**Domain Codes:**

| Code | Domain | Example Tables |
|------|--------|----------------|
| RSV | Reservations | reservations.reservations |
| TIK | Tickets | service.tickets |
| PRP | Properties | property.properties |
| DOC | Documents | knowledge.documents |
| GST | Guests | directory.guests |
| HO | Homeowners | directory.homeowners |
| INT | Internal (Team) | team.team_directory |
| FIN | Finance | finance.transactions |
| PAY | Payroll | finance.payroll_runs |
| AIT | AI Agents | ai.agents |

---

### 8.8 ref.status_transitions

**PURPOSE:** Valid state machine transitions between statuses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| from_status_id | uuid | FK → status_types, NOT NULL | Starting status |
| to_status_id | uuid | FK → status_types, NOT NULL | Destination status |
| domain_code | text | | Limit transition to specific domain |
| requires_approval | boolean | DEFAULT false | Transition needs approval? |
| requires_reason | boolean | DEFAULT false | Reason required? |

**Unique Constraint:** (from_status_id, to_status_id, domain_code)

**Example Transitions:**

| From | To | Domain | Notes |
|------|----|--------|-------|
| draft | pending_approval | DOC | Document workflow |
| pending_approval | approved | — | After approval |
| approved | executed | DOC | Final execution |
| open | scheduled | TIK | Ticket scheduling |
| open | completed | TIK | Direct completion |
| confirmed | arrived | RSV | Guest check-in |
| arrived | departed | RSV | Guest checkout |
| active | inactive | — | Deactivation |
| active | offboarding | INT | Begin exit process |

---

### 8.9 ref.status_events

**PURPOSE:** Centralized audit trail for ALL status changes across the system.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| domain_code | text | NOT NULL | Entity type (RSV, TIK, PRP, etc.) |
| entity_id | uuid | NOT NULL | The record's UUID |
| entity_business_id | text | | Business ID (RES-2025-000001) |
| from_status_id | uuid | FK → status_types | Previous status |
| to_status_id | uuid | FK → status_types, NOT NULL | New status |
| from_status_code | text | | Previous status code (denormalized) |
| to_status_code | text | NOT NULL | New status code (denormalized) |
| changed_by_id | uuid | FK → team.team_directory | Who made the change |
| changed_by_type | text | DEFAULT 'user' | user, system, automation, api |
| reason | text | | Why the change was made |
| metadata | jsonb | DEFAULT '{}' | Additional context |
| approval_required | boolean | DEFAULT false | Did this need approval? |
| approved_by_id | uuid | | Who approved |
| approved_at | timestamptz | | When approved |
| changed_at | timestamptz | DEFAULT now() | When status changed |
| created_at | timestamptz | DEFAULT now() | Record created |

**Indexes:**
- `idx_status_events_entity` ON (domain_code, entity_id)
- `idx_status_events_time` ON (changed_at DESC)
- `idx_status_events_business_id` ON (entity_business_id) WHERE NOT NULL
- `idx_status_events_status` ON (to_status_code)

**Usage:** This table provides complete status history for any entity without needing per-table history tables.

---

### PART C: COMPATIBILITY VIEWS

Views that mimic old table structure for backwards compatibility:

| View | Source | Purpose |
|------|--------|---------|
| ref.v_ticket_types | lookup_values WHERE domain='TICKET_TYPE' | Ticket type lookup |
| ref.v_ticket_priorities | lookup_values WHERE domain='TICKET_PRIORITY' | Priority lookup |
| ref.v_ticket_statuses | lookup_values WHERE domain='TICKET_STATUS' | Status lookup |
| ref.v_room_types | lookup_values WHERE domain='ROOM_TYPE' | Room type lookup |
| ref.v_bed_types | lookup_values WHERE domain='BED_TYPE' | Bed type lookup |
| ref.v_appliance_types | lookup_values WHERE domain='APPLIANCE_TYPE' | Appliance lookup |
| ref.v_clean_types | lookup_values WHERE domain='CLEAN_TYPE' | Clean type lookup |
| ref.v_countries | lookup_values WHERE domain='COUNTRY' | Country lookup |
| ref.v_platforms | lookup_values WHERE domain='PLATFORM_TYPE' | Platform lookup |
| ref.v_all_lookups | All lookup_values + domains | Admin UI view |

---

### REF Schema Summary

| Category | Tables | Description |
|----------|--------|-------------|
| Unified Lookup | 2 | lookup_domains, lookup_values |
| Fee Configuration | 2 | fee_types, fee_rates |
| Status System | 4 | status_types, status_domains, status_transitions, status_events |
| Compatibility Views | 10+ | v_ticket_types, v_room_types, etc. |
| **TOTAL REF TABLES** | **8** | (down from 42) |

**Tables Moved to Domain Schemas:**
- Journey/touchpoint config → `reservations.journey_stages`, `reservations.touchpoints`, `reservations.stage_touchpoints`
- Interest/preference config → `concierge.interest_categories`, `concierge.interests`, `concierge.preference_levels`

**Full Specification:** See `V4_2_Ref_Schema_Specification.md` for complete DDL and seed data.

---

## 9. GEO Schema (5 tables)

**Purpose:** Geographic hierarchy for property locations, areas, and points of interest.

---

### 9.1 geo.countries

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| country_code | text | NOT NULL, UNIQUE | ISO 3166-1 alpha-2 |
| country_name | text | NOT NULL | Country name |
| currency_code | text | | Default currency |
| calling_code | text | | Phone code |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 9.2 geo.states

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| country_id | uuid | FK → countries, NOT NULL | Country reference |
| state_code | text | NOT NULL | State code |
| state_name | text | NOT NULL | State name |
| timezone | text | | Default timezone |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (country_id, state_code)

---

### 9.3 geo.cities

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| state_id | uuid | FK → states, NOT NULL | State reference |
| city_name | text | NOT NULL | City name |
| latitude | numeric(10,7) | | City center lat |
| longitude | numeric(10,7) | | City center lon |
| population | integer | | Population |
| timezone | text | | Timezone override |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 9.4 geo.areas

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| area_id | text | NOT NULL, UNIQUE | Business ID: AREA-NNNN |
| city_id | uuid | FK → cities, NOT NULL | City reference |
| area_name | text | NOT NULL | Area name |
| area_type | text | | neighborhood, district, zone |
| description | text | | Description |
| boundary_geojson | jsonb | | GeoJSON boundary |
| latitude | numeric(10,7) | | Center lat |
| longitude | numeric(10,7) | | Center lon |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 9.5 geo.poi

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| poi_id | text | NOT NULL, UNIQUE | Business ID: POI-NNNNNN |
| area_id | uuid | FK → areas | Area reference |
| poi_name | text | NOT NULL | POI name |
| poi_type | text | NOT NULL | beach, restaurant, attraction, activity |
| description | text | | Description |
| address | text | | Address |
| latitude | numeric(10,7) | | Latitude |
| longitude | numeric(10,7) | | Longitude |
| phone | text | | Phone |
| website | text | | Website |
| hours | jsonb | | Operating hours |
| rating | numeric(3,2) | | Average rating |
| price_level | text | | $, $$, $$$, $$$$ |
| tags | text[] | | Tags |
| is_recommended | boolean | DEFAULT false | We recommend? |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

## 10. AI Schema (18 tables)

**Purpose:** AI agent infrastructure for EVE, NAVI, OTTO, and other AI agents.

---

### 10.1 ai.agents

**PURPOSE:** AI agent definitions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | NOT NULL, UNIQUE | Internal ID |
| database_id | uuid | DEFAULT gen_random_uuid() | System UUID |
| agent_id | text | PK, NOT NULL | Business ID: AGT-NNNN |
| agent_name | text | NOT NULL | Agent name (EVE, NAVI) |
| agent_type | text | NOT NULL | guest_comms, property_ops, scheduling, analytics |
| description | text | | Agent description |
| status | text | DEFAULT 'active' | active, inactive, testing |
| model_config_id | text | FK → model_configs | LLM configuration |
| system_prompt | text | | Base system prompt |
| personality | jsonb | | Personality traits |
| capabilities | text[] | | Capability list |
| rate_limits | jsonb | | Rate limiting config |
| version | text | | Agent version |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 10.2 ai.agent_capabilities

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| capability_code | text | NOT NULL | Capability code |
| capability_name | text | NOT NULL | Display name |
| description | text | | Description |
| is_enabled | boolean | DEFAULT true | Enabled? |
| parameters | jsonb | | Capability parameters |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 10.3 ai.agent_configs

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | NOT NULL, UNIQUE | Internal ID |
| database_id | uuid | DEFAULT gen_random_uuid() | System UUID |
| config_id | text | PK, NOT NULL | Business ID: ACFG-NNNNNN |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| config_key | text | NOT NULL | Configuration key |
| config_value | text | | Configuration value |
| config_type | text | | string, number, json, boolean |
| description | text | | What this config does |
| is_sensitive | boolean | DEFAULT false | Contains secrets? |
| environment | text | DEFAULT 'all' | production, staging, all |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 10.4 ai.agent_prompts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| prompt_id | text | NOT NULL, UNIQUE | Business ID: PRM-NNNNNN |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| prompt_name | text | NOT NULL | Prompt name |
| prompt_type | text | | system, user, assistant, function |
| prompt_text | text | NOT NULL | Prompt content |
| variables | text[] | | Variable placeholders |
| version | integer | DEFAULT 1 | Version number |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 10.5 ai.agent_tools

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| tool_id | text | NOT NULL, UNIQUE | Business ID: TOOL-NNNN |
| agent_id | text | FK → agents | Agent (null = global) |
| tool_name | text | NOT NULL | Tool name |
| tool_type | text | | api, database, function |
| description | text | | What tool does |
| parameters_schema | jsonb | | Parameter JSON schema |
| endpoint | text | | API endpoint |
| auth_config | jsonb | | Auth configuration |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 10.6 ai.agent_tool_calls

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| tool_id | text | FK → agent_tools, NOT NULL | Tool reference |
| conversation_id | uuid | FK → agent_conversations | Conversation context |
| input_params | jsonb | | Input parameters |
| output_result | jsonb | | Output result |
| status | text | NOT NULL | success, error, timeout |
| error_message | text | | Error if failed |
| latency_ms | integer | | Execution time |
| called_at | timestamptz | DEFAULT now() | When called |

---

### 10.7 ai.agent_conversations

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| conversation_id | text | NOT NULL, UNIQUE | Business ID: CONV-NNNNNNNN |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| contact_id | uuid | FK → directory.contacts | Human contact |
| reservation_id | uuid | FK → reservations.reservations | Reservation context |
| property_id | uuid | FK → property.properties | Property context |
| channel | text | NOT NULL | sms, email, chat, voice |
| channel_identifier | text | | Phone/email/session ID |
| started_at | timestamptz | DEFAULT now() | Start time |
| ended_at | timestamptz | | End time |
| duration_seconds | integer | | Total duration |
| message_count | integer | DEFAULT 0 | Message count |
| sentiment | text | | positive, neutral, negative |
| topics | text[] | | Topics discussed |
| resolution | text | | Resolution description |
| resolution_type | text | | self_service, escalated, pending |
| escalated | boolean | DEFAULT false | Was escalated? |
| escalated_to | text | | Who escalated to |
| escalation_reason | text | | Why escalated |
| summary | text | | AI summary |
| action_items | text[] | | Action items |
| quality_score | numeric(3,2) | | Quality (1-5) |
| customer_satisfaction | integer | | CSAT (1-5) |
| metadata | jsonb | | Additional data |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 10.8 ai.agent_messages

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| conversation_id | uuid | FK → agent_conversations, NOT NULL | Conversation |
| message_order | integer | NOT NULL | Sequence |
| role | text | NOT NULL | user, assistant, system |
| content | text | NOT NULL | Message content |
| content_type | text | DEFAULT 'text' | text, image, audio |
| tokens | integer | | Token count |
| model_used | text | | Model version |
| latency_ms | integer | | Response time |
| tool_calls | jsonb | | Tools invoked |
| tool_results | jsonb | | Tool results |
| sentiment | text | | Message sentiment |
| intent | text | | Detected intent |
| entities | jsonb | | Extracted entities |
| created_at | timestamptz | DEFAULT now() | Message time |

---

### 10.9 ai.agent_memory

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| memory_type | text | NOT NULL | short_term, long_term, episodic |
| memory_key | text | NOT NULL | Memory key |
| memory_value | jsonb | NOT NULL | Memory content |
| context_id | uuid | | Related context |
| expires_at | timestamptz | | Expiration |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 10.10 ai.agent_tasks

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| task_id | text | NOT NULL, UNIQUE | Business ID: ATSK-NNNNNNNN |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| task_type | text | NOT NULL | Task type |
| task_name | text | NOT NULL | Task name |
| description | text | | Description |
| input_data | jsonb | | Input parameters |
| status | text | DEFAULT 'pending' | pending, running, completed, failed |
| priority | integer | DEFAULT 5 | Priority (1=highest) |
| scheduled_at | timestamptz | | When to run |
| started_at | timestamptz | | When started |
| completed_at | timestamptz | | When completed |
| error_message | text | | Error if failed |
| retry_count | integer | DEFAULT 0 | Retry attempts |
| max_retries | integer | DEFAULT 3 | Max retries |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 10.11 ai.agent_task_results

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| task_id | uuid | FK → agent_tasks, NOT NULL | Task reference |
| result_data | jsonb | | Result data |
| success | boolean | NOT NULL | Succeeded? |
| error_code | text | | Error code |
| error_details | text | | Error details |
| execution_time_ms | integer | | Execution time |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 10.12 ai.agent_evaluations

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| evaluation_date | date | NOT NULL | Evaluation date |
| evaluation_type | text | | daily, weekly, monthly |
| metrics | jsonb | NOT NULL | Performance metrics |
| score | numeric(5,2) | | Overall score |
| notes | text | | Evaluation notes |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 10.13 ai.agent_feedback

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| message_id | uuid | FK → agent_messages | Message reference |
| conversation_id | uuid | FK → agent_conversations | Conversation |
| feedback_type | text | NOT NULL | thumbs_up, thumbs_down, correction |
| feedback_value | integer | | Rating value |
| feedback_text | text | | Feedback text |
| provided_by_id | uuid | FK → team.team_directory | Who provided |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 10.14 ai.agent_handoffs

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| from_agent_id | text | FK → agents, NOT NULL | Source agent |
| to_agent_id | text | FK → agents | Target agent |
| conversation_id | uuid | FK → agent_conversations | Conversation |
| handoff_reason | text | NOT NULL | Why handoff |
| context_passed | jsonb | | Context transferred |
| handoff_at | timestamptz | DEFAULT now() | When handed off |

---

### 10.15 ai.agent_escalations

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| agent_id | text | FK → agents, NOT NULL | Agent reference |
| conversation_id | uuid | FK → agent_conversations | Conversation |
| escalation_reason | text | NOT NULL | Why escalated |
| escalated_to_id | uuid | FK → team.team_directory | Human target |
| escalated_to_role | text | | Role target |
| context | jsonb | | Context passed |
| status | text | DEFAULT 'pending' | pending, acknowledged, resolved |
| resolved_at | timestamptz | | When resolved |
| resolution_notes | text | | Resolution notes |
| escalated_at | timestamptz | DEFAULT now() | When escalated |

---

### 10.16 ai.model_configs

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| config_id | text | NOT NULL, UNIQUE | Business ID: MCFG-NNNN |
| model_name | text | NOT NULL | Model name |
| provider | text | NOT NULL | openai, anthropic, ollama |
| model_version | text | | Model version |
| temperature | numeric(3,2) | DEFAULT 0.7 | Temperature |
| max_tokens | integer | | Max tokens |
| top_p | numeric(3,2) | | Top P |
| frequency_penalty | numeric(3,2) | | Frequency penalty |
| presence_penalty | numeric(3,2) | | Presence penalty |
| stop_sequences | text[] | | Stop sequences |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 10.17 ai.embedding_configs

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| config_id | text | NOT NULL, UNIQUE | Business ID: ECFG-NNNN |
| model_name | text | NOT NULL | Embedding model |
| provider | text | NOT NULL | openai, cohere, local |
| dimensions | integer | NOT NULL | Vector dimensions |
| chunk_size | integer | | Chunk size |
| chunk_overlap | integer | | Chunk overlap |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 10.18 ai.usage_logs

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| agent_id | text | FK → agents | Agent reference |
| model_config_id | text | FK → model_configs | Model used |
| usage_date | date | NOT NULL | Usage date |
| usage_hour | integer | | Hour (0-23) |
| prompt_tokens | integer | DEFAULT 0 | Prompt tokens |
| completion_tokens | integer | DEFAULT 0 | Completion tokens |
| total_tokens | integer | DEFAULT 0 | Total tokens |
| request_count | integer | DEFAULT 0 | API requests |
| estimated_cost | numeric(10,4) | | Estimated cost |
| created_at | timestamptz | DEFAULT now() | Record created |

---

## 11. COMMS Schema (12 tables)

**Purpose:** Communications system for messages, templates, and campaigns.

---

### 11.1 comms.templates

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| template_id | text | NOT NULL, UNIQUE | Business ID: TMPL-NNNNNN |
| template_name | text | NOT NULL | Template name |
| template_type | text | NOT NULL | sms, email, push |
| category | text | | booking, pre_arrival, in_stay, post_stay |
| subject | text | | Email subject |
| body | text | NOT NULL | Template body |
| variables | text[] | | Available variables |
| is_automated | boolean | DEFAULT false | Auto-send? |
| trigger_event | text | | Trigger event |
| trigger_timing | text | | When to send |
| is_active | boolean | DEFAULT true | Active? |
| created_by_id | uuid | FK → team.team_directory | Creator |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 11.2 comms.template_versions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| template_id | uuid | FK → templates, NOT NULL | Template reference |
| version_number | integer | NOT NULL | Version number |
| subject | text | | Subject at version |
| body | text | NOT NULL | Body at version |
| changed_by_id | uuid | FK → team.team_directory | Who changed |
| change_notes | text | | Change notes |
| created_at | timestamptz | DEFAULT now() | Version created |

---

### 11.3 comms.channels

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| channel_code | text | NOT NULL, UNIQUE | sms, email, push, whatsapp |
| channel_name | text | NOT NULL | Display name |
| provider | text | | twilio, sendgrid, etc. |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 11.4 comms.channel_configs

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| channel_id | uuid | FK → channels, NOT NULL | Channel reference |
| config_key | text | NOT NULL | Config key |
| config_value | text | | Config value |
| is_sensitive | boolean | DEFAULT false | Contains secrets? |
| environment | text | DEFAULT 'production' | Environment |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 11.5 comms.messages

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| message_id | text | NOT NULL, UNIQUE | Business ID: MSG-NNNNNNNN |
| template_id | uuid | FK → templates | Template used |
| channel_id | uuid | FK → channels, NOT NULL | Channel |
| direction | text | NOT NULL | inbound, outbound |
| from_address | text | | Sender |
| to_address | text | | Recipient |
| subject | text | | Subject |
| body | text | NOT NULL | Message body |
| body_html | text | | HTML version |
| contact_id | uuid | FK → directory.contacts | Contact reference |
| reservation_id | uuid | FK → reservations.reservations | Reservation context |
| property_id | uuid | FK → property.properties | Property context |
| status | text | DEFAULT 'pending' | pending, sent, delivered, failed, bounced |
| sent_at | timestamptz | | When sent |
| delivered_at | timestamptz | | When delivered |
| external_id | text | | Provider message ID |
| error_message | text | | Error if failed |
| metadata | jsonb | | Additional data |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 11.6 comms.message_recipients

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| message_id | uuid | FK → messages, NOT NULL | Message reference |
| contact_id | uuid | FK → directory.contacts | Contact |
| recipient_type | text | DEFAULT 'to' | to, cc, bcc |
| address | text | NOT NULL | Email/phone |
| status | text | DEFAULT 'pending' | pending, sent, delivered, bounced |
| delivered_at | timestamptz | | When delivered |
| opened_at | timestamptz | | When opened |
| clicked_at | timestamptz | | When clicked |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 11.7 comms.message_attachments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| message_id | uuid | FK → messages, NOT NULL | Message reference |
| file_id | uuid | FK → storage.files, NOT NULL | File reference |
| filename | text | | Display filename |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 11.8 comms.message_events

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| message_id | uuid | FK → messages, NOT NULL | Message reference |
| event_type | text | NOT NULL | sent, delivered, opened, clicked, bounced, failed |
| event_data | jsonb | | Event details |
| occurred_at | timestamptz | DEFAULT now() | When occurred |

---

### 11.9 comms.campaigns

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| campaign_id | text | NOT NULL, UNIQUE | Business ID: CMP-NNNNNN |
| campaign_name | text | NOT NULL | Campaign name |
| campaign_type | text | | one_time, recurring, triggered |
| description | text | | Description |
| status | text | DEFAULT 'draft' | draft, scheduled, active, paused, completed |
| scheduled_at | timestamptz | | When to send |
| started_at | timestamptz | | When started |
| completed_at | timestamptz | | When completed |
| created_by_id | uuid | FK → team.team_directory | Creator |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 11.10 comms.campaign_messages

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| campaign_id | uuid | FK → campaigns, NOT NULL | Campaign reference |
| message_id | uuid | FK → messages, NOT NULL | Message reference |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 11.11 comms.automations

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| automation_id | text | NOT NULL, UNIQUE | Business ID: AUT-NNNNNN |
| automation_name | text | NOT NULL | Name |
| description | text | | Description |
| template_id | uuid | FK → templates | Template to use |
| trigger_type | text | NOT NULL | event, schedule, condition |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 11.12 comms.automation_triggers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| automation_id | uuid | FK → automations, NOT NULL | Automation |
| trigger_event | text | NOT NULL | Event name |
| trigger_conditions | jsonb | | Conditions |
| timing_offset | integer | | Hours offset |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |

---

## 12. KNOWLEDGE Schema (28 tables)

**Purpose:** Documents, SOPs, embeddings for AI, and training materials.

---

### 12.1 knowledge.articles

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| article_id | text | NOT NULL, UNIQUE | Business ID: ART-NNNNNN |
| title | text | NOT NULL | Article title |
| slug | text | UNIQUE | URL slug |
| content | text | NOT NULL | Article content (markdown) |
| summary | text | | Brief summary |
| article_type | text | | sop, guide, faq, reference |
| status | text | DEFAULT 'draft' | draft, published, archived |
| visibility | text | DEFAULT 'internal' | internal, team, public |
| author_id | uuid | FK → team.team_directory | Author |
| reviewer_id | uuid | FK → team.team_directory | Reviewer |
| published_at | timestamptz | | When published |
| view_count | integer | DEFAULT 0 | View count |
| helpful_count | integer | DEFAULT 0 | Helpful votes |
| not_helpful_count | integer | DEFAULT 0 | Not helpful votes |
| metadata | jsonb | | Additional metadata |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 12.2-12.28 Additional Knowledge Tables

The knowledge schema includes these additional tables following similar patterns:

| Table | Purpose |
|-------|---------|
| knowledge.article_versions | Version history |
| knowledge.article_categories | Category assignments |
| knowledge.article_tags | Tag assignments |
| knowledge.article_embeddings | Vector embeddings |
| knowledge.sops | Standard operating procedures |
| knowledge.sop_steps | SOP step definitions |
| knowledge.sop_checklists | SOP checklist items |
| knowledge.guidebooks | Property guidebooks |
| knowledge.guidebook_sections | Guidebook sections |
| knowledge.faqs | FAQ entries |
| knowledge.faq_categories | FAQ categorization |
| knowledge.documents | Document storage |
| knowledge.document_embeddings | Document embeddings |
| knowledge.training_materials | Training content |
| knowledge.training_modules | Training modules |
| knowledge.training_completions | Completion tracking |
| knowledge.policies | Company policies |
| knowledge.policy_versions | Policy versions |
| knowledge.policy_acknowledgments | Acknowledgments |
| knowledge.checklists | Checklist templates |
| knowledge.checklist_items | Checklist items |
| knowledge.checklist_instances | Checklist usage |
| knowledge.checklist_responses | Item responses |
| knowledge.search_logs | Search logging |
| knowledge.feedback | Content feedback |
| knowledge.suggestions | Content suggestions |
| knowledge.glossary | Term definitions |

---

# PART 3: REVENUE, CONCIERGE, FINANCE SCHEMAS

---

## 13. REVENUE Schema (12 tables)

**Purpose:** Revenue management and dynamic pricing (formerly pricing schema).

---

### 13.1 revenue.pricing_rules

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| rule_id | text | NOT NULL, UNIQUE | Business ID: PRC-NNNNNN |
| property_id | uuid | FK → property.properties | Property (null = global) |
| rule_name | text | NOT NULL | Rule name |
| rule_type | text | NOT NULL | base, seasonal, event, last_minute, length_of_stay |
| priority | integer | DEFAULT 5 | Rule priority |
| conditions | jsonb | | Rule conditions |
| adjustment_type | text | | percentage, fixed |
| adjustment_value | numeric(10,2) | | Adjustment amount |
| effective_date | date | | Start date |
| end_date | date | | End date |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 13.2 revenue.pricing_adjustments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| property_id | uuid | FK → property.properties, NOT NULL | Property |
| adjustment_date | date | NOT NULL | Date affected |
| adjustment_type | text | NOT NULL | manual, event, promotion |
| adjustment_reason | text | | Why adjusted |
| base_rate | numeric(10,2) | | Original rate |
| adjusted_rate | numeric(10,2) | NOT NULL | New rate |
| adjustment_percentage | numeric(5,2) | | % change |
| created_by_id | uuid | FK → team.team_directory | Who adjusted |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 13.3-13.12 Additional Revenue Tables

| Table | Purpose |
|-------|---------|
| revenue.seasonal_rates | Seasonal rate configurations |
| revenue.event_pricing | Event-based pricing |
| revenue.competitor_rates | Competitor rate tracking |
| revenue.market_data | Market intelligence |
| revenue.occupancy_forecasts | Occupancy predictions |
| revenue.revenue_forecasts | Revenue predictions |
| revenue.pricing_recommendations | AI pricing suggestions |
| revenue.rate_history | Historical rate tracking |
| revenue.yield_metrics | Yield management metrics |
| revenue.pricing_logs | Pricing decision logs |

---

## 14. CONCIERGE Schema (27 tables)

**Purpose:** Guest experience and concierge services, including interest and preference configuration.

---

### 14.1 concierge.venues

**PURPOSE:** Master venue database for beaches, hikes, attractions, restaurants.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| venue_id | text | NOT NULL, UNIQUE | Business ID varies by type |
| venue_type | text | NOT NULL | beach, hike, activity, restaurant, attraction |
| venue_name | text | NOT NULL | Venue name |
| description | text | | Description |
| area_id | uuid | FK → geo.areas | Area reference |
| address | text | | Address |
| latitude | numeric(10,7) | | Latitude |
| longitude | numeric(10,7) | | Longitude |
| phone | text | | Phone |
| website | text | | Website |
| hours | jsonb | | Operating hours |
| price_level | text | | $, $$, $$$, $$$$ |
| price_range | text | | Price range description |
| cuisine_types | text[] | | For restaurants |
| activity_types | text[] | | Activity categories |
| difficulty_level | text | | easy, moderate, difficult |
| duration_minutes | integer | | Typical duration |
| distance_miles | numeric(5,2) | | For hikes |
| amenities | text[] | | Available amenities |
| accessibility | text[] | | Accessibility features |
| best_time_to_visit | text | | Best time recommendations |
| insider_tips | text | | Local tips |
| parking_info | text | | Parking details |
| reservation_required | boolean | DEFAULT false | Needs reservation? |
| reservation_url | text | | Booking URL |
| average_rating | numeric(3,2) | | Average rating |
| review_count | integer | DEFAULT 0 | Number of reviews |
| our_rating | numeric(3,2) | | Our internal rating |
| is_recommended | boolean | DEFAULT false | We recommend? |
| is_featured | boolean | DEFAULT false | Featured venue? |
| photo_file_ids | uuid[] | | Photo references |
| tags | text[] | | Tags |
| status | text | DEFAULT 'active' | active, inactive, seasonal |
| seasonal_closure | jsonb | | Closure periods |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 14.2 concierge.interest_categories

**PURPOSE:** High-level interest categories. Moved from ref schema for domain cohesion.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| category_code | text | NOT NULL, UNIQUE | Category code |
| category_name | text | NOT NULL | Display name |
| icon | text | | Icon reference |
| sort_order | integer | DEFAULT 0 | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |

**Example Categories:** outdoor_adventure, water_activities, cultural, dining, relaxation, family_friendly, romantic, nightlife

---

### 14.3 concierge.interests

**PURPOSE:** Specific interest types within categories. Renamed from ref.concierge_interest_types.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| interest_code | text | NOT NULL, UNIQUE | Interest code |
| interest_name | text | NOT NULL | Display name |
| category_id | uuid | FK → interest_categories, NOT NULL | Category reference |
| description | text | | Description |
| icon | text | | Icon reference |
| sort_order | integer | DEFAULT 0 | Display order |
| is_active | boolean | DEFAULT true | Active flag |
| created_at | timestamptz | DEFAULT now() | Record created |

**Example Interests:** snorkeling, hiking, surfing, luau, fine_dining, spa, sunset_cruise, volcano_tour

---

### 14.4 concierge.preference_levels

**PURPOSE:** Preference scales for activity, budget, schedule, driving. Renamed from ref.concierge_preference_levels.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| preference_type | text | NOT NULL | activity, budget, schedule_density, driving_tolerance |
| level_code | text | NOT NULL | Level code |
| level_name | text | NOT NULL | Display name |
| level_order | integer | NOT NULL | 1=lowest, 5=highest |
| description | text | | Level description |

**Unique Constraint:** (preference_type, level_code)

**Example Levels:**
- activity: sedentary, light, moderate, active, very_active
- budget: budget, moderate, upscale, luxury, ultra_luxury
- schedule_density: relaxed, light, moderate, packed, intensive
- driving_tolerance: minimal, short, moderate, extensive, unlimited

---

### 14.5 concierge.guest_preferences

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| guest_id | uuid | FK → directory.guests, NOT NULL, UNIQUE | Guest reference |
| activity_level_id | uuid | FK → preference_levels | Activity preference |
| budget_level_id | uuid | FK → preference_levels | Budget preference |
| schedule_density_id | uuid | FK → preference_levels | Pace preference |
| driving_tolerance_id | uuid | FK → preference_levels | Driving tolerance |
| interests | uuid[] | | Interest references |
| dietary_restrictions | text[] | | Dietary needs |
| limitations | text[] | | Physical limitations |
| preferred_cuisine | text[] | | Preferred cuisines |
| group_composition | text | | couple, family, group |
| children_ages | integer[] | | Ages of children |
| special_occasions | text | | Celebrations |
| notes | text | | Preference notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 14.6-14.27 Additional Concierge Tables

| Table | Purpose |
|-------|---------|
| concierge.guest_surveys | Survey responses |
| concierge.survey_questions | Survey question definitions |
| concierge.survey_responses | Individual survey answers |
| concierge.itineraries | Guest itinerary plans |
| concierge.itinerary_items | Itinerary activities |
| concierge.recommendations | AI recommendations |
| concierge.recommendation_feedback | Recommendation ratings |
| concierge.bookings | Activity/service bookings |
| concierge.booking_confirmations | Booking confirmation tracking |
| concierge.service_providers | Local service providers |
| concierge.service_offerings | Available services |
| concierge.service_requests | Guest service requests |
| concierge.request_fulfillments | Request completion tracking |
| concierge.local_tips | Local area tips |
| concierge.attractions | Local attractions |
| concierge.restaurants | Restaurant recommendations |
| concierge.activities | Activity recommendations |
| concierge.special_occasions | Guest special events |
| concierge.welcome_packages | Welcome package configs |
| concierge.amenity_requests | Amenity request tracking |
| concierge.transportation | Transportation arrangements |
| concierge.grocery_orders | Grocery stocking orders |
| concierge.experience_ratings | Experience feedback |

---

## 15. FINANCE Schema (18 tables)

**Purpose:** Accounting, trust accounts, owner statements, and payroll.

---

### 15.1 finance.transactions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| transaction_id | text | NOT NULL, UNIQUE | Business ID: TXN-NNNNNNNN |
| transaction_type | text | NOT NULL | revenue, expense, transfer, adjustment |
| transaction_date | date | NOT NULL | Transaction date |
| posted_date | date | | When posted |
| amount | numeric(12,2) | NOT NULL | Amount (signed) |
| currency_code | text | DEFAULT 'USD' | Currency |
| description | text | | Description |
| memo | text | | Internal memo |
| account_id | uuid | FK → accounts | Account reference |
| property_id | uuid | FK → property.properties | Property context |
| reservation_id | uuid | FK → reservations.reservations | Reservation context |
| homeowner_id | uuid | FK → directory.homeowners | Owner context |
| vendor_id | uuid | FK → directory.companies | Vendor context |
| contact_id | uuid | FK → directory.contacts | Contact context |
| category_code | text | | Category code |
| reference_type | text | | ticket, claim, invoice |
| reference_id | uuid | | Reference record |
| external_id | text | | External system ID |
| qbo_id | text | | QuickBooks ID |
| status | text | DEFAULT 'pending' | pending, posted, reconciled, void |
| voided_at | timestamptz | | If voided |
| voided_reason | text | | Why voided |
| created_by_id | uuid | FK → team.team_directory | Creator |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 15.2-15.18 Additional Finance Tables

| Table | Purpose |
|-------|---------|
| finance.transaction_lines | Transaction line items |
| finance.accounts | Chart of accounts |
| finance.account_balances | Account balance tracking |
| finance.trust_accounts | Trust account management |
| finance.trust_transactions | Trust account movements |
| finance.owner_statements | Owner statement headers |
| finance.owner_statement_lines | Statement line items |
| finance.owner_payouts | Owner payout tracking |
| finance.vendor_payments | Vendor payment tracking |
| finance.invoices | Invoice management |
| finance.invoice_lines | Invoice line items |
| finance.expenses | Expense tracking |
| finance.expense_receipts | Expense receipt links |
| finance.budgets | Budget definitions |
| finance.budget_lines | Budget line items |
| finance.payroll_runs | Payroll processing |
| finance.payroll_items | Payroll line items |

---

# PART 4: BRAND_MARKETING, PROPERTY_LISTINGS SCHEMAS

---

## 16. BRAND_MARKETING Schema (24 tables)

**Purpose:** Company brand assets and guest marketing campaigns.

---

### 16.1-16.24 Brand Marketing Tables

| Table | Purpose |
|-------|---------|
| brand_marketing.brand_assets | Brand asset library |
| brand_marketing.brand_guidelines | Brand style guides |
| brand_marketing.brand_colors | Brand color palettes |
| brand_marketing.brand_fonts | Brand typography |
| brand_marketing.brand_templates | Branded templates |
| brand_marketing.campaigns | Marketing campaigns |
| brand_marketing.campaign_audiences | Campaign targeting |
| brand_marketing.campaign_content | Campaign creative |
| brand_marketing.campaign_channels | Campaign distribution |
| brand_marketing.campaign_metrics | Campaign performance |
| brand_marketing.email_lists | Email list management |
| brand_marketing.email_subscribers | Subscriber tracking |
| brand_marketing.social_accounts | Social media accounts |
| brand_marketing.social_posts | Social media content |
| brand_marketing.social_metrics | Social media analytics |
| brand_marketing.content_calendar | Content planning |
| brand_marketing.content_pieces | Content library |
| brand_marketing.seo_keywords | SEO keyword tracking |
| brand_marketing.seo_rankings | SEO rank tracking |
| brand_marketing.ad_campaigns | Paid advertising |
| brand_marketing.ad_creatives | Ad creative assets |
| brand_marketing.ad_performance | Ad performance metrics |
| brand_marketing.referral_programs | Referral program configs |
| brand_marketing.referrals | Referral tracking |

---

## 17. PROPERTY_LISTINGS Schema (23 tables)

**Purpose:** Listing content and distribution to OTA channels.

---

### 17.1 property_listings.listings

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| listing_id | text | NOT NULL, UNIQUE | Business ID: LST-NNNNNN |
| property_id | uuid | FK → property.properties, NOT NULL, UNIQUE | Property reference |
| internal_name | text | NOT NULL | Internal name |
| primary_title | text | NOT NULL | Primary listing title |
| primary_description | text | NOT NULL | Primary description |
| bedrooms_display | text | | Bedrooms display |
| bathrooms_display | text | | Bathrooms display |
| sleeps_display | text | | Sleeps display |
| property_type_display | text | | Property type display |
| status | text | DEFAULT 'draft' | draft, active, paused, archived |
| is_published | boolean | DEFAULT false | Published? |
| published_at | timestamptz | | When published |
| quality_score | integer | | Listing quality score |
| completeness_score | integer | | Completeness % |
| seo_score | integer | | SEO score |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 17.2-17.23 Additional Listings Tables

| Table | Purpose |
|-------|---------|
| property_listings.listing_titles | Title variations |
| property_listings.listing_descriptions | Description variations |
| property_listings.listing_photos | Photo management |
| property_listings.listing_amenities | Amenity mappings |
| property_listings.listing_rules | House rule mappings |
| property_listings.listing_pricing | Pricing configurations |
| property_listings.listing_availability | Availability rules |
| property_listings.listing_minimum_stays | Min stay rules |
| property_listings.channel_listings | Channel-specific listings |
| property_listings.channel_mappings | Field mappings per channel |
| property_listings.channel_sync_logs | Sync status tracking |
| property_listings.channel_errors | Sync error tracking |
| property_listings.listing_scores | Listing quality scores |
| property_listings.listing_performance | Listing performance metrics |
| property_listings.listing_reviews_summary | Review aggregations |
| property_listings.seo_content | SEO-optimized content |
| property_listings.virtual_tours | Virtual tour links |
| property_listings.floor_plans | Floor plan assets |
| property_listings.neighborhood_content | Neighborhood descriptions |
| property_listings.listing_promotions | Promotional content |
| property_listings.listing_badges | Badge/certification tracking |
| property_listings.competitor_listings | Competitor tracking |

---

# PART 5: EXTERNAL, HOMEOWNER_ACQUISITION SCHEMAS

---

## 18. EXTERNAL Schema (6 tables)

**Purpose:** External market intelligence from public data sources.

---

### 18.1 external.properties

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| tmk | text | NOT NULL, UNIQUE | Tax Map Key (primary key) |
| property_type | text | | condo, house, land |
| address | text | | Street address |
| city | text | | City |
| zip_code | text | | ZIP code |
| area_id | uuid | FK → geo.areas | Area reference |
| bedrooms | integer | | Bedrooms |
| bathrooms | numeric(3,1) | | Bathrooms |
| building_sqft | integer | | Building size |
| land_sqft | integer | | Land size |
| year_built | integer | | Year built |
| assessed_value | numeric(12,2) | | Tax assessed value |
| last_sale_date | date | | Last sale date |
| last_sale_price | numeric(12,2) | | Last sale price |
| current_owner | text | | Current owner name |
| owner_mailing_address | text | | Owner mailing address |
| is_vacation_rental | boolean | | Appears to be VR? |
| is_managed_by_us | boolean | DEFAULT false | Our property? |
| our_property_id | uuid | FK → property.properties | If ours |
| data_source | text | | county, mls, scrape |
| last_updated_at | timestamptz | | Last data update |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 18.2 external.property_managers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| tmk | text | FK → properties, NOT NULL | Property reference |
| manager_name | text | | PM company name |
| manager_contact | text | | PM contact info |
| first_seen_date | date | NOT NULL | When first seen |
| last_seen_date | date | | Most recent |
| is_current | boolean | DEFAULT true | Current PM? |
| change_detected_at | timestamptz | | PM change detected |
| is_hot_lead | boolean | DEFAULT false | Hot lead? |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 18.3-18.6 Additional External Tables

| Table | Purpose |
|-------|---------|
| external.property_sales | County sale records (hot leads) |
| external.property_reviews | Scraped reviews with sentiment |
| external.property_pricing | Competitor pricing snapshots |
| external.competitive_sets | Our properties vs competitors |

---

## 19. HOMEOWNER_ACQUISITION Schema (11 tables)

**Purpose:** Owner pipeline and onboarding workflow.

---

### 19.1 homeowner_acquisition.prospects

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| prospect_id | text | NOT NULL, UNIQUE | Business ID: PROS-NNNNNN |
| contact_id | uuid | FK → directory.contacts | Contact if created |
| first_name | text | | First name |
| last_name | text | | Last name |
| company_name | text | | If entity |
| email | text | | Email |
| phone | text | | Phone |
| mailing_address | text | | Mailing address |
| status | text | DEFAULT 'new' | new, contacted, qualified, proposal, negotiation, won, lost |
| lead_score | integer | | Lead score (1-100) |
| lead_temperature | text | | cold, warm, hot |
| assigned_to_id | uuid | FK → team.team_directory | Assigned salesperson |
| source_id | uuid | FK → lead_sources | Lead source |
| source_detail | text | | Source details |
| first_contact_date | date | | First contact |
| last_contact_date | date | | Most recent contact |
| expected_close_date | date | | Expected close |
| lost_reason | text | | If lost |
| lost_to_competitor | text | | Which competitor |
| notes | text | | Notes |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 19.2-19.11 Additional Acquisition Tables

| Table | Purpose |
|-------|---------|
| homeowner_acquisition.prospect_properties | Properties in pipeline |
| homeowner_acquisition.lead_sources | Lead source reference |
| homeowner_acquisition.lead_activities | Activity log |
| homeowner_acquisition.proposals | Management proposals |
| homeowner_acquisition.proposal_versions | Proposal history |
| homeowner_acquisition.contracts | Signed contracts |
| homeowner_acquisition.onboarding_tasks | Task templates |
| homeowner_acquisition.onboarding_progress | Task completion |
| homeowner_acquisition.property_assessments | Property evaluations |
| homeowner_acquisition.revenue_projections | Revenue forecasts |

---

# PART 6: SECURE, ANALYTICS, PORTAL SCHEMAS

---

## 20. SECURE Schema (5 tables)

**Purpose:** Sensitive/encrypted data storage.

---

### 20.1 secure.payment_methods

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| contact_id | uuid | FK → directory.contacts, NOT NULL | Contact reference |
| payment_type | text | NOT NULL | credit_card, bank_account, paypal |
| last_four | text | | Last 4 digits |
| card_brand | text | | visa, mastercard, amex |
| expiry_month | integer | | Expiry month |
| expiry_year | integer | | Expiry year |
| billing_name | text | | Name on card |
| billing_address | text | | Billing address |
| token | text | | Payment token (encrypted) |
| is_default | boolean | DEFAULT false | Default payment? |
| is_verified | boolean | DEFAULT false | Verified? |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 20.2-20.5 Additional Secure Tables

| Table | Purpose |
|-------|---------|
| secure.bank_accounts | Encrypted bank data |
| secure.ssn_data | Encrypted SSN data |
| secure.access_credentials | Encrypted property credentials |
| secure.audit_logs | Security audit trail |

---

## 21. ANALYTICS Schema (5 tables)

**Purpose:** Materialized views and analytics dashboards.

---

### 21.1-21.5 Analytics Materialized Views

| Table | Purpose |
|-------|---------|
| analytics.property_performance_mv | Property metrics |
| analytics.guest_lifetime_value_mv | Guest LTV calculations |
| analytics.revenue_summary_mv | Revenue rollups |
| analytics.occupancy_trends_mv | Occupancy analysis |
| analytics.operational_kpis_mv | KPI dashboards |

---

## 22. PORTAL Schema (6 tables)

**Purpose:** User authentication, sessions, and RBAC for all portals.

---

### 22.1 portal.users

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| user_id | text | NOT NULL, UNIQUE | Business ID: USR-NNNNNN |
| contact_id | uuid | FK → directory.contacts, UNIQUE | Contact reference |
| email | text | NOT NULL, UNIQUE | Login email |
| password_hash | text | | Hashed password |
| user_type | text | NOT NULL | guest, homeowner, team, admin |
| status | text | DEFAULT 'pending' | pending, active, suspended, locked |
| email_verified | boolean | DEFAULT false | Email verified? |
| email_verified_at | timestamptz | | When verified |
| phone_verified | boolean | DEFAULT false | Phone verified? |
| mfa_enabled | boolean | DEFAULT false | MFA enabled? |
| mfa_method | text | | totp, sms |
| last_login_at | timestamptz | | Last login |
| last_login_ip | text | | Last login IP |
| failed_login_count | integer | DEFAULT 0 | Failed attempts |
| locked_until | timestamptz | | Lock expiry |
| password_changed_at | timestamptz | | Password change |
| must_change_password | boolean | DEFAULT false | Force change? |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

---

### 22.2 portal.sessions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| user_id | uuid | FK → users, NOT NULL | User reference |
| session_token | text | NOT NULL, UNIQUE | JWT token |
| refresh_token | text | UNIQUE | Refresh token |
| device_info | jsonb | | Device information |
| ip_address | text | | IP address |
| user_agent | text | | User agent |
| started_at | timestamptz | DEFAULT now() | Session start |
| expires_at | timestamptz | NOT NULL | Expiration |
| last_activity_at | timestamptz | | Last activity |
| is_active | boolean | DEFAULT true | Active? |
| revoked_at | timestamptz | | If revoked |
| revoked_reason | text | | Why revoked |

---

### 22.3 portal.roles

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| role_code | text | NOT NULL, UNIQUE | GUEST, HOMEOWNER, TEAM_MEMBER, ADMIN |
| role_name | text | NOT NULL | Display name |
| description | text | | Role description |
| is_system | boolean | DEFAULT false | System role? |
| parent_role_id | uuid | FK → roles | Parent role |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |

---

### 22.4 portal.permissions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| role_id | uuid | FK → roles, NOT NULL | Role reference |
| resource | text | NOT NULL | Resource name |
| action | text | NOT NULL | read, write, delete, admin |
| scope | text | DEFAULT 'own' | own, team, all |
| conditions | jsonb | | Additional conditions |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | DEFAULT now() | Record created |

**Unique Constraint:** (role_id, resource, action, scope)

---

### 22.5 portal.user_roles

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| user_id | uuid | FK → users, NOT NULL | User reference |
| role_id | uuid | FK → roles, NOT NULL | Role reference |
| granted_by_id | uuid | FK → users | Who granted |
| granted_at | timestamptz | DEFAULT now() | When granted |
| expires_at | timestamptz | | Expiration |
| is_active | boolean | DEFAULT true | Active? |

**Unique Constraint:** (user_id, role_id)

---

### 22.6 portal.preferences

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | UUIDv7 primary key |
| user_id | uuid | FK → users, NOT NULL | User reference |
| preference_key | text | NOT NULL | Setting key |
| preference_value | text | | Setting value |
| value_type | text | DEFAULT 'string' | string, boolean, json |
| created_at | timestamptz | DEFAULT now() | Record created |
| updated_at | timestamptz | DEFAULT now() | Record updated |

**Unique Constraint:** (user_id, preference_key)

---

# CROSS-SCHEMA DEPENDENCY MAP

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ref.* (39+ tables)                              │
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
│  contacts → guests, homeowners, companies → vendors                         │
│  homeowner_property_relationship, vendor_assignments                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          property.* (28 tables)                              │
│  resorts → properties → rooms → beds, appliances, fixtures                  │
│  cleans, inspections, inspection_questions, inspection_issues               │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        reservations.* (8 tables)                             │
│  reservations → guest_journeys → touchpoints → reviews                      │
│  reservation_fees, reservation_guests, reservation_financials               │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           service.* (30 tables)                              │
│  tickets → ticket_* joins (properties, reservations, costs, events)         │
│  projects → project_properties, project_tickets                             │
│  damage_claims → submissions → approvals/denials/appeals                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            team.* (6 tables)                                 │
│  teams → team_directory → shifts → time_entries → verifications             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          storage.* (4 tables)                                │
│  files → ticket_files, inspection_files, room_files                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         inventory.* (15 tables)                              │
│  inventory_items → room_inventory, owner_inventory, company_inventory       │
│  storage_inventory, linen_* tables                                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

# TABLE COUNT SUMMARY

| Schema | Tables | Status |
|--------|--------|--------|
| directory | 13 | Complete |
| property | 28 | Complete |
| reservations | 8 | Complete |
| service | 30 | Complete |
| team | 6 | Complete |
| storage | 4 | Complete |
| inventory | 15 | Complete |
| ref | 39+ | Complete |
| geo | 5 | Complete |
| ai | 18 | Complete |
| comms | 12 | Complete |
| knowledge | 28 | Complete |
| revenue | 12 | Complete |
| concierge | 24 | Complete |
| finance | 18 | Complete |
| brand_marketing | 24 | Complete |
| property_listings | 23 | Complete |
| external | 6 | Complete |
| homeowner_acquisition | 11 | Complete |
| secure | 5 | Complete |
| analytics | 5 | Complete |
| portal | 6 | Complete |
| **TOTAL** | **~357** | **Complete** |

---

# DESIGN PRINCIPLES

## UUIDv7 Primary Keys
- All tables use UUIDv7 for primary keys
- Time-ordered for efficient indexing
- Globally unique across all systems
- Generated via `gen_random_uuid()` with UUIDv7 extension

## Business ID Patterns
- Human-readable business identifiers
- Sequential within type
- Format: `{PREFIX}-{SEQUENCE}`
- Immutable after creation

## FK Cascade Rules
- CASCADE DELETE for child records (e.g., ticket events when ticket deleted)
- SET NULL for optional references (e.g., assigned_to when team member deleted)
- RESTRICT for critical dependencies (e.g., cannot delete property with reservations)

## Join Table Pattern
- All many-to-many relationships use explicit join tables
- Join tables include metadata (created_at, relationship type)
- Enables audit trail and soft deletes

## Monetary Fields
- All money stored as `numeric(10,2)` or `numeric(12,2)`
- Never store cents as integers
- Currency code stored separately when needed

## Timestamp Standards
- All timestamps are `timestamptz` (timezone-aware)
- Default timezone: Pacific/Honolulu
- `created_at` and `updated_at` on all tables

---

**Document Version:** 4.2 (Final)
**Generated:** December 9, 2025
**Total Schemas:** 22 (excluding staging)
**Total Tables:** ~357
**Sources:**
- V4.1 Separated Schema (V4_1_Separated_Schema_20251208.md)
- 17 Complete Table Inventory documents
- 20+ System Schema Reference Guides
- Service System Final Specification v4
