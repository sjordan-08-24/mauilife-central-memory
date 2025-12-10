-- ============================================================================
-- OPS Schema Migration 003: Join Tables
-- ============================================================================
-- Creates join tables for many-to-many relationships:
-- 1. homeowner_properties (homeowners <-> properties with ownership details)
-- 2. reservation_guests (reservations <-> guests with roles)
-- 3. resort_contacts (resorts <-> contacts with roles)
-- 4. property_vendors (properties <-> vendors/contacts with types)
-- ============================================================================

-- ============================================================================
-- HOMEOWNER_PROPERTIES
-- Links homeowners to properties with ownership details
-- Many-to-many: one homeowner can own multiple properties,
-- one property could have multiple owners/partners
-- ============================================================================
CREATE TABLE ops.homeowner_properties (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    hprx_id text NOT NULL UNIQUE,
    homeowner_id UUID NOT NULL REFERENCES ops.homeowners(id),
    property_id UUID NOT NULL REFERENCES ops.properties(id),

    -- Ownership details
    ownership_type text,                  -- How this owner holds this property
    ownership_percentage numeric(5,2),    -- Percentage ownership (e.g., 50.00 for 50%)
    relationship_type text,               -- 'primary_owner', 'co_owner', 'managing_partner', 'investor'
    is_managing_owner boolean DEFAULT false,  -- Who makes day-to-day decisions?

    -- Dates
    ownership_start_date date,
    management_start_date date,
    contract_renewal_date date,
    property_purchase_date date,

    -- Source tracking
    previous_management_company_id text,
    management_companies_count integer,
    property_management_notes text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),

    -- Ensure unique homeowner-property pairs
    UNIQUE(homeowner_id, property_id),

    -- Validate ownership type
    CONSTRAINT chk_ownership_type CHECK (
        ownership_type IS NULL OR ownership_type IN (
            'individual', 'sole_proprietorship', 'LLC', 'LLC_individual',
            'LLC_corporation', 'LLC_partnership', 'corporation',
            's_corporation', 'partnership', 'trust', 'estate', 'other'
        )
    ),

    -- Validate relationship type
    CONSTRAINT chk_relationship_type CHECK (
        relationship_type IS NULL OR relationship_type IN (
            'primary_owner', 'co_owner', 'managing_partner', 'investor', 'beneficiary', 'other'
        )
    ),

    -- Validate ownership percentage
    CONSTRAINT chk_ownership_percentage CHECK (
        ownership_percentage IS NULL OR (ownership_percentage >= 0 AND ownership_percentage <= 100)
    )
);

COMMENT ON TABLE ops.homeowner_properties IS 'Join table linking homeowners to properties with ownership details';
COMMENT ON COLUMN ops.homeowner_properties.hprx_id IS 'Business identifier for this relationship';
COMMENT ON COLUMN ops.homeowner_properties.ownership_type IS 'Type of ownership (individual, LLC, trust, etc.) - entity details in contact_entities';
COMMENT ON COLUMN ops.homeowner_properties.ownership_percentage IS 'Percentage ownership of property (0-100)';
COMMENT ON COLUMN ops.homeowner_properties.relationship_type IS 'Role in ownership: primary_owner, co_owner, managing_partner, investor';
COMMENT ON COLUMN ops.homeowner_properties.is_managing_owner IS 'True if this owner makes day-to-day property decisions';

-- ============================================================================
-- RESERVATION_GUESTS
-- Links guests to reservations with roles
-- Many-to-many: multiple guests per reservation, guest on multiple reservations
-- ============================================================================
CREATE TABLE ops.reservation_guests (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    reservation_id UUID NOT NULL REFERENCES ops.reservations(id),
    guest_id UUID NOT NULL REFERENCES ops.guests(id),

    -- Role
    guest_role text NOT NULL DEFAULT 'guest',  -- primary, secondary, guest
    is_primary boolean DEFAULT false,

    -- Guest-specific details for this reservation
    arrival_confirmed boolean,
    special_requests text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),

    -- Ensure unique guest per reservation
    UNIQUE(reservation_id, guest_id),

    -- Validate guest role
    CONSTRAINT chk_guest_role CHECK (
        guest_role IN ('primary', 'secondary', 'guest')
    )
);

COMMENT ON TABLE ops.reservation_guests IS 'Join table linking guests to reservations with roles (primary, secondary, guest)';
COMMENT ON COLUMN ops.reservation_guests.guest_role IS 'Role of guest: primary (booking contact), secondary, or guest';
COMMENT ON COLUMN ops.reservation_guests.is_primary IS 'True if this is the primary guest for the reservation';

-- Ensure only one primary guest per reservation
CREATE UNIQUE INDEX idx_reservation_primary_guest
    ON ops.reservation_guests(reservation_id)
    WHERE is_primary = true;

-- ============================================================================
-- RESORT_CONTACTS
-- Links resorts to contacts with roles
-- Many-to-many: resorts have different contacts for different functions
-- ============================================================================
CREATE TABLE ops.resort_contacts (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    resort_id UUID NOT NULL REFERENCES ops.resorts(id),
    contact_id UUID NOT NULL REFERENCES ops.contacts(id),

    -- Role and priority
    contact_role text NOT NULL,  -- housekeeping, association, engineering, security, general_manager, etc.
    is_primary boolean DEFAULT false,
    notes text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),

    -- Ensure unique contact per role per resort
    UNIQUE(resort_id, contact_id, contact_role)
);

COMMENT ON TABLE ops.resort_contacts IS 'Join table linking resorts to contacts with roles (housekeeping, security, etc.)';
COMMENT ON COLUMN ops.resort_contacts.contact_role IS 'Role: housekeeping, association, engineering, security, general_manager, etc.';

-- ============================================================================
-- PROPERTY_VENDORS
-- Links properties to preferred vendors (vendors are contacts)
-- Many-to-many: properties have different vendors for different services
-- ============================================================================
CREATE TABLE ops.property_vendors (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    property_id UUID NOT NULL REFERENCES ops.properties(id),
    vendor_id UUID REFERENCES ops.contacts(id),  -- vendors are stored as contacts

    -- Vendor details
    vendor_type text NOT NULL,  -- cleaning, maintenance, pest_control, hvac, plumbing, electrical, etc.
    is_preferred boolean DEFAULT false,
    priority integer DEFAULT 1,  -- 1 = first choice, 2 = backup, etc.
    notes text,

    -- Contract details (optional)
    contract_start_date date,
    contract_end_date date,
    rate_info text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),

    -- Ensure unique vendor per type per property
    UNIQUE(property_id, vendor_id, vendor_type)
);

COMMENT ON TABLE ops.property_vendors IS 'Join table linking properties to preferred vendors by service type';
COMMENT ON COLUMN ops.property_vendors.vendor_type IS 'Service type: cleaning, maintenance, pest_control, hvac, plumbing, electrical, etc.';
COMMENT ON COLUMN ops.property_vendors.priority IS 'Priority order: 1 = first choice, 2 = backup, etc.';
