# Central Memory — Service System Final Specification

## Document Purpose
Complete specification for the unified ticketing, time-tracking, projects, and damage-claim subsystem for Central Memory. This document consolidates decisions from both ChatGPT and Claude threads into a single authoritative reference.

**Version:** 4.0 (Final Consolidated)  
**Date:** 2025-12-08  
**Total Tables:** 47 (30 service + 6 team + 4 storage + 8 ref)

---

# PART 1: SCHEMA ARCHITECTURE

---

## Schema Assignments

| Schema | Purpose | Contains |
|--------|---------|----------|
| **service** | Service delivery & work management | tickets, ticket_*, projects, project_*, damage_claims, damage_claim_*, time allocation joins |
| **team** | People, scheduling, labor | teams, team_directory, shifts, time_entries, time_entry_verifications, shift_time_entries |
| **property** | Physical assets | properties, rooms, resorts, inspections, cleans, inventory |
| **reservations** | Booking lifecycle | reservations, guests, guest_surveys |
| **finance** | Money movement | transactions, owner_statements, fees |
| **storage** | File management | files, file context join tables |
| **ref** | Reference data | All *_key tables |

---

## Why This Split

**`service` schema:**
- Tickets = service requests
- Projects = service initiatives
- Damage claims = recovering costs from service issues
- Time allocation joins = tracking time spent on service work (tickets, inspections)

**`team` schema:**
- Teams = organizational structure
- Team directory = who works here
- Shifts = when people work (HR/scheduling)
- Time entries = what people did (labor tracking)
- Shift time entries = HR allocation of time within shifts

The key distinction: **team** is about people and their labor. **service** is about the work being delivered.

---

## Cross-Schema Reference Rules

1. **Join tables live in the schema of the "child" relationship**
   - `service.ticket_time_entries` → ticket needs time entry allocation
   - `team.shift_time_entries` → shift needs time entry allocation

2. **Foreign keys can reference across schemas**
   - `service.tickets.current_agent_id` → `team.team_directory(id)`
   - `service.ticket_time_entries.time_entry_id` → `team.time_entries(id)`

3. **Reference tables always in `ref` schema**

---

# PART 2: DESIGN PRINCIPLES

---

## Core Architecture Decisions

### 1. Single Ticket Table
- All ticket types (PC, RSV, ADM, ACCT) in one `service.tickets` table
- Type-specific behavior driven by `ticket_type_code` and compound `category_code`
- Lean core table with join tables for relationships

### 2. Join Table Pattern
- Every relationship gets its own join table
- Enables: multiple vendors, multiple time entries, multiple photos per ticket
- Domain facts live in domain tables; tickets only link to them

### 3. Compound Category Codes
- Format: `{TYPE}-{CATEGORY}` (e.g., PC-PLUMBING, RSV-LATE_CHECKOUT)
- Self-documenting, no ambiguity across domains
- Drives auto-assignment of teams

### 4. Priority-Driven SLA (No Due Dates)
- No `due_at` field — priority determines urgency
- Critical = 4 hrs, High = 24 hrs, Medium = 48 hrs, Low = 72 hrs
- SLA status calculated in views, not stored

### 5. Scheduled Date Naming
- `scheduled_date` = when work should happen
- Connects tickets to shifts & field operations

### 6. Time Lives in Team, Allocation Lives in Service
- `team.time_entries` = canonical record of labor (HR/payroll concern)
- `service.ticket_time_entries` = how much of that time went to this ticket (service delivery concern)
- Same time entry can be allocated across multiple tickets/inspections

### 7. Separate Verification Table
- `team.time_entry_verifications` tracks verification attempts
- Allows multiple verification cycles per time entry
- Tracks adjustments and reasons

### 8. Central File Storage
- `storage.files` is the master file registry
- Context join tables link files to tickets, inspections, rooms
- Same photo can be linked to multiple contexts

### 9. Damage Claims as Full Lifecycle
- Separate from tickets — tickets do work, claims recover money
- Full submission → approval/denial → appeal workflow
- Tracks recovery across multiple channels

### 10. Amounts in Decimal, Not Cents
- All monetary fields use `numeric(10,2)`
- Never store as integer cents

---

# PART 3: TABLE INVENTORY — TEAM SCHEMA

---

## team.teams

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (UUIDv7) |
| team_id | text | Business ID: TEAM-NNNN |
| name | text | Team name |
| description | text | Team description |
| is_active | boolean | Active flag |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

---

## team.team_directory

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (UUIDv7) |
| member_id | text | Business ID: MBR-NNNNNN |
| contact_id | uuid | → directory.contacts |
| team_id | uuid | → team.teams |
| manager_id | uuid | → team.team_directory (self-reference) |
| role | text | Member role/title |
| hourly_rate | numeric(10,2) | Current hourly rate |
| is_active | boolean | Active flag |
| hire_date | date | When hired |
| termination_date | date | If terminated |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

---

## team.shifts

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (UUIDv7) |
| shift_id | text | Business ID: SHFT-NNNNNN |
| member_id | uuid | → team.team_directory |
| shift_date | date | Date of shift |
| starts_at | timestamptz | Shift start |
| ends_at | timestamptz | Shift end |
| scheduled_hours | numeric(5,2) | Planned hours |
| actual_hours | numeric(5,2) | Actual hours worked |
| status | text | SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED, NO_SHOW |
| notes | text | Shift notes |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

