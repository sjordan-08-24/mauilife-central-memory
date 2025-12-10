# Portal System - Complete Table Inventory

**Date:** 20251206  
**System:** Portal Access & Authentication System  
**Schemas:** portal  
**Tables:** 6 (6 portal)  
**Primary Key:** UUID (globally unique via gen_random_uuid())

---

# TABLE OF CONTENTS

1. [Foreign Key Relationship Matrix](#foreign-key-relationship-matrix)
2. [Business ID Cross-Reference](#business-id-cross-reference)
3. [Index Coverage Summary](#index-coverage-summary)
4. [Table Specifications](#table-specifications)
   - 4.1 [portal.users](#portalusers)
   - 4.2 [portal.sessions](#portalsessions)
   - 4.3 [portal.roles](#portalroles)
   - 4.4 [portal.permissions](#portalpermissions)
   - 4.5 [portal.user_roles](#portaluser_roles)
   - 4.6 [portal.preferences](#portalpreferences)
5. [Business Logic](#business-logic)
6. [Common Usage Patterns](#common-usage-patterns)
7. [Sample Queries](#sample-queries)
8. [Migration Information](#migration-information)

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
ops.contacts (External - Contact Hub)
└─► portal.users (contact_id) [SET NULL]

portal.users (Core User Accounts)
├─► portal.sessions (user_id) [CASCADE DELETE]
├─► portal.user_roles (user_id) [CASCADE DELETE]
└─► portal.preferences (user_id) [CASCADE DELETE]

portal.roles (Role Definitions)
├─► portal.permissions (role_id) [CASCADE DELETE]
└─► portal.user_roles (role_id) [CASCADE DELETE]

portal.sessions
└─► portal.users (user_id) [CASCADE DELETE]

portal.permissions
└─► portal.roles (role_id) [CASCADE DELETE]

portal.user_roles
├─► portal.users (user_id) [CASCADE DELETE]
└─► portal.roles (role_id) [CASCADE DELETE]

portal.preferences
└─► portal.users (user_id) [CASCADE DELETE]
```

**LEGEND:**
- [CASCADE DELETE] - Child records deleted when parent deleted
- [SET NULL] - FK set to NULL when parent deleted
- ops.contacts is external to portal schema (cross-schema dependency)

---

# BUSINESS ID CROSS-REFERENCE

## Portal Business IDs

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| portal.users | USR-NNNNNN | USR-010001 | 10001 | Guest Portal, Owner Portal, Team Portal, Mobile Apps, API Authentication |
| portal.sessions | N/A (UUID only) | N/A | N/A | Session Management, API Gateway |
| portal.roles | {role_code} | HOMEOWNER | N/A | Permission System, API Authorization |
| portal.permissions | N/A (composite) | N/A | N/A | Authorization Engine |
| portal.user_roles | N/A (junction) | N/A | N/A | Role Assignment System |
| portal.preferences | N/A (composite) | N/A | N/A | User Settings UI |

## Cross-System Business ID Dependencies

| External System | References These Business IDs |
|----------------|-------------------------------|
| Guest Portal | user_id (USR-NNNNNN), role_code |
| Owner Portal | user_id (USR-NNNNNN), role_code |
| Team Portal | user_id (USR-NNNNNN), role_code |
| Mobile Apps (iOS/Android) | user_id (USR-NNNNNN), session_token |
| API Gateway | session_token, refresh_token |
| Audit System | user_id (USR-NNNNNN), role_code |
| ops.contacts | contact_id (CON-{TYPE}-NNNNNN) |

---

# INDEX COVERAGE SUMMARY

## Portal Indexes

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| portal.users | pk_users | id (PK) | Primary key lookup |
| | idx_users_user_id | user_id (UNIQUE) | Business ID lookup |
| | idx_users_email | email (UNIQUE) | Login email lookup |
| | idx_users_contact_id | contact_id | Contact hub lookup |
| | idx_users_user_type | user_type | Filter by user type |
| | idx_users_status | status | Filter active users |
| | idx_users_active | status WHERE status = 'active' | Active users only (partial) |
| portal.sessions | pk_sessions | id (PK) | Primary key lookup |
| | idx_sessions_token | session_token (UNIQUE) | Token validation |
| | idx_sessions_refresh | refresh_token | Token refresh |
| | idx_sessions_user_id | user_id | User's sessions |
| | idx_sessions_active | user_id, is_active WHERE is_active = true | Active sessions (partial) |
| | idx_sessions_expires | expires_at | Session cleanup |
| portal.roles | pk_roles | id (PK) | Primary key lookup |
| | idx_roles_code | role_code (UNIQUE) | Role lookup by code |
| | idx_roles_type | role_type | Filter by role type |
| portal.permissions | pk_permissions | id (PK) | Primary key lookup |
| | idx_permissions_role | role_id | Permissions by role |
| | idx_permissions_resource | resource, action | Resource access check |
| | uq_permissions_role_code | role_id, permission_code (UNIQUE) | Prevent duplicate permissions |
| portal.user_roles | pk_user_roles | id (PK) | Primary key lookup |
| | idx_user_roles_user | user_id | User's roles |
| | idx_user_roles_role | role_id | Users in role |
| | uq_user_roles | user_id, role_id (UNIQUE) | One assignment per user-role |
| | idx_user_roles_active | user_id, is_active WHERE is_active = true | Active assignments (partial) |
| portal.preferences | pk_preferences | id (PK) | Primary key lookup |
| | idx_preferences_user | user_id | User's preferences |
| | uq_preferences | user_id, preference_key (UNIQUE) | One value per key per user |

---

# TABLE SPECIFICATIONS

## portal.users

**PURPOSE:** Master table for all portal user accounts. Stores authentication credentials, account status, and security settings. Links to ops.contacts for unified contact information while maintaining portal-specific authentication data. Supports multiple user types (guest, homeowner, team, admin) with different access levels.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT gen_random_uuid() | UUID primary key (globally unique) |
| user_id | text | NOT NULL, UNIQUE | Business ID: USR-NNNNNN (auto-generated from portal.user_seq) |
| contact_id | uuid | FK → ops.contacts(id) | Link to unified contact hub (NULL if no contact record exists) |
| email | text | NOT NULL, UNIQUE | Login email address - must be unique across all users |
| password_hash | text | | Bcrypt hashed password (NULL for SSO-only users) |
| user_type | text | NOT NULL, CHECK | User category: guest, homeowner, team, admin |
| status | text | DEFAULT 'pending', CHECK | Account status: pending, active, suspended, deactivated |
| email_verified | boolean | DEFAULT false | Has user verified their email address? |
| email_verified_at | timestamptz | | Timestamp when email was verified |
| mfa_enabled | boolean | DEFAULT false | Is multi-factor authentication enabled? |
| mfa_secret | text | | TOTP secret for MFA (encrypted) |
| last_login_at | timestamptz | | Timestamp of most recent successful login |
| last_login_ip | inet | | IP address of most recent login |
| failed_login_attempts | integer | DEFAULT 0 | Consecutive failed login attempts |
| locked_until | timestamptz | | Account locked until this time (NULL = not locked) |
| password_changed_at | timestamptz | | When password was last changed |
| must_change_password | boolean | DEFAULT false | Force password change on next login |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp (trigger-maintained) |

**CHECK CONSTRAINTS:**
- user_type IN ('guest', 'homeowner', 'team', 'admin')
- status IN ('pending', 'active', 'suspended', 'deactivated')
- failed_login_attempts >= 0

**FK CASCADE ACTIONS:**
- contact_id: ON DELETE SET NULL, ON UPDATE CASCADE (user account persists if contact deleted)

**SAMPLE DATA:**
```sql
-- Guest user who booked through website
INSERT INTO portal.users (
    user_id, contact_id, email, password_hash, user_type, status,
    email_verified, email_verified_at
)
VALUES (
    'USR-010001',
    (SELECT id FROM ops.contacts WHERE contact_id = 'CON-GST-010042'),
    'john.smith@email.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4BeyWC0mCEW3JVGK',  -- hashed 'password123'
    'guest',
    'active',
    true,
    '2025-01-15 14:30:00-10'
);
-- Guest with verified email, can access booking history and itineraries

-- Homeowner with MFA enabled
INSERT INTO portal.users (
    user_id, contact_id, email, password_hash, user_type, status,
    email_verified, email_verified_at, mfa_enabled, mfa_secret
)
VALUES (
    'USR-010002',
    (SELECT id FROM ops.contacts WHERE contact_id = 'CON-OWN-010015'),
    'owner.williams@email.com',
    '$2b$12$ABC123...hashed...',
    'homeowner',
    'active',
    true,
    '2024-06-01 09:00:00-10',
    true,
    'JBSWY3DPEHPK3PXP'  -- TOTP secret
);
-- Homeowner with enhanced security, can view statements and property performance

-- Team member with pending email verification
INSERT INTO portal.users (
    user_id, contact_id, email, password_hash, user_type, status,
    email_verified, must_change_password
)
VALUES (
    'USR-010003',
    (SELECT id FROM ops.contacts WHERE contact_id = 'CON-TM-010089'),
    'newteam@mauiliferentals.com',
    '$2b$12$TEMP...hashed...',
    'team',
    'pending',
    false,
    true
);
-- New team member, must verify email and change temp password

-- Admin user with recent login
INSERT INTO portal.users (
    user_id, contact_id, email, password_hash, user_type, status,
    email_verified, email_verified_at, mfa_enabled, mfa_secret,
    last_login_at, last_login_ip
)
VALUES (
    'USR-010004',
    (SELECT id FROM ops.contacts WHERE contact_id = 'CON-TM-010001'),
    'admin@mauiliferentals.com',
    '$2b$12$ADMIN...hashed...',
    'admin',
    'active',
    true,
    '2024-01-01 00:00:00-10',
    true,
    'ADMINTOTP3PXP',
    '2025-12-06 08:00:00-10',
    '192.168.1.100'
);
-- Super admin with full system access
```

---

## portal.sessions

**PURPOSE:** Tracks active and historical user sessions. Stores session tokens for authentication, refresh tokens for token renewal, and metadata for security auditing. Sessions are automatically cleaned up after expiration. Used by API gateway for request authentication.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, UNIQUE, DEFAULT gen_random_uuid() | UUID primary key (globally unique) |
| user_id | uuid | FK → portal.users(id), NOT NULL | User who owns this session |
| session_token | text | NOT NULL, UNIQUE | JWT or opaque session token for API authentication |
| refresh_token | text | | Token used to obtain new session token |
| ip_address | inet | | IP address where session was created |
| user_agent | text | | Browser/client user agent string |
| device_type | text | | Device category: desktop, mobile, tablet, api_client |
| is_active | boolean | DEFAULT true | Is session currently valid? |
| expires_at | timestamptz | NOT NULL | When session token expires |
| last_activity_at | timestamptz | | Timestamp of most recent activity |
| created_at | timestamptz | DEFAULT now() | Session creation timestamp |

**CHECK CONSTRAINTS:**
- device_type IN ('desktop', 'mobile', 'tablet', 'api_client') OR device_type IS NULL

**FK CASCADE ACTIONS:**
- user_id: ON DELETE CASCADE, ON UPDATE CASCADE (delete sessions when user deleted)

**SAMPLE DATA:**
```sql
-- Active desktop session for guest user
INSERT INTO portal.sessions (
    user_id, session_token, refresh_token, ip_address,
    user_agent, device_type, is_active, expires_at, last_activity_at
)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010001'),
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiVVNSLTAxMDAwMSJ9.abc123',
    'refresh_eyJhbGciOiJIUzI1NiJ9.xyz789',
    '98.234.56.78',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120.0.0.0',
    'desktop',
    true,
    NOW() + INTERVAL '24 hours',
    NOW()
);
-- Guest viewing their upcoming reservation on laptop

-- Mobile session for homeowner
INSERT INTO portal.sessions (
    user_id, session_token, refresh_token, ip_address,
    user_agent, device_type, is_active, expires_at, last_activity_at
)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010002'),
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiVVNSLTAxMDAwMiJ9.def456',
    'refresh_owner_456',
    '72.100.200.50',
    'MLVOwnerApp/2.1.0 (iPhone; iOS 17.2)',
    'mobile',
    true,
    NOW() + INTERVAL '7 days',
    NOW() - INTERVAL '2 hours'
);
-- Homeowner checking property stats on mobile app

-- Expired session (for audit trail)
INSERT INTO portal.sessions (
    user_id, session_token, ip_address,
    user_agent, device_type, is_active, expires_at, last_activity_at, created_at
)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010001'),
    'expired_session_token_abc',
    '98.234.56.78',
    'Mozilla/5.0 Chrome/119.0.0.0',
    'desktop',
    false,
    '2025-12-05 10:00:00-10',  -- Expired yesterday
    '2025-12-04 16:30:00-10',
    '2025-12-04 08:00:00-10'
);
-- Historical session record for security auditing
```

---

## portal.roles

**PURPOSE:** Defines available roles in the portal system. Roles represent sets of permissions that can be assigned to users. Supports system roles (predefined, cannot be deleted) and custom roles. Links to permissions table to define what each role can do.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, AUTO_INCREMENT | Internal numeric ID |
| database_id | uuid | NOT NULL, UNIQUE, DEFAULT gen_random_uuid() | System UUID for external references |
| role_code | text | NOT NULL, UNIQUE | Short code for role: GUEST, HOMEOWNER, TEAM_MEMBER, etc. |
| role_name | text | NOT NULL | Display name: "Guest", "Homeowner", "Team Member" |
| description | text | | Detailed description of role purpose and capabilities |
| role_type | text | | Category: guest, homeowner, team, admin |
| is_system_role | boolean | DEFAULT false | System roles cannot be deleted |
| is_active | boolean | DEFAULT true | Can this role be assigned to users? |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**CHECK CONSTRAINTS:**
- role_type IN ('guest', 'homeowner', 'team', 'admin') OR role_type IS NULL

**SAMPLE DATA:**
```sql
-- System roles (seed data - inserted during migration)

-- Guest role - basic access for vacation renters
INSERT INTO portal.roles (role_code, role_name, description, role_type, is_system_role, is_active)
VALUES (
    'GUEST',
    'Guest',
    'Standard guest access. Can view reservations, itineraries, and property information for their bookings.',
    'guest',
    true,
    true
);

-- Homeowner role - property owner access
INSERT INTO portal.roles (role_code, role_name, description, role_type, is_system_role, is_active)
VALUES (
    'HOMEOWNER',
    'Homeowner',
    'Property owner access. Can view statements, occupancy reports, maintenance history, and property performance metrics.',
    'homeowner',
    true,
    true
);

-- Team Member role - basic staff access
INSERT INTO portal.roles (role_code, role_name, description, role_type, is_system_role, is_active)
VALUES (
    'TEAM_MEMBER',
    'Team Member',
    'Standard team member access. Can view assigned tasks, schedules, and property information for assigned properties.',
    'team',
    true,
    true
);

-- Team Lead role - supervisory access
INSERT INTO portal.roles (role_code, role_name, description, role_type, is_system_role, is_active)
VALUES (
    'TEAM_LEAD',
    'Team Lead',
    'Team lead access. All team member permissions plus ability to assign tasks, approve time, and view team reports.',
    'team',
    true,
    true
);

-- Manager role - departmental access
INSERT INTO portal.roles (role_code, role_name, description, role_type, is_system_role, is_active)
VALUES (
    'MANAGER',
    'Manager',
    'Management access. All team lead permissions plus financial reports, owner communications, and department metrics.',
    'team',
    true,
    true
);

-- Admin role - administrative access
INSERT INTO portal.roles (role_code, role_name, description, role_type, is_system_role, is_active)
VALUES (
    'ADMIN',
    'Administrator',
    'Administrative access. Can manage users, roles, system settings, and view all operational data.',
    'admin',
    true,
    true
);

-- Super Admin role - full system access
INSERT INTO portal.roles (role_code, role_name, description, role_type, is_system_role, is_active)
VALUES (
    'SUPER_ADMIN',
    'Super Administrator',
    'Full system access. All admin permissions plus ability to manage other admins and system configuration.',
    'admin',
    true,
    true
);
```

---

## portal.permissions

**PURPOSE:** Defines granular permissions assigned to each role. Uses resource/action/scope model to control access. Resource is what is being accessed (reservations, properties, statements), action is what can be done (create, read, update, delete), and scope limits visibility (own records, team records, all records).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, AUTO_INCREMENT | Internal numeric ID |
| role_id | bigint | FK → portal.roles(id), NOT NULL | Role this permission belongs to |
| permission_code | text | NOT NULL | Unique identifier: reservations.read, properties.update |
| resource | text | NOT NULL | What is being accessed: reservations, properties, statements |
| action | text | NOT NULL, CHECK | Operation allowed: create, read, update, delete |
| scope | text | DEFAULT 'own', CHECK | Visibility limit: own, team, all |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |

**UNIQUE CONSTRAINT:** (role_id, permission_code) - One permission code per role

**CHECK CONSTRAINTS:**
- action IN ('create', 'read', 'update', 'delete')
- scope IN ('own', 'team', 'all')

**FK CASCADE ACTIONS:**
- role_id: ON DELETE CASCADE, ON UPDATE CASCADE (delete permissions when role deleted)

**SAMPLE DATA:**
```sql
-- Guest permissions (limited to own reservations)
INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'reservations.read', 'reservations', 'read', 'own'
FROM portal.roles WHERE role_code = 'GUEST';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'itineraries.read', 'itineraries', 'read', 'own'
FROM portal.roles WHERE role_code = 'GUEST';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'properties.read', 'properties', 'read', 'own'
FROM portal.roles WHERE role_code = 'GUEST';
-- Guests can only see info for properties they've booked

-- Homeowner permissions (own properties only)
INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'statements.read', 'statements', 'read', 'own'
FROM portal.roles WHERE role_code = 'HOMEOWNER';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'properties.read', 'properties', 'read', 'own'
FROM portal.roles WHERE role_code = 'HOMEOWNER';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'reservations.read', 'reservations', 'read', 'own'
FROM portal.roles WHERE role_code = 'HOMEOWNER';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'maintenance.read', 'maintenance', 'read', 'own'
FROM portal.roles WHERE role_code = 'HOMEOWNER';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'maintenance.create', 'maintenance', 'create', 'own'
FROM portal.roles WHERE role_code = 'HOMEOWNER';
-- Homeowners can submit maintenance requests for their properties

-- Team Member permissions (assigned properties)
INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'tasks.read', 'tasks', 'read', 'own'
FROM portal.roles WHERE role_code = 'TEAM_MEMBER';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'tasks.update', 'tasks', 'update', 'own'
FROM portal.roles WHERE role_code = 'TEAM_MEMBER';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'properties.read', 'properties', 'read', 'team'
FROM portal.roles WHERE role_code = 'TEAM_MEMBER';
-- Team members can see properties their team manages

-- Admin permissions (all resources)
INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'users.read', 'users', 'read', 'all'
FROM portal.roles WHERE role_code = 'ADMIN';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'users.create', 'users', 'create', 'all'
FROM portal.roles WHERE role_code = 'ADMIN';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'users.update', 'users', 'update', 'all'
FROM portal.roles WHERE role_code = 'ADMIN';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'roles.read', 'roles', 'read', 'all'
FROM portal.roles WHERE role_code = 'ADMIN';

INSERT INTO portal.permissions (role_id, permission_code, resource, action, scope)
SELECT id, 'roles.update', 'roles', 'update', 'all'
FROM portal.roles WHERE role_code = 'ADMIN';
-- Admins can manage users but not delete system roles
```

---

## portal.user_roles

**PURPOSE:** Junction table linking users to roles. Supports multiple roles per user, role expiration, and audit trail of who granted the role. When a user logs in, their effective permissions are calculated by combining all active role assignments.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, AUTO_INCREMENT | Internal numeric ID |
| user_id | uuid | FK → portal.users(id), NOT NULL | User receiving the role |
| role_id | bigint | FK → portal.roles(id), NOT NULL | Role being assigned |
| granted_by | text | | User ID or system identifier that granted this role |
| granted_at | timestamptz | DEFAULT now() | When role was assigned |
| expires_at | timestamptz | | When role assignment expires (NULL = permanent) |
| is_active | boolean | DEFAULT true | Is this assignment currently active? |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |

**UNIQUE CONSTRAINT:** (user_id, role_id) - One assignment per user-role pair

**FK CASCADE ACTIONS:**
- user_id: ON DELETE CASCADE, ON UPDATE CASCADE (delete assignments when user deleted)
- role_id: ON DELETE CASCADE, ON UPDATE CASCADE (delete assignments when role deleted)

**SAMPLE DATA:**
```sql
-- Assign Guest role to guest user (permanent)
INSERT INTO portal.user_roles (user_id, role_id, granted_by, granted_at, is_active)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010001'),
    (SELECT id FROM portal.roles WHERE role_code = 'GUEST'),
    'SYSTEM',
    '2025-01-15 14:30:00-10',
    true
);
-- Automatically assigned when guest account created

-- Assign Homeowner role to homeowner user (permanent)
INSERT INTO portal.user_roles (user_id, role_id, granted_by, granted_at, is_active)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010002'),
    (SELECT id FROM portal.roles WHERE role_code = 'HOMEOWNER'),
    'USR-010004',  -- Admin who set up account
    '2024-06-01 09:00:00-10',
    true
);
-- Assigned by admin during homeowner onboarding

-- Assign Team Member role to team user
INSERT INTO portal.user_roles (user_id, role_id, granted_by, granted_at, is_active)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010003'),
    (SELECT id FROM portal.roles WHERE role_code = 'TEAM_MEMBER'),
    'USR-010004',
    NOW(),
    true
);

-- Admin with multiple roles (Admin + Super Admin)
INSERT INTO portal.user_roles (user_id, role_id, granted_by, granted_at, is_active)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010004'),
    (SELECT id FROM portal.roles WHERE role_code = 'ADMIN'),
    'SYSTEM',
    '2024-01-01 00:00:00-10',
    true
);

INSERT INTO portal.user_roles (user_id, role_id, granted_by, granted_at, is_active)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010004'),
    (SELECT id FROM portal.roles WHERE role_code = 'SUPER_ADMIN'),
    'SYSTEM',
    '2024-01-01 00:00:00-10',
    true
);
-- Admin has both roles for full system access

-- Temporary elevated access (expires after 30 days)
INSERT INTO portal.user_roles (user_id, role_id, granted_by, granted_at, expires_at, is_active)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010003'),
    (SELECT id FROM portal.roles WHERE role_code = 'TEAM_LEAD'),
    'USR-010004',
    NOW(),
    NOW() + INTERVAL '30 days',
    true
);
-- Team member temporarily promoted to cover for vacationing team lead
```

---

## portal.preferences

**PURPOSE:** Stores user-specific preferences and settings. Key-value structure allows flexible storage of any preference type. Common uses include notification settings, display preferences, and UI customizations. Each preference has a type hint for proper parsing.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, AUTO_INCREMENT | Internal numeric ID |
| user_id | uuid | FK → portal.users(id), NOT NULL | User who owns this preference |
| preference_key | text | NOT NULL | Preference identifier: notification.email, display.theme |
| preference_value | text | | Stored value (may need type conversion based on preference_type) |
| preference_type | text | | Data type hint: string, boolean, integer, json |
| created_at | timestamptz | DEFAULT now() | Record creation timestamp |
| updated_at | timestamptz | DEFAULT now() | Last update timestamp |

**UNIQUE CONSTRAINT:** (user_id, preference_key) - One value per key per user

**FK CASCADE ACTIONS:**
- user_id: ON DELETE CASCADE, ON UPDATE CASCADE (delete preferences when user deleted)

**SAMPLE DATA:**
```sql
-- Guest notification preferences
INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010001'),
    'notification.email.booking_confirmation',
    'true',
    'boolean'
);

INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010001'),
    'notification.sms.check_in_reminder',
    'true',
    'boolean'
);

INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010001'),
    'display.timezone',
    'Pacific/Honolulu',
    'string'
);

-- Homeowner preferences
INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010002'),
    'notification.email.monthly_statement',
    'true',
    'boolean'
);

INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010002'),
    'notification.email.maintenance_alert',
    'true',
    'boolean'
);

INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010002'),
    'statement.delivery_method',
    'email',
    'string'
);

INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010002'),
    'display.dashboard_widgets',
    '["occupancy_chart", "revenue_summary", "upcoming_reservations", "recent_reviews"]',
    'json'
);
-- Homeowner customized their dashboard layout

-- Admin preferences
INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010004'),
    'display.theme',
    'dark',
    'string'
);

INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010004'),
    'display.items_per_page',
    '50',
    'integer'
);

INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010004'),
    'notification.email.system_alerts',
    'true',
    'boolean'
);
```

---

# BUSINESS LOGIC

## Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AUTHENTICATION FLOW                                  │
└─────────────────────────────────────────────────────────────────────────────┘

1. LOGIN REQUEST
   ├── Receive email + password
   ├── Look up user by email
   └── Check status = 'active'
       ├── If 'pending' → "Please verify your email"
       ├── If 'suspended' → "Account suspended, contact support"
       ├── If 'deactivated' → "Account not found"
       └── If 'active' → Continue

2. ACCOUNT LOCK CHECK
   ├── Check locked_until > NOW()
   │   └── If locked → "Account locked until {time}"
   └── If not locked → Continue

3. PASSWORD VERIFICATION
   ├── bcrypt.compare(password, password_hash)
   ├── If FAIL:
   │   ├── Increment failed_login_attempts
   │   ├── If failed_login_attempts >= 5:
   │   │   └── Set locked_until = NOW() + 30 minutes
   │   └── Return "Invalid credentials"
   └── If PASS:
       ├── Reset failed_login_attempts = 0
       └── Continue

4. MFA CHECK (if mfa_enabled = true)
   ├── Prompt for TOTP code
   ├── Verify against mfa_secret
   └── If FAIL → "Invalid MFA code"

5. PASSWORD EXPIRY CHECK
   ├── If must_change_password = true:
   │   └── Redirect to password change
   └── Continue

6. CREATE SESSION
   ├── Generate session_token (JWT)
   ├── Generate refresh_token
   ├── Insert into portal.sessions
   ├── Update last_login_at, last_login_ip
   └── Return tokens to client
```

