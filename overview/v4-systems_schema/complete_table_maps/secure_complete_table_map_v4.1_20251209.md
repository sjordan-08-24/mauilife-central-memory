# Secure Schema — Complete Table Map v4.1

**Date:** 2025-12-09  
**Schema:** secure  
**Tables:** 5  
**Primary Key Standard:** UUIDv7 (time-ordered, globally unique)

---

## Schema Overview

The secure schema stores sensitive and encrypted data that requires elevated access controls. This includes PII (personally identifiable information), payment tokens, system credentials, and comprehensive audit logging. All tables in this schema should have Row Level Security (RLS) enabled and restricted access policies.

**Security Principles:**
- Encryption at rest for all sensitive fields
- Minimal access (principle of least privilege)
- Complete audit trail of all access
- Separation from operational data
- No direct joins to operational tables (use IDs only)

---

## Foreign Key Relationship Matrix

```
secure.pii_vault ───────────────────────────────────────────────────────────────┐
    (standalone - references contacts by ID only, no FK)                        │
                                                                                │
secure.payment_tokens ──────────────────────────────────────────────────────────┤
    (standalone - references contacts by ID only, no FK)                        │
                                                                                │
secure.access_credentials ──────────────────────────────────────────────────────┤
    (standalone - no FK to avoid leaking credential associations)               │
                                                                                │
secure.audit_events ────────────────────────────────────────────────────────────┤
    (standalone - immutable audit log)                                          │
                                                                                │
secure.data_access_log ─────────────────────────────────────────────────────────┘
    (standalone - immutable access log)
```

**NO FOREIGN KEYS** — By design, the secure schema does not have foreign key relationships to other schemas. This prevents:
- Cascade deletes from exposing sensitive data
- Join queries that could leak data
- FK constraint errors blocking critical operations

Entity references use ID fields (contact_id, user_id) without FK constraints.

---

## Business ID Cross-Reference

| Table | Business ID Format | Example | Sequence Start |
|-------|-------------------|---------|----------------|
| pii_vault | PII-NNNNNN | PII-010001 | 10001 |
| payment_tokens | TOK-NNNNNN | TOK-010001 | 10001 |
| access_credentials | CRED-NNNNNN | CRED-010001 | 10001 |
| audit_events | AUD-NNNNNN | AUD-010001 | 10001 |
| data_access_log | DAL-NNNNNN | DAL-010001 | 10001 |

---

## Index Coverage Summary

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| secure.pii_vault | idx_pii_id | pii_id (UNIQUE) | Business ID lookup |
| | idx_pii_entity | entity_type, entity_id | Entity lookup |
| | idx_pii_type | data_type | Filter by PII type |
| | idx_pii_expires | expires_at WHERE expires_at IS NOT NULL | Expiration cleanup |
| secure.payment_tokens | idx_token_id | token_id (UNIQUE) | Business ID lookup |
| | idx_token_contact | contact_id | Contact's tokens |
| | idx_token_type | token_type | Filter by type |
| | idx_token_active | is_active WHERE is_active = true | Active tokens |
| | idx_token_expires | expires_at WHERE expires_at IS NOT NULL | Expiration cleanup |
| secure.access_credentials | idx_cred_id | credential_id (UNIQUE) | Business ID lookup |
| | idx_cred_system | system_name | System credentials |
| | idx_cred_type | credential_type | Filter by type |
| | idx_cred_active | is_active WHERE is_active = true | Active credentials |
| | idx_cred_expires | expires_at WHERE expires_at IS NOT NULL | Expiration alerts |
| secure.audit_events | idx_audit_id | audit_id (UNIQUE) | Business ID lookup |
| | idx_audit_timestamp | event_timestamp | Chronological queries |
| | idx_audit_user | user_id | User's audit trail |
| | idx_audit_entity | entity_type, entity_id | Entity audit trail |
| | idx_audit_action | action_type | Filter by action |
| | idx_audit_severity | severity WHERE severity IN ('warning', 'critical') | Security alerts |
| secure.data_access_log | idx_dal_id | log_id (UNIQUE) | Business ID lookup |
| | idx_dal_timestamp | access_timestamp | Chronological queries |
| | idx_dal_user | accessed_by | User's access history |
| | idx_dal_table | table_accessed | Table access history |
| | idx_dal_record | record_id | Record access history |

---

# TABLE SPECIFICATIONS

---

## 1. secure.pii_vault