---

## team.time_entries

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (UUIDv7) |
| time_entry_id | text | Business ID: TIME-NNNNNNNN |
| member_id | uuid | → team.team_directory |
| property_id | uuid | → property.properties (where work happened) |
| work_date | date | Date of work |
| started_at | timestamptz | Start time |
| ended_at | timestamptz | End time |
| duration_seconds | integer | Total duration |
| activity_type_code | text | → ref.activity_types |
| hourly_rate | numeric(10,2) | Rate at time of work |
| labor_cost | numeric(10,2) | Calculated cost |
| is_billable | boolean | Billable? |
| billable_to | text | owner, company, guest |
| timesheet_status | text | START, STOP, VERIFY, APPROVED, RECORDED |
| requires_verification | boolean | Needs verification? |
| notes | text | Work notes |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

**Timesheet Status Lifecycle:**
1. `START` → timer begins
2. `STOP` → ended_at + duration set
3. Supervisor chooses:
   - `APPROVED` (no verification needed), or
   - `VERIFY` (requires_verification = true)
4. After verification → `APPROVED`
5. Once in cost reporting → `RECORDED`

---

## team.time_entry_verifications

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| time_entry_id | uuid | → team.time_entries |
| verification_number | integer | Sequence (1, 2, 3...) |
| verification_status | text | PENDING, VERIFIED, REJECTED, ADJUSTED |
| verified_by_id | uuid | → team.team_directory |
| verified_at | timestamptz | When verified |
| original_duration_seconds | integer | Before adjustment |
| adjusted_duration_seconds | integer | After adjustment |
| adjustment_reason | text | Why adjusted |
| notes | text | Verification notes |
| created_at | timestamptz | When created |

**Unique Constraint:** (time_entry_id, verification_number)

---

## team.shift_time_entries

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| shift_id | uuid | → team.shifts |
| time_entry_id | uuid | → team.time_entries |
| allocated_seconds | integer | How much allocated to shift |
| notes | text | Allocation notes |
| created_at | timestamptz | When linked |

**Purpose:** HR-level tracking of how time entries roll up to shifts.

---

# PART 4: TABLE INVENTORY — SERVICE SCHEMA

---

## CORE TICKET TABLE

### service.tickets

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (UUIDv7) |
| ticket_id | text | Business ID: TIK-{TYPE}-NNNNNN |
| ticket_type_code | text | PC, RSV, ADM, ACCT |
| category_code | text | Compound: PC-PLUMBING, RSV-LATE_CHECKOUT, etc. |
| title | text | Ticket name/subject |
| description | text | Main description/comments |
| work_notes | text | Internal work notes |
| guest_comments | text | Guest-facing comments |
| status | text | OPEN, IN_PROGRESS, ON_HOLD, RESOLVED, CANCELLED |
| priority | text | LOW, MEDIUM, HIGH, CRITICAL |
| source | text | OWNER, GUEST, INTERNAL, SYSTEM, INSPECTION |
| property_id | uuid | → property.properties (primary, nullable by type) |
| reservation_id | uuid | → reservations.reservations (nullable by type) |
| homeowner_id | uuid | → property.homeowners (primary owner contact) |
| requestor_contact_id | uuid | → directory.contacts |
| current_agent_id | uuid | → team.team_directory |
| current_team_id | uuid | → team.teams |
| scheduled_date | date | When work should happen |
| first_response_at | timestamptz | When first responded |
| started_at | timestamptz | When work began |
| resolved_at | timestamptz | When resolved |
| is_archived | boolean | Soft delete flag |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

**Type Rules (enforced by app or constraints):**
- `ticket_type_code = 'PC'` → `property_id` required
- `ticket_type_code = 'RSV'` → `reservation_id` required
- `ticket_type_code IN ('ADM','ACCT')` → `property_id` may be NULL

---

## TIME ALLOCATION JOINS

### service.ticket_time_entries

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| time_entry_id | uuid | → team.time_entries |
| allocated_seconds | integer | How much allocated to this ticket |
| allocation_percentage | numeric(5,2) | Percentage of total entry |
| role | text | onsite, remote, travel, reporting |
| created_at | timestamptz | When linked |

**Purpose:** Track how much of a time entry was spent on this ticket.

---

### service.inspection_time_entries

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| inspection_id | uuid | → property.inspections |
| time_entry_id | uuid | → team.time_entries |
| allocated_seconds | integer | How much allocated to inspection |
| role | text | inspection, followup, report |
| created_at | timestamptz | When linked |

**Purpose:** Track how much of a time entry was spent on this inspection.

---

## TICKET JOIN TABLES — RELATIONSHIPS

### service.ticket_properties

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| property_id | uuid | → property.properties |
| resort_id | uuid | → property.resorts (snapshot) |
| address_snapshot | text | Address at time of ticket |
| role | text | PRIMARY, SECONDARY, AFFECTED, EXAMPLE |
| created_at | timestamptz | When linked |

---

### service.ticket_reservations

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| reservation_id | uuid | → reservations.reservations |
| reservation_number | text | Res # snapshot |
| guest_name_snapshot | text | Guest name at time of ticket |
| check_in_date | date | Check-in snapshot |
| check_out_date | date | Check-out snapshot |
| created_at | timestamptz | When linked |

---

