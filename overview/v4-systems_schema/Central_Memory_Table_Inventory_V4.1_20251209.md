# Central Memory — Complete Table Inventory V4.1

**Date:** 2025-12-09  
**Version:** 4.1  
**Total Schemas Detailed:** 7  
**Total Tables Detailed:** 124  

---

# QUICK REFERENCE

| Schema | Tables | Purpose |
|--------|--------|---------|
| ref | 35 | Reference/lookup tables (type_key) |
| directory | 13 | Contacts, guests, homeowners, vendors |
| property | 30 | Properties, rooms, cleans, inspections |
| service | 30 | Tickets, projects, damage claims |
| team | 6 | Teams, members, shifts, time tracking |
| storage | 4 | File management |
| portal | 6 | Authentication, roles, permissions |

---

# REF SCHEMA (35 tables)

All ref tables follow this standard structure unless noted:

```
Standard Columns:
- id (uuid, PK)
- {name}_code (text, UNIQUE) — lookup key
- {name}_name (text) — display name
- description (text) — what it means
- sort_order (integer) — display order
- is_active (boolean, DEFAULT true)
```

---

## From Directory System (3 tables)

### ref.vendor_category_key
**Purpose:** Vendor service categories for routing and assignment

| Code | Name | Example Vendors |
|------|------|-----------------|
| CLEANING | Cleaning Services | Maid services, deep clean specialists |
| PLUMBING | Plumbing | Licensed plumbers |
| ELECTRICAL | Electrical | Licensed electricians |
| HVAC | HVAC/AC | AC repair, heating |
| APPLIANCE | Appliance Repair | Washer/dryer, refrigerator |
| LANDSCAPING | Landscaping | Lawn care, tree service |
| POOL | Pool Service | Pool cleaning, equipment |
| PEST | Pest Control | Exterminators |
| LOCKSMITH | Locksmith | Lock repair, key cutting |
| HANDYMAN | General Handyman | Minor repairs |
| ROOFING | Roofing | Roof repair |
| PAINTING | Painting | Interior/exterior |
| FLOORING | Flooring | Carpet, tile, hardwood |
| GLASS | Glass/Windows | Window repair, screens |
| GARAGE | Garage Door | Opener repair |
| SECURITY | Security Systems | Alarms, cameras |
| INTERNET | Internet/Cable | WiFi, TV service |
| TRASH | Trash/Hauling | Junk removal |

---

### ref.relationship_type_key
**Purpose:** Contact-to-contact relationship types

| Code | Name | Description |
|------|------|-------------|
| SPOUSE | Spouse/Partner | Married or domestic partner |
| FAMILY | Family Member | Related by blood or marriage |
| ASSISTANT | Assistant | Personal or executive assistant |
| COOWNER | Co-Owner | Joint property ownership |
| EMERGENCY | Emergency Contact | Emergency contact person |
| ACCOUNTANT | Accountant | Financial advisor |
| ATTORNEY | Attorney | Legal representative |
| PROPERTY_MGR | Property Manager | External property manager |
| REFERRAL | Referral Source | Who referred them |
| EMPLOYER | Employer | Work relationship |

---

### ref.contact_tag_key
**Purpose:** Contact classification tags

| Code | Name | Description |
|------|------|-------------|
| VIP | VIP | High-value, special treatment |
| HIGH_VALUE | High Value | High lifetime value |
| AT_RISK | At Risk | May churn, needs attention |
| INFLUENCER | Influencer | Social media presence |
| REPEAT | Repeat Guest | Multiple bookings |
| REFERRER | Referrer | Sends referrals |
| PROBLEM | Problem | History of issues |
| CORPORATE | Corporate | Business traveler |
| LOCAL | Local | Lives nearby |
| INTERNATIONAL | International | Non-US resident |

---

## From Property System (10 tables)

### ref.room_type_key
**Purpose:** Room type classification

| Code | Name | Typical Use |
|------|------|-------------|
| MBR | Master Bedroom | Primary bedroom with ensuite |
| BR | Bedroom | Standard bedroom |
| GBR | Guest Bedroom | Secondary guest room |
| BTH | Bathroom | Full bathroom |
| HBTH | Half Bath | Toilet + sink only |
| MBTH | Master Bath | Ensuite to master |
| KIT | Kitchen | Main kitchen |
| LR | Living Room | Main living area |
| DR | Dining Room | Formal dining |
| DEN | Den/Office | Home office or den |
| FAM | Family Room | Secondary living area |
| LOFT | Loft | Open upper area |
| GAR | Garage | Vehicle storage |
| LAN | Lanai/Patio | Covered outdoor |
| DECK | Deck | Outdoor deck |
| POOL | Pool Area | Pool and surroundings |
| LAUN | Laundry | Washer/dryer area |
| STOR | Storage | Storage closet/room |
| ENTRY | Entry/Foyer | Main entrance |
| HALL | Hallway | Connecting hallway |

---

### ref.bed_type_key
**Purpose:** Bed type classification

| Code | Name | Sleeps | Width |
|------|------|--------|-------|
| KING | King | 2 | 76" |
| CKING | Cal King | 2 | 72" |
| QUEEN | Queen | 2 | 60" |
| FULL | Full/Double | 2 | 54" |
| TWIN | Twin | 1 | 38" |
| TWIN_XL | Twin XL | 1 | 38" |
| BUNK_TT | Bunk Twin/Twin | 2 | 38" |
| BUNK_TF | Bunk Twin/Full | 3 | varies |
| TRUNDLE | Trundle | 1 | 38" |
| SOFA_Q | Sofa Bed Queen | 2 | 60" |
| SOFA_F | Sofa Bed Full | 2 | 54" |
| DAYBED | Daybed | 1 | 38" |
| MURPHY_Q | Murphy Queen | 2 | 60" |
| CRIB | Crib | 1 | - |
| PAC_PLAY | Pack-n-Play | 1 | - |
| AIR_Q | Air Mattress Queen | 2 | 60" |

---

### ref.cleaning_type_key
**Purpose:** Clean type classification

| Code | Name | Typical Duration | Billing |
|------|------|------------------|---------|
| TURNOVER | Turnover Clean | 2-4 hrs | Guest |
| DEEP | Deep Clean | 4-8 hrs | Owner |
| MIDSTAY | Mid-Stay Clean | 1-2 hrs | Guest |
| CHECKOUT | Checkout Only | 1 hr | Guest |
| OWNER | Owner Prep | 2-4 hrs | Owner |
| MOVE_IN | Move-In Ready | 4-8 hrs | Owner |
| SPRING | Spring Clean | 6-10 hrs | Owner |
| POST_CONST | Post-Construction | 8+ hrs | Owner |
| TOUCH_UP | Touch-Up | 30 min | Company |

---

### ref.inspection_category_key
**Purpose:** Inspection question categories

| Code | Name | Description |
|------|------|-------------|
| CLEAN | Cleanliness | Cleaning quality checks |
| MAINT | Maintenance | Property condition |
| INVEN | Inventory | Item presence/count |
| SAFETY | Safety | Safety equipment checks |
| PHOTO | Photo Documentation | Required photos |
| SETUP | Guest Setup | Amenity staging |
| EXTERIOR | Exterior | Outside property |
| HVAC | HVAC/Climate | AC, heating systems |
| PLUMB | Plumbing | Water systems |
| ELEC | Electrical | Power, lighting |

---

### ref.issue_severity_key
**Purpose:** Issue/deficiency severity levels

| Code | Name | SLA Hours | Auto-Ticket | Color |
|------|------|-----------|-------------|-------|
| CRITICAL | Critical | 4 | Yes | Red |
| HIGH | High | 24 | Yes | Orange |
| MEDIUM | Medium | 48 | Optional | Yellow |
| LOW | Low | 72 | No | Blue |
| INFO | Informational | None | No | Gray |

---

### ref.appliance_type_key
**Purpose:** Appliance classification

| Code | Name | Typical Location |
|------|------|------------------|
| FRIDGE | Refrigerator | Kitchen |
| FRIDGE_MINI | Mini Fridge | Bedroom, Bar |
| FREEZER | Standalone Freezer | Garage |
| STOVE | Stove/Range | Kitchen |
| OVEN | Wall Oven | Kitchen |
| MICRO | Microwave | Kitchen |
| DISH | Dishwasher | Kitchen |
| WASH | Washer | Laundry |
| DRY | Dryer | Laundry |
| DISP | Garbage Disposal | Kitchen |
| TRASH_COMP | Trash Compactor | Kitchen |
| ICE | Ice Maker | Kitchen, Bar |
| WINE | Wine Cooler | Kitchen, Bar |
| COFFEE | Coffee Maker | Kitchen |
| TV | Television | Various |
| SOUND | Sound System | Living Areas |

---

### ref.fixture_type_key
**Purpose:** Plumbing fixture classification

