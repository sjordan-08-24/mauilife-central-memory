-- ============================================================================
-- OPS Schema Migration 004: Ticket Tables
-- ============================================================================
-- Creates ticket tables for operational tracking:
-- 1. property_care_tickets (maintenance, repairs, projects - property-focused)
-- 2. reservation_tickets (guest requests, issues during stay - reservation-focused)
-- ============================================================================

-- ============================================================================
-- PROPERTY_CARE_TICKETS
-- Maintenance, repairs, and project tickets (property-focused)
-- ============================================================================
CREATE TABLE ops.property_care_tickets (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    ticket_id text NOT NULL UNIQUE,
    ticket_code text,

    -- Relationships
    property_id UUID REFERENCES ops.properties(id),
    reservation_id UUID REFERENCES ops.reservations(id),  -- if related to a stay
    homeowner_id UUID REFERENCES ops.homeowners(id),
    vendor_id UUID REFERENCES ops.contacts(id),

    -- Ticket info
    ticket_name text,
    ticket_type text,
    ticket_category text,
    ticket_priority text,
    ticket_status text,
    ticket_source text,

    -- Dates
    ticket_created_at timestamptz,
    service_date date,
    work_started_at timestamptz,
    work_completion_date date,

    -- Comments
    guest_comments text,
    internal_comments text,
    ticket_instructions text,
    owner_comments text,
    owner_instructions text,
    work_notes text,

    -- Labor
    labor_time interval,
    labor_cost numeric(12,2),

    -- Costs
    supplies_cost numeric(12,2),
    parts_cost numeric(12,2),

    -- Cost allocation
    parts_cost_allocation text,
    supplies_cost_allocation text,
    labor_cost_allocation text,

    -- Vendor/ordering
    vendor_type text,
    vendor_category text,
    supplier_id text,
    ordering_platform_id text,
    external_order_number text,
    order_date date,
    delivered_date date,
    shipping_carrier_id text,
    shipping_carrier_tracking_number text,

    -- Status tracking
    accounting_status text,
    completion_timeline text,
    resolved_by text,

    -- Workflow timestamps
    ticket_paused_at timestamptz,
    ticket_resumed_at timestamptz,
    vendor_requested_at timestamptz,
    vendor_scheduled_at timestamptz,
    order_requested_at timestamptz,
    ordered_at timestamptz,
    labor_verification_requested_at timestamptz,

    -- Metrics (source data)
    response_time interval,
    resolution_time interval,
    count_of_service_dates_missed integer,
    days_since_missed_service_date integer,
    count_of_labor_verification_requests integer,

    -- Attachments
    receipt_paths jsonb,
    ticket_photo_paths jsonb,
    completion_photo_paths jsonb,

    -- External references
    work_order_number text,
    damage_claim_id text,
    inventory_action_id text,
    transaction_id text,
    shift_id text,
    missed_service_id text,
    ticket_submission_id text,
    monday_item_id text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE ops.property_care_tickets IS 'Property maintenance, repair, and project tickets';
COMMENT ON COLUMN ops.property_care_tickets.ticket_id IS 'Business identifier for the ticket';
COMMENT ON COLUMN ops.property_care_tickets.ticket_status IS 'Current status of the ticket';

-- ============================================================================
-- RESERVATION_TICKETS
-- Guest requests and issues during stay (reservation-focused)
-- ============================================================================
CREATE TABLE ops.reservation_tickets (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    ticket_id text NOT NULL UNIQUE,
    ticket_code text,

    -- Relationships
    reservation_id UUID NOT NULL REFERENCES ops.reservations(id),
    property_id UUID REFERENCES ops.properties(id),
    homeowner_id UUID REFERENCES ops.homeowners(id),
    vendor_id UUID REFERENCES ops.contacts(id),

    -- Ticket info
    ticket_name text,
    ticket_type text,
    ticket_category text,
    ticket_priority text,
    ticket_status text,
    ticket_source text,

    -- Dates
    ticket_created_at timestamptz,
    due_at timestamptz,
    work_started_at timestamptz,
    work_completion_date date,

    -- Comments
    guest_comments text,
    internal_comments text,
    ticket_instructions text,
    owner_comments text,
    owner_instructions text,
    work_notes text,

    -- Labor & costs
    labor_time interval,
    labor_cost numeric(12,2),
    supplies_cost numeric(12,2),
    parts_cost numeric(12,2),
    cost_allocation text,

    -- Vendor
    vendor_type text,
    vendor_category text,

    -- Status tracking
    accounting_status text,
    completion_timeline text,
    resolved_by text,

    -- Workflow timestamps
    ticket_paused_at timestamptz,
    ticket_resumed_at timestamptz,
    labor_verification_requested_at timestamptz,

    -- Metrics
    response_time interval,
    resolution_time interval,
    count_of_due_dates_missed integer,
    days_since_missed_due_date integer,
    count_of_labor_verification_requests integer,

    -- Attachments
    receipt_paths jsonb,
    ticket_photo_paths jsonb,
    completion_photo_paths jsonb,

    -- External references
    work_order_number text,
    damage_claim_id text,
    inventory_action_id text,
    transaction_id text,
    missed_due_date_id text,
    ticket_submission_id text,
    monday_item_id text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE ops.reservation_tickets IS 'Guest request and issue tickets during reservations';
COMMENT ON COLUMN ops.reservation_tickets.ticket_id IS 'Business identifier for the ticket';
COMMENT ON COLUMN ops.reservation_tickets.due_at IS 'When the ticket should be resolved by';