### service.ticket_homeowners

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| homeowner_id | uuid | → property.homeowners |
| role | text | PRIMARY, CC, ESCALATION |
| is_requestor | boolean | Did this homeowner request the ticket? |
| is_billable | boolean | Should costs be billed to this owner? |
| billing_notes | text | Special billing instructions |
| communication_notes | text | Owner communication preferences |
| created_at | timestamptz | When linked |

---

### service.ticket_relationships

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets (source) |
| related_ticket_id | uuid | → service.tickets (related) |
| relationship_type | text | parent, child, related, duplicate, follow_up, escalated_from |
| notes | text | Relationship notes |
| created_at | timestamptz | When linked |

---

## TICKET JOIN TABLES — ASSIGNMENTS

### service.ticket_shifts

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| shift_id | uuid | → team.shifts |
| shift_agent_id | uuid | → team.team_directory |
| shift_date | date | Date of assigned shift |
| role | text | PRIMARY, BACKUP, REVIEWER |
| assignment_notes | text | Notes about this assignment |
| created_at | timestamptz | When assigned |
| updated_at | timestamptz | When changed |

---

### service.ticket_contacts

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| contact_id | uuid | → directory.contacts (external person) |
| team_member_id | uuid | → team.team_directory (if internal) |
| homeowner_id | uuid | → property.homeowners (if homeowner) |
| guest_id | uuid | → reservations.guests (if guest) |
| role | text | requestor, resolved_by, escalated_to, guest, homeowner, vendor_contact, internal_cc |
| notify | boolean | Should this person receive notifications? |
| assigned_at | timestamptz | When assigned this role |
| completed_at | timestamptz | When completed their role |
| notes | text | Role-specific notes |
| created_at | timestamptz | When linked |

---

### service.ticket_vendors

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| vendor_id | uuid | → directory.companies |
| vendor_contact_id | uuid | → directory.contacts (specific person) |
| role | text | PRIMARY, SECONDARY, QUOTE_ONLY |
| vendor_category | text | Electrical, Plumbing, AC, etc. |
| vendor_type | text | Third Party, Preferred, Emergency |
| scheduled_date | date | When vendor scheduled |
| actual_date | date | When vendor actually came |
| status | text | Scheduled, Confirmed, Completed, Cancelled, No-Show |
| cost_estimate | numeric(10,2) | Quoted cost |
| actual_cost | numeric(10,2) | Final cost |
| invoice_number | text | Vendor invoice reference |
| internal_score | integer | 1-5 performance rating |
| score_notes | text | Why this score |
| notes | text | Vendor-specific notes |
| created_at | timestamptz | When added |
| updated_at | timestamptz | When changed |

---

## TICKET JOIN TABLES — TRACKING

### service.ticket_misses

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| scheduled_date | date | The date that was missed |
| miss_date | date | When the miss was recorded |
| shift_id | uuid | → team.shifts (shift that missed) |
| member_id | uuid | → team.team_directory |
| miss_reason_code | text | NO_SHOW, SCHEDULING_ERROR, ACCESS_ISSUE, etc. |
| rescheduled_date | date | New scheduled date |
| notes | text | Additional notes |
| created_at | timestamptz | When recorded |

---

### service.ticket_costs

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| cost_type | text | labor, supplies, parts, vendor_service, adjustment, other |
| description | text | What this cost is for |
| amount | numeric(10,2) | Dollar amount |
| quantity | numeric(10,2) | If applicable |
| unit_cost | numeric(10,2) | If applicable |
| allocation | text | owner, company, guest, split |
| allocation_percentage | numeric(5,2) | If split |
| homeowner_id | uuid | → property.homeowners (if allocated to owner) |
| vendor_id | uuid | → directory.companies (if vendor cost) |
| purchase_id | uuid | → service.ticket_purchases |
| time_entry_id | uuid | → team.time_entries |
| transaction_id | uuid | → finance.transactions (when posted) |
| is_posted | boolean | Posted to accounting? |
| notes | text | Cost notes |
| created_at | timestamptz | When added |

---

### service.ticket_purchases

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| supplier_id | uuid | → directory.companies |
| brand_manufacturer | text | Brand or manufacturer |
| order_platform | text | Amazon, Home Depot, etc. |
| order_number | text | External order number |
| order_date | date | When ordered |
| expected_delivery_date | date | Original delivery date |
| actual_delivery_date | date | When delivered |
| shipping_carrier | text | FedEx, UPS, USPS |
| tracking_number | text | Shipping tracking |
| item_description | text | What was ordered |
| quantity | integer | How many |
| unit_cost | numeric(10,2) | Cost per unit |
| total_cost | numeric(10,2) | Total for purchase |
| receipt_file_id | uuid | → storage.files |
| status | text | Ordered, Shipped, Delivered, Returned, Cancelled |
| notes | text | Purchase notes |
| created_at | timestamptz | When added |

---

