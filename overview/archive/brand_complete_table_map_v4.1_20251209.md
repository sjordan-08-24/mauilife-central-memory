# Brand Schema — Complete Table Map v4.1

**Date:** 2025-12-09  
**Schema:** brand  
**Tables:** 5  
**Primary Key Standard:** UUIDv7 (time-ordered, globally unique)

---

## Schema Overview

The brand schema manages company-level brand identity including guidelines, logos, colors, typography, and messaging templates. This is the master source for brand consistency across all marketing materials, communications, and AI-generated content. Referenced by BENSON AI for content generation.

**Key Integrations:**
- BENSON AI — Content generation with brand voice
- Brand Portal — Asset management and guidelines
- Email/SMS Systems — Messaging templates
- Website CMS — Brand assets

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
brand.brand_guidelines ─────────────────────────────────────────────────────────┐
    (standalone reference table - no FKs)                                       │
                                                                                │
brand.logos ────────────────────────────────────────────────────────────────────┤
    (standalone reference table - no FKs)                                       │
                                                                                │
brand.color_palettes ───────────────────────────────────────────────────────────┤
    (standalone reference table - no FKs)                                       │
                                                                                │
brand.typography ───────────────────────────────────────────────────────────────┤
    (standalone reference table - no FKs)                                       │
                                                                                │
brand.messaging_templates ──────────────────────────────────────────────────────┘
    (standalone reference table - no FKs)
