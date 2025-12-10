-- ============================================================================
-- OPS Schema Migration 005: Indexes
-- ============================================================================
-- Creates indexes for common query patterns and foreign key lookups.
-- Organized by table for easy maintenance.
-- ============================================================================

-- ============================================================================
-- CONTACTS INDEXES
-- ============================================================================
CREATE INDEX idx_contacts_contact_type ON ops.contacts(contact_type);
CREATE INDEX idx_contacts_email ON ops.contacts(email) WHERE email IS NOT NULL;
CREATE INDEX idx_contacts_phone ON ops.contacts(phone) WHERE phone IS NOT NULL;
CREATE INDEX idx_contacts_status ON ops.contacts(status) WHERE status IS NOT NULL;
CREATE INDEX idx_contacts_household_id ON ops.contacts(household_id) WHERE household_id IS NOT NULL;
CREATE INDEX idx_contacts_source_system ON ops.contacts(source_system) WHERE source_system IS NOT NULL;

-- ============================================================================
-- GUESTS INDEXES
-- ============================================================================
CREATE INDEX idx_guests_contact_id ON ops.guests(contact_id);
CREATE INDEX idx_guests_is_vip ON ops.guests(is_vip) WHERE is_vip = true;
CREATE INDEX idx_guests_repeat_book_flag ON ops.guests(repeat_book_flag) WHERE repeat_book_flag = true;

-- ============================================================================
-- HOMEOWNERS INDEXES
-- ============================================================================
CREATE INDEX idx_homeowners_contact_id ON ops.homeowners(contact_id);
CREATE INDEX idx_homeowners_status ON ops.homeowners(status) WHERE status IS NOT NULL;

-- ============================================================================
-- RESORTS INDEXES
-- ============================================================================
CREATE INDEX idx_resorts_resort_code ON ops.resorts(resort_code) WHERE resort_code IS NOT NULL;
CREATE INDEX idx_resorts_city ON ops.resorts(city) WHERE city IS NOT NULL;

-- ============================================================================
-- PROPERTIES INDEXES
-- ============================================================================
CREATE INDEX idx_properties_resort_id ON ops.properties(resort_id);
CREATE INDEX idx_properties_status ON ops.properties(status) WHERE status IS NOT NULL;
CREATE INDEX idx_properties_property_type ON ops.properties(property_type) WHERE property_type IS NOT NULL;
CREATE INDEX idx_properties_bedrooms ON ops.properties(bedrooms) WHERE bedrooms IS NOT NULL;
CREATE INDEX idx_properties_clean_status ON ops.properties(clean_status) WHERE clean_status IS NOT NULL;
CREATE INDEX idx_properties_streamline_property_id ON ops.properties(streamline_property_id) WHERE streamline_property_id IS NOT NULL;

-- ============================================================================
-- RESERVATIONS INDEXES
-- ============================================================================
CREATE INDEX idx_reservations_property_id ON ops.reservations(property_id);
CREATE INDEX idx_reservations_arrival_date ON ops.reservations(arrival_date);
CREATE INDEX idx_reservations_departure_date ON ops.reservations(departure_date);
CREATE INDEX idx_reservations_reservation_status ON ops.reservations(reservation_status) WHERE reservation_status IS NOT NULL;
CREATE INDEX idx_reservations_booking_platform ON ops.reservations(booking_platform) WHERE booking_platform IS NOT NULL;
CREATE INDEX idx_reservations_booked_at ON ops.reservations(booked_at);
CREATE INDEX idx_reservations_streamline_confirmation_id ON ops.reservations(streamline_confirmation_id);

-- Composite index for common date range queries
CREATE INDEX idx_reservations_date_range ON ops.reservations(arrival_date, departure_date);

-- ============================================================================
-- HOMEOWNER_PROPERTIES INDEXES
-- ============================================================================
CREATE INDEX idx_homeowner_properties_homeowner_id ON ops.homeowner_properties(homeowner_id);
CREATE INDEX idx_homeowner_properties_property_id ON ops.homeowner_properties(property_id);
CREATE INDEX idx_homeowner_properties_ownership_type ON ops.homeowner_properties(ownership_type) WHERE ownership_type IS NOT NULL;
CREATE INDEX idx_homeowner_properties_relationship_type ON ops.homeowner_properties(relationship_type) WHERE relationship_type IS NOT NULL;
CREATE INDEX idx_homeowner_properties_is_managing ON ops.homeowner_properties(is_managing_owner) WHERE is_managing_owner = true;

