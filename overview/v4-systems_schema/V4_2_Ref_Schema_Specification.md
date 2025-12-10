# REF Schema V4.2 — Hybrid Design Specification

**Version:** 4.2.1
**Date:** December 10, 2025
**Purpose:** Simplified reference data architecture using unified lookup tables for simple types, cross-schema configuration tables, and centralized status management.

---

## Design Philosophy

The ref schema serves as the central repository for **cross-schema** lookup/reference data. Rather than maintaining 39+ nearly-identical tables, we use a **hybrid approach**:

1. **Unified Lookup System** (2 tables) — For simple code/name/description types
2. **Fee Configuration** (2 tables) — Cross-schema fee type definitions
3. **Status System** (4 tables) — Centralized status management and audit trail

**Domain-specific configuration** has been moved to domain schemas:
- Journey/touchpoint configuration → `reservations` schema
- Interest/preference configuration → `concierge` schema

This reduces the ref table count from ~42 to **8 tables** while maintaining type safety and query performance.

---

## PART 1: UNIFIED LOOKUP SYSTEM

### 1.1 ref.lookup_domains

**PURPOSE:** Registry of all lookup domains. Defines what types of lookups exist and binds them to their target tables.

```sql
CREATE TABLE ref.lookup_domains (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Domain identification
    domain_code text NOT NULL UNIQUE,
    domain_name text NOT NULL,
    description text,

    -- Schema binding (which table/column uses this domain)
    bound_schema text,
    bound_table text,
    bound_column text,

    -- Attribute schema (JSON Schema for validating domain-specific attributes)
    attribute_schema jsonb,

    -- Behavior flags
    allow_hierarchy boolean DEFAULT false,
    allow_user_created boolean DEFAULT true,
    requires_parent boolean DEFAULT false,
    parent_domain_code text,

    -- Metadata
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Index for parent lookups
CREATE INDEX idx_lookup_domains_parent ON ref.lookup_domains(parent_domain_code)
    WHERE parent_domain_code IS NOT NULL;
```

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| domain_code | text | Unique domain identifier (TICKET_TYPE, ROOM_TYPE) |
| domain_name | text | Human-readable name |
| description | text | Domain description |
| bound_schema | text | Target schema name |
| bound_table | text | Target table name |
| bound_column | text | Target column name |
| attribute_schema | jsonb | JSON Schema for validating attributes |
| allow_hierarchy | boolean | Can values have parent-child relationships? |
| allow_user_created | boolean | Can users add new values? |
| requires_parent | boolean | Must values have a parent? |
| parent_domain_code | text | If hierarchical, which domain is the parent? |
| is_active | boolean | Domain active flag |

---

### 1.2 ref.lookup_values

**PURPOSE:** All simple lookup values across all domains. Single table replaces ~30 individual type tables.

```sql
CREATE TABLE ref.lookup_values (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Domain and value identification
    domain_code text NOT NULL REFERENCES ref.lookup_domains(domain_code),
    value_code text NOT NULL,
    value_name text NOT NULL,
    description text,

    -- Hierarchy support (for parent-child relationships)
    parent_id uuid REFERENCES ref.lookup_values(id),
    parent_domain_code text,
    parent_value_code text,

    -- Extended attributes (domain-specific fields as JSONB)
    attributes jsonb DEFAULT '{}',

    -- Display and behavior
    sort_order integer DEFAULT 0,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_system boolean DEFAULT false,

    -- Metadata
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),

    -- Constraints
    CONSTRAINT uq_lookup_domain_value UNIQUE (domain_code, value_code),
    CONSTRAINT chk_parent_consistency CHECK (
        (parent_id IS NULL AND parent_domain_code IS NULL AND parent_value_code IS NULL) OR
        (parent_id IS NOT NULL AND parent_domain_code IS NOT NULL AND parent_value_code IS NOT NULL)
    )
);

-- Performance indexes
CREATE INDEX idx_lookup_values_domain ON ref.lookup_values(domain_code);
CREATE INDEX idx_lookup_values_parent ON ref.lookup_values(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX idx_lookup_values_active ON ref.lookup_values(domain_code, is_active) WHERE is_active = true;
CREATE INDEX idx_lookup_values_default ON ref.lookup_values(domain_code) WHERE is_default = true;
CREATE INDEX idx_lookup_values_attributes ON ref.lookup_values USING gin(attributes);
```

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| domain_code | text | FK to lookup_domains |
| value_code | text | Business code (PC, KING, PLUMBING) |
| value_name | text | Display name |
| description | text | Value description |
| parent_id | uuid | Parent value (for hierarchies) |
| parent_domain_code | text | Parent's domain (denormalized for queries) |
| parent_value_code | text | Parent's code (denormalized for queries) |
| attributes | jsonb | Domain-specific extended attributes |
| sort_order | integer | Display ordering |
| is_default | boolean | Default value for this domain? |
| is_active | boolean | Value active flag |
| is_system | boolean | System-managed (not user-editable)? |