**PURPOSE:** Encrypted storage for personally identifiable information (PII) that must be protected. Stores SSN, passport numbers, driver's license, bank account details, and other sensitive identifiers. Data is encrypted at the application layer before storage.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| pii_id | text | NOT NULL, UNIQUE | Business ID: PII-NNNNNN | N/A |
| entity_type | text | NOT NULL | Entity: contact, homeowner, guest, team_member | |
| entity_id | uuid | NOT NULL | Reference to entity (no FK) | |
| data_type | text | NOT NULL | Type: ssn, passport, drivers_license, bank_account, tax_id | |
| encrypted_value | text | NOT NULL | Encrypted data (AES-256) | |
| encryption_key_id | text | NOT NULL | Reference to encryption key | |
| encryption_algorithm | text | DEFAULT 'AES-256-GCM' | Encryption method used | |
| data_hash | text | | SHA-256 hash for verification | |
| last_four | text | | Last 4 chars (for display) | |
| issuing_authority | text | | Issuing authority (state, country) | |
| issue_date | date | | Date issued | |
| expiration_date | date | | Expiration date | |
| is_verified | boolean | DEFAULT false | Verification status | |
| verified_at | timestamptz | | When verified | |
| verified_by | text | | Who/what verified | |
| expires_at | timestamptz | | When to purge from vault | |
| is_active | boolean | DEFAULT true | Currently active | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |
| created_by | text | | Who created | |

**CHECK CONSTRAINTS:**
- entity_type IN ('contact', 'homeowner', 'guest', 'team_member', 'company')
- data_type IN ('ssn', 'passport', 'drivers_license', 'bank_account', 'tax_id', 'ein', 'routing_number')

**UNIQUE CONSTRAINT:** (entity_type, entity_id, data_type) — One record per entity/type combination

**RLS POLICY:** Only security_admin role can SELECT/INSERT/UPDATE. No DELETE allowed.

---

## 2. secure.payment_tokens

**PURPOSE:** Tokenized payment method storage. Actual card numbers and bank accounts are stored with payment processors (Stripe, etc.). This table stores the tokens and metadata needed to charge saved payment methods.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| token_id | text | NOT NULL, UNIQUE | Business ID: TOK-NNNNNN | N/A |
| contact_id | uuid | NOT NULL | Contact reference (no FK) | |
| token_type | text | NOT NULL | Type: credit_card, debit_card, bank_account, ach | |
| processor | text | NOT NULL | Processor: stripe, square, authorize_net | |
| processor_customer_id | text | NOT NULL | Processor's customer ID | |
| processor_token | text | NOT NULL | Processor's payment method token | |
| card_brand | text | | Card brand: visa, mastercard, amex, discover | |
| last_four | text | NOT NULL | Last 4 digits | |
| exp_month | integer | | Expiration month (1-12) | |
| exp_year | integer | | Expiration year (YYYY) | |
| cardholder_name | text | | Name on card | |
| billing_address_line1 | text | | Billing address | |
| billing_address_line2 | text | | Billing address line 2 | |
| billing_city | text | | Billing city | |
| billing_state | text | | Billing state | |
| billing_postal_code | text | | Billing ZIP | |
| billing_country | text | DEFAULT 'US' | Billing country | |
| bank_name | text | | Bank name (for ACH) | |
| account_type | text | | checking, savings (for ACH) | |
| is_default | boolean | DEFAULT false | Default payment method | |
| is_verified | boolean | DEFAULT false | Payment method verified | |
| is_active | boolean | DEFAULT true | Currently active | |
| expires_at | timestamptz | | When token expires | |
| last_used_at | timestamptz | | Last successful charge | |
| failure_count | integer | DEFAULT 0 | Consecutive failures | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |
| created_by | text | | Who created | |

**CHECK CONSTRAINTS:**
- token_type IN ('credit_card', 'debit_card', 'bank_account', 'ach')
- processor IN ('stripe', 'square', 'authorize_net', 'manual')
- card_brand IN ('visa', 'mastercard', 'amex', 'discover', 'jcb', 'diners', 'unionpay') OR card_brand IS NULL
- account_type IN ('checking', 'savings') OR account_type IS NULL
- exp_month BETWEEN 1 AND 12 OR exp_month IS NULL

**RLS POLICY:** Users can see their own tokens. Finance role can see all.

---

## 3. secure.access_credentials

