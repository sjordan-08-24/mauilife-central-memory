# Marketing Schema — Brand Guidelines Addition v4.1

**Date:** 2025-12-10  
**Addition to:** marketing schema  
**New Table:** 1 (brand_guidelines)  
**Updated Total:** 28 tables

---

## Context

**Visual brand files** (logos, images) → `storage.digital_assets` with `asset_type = 'brand'`

**Brand guidelines** (colors, fonts, usage instructions) → `marketing.brand_guidelines` 

This table uses flexible JSONB columns (`attributes`, `instructions`) to handle varying data structures across guideline types. <100 records initially — if needed, can split into specific tables later.

---

# NEW TABLE SPECIFICATION

---

## marketing.brand_guidelines

**PURPOSE:** Brand guidelines — colors, typography, logo usage, imagery standards. Flexible JSONB structure accommodates different guideline types. Supports company-level AND property-level branding.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key |
| guideline_id | text | NOT NULL, UNIQUE | Business ID: BG-NNNNNN |
| property_id | uuid | FK → property.properties(id) | Property (NULL = company-level) |
| guideline_type | text | NOT NULL | Type: colors, typography, logo_usage, imagery, voice, messaging |
| name | text | NOT NULL | Guideline name |
| description | text | | Brief description |
| attributes | jsonb | | Type-specific data (colors, fonts, etc.) |
| instructions | jsonb | | Usage instructions, do/don't rules |
| ai_context | text | | Context for AI content generation |
| is_primary | boolean | DEFAULT false | Primary guideline for this type |
| status | text | DEFAULT 'active' | active, draft, archived |
| sort_order | integer | | Display ordering |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

---

## Guideline Types & JSONB Structures

### colors
```json
// attributes
{
  "palette": [
    {"name": "Ocean Blue", "role": "primary", "hex": "#0066CC", "rgb": "0,102,204"},
    {"name": "Sunset Gold", "role": "secondary", "hex": "#F5A623"},
    {"name": "Palm Green", "role": "accent", "hex": "#2ECC71"},
    {"name": "Sand Beige", "role": "neutral", "hex": "#F5F0E6"},
    {"name": "Lava Black", "role": "text", "hex": "#1A1A1A"}
  ]
}

// instructions
{
  "usage": {
    "primary": "Headers, CTAs, links",
    "secondary": "Accents, highlights",
    "neutral": "Backgrounds"
  },
  "combinations": ["Ocean Blue + Sand Beige", "Sunset Gold + Lava Black"],
  "avoid": ["Never use Palm Green as background", "Don't combine Sunset Gold with Ocean Blue text"]
}
```

### typography
```json
// attributes
{
  "fonts": [
    {"name": "Montserrat", "role": "headline", "weights": ["600", "700"], "url": "https://fonts.google..."},
    {"name": "Open Sans", "role": "body", "weights": ["400", "600"], "url": "https://fonts.google..."}
  ],
  "scale": {"xs": "12px", "sm": "14px", "base": "16px", "lg": "18px", "xl": "24px", "2xl": "32px"}
}

// instructions
{
  "usage": {
    "headline": "H1, H2, hero text, CTAs",
    "body": "Paragraphs, lists, captions"
  },
  "line_height": {"headline": "1.2", "body": "1.6"},
  "avoid": ["Never use more than 2 fonts", "Don't use headline font for body text"]
}
```

### logo_usage
```json
// attributes
{
  "versions": ["primary", "icon", "wordmark", "white", "black"],
  "min_size_px": 120,
  "clear_space": "Height of 'M' on all sides",
  "file_location": "storage.digital_assets where asset_type='brand' and tags @> '{logo}'"
}

// instructions
{
  "approved": ["Website header", "Email signatures", "Marketing materials", "Social profiles"],
  "prohibited": ["Don't stretch or distort", "Don't change colors", "Don't add shadows/effects", "Don't place on busy backgrounds"],
  "co_branding": "Logo must be equal or larger than partner logos",
  "backgrounds": "Use white version on dark backgrounds, full color on light"
}
```

### imagery
```json
// attributes
{
  "style": "Bright, natural, lifestyle-focused",
  "mood": ["welcoming", "luxurious", "relaxed", "authentic"],
  "technical": {"min_resolution": "1920x1080", "aspect_ratios": ["16:9", "4:3", "1:1"]}
}

// instructions
{
  "subjects": ["Property interiors", "Ocean views", "Guests enjoying", "Local culture"],
  "avoid": ["Overly staged shots", "Empty rooms", "Harsh lighting", "Stock photo feel"],
  "editing": "Natural color, slightly warm treatment"
}
```