### service.ticket_events

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| event_id | text | Business ID: EVT-NNNNNNNN |
| ticket_id | uuid | → service.tickets |
| event_type | text | STATUS_CHANGE, ASSIGNED, COMMENT, FIELD_UPDATE, SYSTEM |
| event_subtype | text | More specific (e.g., assigned_to_shift, priority_changed) |
| actor_member_id | uuid | → team.team_directory |
| actor_contact_id | uuid | → directory.contacts |
| field_name | text | Which field changed |
| old_value | text | Previous value |
| new_value | text | New value |
| old_status | text | For status changes |
| new_status | text | For status changes |
| old_assignee_id | uuid | → team.team_directory |
| new_assignee_id | uuid | → team.team_directory |
| comment_body | text | For comments |
| is_internal | boolean | Internal only or visible to guest/owner? |
| is_automated | boolean | System-generated vs human action |
| automation_source | text | Which system/trigger created it |
| created_at | timestamptz | When event occurred |

---

### service.ticket_labels

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| label_id | uuid | → ref.label_key |
| freeform_label | text | Custom label if not from key |
| applied_by_id | uuid | → team.team_directory |
| applied_at | timestamptz | When applied |
| removed_at | timestamptz | If removed (soft tracking) |
| created_at | timestamptz | Record created |

**Unique Constraint:** (ticket_id, label_id) WHERE removed_at IS NULL

---

## TICKET JOIN TABLES — OPERATIONS

### service.ticket_inspections

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| inspection_id | uuid | → property.inspections |
| relationship | text | ROOT_CAUSE, FOLLOWUP, FOUND_BY, VERIFICATION |
| notes | text | Link notes |
| created_at | timestamptz | When linked |

---

### service.ticket_cleans

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| clean_id | uuid | → property.cleans |
| relationship | text | FOUND_DURING_CLEAN, CAUSED_RECLEAN, VERIFIED_BY_CLEAN |
| notes | text | Link notes |
| created_at | timestamptz | When linked |

---

### service.ticket_inventory_events

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| inventory_event_id | uuid | → property.inventory_events |
| quantity | integer | How many affected |
| notes | text | Inventory notes |
| created_at | timestamptz | When linked |

---

### service.ticket_recurring

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| recurring_task_id | uuid | → service.recurring_tasks |
| scheduled_date | date | When this instance was due |
| knowledge_article_id | uuid | → knowledge.articles (SOP/guidebook) |
| checklist_template_id | uuid | → service.checklist_templates |
| is_on_schedule | boolean | Completed on time? |
| notes | text | Instance-specific notes |
| created_at | timestamptz | When generated |

---

### service.ticket_transactions

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| transaction_id | uuid | → finance.transactions |
| role | text | EXPENSE, OWNER_CHARGE, ADJUSTMENT, REFUND, CLAIM_RECOVERY |
| created_at | timestamptz | When linked |

---

## PROJECTS

### service.projects

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| project_id | text | Business ID: PRJ-NNNNNN |
| project_name | text | Project name |
| project_description | text | Description |
| project_type | text | LISTING_UPDATE, INVENTORY_ROLLOUT, POLICY_CHANGE, COMPLIANCE |
| scope_type | text | PROPERTY, RESORT, PORTFOLIO, GLOBAL |
| resort_id | uuid | → property.resorts (if resort-scoped) |
| status | text | DRAFT, ACTIVE, PAUSED, COMPLETED, CANCELLED |
| priority | text | LOW, MEDIUM, HIGH, CRITICAL |
| target_start_date | date | When should start |
| target_end_date | date | When should complete |
| actual_start_date | date | When actually started |
| actual_end_date | date | When completed |
| owner_member_id | uuid | → team.team_directory (project owner) |
| notes | text | Project notes |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

---

### service.project_properties

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| project_id | uuid | → service.projects |
| property_id | uuid | → property.properties |
| resort_id | uuid | → property.resorts |
| status | text | PENDING, IN_PROGRESS, DONE, SKIPPED, BLOCKED |
| assigned_member_id | uuid | → team.team_directory |
| assigned_at | timestamptz | When property added to project |
| started_at | timestamptz | When work started |
| completed_at | timestamptz | When completed |
| notes | text | Property-specific notes |
| skip_reason | text | If skipped, why |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

**Unique Constraint:** (project_id, property_id)

---

### service.project_tickets

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| project_id | uuid | → service.projects |
| ticket_id | uuid | → service.tickets |
| property_id | uuid | → property.properties (which property this ticket covers) |
| role | text | PRIMARY, SUBTASK, FOLLOWUP |
| sequence_order | integer | Order within project |
| is_required | boolean | Must complete for project completion? |
| notes | text | Link notes |
| created_at | timestamptz | When linked |

**Unique Constraint:** (project_id, ticket_id)

---

## DAMAGE CLAIMS

### service.ticket_damage

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| damage_category_code | text | → ref.damage_category_key |
| description | text | Damage description |
| estimated_cost | numeric(10,2) | Initial cost estimate |
| discovered_at | timestamptz | When damage found |
| discovered_by_id | uuid | → team.team_directory |
| damage_claim_id | uuid | → service.damage_claims (when claim created) |
| notes | text | Additional notes |
| created_at | timestamptz | When record created |

---

### service.ticket_claims

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| damage_claim_id | uuid | → service.damage_claims |
| allocated_cost | numeric(10,2) | How much cost attributed to claim |
| is_recovery_blocking | boolean | Ticket blocks claim resolution? |
| link_type | text | repair, replacement, assessment, re-clean |
| notes | text | Link notes |
| created_at | timestamptz | When linked |

---

### service.damage_claims

