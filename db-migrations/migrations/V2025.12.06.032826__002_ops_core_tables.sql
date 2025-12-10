-- ============================================================================
-- OPS Schema Migration 002: Core Tables
-- ============================================================================
-- Creates the core operational tables in dependency order:
-- 1. contacts (base entity for all people)
-- 2. guests (guest-specific data)
-- 3. homeowners (homeowner-specific data)
-- 4. resorts (resort/complex information)
-- 5. properties (property data, depends on resorts)
-- 6. reservations (reservation data, depends on properties)
-- ============================================================================

-- ============================================================================
-- CONTACTS
-- Base entity for all people (guests, homeowners, vendors, staff)
-- ============================================================================
CREATE TABLE ops.contacts (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    contact_type text NOT NULL,                    -- guest, homeowner, vendor, staff, etc.
    contact_id text NOT NULL UNIQUE,               -- CON-GST-010001, etc.
    status text,

    -- Name fields
    full_name text,
    first_name text,
    middle_name text,
    last_name text,
    preferred_name text,

    -- Contact methods
    preferred_contact_method text,
    email text,
    phone text,
    phone2 text,
    phone3 text,

    -- Demographics
    birth_date date,
    gender text,
    language_preference text,

    -- Physical address
    physical_address text,
    physical_address_line_2 text,
    physical_city text,
    physical_state text,
    physical_zip text,
    physical_country text,

    -- Mailing address
    mailing_address text,
    mailing_address_line_2 text,
    mailing_city text,
    mailing_state text,
    mailing_zip text,
    mailing_country text,

    -- Source tracking
    source_system text,
    source_record_id text,

    -- Household grouping (from source)
    household_id text,
    is_primary_household_contact boolean,

    -- Metadata
    last_contact_date date,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE ops.contacts IS 'Base entity for all people: guests, homeowners, vendors, staff';
COMMENT ON COLUMN ops.contacts.contact_type IS 'Type of contact: guest, homeowner, vendor, staff, etc.';
COMMENT ON COLUMN ops.contacts.contact_id IS 'Business identifier from source system (e.g., CON-GST-010001)';

-- ============================================================================
-- GUESTS
-- Guest-specific data linked to contacts
-- ============================================================================
CREATE TABLE ops.guests (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    guest_id text NOT NULL UNIQUE,                 -- GST-010001
    contact_id UUID REFERENCES ops.contacts(id),

    -- Source flags
    repeat_book_flag boolean,
    promo text,
    is_vip boolean,

    -- Source tracking
    source_system text,
    source_record_id text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE ops.guests IS 'Guest-specific data linked to contacts. Behavioral data is in analytics schema.';
COMMENT ON COLUMN ops.guests.guest_id IS 'Business identifier (e.g., GST-010001)';
COMMENT ON COLUMN ops.guests.is_vip IS 'VIP flag from source system';

-- ============================================================================
-- HOMEOWNERS
-- Homeowner-specific data linked to contacts
-- ============================================================================
CREATE TABLE ops.homeowners (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    homeowner_id text NOT NULL UNIQUE,
    contact_id UUID REFERENCES ops.contacts(id),

    -- Identity
    legal_name text,
    full_name text,
    preferred_name text,
    status text,

    -- External system references
    external_homeowner_code text,
    external_homeowner_id text,

    -- Payment
    payment_terms text,
    preferred_payment_method text,

    -- Source tracking
    source_system text,
    source_record_id text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE ops.homeowners IS 'Homeowner-specific data linked to contacts. Property relationships in join table.';
COMMENT ON COLUMN ops.homeowners.legal_name IS 'Legal name for contracts and tax documents';

-- ============================================================================
-- RESORTS
-- Resort/complex information
-- ============================================================================
CREATE TABLE ops.resorts (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    resort_id text NOT NULL UNIQUE,
    resort_code text,
    resort_name text,

    -- Location
    street_address text,
    city text,
    state text,
    postal_code text,
    country text,

    -- Contact info
    front_desk_phone text,
    front_desk_email text,

    -- Amenities (boolean flags - source data)
    has_air_conditioning boolean,
    has_fitness_center boolean,
    has_tennis_courts boolean,
    has_jacuzzi boolean,
    jacuzzi_details text,
    has_pool boolean,
    pool_details text,
    pool_hours text,
    has_day_spa boolean,
    has_beach_access boolean,
    has_bbq boolean,
    has_designated_parking boolean,
    has_free_parking boolean,
    provides_beach_towels boolean,
    provides_pool_towels boolean,
    has_outdoor_games boolean,

    -- Operations
    package_pickup_location text,
    service_request_process text,
    trash_notes text,
    parking_details text,

    -- Internet/utilities
    internet_info text,
    internet_provider text,
    cable_provider text,
    pest_control_vendor text,

    -- Guest registration
    guest_registration_required boolean,
    guest_registration_process text,

    -- Fees
    resort_fee_description text,
    resort_fee_daily_amount numeric(12,2),
    resort_fee_reservation_amount numeric(12,2),
    resort_fee_pay_due text,
    bills_through_pm boolean,

    -- Construction rules
    construction_form_required boolean,
    construction_advance_notice_required boolean,
    construction_restrictions text,
    insurance_required boolean,

    -- Notes
    notes text,
    is_ai_visible boolean,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE ops.resorts IS 'Resort/complex information. Contact relationships in resort_contacts join table.';

-- ============================================================================
-- PROPERTIES
-- Core property data
-- ============================================================================
CREATE TABLE ops.properties (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    property_id text NOT NULL UNIQUE,
    resort_id UUID REFERENCES ops.resorts(id),

    -- Names
    property_code_name text,
    legacy_name text,
    property_short_name text,
    full_property_name text,

    -- Physical attributes
    property_type text,
    bedrooms numeric(4,1),
    bathrooms numeric(4,1),
    square_feet integer,
    view text,
    max_occupancy integer,

    -- Location
    tmk_number text,
    rental_permit_number text,
    latitude numeric(10,7),
    longitude numeric(10,7),
    street_number text,
    street_name text,
    unit_number text,
    building_floor text,
    building text,
    street_address text,
    street_address_2 text,
    city text,
    state text,
    zip text,
    country text,

    -- Access & WiFi
    wifi_network text,
    wifi_password text,
    wifi_speed text,
    access_instructions text,
    house_rules text,

    -- Status
    status text,
    clean_status text,
    inspection_status text,

    -- Check-in/out
    check_in_time time,
    check_out_time time,
    early_checkin_allowed boolean,
    late_checkout_allowed boolean,
    minimum_nights integer,

    -- Pricing (source data)
    pricing_group text,
    pricing_base_rate numeric(12,2),
    pricing_minimum_rate numeric(12,2),
    cleaning_fee numeric(12,2),
    cleaning_cost numeric(12,2),
    coupons_enabled boolean,
    discounts_enabled boolean,
    has_early_bird_discount boolean,
    has_length_of_stay_discount boolean,
    has_last_minute_discount boolean,

    -- Beach
    has_beach_access boolean,
    beach_items_detail text,
    closest_beach_id text,

    -- Parking
    has_parking boolean,
    parking_cost numeric(12,2),

    -- Amenities & rooms (JSON from source)
    amenities jsonb,
    rooms jsonb,

    -- Images (paths from source)
    image_count integer,
    default_image_path text,
    thumbnail_path text,
    floorplan_path text,
    property_video_path text,
    property_photo_paths jsonb,
    property_photos jsonb,

    -- Web/SEO
    web_link text,
    web_name text,
    web_ribbon text,
    description text,
    short_description text,
    seo_title text,
    seo_description text,
    seo_keywords text,

    -- OTA listings
    vrbo_id text,
    vrbo_link text,
    vrbo_description text,
    vrbo_headline text,
    airbnb_id text,
    airbnb_link text,
    airbnb_headline text,
    airbnb_description text,
    airbnb_guest_favorite boolean,
    airbnb_guest_interactions text,
    airbnb_arrival_guide text,

    -- Operations
    trash_location text,
    trash_instructions text,
    trash_day text,
    preferred_vendor text,
    preferred_vendor_types text,
    pest_control_schedule text,
    pest_control_vendor text,
    spend_approval_amount numeric(12,2),
    has_replacement_approval boolean,
    last_audit_date date,
    next_audit_date date,

    -- Notes (various teams)
    special_instructions text,
    owner_notes text,
    sales_notes text,
    onboarding_notes text,
    cleaning_notes text,
    pricing_notes text,
    guest_notes text,
    maintenance_notes text,

    -- Financials
    hoa_due_amount numeric(12,2),
    last_purchase_price numeric(14,2),
    last_sale_date date,
    mortgage text,
    insurance_provider text,
    insurance_policy_number text,
    property_tax_assessed_value numeric(14,2),
    property_tax_annual_amount numeric(14,2),
    tax_rate numeric(7,4),

    -- Tax IDs
    general_excise_tax_id text,
    general_excise_tax_letter_number text,
    transient_accommodations_tax_id text,
    transient_accommodations_tax_letter_number text,

    -- Accounting
    payment_gateway text,
    quickbooks_class text,
    payout_schedule text,

    -- Contract
    contract_start_date date,
    contract_initial_period_end date,
    contract_renewal_terms text,

    -- Streamline sync fields
    streamline_property_id text,
    streamline_resort_id text,
    streamline_homeowner_id text,
    streamline_property_group_id text,
    streamline_status text,
    streamline_created_at timestamptz,
    streamline_content_updated_at timestamptz,
    streamline_price_updated_at timestamptz,
    streamline_reservations_updated_at timestamptz,

    -- External references
    airtable_bases jsonb,
    monday_item_id text,
    company_code text,

    -- Reviews (source data, not calculated)
    reviews jsonb,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE ops.properties IS 'Core property data. Homeowner relationships in homeowner_properties join table.';
COMMENT ON COLUMN ops.properties.resort_id IS 'FK to resorts table';
COMMENT ON COLUMN ops.properties.tmk_number IS 'Hawaii Tax Map Key number';

-- ============================================================================
-- RESERVATIONS
-- Core reservation data
-- ============================================================================
CREATE TABLE ops.reservations (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    reservation_id text NOT NULL UNIQUE,
    property_id UUID REFERENCES ops.properties(id),

    -- Streamline references
    streamline_confirmation_id integer NOT NULL,
    streamline_reservation_id integer,
    streamline_unit_id integer,
    streamline_status_code integer,

    -- Status
    reservation_status text,
    guest_registration_status text,
    reservation_type text,

    -- Dates & times
    arrival_date date,
    arrival_time time,
    departure_date date,
    departure_time time,
    booked_at timestamptz,

    -- Guest counts
    guest_count integer,
    adult_count integer,
    child_count integer,
    infant_count integer,

    -- Booking details
    booking_platform text,
    promotion_code text,

    -- Financials
    revenue_amount numeric(12,2),
    total_amount numeric(12,2),
    balance_amount numeric(12,2),
    additional_services_amount numeric(12,2),

    -- Fees & taxes
    damage_waiver numeric(12,2),
    booking_fee numeric(12,2),
    cleaning_fee numeric(12,2),
    cleaning_cost numeric(12,2),
    processing_fee numeric(12,2),
    airbnb_service_fee numeric(12,2),
    vrbo_service_fee numeric(12,2),
    hometogo_fee numeric(12,2),
    direct_booking_fee numeric(12,2),
    transient_accommodations_tax_amount numeric(12,2),
    general_excise_tax_amount numeric(12,2),
    maui_transient_tax_amount numeric(12,2),

    -- Commission
    management_commission_rate numeric(6,3),
    management_commission_amount numeric(12,2),
    owner_revenue_share_rate numeric(6,3),
    owner_revenue_share_amount numeric(12,2),

    -- Guest experience tracking
    guest_experience_agent_id text,
    additional_services text,
    add_ons_offered boolean,
    add_nights_offered boolean,
    additional_nights integer,
    next_followup_date timestamptz,
    last_action_date timestamptz,

    -- Guest input
    guest_comments text,

    -- Source sync
    last_sl_update timestamptz,
    company_code text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE ops.reservations IS 'Core reservation data. Guest relationships in reservation_guests join table.';
COMMENT ON COLUMN ops.reservations.streamline_confirmation_id IS 'Primary identifier from Streamline PMS';
