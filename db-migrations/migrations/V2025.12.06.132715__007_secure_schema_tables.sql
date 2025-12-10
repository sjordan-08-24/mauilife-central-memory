-- ============================================================================
-- Secure Schema Migration 007: Users and Contact Entities
-- ============================================================================
-- Creates tables in the secure schema for sensitive data:
-- 1. users - Authentication (login credentials)
-- 2. contact_entities - PII (tax IDs, banking information)
--
-- This schema should have restricted access. Only application service
-- accounts and authorized admin roles should have access.
-- ============================================================================

-- ============================================================================
-- USERS
-- Authentication table for application login
-- Links to ops.contacts for profile/operational data
-- ============================================================================
CREATE TABLE secure.users (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    contact_id UUID REFERENCES ops.contacts(id),

    -- Authentication
    email text UNIQUE NOT NULL,
    password_hash text NOT NULL,

    -- Account status
    is_active boolean DEFAULT true,
    is_verified boolean DEFAULT false,

    -- Login tracking
    last_login_at timestamptz,
    failed_login_attempts integer DEFAULT 0,
    locked_until timestamptz,

    -- Password reset
    password_reset_token text,
    password_reset_expires_at timestamptz,

    -- Email verification
    email_verification_token text,
    email_verified_at timestamptz,

    -- Audit
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

COMMENT ON TABLE secure.users IS 'Authentication credentials for application login - restricted access';
COMMENT ON COLUMN secure.users.contact_id IS 'Links to ops.contacts for profile and operational data';
COMMENT ON COLUMN secure.users.password_hash IS 'Bcrypt or Argon2 hashed password - never store plaintext';
COMMENT ON COLUMN secure.users.is_active IS 'False to disable account without deleting';
COMMENT ON COLUMN secure.users.locked_until IS 'Account locked until this time after too many failed attempts';

-- Indexes for users
CREATE INDEX idx_secure_users_contact_id ON secure.users(contact_id);
CREATE INDEX idx_secure_users_email ON secure.users(email);
CREATE INDEX idx_secure_users_is_active ON secure.users(is_active) WHERE is_active = true;
CREATE INDEX idx_secure_users_password_reset ON secure.users(password_reset_token) WHERE password_reset_token IS NOT NULL;

-- ============================================================================
-- CONTACT_ENTITIES
-- Sensitive entity, tax, and banking information for contacts
-- Only created for contacts who require it (homeowners, vendors, team members)
-- Guests do NOT have records in this table
-- ============================================================================
CREATE TABLE secure.contact_entities (
    id UUID PRIMARY KEY DEFAULT generate_uuid_v7(),
    contact_id UUID NOT NULL REFERENCES ops.contacts(id),

    -- Entity classification
    entity_type text NOT NULL,            -- 'individual', 'sole_proprietorship', 'LLC', 'corporation', 'trust', etc.
    entity_name text,                      -- Legal entity name (NULL for individuals using personal name)
    dba_name text,                         -- "Doing business as" name if different from entity_name

    -- Tax identification (only ONE tax ID per contact for 1099/W-2 purposes)
    tax_id_type text,                      -- 'SSN', 'EIN', 'ITIN'
    tax_id_encrypted text,                 -- Encrypted tax ID value
    tax_classification text,               -- For LLCs: how they elect to be taxed ('C', 'S', 'P')

    -- W-9 / tax form tracking
    w9_on_file boolean DEFAULT false,
    w9_received_date date,
    w9_document_path text,                 -- Path to stored W-9 document

    -- Banking information (for payments: owner payouts, vendor payments, payroll)
    bank_name text,
    bank_account_type text,                -- 'checking', 'savings'
    bank_routing_encrypted text,           -- Encrypted routing number
    bank_account_encrypted text,           -- Encrypted account number
    payment_method_preference text,        -- 'ach', 'check', 'wire', 'zelle'

    -- Verification audit trail
    verified_at timestamptz,
    verified_by text,                      -- Who verified this information
    verification_notes text,

    -- Source tracking
    source_system text,
    source_record_id text,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),

    -- One entity record per contact
    CONSTRAINT uq_contact_entities_contact UNIQUE(contact_id),

    -- Validate entity type
    CONSTRAINT chk_entity_type CHECK (
        entity_type IN (
            'individual', 'sole_proprietorship', 'LLC', 'corporation',
            's_corporation', 'partnership', 'trust', 'estate', 'other'
        )
    ),

    -- Validate tax ID type
    CONSTRAINT chk_tax_id_type CHECK (
        tax_id_type IS NULL OR tax_id_type IN ('SSN', 'EIN', 'ITIN')
    ),

    -- Validate bank account type
    CONSTRAINT chk_bank_account_type CHECK (
        bank_account_type IS NULL OR bank_account_type IN ('checking', 'savings')
    ),

    -- Entity name required for non-individual types
    CONSTRAINT chk_entity_name_required CHECK (
        entity_type = 'individual'
        OR entity_type = 'sole_proprietorship'
        OR entity_name IS NOT NULL
    )
);

-- Comments
COMMENT ON TABLE secure.contact_entities IS 'Sensitive entity, tax, and banking info - restricted access';
COMMENT ON COLUMN secure.contact_entities.entity_type IS 'Legal entity type matching W-9 classifications';
COMMENT ON COLUMN secure.contact_entities.entity_name IS 'Legal entity name (e.g., "Smith Family Trust", "ABC Properties LLC")';
COMMENT ON COLUMN secure.contact_entities.tax_id_type IS 'Type of tax ID: SSN (individuals), EIN (entities), ITIN (foreign)';
COMMENT ON COLUMN secure.contact_entities.tax_id_encrypted IS 'Encrypted tax identification number - decrypt only when needed';
COMMENT ON COLUMN secure.contact_entities.tax_classification IS 'For LLCs: how they elect to be taxed (C-corp, S-corp, Partnership)';
COMMENT ON COLUMN secure.contact_entities.w9_on_file IS 'Whether a signed W-9 has been received';
COMMENT ON COLUMN secure.contact_entities.bank_routing_encrypted IS 'Encrypted bank routing number for ACH payments';
COMMENT ON COLUMN secure.contact_entities.bank_account_encrypted IS 'Encrypted bank account number for ACH payments';

-- Indexes for contact_entities
CREATE INDEX idx_secure_contact_entities_contact_id ON secure.contact_entities(contact_id);
CREATE INDEX idx_secure_contact_entities_entity_type ON secure.contact_entities(entity_type);
CREATE INDEX idx_secure_contact_entities_w9_missing ON secure.contact_entities(w9_on_file) WHERE w9_on_file = false;
CREATE INDEX idx_secure_contact_entities_unverified ON secure.contact_entities(verified_at) WHERE verified_at IS NULL;