| Column | Type | Description |
|--------|------|-------------|
| **Identity** | | |
| id | uuid | Primary key |
| claim_id | text | Business ID: CLM-NNNNNN |
| ticket_id | uuid | → service.tickets (origin ticket) |
| reservation_id | uuid | → reservations.reservations |
| **Classification** | | |
| damage_category_code | text | → ref.damage_category_key |
| incident_date | date | When damage occurred |
| discovery_source | text | INSPECTION, CLEAN, GUEST, OWNER, SYSTEM |
| status_code | text | OPEN, SUBMITTED, PARTIAL, CLOSED, DENIED |
| priority | text | LOW, MEDIUM, HIGH, URGENT |
| **Description** | | |
| claim_name | text | Short description |
| description | text | Detailed description |
| work_notes | text | Internal notes |
| **Our Team** | | |
| discovered_by_id | uuid | → team.team_directory |
| claim_owner_id | uuid | → team.team_directory (managing claim) |
| **Financials (Totals)** | | |
| total_damage_cost | numeric(10,2) | Full cost of damage |
| total_recovered | numeric(10,2) | Sum of successful recoveries |
| total_denied | numeric(10,2) | Sum of denials |
| outstanding | numeric(10,2) | What's still owed |
| **Final Responsibility** | | |
| responsible_party | text | GUEST, OWNER, COMPANY, OTA, INSURER, MIXED, WRITTEN_OFF |
| homeowner_charged | boolean | Was homeowner charged? |
| homeowner_charge_date | date | When charged |
| homeowner_charge_amount | numeric(10,2) | Amount charged |
| **Dates** | | |
| discovery_date | date | When found |
| created_at | timestamptz | When claim created |
| resolved_at | timestamptz | When fully resolved |
| updated_at | timestamptz | Record updated |

---

### service.damage_claim_submissions

| Column | Type | Description |
|--------|------|-------------|
| **Identity** | | |
| id | uuid | Primary key |
| submission_id | text | Business ID: SUB-{claim_suffix}-NN |
| damage_claim_id | uuid | → service.damage_claims |
| submission_number | integer | Sequence (1, 2, 3...) |
| **Submission Type** | | |
| submission_type_code | text | → ref.claim_submission_type_key |
| **Who We Submitted To** | | |
| submitted_to_company_id | uuid | → directory.companies (insurance, Airbnb, VRBO, etc.) |
| submitted_to_contact_id | uuid | → directory.contacts (specific rep) |
| external_claim_number | text | Their reference number |
| **Our Team** | | |
| submitted_by_id | uuid | → team.team_directory |
| **Timeline** | | |
| submission_deadline | date | Deadline to submit |
| submitted_at | timestamptz | When submitted |
| response_due_at | date | When we expect response |
| response_at | timestamptz | When they responded |
| **Financials** | | |
| amount_requested | numeric(10,2) | What we asked for |
| amount_approved | numeric(10,2) | Sum from approvals |
| amount_denied | numeric(10,2) | Sum from denials |
| amount_received | numeric(10,2) | Sum from approvals.amount_received |
| **Outcome** | | |
| status_code | text | DRAFT, SUBMITTED, PENDING, APPROVED, PARTIAL, DENIED, COLLECTED |
| outcome | text | FULL_APPROVAL, PARTIAL_APPROVAL, FULL_DENIAL, WITHDRAWN |
| **Notes** | | |
| notes | text | Submission notes |
| lessons_learned | text | What to do differently |
| **Audit** | | |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

**Unique Constraint:** (damage_claim_id, submission_number)

---

### service.damage_claim_approvals

| Column | Type | Description |
|--------|------|-------------|
| **Identity** | | |
| id | uuid | Primary key |
| approval_id | text | Business ID: APV-{submission_suffix}-NN |
| damage_claim_id | uuid | → service.damage_claims |
| submission_id | uuid | → service.damage_claim_submissions |
| approval_number | integer | Sequence within submission |
| **What Was Approved** | | |
| item_description | text | Specific item/cost approved |
| amount_claimed | numeric(10,2) | What we asked |
| amount_approved | numeric(10,2) | What they approved |
| is_partial | boolean | Less than claimed? (triggers next action) |
| variance_reason | text | Why less (depreciation, etc.) |
| **Payment Expected** | | |
| expected_payment_date | date | When payment should arrive |
| payment_method | text | CHECK, ACH, OTA_CREDIT, CARD_CREDIT |
| payment_terms | text | Any conditions |
| **Payment Received** | | |
| transaction_id | uuid | → finance.transactions |
| amount_received | numeric(10,2) | Actual amount |
| payment_date | date | When received |
| payment_reference | text | Check #, ACH ref |
| **Reconciliation** | | |
| is_reconciled | boolean | Payment matches approval? |
| reconciliation_variance | numeric(10,2) | amount_received - amount_approved |
| reconciliation_notes | text | Explanation if variance |
| **Dates** | | |
| approved_at | timestamptz | When approved |
| **Notes** | | |
| notes | text | Approval notes |
| **Audit** | | |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

**Unique Constraint:** (submission_id, approval_number)

---

### service.damage_claim_denials

