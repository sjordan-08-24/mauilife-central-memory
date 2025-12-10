-- ============================================================================
-- Schema Migration 001: Create Schemas
-- ============================================================================
-- Creates the database schemas for the operational data model:
-- - ops: Source/transactional business data
-- - secure: Authentication and PII (restricted access)
-- - analytics: Calculated/derived views
-- ============================================================================

-- Operational data schema (business data)
CREATE SCHEMA IF NOT EXISTS ops;

COMMENT ON SCHEMA ops IS 'Operational data: source system data from Streamline, normalized and cleaned';

-- Secure schema for authentication and PII (restricted access)
CREATE SCHEMA IF NOT EXISTS secure;

COMMENT ON SCHEMA secure IS 'Secure data: authentication (users) and PII (tax IDs, banking) - restricted access';

-- Analytics schema for derived/calculated data
CREATE SCHEMA IF NOT EXISTS analytics;

COMMENT ON SCHEMA analytics IS 'Analytics data: calculated metrics, views, and derived insights';

-- Future: Audit schema for historical change tracking
-- CREATE SCHEMA IF NOT EXISTS audit;
-- COMMENT ON SCHEMA audit IS 'Audit data: historical change tracking for AI insights';