**PURPOSE:** Stores credentials for external system integrations — API keys, OAuth tokens, service account passwords. All values are encrypted. Used by AI agents and automation systems to authenticate with external services.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| credential_id | text | NOT NULL, UNIQUE | Business ID: CRED-NNNNNN | N/A |
| credential_name | text | NOT NULL | Human-readable name | |
| system_name | text | NOT NULL | System: streamline, airbnb, vrbo, stripe, mailchimp, etc. | |
| credential_type | text | NOT NULL | Type: api_key, oauth_token, password, certificate | |
| environment | text | NOT NULL | Environment: production, staging, development | |
| encrypted_value | text | NOT NULL | Encrypted credential value | |
| encryption_key_id | text | NOT NULL | Reference to encryption key | |
| oauth_refresh_token | text | | Encrypted refresh token (for OAuth) | |
| oauth_expires_at | timestamptz | | OAuth token expiration | |
| associated_email | text | | Associated account email | |
| associated_account_id | text | | Associated account ID | |
| scopes | text[] | | OAuth scopes / permissions | |
| rate_limit | integer | | Requests per period allowed | |
| rate_limit_period | text | | Rate limit period: minute, hour, day | |
| last_used_at | timestamptz | | Last successful use | |
| last_rotated_at | timestamptz | | Last credential rotation | |
| rotation_due_at | timestamptz | | When rotation is due | |
| expires_at | timestamptz | | When credential expires | |
| is_active | boolean | DEFAULT true | Currently active | |
| failure_count | integer | DEFAULT 0 | Consecutive failures | |
| last_failure_reason | text | | Last failure message | |
| notes | text | | Internal notes | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |
| created_by | text | | Who created | |
| updated_by | text | | Who last updated | |

**CHECK CONSTRAINTS:**
- credential_type IN ('api_key', 'oauth_token', 'password', 'certificate', 'ssh_key', 'bearer_token')
- environment IN ('production', 'staging', 'development', 'test')

**UNIQUE CONSTRAINT:** (system_name, environment, credential_name) — One credential per system/env/name

**RLS POLICY:** Only system_admin role can access. Agents access via secure functions.

---

## 4. secure.audit_events

**PURPOSE:** Immutable security audit log for compliance and forensics. Tracks all security-relevant events: logins, permission changes, sensitive data access, configuration changes, and security incidents.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| audit_id | text | NOT NULL, UNIQUE | Business ID: AUD-NNNNNN | N/A |
| event_timestamp | timestamptz | NOT NULL, DEFAULT now() | When event occurred | |
| event_type | text | NOT NULL | Type: login, logout, permission_change, data_access, config_change, security_incident | |
| action_type | text | NOT NULL | Action: create, read, update, delete, export, grant, revoke | |
| severity | text | NOT NULL | Severity: info, warning, critical | |
| user_id | uuid | | User who performed action (no FK) | |
| user_email | text | | User email (denormalized for audit) | |
| user_role | text | | User's role at time of action | |
| ip_address | inet | | Source IP address | |
| user_agent | text | | Browser/client user agent | |
| session_id | text | | Session identifier | |
| entity_type | text | | Affected entity type | |
| entity_id | uuid | | Affected entity ID | |
| entity_name | text | | Entity name (denormalized) | |
| table_name | text | | Database table affected | |
| record_id | uuid | | Specific record ID | |
| old_values | jsonb | | Previous values (for updates) | |
| new_values | jsonb | | New values (for updates) | |
| description | text | NOT NULL | Human-readable description | |
| metadata | jsonb | | Additional context | |
| request_id | text | | API request ID | |
| success | boolean | NOT NULL | Action succeeded | |
| failure_reason | text | | Reason if failed | |
| risk_score | integer | | Calculated risk score (0-100) | |
| flagged_for_review | boolean | DEFAULT false | Needs security review | |
| reviewed_at | timestamptz | | When reviewed | |
| reviewed_by | text | | Who reviewed | |
| review_notes | text | | Review notes | |

**CHECK CONSTRAINTS:**
- event_type IN ('login', 'logout', 'permission_change', 'data_access', 'config_change', 'security_incident', 'api_access', 'export', 'bulk_operation')
- action_type IN ('create', 'read', 'update', 'delete', 'export', 'grant', 'revoke', 'login', 'logout', 'execute')
- severity IN ('info', 'warning', 'critical')

**RLS POLICY:** INSERT only (no UPDATE/DELETE). Only security_admin can SELECT.