| Column | Type | Description |
|--------|------|-------------|
| **Identity** | | |
| id | uuid | Primary key |
| denial_id | text | Business ID: DNL-{submission_suffix}-NN |
| damage_claim_id | uuid | → service.damage_claims |
| submission_id | uuid | → service.damage_claim_submissions |
| denial_number | integer | Sequence within submission |
| **What Was Denied** | | |
| item_description | text | Specific item/cost denied |
| amount_denied | numeric(10,2) | Dollar amount |
| **Why** | | |
| denial_code | text | Their denial code |
| denial_reason | text | Detailed explanation |
| denial_letter_file_id | uuid | → storage.files (their documentation) |
| **Learning** | | |
| preventable | boolean | Could we have prevented? |
| prevention_notes | text | What to do differently (includes what was missing) |
| **Dates** | | |
| denied_at | timestamptz | When denied |
| **Audit** | | |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

**Unique Constraint:** (submission_id, denial_number)

---

### service.damage_claim_appeals

| Column | Type | Description |
|--------|------|-------------|
| **Identity** | | |
| id | uuid | Primary key |
| appeal_id | text | Business ID: APL-{submission_suffix}-NN |
| damage_claim_id | uuid | → service.damage_claims |
| submission_id | uuid | → service.damage_claim_submissions |
| denial_id | uuid | → service.damage_claim_denials |
| appeal_number | integer | Sequence within submission |
| **Appeal Details** | | |
| appeal_submitted_at | timestamptz | When submitted |
| appeal_reason | text | Why we're appealing |
| **Response** | | |
| appeal_status_code | text | PENDING, UPHELD, OVERTURNED, PARTIAL |
| is_partial | boolean | Partial success? |
| outcome_notes | text | Their explanation |
| additional_recovered | numeric(10,2) | Additional amount from appeal |
| **Audit** | | |
| created_at | timestamptz | Record created |
| updated_at | timestamptz | Record updated |

**Unique Constraint:** (submission_id, appeal_number)

---

# PART 5: TABLE INVENTORY — STORAGE SCHEMA

---

## storage.files

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| file_id | text | Business ID: FILE-NNNNNNNN |
| file_url | text | S3/Supabase Storage URL |
| thumbnail_url | text | Smaller version |
| file_type | text | image, document, video |
| mime_type | text | image/jpeg, application/pdf, etc. |
| file_size_bytes | integer | File size |
| original_filename | text | Original name when uploaded |
| property_id | uuid | → property.properties (where taken, if applicable) |
| room_id | uuid | → property.rooms (where taken, if applicable) |
| uploaded_by_id | uuid | → team.team_directory |
| uploaded_at | timestamptz | When uploaded |
| created_at | timestamptz | Record created |

---

## storage.ticket_files

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | → service.tickets |
| file_id | uuid | → storage.files |
| context_type | text | before, after, damage, receipt, completion, owner_visible |
| caption | text | Description |
| is_owner_visible | boolean | Show to homeowner? |
| is_guest_visible | boolean | Show to guest? |
| sort_order | integer | Display order |
| created_at | timestamptz | When linked |

---

## storage.inspection_files

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| inspection_id | uuid | → property.inspections |
| file_id | uuid | → storage.files |
| context_type | text | issue, room, completion, checklist_item |
| inspection_item_id | uuid | → property.inspection_items (if specific item) |
| room_id | uuid | → property.rooms |
| caption | text | Description |
| sort_order | integer | Display order |
| created_at | timestamptz | When linked |

---

## storage.room_files

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| room_id | uuid | → property.rooms |
| file_id | uuid | → storage.files |
| context_type | text | reference, current, issue |
| is_reference | boolean | Is this the baseline reference photo? |
| caption | text | Description |
| sort_order | integer | Display order |
| created_at | timestamptz | When linked |

---

# PART 6: TABLE INVENTORY — REF SCHEMA

---

## ref.ticket_type_key

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_type | text | Property Care, Reservation, Admin, Accounting |
| type_code | text | PC, RSV, ADM, ACCT |
| type_id_prefix | text | TIK-PC, TIK-RSV, TIK-ADM, TIK-ACCT |
| type_description | text | Description |
| default_labor_allocation | text | owner, company |
| default_sla_hours | integer | Default SLA |
| requires_property | boolean | Needs property? |
| requires_reservation | boolean | Needs reservation? |
| sort_order | integer | Display order |
| is_active | boolean | Active flag |

---

## ref.ticket_category_key

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| category_code | text | PC-PLUMBING, RSV-LATE_CHECKOUT, etc. |
| ticket_type_code | text | PC, RSV, ADM, ACCT |
| category_name | text | Plumbing, Late Checkout (display name) |
| category_description | text | Description |
| default_assigned_team | text | Team to auto-assign |
| default_priority | text | Default priority |
| requires_vendor | boolean | Typically needs vendor? |
| triggers_inventory_check | boolean | Check inventory? |
| sort_order | integer | Display order within type |
| is_active | boolean | Active flag |

---

## ref.ticket_priority_key

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| priority_code | text | CRITICAL, HIGH, MEDIUM, LOW |
| priority_name | text | Critical, High, Medium, Low |
| sla_hours | integer | 4, 24, 48, 72 |
| sort_order | integer | Display order |
| is_active | boolean | Active flag |

---

## ref.activity_types

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| activity_type_code | text | CLEAN, INSPECT, MAINT, REPAIR, DAMAGE, INVENTORY, ADMIN, TRAVEL |
| activity_name | text | Display name |
| activity_category | text | cleaning, inspection, maintenance, admin, travel, claims, inventory |
| links_to_table | text | Which table this typically links to |
| default_duration_minutes | integer | Expected duration |
| is_billable | boolean | Can be billed |
| billable_to_default | text | Default billable entity |
| requires_property | boolean | Must have property context |
| description | text | Full description |
| sort_order | integer | Display order |
| is_active | boolean | Active flag |