| Code | Name | Description |
|------|------|-------------|
| SINK | Sink | Any sink |
| TOILET | Toilet | Commode |
| SHOWER | Shower | Shower only |
| TUB | Bathtub | Tub only |
| TUB_SHOW | Tub/Shower Combo | Combined unit |
| FAUCET | Faucet | Any faucet |
| BIDET | Bidet | Standalone or attachment |
| HOT_TUB | Hot Tub | Spa/jacuzzi |
| OUTDOOR_SHOW | Outdoor Shower | External shower |

---

### ref.surface_type_key
**Purpose:** Surface classification for cleaning/maintenance

| Code | Name | Typical Materials |
|------|------|-------------------|
| FLOOR | Floor | Tile, wood, carpet |
| COUNTER | Countertop | Granite, quartz, laminate |
| BACKSPLASH | Backsplash | Tile, stone |
| WALL | Wall | Paint, wallpaper |
| CEILING | Ceiling | Drywall, popcorn |
| CABINET | Cabinet | Wood, laminate |
| WINDOW | Window | Glass |
| MIRROR | Mirror | Glass |
| DOOR | Door | Wood, glass |

---

### ref.amenity_type_key
**Purpose:** Property amenity classification

| Code | Name | Category |
|------|------|----------|
| WIFI | WiFi | Technology |
| POOL | Pool | Recreation |
| POOL_HEAT | Heated Pool | Recreation |
| HOT_TUB | Hot Tub | Recreation |
| AC | Air Conditioning | Climate |
| HEAT | Heating | Climate |
| PARKING | Parking | Access |
| GARAGE | Garage Parking | Access |
| EV_CHARGE | EV Charger | Access |
| GYM | Gym/Fitness | Recreation |
| BBQ | BBQ/Grill | Outdoor |
| FIREPLACE | Fireplace | Climate |
| WASHER | Washer | Laundry |
| DRYER | Dryer | Laundry |
| KITCHEN | Full Kitchen | Kitchen |
| OCEAN_VIEW | Ocean View | View |
| MTN_VIEW | Mountain View | View |
| BEACH_ACC | Beach Access | Access |
| PET_FRIEND | Pet Friendly | Policy |
| WHEELCHAIR | Wheelchair Access | Accessibility |

---

### ref.safety_item_type_key
**Purpose:** Safety equipment classification

| Code | Name | Check Frequency | Required |
|------|------|-----------------|----------|
| SMOKE | Smoke Detector | Monthly | Yes |
| CO | CO Detector | Monthly | Yes |
| FIRE_EXT | Fire Extinguisher | Annual | Yes |
| FIRST_AID | First Aid Kit | Annual | Recommended |
| FLASH | Flashlight | Annual | Recommended |
| POOL_ALARM | Pool Alarm | Monthly | If pool |
| DOOR_ALARM | Door Alarm | Monthly | If pool |
| LIFE_RING | Life Ring | Annual | If pool |
| AED | AED | Annual | Optional |
| SAFE | Safe | As needed | Optional |

---

## From Service System (8 tables)

### ref.ticket_type_key
**Purpose:** Ticket type classification

| type_code | ticket_type | type_id_prefix | requires_property | requires_reservation |
|-----------|-------------|----------------|-------------------|---------------------|
| PC | Property Care | TIK-PC | Yes | No |
| RSV | Reservation | TIK-RSV | No | Yes |
| ADM | Administrative | TIK-ADM | No | No |
| ACCT | Accounting | TIK-ACCT | No | No |

**Additional Columns:**
- default_labor_allocation (text): owner, company
- default_sla_hours (integer)

---

### ref.ticket_category_key
**Purpose:** Compound category codes per ticket type

| category_code | ticket_type_code | category_name |
|---------------|------------------|---------------|
| PC-PLUMBING | PC | Plumbing Issue |
| PC-ELECTRICAL | PC | Electrical Issue |
| PC-HVAC | PC | HVAC/AC Issue |
| PC-APPLIANCE | PC | Appliance Issue |
| PC-STRUCTURAL | PC | Structural Issue |
| PC-PEST | PC | Pest Control |
| PC-POOL | PC | Pool/Spa Issue |
| PC-LANDSCAPING | PC | Landscaping |
| PC-CLEANING | PC | Cleaning Issue |
| PC-GENERAL | PC | General Maintenance |
| RSV-EARLY_CHECK_IN | RSV | Early Check-In Request |
| RSV-LATE_CHECKOUT | RSV | Late Checkout Request |
| RSV-COMPLAINT | RSV | Guest Complaint |
| RSV-AMENITY | RSV | Amenity Request |
| RSV-DAMAGE | RSV | Guest Damage Report |
| RSV-REFUND | RSV | Refund Request |
| RSV-CANCELLATION | RSV | Cancellation |
| RSV-MODIFICATION | RSV | Booking Modification |
| RSV-GENERAL | RSV | General Inquiry |
| ADM-HR | ADM | HR/Personnel |
| ADM-TRAINING | ADM | Training |
| ADM-POLICY | ADM | Policy Update |
| ADM-VENDOR | ADM | Vendor Management |
| ADM-GENERAL | ADM | General Admin |
| ACCT-INVOICE | ACCT | Invoice Issue |
| ACCT-PAYMENT | ACCT | Payment Issue |
| ACCT-STATEMENT | ACCT | Statement Issue |
| ACCT-TAX | ACCT | Tax Related |
| ACCT-GENERAL | ACCT | General Accounting |

**Additional Columns:**
- default_team_id (uuid): Auto-assign team
- default_priority (text)
- requires_vendor (boolean)

---

### ref.ticket_priority_key
**Purpose:** Priority levels with SLA

| priority_code | priority_name | sla_hours | color |
|---------------|---------------|-----------|-------|
| CRITICAL | Critical | 4 | #DC2626 |
| HIGH | High | 24 | #F97316 |
| MEDIUM | Medium | 48 | #EAB308 |
| LOW | Low | 72 | #3B82F6 |

---

### ref.label_key
**Purpose:** Ticket labels/tags

| label_code | label_name | label_group | color |
|------------|------------|-------------|-------|
| URGENT | Urgent | status | #DC2626 |
| WAITING_PARTS | Waiting for Parts | workflow | #F97316 |
| WAITING_VENDOR | Waiting for Vendor | workflow | #F97316 |
| WAITING_OWNER | Waiting for Owner | workflow | #EAB308 |
| OWNER_AWARE | Owner Aware | visibility | #3B82F6 |
| GUEST_IMPACT | Guest Impacted | status | #DC2626 |
| RECURRING | Recurring Issue | workflow | #8B5CF6 |
| BILLABLE | Billable | billing | #10B981 |
| WARRANTY | Under Warranty | billing | #10B981 |
| INSURANCE | Insurance Claim | billing | #10B981 |

---

### ref.damage_category_key
**Purpose:** Damage type classification

| category_code | category_name | typical_recovery_rate | requires_photos |
|---------------|---------------|----------------------|-----------------|
| FURNITURE | Furniture Damage | 0.60 | Yes |
| APPLIANCE | Appliance Damage | 0.50 | Yes |
| FLOORING | Flooring Damage | 0.70 | Yes |
| WALL | Wall Damage | 0.80 | Yes |
| PLUMBING | Plumbing Damage | 0.50 | Yes |
| LINENS | Linens/Bedding | 0.40 | Yes |
| ELECTRONICS | Electronics | 0.30 | Yes |
| DECOR | Decor/Art | 0.40 | Yes |
| OUTDOOR | Outdoor/Patio | 0.50 | Yes |
| KITCHEN | Kitchen Items | 0.50 | Yes |
| EXCESSIVE_CLEAN | Excessive Cleaning | 0.90 | Yes |
| SMOKING | Smoking Violation | 0.80 | Yes |
| PET | Unauthorized Pet | 0.70 | Yes |
| POOL | Pool/Spa Damage | 0.60 | Yes |

---

### ref.claim_submission_type_key
**Purpose:** Where claims are submitted

| type_code | type_name | typical_deadline_days | typical_response_days |
|-----------|-----------|----------------------|----------------------|
| AIRBNB | Airbnb Resolution | 14 | 5 |
| VRBO | VRBO Resolution | 14 | 7 |
| INSURANCE | Insurance Claim | 30 | 30 |
| GUEST_DIRECT | Guest Direct | 30 | 14 |
| CREDIT_CARD | Credit Card Dispute | 60 | 45 |
| SECURITY_DEP | Security Deposit | 14 | 7 |
| OTHER_OTA | Other OTA | 14 | 14 |

**Additional Columns:**
- documentation_requirements (text)

---

### ref.denial_category_key
**Purpose:** Claim denial reasons

| category_code | category_name | is_appealable |
|---------------|---------------|---------------|
| INSUFFICIENT_DOCS | Insufficient Documentation | Yes |
| PRE_EXISTING | Pre-Existing Damage | Yes |
| NOT_COVERED | Not Covered by Policy | No |
| POLICY_EXCLUSION | Policy Exclusion | No |
| LATE_SUBMISSION | Late Submission | Sometimes |
| NO_PROOF_GUEST | Cannot Prove Guest Caused | Yes |
| WEAR_AND_TEAR | Normal Wear and Tear | No |
| EXCEEDED_LIMIT | Exceeds Coverage Limit | Partial |
| DUPLICATE | Duplicate Claim | No |

