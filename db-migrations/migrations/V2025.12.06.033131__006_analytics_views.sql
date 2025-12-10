-- ============================================================================
-- Analytics Schema Migration 006: Views
-- ============================================================================
-- Creates views for calculated/derived data that replaces behavioral fields
-- removed from core tables. These start as views (always current) and can be
-- converted to materialized views when performance requires it.
--
-- Views created:
-- 1. guest_metrics - Calculated guest behavior from reservation history
-- 2. property_performance - Revenue and occupancy metrics
-- 3. homeowner_portfolio - Aggregated portfolio metrics
-- 4. reservation_insights - Enriched reservation data for real-time insights
-- ============================================================================

-- ============================================================================
-- GUEST_METRICS
-- Calculated from reservation history - replaces behavioral fields in guests table
-- ============================================================================
CREATE OR REPLACE VIEW analytics.guest_metrics AS
SELECT
    g.id AS guest_id,
    g.guest_id AS guest_code,
    c.full_name,
    c.email,

    -- Booking metrics
    COUNT(DISTINCT rg.reservation_id) AS total_bookings,
    MIN(r.arrival_date) AS first_booking_date,
    MAX(r.arrival_date) AS most_recent_booking_date,
    ROUND(AVG(r.departure_date - r.arrival_date), 2) AS avg_length_of_stay,

    -- Revenue metrics
    COALESCE(SUM(r.total_amount), 0) AS lifetime_value,
    ROUND(AVG(r.total_amount), 2) AS avg_booking_value,
    COALESCE(SUM(r.additional_services_amount), 0) AS total_additional_services_spend,

    -- Booking patterns
    MODE() WITHIN GROUP (ORDER BY r.booking_platform) AS preferred_booking_platform,
    ROUND(AVG(r.arrival_date - r.booked_at::date), 0) AS avg_days_booked_in_advance,

    -- Stay patterns
    ARRAY_AGG(DISTINCT r.arrival_time ORDER BY r.arrival_time)
        FILTER (WHERE r.arrival_time IS NOT NULL) AS arrival_times,
    ARRAY_AGG(DISTINCT r.departure_time ORDER BY r.departure_time)
        FILTER (WHERE r.departure_time IS NOT NULL) AS departure_times,

    -- Property preferences
    ARRAY_AGG(DISTINCT p.property_type ORDER BY p.property_type)
        FILTER (WHERE p.property_type IS NOT NULL) AS property_types_booked,
    ARRAY_AGG(DISTINCT p.view ORDER BY p.view)
        FILTER (WHERE p.view IS NOT NULL) AS views_booked,
    MODE() WITHIN GROUP (ORDER BY p.bedrooms) AS preferred_bedroom_count,

    -- Repeat guest flag
    CASE WHEN COUNT(DISTINCT rg.reservation_id) > 1 THEN true ELSE false END AS is_repeat_guest

FROM ops.guests g
LEFT JOIN ops.contacts c ON g.contact_id = c.id
LEFT JOIN ops.reservation_guests rg ON g.id = rg.guest_id
LEFT JOIN ops.reservations r ON rg.reservation_id = r.id
LEFT JOIN ops.properties p ON r.property_id = p.id
GROUP BY g.id, g.guest_id, c.full_name, c.email;

COMMENT ON VIEW analytics.guest_metrics IS 'Calculated guest metrics from reservation history';

-- ============================================================================
-- PROPERTY_PERFORMANCE
-- Revenue and occupancy metrics by property
-- ============================================================================
CREATE OR REPLACE VIEW analytics.property_performance AS
SELECT
    p.id AS property_id,
    p.property_id AS property_code,
    p.full_property_name,
    p.property_type,
    p.bedrooms,
    res.resort_name,

    -- Reservation counts
    COUNT(r.id) AS total_reservations,
    COUNT(r.id) FILTER (WHERE r.arrival_date >= CURRENT_DATE - INTERVAL '1 year') AS reservations_last_year,
    COUNT(r.id) FILTER (WHERE r.arrival_date >= CURRENT_DATE - INTERVAL '30 days') AS reservations_last_30_days,

    -- Revenue
    COALESCE(SUM(r.revenue_amount), 0) AS total_revenue,
    COALESCE(SUM(r.revenue_amount) FILTER (WHERE r.arrival_date >= CURRENT_DATE - INTERVAL '1 year'), 0) AS revenue_last_year,
    ROUND(AVG(r.revenue_amount), 2) AS avg_revenue_per_booking,

    -- Occupancy (nights booked)
    COALESCE(SUM(r.departure_date - r.arrival_date), 0) AS total_nights_booked,
    COALESCE(SUM(r.departure_date - r.arrival_date)
        FILTER (WHERE r.arrival_date >= CURRENT_DATE - INTERVAL '1 year'), 0) AS nights_booked_last_year,

    -- Guest metrics
    COUNT(DISTINCT rg.guest_id) AS unique_guests,
    ROUND(AVG(r.guest_count), 1) AS avg_guest_count,

    -- Booking lead time
    ROUND(AVG(r.arrival_date - r.booked_at::date), 0) AS avg_booking_lead_time,

    -- Platform distribution
    COUNT(*) FILTER (WHERE r.booking_platform ILIKE '%airbnb%') AS airbnb_bookings,
    COUNT(*) FILTER (WHERE r.booking_platform ILIKE '%vrbo%') AS vrbo_bookings,
    COUNT(*) FILTER (WHERE r.booking_platform ILIKE '%direct%') AS direct_bookings,

    -- Cleaning metrics
    ROUND(AVG(p.cleaning_fee), 2) AS avg_cleaning_fee,
    ROUND(AVG(p.cleaning_cost), 2) AS avg_cleaning_cost