### voice
```json
// attributes
{
  "tone": "Warm, welcoming, professional but not stuffy",
  "personality": ["friendly", "knowledgeable", "helpful", "local expert"]
}

// instructions
{
  "do": ["Use 'Aloha' in greetings", "Address guests by name", "Be conversational", "Share local tips"],
  "dont": ["Use corporate jargon", "Be overly formal", "Use passive voice", "Sound robotic"],
  "examples": {
    "good": "Aloha John! We're so excited you're joining us at Oceanview Villa.",
    "bad": "Dear Guest, Your reservation has been confirmed."
  }
}
```

### messaging
```json
// attributes
{
  "tagline": "Live the Maui Life",
  "elevator_pitch": "Luxury vacation rentals with local expertise and personal service",
  "key_messages": ["Locally owned and operated", "Hand-selected properties", "24/7 concierge service"]
}

// instructions
{
  "use_tagline": "Marketing materials, email signatures, social bios",
  "key_message_contexts": {
    "differentiation": "Locally owned and operated",
    "quality": "Hand-selected properties",
    "service": "24/7 concierge service"
  }
}
```

---

## Indexes

| Index | Columns | Purpose |
|-------|---------|---------|
| idx_bg_id | guideline_id (UNIQUE) | Business ID lookup |
| idx_bg_property | property_id | Property guidelines |
| idx_bg_type | guideline_type | Filter by type |
| idx_bg_company | property_id WHERE property_id IS NULL | Company-level |
| idx_bg_primary | is_primary WHERE is_primary = true | Primary guidelines |
| idx_bg_status | status WHERE status = 'active' | Active only |

---

## Foreign Keys

| Column | References | On Delete |
|--------|------------|-----------|
| property_id | property.properties(id) | SET NULL |

---

## Sample Data

| guideline_id | property_id | guideline_type | name | is_primary |
|--------------|-------------|----------------|------|------------|
| BG-010001 | NULL | colors | Company Color Palette | true |
| BG-010002 | NULL | typography | Company Typography | true |
| BG-010003 | NULL | logo_usage | Logo Usage Guidelines | true |
| BG-010004 | NULL | imagery | Photography Standards | true |
| BG-010005 | NULL | voice | Brand Voice | true |
| BG-010006 | NULL | messaging | Key Messages | true |
| BG-010007 | {prop-uuid} | colors | Oceanview Villa Colors | true |

---

## Access Patterns

### Get company color palette
```sql
SELECT attributes->'palette' AS colors, instructions
FROM marketing.brand_guidelines
WHERE property_id IS NULL 
  AND guideline_type = 'colors'
  AND is_primary = true
  AND status = 'active';
```

### Get all brand guidelines for AI context
```sql
SELECT guideline_type, name, attributes, instructions, ai_context
FROM marketing.brand_guidelines
WHERE (property_id IS NULL OR property_id = $1)
  AND status = 'active'
ORDER BY property_id NULLS LAST, is_primary DESC;
```

### Get property guidelines with company fallback
```sql
SELECT DISTINCT ON (guideline_type)
  guideline_id, guideline_type, name, attributes, instructions
FROM marketing.brand_guidelines
WHERE (property_id IS NULL OR property_id = $1)
  AND status = 'active'
ORDER BY guideline_type, property_id NULLS LAST;
```

---

## Where Brand Files Live

**Logos, brand images, brand documents** are stored in `storage.digital_assets`:

```sql
-- Find all brand logos
SELECT * FROM storage.digital_assets 
WHERE asset_type = 'brand' 
  AND 'logo' = ANY(tags);

-- Find brand assets for a property
SELECT * FROM storage.digital_assets 
WHERE asset_type = 'brand' 
  AND (property_id = $1 OR property_id IS NULL);
```

---

## Updated Marketing Schema Table Count

| Category | Tables |
|----------|--------|
| Content Management | 6 |
| Strategy & Planning | 3 |
| Campaigns | 2 |
| Segments | 2 |
| Social Media | 4 |
| Websites | 2 |
| Attribution | 1 |
| SEO | 3 |
| **Brand** | **1** |
| Reference | 4 |
| **TOTAL** | **28** |

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-10  
**New Table:** 1 (brand_guidelines)