---

### 1.3 Validation Function

```sql
-- Function to validate lookup references
CREATE OR REPLACE FUNCTION ref.is_valid_lookup(
    p_domain text,
    p_code text,
    p_allow_null boolean DEFAULT true
)
RETURNS boolean AS $$
BEGIN
    -- Allow NULL if permitted
    IF p_code IS NULL THEN
        RETURN p_allow_null;
    END IF;

    -- Check if value exists and is active
    RETURN EXISTS(
        SELECT 1 FROM ref.lookup_values
        WHERE domain_code = p_domain
        AND value_code = p_code
        AND is_active = true
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to get lookup value name
CREATE OR REPLACE FUNCTION ref.get_lookup_name(p_domain text, p_code text)
RETURNS text AS $$
BEGIN
    RETURN (
        SELECT value_name FROM ref.lookup_values
        WHERE domain_code = p_domain AND value_code = p_code
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to get lookup attributes
CREATE OR REPLACE FUNCTION ref.get_lookup_attr(p_domain text, p_code text, p_attr text)
RETURNS text AS $$
BEGIN
    RETURN (
        SELECT attributes->>p_attr FROM ref.lookup_values
        WHERE domain_code = p_domain AND value_code = p_code
    );
END;
$$ LANGUAGE plpgsql STABLE;
```

---

### 1.4 Domains to Migrate to Unified System

The following 31 simple type tables will be replaced by domains in `lookup_values`:

| Domain Code | Old Table | Bound To | Attributes Schema |
|-------------|-----------|----------|-------------------|
| TICKET_TYPE | ref.ticket_type_key | service.tickets.ticket_type_code | `{"default_sla_hours": "integer", "requires_property": "boolean", "requires_reservation": "boolean"}` |
| TICKET_PRIORITY | ref.ticket_priority_key | service.tickets.priority | `{"sla_hours": "integer"}` |
| TICKET_STATUS | ref.status_types (ticket) | service.tickets.status | `{"is_terminal": "boolean"}` |
| ACTIVITY_TYPE | ref.activity_types | team.time_entries.activity_type_code | `{"default_duration_minutes": "integer", "is_billable": "boolean", "billable_to_default": "string"}` |
| LABEL | ref.label_key | service.ticket_labels.label_id | `{"label_group": "string", "label_color": "string"}` |
| DAMAGE_CATEGORY | ref.damage_category_key | service.damage_claims.damage_category_code | `{"typical_cost_low": "number", "typical_cost_high": "number"}` |
| CLAIM_SUBMISSION_TYPE | ref.claim_submission_type_key | service.damage_claim_submissions.submission_type_code | `{"typical_deadline_days": "integer", "typical_response_days": "integer"}` |
| DENIAL_CATEGORY | ref.denial_category_key | service.damage_claim_denials.denial_code | `{"is_preventable_default": "boolean", "prevention_guidance": "string"}` |
| ROOM_TYPE | ref.room_types | property.rooms.room_type_code | — |
| BED_TYPE | ref.bed_types | property.beds.bed_type_code | `{"sleeps": "integer"}` |
| AMENITY_TYPE | ref.amenity_types | property.property_amenities.amenity_type_code | `{"category": "string", "icon": "string"}` |
| APPLIANCE_TYPE | ref.appliance_types | property.appliances.appliance_type_code | `{"category": "string", "typical_lifespan_years": "integer", "maintenance_interval_months": "integer"}` |
| FIXTURE_TYPE | ref.fixture_types | property.fixtures.fixture_type_code | `{"category": "string"}` |
| SURFACE_TYPE | ref.surface_types | property.surfaces.surface_type_code | — |
| INVENTORY_ITEM_TYPE | ref.inventory_item_types | inventory.inventory_items.item_type_code | `{"category": "string", "is_trackable": "boolean", "default_par": "integer"}` |
| COUNTRY | ref.country_codes | directory.contacts.country_code | `{"currency_code": "string", "calling_code": "string"}` |
| STATE | ref.state_codes | directory.contacts.state | `{"country_code": "string", "timezone": "string"}` |
| CURRENCY | ref.currency_codes | finance.transactions.currency_code | `{"symbol": "string", "decimal_places": "integer"}` |
| LANGUAGE | ref.language_codes | directory.contacts.preferred_language | — |
| TIMEZONE | ref.timezone_codes | — | `{"utc_offset": "string"}` |
| PLATFORM_TYPE | ref.platform_types | reservations.reservations.booking_source | `{"is_ota": "boolean", "commission_rate": "number"}` |
| CHANNEL_TYPE | ref.channel_types | comms.channels.channel_code | — |
| DOCUMENT_TYPE | ref.document_types | knowledge.documents.document_type | — |
| RELATIONSHIP_TYPE | ref.relationship_types | directory.contact_relationships.relationship_type | `{"is_bidirectional": "boolean"}` |
| VENDOR_CATEGORY | ref.vendor_categories | directory.vendors.service_categories | — |
| EXPENSE_CATEGORY | ref.expense_categories | finance.expenses.category_code | `{"is_billable_default": "boolean"}` |
| REVENUE_CATEGORY | ref.revenue_categories | finance.transactions.category_code | — |
| TAX_TYPE | ref.tax_types | — | `{"rate": "number", "jurisdiction": "string"}` |
| INSPECTION_CATEGORY | ref.inspection_categories | property.inspection_questions.category | — |
| ISSUE_SEVERITY | ref.issue_severity_types | property.inspection_issues.severity | `{"response_hours": "integer"}` |
| CLEAN_TYPE | ref.cleaning_types | property.cleans.clean_type | `{"default_duration_minutes": "integer"}` |

---

### 1.5 Hierarchical Domains (Parent-Child)

Some domains have parent-child relationships:

| Child Domain | Parent Domain | Example |
|--------------|---------------|---------|
| TICKET_CATEGORY | TICKET_TYPE | PC-PLUMBING → PC |
| STATE | COUNTRY | HI → US |
| CITY | STATE | (if needed) |

```sql
-- Example: Ticket categories under ticket types
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, parent_id, parent_domain_code, parent_value_code, attributes)
SELECT
    'TICKET_CATEGORY',
    'PC-PLUMBING',
    'Plumbing',
    lv.id,
    'TICKET_TYPE',
    'PC',
    '{"default_priority": "MEDIUM", "requires_vendor": true}'::jsonb
FROM ref.lookup_values lv
WHERE lv.domain_code = 'TICKET_TYPE' AND lv.value_code = 'PC';
```

---

## PART 2: COMPLEX REFERENCE TABLES

These tables remain separate because they have unique relationships, complex business logic, or self-referential structures that don't fit cleanly into the unified model.

---

### 2.1 ref.fee_types + ref.fee_rates

**WHY SEPARATE:** Fee calculation requires rate tiers by scope (global, resort, property) with effective dates. Too complex for JSONB attributes.