FROM ops.properties p
LEFT JOIN ops.resorts res ON p.resort_id = res.id
LEFT JOIN ops.reservations r ON p.id = r.property_id
LEFT JOIN ops.reservation_guests rg ON r.id = rg.reservation_id
GROUP BY p.id, p.property_id, p.full_property_name, p.property_type, p.bedrooms, res.resort_name;

COMMENT ON VIEW analytics.property_performance IS 'Property revenue and occupancy metrics';

-- ============================================================================
-- HOMEOWNER_PORTFOLIO
-- Aggregated metrics across all properties owned by a homeowner
-- ============================================================================
CREATE OR REPLACE VIEW analytics.homeowner_portfolio AS
SELECT
    h.id AS homeowner_id,
    h.homeowner_id AS homeowner_code,
    h.full_name,
    c.email,

    -- Portfolio size
    COUNT(DISTINCT hp.property_id) AS property_count,
    ARRAY_AGG(DISTINCT p.property_id ORDER BY p.property_id) AS property_codes,
    ARRAY_AGG(DISTINCT p.full_property_name ORDER BY p.full_property_name) AS property_names,

    -- Revenue across portfolio
    COALESCE(SUM(r.revenue_amount), 0) AS total_portfolio_revenue,
    COALESCE(SUM(r.revenue_amount) FILTER (WHERE r.arrival_date >= CURRENT_DATE - INTERVAL '1 year'), 0) AS revenue_last_year,
    COALESCE(SUM(r.owner_revenue_share_amount), 0) AS total_owner_revenue,
    ROUND(AVG(r.owner_revenue_share_rate), 3) AS avg_revenue_share_rate,

    -- Reservation counts
    COUNT(r.id) AS total_reservations,
    COUNT(r.id) FILTER (WHERE r.arrival_date >= CURRENT_DATE - INTERVAL '1 year') AS reservations_last_year,

    -- Property types
    ARRAY_AGG(DISTINCT p.property_type ORDER BY p.property_type)
        FILTER (WHERE p.property_type IS NOT NULL) AS property_types,

    -- Ownership info
    MIN(hp.management_start_date) AS earliest_management_date,
    MAX(hp.contract_renewal_date) AS next_contract_renewal

FROM ops.homeowners h
LEFT JOIN ops.contacts c ON h.contact_id = c.id
LEFT JOIN ops.homeowner_properties hp ON h.id = hp.homeowner_id
LEFT JOIN ops.properties p ON hp.property_id = p.id
LEFT JOIN ops.reservations r ON p.id = r.property_id
GROUP BY h.id, h.homeowner_id, h.full_name, c.email;

COMMENT ON VIEW analytics.homeowner_portfolio IS 'Aggregated portfolio metrics for homeowners';