-- ============================================================================
-- RESERVATION_GUESTS INDEXES
-- ============================================================================
CREATE INDEX idx_reservation_guests_reservation_id ON ops.reservation_guests(reservation_id);
CREATE INDEX idx_reservation_guests_guest_id ON ops.reservation_guests(guest_id);
CREATE INDEX idx_reservation_guests_guest_role ON ops.reservation_guests(guest_role);

-- ============================================================================
-- RESORT_CONTACTS INDEXES
-- ============================================================================
CREATE INDEX idx_resort_contacts_resort_id ON ops.resort_contacts(resort_id);
CREATE INDEX idx_resort_contacts_contact_id ON ops.resort_contacts(contact_id);
CREATE INDEX idx_resort_contacts_contact_role ON ops.resort_contacts(contact_role);

-- ============================================================================
-- PROPERTY_VENDORS INDEXES
-- ============================================================================
CREATE INDEX idx_property_vendors_property_id ON ops.property_vendors(property_id);
CREATE INDEX idx_property_vendors_vendor_id ON ops.property_vendors(vendor_id);
CREATE INDEX idx_property_vendors_vendor_type ON ops.property_vendors(vendor_type);
CREATE INDEX idx_property_vendors_is_preferred ON ops.property_vendors(is_preferred) WHERE is_preferred = true;

-- ============================================================================
-- PROPERTY_CARE_TICKETS INDEXES
-- ============================================================================
CREATE INDEX idx_property_care_tickets_property_id ON ops.property_care_tickets(property_id);
CREATE INDEX idx_property_care_tickets_reservation_id ON ops.property_care_tickets(reservation_id) WHERE reservation_id IS NOT NULL;
CREATE INDEX idx_property_care_tickets_homeowner_id ON ops.property_care_tickets(homeowner_id) WHERE homeowner_id IS NOT NULL;
CREATE INDEX idx_property_care_tickets_vendor_id ON ops.property_care_tickets(vendor_id) WHERE vendor_id IS NOT NULL;
CREATE INDEX idx_property_care_tickets_ticket_status ON ops.property_care_tickets(ticket_status) WHERE ticket_status IS NOT NULL;
CREATE INDEX idx_property_care_tickets_ticket_priority ON ops.property_care_tickets(ticket_priority) WHERE ticket_priority IS NOT NULL;
CREATE INDEX idx_property_care_tickets_service_date ON ops.property_care_tickets(service_date) WHERE service_date IS NOT NULL;
CREATE INDEX idx_property_care_tickets_ticket_created_at ON ops.property_care_tickets(ticket_created_at);

-- ============================================================================
-- RESERVATION_TICKETS INDEXES
-- ============================================================================
CREATE INDEX idx_reservation_tickets_reservation_id ON ops.reservation_tickets(reservation_id);
CREATE INDEX idx_reservation_tickets_property_id ON ops.reservation_tickets(property_id) WHERE property_id IS NOT NULL;
CREATE INDEX idx_reservation_tickets_homeowner_id ON ops.reservation_tickets(homeowner_id) WHERE homeowner_id IS NOT NULL;
CREATE INDEX idx_reservation_tickets_vendor_id ON ops.reservation_tickets(vendor_id) WHERE vendor_id IS NOT NULL;
CREATE INDEX idx_reservation_tickets_ticket_status ON ops.reservation_tickets(ticket_status) WHERE ticket_status IS NOT NULL;
CREATE INDEX idx_reservation_tickets_ticket_priority ON ops.reservation_tickets(ticket_priority) WHERE ticket_priority IS NOT NULL;
CREATE INDEX idx_reservation_tickets_due_at ON ops.reservation_tickets(due_at) WHERE due_at IS NOT NULL;
CREATE INDEX idx_reservation_tickets_ticket_created_at ON ops.reservation_tickets(ticket_created_at);