```sql
CREATE TABLE ref.fee_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fee_type_code text NOT NULL UNIQUE,
    fee_type_name text NOT NULL,
    description text,
    is_taxable boolean DEFAULT false,
    is_refundable boolean DEFAULT true,
    default_amount numeric(10,2),
    calculation_method text,  -- flat, per_night, per_guest, percentage
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE TABLE ref.fee_rates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fee_type_id uuid NOT NULL REFERENCES ref.fee_types(id),
    scope_type text NOT NULL,  -- global, resort, property
    scope_id uuid,             -- resort_id or property_id
    rate numeric(10,2) NOT NULL,
    rate_type text NOT NULL,   -- flat, per_night, per_guest, percentage
    effective_date date NOT NULL,
    end_date date,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),

    CONSTRAINT uq_fee_rate_scope_date UNIQUE (fee_type_id, scope_type, scope_id, effective_date)
);

CREATE INDEX idx_fee_rates_effective ON ref.fee_rates(fee_type_id, effective_date DESC);
```

---

> **NOTE:** Journey/touchpoint tables moved to `reservations` schema. Concierge interest/preference tables moved to `concierge` schema. See those schemas for full specifications.

---

## PART 2B: STATUS SYSTEM TABLES

---

### 2.2 ref.status_types

**WHY SEPARATE:** Statuses have complex domain applicability, state machine transitions, and approval requirements that don't fit the simple lookup model.

```sql
CREATE TABLE ref.status_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code text NOT NULL UNIQUE,
    status_name text NOT NULL,
    description text,

    -- Behavior flags
    is_terminal boolean DEFAULT false,      -- No further transitions allowed
    requires_approval boolean DEFAULT false, -- Needs approval to enter

    -- Metadata
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_status_types_terminal ON ref.status_types(is_terminal);
```

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| status_code | text | Unique status identifier (active, approved, cancelled) |
| status_name | text | Display name |
| description | text | What this status means |
| is_terminal | boolean | If true, no further transitions allowed |
| requires_approval | boolean | If true, approval needed to enter this status |

**Initial Status Values:**

| status_code | status_name | is_terminal | requires_approval |
|-------------|-------------|-------------|-------------------|
| draft | Draft | false | false |
| pending_approval | Pending Approval | false | true |
| approved | Approved | false | true |
| executed | Executed | true | true |
| archived | Archived | true | false |
| sent | Sent | false | false |
| received | Received | false | false |
| open | Open | false | false |
| scheduled | Scheduled | false | true |
| paused | Paused | false | false |
| completed | Completed | false | false |
| closed | Closed | true | false |
| active | Active | false | false |
| inactive | Inactive | false | false |
| onboarding | Onboarding | false | false |
| offboarding | Offboarding | false | false |
| maintenance_hold | Maintenance Hold | false | true |
| long_term_rental | Long Term Rental | false | true |
| owner_hold | Owner Hold | false | false |
| confirmed | Confirmed | false | false |
| arrived | Arrived | false | false |
| departed | Departed | true | false |
| cancelled | Cancelled | true | false |
| terminated | Terminated | true | true |
| blocked | Blocked | true | true |
| void | Void | true | true |

---

### 2.3 ref.status_domains

**WHY SEPARATE:** Junction table defining which entity types can use which statuses. Enforces domain-specific status validation.

```sql
CREATE TABLE ref.status_domains (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_id uuid NOT NULL REFERENCES ref.status_types(id) ON DELETE CASCADE,
    domain_code text NOT NULL,  -- RSV, TIK, PRP, DOC, GST, HO, INT, etc.
    domain_name text,           -- Reservations, Tickets, Properties, etc.

    CONSTRAINT uq_status_domain UNIQUE (status_id, domain_code)
);

CREATE INDEX idx_status_domains_code ON ref.status_domains(domain_code);
```

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| status_id | uuid | FK to status_types |
| domain_code | text | Entity domain code (RSV, TIK, PRP, DOC, GST, HO, INT, FIN, PAY, TRX) |
| domain_name | text | Human-readable domain name |

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
| TRX | Transactions | finance.receipts |
| CTH | Conversations/Threads | comms.threads |
| CMSG | Messages | comms.messages |
| AIT | AI Agents | ai.agents |