---

## ref.label_key

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| label_code | text | URGENT, VIP_GUEST, OWNER_ESCALATION, AI_FLAGGED, etc. |
| label_name | text | Display name |
| label_group | text | RISK, THEME, AI, OPS |
| label_color | text | Hex color for UI |
| description | text | What this label means |
| is_system | boolean | System-managed vs user-created |
| is_active | boolean | Active flag |
| sort_order | integer | Display order |

---

## ref.damage_category_key

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| category_code | text | APPLIANCE, FURNITURE, LINENS, etc. |
| category_name | text | Display name |
| category_description | text | Description |
| typical_cost_range_low | numeric(10,2) | Low end estimate |
| typical_cost_range_high | numeric(10,2) | High end estimate |
| sort_order | integer | Display order |
| is_active | boolean | Active flag |

---

## ref.claim_submission_type_key

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| submission_type_code | text | DAMAGE_WAIVER, AIRBNB, VRBO, GUEST_DIRECT, HOMEOWNER |
| submission_type_name | text | Display name |
| typical_deadline_days | integer | Days to submit |
| typical_response_days | integer | Days to respond |
| sort_order | integer | Typical order (1=first, 4=last resort) |
| is_active | boolean | Active flag |

---

## ref.denial_category_key

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| denial_category_code | text | DOCUMENTATION, TIMING, COVERAGE, etc. |
| denial_category_name | text | Display name |
| denial_category_description | text | Description |
| is_preventable_default | boolean | Usually preventable? |
| prevention_guidance | text | How to prevent |
| sort_order | integer | Display order |
| is_active | boolean | Active flag |

---

# PART 7: TABLE COUNTS

---

## Summary by Schema

| Schema | Tables |
|--------|--------|
| service | 30 |
| team | 6 |
| storage | 4 |
| ref | 8 |
| **TOTAL** | **48** |

---

## Complete Table List

### service Schema (30 tables)

| # | Table | Purpose |
|---|-------|---------|
| 1 | service.tickets | Core ticket data |
| 2 | service.ticket_time_entries | Ticket ↔ time allocation |
| 3 | service.inspection_time_entries | Inspection ↔ time allocation |
| 4 | service.ticket_properties | Property links |
| 5 | service.ticket_reservations | Reservation links |
| 6 | service.ticket_homeowners | Homeowner links |
| 7 | service.ticket_relationships | Related tickets |
| 8 | service.ticket_shifts | Shift assignments |
| 9 | service.ticket_contacts | People + notifications |
| 10 | service.ticket_vendors | Vendor services + scoring |
| 11 | service.ticket_misses | Miss history |
| 12 | service.ticket_costs | Cost allocations |
| 13 | service.ticket_purchases | Procurement |
| 14 | service.ticket_events | Activity log |
| 15 | service.ticket_labels | Tagging |
| 16 | service.ticket_inspections | Inspection links |
| 17 | service.ticket_cleans | Clean links |
| 18 | service.ticket_inventory_events | Inventory links |
| 19 | service.ticket_recurring | Recurring task links |
| 20 | service.ticket_transactions | Finance links |
| 21 | service.projects | Umbrella tasks |
| 22 | service.project_properties | Per-property checklist |
| 23 | service.project_tickets | Tickets linked to projects |
| 24 | service.ticket_damage | Damage flags |
| 25 | service.ticket_claims | Ticket-to-claim links |
| 26 | service.damage_claims | Damage events |
| 27 | service.damage_claim_submissions | Recovery attempts |
| 28 | service.damage_claim_approvals | Approvals + payments |
| 29 | service.damage_claim_denials | Denials + reasons |
| 30 | service.damage_claim_appeals | Appeals |

### team Schema (6 tables)

| # | Table | Purpose |
|---|-------|---------|
| 1 | team.teams | Team definitions |
| 2 | team.team_directory | Team members |
| 3 | team.shifts | Shift scheduling |
| 4 | team.time_entries | Time tracking |
| 5 | team.time_entry_verifications | Verification history |
| 6 | team.shift_time_entries | Shift ↔ time allocation |

### storage Schema (4 tables)

| # | Table | Purpose |
|---|-------|---------|
| 1 | storage.files | Central file registry |
| 2 | storage.ticket_files | Ticket ↔ file links |
| 3 | storage.inspection_files | Inspection ↔ file links |
| 4 | storage.room_files | Room ↔ file links |

### ref Schema (8 tables)

| # | Table | Purpose |
|---|-------|---------|
| 1 | ref.ticket_type_key | PC, RSV, ADM, ACCT |
| 2 | ref.ticket_category_key | Categories per type |
| 3 | ref.ticket_priority_key | Priority + SLA hours |
| 4 | ref.activity_types | Time entry activities |
| 5 | ref.label_key | Ticket labels |
| 6 | ref.damage_category_key | Damage categories |
| 7 | ref.claim_submission_type_key | Submission types |
| 8 | ref.denial_category_key | Denial categories |

---

# PART 8: CALCULATED FIELDS & VIEWS

---

## Fields Calculated in Views (Not Stored)