-- ============================================================================
-- RESERVATION_INSIGHTS
-- Enriched reservation data for real-time insights during booking/guest interactions
-- ============================================================================
CREATE OR REPLACE VIEW analytics.reservation_insights AS
SELECT
    r.id AS reservation_id,
    r.reservation_id AS reservation_code,
    r.arrival_date,
    r.departure_date,
    r.departure_date - r.arrival_date AS length_of_stay,
    r.reservation_status,
    r.total_amount,
    r.booking_platform,
    r.booked_at,

    -- Guest info
    g.guest_id AS primary_guest_code,
    c.full_name AS guest_name,
    c.email AS guest_email,
    c.phone AS guest_phone,
    gm.total_bookings AS guest_total_bookings,
    gm.lifetime_value AS guest_lifetime_value,
    gm.avg_length_of_stay AS guest_avg_stay,
    gm.is_repeat_guest,
    og.is_vip AS guest_is_vip,

    -- Property info
    p.property_id AS property_code,
    p.full_property_name,
    p.property_type,
    p.bedrooms,
    res.resort_name,

    -- Homeowner info
    ho.homeowner_id AS homeowner_code,
    ho.full_name AS homeowner_name,

    -- Upsell opportunities
    CASE
        WHEN r.add_ons_offered = false OR r.add_ons_offered IS NULL THEN 'Add-ons not offered'
        WHEN r.additional_services_amount > 0 THEN 'Add-ons purchased'
        ELSE 'Add-ons offered, not purchased'
    END AS addon_status,

    CASE
        WHEN r.add_nights_offered = false OR r.add_nights_offered IS NULL THEN 'Extra nights not offered'
        WHEN r.additional_nights > 0 THEN 'Extra nights added'
        ELSE 'Extra nights offered, not added'
    END AS extra_nights_status,

    -- Days until arrival (for upcoming reservations)
    CASE
        WHEN r.arrival_date > CURRENT_DATE THEN r.arrival_date - CURRENT_DATE
        ELSE NULL
    END AS days_until_arrival,

    -- Stay status
    CASE
        WHEN r.departure_date < CURRENT_DATE THEN 'completed'
        WHEN r.arrival_date <= CURRENT_DATE AND r.departure_date >= CURRENT_DATE THEN 'in_progress'
        WHEN r.arrival_date > CURRENT_DATE THEN 'upcoming'
        ELSE 'unknown'
    END AS stay_status

FROM ops.reservations r
LEFT JOIN ops.reservation_guests rg ON r.id = rg.reservation_id AND rg.is_primary = true
LEFT JOIN ops.guests og ON rg.guest_id = og.id
LEFT JOIN ops.guests g ON rg.guest_id = g.id
LEFT JOIN ops.contacts c ON g.contact_id = c.id
LEFT JOIN ops.properties p ON r.property_id = p.id
LEFT JOIN ops.resorts res ON p.resort_id = res.id
LEFT JOIN ops.homeowner_properties hp ON p.id = hp.property_id
LEFT JOIN ops.homeowners ho ON hp.homeowner_id = ho.id
LEFT JOIN analytics.guest_metrics gm ON g.id = gm.guest_id;

COMMENT ON VIEW analytics.reservation_insights IS 'Enriched reservation data for real-time guest insights and upsell opportunities';

-- ============================================================================
-- TICKET_METRICS
-- Aggregated ticket metrics for operational insights
-- ============================================================================
CREATE OR REPLACE VIEW analytics.ticket_metrics AS
SELECT
    p.id AS property_id,
    p.property_id AS property_code,
    p.full_property_name,

    -- Property care ticket counts
    COUNT(DISTINCT pct.id) AS total_property_care_tickets,
    COUNT(DISTINCT pct.id) FILTER (WHERE pct.ticket_status NOT IN ('completed', 'closed', 'cancelled')) AS open_property_care_tickets,
    COUNT(DISTINCT pct.id) FILTER (WHERE pct.ticket_created_at >= CURRENT_DATE - INTERVAL '30 days') AS property_care_tickets_last_30_days,

    -- Reservation ticket counts
    COUNT(DISTINCT rt.id) AS total_reservation_tickets,
    COUNT(DISTINCT rt.id) FILTER (WHERE rt.ticket_status NOT IN ('completed', 'closed', 'cancelled')) AS open_reservation_tickets,
    COUNT(DISTINCT rt.id) FILTER (WHERE rt.ticket_created_at >= CURRENT_DATE - INTERVAL '30 days') AS reservation_tickets_last_30_days,

    -- Costs
    COALESCE(SUM(pct.labor_cost), 0) AS total_labor_cost,
    COALESCE(SUM(pct.supplies_cost), 0) AS total_supplies_cost,
    COALESCE(SUM(pct.parts_cost), 0) AS total_parts_cost,

    -- Response times (average)
    AVG(pct.response_time) AS avg_property_care_response_time,
    AVG(pct.resolution_time) AS avg_property_care_resolution_time,
    AVG(rt.response_time) AS avg_reservation_ticket_response_time,
    AVG(rt.resolution_time) AS avg_reservation_ticket_resolution_time

FROM ops.properties p
LEFT JOIN ops.property_care_tickets pct ON p.id = pct.property_id
LEFT JOIN ops.reservation_tickets rt ON p.id = rt.property_id
GROUP BY p.id, p.property_id, p.full_property_name;

COMMENT ON VIEW analytics.ticket_metrics IS 'Aggregated ticket metrics by property';