---

### 2.4 ref.status_transitions

**WHY SEPARATE:** Defines the state machine — which statuses can transition to which other statuses. Essential for workflow validation.

```sql
CREATE TABLE ref.status_transitions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    from_status_id uuid NOT NULL REFERENCES ref.status_types(id) ON DELETE CASCADE,
    to_status_id uuid NOT NULL REFERENCES ref.status_types(id) ON DELETE CASCADE,
    domain_code text,           -- Optional: limit transition to specific domain
    requires_approval boolean DEFAULT false,
    requires_reason boolean DEFAULT false,

    CONSTRAINT uq_status_transition UNIQUE (from_status_id, to_status_id, domain_code)
);

CREATE INDEX idx_status_transitions_from ON ref.status_transitions(from_status_id);
CREATE INDEX idx_status_transitions_domain ON ref.status_transitions(domain_code) WHERE domain_code IS NOT NULL;
```

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| from_status_id | uuid | Starting status |
| to_status_id | uuid | Allowed destination status |
| domain_code | text | If set, transition only valid for this domain |
| requires_approval | boolean | If true, transition needs approval |
| requires_reason | boolean | If true, reason must be provided |

**Example Transitions:**

| From | To | Notes |
|------|----|-------|
| draft | pending_approval | Document workflow |
| pending_approval | approved | After approval |
| approved | executed | Final execution |
| open | scheduled | Ticket scheduling |
| open | completed | Direct completion |
| scheduled | completed | After work done |
| completed | closed | Final close |
| confirmed | arrived | Guest check-in |
| arrived | departed | Guest checkout |
| active | inactive | Deactivation |
| active | offboarding | Begin exit process |

---

### 2.5 ref.status_events

**WHY SEPARATE:** Centralized audit trail for ALL status changes across the system. Provides complete history without per-table history tables.

```sql
CREATE TABLE ref.status_events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- What changed
    domain_code text NOT NULL,          -- RSV, TIK, PRP, etc.
    entity_id uuid NOT NULL,            -- The record's UUID
    entity_business_id text,            -- Business ID (RES-2025-000001, TIK-PC-000001)

    -- Status change
    from_status_id uuid REFERENCES ref.status_types(id),
    to_status_id uuid NOT NULL REFERENCES ref.status_types(id),
    from_status_code text,              -- Denormalized for queries
    to_status_code text NOT NULL,       -- Denormalized for queries

    -- Context
    changed_by_id uuid,                 -- FK to team.team_directory (nullable for system)
    changed_by_type text DEFAULT 'user', -- user, system, automation, api
    reason text,                        -- Why the change was made
    metadata jsonb DEFAULT '{}',        -- Additional context

    -- Approval tracking
    approval_required boolean DEFAULT false,
    approved_by_id uuid,
    approved_at timestamptz,

    -- Timestamps
    changed_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
);

-- Performance indexes
CREATE INDEX idx_status_events_entity ON ref.status_events(domain_code, entity_id);
CREATE INDEX idx_status_events_time ON ref.status_events(changed_at DESC);
CREATE INDEX idx_status_events_business_id ON ref.status_events(entity_business_id) WHERE entity_business_id IS NOT NULL;
CREATE INDEX idx_status_events_status ON ref.status_events(to_status_code);
CREATE INDEX idx_status_events_changed_by ON ref.status_events(changed_by_id) WHERE changed_by_id IS NOT NULL;
```

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| domain_code | text | Entity type (RSV, TIK, PRP, etc.) |
| entity_id | uuid | The record's UUID |
| entity_business_id | text | Business ID for easy identification |
| from_status_id | uuid | Previous status (null if first) |
| to_status_id | uuid | New status |
| from_status_code | text | Previous status code (denormalized) |
| to_status_code | text | New status code (denormalized) |
| changed_by_id | uuid | Who made the change |
| changed_by_type | text | user, system, automation, api |
| reason | text | Why the change was made |
| metadata | jsonb | Additional context |
| approval_required | boolean | Did this transition require approval? |
| approved_by_id | uuid | Who approved (if required) |
| approved_at | timestamptz | When approved |
| changed_at | timestamptz | When the status changed |