**Additional Columns:**
- prevention_guidance (text)

---

### ref.activity_types
**Purpose:** Time entry activity classification

| activity_code | activity_name | is_billable | default_allocation |
|---------------|---------------|-------------|-------------------|
| CLEANING | Cleaning | Yes | guest |
| INSPECTION | Inspection | Yes | company |
| MAINTENANCE | Maintenance | Yes | owner |
| REPAIR | Repair Work | Yes | owner |
| TRAVEL | Travel Time | Depends | split |
| ADMIN | Administrative | No | company |
| TRAINING | Training | No | company |
| MEETING | Meeting | No | company |
| GUEST_SERVICE | Guest Service | Yes | company |
| INVENTORY | Inventory Work | Yes | company |

---

## From Guest Journey System (5 tables)

### ref.journey_stages
**Purpose:** Guest journey stage definitions

| stage_code | stage_name | stage_order | typical_days_before |
|------------|------------|-------------|---------------------|
| BOOKING | Booking | 1 | varies |
| PRE_ARRIVAL | Pre-Arrival | 2 | 14-1 |
| CHECK_IN | Check-In | 3 | 0 |
| IN_STAY | In-Stay | 4 | during |
| CHECK_OUT | Check-Out | 5 | 0 |
| POST_STAY | Post-Stay | 6 | 1-14 |
| LOYALTY | Loyalty/Re-engagement | 7 | 30+ |

---

### ref.touchpoint_types
**Purpose:** Communication/action touchpoint types

| touchpoint_code | touchpoint_name | channel | is_automated |
|-----------------|-----------------|---------|--------------|
| BOOKING_CONFIRM | Booking Confirmation | email | Yes |
| WELCOME_EMAIL | Welcome Email | email | Yes |
| PRE_ARRIVAL_1 | Pre-Arrival (14 days) | email | Yes |
| PRE_ARRIVAL_2 | Pre-Arrival (3 days) | email | Yes |
| CHECK_IN_INST | Check-In Instructions | email/sms | Yes |
| DAY_OF_ARRIVAL | Day of Arrival | sms | Yes |
| WELCOME_CALL | Welcome Call | phone | No |
| MID_STAY_CHECK | Mid-Stay Check-In | sms | Yes |
| CHECKOUT_REMIND | Checkout Reminder | email/sms | Yes |
| CHECKOUT_INST | Checkout Instructions | email | Yes |
| THANK_YOU | Thank You | email | Yes |
| REVIEW_REQUEST | Review Request | email | Yes |
| FEEDBACK_SURVEY | Feedback Survey | email | Yes |
| RETURN_OFFER | Return Guest Offer | email | Yes |

---

### ref.stage_required_touchpoints
**Purpose:** Which touchpoints are required per stage

| stage_code | touchpoint_code | is_required | sequence_order |
|------------|-----------------|-------------|----------------|
| BOOKING | BOOKING_CONFIRM | Yes | 1 |
| PRE_ARRIVAL | WELCOME_EMAIL | Yes | 1 |
| PRE_ARRIVAL | PRE_ARRIVAL_1 | Yes | 2 |
| CHECK_IN | CHECK_IN_INST | Yes | 1 |
| POST_STAY | THANK_YOU | Yes | 1 |
| POST_STAY | REVIEW_REQUEST | Yes | 2 |

---

### ref.fee_types
**Purpose:** Fee type definitions

| fee_code | fee_name | is_taxable | is_owner_revenue |
|----------|----------|------------|------------------|
| CLEAN | Cleaning Fee | Yes | Partial |
| PET | Pet Fee | Yes | Yes |
| RESORT | Resort Fee | Yes | Partial |
| DAMAGE_WAIVER | Damage Waiver | No | No |
| EARLY_CHECK_IN | Early Check-In | Yes | Yes |
| LATE_CHECKOUT | Late Checkout | Yes | Yes |
| EXTRA_GUEST | Extra Guest | Yes | Yes |
| PARKING | Parking | Yes | Yes |
| POOL_HEAT | Pool Heating | Yes | Partial |
| ADMIN | Admin Fee | No | No |

---

### ref.fee_rates
**Purpose:** Fee rate schedules

| fee_code | property_id | effective_date | rate_type | amount |
|----------|-------------|----------------|-----------|--------|
| CLEAN | NULL (default) | 2024-01-01 | flat | 250.00 |
| PET | NULL (default) | 2024-01-01 | flat | 150.00 |
| POOL_HEAT | NULL (default) | 2024-01-01 | per_night | 75.00 |

*Note: property_id NULL = default rate; property_id set = property override*

---

## From Inventory System (1 table)

### ref.inventory_item_types
**Purpose:** Inventory item classification

| type_code | type_name | category | is_consumable | typical_lifespan_months |
|-----------|-----------|----------|---------------|------------------------|
| LINENS_SHEET | Sheets | Linens | No | 24 |
| LINENS_TOWEL | Towels | Linens | No | 18 |
| LINENS_PILLOW | Pillows | Linens | No | 24 |
| LINENS_BLANKET | Blankets | Linens | No | 36 |
| KITCHEN_DISH | Dishes | Kitchen | No | 36 |
| KITCHEN_GLASS | Glassware | Kitchen | No | 24 |
| KITCHEN_UTENSIL | Utensils | Kitchen | No | 36 |
| KITCHEN_COOKWARE | Cookware | Kitchen | No | 48 |
| KITCHEN_APPLIANCE | Small Appliance | Kitchen | No | 36 |
| BATH_SUPPLIES | Bath Supplies | Consumables | Yes | 1 |
| KITCHEN_SUPPLIES | Kitchen Supplies | Consumables | Yes | 1 |
| CLEANING_SUPPLIES | Cleaning Supplies | Consumables | Yes | 1 |
| DECOR | Decor Items | Decor | No | 60 |
| ELECTRONICS | Electronics | Tech | No | 48 |
| FURNITURE | Furniture | Furniture | No | 84 |
| OUTDOOR | Outdoor Items | Outdoor | No | 36 |

---

# DIRECTORY SCHEMA (13 tables)

---

## directory.contacts

**Purpose:** Universal contact hub — every person/organization exists ONCE here  
**Business ID:** CON-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| contact_id | text | UNIQUE, NOT NULL | CON-NNNNNN |
| **Classification** |
| contact_type | text | NOT NULL | individual, company |
| status | text | NOT NULL, DEFAULT 'active' | active, inactive, merged, deceased |
| **Name (Individual)** |
| first_name | text | | First name |
| middle_name | text | | Middle name |
| last_name | text | | Last name |
| preferred_name | text | | Nickname/preferred |
| suffix | text | | Jr, Sr, III |
| **Name (Company)** |
| company_name | text | | Organization name |
| dba_name | text | | Doing business as |
| **Contact Methods** |
| primary_email | text | | Main email |
| secondary_email | text | | Alternate email |
| primary_phone | text | | Main phone |
| secondary_phone | text | | Alternate phone |
| phone_type | text | | mobile, home, work |
| **Address** |
| address_line_1 | text | | Street address |
| address_line_2 | text | | Unit/suite |
| city | text | | City |
| state_province | text | | State/province |
| postal_code | text | | ZIP/postal |
| country_code | text | FK → geo.countries | Country |
| **Preferences** |
| preferred_language | text | DEFAULT 'en' | Language code |
| preferred_contact_method | text | | email, phone, sms |
| timezone | text | | IANA timezone |
| **Communication** |
| email_opt_in | boolean | DEFAULT true | Marketing emails |
| sms_opt_in | boolean | DEFAULT false | SMS messages |
| do_not_contact | boolean | DEFAULT false | No outreach |
| **External IDs** |
| streamline_id | integer | | Streamline contact ID |
| quickbooks_id | text | | QuickBooks customer ID |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |
| created_by | uuid | FK → team.team_directory | Who created |

---

## directory.guests

**Purpose:** Guest-specific extension of contacts  
**Business ID:** GST-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| guest_id | text | UNIQUE, NOT NULL | GST-NNNNNN |
| contact_id | uuid | FK → contacts, NOT NULL | Link to contact |
| **Guest Profile** |
| guest_type | text | DEFAULT 'leisure' | leisure, business, group |
| vip_status | text | | standard, silver, gold, platinum |
| **Travel Preferences** |
| purpose_of_travel | text | | vacation, work, relocation |
| group_size_typical | integer | | Usual party size |
| pet_owner | boolean | DEFAULT false | Travels with pets |
| **Stay History (denormalized)** |
| total_stays | integer | DEFAULT 0 | Count of completed stays |
| total_nights | integer | DEFAULT 0 | Cumulative nights |
| total_revenue | numeric(12,2) | DEFAULT 0 | Lifetime revenue |
| first_stay_date | date | | First booking date |
| last_stay_date | date | | Most recent checkout |
| average_lead_time_days | integer | | Booking lead time |
| **Marketing** |
| acquisition_source | text | | How they found us |
| acquisition_campaign | text | | Specific campaign |
| referral_contact_id | uuid | FK → contacts | Who referred |
| **Ratings (from surveys)** |
| average_nps | numeric(3,1) | | Average NPS score |
| average_rating | numeric(3,2) | | Average satisfaction |
| **External IDs** |
| streamline_guest_id | integer | | Streamline ID |
| airbnb_guest_id | text | | Airbnb ID |
| vrbo_guest_id | text | | VRBO ID |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |

---

## directory.homeowners

**Purpose:** Property owner extension of contacts  
**Business ID:** OWN-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| owner_id | text | UNIQUE, NOT NULL | OWN-NNNNNN |
| contact_id | uuid | FK → contacts, NOT NULL | Link to contact |
| **Owner Type** |
| owner_type | text | NOT NULL | individual, llc, trust, corporation, partnership |
| **Business Entity (if not individual)** |
| entity_name | text | | Legal entity name |
| entity_state | text | | State of formation |
| ein | text | | Employer ID (encrypted) |
| **Tax Info** |
| tax_id_type | text | | ssn, ein, itin |
| tax_id_last_four | text | | Last 4 digits only |
| w9_on_file | boolean | DEFAULT false | W-9 received |
| w9_date | date | | When W-9 received |
| **Banking** |
| payment_method | text | | ach, check, wire |
| bank_name | text | | Bank name |
| account_last_four | text | | Last 4 of account |
| **Communication Preferences** |
| statement_delivery | text | DEFAULT 'email' | email, mail, both |
| statement_frequency | text | DEFAULT 'monthly' | monthly, quarterly |
| report_detail_level | text | DEFAULT 'summary' | summary, detailed |
| **Relationship** |
| contract_start_date | date | | When contracted |
| contract_end_date | date | | If terminated |
| management_fee_rate | numeric(5,4) | | Override rate |
| **External IDs** |
| streamline_owner_id | integer | | Streamline ID |
| quickbooks_vendor_id | text | | QuickBooks vendor ID |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |

---

## directory.companies

**Purpose:** Company/organization extension of contacts  
**Business ID:** CMP-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| company_id | text | UNIQUE, NOT NULL | CMP-NNNNNN |
| contact_id | uuid | FK → contacts, NOT NULL | Link to contact |
| **Classification** |
| company_type | text | NOT NULL | vendor, supplier, partner, ota, insurance, other |
| **Business Details** |
| website | text | | Company website |
| industry | text | | Industry category |
| employee_count | text | | Size range |
| **Licensing** |
| license_number | text | | Business/contractor license |
| license_state | text | | License state |
| license_expiry | date | | When expires |
| **Insurance** |
| insurance_carrier | text | | Insurance company |
| insurance_policy | text | | Policy number |
| insurance_expiry | date | | When expires |
| coi_on_file | boolean | DEFAULT false | Certificate on file |
| coi_date | date | | When COI received |
| **Financial** |
| payment_terms | text | | net_15, net_30, due_on_receipt |
| credit_limit | numeric(10,2) | | Credit limit |
| tax_exempt | boolean | DEFAULT false | Tax exempt |
| **External IDs** |
| quickbooks_vendor_id | text | | QuickBooks vendor ID |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |

---

## directory.vendors

**Purpose:** Vendor-specific extension of companies  
**Business ID:** VND-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| vendor_id | text | UNIQUE, NOT NULL | VND-NNNNNN |
| company_id | uuid | FK → companies, NOT NULL | Link to company |
| **Classification** |
| vendor_category_code | text | FK → ref.vendor_category_key | Primary category |
| secondary_categories | text[] | | Additional categories |
| vendor_tier | text | DEFAULT 'standard' | preferred, standard, backup, emergency_only |
| **Service Area** |
| service_areas | text[] | | Geographic areas served |
| max_travel_miles | integer | | Travel radius |
| **Availability** |
| hours_of_operation | jsonb | | Typical hours |
| emergency_available | boolean | DEFAULT false | After-hours? |
| emergency_rate_multiplier | numeric(3,2) | | Emergency rate premium |
| **Rates** |
| standard_hourly_rate | numeric(10,2) | | Base hourly rate |
| minimum_charge | numeric(10,2) | | Minimum service charge |
| trip_charge | numeric(10,2) | | Trip/dispatch fee |
| **Performance** |
| rating_average | numeric(3,2) | | Average rating |
| rating_count | integer | DEFAULT 0 | Number of ratings |
| jobs_completed | integer | DEFAULT 0 | Total jobs |
| jobs_cancelled | integer | DEFAULT 0 | Cancelled jobs |
| avg_response_time_hours | numeric(5,2) | | Average response |
| **Status** |
| is_active | boolean | DEFAULT true | Active vendor |
| is_approved | boolean | DEFAULT false | Approved to use |
| approved_date | date | | When approved |
| approved_by | uuid | FK → team.team_directory | Who approved |
| **Notes** |
| internal_notes | text | | Internal notes |
| dispatch_notes | text | | For dispatchers |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |

---

## directory.homeowner_property_relationship

**Purpose:** Links homeowners to properties (supports multiple owners per property)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| homeowner_id | uuid | FK → homeowners, NOT NULL | Homeowner |
| property_id | uuid | FK → property.properties, NOT NULL | Property |
| **Ownership** |
| ownership_percentage | numeric(5,2) | DEFAULT 100.00 | Ownership % |
| ownership_type | text | NOT NULL | owner, beneficial_owner, trustee, manager |
| is_primary_contact | boolean | DEFAULT false | Primary for this property |
| **Dates** |
| effective_date | date | NOT NULL | When started |
| end_date | date | | If ended |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |

**UNIQUE CONSTRAINT:** (homeowner_id, property_id, ownership_type)

---

## directory.vendor_assignments

**Purpose:** Assigns vendors to properties by service type

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| vendor_id | uuid | FK → vendors, NOT NULL | Vendor |
| property_id | uuid | FK → property.properties, NOT NULL | Property |
| vendor_category_code | text | FK → ref.vendor_category_key | Service type |
| **Assignment** |
| assignment_type | text | NOT NULL | preferred, backup, do_not_use |
| priority_rank | integer | DEFAULT 1 | 1 = first choice |
| **Rate Overrides** |
| rate_override | numeric(10,2) | | Property-specific rate |
| rate_notes | text | | Rate explanation |
| **Dates** |
| effective_date | date | NOT NULL | When assigned |
| end_date | date | | If ended |
| **Notes** |
| notes | text | | Assignment notes |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |

**UNIQUE CONSTRAINT:** (vendor_id, property_id, vendor_category_code)

---

## directory.contact_groups

**Purpose:** Contact groupings (mailing lists, segments)  
**Business ID:** GRP-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| group_id | text | UNIQUE, NOT NULL | GRP-NNNNNN |
| **Group Info** |
| group_name | text | NOT NULL | Display name |
| group_type | text | NOT NULL | static, dynamic |
| description | text | | What this group is for |
| **Dynamic Rules (if type = dynamic)** |
| filter_rules | jsonb | | JSON rules for membership |
| **Status** |
| is_active | boolean | DEFAULT true | Active group |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |
| created_by | uuid | FK → team.team_directory | Who created |

---

## directory.contact_group_members

**Purpose:** Contact membership in groups (for static groups)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| group_id | uuid | FK → contact_groups, NOT NULL | Group |
| contact_id | uuid | FK → contacts, NOT NULL | Contact |
| **Membership** |
| added_at | timestamptz | NOT NULL, DEFAULT now() | When added |
| added_by | uuid | FK → team.team_directory | Who added |
| removed_at | timestamptz | | If removed |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |

**UNIQUE CONSTRAINT:** (group_id, contact_id) WHERE removed_at IS NULL

---

## directory.contact_relationships

**Purpose:** Relationships between contacts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| contact_id | uuid | FK → contacts, NOT NULL | Source contact |
| related_contact_id | uuid | FK → contacts, NOT NULL | Related contact |
| relationship_type_code | text | FK → ref.relationship_type_key | Type |
| **Details** |
| is_primary | boolean | DEFAULT false | Primary relationship |
| notes | text | | Relationship notes |
| **Dates** |
| effective_date | date | | When started |
| end_date | date | | If ended |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |

**CHECK CONSTRAINT:** contact_id != related_contact_id

---

## directory.contact_notes

**Purpose:** Notes/comments on contacts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| contact_id | uuid | FK → contacts, NOT NULL | Contact |
| **Note** |
| note_type | text | DEFAULT 'general' | general, warning, preference, interaction |
| note_text | text | NOT NULL | The note |
| is_pinned | boolean | DEFAULT false | Show prominently |
| is_internal | boolean | DEFAULT true | Internal only |
| **Author** |
| created_by | uuid | FK → team.team_directory | Who wrote |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |
| updated_at | timestamptz | NOT NULL | Record updated |