| Field | Calculation |
|-------|-------------|
| missed_service_count | COUNT from service.ticket_misses |
| days_over_missed | CURRENT_DATE - MIN(ticket_misses.scheduled_date) |
| sla_hours | From ref.ticket_priority_key based on priority |
| elapsed_hours | EXTRACT(EPOCH FROM (now() - created_at))/3600 |
| is_within_sla | elapsed_hours <= sla_hours |
| total_allocated_seconds | SUM from ticket_time_entries |
| total_labor_cost | SUM from time_entries via ticket_time_entries |
| total_supplies_cost | SUM from ticket_purchases |
| total_cost | Aggregated from all cost sources |
| project_completion_pct | completed properties / total properties |
| claim_recovery_rate | total_recovered / total_damage_cost |

---

## Key Views

### v_tickets_full
Complete ticket with all common joins for dashboard display.

### v_time_by_ticket
Aggregated time entries per ticket.

### v_time_by_shift
Aggregated time entries per shift.

### v_time_by_inspection
Aggregated time entries per inspection.

### v_project_progress
Project completion metrics.

### v_damage_claim_recovery
Claim recovery lifecycle and totals.

### v_ticket_sla_status
SLA calculations per ticket.

---

# PART 9: UI MAPPING

---

## Single Ticket Form → Multiple Tables

| UI Section | Table Updated |
|------------|---------------|
| Title, Description, Status, Priority | service.tickets |
| Property dropdown | service.ticket_properties |
| Reservation link | service.ticket_reservations |
| Shift assignment | service.ticket_shifts |
| Add vendor | service.ticket_vendors |
| Log time | team.time_entries + service.ticket_time_entries |
| Add cost | service.ticket_costs |
| Upload photo | storage.files + storage.ticket_files |
| Link inspection | service.ticket_inspections |
| Flag damage | service.ticket_damage |
| Link to claim | service.ticket_claims |
| Add label | service.ticket_labels |
| Add comment | service.ticket_events |
| Add/remove notification recipient | service.ticket_contacts |

---

## Time Entry Allocation Workflow

1. Team member clocks time at property
2. Creates `team.time_entries` with total duration
3. Reviews work done (inspection + tickets)
4. Allocates time via:
   - `service.inspection_time_entries` for inspection work
   - `service.ticket_time_entries` for each ticket worked
5. Total allocated should equal total duration
6. Supervisor reviews via `team.shift_time_entries` for HR purposes
7. Supervisor approves/verifies via `team.time_entry_verifications`

---

# PART 10: CROSS-SCHEMA RELATIONSHIPS

---

## Visual Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              team schema                                     │
│                                                                              │
│  teams ←── team_directory ←── shifts                                        │
│                  │               │                                           │
│                  │               ├── shift_time_entries ──┐                 │
│                  │               │                         │                 │
│                  └───────────────┼── time_entries ←────────┘                │
│                                  │        │                                  │
│                                  │        └── time_entry_verifications      │
│                                  │                                           │
└──────────────────────────────────┼───────────────────────────────────────────┘
                                   │
                                   │ (FKs across schemas)
                                   │
┌──────────────────────────────────┼───────────────────────────────────────────┐
│                              service schema                                  │
│                                  │                                           │
│  ┌───────────────────────────────┼───────────────────────────────────┐      │
│  │                          tickets                                   │      │
│  │                               │                                    │      │
│  │  ┌────────────────────────────┼────────────────────────────┐      │      │
│  │  │                            │                            │      │      │
│  │  ▼                            ▼                            ▼      │      │
│  │ ticket_time_entries    ticket_properties           ticket_shifts  │      │
│  │ inspection_time_entries ticket_reservations        ticket_contacts│      │
│  │                         ticket_homeowners          ticket_vendors │      │
│  │                         ticket_relationships                      │      │
│  │                                                                   │      │
│  │ ticket_misses   ticket_inspections   projects                     │      │
│  │ ticket_costs    ticket_cleans        project_properties           │      │
│  │ ticket_purchases ticket_inventory_events project_tickets          │      │
│  │ ticket_events   ticket_recurring                                  │      │
│  │ ticket_labels   ticket_transactions                               │      │
│  │                                                                   │      │
│  │ ticket_damage ──► damage_claims                                   │      │
│  │ ticket_claims ──► damage_claim_submissions                        │      │
│  │                   damage_claim_approvals                          │      │
│  │                   damage_claim_denials                            │      │
│  │                   damage_claim_appeals                            │      │
│  └───────────────────────────────────────────────────────────────────┘      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ (FKs to storage)
                                   │
┌──────────────────────────────────┼───────────────────────────────────────────┐
│                              storage schema                                  │
│                                  │                                           │
│  files ←── ticket_files                                                     │
│        ←── inspection_files                                                 │
│        ←── room_files                                                       │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ (FKs to ref)
                                   │
┌──────────────────────────────────┼───────────────────────────────────────────┐
│                              ref schema                                      │
│                                                                              │
│  ticket_type_key          activity_types          damage_category_key       │
│  ticket_category_key      label_key               claim_submission_type_key │
│  ticket_priority_key                              denial_category_key       │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

*Document Version: 4.0 (Final Consolidated)*  
*Created: 2025-12-08*  
*Sources: ChatGPT thread + Claude thread consolidated*  
*Total Tables: 48 (30 service + 6 team + 4 storage + 8 ref)*