**Usage Examples:**

```sql
-- Get full status history for a reservation
SELECT
    se.changed_at,
    se.from_status_code,
    se.to_status_code,
    se.reason,
    td.display_name AS changed_by
FROM ref.status_events se
LEFT JOIN team.team_directory td ON td.id = se.changed_by_id
WHERE se.domain_code = 'RSV'
  AND se.entity_business_id = 'RES-2025-000123'
ORDER BY se.changed_at;

-- Get all status changes in last 24 hours
SELECT
    domain_code,
    entity_business_id,
    from_status_code,
    to_status_code,
    changed_at
FROM ref.status_events
WHERE changed_at > now() - interval '24 hours'
ORDER BY changed_at DESC;

-- Get status change counts by domain
SELECT
    domain_code,
    to_status_code,
    count(*) as changes
FROM ref.status_events
WHERE changed_at > now() - interval '7 days'
GROUP BY domain_code, to_status_code
ORDER BY domain_code, changes DESC;
```

---

### 2.6 Status Validation Functions

```sql
-- Check if a status is valid for a domain
CREATE OR REPLACE FUNCTION ref.is_valid_status(
    p_domain text,
    p_status_code text
)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS(
        SELECT 1
        FROM ref.status_types st
        JOIN ref.status_domains sd ON sd.status_id = st.id
        WHERE sd.domain_code = p_domain
          AND st.status_code = p_status_code
          AND st.is_active = true
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- Check if a status transition is valid
CREATE OR REPLACE FUNCTION ref.is_valid_transition(
    p_domain text,
    p_from_status text,
    p_to_status text
)
RETURNS boolean AS $$
BEGIN
    -- First status (from NULL) is always valid if to_status is valid for domain
    IF p_from_status IS NULL THEN
        RETURN ref.is_valid_status(p_domain, p_to_status);
    END IF;

    -- Check transition exists
    RETURN EXISTS(
        SELECT 1
        FROM ref.status_transitions tr
        JOIN ref.status_types st_from ON st_from.id = tr.from_status_id
        JOIN ref.status_types st_to ON st_to.id = tr.to_status_id
        WHERE st_from.status_code = p_from_status
          AND st_to.status_code = p_to_status
          AND (tr.domain_code IS NULL OR tr.domain_code = p_domain)
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- Log a status change (call from application or trigger)
CREATE OR REPLACE FUNCTION ref.log_status_change(
    p_domain text,
    p_entity_id uuid,
    p_entity_business_id text,
    p_from_status text,
    p_to_status text,
    p_changed_by_id uuid DEFAULT NULL,
    p_changed_by_type text DEFAULT 'system',
    p_reason text DEFAULT NULL,
    p_metadata jsonb DEFAULT '{}'
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
    v_from_status_id uuid;
    v_to_status_id uuid;
BEGIN
    -- Get status IDs
    SELECT id INTO v_from_status_id FROM ref.status_types WHERE status_code = p_from_status;
    SELECT id INTO v_to_status_id FROM ref.status_types WHERE status_code = p_to_status;

    -- Insert event
    INSERT INTO ref.status_events (
        domain_code, entity_id, entity_business_id,
        from_status_id, to_status_id, from_status_code, to_status_code,
        changed_by_id, changed_by_type, reason, metadata
    ) VALUES (
        p_domain, p_entity_id, p_entity_business_id,
        v_from_status_id, v_to_status_id, p_from_status, p_to_status,
        p_changed_by_id, p_changed_by_type, p_reason, p_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql;
```

---

## PART 3: APPLYING CONSTRAINTS TO TARGET TABLES

### 3.1 CHECK Constraints Using Validation Function

