-- ============================================================================
-- REF SCHEMA V4.2 — Unified Lookup System
-- ============================================================================
-- Migrates from 39 individual reference tables to a hybrid model:
--   - 2 unified lookup tables for simple types
--   - 8 complex tables for types with unique relationships
--
-- Run this AFTER the core schema tables are created
-- ============================================================================

-- ============================================================================
-- PART 1: UNIFIED LOOKUP TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1.1 Domain Registry
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref.lookup_domains (
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

CREATE INDEX IF NOT EXISTS idx_lookup_domains_parent
    ON ref.lookup_domains(parent_domain_code)
    WHERE parent_domain_code IS NOT NULL;

COMMENT ON TABLE ref.lookup_domains IS 'Registry of all lookup domains with schema bindings';

-- ----------------------------------------------------------------------------
-- 1.2 Lookup Values
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref.lookup_values (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Domain and value identification
    domain_code text NOT NULL,
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
    CONSTRAINT fk_lookup_values_domain
        FOREIGN KEY (domain_code) REFERENCES ref.lookup_domains(domain_code),
    CONSTRAINT uq_lookup_domain_value
        UNIQUE (domain_code, value_code),
    CONSTRAINT chk_parent_consistency CHECK (
        (parent_id IS NULL AND parent_domain_code IS NULL AND parent_value_code IS NULL) OR
        (parent_id IS NOT NULL AND parent_domain_code IS NOT NULL AND parent_value_code IS NOT NULL)
    )
);

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_lookup_values_domain
    ON ref.lookup_values(domain_code);
CREATE INDEX IF NOT EXISTS idx_lookup_values_parent
    ON ref.lookup_values(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_lookup_values_active
    ON ref.lookup_values(domain_code, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_lookup_values_default
    ON ref.lookup_values(domain_code) WHERE is_default = true;
CREATE INDEX IF NOT EXISTS idx_lookup_values_attributes
    ON ref.lookup_values USING gin(attributes);

COMMENT ON TABLE ref.lookup_values IS 'All simple lookup values across all domains';

-- ============================================================================
-- PART 2: VALIDATION FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 Validate lookup reference
-- ----------------------------------------------------------------------------
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

COMMENT ON FUNCTION ref.is_valid_lookup IS 'Validates that a code exists in lookup_values for the given domain';

-- ----------------------------------------------------------------------------
-- 2.2 Get lookup value name
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ref.get_lookup_name(p_domain text, p_code text)
RETURNS text AS $$
BEGIN
    RETURN (
        SELECT value_name FROM ref.lookup_values
        WHERE domain_code = p_domain AND value_code = p_code
    );
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION ref.get_lookup_name IS 'Returns display name for a lookup code';

-- ----------------------------------------------------------------------------
-- 2.3 Get lookup attribute
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ref.get_lookup_attr(p_domain text, p_code text, p_attr text)
RETURNS text AS $$
BEGIN
    RETURN (
        SELECT attributes->>p_attr FROM ref.lookup_values
        WHERE domain_code = p_domain AND value_code = p_code
    );
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION ref.get_lookup_attr IS 'Returns a specific attribute value from lookup_values';

-- ----------------------------------------------------------------------------
-- 2.4 Get all values for domain
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ref.get_domain_values(p_domain text, p_active_only boolean DEFAULT true)
RETURNS TABLE(value_code text, value_name text, attributes jsonb, sort_order integer) AS $$
BEGIN
    RETURN QUERY
    SELECT lv.value_code, lv.value_name, lv.attributes, lv.sort_order
    FROM ref.lookup_values lv
    WHERE lv.domain_code = p_domain
    AND (NOT p_active_only OR lv.is_active = true)
    ORDER BY lv.sort_order, lv.value_name;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION ref.get_domain_values IS 'Returns all values for a domain';

-- ============================================================================
-- PART 3: COMPLEX REFERENCE TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 3.1 Fee Types & Rates (complex calculation logic)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref.fee_types (
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

CREATE TABLE IF NOT EXISTS ref.fee_rates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fee_type_id uuid NOT NULL REFERENCES ref.fee_types(id) ON DELETE CASCADE,
    scope_type text NOT NULL,  -- global, resort, property
    scope_id uuid,             -- resort_id or property_id (NULL for global)
    rate numeric(10,2) NOT NULL,
    rate_type text NOT NULL,   -- flat, per_night, per_guest, percentage
    effective_date date NOT NULL,
    end_date date,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),

    CONSTRAINT uq_fee_rate_scope_date UNIQUE (fee_type_id, scope_type, COALESCE(scope_id, '00000000-0000-0000-0000-000000000000'::uuid), effective_date)
);

CREATE INDEX IF NOT EXISTS idx_fee_rates_effective
    ON ref.fee_rates(fee_type_id, effective_date DESC);
CREATE INDEX IF NOT EXISTS idx_fee_rates_scope
    ON ref.fee_rates(scope_type, scope_id) WHERE scope_id IS NOT NULL;

-- ----------------------------------------------------------------------------
-- 3.2 Journey Stages (self-referential)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref.journey_stages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    stage_code text NOT NULL UNIQUE,
    stage_name text NOT NULL,
    stage_description text,
    stage_order integer NOT NULL,
    typical_duration_hours integer,
    is_terminal boolean DEFAULT false,
    next_stage_id uuid REFERENCES ref.journey_stages(id),
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_journey_stages_order
    ON ref.journey_stages(stage_order);

-- ----------------------------------------------------------------------------
-- 3.3 Touchpoint Types (FK to templates)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref.touchpoint_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    touchpoint_code text NOT NULL UNIQUE,
    touchpoint_name text NOT NULL,
    description text,
    channel text,           -- sms, email, phone, system
    direction text,         -- inbound, outbound
    is_automated boolean DEFAULT false,
    template_id uuid,       -- FK to comms.templates (added after comms schema exists)
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 3.4 Stage Required Touchpoints (junction with timing)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref.stage_required_touchpoints (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    stage_id uuid NOT NULL REFERENCES ref.journey_stages(id) ON DELETE CASCADE,
    touchpoint_type_id uuid NOT NULL REFERENCES ref.touchpoint_types(id) ON DELETE CASCADE,
    is_required boolean DEFAULT true,
    timing_rule text,
    timing_offset_hours integer,
    sort_order integer DEFAULT 0,

    CONSTRAINT uq_stage_touchpoint UNIQUE (stage_id, touchpoint_type_id)
);

-- ----------------------------------------------------------------------------
-- 3.5 Concierge Interest Categories & Types
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref.concierge_interest_categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code text NOT NULL UNIQUE,
    category_name text NOT NULL,
    icon text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ref.concierge_interest_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    interest_code text NOT NULL UNIQUE,
    interest_name text NOT NULL,
    category_id uuid NOT NULL REFERENCES ref.concierge_interest_categories(id),
    description text,
    icon text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- 3.6 Concierge Preference Levels
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref.concierge_preference_levels (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    preference_type text NOT NULL,  -- activity, budget, schedule_density, driving_tolerance
    level_code text NOT NULL,
    level_name text NOT NULL,
    level_order integer NOT NULL,   -- 1=lowest, 5=highest
    description text,

    CONSTRAINT uq_preference_level UNIQUE (preference_type, level_code)
);

CREATE INDEX IF NOT EXISTS idx_preference_levels_type
    ON ref.concierge_preference_levels(preference_type, level_order);

-- ============================================================================
-- PART 4: SEED DATA — DOMAINS
-- ============================================================================

INSERT INTO ref.lookup_domains (domain_code, domain_name, description, bound_schema, bound_table, bound_column, attribute_schema, allow_hierarchy, parent_domain_code) VALUES

-- Ticket system domains
('TICKET_TYPE', 'Ticket Types', 'Types of service tickets', 'service', 'tickets', 'ticket_type_code',
 '{"type":"object","properties":{"default_sla_hours":{"type":"integer"},"requires_property":{"type":"boolean"},"requires_reservation":{"type":"boolean"}}}',
 false, NULL),

('TICKET_CATEGORY', 'Ticket Categories', 'Categories within ticket types', 'service', 'tickets', 'category_code',
 '{"type":"object","properties":{"default_priority":{"type":"string"},"requires_vendor":{"type":"boolean"},"triggers_inventory_check":{"type":"boolean"}}}',
 true, 'TICKET_TYPE'),

('TICKET_PRIORITY', 'Ticket Priorities', 'Priority levels for tickets', 'service', 'tickets', 'priority',
 '{"type":"object","properties":{"sla_hours":{"type":"integer"}}}',
 false, NULL),

('TICKET_STATUS', 'Ticket Statuses', 'Status values for tickets', 'service', 'tickets', 'status',
 '{"type":"object","properties":{"is_terminal":{"type":"boolean"},"allows_edit":{"type":"boolean"}}}',
 false, NULL),

('ACTIVITY_TYPE', 'Activity Types', 'Types of time entry activities', 'team', 'time_entries', 'activity_type_code',
 '{"type":"object","properties":{"default_duration_minutes":{"type":"integer"},"is_billable":{"type":"boolean"},"billable_to_default":{"type":"string"},"links_to_table":{"type":"string"}}}',
 false, NULL),

('LABEL', 'Labels/Tags', 'Labels for tickets and other entities', 'service', 'ticket_labels', 'label_code',
 '{"type":"object","properties":{"label_group":{"type":"string"},"label_color":{"type":"string"}}}',
 false, NULL),

-- Damage claim domains
('DAMAGE_CATEGORY', 'Damage Categories', 'Categories of property damage', 'service', 'damage_claims', 'damage_category_code',
 '{"type":"object","properties":{"typical_cost_low":{"type":"number"},"typical_cost_high":{"type":"number"}}}',
 false, NULL),

('CLAIM_SUBMISSION_TYPE', 'Claim Submission Types', 'Types of damage claim submissions', 'service', 'damage_claim_submissions', 'submission_type_code',
 '{"type":"object","properties":{"typical_deadline_days":{"type":"integer"},"typical_response_days":{"type":"integer"}}}',
 false, NULL),

('DENIAL_CATEGORY', 'Denial Categories', 'Reasons for claim denials', 'service', 'damage_claim_denials', 'denial_code',
 '{"type":"object","properties":{"is_preventable_default":{"type":"boolean"},"prevention_guidance":{"type":"string"}}}',
 false, NULL),

-- Property domains
('ROOM_TYPE', 'Room Types', 'Types of rooms in properties', 'property', 'rooms', 'room_type_code', NULL, false, NULL),

('BED_TYPE', 'Bed Types', 'Types of beds', 'property', 'beds', 'bed_type_code',
 '{"type":"object","properties":{"sleeps":{"type":"integer"}}}',
 false, NULL),

('AMENITY_TYPE', 'Amenity Types', 'Property amenities', 'property', 'property_amenities', 'amenity_type_code',
 '{"type":"object","properties":{"category":{"type":"string"},"icon":{"type":"string"}}}',
 false, NULL),

('APPLIANCE_TYPE', 'Appliance Types', 'Types of appliances', 'property', 'appliances', 'appliance_type_code',
 '{"type":"object","properties":{"category":{"type":"string"},"typical_lifespan_years":{"type":"integer"},"maintenance_interval_months":{"type":"integer"}}}',
 false, NULL),

('FIXTURE_TYPE', 'Fixture Types', 'Types of plumbing fixtures', 'property', 'fixtures', 'fixture_type_code',
 '{"type":"object","properties":{"category":{"type":"string"}}}',
 false, NULL),

('SURFACE_TYPE', 'Surface Types', 'Types of surfaces (floors, counters)', 'property', 'surfaces', 'surface_type_code', NULL, false, NULL),

('CLEAN_TYPE', 'Clean Types', 'Types of property cleans', 'property', 'cleans', 'clean_type',
 '{"type":"object","properties":{"default_duration_minutes":{"type":"integer"}}}',
 false, NULL),

('INSPECTION_CATEGORY', 'Inspection Categories', 'Categories for inspection questions', 'property', 'inspection_questions', 'category', NULL, false, NULL),

('ISSUE_SEVERITY', 'Issue Severity', 'Severity levels for issues', 'property', 'inspection_issues', 'severity',
 '{"type":"object","properties":{"response_hours":{"type":"integer"}}}',
 false, NULL),

-- Inventory domains
('INVENTORY_ITEM_TYPE', 'Inventory Item Types', 'Types of inventory items', 'inventory', 'inventory_items', 'item_type_code',
 '{"type":"object","properties":{"category":{"type":"string"},"is_trackable":{"type":"boolean"},"default_par":{"type":"integer"}}}',
 false, NULL),

-- Geographic domains
('COUNTRY', 'Countries', 'Country codes', 'directory', 'contacts', 'country_code',
 '{"type":"object","properties":{"currency_code":{"type":"string"},"calling_code":{"type":"string"}}}',
 false, NULL),

('STATE', 'States/Provinces', 'State and province codes', 'directory', 'contacts', 'state',
 '{"type":"object","properties":{"timezone":{"type":"string"}}}',
 true, 'COUNTRY'),

('CURRENCY', 'Currencies', 'Currency codes', 'finance', 'transactions', 'currency_code',
 '{"type":"object","properties":{"symbol":{"type":"string"},"decimal_places":{"type":"integer"}}}',
 false, NULL),

('LANGUAGE', 'Languages', 'Language codes', 'directory', 'contacts', 'preferred_language', NULL, false, NULL),

('TIMEZONE', 'Timezones', 'Timezone identifiers', NULL, NULL, NULL,
 '{"type":"object","properties":{"utc_offset":{"type":"string"}}}',
 false, NULL),

-- Platform and channel domains
('PLATFORM_TYPE', 'Booking Platforms', 'OTA and booking platforms', 'reservations', 'reservations', 'booking_source',
 '{"type":"object","properties":{"is_ota":{"type":"boolean"},"commission_rate":{"type":"number"}}}',
 false, NULL),

('CHANNEL_TYPE', 'Communication Channels', 'Types of communication channels', 'comms', 'channels', 'channel_code', NULL, false, NULL),

-- Document and content domains
('DOCUMENT_TYPE', 'Document Types', 'Types of documents', 'knowledge', 'documents', 'document_type', NULL, false, NULL),

-- Contact domains
('RELATIONSHIP_TYPE', 'Relationship Types', 'Types of contact relationships', 'directory', 'contact_relationships', 'relationship_type',
 '{"type":"object","properties":{"is_bidirectional":{"type":"boolean"}}}',
 false, NULL),

('CONTACT_TYPE', 'Contact Types', 'Types of contacts', 'directory', 'contacts', 'contact_type', NULL, false, NULL),

-- Vendor domains
('VENDOR_CATEGORY', 'Vendor Categories', 'Categories of vendors', 'directory', 'vendors', 'vendor_type', NULL, false, NULL),

-- Finance domains
('EXPENSE_CATEGORY', 'Expense Categories', 'Categories of expenses', 'finance', 'expenses', 'category_code',
 '{"type":"object","properties":{"is_billable_default":{"type":"boolean"}}}',
 false, NULL),

('REVENUE_CATEGORY', 'Revenue Categories', 'Categories of revenue', 'finance', 'transactions', 'category_code', NULL, false, NULL),

('TAX_TYPE', 'Tax Types', 'Types of taxes', NULL, NULL, NULL,
 '{"type":"object","properties":{"rate":{"type":"number"},"jurisdiction":{"type":"string"}}}',
 false, NULL)

ON CONFLICT (domain_code) DO NOTHING;

-- ============================================================================
-- PART 5: SEED DATA — LOOKUP VALUES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Ticket Types
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, description, attributes, sort_order, is_system) VALUES
('TICKET_TYPE', 'PC', 'Property Care', 'Maintenance and repair tickets', '{"default_sla_hours": 24, "requires_property": true, "requires_reservation": false}', 1, true),
('TICKET_TYPE', 'RSV', 'Reservation', 'Guest service tickets', '{"default_sla_hours": 4, "requires_property": false, "requires_reservation": true}', 2, true),
('TICKET_TYPE', 'ADM', 'Administrative', 'Internal admin tickets', '{"default_sla_hours": 48, "requires_property": false, "requires_reservation": false}', 3, true),
('TICKET_TYPE', 'ACCT', 'Accounting', 'Finance and accounting tickets', '{"default_sla_hours": 72, "requires_property": false, "requires_reservation": false}', 4, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Ticket Priorities
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, attributes, sort_order, is_system) VALUES
('TICKET_PRIORITY', 'CRITICAL', 'Critical', '{"sla_hours": 1}', 1, true),
('TICKET_PRIORITY', 'HIGH', 'High', '{"sla_hours": 4}', 2, true),
('TICKET_PRIORITY', 'MEDIUM', 'Medium', '{"sla_hours": 24}', 3, true),
('TICKET_PRIORITY', 'LOW', 'Low', '{"sla_hours": 72}', 4, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Ticket Statuses
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, attributes, sort_order, is_system) VALUES
('TICKET_STATUS', 'OPEN', 'Open', '{"is_terminal": false, "allows_edit": true}', 1, true),
('TICKET_STATUS', 'IN_PROGRESS', 'In Progress', '{"is_terminal": false, "allows_edit": true}', 2, true),
('TICKET_STATUS', 'ON_HOLD', 'On Hold', '{"is_terminal": false, "allows_edit": true}', 3, true),
('TICKET_STATUS', 'RESOLVED', 'Resolved', '{"is_terminal": true, "allows_edit": false}', 4, true),
('TICKET_STATUS', 'CANCELLED', 'Cancelled', '{"is_terminal": true, "allows_edit": false}', 5, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Room Types
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, sort_order, is_system) VALUES
('ROOM_TYPE', 'MASTER', 'Master Bedroom', 1, true),
('ROOM_TYPE', 'BEDROOM', 'Bedroom', 2, true),
('ROOM_TYPE', 'BATHROOM', 'Bathroom', 3, true),
('ROOM_TYPE', 'HALF_BATH', 'Half Bath', 4, true),
('ROOM_TYPE', 'KITCHEN', 'Kitchen', 5, true),
('ROOM_TYPE', 'LIVING', 'Living Room', 6, true),
('ROOM_TYPE', 'DINING', 'Dining Room', 7, true),
('ROOM_TYPE', 'LANAI', 'Lanai/Balcony', 8, true),
('ROOM_TYPE', 'GARAGE', 'Garage', 9, true),
('ROOM_TYPE', 'LAUNDRY', 'Laundry Room', 10, true),
('ROOM_TYPE', 'OFFICE', 'Office/Den', 11, true),
('ROOM_TYPE', 'ENTRY', 'Entry/Foyer', 12, true),
('ROOM_TYPE', 'HALLWAY', 'Hallway', 13, true),
('ROOM_TYPE', 'STORAGE', 'Storage', 14, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Bed Types
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, attributes, sort_order, is_system) VALUES
('BED_TYPE', 'KING', 'King', '{"sleeps": 2}', 1, true),
('BED_TYPE', 'CAL_KING', 'California King', '{"sleeps": 2}', 2, true),
('BED_TYPE', 'QUEEN', 'Queen', '{"sleeps": 2}', 3, true),
('BED_TYPE', 'FULL', 'Full/Double', '{"sleeps": 2}', 4, true),
('BED_TYPE', 'TWIN', 'Twin', '{"sleeps": 1}', 5, true),
('BED_TYPE', 'TWIN_XL', 'Twin XL', '{"sleeps": 1}', 6, true),
('BED_TYPE', 'BUNK', 'Bunk Bed', '{"sleeps": 2}', 7, true),
('BED_TYPE', 'SOFA_BED', 'Sofa Bed', '{"sleeps": 2}', 8, true),
('BED_TYPE', 'DAYBED', 'Daybed', '{"sleeps": 1}', 9, true),
('BED_TYPE', 'MURPHY', 'Murphy Bed', '{"sleeps": 2}', 10, true),
('BED_TYPE', 'CRIB', 'Crib', '{"sleeps": 1}', 11, true),
('BED_TYPE', 'TODDLER', 'Toddler Bed', '{"sleeps": 1}', 12, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Appliance Types
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, attributes, sort_order, is_system) VALUES
('APPLIANCE_TYPE', 'FRIDGE', 'Refrigerator', '{"category": "kitchen", "typical_lifespan_years": 15, "maintenance_interval_months": 12}', 1, true),
('APPLIANCE_TYPE', 'OVEN', 'Oven/Range', '{"category": "kitchen", "typical_lifespan_years": 15, "maintenance_interval_months": 12}', 2, true),
('APPLIANCE_TYPE', 'MICROWAVE', 'Microwave', '{"category": "kitchen", "typical_lifespan_years": 10, "maintenance_interval_months": null}', 3, true),
('APPLIANCE_TYPE', 'DISHWASHER', 'Dishwasher', '{"category": "kitchen", "typical_lifespan_years": 10, "maintenance_interval_months": 12}', 4, true),
('APPLIANCE_TYPE', 'WASHER', 'Washing Machine', '{"category": "laundry", "typical_lifespan_years": 12, "maintenance_interval_months": 12}', 5, true),
('APPLIANCE_TYPE', 'DRYER', 'Dryer', '{"category": "laundry", "typical_lifespan_years": 12, "maintenance_interval_months": 12}', 6, true),
('APPLIANCE_TYPE', 'WATER_HEATER', 'Water Heater', '{"category": "plumbing", "typical_lifespan_years": 12, "maintenance_interval_months": 12}', 7, true),
('APPLIANCE_TYPE', 'AC_SPLIT', 'Split A/C Unit', '{"category": "climate", "typical_lifespan_years": 15, "maintenance_interval_months": 6}', 8, true),
('APPLIANCE_TYPE', 'AC_CENTRAL', 'Central A/C', '{"category": "climate", "typical_lifespan_years": 20, "maintenance_interval_months": 6}', 9, true),
('APPLIANCE_TYPE', 'AC_WINDOW', 'Window A/C Unit', '{"category": "climate", "typical_lifespan_years": 10, "maintenance_interval_months": 6}', 10, true),
('APPLIANCE_TYPE', 'CEILING_FAN', 'Ceiling Fan', '{"category": "climate", "typical_lifespan_years": 15, "maintenance_interval_months": null}', 11, true),
('APPLIANCE_TYPE', 'DISPOSAL', 'Garbage Disposal', '{"category": "kitchen", "typical_lifespan_years": 10, "maintenance_interval_months": null}', 12, true),
('APPLIANCE_TYPE', 'TV', 'Television', '{"category": "electronics", "typical_lifespan_years": 8, "maintenance_interval_months": null}', 13, true),
('APPLIANCE_TYPE', 'COFFEE_MAKER', 'Coffee Maker', '{"category": "kitchen", "typical_lifespan_years": 5, "maintenance_interval_months": null}', 14, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Clean Types
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, description, attributes, sort_order, is_system) VALUES
('CLEAN_TYPE', 'TURNOVER', 'Turnover Clean', 'Standard checkout/check-in clean', '{"default_duration_minutes": 180}', 1, true),
('CLEAN_TYPE', 'DEEP', 'Deep Clean', 'Thorough deep cleaning', '{"default_duration_minutes": 360}', 2, true),
('CLEAN_TYPE', 'MID_STAY', 'Mid-Stay Clean', 'Light clean during guest stay', '{"default_duration_minutes": 90}', 3, true),
('CLEAN_TYPE', 'PRE_ARRIVAL', 'Pre-Arrival Check', 'Final check before guest arrival', '{"default_duration_minutes": 30}', 4, true),
('CLEAN_TYPE', 'REFRESH', 'Refresh', 'Quick refresh between stays', '{"default_duration_minutes": 60}', 5, true),
('CLEAN_TYPE', 'POST_MAINTENANCE', 'Post-Maintenance', 'Clean after maintenance work', '{"default_duration_minutes": 120}', 6, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Issue Severity
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, attributes, sort_order, is_system) VALUES
('ISSUE_SEVERITY', 'CRITICAL', 'Critical', '{"response_hours": 1}', 1, true),
('ISSUE_SEVERITY', 'MAJOR', 'Major', '{"response_hours": 4}', 2, true),
('ISSUE_SEVERITY', 'MODERATE', 'Moderate', '{"response_hours": 24}', 3, true),
('ISSUE_SEVERITY', 'MINOR', 'Minor', '{"response_hours": 72}', 4, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Platform Types (Booking Sources)
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, attributes, sort_order, is_system) VALUES
('PLATFORM_TYPE', 'DIRECT', 'Direct Booking', '{"is_ota": false, "commission_rate": 0}', 1, true),
('PLATFORM_TYPE', 'AIRBNB', 'Airbnb', '{"is_ota": true, "commission_rate": 3}', 2, true),
('PLATFORM_TYPE', 'VRBO', 'VRBO/HomeAway', '{"is_ota": true, "commission_rate": 5}', 3, true),
('PLATFORM_TYPE', 'BOOKING', 'Booking.com', '{"is_ota": true, "commission_rate": 15}', 4, true),
('PLATFORM_TYPE', 'EXPEDIA', 'Expedia', '{"is_ota": true, "commission_rate": 15}', 5, true),
('PLATFORM_TYPE', 'GOOGLE', 'Google Travel', '{"is_ota": true, "commission_rate": 10}', 6, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Contact Types
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, sort_order, is_system) VALUES
('CONTACT_TYPE', 'PERSON', 'Person', 1, true),
('CONTACT_TYPE', 'COMPANY', 'Company', 2, true),
('CONTACT_TYPE', 'TRUST', 'Trust', 3, true),
('CONTACT_TYPE', 'ESTATE', 'Estate', 4, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Countries (sample)
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, attributes, sort_order, is_system) VALUES
('COUNTRY', 'US', 'United States', '{"currency_code": "USD", "calling_code": "+1"}', 1, true),
('COUNTRY', 'CA', 'Canada', '{"currency_code": "CAD", "calling_code": "+1"}', 2, true),
('COUNTRY', 'MX', 'Mexico', '{"currency_code": "MXN", "calling_code": "+52"}', 3, true),
('COUNTRY', 'GB', 'United Kingdom', '{"currency_code": "GBP", "calling_code": "+44"}', 4, true),
('COUNTRY', 'AU', 'Australia', '{"currency_code": "AUD", "calling_code": "+61"}', 5, true),
('COUNTRY', 'JP', 'Japan', '{"currency_code": "JPY", "calling_code": "+81"}', 6, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Languages
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, sort_order, is_system) VALUES
('LANGUAGE', 'en', 'English', 1, true),
('LANGUAGE', 'es', 'Spanish', 2, true),
('LANGUAGE', 'ja', 'Japanese', 3, true),
('LANGUAGE', 'zh', 'Chinese', 4, true),
('LANGUAGE', 'ko', 'Korean', 5, true),
('LANGUAGE', 'fr', 'French', 6, true),
('LANGUAGE', 'de', 'German', 7, true),
('LANGUAGE', 'pt', 'Portuguese', 8, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Currencies
-- ----------------------------------------------------------------------------
INSERT INTO ref.lookup_values (domain_code, value_code, value_name, attributes, sort_order, is_system) VALUES
('CURRENCY', 'USD', 'US Dollar', '{"symbol": "$", "decimal_places": 2}', 1, true),
('CURRENCY', 'CAD', 'Canadian Dollar', '{"symbol": "C$", "decimal_places": 2}', 2, true),
('CURRENCY', 'EUR', 'Euro', '{"symbol": "€", "decimal_places": 2}', 3, true),
('CURRENCY', 'GBP', 'British Pound', '{"symbol": "£", "decimal_places": 2}', 4, true),
('CURRENCY', 'AUD', 'Australian Dollar', '{"symbol": "A$", "decimal_places": 2}', 5, true),
('CURRENCY', 'JPY', 'Japanese Yen', '{"symbol": "¥", "decimal_places": 0}', 6, true)
ON CONFLICT (domain_code, value_code) DO NOTHING;

-- ============================================================================
-- PART 6: SEED DATA — COMPLEX TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Fee Types
-- ----------------------------------------------------------------------------
INSERT INTO ref.fee_types (fee_type_code, fee_type_name, description, is_taxable, is_refundable, default_amount, calculation_method, sort_order) VALUES
('CLEANING', 'Cleaning Fee', 'Standard cleaning fee', true, true, 150.00, 'flat', 1),
('RESORT', 'Resort Fee', 'Resort amenity fee', true, false, 25.00, 'per_night', 2),
('PET', 'Pet Fee', 'Fee for pets', true, true, 100.00, 'flat', 3),
('LATE_CHECKOUT', 'Late Checkout', 'Late checkout fee', true, false, 50.00, 'flat', 4),
('EARLY_CHECKIN', 'Early Check-in', 'Early check-in fee', true, false, 50.00, 'flat', 5),
('DAMAGE_WAIVER', 'Damage Waiver', 'Optional damage waiver', false, false, 49.00, 'flat', 6),
('EXTRA_GUEST', 'Extra Guest', 'Fee per extra guest over base', true, false, 25.00, 'per_night', 7),
('PARKING', 'Parking Fee', 'Parking fee', true, false, 15.00, 'per_night', 8)
ON CONFLICT (fee_type_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Journey Stages
-- ----------------------------------------------------------------------------
INSERT INTO ref.journey_stages (stage_code, stage_name, stage_description, stage_order, typical_duration_hours, is_terminal) VALUES
('BOOKED', 'Booked', 'Reservation confirmed', 1, NULL, false),
('PRE_ARRIVAL', 'Pre-Arrival', 'Guest preparing for arrival', 2, 168, false),
('CHECK_IN_DAY', 'Check-In Day', 'Day of arrival', 3, 24, false),
('IN_STAY', 'In Stay', 'Guest currently at property', 4, NULL, false),
('CHECK_OUT_DAY', 'Check-Out Day', 'Day of departure', 5, 24, false),
('POST_STAY', 'Post-Stay', 'After guest departure', 6, 168, false),
('COMPLETED', 'Completed', 'Journey complete', 7, NULL, true),
('CANCELLED', 'Cancelled', 'Reservation cancelled', 8, NULL, true)
ON CONFLICT (stage_code) DO NOTHING;

-- Update next_stage_id references
UPDATE ref.journey_stages SET next_stage_id = (SELECT id FROM ref.journey_stages WHERE stage_code = 'PRE_ARRIVAL') WHERE stage_code = 'BOOKED';
UPDATE ref.journey_stages SET next_stage_id = (SELECT id FROM ref.journey_stages WHERE stage_code = 'CHECK_IN_DAY') WHERE stage_code = 'PRE_ARRIVAL';
UPDATE ref.journey_stages SET next_stage_id = (SELECT id FROM ref.journey_stages WHERE stage_code = 'IN_STAY') WHERE stage_code = 'CHECK_IN_DAY';
UPDATE ref.journey_stages SET next_stage_id = (SELECT id FROM ref.journey_stages WHERE stage_code = 'CHECK_OUT_DAY') WHERE stage_code = 'IN_STAY';
UPDATE ref.journey_stages SET next_stage_id = (SELECT id FROM ref.journey_stages WHERE stage_code = 'POST_STAY') WHERE stage_code = 'CHECK_OUT_DAY';
UPDATE ref.journey_stages SET next_stage_id = (SELECT id FROM ref.journey_stages WHERE stage_code = 'COMPLETED') WHERE stage_code = 'POST_STAY';

-- ----------------------------------------------------------------------------
-- Touchpoint Types
-- ----------------------------------------------------------------------------
INSERT INTO ref.touchpoint_types (touchpoint_code, touchpoint_name, description, channel, direction, is_automated, sort_order) VALUES
('BOOKING_CONFIRM', 'Booking Confirmation', 'Confirmation email after booking', 'email', 'outbound', true, 1),
('PRE_ARRIVAL_7D', 'Pre-Arrival (7 days)', 'Reminder 7 days before', 'email', 'outbound', true, 2),
('PRE_ARRIVAL_3D', 'Pre-Arrival (3 days)', 'Reminder 3 days before', 'email', 'outbound', true, 3),
('PRE_ARRIVAL_1D', 'Pre-Arrival (1 day)', 'Reminder 1 day before', 'sms', 'outbound', true, 4),
('CHECK_IN_INSTRUCTIONS', 'Check-In Instructions', 'Check-in details', 'sms', 'outbound', true, 5),
('WELCOME', 'Welcome Message', 'Welcome after check-in', 'sms', 'outbound', true, 6),
('MID_STAY_CHECK', 'Mid-Stay Check', 'Check on guest during stay', 'sms', 'outbound', true, 7),
('CHECK_OUT_REMINDER', 'Check-Out Reminder', 'Check-out reminder', 'sms', 'outbound', true, 8),
('THANK_YOU', 'Thank You', 'Post-stay thank you', 'email', 'outbound', true, 9),
('REVIEW_REQUEST', 'Review Request', 'Request for review', 'email', 'outbound', true, 10),
('GUEST_INQUIRY', 'Guest Inquiry', 'Guest question (inbound)', 'sms', 'inbound', false, 11),
('GUEST_COMPLAINT', 'Guest Complaint', 'Guest issue (inbound)', 'phone', 'inbound', false, 12)
ON CONFLICT (touchpoint_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Concierge Interest Categories
-- ----------------------------------------------------------------------------
INSERT INTO ref.concierge_interest_categories (category_code, category_name, icon, sort_order) VALUES
('OUTDOOR', 'Outdoor Activities', 'hiking', 1),
('WATER', 'Water Activities', 'waves', 2),
('FOOD', 'Food & Dining', 'utensils', 3),
('CULTURE', 'Culture & History', 'landmark', 4),
('WELLNESS', 'Wellness & Relaxation', 'spa', 5),
('ADVENTURE', 'Adventure & Tours', 'compass', 6),
('NIGHTLIFE', 'Nightlife & Entertainment', 'music', 7),
('FAMILY', 'Family Activities', 'users', 8)
ON CONFLICT (category_code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Concierge Preference Levels
-- ----------------------------------------------------------------------------
INSERT INTO ref.concierge_preference_levels (preference_type, level_code, level_name, level_order, description) VALUES
-- Activity levels
('ACTIVITY', 'RELAXED', 'Relaxed', 1, 'Prefers low-key, restful activities'),
('ACTIVITY', 'LIGHT', 'Light', 2, 'Enjoys light activities with breaks'),
('ACTIVITY', 'MODERATE', 'Moderate', 3, 'Balanced mix of activity and rest'),
('ACTIVITY', 'ACTIVE', 'Active', 4, 'Enjoys being active most of the day'),
('ACTIVITY', 'VERY_ACTIVE', 'Very Active', 5, 'Non-stop adventure seeker'),

-- Budget levels
('BUDGET', 'BUDGET', 'Budget-Friendly', 1, 'Focuses on free/low-cost options'),
('BUDGET', 'MODERATE', 'Moderate', 2, 'Mix of free and paid activities'),
('BUDGET', 'COMFORTABLE', 'Comfortable', 3, 'Willing to pay for good experiences'),
('BUDGET', 'PREMIUM', 'Premium', 4, 'Prefers higher-end experiences'),
('BUDGET', 'LUXURY', 'Luxury', 5, 'Seeks exclusive/luxury experiences'),

-- Schedule density
('SCHEDULE_DENSITY', 'OPEN', 'Very Open', 1, 'Minimal planned activities'),
('SCHEDULE_DENSITY', 'FLEXIBLE', 'Flexible', 2, 'A few must-dos, otherwise open'),
('SCHEDULE_DENSITY', 'BALANCED', 'Balanced', 3, 'Good mix of planned and free time'),
('SCHEDULE_DENSITY', 'STRUCTURED', 'Structured', 4, 'Mostly planned with some flexibility'),
('SCHEDULE_DENSITY', 'PACKED', 'Packed', 5, 'Maximize every moment'),

-- Driving tolerance
('DRIVING_TOLERANCE', 'MINIMAL', 'Minimal', 1, 'Prefers walking distance only'),
('DRIVING_TOLERANCE', 'SHORT', 'Short Drives', 2, 'OK with drives under 15 minutes'),
('DRIVING_TOLERANCE', 'MODERATE', 'Moderate', 3, 'OK with drives up to 30 minutes'),
('DRIVING_TOLERANCE', 'WILLING', 'Willing', 4, 'Will drive up to an hour'),
('DRIVING_TOLERANCE', 'ANYWHERE', 'Anywhere', 5, 'Will drive anywhere on island')
ON CONFLICT (preference_type, level_code) DO NOTHING;

-- ============================================================================
-- PART 7: COMPATIBILITY VIEWS
-- ============================================================================

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

-- Ticket priorities view
CREATE OR REPLACE VIEW ref.v_ticket_priorities AS
SELECT
    id,
    value_code AS priority_code,
    value_name AS priority_name,
    (attributes->>'sla_hours')::integer AS sla_hours,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'TICKET_PRIORITY';

-- Ticket statuses view
CREATE OR REPLACE VIEW ref.v_ticket_statuses AS
SELECT
    id,
    value_code AS status_code,
    value_name AS status_name,
    (attributes->>'is_terminal')::boolean AS is_terminal,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'TICKET_STATUS';

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

-- Appliance types view
CREATE OR REPLACE VIEW ref.v_appliance_types AS
SELECT
    id,
    value_code AS appliance_code,
    value_name AS appliance_name,
    (attributes->>'category') AS category,
    (attributes->>'typical_lifespan_years')::integer AS typical_lifespan_years,
    (attributes->>'maintenance_interval_months')::integer AS maintenance_interval_months,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'APPLIANCE_TYPE';

-- Clean types view
CREATE OR REPLACE VIEW ref.v_clean_types AS
SELECT
    id,
    value_code AS clean_type_code,
    value_name AS clean_type_name,
    description,
    (attributes->>'default_duration_minutes')::integer AS default_duration_minutes,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'CLEAN_TYPE';

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

-- Platforms view
CREATE OR REPLACE VIEW ref.v_platforms AS
SELECT
    id,
    value_code AS platform_code,
    value_name AS platform_name,
    (attributes->>'is_ota')::boolean AS is_ota,
    (attributes->>'commission_rate')::numeric AS commission_rate,
    sort_order,
    is_active
FROM ref.lookup_values
WHERE domain_code = 'PLATFORM_TYPE';

-- All lookups flat view (for admin UI)
CREATE OR REPLACE VIEW ref.v_all_lookups AS
SELECT
    lv.id,
    ld.domain_code,
    ld.domain_name,
    lv.value_code,
    lv.value_name,
    lv.description,
    lv.parent_domain_code,
    lv.parent_value_code,
    lv.attributes,
    lv.sort_order,
    lv.is_default,
    lv.is_active,
    lv.is_system,
    ld.bound_schema,
    ld.bound_table,
    ld.bound_column
FROM ref.lookup_values lv
JOIN ref.lookup_domains ld ON lv.domain_code = ld.domain_code
ORDER BY ld.domain_code, lv.sort_order, lv.value_name;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