---

## directory.contact_tags

**Purpose:** Tags applied to contacts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| contact_id | uuid | FK → contacts, NOT NULL | Contact |
| tag_code | text | FK → ref.contact_tag_key, NOT NULL | Tag |
| **Application** |
| applied_at | timestamptz | NOT NULL, DEFAULT now() | When applied |
| applied_by | uuid | FK → team.team_directory | Who applied |
| removed_at | timestamptz | | If removed |
| **Notes** |
| notes | text | | Why tagged |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |

**UNIQUE CONSTRAINT:** (contact_id, tag_code) WHERE removed_at IS NULL

---

## directory.contact_merge_history

**Purpose:** Tracks merged/deduplicated contacts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| **Merge Details** |
| winner_contact_id | uuid | FK → contacts, NOT NULL | Surviving contact |
| loser_contact_id | uuid | FK → contacts, NOT NULL | Merged away contact |
| merge_reason | text | | Why merged |
| **Tracking** |
| merged_at | timestamptz | NOT NULL, DEFAULT now() | When merged |
| merged_by | uuid | FK → team.team_directory | Who merged |
| **Reversibility** |
| is_reversible | boolean | DEFAULT true | Can undo? |
| reversed_at | timestamptz | | If reversed |
| **Audit** |
| created_at | timestamptz | NOT NULL | Record created |

---

# PROPERTY SCHEMA (30 tables)

---

## Core Property Tables (3)

### property.resorts