```

**NO FOREIGN KEYS** — All brand tables are standalone reference tables. They define company standards without dependencies on other schemas.

**External References TO brand:**
```
marketing.content → brand.messaging_templates (template guidance)
ai.agents → brand.brand_guidelines (voice/tone rules)
comms.templates → brand.messaging_templates (message templates)
```

---

# BUSINESS ID CROSS-REFERENCE

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| brand_guidelines | BG-NNNNNN | BG-010001 | 10001 | BENSON AI, Brand Portal |
| logos | LOGO-NNNN | LOGO-0001 | 0001 | Brand Portal, Website CMS |
| messaging_templates | TMPL-NNNNNN | TMPL-010001 | 10001 | BENSON AI, Email System, Guest Messaging |
| color_palettes | — | — | — | Brand Portal |
| typography | — | — | — | Brand Portal |

---

# INDEX COVERAGE SUMMARY

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| brand.brand_guidelines | idx_bg_id | guideline_id (UNIQUE) | Business ID lookup |
| | idx_bg_category | category | Filter by category |
| | idx_bg_status | status WHERE status = 'active' | Active guidelines |
| brand.logos | idx_logos_id | logo_id (UNIQUE) | Business ID lookup |
| | idx_logos_type | logo_type | Filter by type |
| | idx_logos_context | usage_context | Filter by context |
| brand.color_palettes | idx_color_role | color_role | Filter by role |
| | idx_color_name | color_name | Name lookup |
| brand.typography | idx_typo_role | font_role | Filter by role |
| | idx_typo_name | font_name | Name lookup |
| brand.messaging_templates | idx_tmpl_id | template_id (UNIQUE) | Business ID lookup |
| | idx_tmpl_type | template_type | Filter by type |
| | idx_tmpl_channel | channel | Filter by channel |
| | idx_tmpl_status | status WHERE status = 'active' | Active templates |

---

# TABLE SPECIFICATIONS

---

## 1. brand.brand_guidelines

**PURPOSE:** Master brand standards including voice guidelines, naming conventions, style rules, and usage policies. Referenced by BENSON AI for content generation and brand consistency enforcement.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| guideline_id | text | NOT NULL, UNIQUE | Business ID: BG-NNNNNN | N/A |
| category | text | NOT NULL | Category: voice, naming, imagery, messaging, social, legal | |
| title | text | NOT NULL | Guideline title | |
| description | text | | Brief description | |
| content | text | NOT NULL | Full guideline content (markdown) | |
| examples | jsonb | | Good/bad examples: {"do": [...], "dont": [...]} | |
| applies_to | text[] | | Where applies: email, social, website, ota, sms | |
| priority | text | DEFAULT 'standard' | Priority: critical, high, standard, optional | |
| version | text | | Version number | |
| effective_date | date | | When guideline takes effect | |
| expiration_date | date | | When guideline expires | |
| status | text | DEFAULT 'draft' | Status: draft, active, archived | |
| approved_by | text | | Who approved | |
| approved_at | timestamptz | | When approved | |
| file_url | text | | Supporting document URL | |
| tags | text[] | | Searchable tags | |
| ai_prompt_context | text | | Context for AI agents | |
| created_by | text | | Who created | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- category IN ('voice', 'naming', 'imagery', 'messaging', 'social', 'legal', 'photography', 'video')
- priority IN ('critical', 'high', 'standard', 'optional')
- status IN ('draft', 'active', 'archived', 'pending_review')

**NO FOREIGN KEYS** — Reference table

---

## 2. brand.logos

**PURPOSE:** Company logo assets in various formats, sizes, and color versions. Includes usage guidelines and minimum size requirements. Central repository for all logo variations.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| logo_id | text | NOT NULL, UNIQUE | Business ID: LOGO-NNNN | N/A |
| logo_name | text | NOT NULL | Logo name: "Primary Logo", "Icon Only" | |
| logo_type | text | NOT NULL | Type: primary, secondary, icon, wordmark, badge | |
| color_version | text | NOT NULL | Version: full_color, white, black, single_color | |
| file_url | text | NOT NULL | File storage URL | |
| format | text | NOT NULL | Format: svg, png, jpg, eps, pdf | |
| dimensions | jsonb | | Dimensions: {"width": 1200, "height": 400} | |
| file_size_bytes | integer | | File size | |
| min_size_px | integer | | Minimum display size in pixels | |
| clear_space_ratio | numeric(3,2) | | Required clear space as ratio of logo height | |
| usage_context | text[] | | Where to use: web, print, social, email, favicon | |
| background_requirements | text | | Background requirements | |
| usage_guidelines | text | | Specific usage notes | |
| do_not_use | text[] | | Prohibited uses | |
| is_primary | boolean | DEFAULT false | Primary version for this type | |
| sort_order | integer | | Display ordering | |
| status | text | DEFAULT 'active' | Status: active, deprecated, archived | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- logo_type IN ('primary', 'secondary', 'icon', 'wordmark', 'badge', 'favicon', 'social')
- color_version IN ('full_color', 'white', 'black', 'single_color', 'grayscale')
- format IN ('svg', 'png', 'jpg', 'eps', 'pdf', 'ico')
- status IN ('active', 'deprecated', 'archived')

**NO FOREIGN KEYS** — Reference table

---

## 3. brand.color_palettes

**PURPOSE:** Company brand colors with hex, RGB, CMYK, and Pantone values. Defines primary, secondary, and accent colors with usage guidelines for visual consistency.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| color_name | text | NOT NULL, UNIQUE | Color name: "Maui Blue", "Sunset Orange" | |
| color_role | text | NOT NULL | Role: primary, secondary, accent, neutral, background, text | |
| hex_value | text | NOT NULL | Hex: #0066CC | |
| rgb_value | jsonb | | RGB: {"r": 0, "g": 102, "b": 204} | |
| cmyk_value | jsonb | | CMYK: {"c": 100, "m": 50, "y": 0, "k": 20} | |
| hsl_value | jsonb | | HSL: {"h": 210, "s": 100, "l": 40} | |
| pantone_value | text | | Pantone: "286 C" | |
| usage_context | text[] | | Where to use: web, print, email | |
| usage_notes | text | | Usage guidelines | |
| accessibility_notes | text | | Contrast/accessibility info | |
| wcag_contrast_white | numeric(4,2) | | Contrast ratio against white | |
| wcag_contrast_black | numeric(4,2) | | Contrast ratio against black | |
| paired_with | text[] | | Colors that pair well | |
| avoid_with | text[] | | Colors to avoid pairing | |
| is_active | boolean | DEFAULT true | Currently active | |
| sort_order | integer | | Display ordering | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- color_role IN ('primary', 'secondary', 'accent', 'neutral', 'background', 'text', 'error', 'success', 'warning')

**NO FOREIGN KEYS** — Reference table

---

## 4. brand.typography

**PURPOSE:** Company fonts and typography standards including web fonts, weights, and usage guidelines per role (headlines, body, etc.). Ensures consistent typography across all materials.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| font_name | text | NOT NULL | Font name: "Montserrat", "Open Sans" | |
| font_role | text | NOT NULL | Role: headline, subhead, body, caption, accent, monospace | |
| font_family | text | NOT NULL | CSS font-family value | |
| font_weight | text | NOT NULL | Weight: 300, 400, 500, 600, 700, bold, regular | |
| font_style | text | DEFAULT 'normal' | Style: normal, italic | |
| font_url | text | | Web font URL (Google Fonts, etc.) | |
| font_file_urls | jsonb | | Self-hosted font files | |
| fallback_fonts | text[] | | Fallback stack: ["Helvetica", "Arial", "sans-serif"] | |
| line_height | text | | Recommended line-height | |
| letter_spacing | text | | Recommended letter-spacing | |
| size_scale | jsonb | | Size scale: {"xs": "12px", "sm": "14px", ...} | |
| usage_context | text[] | | Where to use: web, print, email | |
| usage_notes | text | | Usage guidelines | |
| pairing_notes | text | | Font pairing recommendations | |
| license_type | text | | License: google_fonts, commercial, custom | |
| is_active | boolean | DEFAULT true | Currently active | |
| sort_order | integer | | Display ordering | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**UNIQUE CONSTRAINT:** (font_name, font_role, font_weight)

**CHECK CONSTRAINTS:**
- font_role IN ('headline', 'subhead', 'body', 'caption', 'accent', 'monospace', 'button', 'navigation')
- font_style IN ('normal', 'italic', 'oblique')

**NO FOREIGN KEYS** — Reference table

---

## 5. brand.messaging_templates

**PURPOSE:** Reusable message templates for all channels (email, SMS, OTA messaging). Contains variables for personalization and tracks performance. Used by AI agents and team for consistent communications.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| template_id | text | NOT NULL, UNIQUE | Business ID: TMPL-NNNNNN | N/A |
| template_name | text | NOT NULL | Template name | |
| template_type | text | NOT NULL | Type: booking_confirmation, check_in, review_request, etc. | |
| channel | text | NOT NULL | Channel: email, sms, ota_message, push, in_app | |
| category | text | | Category: transactional, marketing, operational, support | |
| subject_line | text | | Email subject (with variables) | |
| preview_text | text | | Email preview text | |
| body_content | text | NOT NULL | Body content (with variables) | |
| body_html | text | | HTML version for email | |
| variables | jsonb | | Available variables: {"guest_name": "Guest's first name", ...} | |
| required_variables | text[] | | Required variables that must be populated | |
| default_values | jsonb | | Default values for optional variables | |
| tone | text | | Tone: warm, professional, casual, urgent | |
| language | text | DEFAULT 'en' | Language code | |
| version | integer | DEFAULT 1 | Version number | |
| a_b_variant | text | | A/B test variant identifier | |
| performance_metrics | jsonb | | Open rate, click rate, response rate | |
| use_count | integer | DEFAULT 0 | Times used | |
| last_used_at | timestamptz | | Last use timestamp | |
| status | text | DEFAULT 'draft' | Status: draft, active, archived, testing | |
| approved_by | text | | Who approved | |
| approved_at | timestamptz | | When approved | |
| tags | text[] | | Searchable tags | |
| created_by | text | | Who created | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- template_type IN ('booking_confirmation', 'check_in', 'check_out', 'review_request', 'welcome', 'pre_arrival', 'mid_stay', 'post_stay', 'payment_reminder', 'maintenance_notice', 'marketing', 'survey', 'concierge')
- channel IN ('email', 'sms', 'ota_message', 'push', 'in_app', 'whatsapp')
- category IN ('transactional', 'marketing', 'operational', 'support', 'concierge')
- tone IN ('warm', 'professional', 'casual', 'urgent', 'apologetic')
- status IN ('draft', 'active', 'archived', 'testing')

**NO FOREIGN KEYS** — Reference table

---

# SAMPLE DATA

## brand_guidelines

| guideline_id | category | title | priority |
|--------------|----------|-------|----------|
| BG-010001 | voice | Brand Voice Standards | critical |
| BG-010002 | voice | Guest Communication Tone | high |
| BG-010003 | naming | Property Naming Convention | standard |
| BG-010004 | imagery | Photography Standards | high |
| BG-010005 | social | Social Media Guidelines | standard |
| BG-010006 | legal | Disclaimer Requirements | critical |

## logos

| logo_id | logo_type | color_version | format | usage_context |
|---------|-----------|---------------|--------|---------------|
| LOGO-0001 | primary | full_color | svg | web, print |
| LOGO-0002 | primary | white | svg | dark backgrounds |
| LOGO-0003 | icon | full_color | png | favicon, app |
| LOGO-0004 | wordmark | black | svg | print |

## color_palettes

| color_name | color_role | hex_value |
|------------|------------|-----------|
| Ocean Blue | primary | #0066CC |
| Sunset Gold | secondary | #F5A623 |
| Palm Green | accent | #2ECC71 |
| Sand Beige | neutral | #F5F0E6 |
| Lava Black | text | #1A1A1A |

## typography

| font_name | font_role | font_weight |
|-----------|-----------|-------------|
| Montserrat | headline | 700 |
| Montserrat | subhead | 600 |
| Open Sans | body | 400 |
| Open Sans | caption | 400 |

## messaging_templates

| template_id | template_type | channel | tone |
|-------------|---------------|---------|------|
| TMPL-010001 | booking_confirmation | email | warm |
| TMPL-010002 | check_in | sms | friendly |
| TMPL-010003 | review_request | email | warm |
| TMPL-010004 | pre_arrival | email | professional |

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-09  
**UUIDv7 Migration:** V4.1 Schema Specification  
**Total Tables:** 5