```sql
-- service.tickets
ALTER TABLE service.tickets
ADD CONSTRAINT chk_ticket_type_valid
    CHECK (ref.is_valid_lookup('TICKET_TYPE', ticket_type_code, false)),
ADD CONSTRAINT chk_ticket_priority_valid
    CHECK (ref.is_valid_lookup('TICKET_PRIORITY', priority, false)),
ADD CONSTRAINT chk_ticket_status_valid
    CHECK (ref.is_valid_lookup('TICKET_STATUS', status, false));

-- property.rooms
ALTER TABLE property.rooms
ADD CONSTRAINT chk_room_type_valid
    CHECK (ref.is_valid_lookup('ROOM_TYPE', room_type_code));

-- property.beds
ALTER TABLE property.beds
ADD CONSTRAINT chk_bed_type_valid
    CHECK (ref.is_valid_lookup('BED_TYPE', bed_type_code, false));

-- property.appliances
ALTER TABLE property.appliances
ADD CONSTRAINT chk_appliance_type_valid
    CHECK (ref.is_valid_lookup('APPLIANCE_TYPE', appliance_type_code, false));

-- property.fixtures
ALTER TABLE property.fixtures
ADD CONSTRAINT chk_fixture_type_valid
    CHECK (ref.is_valid_lookup('FIXTURE_TYPE', fixture_type_code, false));

-- property.cleans
ALTER TABLE property.cleans
ADD CONSTRAINT chk_clean_type_valid
    CHECK (ref.is_valid_lookup('CLEAN_TYPE', clean_type, false));

-- team.time_entries
ALTER TABLE team.time_entries
ADD CONSTRAINT chk_activity_type_valid
    CHECK (ref.is_valid_lookup('ACTIVITY_TYPE', activity_type_code));

-- directory.contacts
ALTER TABLE directory.contacts
ADD CONSTRAINT chk_country_valid
    CHECK (ref.is_valid_lookup('COUNTRY', country_code)),
ADD CONSTRAINT chk_language_valid
    CHECK (ref.is_valid_lookup('LANGUAGE', preferred_language));

-- reservations.reservations
ALTER TABLE reservations.reservations
ADD CONSTRAINT chk_booking_source_valid
    CHECK (ref.is_valid_lookup('PLATFORM_TYPE', booking_source, false));

-- inventory.inventory_items
ALTER TABLE inventory.inventory_items
ADD CONSTRAINT chk_item_type_valid
    CHECK (ref.is_valid_lookup('INVENTORY_ITEM_TYPE', item_type_code));
```

---

## PART 4: COMPATIBILITY VIEWS

For backwards compatibility and simpler queries, create views that mimic the old table structure:

```sql
-- Ticket types view
CREATE OR REPLACE VIEW ref.v_ticket_types AS
SELECT
    id,
    value_code AS type_code,
    value_name AS ticket_type,
    description,
    (attributes->>'default_sla_hours')::integer AS default_sla_hours,
    (attributes->>'requires_property')::boolean AS requires_property,
    (attributes->>'requires_reservation')::boolean AS requires_reservation,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'TICKET_TYPE';

-- Ticket categories view (with parent join)
CREATE OR REPLACE VIEW ref.v_ticket_categories AS
SELECT
    lv.id,
    lv.value_code AS category_code,
    lv.parent_value_code AS ticket_type_code,
    lv.value_name AS category_name,
    lv.description,
    (lv.attributes->>'default_priority') AS default_priority,
    (lv.attributes->>'requires_vendor')::boolean AS requires_vendor,
    lv.sort_order,
    lv.is_active
FROM ref.lookup_values lv
WHERE lv.domain_code = 'TICKET_CATEGORY';

-- Room types view
CREATE OR REPLACE VIEW ref.v_room_types AS
SELECT
    id,
    value_code AS room_type_code,
    value_name AS room_type_name,
    description,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'ROOM_TYPE';

-- Bed types view
CREATE OR REPLACE VIEW ref.v_bed_types AS
SELECT
    id,
    value_code AS bed_type_code,
    value_name AS bed_type_name,
    (attributes->>'sleeps')::integer AS sleeps,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'BED_TYPE';

-- Activity types view
CREATE OR REPLACE VIEW ref.v_activity_types AS
SELECT
    id,
    value_code AS activity_type_code,
    value_name AS activity_name,
    description,
    (attributes->>'default_duration_minutes')::integer AS default_duration_minutes,
    (attributes->>'is_billable')::boolean AS is_billable,
    (attributes->>'billable_to_default') AS billable_to_default,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'ACTIVITY_TYPE';

-- Countries view
CREATE OR REPLACE VIEW ref.v_countries AS
SELECT
    id,
    value_code AS country_code,
    value_name AS country_name,
    (attributes->>'currency_code') AS currency_code,
    (attributes->>'calling_code') AS calling_code,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'COUNTRY';

-- Generic lookup helper view
CREATE OR REPLACE VIEW ref.v_all_lookups AS
SELECT
    domain_code,
    value_code,
    value_name,
    description,
    parent_domain_code,
    parent_value_code,
    attributes,
    sort_order,
    is_default,
    is_active
FROM ref.lookup_values
ORDER BY domain_code, sort_order, value_name;
```