**Purpose:** Optional property groupings (condo complexes, HOAs)  
**Business ID:** RST-NNNN (sequence starts 1001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| resort_id | text | UNIQUE, NOT NULL | RST-NNNN |
| resort_name | text | NOT NULL | Display name |
| resort_code | text | UNIQUE | Short code |
| **Location** |
| address_line_1 | text | | Street address |
| city | text | | City |
| state_province | text | | State |
| postal_code | text | | ZIP |
| country_code | text | FK → geo.countries | Country |
| latitude | numeric(10,7) | | GPS lat |
| longitude | numeric(10,7) | | GPS long |
| **Contact** |
| front_desk_phone | text | | Front desk |
| front_desk_email | text | | Front desk email |
| security_phone | text | | Security |
| hoa_contact_id | uuid | FK → directory.contacts | HOA contact |
| **Details** |
| description | text | | Description |
| amenities | text[] | | Resort amenities |
| **Status** |
| is_active | boolean | DEFAULT true | Active |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.properties

**Purpose:** Core property/unit record  
**Business ID:** PROP-{CO}-NNNNNN where CO = MLVR, NASH, UVH (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| property_id | text | UNIQUE, NOT NULL | PROP-MLVR-100001 |
| **Grouping** |
| resort_id | uuid | FK → resorts | Parent resort |
| **Identification** |
| property_name | text | NOT NULL | Display name |
| property_code | text | UNIQUE | Short code (MLV-101) |
| unit_number | text | | Unit/apt number |
| **Location** |
| address_line_1 | text | NOT NULL | Street |
| address_line_2 | text | | Unit |
| city | text | NOT NULL | City |
| state_province | text | NOT NULL | State |
| postal_code | text | NOT NULL | ZIP |
| country_code | text | FK → geo.countries | Country |
| latitude | numeric(10,7) | | GPS lat |
| longitude | numeric(10,7) | | GPS long |
| **Specs** |
| bedrooms | integer | NOT NULL | Bedroom count |
| bathrooms | numeric(3,1) | NOT NULL | Bathroom count |
| half_baths | integer | DEFAULT 0 | Half bath count |
| sleeps | integer | NOT NULL | Max guests |
| square_feet | integer | | Living area |
| floors | integer | DEFAULT 1 | Number of floors |
| **Classification** |
| property_type | text | NOT NULL | condo, house, townhouse, villa |
| property_class | text | | luxury, premium, standard |
| **Status** |
| status | text | NOT NULL, DEFAULT 'active' | active, inactive, onboarding, offboarding |
| listing_status | text | DEFAULT 'listed' | listed, unlisted, owner_hold |
| **Dates** |
| contract_start_date | date | | When started |
| contract_end_date | date | | If ended |
| **External IDs** |
| streamline_unit_id | integer | | Streamline ID |
| airbnb_listing_id | text | | Airbnb listing |
| vrbo_listing_id | text | | VRBO listing |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.rooms

**Purpose:** Individual rooms within properties  
**Business ID:** RM-{prop_code}-{room_code} (e.g., RM-MLV101-MBR)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| room_id | text | UNIQUE, NOT NULL | RM-MLV101-MBR |
| property_id | uuid | FK → properties, NOT NULL | Property |
| **Classification** |
| room_type_code | text | FK → ref.room_type_key | Type |
| room_name | text | NOT NULL | Display name |
| room_code | text | NOT NULL | Short code (MBR, BR1) |
| **Location** |
| floor_level | integer | DEFAULT 1 | Which floor |
| sequence_order | integer | | Display order |
| **Specs** |
| square_feet | integer | | Room size |
| has_window | boolean | | Has window |
| has_closet | boolean | | Has closet |
| has_ensuite | boolean | | Attached bathroom |
| **Status** |
| is_active | boolean | DEFAULT true | Active |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

**UNIQUE CONSTRAINT:** (property_id, room_code)

---

## Cleaning & Inspection Tables (7)

### property.cleans

**Purpose:** Cleaning events  
**Business ID:** CLN-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| clean_id | text | UNIQUE, NOT NULL | CLN-100001 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| **Scheduling** |
| cleaning_type_code | text | FK → ref.cleaning_type_key | Type |
| scheduled_date | date | NOT NULL | When scheduled |
| scheduled_start_time | time | | Start time |
| **Execution** |
| actual_date | date | | When done |
| started_at | timestamptz | | Start time |
| completed_at | timestamptz | | End time |
| duration_minutes | integer | | How long |
| **Team** |
| cleaner_id | uuid | FK → team.team_directory | Primary cleaner |
| team_id | uuid | FK → team.teams | Cleaning team |
| **Reservation Link** |
| checkout_reservation_id | uuid | FK → reservations.reservations | Departing res |
| checkin_reservation_id | uuid | FK → reservations.reservations | Arriving res |
| **Status** |
| status | text | NOT NULL | scheduled, in_progress, completed, cancelled, reclean |
| **Quality** |
| inspection_id | uuid | FK → inspections | Linked inspection |
| passed_inspection | boolean | | Did it pass? |
| **Billing** |
| is_billable | boolean | DEFAULT true | Charge guest? |
| clean_fee | numeric(10,2) | | Fee amount |
| **Notes** |
| notes | text | | Clean notes |
| **External IDs** |
| streamline_clean_id | integer | | Streamline ID |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.inspections

**Purpose:** Property inspections  
**Business ID:** INS-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| inspection_id | text | UNIQUE, NOT NULL | INS-100001 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| **Type & Scheduling** |
| inspection_type | text | NOT NULL | turnover, periodic, complaint, pre_listing |
| scheduled_date | date | NOT NULL | When scheduled |
| **Execution** |
| actual_date | date | | When done |
| started_at | timestamptz | | Start time |
| completed_at | timestamptz | | End time |
| **Inspector** |
| inspector_id | uuid | FK → team.team_directory | Who inspected |
| **Clean Link** |
| clean_id | uuid | FK → cleans | Related clean |
| **Reservation Link** |
| reservation_id | uuid | FK → reservations.reservations | Related res |
| **Status** |
| status | text | NOT NULL | scheduled, in_progress, passed, failed, cancelled |
| **Scores** |
| overall_score | numeric(5,2) | | Calculated score |
| cleanliness_score | numeric(5,2) | | Clean subscore |
| maintenance_score | numeric(5,2) | | Maint subscore |
| inventory_score | numeric(5,2) | | Inventory subscore |
| **Issue Counts** |
| issues_critical | integer | DEFAULT 0 | Critical issues |
| issues_high | integer | DEFAULT 0 | High issues |
| issues_medium | integer | DEFAULT 0 | Medium issues |
| issues_low | integer | DEFAULT 0 | Low issues |
| **Follow-up** |
| requires_followup | boolean | DEFAULT false | Needs follow-up? |
| followup_ticket_id | uuid | FK → service.tickets | Generated ticket |
| followup_notes | text | | Follow-up notes |
| **Notes** |
| notes | text | | General notes |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.inspection_questions

**Purpose:** Master inspection question templates  
**Business ID:** INSPQ-{category}-NNNN (e.g., INSPQ-CLEAN-0001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| question_id | text | UNIQUE, NOT NULL | INSPQ-CLEAN-0001 |
| **Classification** |
| category_code | text | FK → ref.inspection_category_key | Category |
| **Question** |
| question_text | text | NOT NULL | The question |
| question_type | text | NOT NULL | pass_fail, rating, count, text, photo |
| **Applicability** |
| applies_to_room_types | text[] | | Which room types |
| applies_to_property_types | text[] | | Which property types |
| is_ac_unit_question | boolean | DEFAULT false | For AC units? |
| **Requirements** |
| requires_photo_on_fail | boolean | DEFAULT false | Photo if fail? |
| auto_create_ticket_on_fail | boolean | DEFAULT false | Auto-ticket? |
| default_severity_on_fail | text | | Default severity |
| **Scoring** |
| weight | numeric(3,2) | DEFAULT 1.00 | Score weight |
| **Inventory Link** |
| links_to_inventory | boolean | DEFAULT false | Check inventory? |
| **Status** |
| is_active | boolean | DEFAULT true | Active |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.inspection_room_questions

**Purpose:** Inspection responses for room questions  
**Business ID:** INSPQR-{ins}-{room}-NNN (e.g., INSPQR-100001-MBR-001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| response_id | text | UNIQUE, NOT NULL | INSPQR-100001-MBR-001 |
| inspection_id | uuid | FK → inspections, NOT NULL | Inspection |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| question_id | uuid | FK → inspection_questions, NOT NULL | Question |
| **Response** |
| response_value | text | | The answer |
| passed | boolean | | Pass/fail result |
| score | numeric(5,2) | | Numeric score |
| **Issue (if failed)** |
| issue_severity | text | FK → ref.issue_severity_key | Severity |
| issue_notes | text | | Issue description |
| **Ticket** |
| generated_ticket_id | uuid | FK → service.tickets | If auto-created |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| answered_at | timestamptz | | When answered |
| answered_by | uuid | FK → team.team_directory | Who answered |

---

### property.inspection_ac_unit_questions

**Purpose:** Inspection responses for AC unit questions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| inspection_id | uuid | FK → inspections, NOT NULL | Inspection |
| ac_unit_id | uuid | FK → ac_units, NOT NULL | AC unit |
| question_id | uuid | FK → inspection_questions, NOT NULL | Question |
| **Response** |
| response_value | text | | The answer |
| passed | boolean | | Pass/fail |
| **Issue** |
| issue_severity | text | | Severity |
| issue_notes | text | | Notes |
| **Ticket** |
| generated_ticket_id | uuid | FK → service.tickets | Auto-created |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| answered_at | timestamptz | | When answered |

---

### property.inspection_question_inventory_links

**Purpose:** Links inspection questions to inventory items

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| question_id | uuid | FK → inspection_questions, NOT NULL | Question |
| inventory_item_type_code | text | FK → ref.inventory_item_types | Item type |
| **Validation** |
| expected_count | integer | | Expected quantity |
| count_tolerance | integer | | Acceptable variance |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |

---

### property.inspection_issues

**Purpose:** Issues found during inspections  
**Business ID:** ISS-{ins}-NNN (e.g., ISS-100001-001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| issue_id | text | UNIQUE, NOT NULL | ISS-100001-001 |
| inspection_id | uuid | FK → inspections, NOT NULL | Inspection |
| room_id | uuid | FK → rooms | Which room |
| **Issue Details** |
| category_code | text | FK → ref.inspection_category_key | Category |
| severity_code | text | FK → ref.issue_severity_key | Severity |
| description | text | NOT NULL | Description |
| **Resolution** |
| status | text | NOT NULL | open, in_progress, resolved, deferred |
| resolution_notes | text | | How resolved |
| resolved_at | timestamptz | | When resolved |
| resolved_by | uuid | FK → team.team_directory | Who resolved |
| **Ticket** |
| generated_ticket_id | uuid | FK → service.tickets | Created ticket |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.inspection_room_scores

**Purpose:** Calculated scores per room per inspection

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| inspection_id | uuid | FK → inspections, NOT NULL | Inspection |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| **Scores** |
| overall_score | numeric(5,2) | | Room overall |
| cleanliness_score | numeric(5,2) | | Clean score |
| maintenance_score | numeric(5,2) | | Maint score |
| inventory_score | numeric(5,2) | | Inventory score |
| **Counts** |
| questions_total | integer | | Total questions |
| questions_passed | integer | | Passed |
| questions_failed | integer | | Failed |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |

**UNIQUE CONSTRAINT:** (inspection_id, room_id)

---

## Room Components (8)

### property.beds

**Purpose:** Beds in rooms  
**Business ID:** BED-{room_code}-NN (e.g., BED-MLV101-MBR-01)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| bed_id | text | UNIQUE, NOT NULL | BED-MLV101-MBR-01 |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| **Bed Details** |
| bed_type_code | text | FK → ref.bed_type_key | Type |
| bed_name | text | | Display name |
| sleeps | integer | NOT NULL | How many |
| **Status** |
| is_active | boolean | DEFAULT true | Active |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.appliances

**Purpose:** Appliances in property  
**Business ID:** APPL-{prop_code}-NNNN (e.g., APPL-MLV101-0001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| appliance_id | text | UNIQUE, NOT NULL | APPL-MLV101-0001 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| room_id | uuid | FK → rooms | Which room |
| **Appliance Details** |
| appliance_type_code | text | FK → ref.appliance_type_key | Type |
| appliance_name | text | | Display name |
| brand | text | | Brand |
| model | text | | Model |
| serial_number | text | | Serial |
| **Dates** |
| purchase_date | date | | When bought |
| install_date | date | | When installed |
| warranty_expiry | date | | Warranty end |
| **Status** |
| status | text | DEFAULT 'active' | active, needs_repair, replaced |
| **Notes** |
| notes | text | | Notes |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.appliance_parts

**Purpose:** Replacement parts for appliances

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| appliance_id | uuid | FK → appliances, NOT NULL | Appliance |
| **Part Details** |
| part_name | text | NOT NULL | Part name |
| part_number | text | | Manufacturer part # |
| supplier | text | | Where to buy |
| typical_cost | numeric(10,2) | | Expected cost |
| **Notes** |
| notes | text | | Notes |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |

---

### property.fixtures

**Purpose:** Plumbing fixtures

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| **Fixture Details** |
| fixture_type_code | text | FK → ref.fixture_type_key | Type |
| fixture_name | text | | Display name |
| brand | text | | Brand |
| model | text | | Model |
| finish | text | | Chrome, brushed nickel, etc. |
| **Status** |
| status | text | DEFAULT 'active' | Status |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.surfaces

**Purpose:** Surfaces for cleaning/maintenance tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| **Surface Details** |
| surface_type_code | text | FK → ref.surface_type_key | Type |
| material | text | | Tile, hardwood, granite, etc. |
| color | text | | Color |
| square_feet | numeric(8,2) | | Area |
| **Maintenance** |
| cleaning_instructions | text | | How to clean |
| special_care | text | | Special requirements |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.lighting

**Purpose:** Light fixtures

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| **Lighting Details** |
| fixture_name | text | NOT NULL | Name |
| fixture_type | text | | ceiling, wall, lamp, recessed |
| bulb_type | text | | LED, incandescent, etc. |
| bulb_count | integer | DEFAULT 1 | How many bulbs |
| is_dimmable | boolean | DEFAULT false | Dimmable? |
| is_smart | boolean | DEFAULT false | Smart control? |
| **Status** |
| status | text | DEFAULT 'active' | Status |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.window_coverings

**Purpose:** Window treatments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| **Covering Details** |
| covering_type | text | NOT NULL | blinds, shades, curtains, shutters |
| material | text | | Material |
| color | text | | Color |
| width_inches | numeric(6,2) | | Width |
| height_inches | numeric(6,2) | | Height |
| is_blackout | boolean | DEFAULT false | Blackout? |
| is_motorized | boolean | DEFAULT false | Motorized? |
| **Status** |
| status | text | DEFAULT 'active' | Status |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.room_features

**Purpose:** Other room features

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| **Feature Details** |
| feature_type | text | NOT NULL | Type |
| feature_name | text | NOT NULL | Name |
| description | text | | Description |
| **Status** |
| is_active | boolean | DEFAULT true | Active |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |

---

## Property Systems (6)

### property.ac_systems

**Purpose:** HVAC systems  
**Business ID:** HVAC-{prop_code}-NN (e.g., HVAC-MLV101-01)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| system_id | text | UNIQUE, NOT NULL | HVAC-MLV101-01 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| **System Details** |
| system_name | text | NOT NULL | Name |
| system_type | text | NOT NULL | split, central, mini_split, window |
| brand | text | | Brand |
| model | text | | Model |
| serial_number | text | | Serial |
| tonnage | numeric(3,1) | | Capacity |
| seer_rating | numeric(4,1) | | Efficiency |
| **Dates** |
| install_date | date | | When installed |
| warranty_expiry | date | | Warranty end |
| last_service_date | date | | Last service |
| **Status** |
| status | text | DEFAULT 'active' | Status |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.ac_units

**Purpose:** Individual AC units within systems

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| ac_system_id | uuid | FK → ac_systems, NOT NULL | System |
| **Unit Details** |
| unit_name | text | NOT NULL | Name |
| unit_type | text | NOT NULL | indoor, outdoor, handler |
| location | text | | Where located |
| **Status** |
| status | text | DEFAULT 'active' | Status |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.ac_unit_rooms

**Purpose:** Links AC units to rooms they serve

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| ac_unit_id | uuid | FK → ac_units, NOT NULL | AC unit |
| room_id | uuid | FK → rooms, NOT NULL | Room |
| **Details** |
| is_primary | boolean | DEFAULT true | Primary unit? |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |

**UNIQUE CONSTRAINT:** (ac_unit_id, room_id)

---

### property.property_doors

**Purpose:** Exterior doors  
**Business ID:** DOOR-{prop_code}-NN (e.g., DOOR-MLV101-01)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| door_id | text | UNIQUE, NOT NULL | DOOR-MLV101-01 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| **Door Details** |
| door_name | text | NOT NULL | Front, Garage, etc. |
| door_type | text | NOT NULL | entry, garage, sliding, gate |
| location | text | | Where |
| **Lock Info** |
| has_smart_lock | boolean | DEFAULT false | Smart lock? |
| smart_lock_brand | text | | Lock brand |
| smart_lock_model | text | | Lock model |
| **Status** |
| status | text | DEFAULT 'active' | Status |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.property_locks

**Purpose:** Locks on doors  
**Business ID:** LOCK-{door_id}-NN

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| lock_id | text | UNIQUE, NOT NULL | LOCK-MLV101-01-01 |
| door_id | uuid | FK → property_doors, NOT NULL | Door |
| **Lock Details** |
| lock_type | text | NOT NULL | smart, deadbolt, keypad, keyed |
| brand | text | | Brand |
| model | text | | Model |
| serial_number | text | | Serial |
| **Smart Lock** |
| is_smart | boolean | DEFAULT false | Smart? |
| integration_type | text | | august, schlage, yale, etc. |
| external_lock_id | text | | API ID |
| **Codes** |
| master_code | text | | Master (encrypted) |
| guest_code_pattern | text | | Pattern |
| **Status** |
| status | text | DEFAULT 'active' | Status |
| battery_last_replaced | date | | Battery date |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.key_checkouts

**Purpose:** Physical key checkout tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| lock_id | uuid | FK → property_locks, NOT NULL | Which lock |
| **Checkout** |
| key_number | text | NOT NULL | Key identifier |
| checked_out_to | uuid | FK → team.team_directory | Who has it |
| checked_out_at | timestamptz | NOT NULL | When |
| expected_return_at | timestamptz | | When due |
| **Return** |
| checked_in_at | timestamptz | | When returned |
| checked_in_by | uuid | FK → team.team_directory | Who received |
| **Status** |
| status | text | NOT NULL | out, returned, lost |
| **Notes** |
| notes | text | | Notes |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |

---

### property.safety_items

**Purpose:** Safety equipment  
**Business ID:** SAFE-{prop_code}-NNNN (e.g., SAFE-MLV101-0001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| safety_item_id | text | UNIQUE, NOT NULL | SAFE-MLV101-0001 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| room_id | uuid | FK → rooms | Which room |
| **Item Details** |
| item_type_code | text | FK → ref.safety_item_type_key | Type |
| item_name | text | | Name |
| brand | text | | Brand |
| model | text | | Model |
| serial_number | text | | Serial |
| location_description | text | | Where exactly |
| **Dates** |
| install_date | date | | Installed |
| expiry_date | date | | Expires |
| last_tested_date | date | | Last tested |
| next_test_date | date | | Next test |
| battery_last_replaced | date | | Battery |
| **Status** |
| status | text | DEFAULT 'active' | Status |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

## Configuration Tables (3)

### property.property_amenities

**Purpose:** Amenities available at property

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| amenity_type_code | text | FK → ref.amenity_type_key | Amenity |
| **Details** |
| is_available | boolean | DEFAULT true | Available? |
| notes | text | | Notes |
| seasonal | boolean | DEFAULT false | Seasonal only? |
| seasonal_start | text | | When available (MM-DD) |
| seasonal_end | text | | When ends (MM-DD) |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

**UNIQUE CONSTRAINT:** (property_id, amenity_type_code)

---

### property.property_rules

**Purpose:** Property-specific rules

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| **Rule Details** |
| rule_type | text | NOT NULL | check_in, check_out, quiet_hours, pets, smoking, parking, etc. |
| rule_name | text | NOT NULL | Display name |
| rule_text | text | NOT NULL | Full text |
| **Enforcement** |
| is_strict | boolean | DEFAULT false | Strictly enforced? |
| violation_fee | numeric(10,2) | | Fee if violated |
| **Display** |
| display_order | integer | | Order |
| show_in_listing | boolean | DEFAULT true | Show in listing? |
| show_in_confirmation | boolean | DEFAULT true | Show in confirmation? |
| **Status** |
| is_active | boolean | DEFAULT true | Active? |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

### property.property_access_codes

**Purpose:** Access codes for property

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| property_id | uuid | FK → properties, NOT NULL | Property |
| door_id | uuid | FK → property_doors | Which door |
| **Code Details** |
| code_type | text | NOT NULL | master, guest, vendor, owner |
| code_name | text | NOT NULL | Name |
| code_value | text | NOT NULL | The code (encrypted) |
| **Validity** |
| valid_from | timestamptz | | Start |
| valid_until | timestamptz | | End |
| **Usage** |
| reservation_id | uuid | FK → reservations.reservations | If for specific res |
| contact_id | uuid | FK → directory.contacts | If for specific person |
| **Status** |
| is_active | boolean | DEFAULT true | Active? |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |
| created_by | uuid | FK → team.team_directory | Who created |

---

# SERVICE SCHEMA (30 tables)

*See Service System Reference Guide for full details*

## Summary Table List

| # | Table | Purpose | Business ID |
|---|-------|---------|-------------|
| 1 | tickets | Core ticket table | TIK-{TYPE}-NNNNNN |
| 2 | ticket_time_entries | Time allocation to tickets | — |
| 3 | inspection_time_entries | Time allocation to inspections | — |
| 4 | ticket_properties | Ticket ↔ property links | — |
| 5 | ticket_reservations | Ticket ↔ reservation links | — |
| 6 | ticket_homeowners | Ticket ↔ homeowner links | — |
| 7 | ticket_relationships | Ticket ↔ ticket links | — |
| 8 | ticket_shifts | Ticket ↔ shift assignments | — |
| 9 | ticket_contacts | Ticket ↔ contact links | — |
| 10 | ticket_vendors | Ticket ↔ vendor assignments | — |
| 11 | ticket_misses | Missed service tracking | — |
| 12 | ticket_costs | Cost line items | — |
| 13 | ticket_purchases | Purchase tracking | — |
| 14 | ticket_events | Audit trail | EVT-NNNNNNNN |
| 15 | ticket_labels | Labels/tags | — |
| 16 | ticket_inspections | Ticket ↔ inspection links | — |
| 17 | ticket_cleans | Ticket ↔ clean links | — |
| 18 | ticket_inventory_events | Ticket ↔ inventory links | — |
| 19 | ticket_recurring | Recurring task instances | — |
| 20 | ticket_transactions | Ticket ↔ finance links | — |
| 21 | ticket_damage | Damage records | — |
| 22 | ticket_claims | Ticket ↔ claim links | — |
| 23 | projects | Multi-property projects | PRJ-NNNNNN |
| 24 | project_properties | Project ↔ property tracking | — |
| 25 | project_tickets | Project ↔ ticket tracking | — |
| 26 | damage_claims | Damage claim master | CLM-NNNNNN |
| 27 | damage_claim_submissions | Claim submissions | SUB-{claim}-NN |
| 28 | damage_claim_approvals | Approval records | APV-{sub}-NN |
| 29 | damage_claim_denials | Denial records | DNL-{sub}-NN |
| 30 | damage_claim_appeals | Appeal records | APL-{sub}-NN |

---

# TEAM SCHEMA (6 tables)

---

## team.teams

**Purpose:** Team definitions  
**Business ID:** TEAM-NNNN (sequence starts 1001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| team_id | text | UNIQUE, NOT NULL | TEAM-1001 |
| name | text | NOT NULL | Team name |
| description | text | | Description |
| is_active | boolean | DEFAULT true | Active |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

## team.team_directory

**Purpose:** Team members  
**Business ID:** MBR-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| member_id | text | UNIQUE, NOT NULL | MBR-100001 |
| contact_id | uuid | FK → directory.contacts | Contact record |
| team_id | uuid | FK → teams | Primary team |
| manager_id | uuid | FK → team_directory | Reports to |
| role | text | | Job title |
| hourly_rate | numeric(10,2) | | Hourly rate |
| is_active | boolean | DEFAULT true | Active |
| hire_date | date | | Start date |
| termination_date | date | | If terminated |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

## team.shifts

**Purpose:** Shift scheduling  
**Business ID:** SHFT-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| shift_id | text | UNIQUE, NOT NULL | SHFT-100001 |
| member_id | uuid | FK → team_directory | Who |
| shift_date | date | NOT NULL | Date |
| starts_at | timestamptz | | Start time |
| ends_at | timestamptz | | End time |
| scheduled_hours | numeric(5,2) | | Planned hours |
| actual_hours | numeric(5,2) | | Actual hours |
| status | text | NOT NULL | SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED, NO_SHOW |
| notes | text | | Notes |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

## team.time_entries

**Purpose:** Time tracking  
**Business ID:** TIME-NNNNNNNN (sequence starts 10000001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| time_entry_id | text | UNIQUE, NOT NULL | TIME-10000001 |
| member_id | uuid | FK → team_directory | Who |
| property_id | uuid | FK → property.properties | Where |
| work_date | date | NOT NULL | Date |
| started_at | timestamptz | | Start |
| ended_at | timestamptz | | End |
| duration_seconds | integer | | Duration |
| activity_type_code | text | FK → ref.activity_types | Activity |
| hourly_rate | numeric(10,2) | | Rate at time |
| labor_cost | numeric(10,2) | | Calculated cost |
| is_billable | boolean | DEFAULT true | Billable? |
| billable_to | text | | owner, company, guest |
| timesheet_status | text | NOT NULL | START, STOP, VERIFY, APPROVED, RECORDED |
| requires_verification | boolean | DEFAULT false | Needs verify? |
| notes | text | | Notes |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

## team.time_entry_verifications

**Purpose:** Verification history

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| time_entry_id | uuid | FK → time_entries | Entry |
| verification_number | integer | NOT NULL | Sequence |
| verification_status | text | NOT NULL | PENDING, VERIFIED, REJECTED, ADJUSTED |
| verified_by_id | uuid | FK → team_directory | Verifier |
| verified_at | timestamptz | | When |
| original_duration_seconds | integer | | Before |
| adjusted_duration_seconds | integer | | After |
| adjustment_reason | text | | Why |
| notes | text | | Notes |
| created_at | timestamptz | NOT NULL | Created |

**UNIQUE CONSTRAINT:** (time_entry_id, verification_number)

---

## team.shift_time_entries

**Purpose:** Shift ↔ time entry allocation (HR view)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| shift_id | uuid | FK → shifts | Shift |
| time_entry_id | uuid | FK → time_entries | Entry |
| allocated_seconds | integer | NOT NULL | Allocated |
| notes | text | | Notes |
| created_at | timestamptz | NOT NULL | Created |

---

# STORAGE SCHEMA (4 tables)

---

## storage.files

**Purpose:** Central file registry  
**Business ID:** FILE-NNNNNNNN (sequence starts 10000001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| file_id | text | UNIQUE, NOT NULL | FILE-10000001 |
| file_url | text | NOT NULL | Storage URL |
| thumbnail_url | text | | Thumbnail |
| file_type | text | NOT NULL | image, document, video |
| mime_type | text | | MIME type |
| file_size_bytes | integer | | Size |
| original_filename | text | | Original name |
| property_id | uuid | FK → property.properties | Where taken |
| room_id | uuid | FK → property.rooms | Which room |
| uploaded_by_id | uuid | FK → team.team_directory | Who |
| uploaded_at | timestamptz | NOT NULL | When |
| created_at | timestamptz | NOT NULL | Created |

---

## storage.ticket_files

**Purpose:** Ticket ↔ file links

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| ticket_id | uuid | FK → service.tickets | Ticket |
| file_id | uuid | FK → files | File |
| context_type | text | | before, after, damage, receipt, completion |
| caption | text | | Description |
| is_owner_visible | boolean | DEFAULT false | Show to owner? |
| is_guest_visible | boolean | DEFAULT false | Show to guest? |
| sort_order | integer | | Order |
| created_at | timestamptz | NOT NULL | Created |

---

## storage.inspection_files

**Purpose:** Inspection ↔ file links

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| inspection_id | uuid | FK → property.inspections | Inspection |
| file_id | uuid | FK → files | File |
| context_type | text | | issue, room, completion, checklist_item |
| inspection_item_id | uuid | | Specific item |
| room_id | uuid | FK → property.rooms | Room |
| caption | text | | Description |
| sort_order | integer | | Order |
| created_at | timestamptz | NOT NULL | Created |

---

## storage.room_files

**Purpose:** Room ↔ file links

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| room_id | uuid | FK → property.rooms | Room |
| file_id | uuid | FK → files | File |
| context_type | text | | reference, current, issue |
| is_reference | boolean | DEFAULT false | Baseline photo? |
| caption | text | | Description |
| sort_order | integer | | Order |
| created_at | timestamptz | NOT NULL | Created |

---

# PORTAL SCHEMA (6 tables)

---

## portal.users

**Purpose:** Portal user accounts  
**Business ID:** USR-NNNNNN (sequence starts 100001)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| user_id | text | UNIQUE, NOT NULL | USR-100001 |
| contact_id | uuid | FK → directory.contacts | Contact record |
| **Auth** |
| email | text | UNIQUE, NOT NULL | Login email |
| password_hash | text | | Hashed password |
| auth_provider | text | | local, google, apple |
| external_auth_id | text | | Provider ID |
| **Status** |
| status | text | NOT NULL | active, inactive, pending, suspended |
| email_verified | boolean | DEFAULT false | Verified? |
| email_verified_at | timestamptz | | When verified |
| **Security** |
| mfa_enabled | boolean | DEFAULT false | MFA on? |
| mfa_method | text | | totp, sms |
| last_login_at | timestamptz | | Last login |
| failed_login_count | integer | DEFAULT 0 | Failed attempts |
| locked_until | timestamptz | | If locked |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

---

## portal.sessions

**Purpose:** User sessions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| user_id | uuid | FK → users, NOT NULL | User |
| **Session** |
| token_hash | text | NOT NULL | Hashed token |
| refresh_token_hash | text | | Refresh token |
| **Device** |
| device_type | text | | web, ios, android |
| device_name | text | | Device name |
| ip_address | text | | IP |
| user_agent | text | | User agent |
| **Validity** |
| expires_at | timestamptz | NOT NULL | Expiry |
| refresh_expires_at | timestamptz | | Refresh expiry |
| **Status** |
| is_active | boolean | DEFAULT true | Active? |
| revoked_at | timestamptz | | If revoked |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |

---

## portal.roles

**Purpose:** Role definitions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| role_code | text | UNIQUE, NOT NULL | ADMIN, TEAM, OWNER, GUEST |
| role_name | text | NOT NULL | Display name |
| description | text | | Description |
| is_system | boolean | DEFAULT false | System role? |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | NOT NULL | Created |

---

## portal.permissions

**Purpose:** Permission definitions

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| permission_code | text | UNIQUE, NOT NULL | tickets.create |
| resource | text | NOT NULL | tickets, properties, etc. |
| action | text | NOT NULL | create, read, update, delete |
| scope | text | | own, team, all |
| description | text | | Description |
| is_active | boolean | DEFAULT true | Active? |
| created_at | timestamptz | NOT NULL | Created |

---

## portal.user_roles

**Purpose:** User ↔ role assignments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| user_id | uuid | FK → users, NOT NULL | User |
| role_id | uuid | FK → roles, NOT NULL | Role |
| **Scope** |
| scope_type | text | | global, property, resort |
| scope_id | uuid | | Property/resort ID |
| **Validity** |
| granted_at | timestamptz | NOT NULL | When granted |
| granted_by | uuid | FK → users | Who granted |
| expires_at | timestamptz | | If expires |
| revoked_at | timestamptz | | If revoked |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |

**UNIQUE CONSTRAINT:** (user_id, role_id, scope_type, scope_id) WHERE revoked_at IS NULL

---

## portal.preferences

**Purpose:** User preferences (key-value)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | UUIDv7 |
| user_id | uuid | FK → users, NOT NULL | User |
| **Preference** |
| preference_key | text | NOT NULL | Key |
| preference_value | jsonb | | Value |
| **Audit** |
| created_at | timestamptz | NOT NULL | Created |
| updated_at | timestamptz | NOT NULL | Updated |

**UNIQUE CONSTRAINT:** (user_id, preference_key)

---

# DOCUMENT SUMMARY

| Schema | Tables | Ready for SQL |
|--------|--------|---------------|
| ref | 35 | ✅ Yes |
| directory | 13 | ✅ Yes |
| property | 30 | ✅ Yes |
| service | 30 | ✅ Yes |
| team | 6 | ✅ Yes |
| storage | 4 | ✅ Yes |
| portal | 6 | ✅ Yes |
| **TOTAL** | **124** | |

---

**Document Version:** 4.1  
**Last Updated:** December 9, 2025  
**Status:** Ready for Review