**IMPORTANT:** This table is append-only. Updates and deletes are prohibited.

---

## 5. secure.data_access_log

**PURPOSE:** Tracks every access to sensitive data for compliance (SOC2, GDPR, etc.). Records who accessed what data, when, and why. Separate from audit_events for high-volume access logging.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| log_id | text | NOT NULL, UNIQUE | Business ID: DAL-NNNNNN | N/A |
| access_timestamp | timestamptz | NOT NULL, DEFAULT now() | When accessed | |
| accessed_by | uuid | NOT NULL | User/agent who accessed (no FK) | |
| accessor_type | text | NOT NULL | Type: user, agent, system, api | |
| accessor_name | text | | Name (denormalized) | |
| accessor_role | text | | Role at time of access | |
| table_accessed | text | NOT NULL | Schema.table accessed | |
| record_id | uuid | | Specific record ID | |
| record_business_id | text | | Business ID of record | |
| columns_accessed | text[] | | Specific columns viewed | |
| access_type | text | NOT NULL | Type: view, export, copy, print | |
| access_reason | text | | Business justification | |
| access_context | text | | Context: reservation_lookup, report_generation, etc. | |
| data_classification | text | | Classification: public, internal, confidential, restricted | |
| record_count | integer | DEFAULT 1 | Number of records accessed | |
| query_hash | text | | Hash of query (for pattern analysis) | |
| ip_address | inet | | Source IP | |
| session_id | text | | Session identifier | |
| request_id | text | | API request ID | |
| duration_ms | integer | | Query duration | |
| metadata | jsonb | | Additional context | |

**CHECK CONSTRAINTS:**
- accessor_type IN ('user', 'agent', 'system', 'api', 'scheduled_job')
- access_type IN ('view', 'export', 'copy', 'print', 'api_read', 'report')
- data_classification IN ('public', 'internal', 'confidential', 'restricted')

**RLS POLICY:** INSERT only (no UPDATE/DELETE). Only security_admin can SELECT.

**IMPORTANT:** This table is append-only. Updates and deletes are prohibited.

---

# SECURITY IMPLEMENTATION NOTES

## Row Level Security (RLS)

All tables in the secure schema MUST have RLS enabled:

```sql
ALTER TABLE secure.pii_vault ENABLE ROW LEVEL SECURITY;
ALTER TABLE secure.payment_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE secure.access_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE secure.audit_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE secure.data_access_log ENABLE ROW LEVEL SECURITY;
```

## Access Roles

| Role | pii_vault | payment_tokens | access_credentials | audit_events | data_access_log |
|------|-----------|----------------|-------------------|--------------|-----------------|
| security_admin | FULL | FULL | FULL | SELECT | SELECT |
| finance_admin | — | SELECT | — | — | — |
| app_service | — | SELECT (own) | via function | INSERT | INSERT |
| ai_agent | — | — | via function | INSERT | INSERT |
| All others | — | — | — | — | — |

## Encryption Requirements

1. **pii_vault.encrypted_value** — AES-256-GCM encryption
2. **access_credentials.encrypted_value** — AES-256-GCM encryption
3. **access_credentials.oauth_refresh_token** — AES-256-GCM encryption

Encryption keys stored in external key management system (AWS KMS, Vault, etc.)

## Audit Triggers

Automatic audit logging triggers should be created for:
- All INSERT/UPDATE/DELETE on secure schema tables
- All SELECT on pii_vault and access_credentials
- All failed authentication attempts

## Data Retention

| Table | Retention Policy |
|-------|-----------------|
| pii_vault | Until entity deletion + 7 years |
| payment_tokens | Until token expiration or deactivation |
| access_credentials | Until credential rotation |
| audit_events | 7 years (compliance requirement) |
| data_access_log | 3 years |

---

# CROSS-SCHEMA DEPENDENCIES

## Secure → Other Schemas

**None by design.** The secure schema does not have foreign keys to other schemas.

## Other Schemas → Secure

**None by design.** Other schemas should not directly reference secure tables.

## Integration Pattern

Access to secure data is done through:
1. **Secure functions** — `secure.get_pii()`, `secure.get_credential()`
2. **ID references** — Store entity_id without FK constraint
3. **Audit logging** — All access logged to data_access_log

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-09  
**UUIDv7 Migration:** V4.1 Schema Specification  
**Total Tables:** 5