## Permission Resolution

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      PERMISSION RESOLUTION ORDER                             │
└─────────────────────────────────────────────────────────────────────────────┘

When checking: "Can user X perform action Y on resource Z?"

1. GET USER'S ACTIVE ROLES
   SELECT DISTINCT r.role_code
   FROM portal.user_roles ur
   JOIN portal.roles r ON ur.role_id = r.id
   WHERE ur.user_id = {user_uuid}
     AND ur.is_active = true
     AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
     AND r.is_active = true;

2. GET ALL PERMISSIONS FOR THOSE ROLES
   SELECT p.permission_code, p.resource, p.action, p.scope
   FROM portal.permissions p
   JOIN portal.user_roles ur ON p.role_id = ur.role_id
   WHERE ur.user_id = {user_uuid}
     AND ur.is_active = true
     AND (ur.expires_at IS NULL OR ur.expires_at > NOW());

3. SCOPE RESOLUTION
   For the requested resource/action, find matching permission:
   - 'all'  → User can access ANY record of this resource
   - 'team' → User can access records owned by their team
   - 'own'  → User can only access their own records

4. APPLY SCOPE FILTER
   If scope = 'own':
     WHERE owner_id = {user_uuid}
   If scope = 'team':
     WHERE team_id IN (SELECT team_id FROM user's teams)
   If scope = 'all':
     No filter applied
```

## User Type Hierarchy

```
USER TYPE HIERARCHY (implicit permissions)

SUPER_ADMIN
    └── All permissions with scope='all'
    └── Can manage other admins
    └── Can modify system roles

ADMIN
    └── Can manage users (except super_admins)
    └── Can view all operational data
    └── Cannot delete system roles

MANAGER
    └── All TEAM_LEAD permissions
    └── Financial reports access
    └── Owner communication access

TEAM_LEAD
    └── All TEAM_MEMBER permissions
    └── Task assignment
    └── Time approval
    └── Team reports

TEAM_MEMBER
    └── View assigned tasks
    └── Update own tasks
    └── View assigned properties

HOMEOWNER
    └── Own properties only
    └── Statements and reports
    └── Maintenance requests

GUEST
    └── Own reservations only
    └── Itineraries for bookings
    └── Property info for bookings
```

## Session Management Rules

1. **Session Duration**
   - Default: 24 hours for web
   - Mobile apps: 7 days
   - API clients: 1 hour (use refresh tokens)

2. **Concurrent Sessions**
   - Guests: Unlimited
   - Homeowners: Max 5 active
   - Team: Max 3 active
   - Admin: Max 2 active (security)

3. **Session Invalidation**
   - Logout: Mark is_active = false
   - Password change: Invalidate all sessions
   - Account suspension: Invalidate all sessions
   - Security event: Admin can invalidate all user sessions

---

# COMMON USAGE PATTERNS

## Pattern 1: Authenticate User and Create Session

```sql
-- Step 1: Look up user and verify status
WITH user_lookup AS (
    SELECT 
        id,
        user_id,
        password_hash,
        user_type,
        status,
        email_verified,
        mfa_enabled,
        mfa_secret,
        failed_login_attempts,
        locked_until,
        must_change_password
    FROM portal.users
    WHERE email = 'john.smith@email.com'
      AND status = 'active'
)
SELECT * FROM user_lookup;

-- Step 2: After password verification succeeds, create session
INSERT INTO portal.sessions (
    user_id,
    session_token,
    refresh_token,
    ip_address,
    user_agent,
    device_type,
    expires_at
)
SELECT 
    id,
    'generated_jwt_token_here',
    'generated_refresh_token_here',
    '98.234.56.78'::inet,
    'Mozilla/5.0 Chrome/120.0.0.0',
    'desktop',
    NOW() + INTERVAL '24 hours'
FROM portal.users
WHERE user_id = 'USR-010001'
RETURNING *;

-- Step 3: Update login tracking
UPDATE portal.users
SET 
    last_login_at = NOW(),
    last_login_ip = '98.234.56.78'::inet,
    failed_login_attempts = 0,
    updated_at = NOW()
WHERE user_id = 'USR-010001';
```

## Pattern 2: Check User Permissions

```sql
-- Get all effective permissions for a user
SELECT DISTINCT
    u.user_id,
    r.role_code,
    p.permission_code,
    p.resource,
    p.action,
    p.scope
FROM portal.users u
JOIN portal.user_roles ur ON u.id = ur.user_id
JOIN portal.roles r ON ur.role_id = r.id
JOIN portal.permissions p ON r.id = p.role_id
WHERE u.user_id = 'USR-010002'
  AND ur.is_active = true
  AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
  AND r.is_active = true
ORDER BY r.role_code, p.resource, p.action;

-- Check specific permission
SELECT EXISTS (
    SELECT 1
    FROM portal.users u
    JOIN portal.user_roles ur ON u.id = ur.user_id
    JOIN portal.roles r ON ur.role_id = r.id
    JOIN portal.permissions p ON r.id = p.role_id
    WHERE u.user_id = 'USR-010002'
      AND p.resource = 'statements'
      AND p.action = 'read'
      AND ur.is_active = true
      AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
) AS has_permission;
```

## Pattern 3: Validate Session Token

```sql
-- Check if session is valid and get user info
SELECT 
    s.id AS session_id,
    s.user_id AS session_user_uuid,
    s.expires_at,
    s.is_active,
    u.user_id,
    u.email,
    u.user_type,
    u.status AS user_status
FROM portal.sessions s
JOIN portal.users u ON s.user_id = u.id
WHERE s.session_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  AND s.is_active = true
  AND s.expires_at > NOW()
  AND u.status = 'active';

-- Update last activity timestamp
UPDATE portal.sessions
SET last_activity_at = NOW()
WHERE session_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  AND is_active = true;
```

## Pattern 4: Get User Preferences

```sql
-- Get all preferences for a user
SELECT 
    preference_key,
    preference_value,
    preference_type
FROM portal.preferences
WHERE user_id = (SELECT id FROM portal.users WHERE user_id = 'USR-010001')
ORDER BY preference_key;

-- Get specific preference with default
SELECT COALESCE(
    (SELECT preference_value 
     FROM portal.preferences 
     WHERE user_id = (SELECT id FROM portal.users WHERE user_id = 'USR-010001')
       AND preference_key = 'display.theme'),
    'light'  -- default value
) AS theme;

-- Upsert preference (insert or update)
INSERT INTO portal.preferences (user_id, preference_key, preference_value, preference_type)
VALUES (
    (SELECT id FROM portal.users WHERE user_id = 'USR-010001'),
    'display.theme',
    'dark',
    'string'
)
ON CONFLICT (user_id, preference_key) 
DO UPDATE SET 
    preference_value = EXCLUDED.preference_value,
    updated_at = NOW();
```

## Pattern 5: Assign Role to User

```sql
-- Assign new role (with audit)
INSERT INTO portal.user_roles (user_id, role_id, granted_by, granted_at)
SELECT 
    u.id,
    r.id,
    'USR-010004',  -- Admin who is granting
    NOW()
FROM portal.users u
CROSS JOIN portal.roles r
WHERE u.user_id = 'USR-010003'
  AND r.role_code = 'TEAM_LEAD'
  AND NOT EXISTS (
      -- Prevent duplicate assignment
      SELECT 1 FROM portal.user_roles ur2
      WHERE ur2.user_id = u.id AND ur2.role_id = r.id
  )
RETURNING *;

-- Assign temporary elevated role
INSERT INTO portal.user_roles (user_id, role_id, granted_by, granted_at, expires_at)
SELECT 
    u.id,
    r.id,
    'USR-010004',
    NOW(),
    NOW() + INTERVAL '7 days'
FROM portal.users u
CROSS JOIN portal.roles r
WHERE u.user_id = 'USR-010003'
  AND r.role_code = 'MANAGER'
RETURNING *;
```

## Pattern 6: Logout and Session Cleanup

```sql
-- Logout single session
UPDATE portal.sessions
SET is_active = false
WHERE session_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
RETURNING *;

-- Logout all sessions for user (e.g., after password change)
UPDATE portal.sessions
SET is_active = false
WHERE user_id = (SELECT id FROM portal.users WHERE user_id = 'USR-010001')
  AND is_active = true;

-- Cleanup expired sessions (run periodically)
DELETE FROM portal.sessions
WHERE expires_at < NOW() - INTERVAL '30 days'
  AND is_active = false;
```

---

# SAMPLE QUERIES

## Query 1: User Dashboard Data

```sql
-- Get all data needed for user dashboard
WITH user_data AS (
    SELECT 
        u.id,
        u.user_id,
        u.email,
        u.user_type,
        u.last_login_at,
        c.full_name,
        c.phone
    FROM portal.users u
    LEFT JOIN ops.contacts c ON u.contact_id = c.id
    WHERE u.user_id = 'USR-010002'
),
user_roles_data AS (
    SELECT 
        r.role_code,
        r.role_name,
        ur.granted_at,
        ur.expires_at
    FROM portal.user_roles ur
    JOIN portal.roles r ON ur.role_id = r.id
    JOIN user_data ud ON ur.user_id = ud.id
    WHERE ur.is_active = true
      AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
),
active_sessions AS (
    SELECT COUNT(*) AS session_count
    FROM portal.sessions s
    JOIN user_data ud ON s.user_id = ud.id
    WHERE s.is_active = true
      AND s.expires_at > NOW()
)
SELECT 
    ud.*,
    (SELECT json_agg(row_to_json(urd)) FROM user_roles_data urd) AS roles,
    (SELECT session_count FROM active_sessions) AS active_sessions
FROM user_data ud;
```

## Query 2: Active Sessions Report (Admin View)

```sql
-- All active sessions with user details
SELECT 
    u.user_id,
    u.email,
    u.user_type,
    r.role_code,
    s.device_type,
    s.ip_address,
    s.created_at AS session_started,
    s.last_activity_at,
    s.expires_at,
    EXTRACT(EPOCH FROM (NOW() - s.last_activity_at)) / 60 AS minutes_idle
FROM portal.sessions s
JOIN portal.users u ON s.user_id = u.id
LEFT JOIN portal.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
LEFT JOIN portal.roles r ON ur.role_id = r.id
WHERE s.is_active = true
  AND s.expires_at > NOW()
ORDER BY s.last_activity_at DESC;
```

## Query 3: Permission Matrix for Role

```sql
-- Show all permissions organized by resource for a role
SELECT 
    r.role_code,
    r.role_name,
    p.resource,
    array_agg(DISTINCT p.action ORDER BY p.action) AS allowed_actions,
    MAX(CASE 
        WHEN p.scope = 'all' THEN 3
        WHEN p.scope = 'team' THEN 2
        WHEN p.scope = 'own' THEN 1
    END) AS max_scope_level,
    CASE MAX(CASE 
        WHEN p.scope = 'all' THEN 3
        WHEN p.scope = 'team' THEN 2
        WHEN p.scope = 'own' THEN 1
    END)
        WHEN 3 THEN 'all'
        WHEN 2 THEN 'team'
        WHEN 1 THEN 'own'
    END AS effective_scope
FROM portal.roles r
JOIN portal.permissions p ON r.id = p.role_id
WHERE r.role_code = 'HOMEOWNER'
GROUP BY r.role_code, r.role_name, p.resource
ORDER BY p.resource;
```

## Query 4: Failed Login Attempts Report

```sql
-- Users with recent failed login attempts (security monitoring)
SELECT 
    u.user_id,
    u.email,
    u.user_type,
    u.failed_login_attempts,
    u.locked_until,
    u.last_login_at,
    u.last_login_ip,
    CASE 
        WHEN u.locked_until > NOW() THEN 'LOCKED'
        WHEN u.failed_login_attempts >= 3 THEN 'WARNING'
        ELSE 'OK'
    END AS account_status
FROM portal.users u
WHERE u.failed_login_attempts > 0
   OR u.locked_until > NOW()
ORDER BY u.failed_login_attempts DESC, u.locked_until DESC NULLS LAST;
```

## Query 5: User Role Assignment Audit

```sql
-- Full audit trail of role assignments
SELECT 
    u.user_id,
    u.email,
    r.role_code,
    r.role_name,
    ur.granted_by,
    granter.email AS granted_by_email,
    ur.granted_at,
    ur.expires_at,
    ur.is_active,
    CASE 
        WHEN ur.is_active = false THEN 'Revoked'
        WHEN ur.expires_at < NOW() THEN 'Expired'
        ELSE 'Active'
    END AS assignment_status
FROM portal.user_roles ur
JOIN portal.users u ON ur.user_id = u.id
JOIN portal.roles r ON ur.role_id = r.id
LEFT JOIN portal.users granter ON ur.granted_by = granter.user_id
ORDER BY ur.granted_at DESC;
```

## Query 6: Users by Type with Role Summary

```sql
-- Summary of users and their roles grouped by user type
SELECT 
    u.user_type,
    COUNT(DISTINCT u.id) AS user_count,
    COUNT(DISTINCT CASE WHEN u.status = 'active' THEN u.id END) AS active_users,
    COUNT(DISTINCT CASE WHEN u.email_verified THEN u.id END) AS verified_users,
    COUNT(DISTINCT CASE WHEN u.mfa_enabled THEN u.id END) AS mfa_users,
    array_agg(DISTINCT r.role_code) AS roles_used
FROM portal.users u
LEFT JOIN portal.user_roles ur ON u.id = ur.user_id AND ur.is_active = true
LEFT JOIN portal.roles r ON ur.role_id = r.id
GROUP BY u.user_type
ORDER BY u.user_type;
```

## Query 7: User Preferences Summary

```sql
-- Common preference settings across users
SELECT 
    p.preference_key,
    p.preference_type,
    COUNT(DISTINCT p.user_id) AS users_with_setting,
    COUNT(DISTINCT CASE WHEN p.preference_value = 'true' THEN p.user_id END) AS users_true,
    COUNT(DISTINCT CASE WHEN p.preference_value = 'false' THEN p.user_id END) AS users_false,
    array_agg(DISTINCT p.preference_value) FILTER (WHERE p.preference_type = 'string') AS string_values
FROM portal.preferences p
GROUP BY p.preference_key, p.preference_type
ORDER BY users_with_setting DESC;
```

## Query 8: Security Audit - Recent Account Activity

```sql
-- Recent account activity for security review
SELECT 
    u.user_id,
    u.email,
    u.user_type,
    u.status,
    u.last_login_at,
    u.last_login_ip,
    u.password_changed_at,
    u.failed_login_attempts,
    COUNT(s.id) FILTER (WHERE s.is_active AND s.expires_at > NOW()) AS active_sessions,
    MAX(s.last_activity_at) AS most_recent_activity,
    MAX(s.created_at) AS newest_session
FROM portal.users u
LEFT JOIN portal.sessions s ON u.id = s.user_id
WHERE u.last_login_at > NOW() - INTERVAL '7 days'
   OR u.failed_login_attempts > 0
   OR EXISTS (
       SELECT 1 FROM portal.sessions s2 
       WHERE s2.user_id = u.id 
         AND s2.created_at > NOW() - INTERVAL '7 days'
   )
GROUP BY u.id, u.user_id, u.email, u.user_type, u.status, 
         u.last_login_at, u.last_login_ip, u.password_changed_at, u.failed_login_attempts
ORDER BY u.last_login_at DESC NULLS LAST;
```

---

# MIGRATION INFORMATION

**Migration File:** `V2025.12.06.100000__create_portal_schema.sql`  
**Date:** December 6, 2025  
**Author:** Central Memory Team  

## What This Migration Creates:

- ✅ 6 tables (all in portal schema)
- ✅ 1 sequence for Business IDs (portal.user_seq)
- ✅ 14 indexes for query performance
- ✅ 2 trigger functions (set_updated_at, generate_user_id)
- ✅ 6 triggers (updated_at for all tables)
- ✅ Seed data for 7 system roles

## Dependencies:

**Required Tables (Must Exist):**
- ops.contacts (for contact_id FK in portal.users)

**Required Functions:**
- public.set_updated_at() (shared trigger function)

## Post-Migration Steps:

1. **Seed system roles** - Run role INSERT statements (included in migration)
2. **Seed role permissions** - Run permission INSERT statements
3. **Create initial admin user** - Manual step with secure password
4. **Configure session settings** - Set token expiry in application config
5. **Test authentication flow** - Verify login/logout works

## Migration SQL Structure:

```sql
-- 1. Create schema if not exists
CREATE SCHEMA IF NOT EXISTS portal;

-- 2. Create sequence for user Business IDs
CREATE SEQUENCE portal.user_seq START WITH 10001;

-- 3. Create tables in dependency order:
--    a. portal.roles (no FKs)
--    b. portal.users (FK to ops.contacts)
--    c. portal.sessions (FK to users)
--    d. portal.permissions (FK to roles)
--    e. portal.user_roles (FKs to users, roles)
--    f. portal.preferences (FK to users)

-- 4. Create indexes

-- 5. Create triggers for updated_at

-- 6. Seed system roles

-- 7. Seed default permissions
```

## Rollback:

```sql
-- Reverse order of creation
DROP TABLE IF EXISTS portal.preferences CASCADE;
DROP TABLE IF EXISTS portal.user_roles CASCADE;
DROP TABLE IF EXISTS portal.permissions CASCADE;
DROP TABLE IF EXISTS portal.sessions CASCADE;
DROP TABLE IF EXISTS portal.users CASCADE;
DROP TABLE IF EXISTS portal.roles CASCADE;
DROP SEQUENCE IF EXISTS portal.user_seq;
-- Keep schema (may have other objects)
```

---

**Document Version:** 1.0  
**Last Updated:** December 6, 2025  
**Total Tables:** 6 (portal schema)  
**Migration:** `V2025.12.06.100000__create_portal_schema.sql`