---

## PART 5: SUMMARY

### Table Count Comparison

| Category | Before (V4.1) | After (V4.2.1) |
|----------|---------------|----------------|
| Simple lookup tables | 31 | 0 (→ lookup_values) |
| Unified lookup tables | 0 | 2 |
| Fee configuration | 0 | 2 |
| Status system | 0 | 4 |
| Journey/touchpoint | 3 | 0 (→ reservations schema) |
| Concierge config | 3 | 0 (→ concierge schema) |
| Compatibility views | 0 | 10+ |
| **Total REF Tables** | **~42** | **8** |

### REF Schema Table Inventory (8 Tables)

| # | Table | Category | Purpose |
|---|-------|----------|---------|
| 1 | ref.lookup_domains | Unified Lookup | Registry of all lookup domain types |
| 2 | ref.lookup_values | Unified Lookup | All simple lookup values (replaces 31 tables) |
| 3 | ref.fee_types | Fee Config | Fee type definitions (cross-schema) |
| 4 | ref.fee_rates | Fee Config | Fee rate tiers by scope and date |
| 5 | ref.status_types | Status System | Master status definitions |
| 6 | ref.status_domains | Status System | Status-to-entity domain mapping |
| 7 | ref.status_transitions | Status System | Valid state machine transitions |
| 8 | ref.status_events | Status System | Centralized status change audit trail |

### Tables Moved to Domain Schemas

| Old Location | New Location | Tables |
|--------------|--------------|--------|
| ref.journey_stages | reservations.journey_stages | 1 |
| ref.touchpoint_types | reservations.touchpoints | 1 |
| ref.stage_required_touchpoints | reservations.stage_touchpoints | 1 |
| ref.concierge_interest_categories | concierge.interest_categories | 1 |
| ref.concierge_interest_types | concierge.interests | 1 |
| ref.concierge_preference_levels | concierge.preference_levels | 1 |

### Benefits

1. **Simplified REF Schema** — Only 8 tables for truly cross-schema concerns
2. **Domain Cohesion** — Domain-specific config lives in domain schemas
3. **Single Admin Interface** — One CRUD for all simple lookups
4. **Flexible Attributes** — Add domain-specific fields without schema changes
5. **Hierarchical Support** — Parent-child relationships built-in
6. **Type Safety Preserved** — CHECK constraints validate all references
7. **Centralized Status Audit** — One table for ALL status history across system
8. **State Machine Enforcement** — Transition validation prevents invalid status changes

### Migration Path

1. Create `lookup_domains` and `lookup_values` tables
2. Create `fee_types` and `fee_rates` tables
3. Create status system tables (status_types, status_domains, status_transitions, status_events)
4. Create journey/touchpoint tables in reservations schema
5. Create interest/preference tables in concierge schema
6. Create validation functions
7. Migrate data from old tables
8. Add CHECK constraints to target tables
9. Create compatibility views
10. Remove deprecated tables

---

**Document Version:** 4.2.1
**Updated:** December 10, 2025
**Author:** Schema Design Team
