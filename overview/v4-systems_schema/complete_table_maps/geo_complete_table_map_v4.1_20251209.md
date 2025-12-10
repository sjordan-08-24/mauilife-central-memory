# Geo Schema — Complete Table Map v4.1

**Date:** 2025-12-09  
**Schema:** geo  
**Tables:** 4  
**Primary Key Standard:** UUIDv7 (time-ordered, globally unique)

---

## Schema Overview

The geo schema provides a hierarchical geographic structure for location-based operations. Properties are assigned to areas. All concierge venues (beaches, restaurants, activities, attractions, shops) are stored as points_of_interest with geo-coordinates. Resorts (in property schema) serve as the neighborhood/sub-area grouping.

**Hierarchy:** zones → cities → areas → points_of_interest

---

# FOREIGN KEY RELATIONSHIP MATRIX

```
geo.zones
├─► geo.cities (zone_id) [RESTRICT DELETE]
└─► geo.areas (zone_id) [RESTRICT DELETE] — denormalized for query performance

geo.cities
├─► geo.zones (zone_id) [RESTRICT DELETE]
└─► geo.areas (city_id) [RESTRICT DELETE]

geo.areas
├─► geo.cities (city_id) [RESTRICT DELETE]
├─► geo.zones (zone_id) [RESTRICT DELETE]
└─► geo.points_of_interest (area_id) [RESTRICT DELETE]

geo.points_of_interest
└─► geo.areas (area_id) [RESTRICT DELETE]
```

**LEGEND:**
- [RESTRICT DELETE] — Cannot delete parent if children exist

**HIERARCHY:**
```
zones (top-level: islands/states/metros)
  ├─► cities (towns within zones)
  │     └─► areas (neighborhoods/districts)
  │           └─► points_of_interest (venues, landmarks)
  │
  └─► areas (direct zone reference for query performance)
```

**External References TO geo:**
```
property.properties → geo.areas (area_id)
property.resorts → geo.areas (area_id)
concierge.* → geo.points_of_interest (replaces separate venue tables)
revenue.market_events → geo.areas (area_id)
external.properties → geo.areas (area_id)
```

---

# BUSINESS ID CROSS-REFERENCE

| Table | Business ID Format | Example | Sequence Start | External System References |
|-------|-------------------|---------|----------------|---------------------------|
| geo.zones | ZN-NNNN | ZN-0001 | 0001 | Property Management, Analytics Dashboard |
| geo.cities | CTY-NNNN | CTY-0001 | 0001 | Property Management, Analytics Dashboard |
| geo.areas | AREA-NNNN | AREA-0001 | 0001 | Property Management, Concierge AI (CAPRI), Mobile App, OTA Channel Sync |
| geo.points_of_interest | POI-NNNNNN | POI-010001 | 10001 | Concierge AI (CAPRI), Mobile App, Itinerary Engine |

---

# INDEX COVERAGE SUMMARY

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| geo.zones | idx_zones_id | zone_id (UNIQUE) | Business ID lookup |
| | idx_zones_slug | slug (UNIQUE) | URL slug lookup |
| | idx_zones_name | zone_name | Name search |
| | idx_zones_active | is_active WHERE is_active = true | Active zones |
| | idx_zones_ai_visible | is_ai_visible WHERE is_ai_visible = true | AI-visible zones |
| | idx_zones_featured | is_featured WHERE is_featured = true | Featured zones |
| | idx_zones_geo | geom USING GIST | Spatial queries |
| geo.cities | idx_cities_id | city_id (UNIQUE) | Business ID lookup |
| | idx_cities_slug | slug (UNIQUE) | URL slug lookup |
| | idx_cities_zone | zone_id | Cities by zone |
| | idx_cities_name | city_name | Name search |
| | idx_cities_active | is_active WHERE is_active = true | Active cities |
| | idx_cities_ai_visible | is_ai_visible WHERE is_ai_visible = true | AI-visible cities |
| | idx_cities_featured | is_featured WHERE is_featured = true | Featured cities |
| | idx_cities_geo | geom USING GIST | Spatial queries |
| geo.areas | idx_areas_id | area_id (UNIQUE) | Business ID lookup |
| | idx_areas_slug | slug (UNIQUE) | URL slug lookup |
| | idx_areas_city | city_id | Areas by city |
| | idx_areas_zone | zone_id | Areas by zone (direct) |
| | idx_areas_code | area_code WHERE area_code IS NOT NULL (UNIQUE) | Code lookup |
| | idx_areas_name | area_name | Name search |
| | idx_areas_type | area_type | Filter by type |
| | idx_areas_active | is_active WHERE is_active = true | Active areas |
| | idx_areas_ai_visible | is_ai_visible WHERE is_ai_visible = true | AI-visible areas |
| | idx_areas_featured | is_featured WHERE is_featured = true | Featured areas |
| | idx_areas_vibe_tags | vibe_tags USING GIN | Tag search |
| | idx_areas_geo | geom USING GIST | Spatial queries |
| geo.points_of_interest | idx_poi_id | poi_id (UNIQUE) | Business ID lookup |
| | idx_poi_area | area_id | POI by area |
| | idx_poi_type | poi_type | Filter by type |
| | idx_poi_category | poi_category | Filter by category |
| | idx_poi_geo | latitude, longitude | Geo queries |
| | idx_poi_active | is_active WHERE is_active = true | Active POI |
| | idx_poi_ai_visible | is_ai_visible WHERE is_ai_visible = true | AI-visible POI |
| | idx_poi_featured | is_featured WHERE is_featured = true | Featured POI |
| | idx_poi_tags | tags USING GIN | Tag search |

---

# TABLE SPECIFICATIONS

---

## 1. geo.zones

**PURPOSE:** Top-level geographic regions representing islands (Maui), states (Tennessee), or metro areas (Utah). Entry point for all location queries and multi-market isolation.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| zone_id | text | NOT NULL, UNIQUE | Business ID: ZN-NNNN | N/A |
| slug | text | NOT NULL, UNIQUE | URL-friendly identifier: west-maui | |
| zone_code | text | | Short code: WMAUI, SMAUI | |
| zone_name | text | NOT NULL | Display name: West Maui, South Maui | |
| zone_type | text | | Type: island, state, metro, region | |
| short_description | text | | Brief description for display | |
| description | text | | Full zone description | |
| tags | text[] | | Searchable tags: luxury, sunsets, resorts, snorkeling | |
| postal_codes | text[] | | ZIP codes in zone: 96761, 96767 | |
| primary_latitude | numeric(10,7) | | Primary reference latitude | |
| primary_longitude | numeric(10,7) | | Primary reference longitude | |
| centroid | geometry(Point, 4326) | | Calculated center point | |
| geom | geometry(MultiPolygon, 4326) | | Zone boundary polygon | |
| bbox | geometry(Polygon, 4326) | | Bounding box | |
| boundary_extreme_points | jsonb | | N/S/E/W extreme coordinates | |
| area_m2 | numeric | | Area in square meters | |
| timezone | text | | Primary timezone | |
| is_active | boolean | DEFAULT true | Available for operations | |
| is_ai_visible | boolean | DEFAULT true | Visible to CAPRI/concierge AI | |
| is_featured | boolean | DEFAULT false | Featured in UI/marketing | |
| sort_order | integer | | Display ordering | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**NO FOREIGN KEYS** — Top-level reference table

**NOTES:** Requires PostGIS extension for geometry columns.

---

## 2. geo.cities

**PURPOSE:** Cities/regions within zones. For Maui, represents actual towns like Lahaina, Kihei, Paia rather than broad regions. Groups areas for mid-level queries.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| city_id | text | NOT NULL, UNIQUE | Business ID: CTY-NNNN | N/A |
| zone_id | uuid | FK → geo.zones(id), NOT NULL | Parent zone | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| slug | text | NOT NULL, UNIQUE | URL-friendly identifier: lahaina | |
| city_code | text | | Short code: LAH, KIH, PAI | |
| city_name | text | NOT NULL | Display name: Lahaina, Kihei, Paia | |
| city_type | text | | Type: city, town, district | |
| short_description | text | | Brief description for display | |
| description | text | | Full city description | |
| postal_codes | text[] | | ZIP codes in city: 96761 | |
| primary_latitude | numeric(10,7) | | Primary reference latitude | |
| primary_longitude | numeric(10,7) | | Primary reference longitude | |
| geom | geometry(Point, 4326) | | City center point | |
| is_active | boolean | DEFAULT true | Available for operations | |
| is_ai_visible | boolean | DEFAULT true | Visible to CAPRI/concierge AI | |
| is_featured | boolean | DEFAULT false | Featured in UI/marketing | |
| sort_order | integer | | Display ordering | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**NOTES:** Requires PostGIS extension for geometry column.

---

## 3. geo.areas

**PURPOSE:** Primary property location reference. Properties are assigned to areas. Areas define the guest's neighborhood experience and drive concierge recommendations. Examples: Kaanapali, Wailea, Kapalua, Napili.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| area_id | text | NOT NULL, UNIQUE | Business ID: AREA-NNNN | N/A |
| city_id | uuid | FK → geo.cities(id), NOT NULL | Parent city | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| zone_id | uuid | FK → geo.zones(id), NOT NULL | Direct zone reference (denormalized for query performance) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| slug | text | NOT NULL, UNIQUE | URL-friendly identifier: kaanapali | |
| area_code | text | UNIQUE | Short code: KAA, WAI, KAP | |
| area_name | text | NOT NULL | Display name: Kaanapali, Wailea | |
| area_type | text | | Type: resort_district, district, city_wide | |
| short_description | text | | Brief description for display | |
| description | text | | Full area description | |
| vibe_tags | text[] | | Searchable vibe tags: luxury, surf, family, quiet | |
| postal_codes | text[] | | ZIP codes in area: 96761 | |
| primary_latitude | numeric(10,7) | | Primary reference latitude | |
| primary_longitude | numeric(10,7) | | Primary reference longitude | |
| geom | geometry(Point, 4326) | | Area center point | |
| boundary_polygon | jsonb | | GeoJSON polygon for area boundary | |
| drive_time_to_airport_min | integer | | Minutes to nearest airport | |
| nearest_airport_code | text | | Airport code (OGG, BNA, SLC) | |
| is_resort_area | boolean | DEFAULT false | Tourist/resort area | |
| is_active | boolean | DEFAULT true | Available for operations | |
| is_ai_visible | boolean | DEFAULT true | Visible to CAPRI/concierge AI | |
| is_featured | boolean | DEFAULT false | Featured in UI/marketing | |
| sort_order | integer | | Display ordering | |
| notes | text | | Internal notes | |
| created_at | timestamptz | DEFAULT now() | Record creation | |
| updated_at | timestamptz | DEFAULT now() | Last update | |

**CHECK CONSTRAINTS:**
- area_type IN ('resort_district', 'district', 'city_wide')

**NOTES:** 
- Requires PostGIS extension for geometry column.
- zone_id is denormalized (also available via city_id → zone_id) for query performance when filtering areas by zone directly.

---

## 4. geo.points_of_interest

**PURPOSE:** All concierge system venues — beaches, restaurants, activities, attractions, shops, services, landmarks. Powers AI recommendations and guest itineraries. Contains geo-coordinates for proximity calculations.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| poi_id | text | NOT NULL, UNIQUE | Business ID: POI-NNNNNN | N/A |
| area_id | uuid | FK → geo.areas(id), NOT NULL | Parent area | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| poi_type | text | NOT NULL | Type: beach, restaurant, activity, attraction, shop, service, landmark, airport, grocery, hospital |
| poi_category | text | | Subcategory: fine_dining, casual, snorkeling, hiking, etc. |
| poi_name | text | NOT NULL | Venue/POI name |
| description | text | | Description |
| address | text | | Street address |
| latitude | numeric(10,7) | NOT NULL | Latitude |
| longitude | numeric(10,7) | NOT NULL | Longitude |
| phone | text | | Contact phone |
| email | text | | Contact email |
| website | text | | Website URL |
| hours | jsonb | | Operating hours by day |
| price_level | text | | Price tier: $, $$, $$$, $$$$ |
| cuisine_type | text | | For restaurants: cuisine type |
| activity_level | text | | For activities: easy, moderate, strenuous |
| duration_minutes | integer | | Typical visit duration |
| booking_required | boolean | DEFAULT false | Advance booking needed |
| booking_url | text | | Booking link |
| amenities | text[] | | Available amenities |
| accessibility_features | text[] | | ADA/accessibility features |
| parking_info | text | | Parking details |
| photo_urls | text[] | | POI photos |
| rating | numeric(3,2) | | Average rating (1-5) |
| review_count | integer | | Number of reviews |
| google_place_id | text | | Google Places ID |
| yelp_id | text | | Yelp business ID |
| tripadvisor_id | text | | TripAdvisor ID |
| company_id | uuid | | Link to directory.companies if vendor |
| is_partner | boolean | DEFAULT false | Partner/affiliate venue |
| commission_rate | numeric(5,4) | | Commission if partner |
| is_featured | boolean | DEFAULT false | Featured/recommended |
| is_active | boolean | DEFAULT true | Currently active |
| is_ai_visible | boolean | DEFAULT true | Visible to CAPRI/concierge AI |
| seasonal_availability | jsonb | | Seasonal hours/closures |
| tags | text[] | | Searchable tags |
| sort_order | integer | | Display ordering |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**CHECK CONSTRAINTS:**
- poi_type IN ('beach', 'restaurant', 'activity', 'attraction', 'shop', 'service', 'landmark', 'airport', 'grocery', 'hospital', 'park', 'golf', 'spa')
- price_level IN ('$', '$$', '$$$', '$$$$')
- activity_level IN ('easy', 'moderate', 'strenuous')

---

# CROSS-SCHEMA DEPENDENCIES

## Other Schemas → Geo

| Source Schema.Table | References | Target Table |
|---------------------|------------|--------------|
| property.properties | area_id | geo.areas |
| property.resorts | area_id | geo.areas |
| revenue.market_events | area_id | geo.areas |
| external.properties | area_id | geo.areas |
| concierge.itinerary_items | poi_id | geo.points_of_interest |
| concierge.bookings | poi_id | geo.points_of_interest |
| concierge.guest_preferences | preferred_poi_ids | geo.points_of_interest |

---

# SAMPLE DATA (Maui)

## Zones (6)
| zone_id | slug | zone_name | short_description | known_for |
|---------|------|-----------|-------------------|-----------|
| ZN-0001 | west-maui | West Maui | Historic whaling towns, luxury resorts, and calm leeward beaches | Sunsets, Kaanapali Beach, historic Front Street |
| ZN-0002 | south-maui | South Maui | Sun-drenched coastline with condo resorts and luxury hotels | Driest weather, gold sand beaches, Wailea luxury |
| ZN-0003 | central-maui | Central Maui | The commercial hub and government seat of the island | Airport (OGG), Iao Valley, shopping malls |
| ZN-0004 | north-shore | North Shore | Windsurfing capital with a bohemian, surf-town vibe | Big waves, turtles, Paia town, Road to Hana start |
| ZN-0005 | upcountry | Upcountry | High-elevation agricultural communities on Haleakalā's slopes | Cooler temperatures, botanical gardens, panoramic views |
| ZN-0006 | east-maui-hana | East Maui / Hāna | Remote, lush rainforest region accessed by the famous winding road | Waterfalls, black sand beaches, bamboo forests |

## Cities (10)
| city_id | slug | city_name | zone | short_description | known_for |
|---------|------|-----------|------|-------------------|-----------|
| CTY-0001 | lahaina | Lahaina | West Maui | Historic port town and former capital of the Hawaiian Kingdom | Front Street, Banyan Tree, harbor activities |
| CTY-0002 | kihei | Kihei | South Maui | Bustling beach town with condos, parks, and sunny weather | Kamaole beaches, affordable dining, surf schools |
| CTY-0003 | wailuku | Wailuku | Central Maui | Historic county seat with local boutiques and government offices | Iao Valley gateway, Market Street shops |
| CTY-0004 | kahului | Kahului | Central Maui | Main commercial hub hosting the airport and big-box retail | OGG Airport, Queen Ka'ahumanu Center, harbor |
| CTY-0005 | paia | Paia | North Shore | Eclectic surf town with colorful storefronts and galleries | Mana Foods, hippie vibe, start of Hana Highway |
| CTY-0006 | haiku | Haiku | North Shore | Lush, rural community tucked into the rainforest edge | Jungle scenery, privacy, old canneries |
| CTY-0007 | hana | Hana | East Maui | Isolated town at the end of the famous road, steeped in culture | Hasegawa General Store, Wananalua Church, relaxation |
| CTY-0008 | makawao | Makawao | Upcountry | Historic paniolo (cowboy) town with art galleries and bakeries | T. Komoda Store, rodeo heritage, art scene |
| CTY-0009 | kula | Kula | Upcountry | Rustic agricultural district on the upper slopes of Haleakalā | Kula Lodge, botanical gardens, farm tours |
| CTY-0010 | pukalani | Pukalani | Upcountry | "Hole in the Heavens," a residential golf community | Golf course, cooler weather, scenic views |

## Areas (25)
| area_id | slug | area_name | city | short_description | known_for |
|---------|------|-----------|------|-------------------|-----------|
| **West Maui** |
| AREA-0001 | lahaina-town | Lahaina Town | Lahaina | The historic heart of West Maui (impacted by 2023 fires) | Historical sites, harbor, banyan tree |
| AREA-0002 | launiupoko | Launiupoko | Lahaina | Residential agricultural estates with a popular beach park | Longboard surfing, family picnics, hillside estates |
| AREA-0003 | olowalu | Olowalu | Lahaina | Coastal area known for its massive coral reef system | Snorkeling, roadside fruit stands, camping |
| AREA-0004 | kaanapali | Kaanapali | Lahaina | Master-planned resort area with high-end hotels and golf | Whalers Village, Black Rock, beach walk |
| AREA-0005 | honokowai | Honokowai | Lahaina | Condo-dense coastline north of Kaanapali with local parks | Farmers market, food trucks, reef-protected swimming |
| AREA-0006 | kahana | Kahana | Lahaina | Quiet stretch of oceanfront condos and vacation rentals | Sea turtles, quiet atmosphere, local dining |
| AREA-0007 | napili | Napili | Lahaina | Low-rise resort bay with a classic old-Hawaii feel | Napili Bay, snorkeling, Gazebo restaurant |
| AREA-0008 | kapalua | Kapalua | Lahaina | Luxury resort community known for golf and wind protection | Ritz-Carlton, Kapalua Bay, Wine & Food Festival |
| **South Maui** |
| AREA-0009 | north-kihei | North Kihei | Kihei | Windy stretch of coastline with long beaches and fishponds | Sugar Beach, canoe clubs, whale sanctuary center |
| AREA-0010 | south-kihei | South Kihei | Kihei | The dense tourist center of Kihei with shops and bars | The Cove (surfing), Kalama Park, nightlife |
| AREA-0011 | wailea | Wailea | Kihei | Upscale resort district with luxury shopping and golf | Four Seasons, Grand Wailea, Shops at Wailea |
| AREA-0012 | makena | Makena | Kihei | Rugged, less developed southern coastline with lava fields | Big Beach, turtle town, La Perouse Bay |
| **Central Maui** |
| AREA-0013 | maalaea | Maalaea | Wailuku | Windy harbor village known for the ocean center and boat tours | Maui Ocean Center, harbor departures, surf break |
| AREA-0014 | waikapu | Waikapu | Wailuku | Central valley agricultural area with plantation history | Tropical Plantation, golf, valley views |
| AREA-0015 | maui-lani | Maui Lani | Kahului | Master-planned residential community within Kahului | The Dunes golf course, residential living |
| **North Shore** |
| AREA-0016 | spreckelsville | Spreckelsville | Paia | Windy north shore area famous for aviation and windsports | Windsurfing, private estates, golf course |
| AREA-0017 | kuau | Kuau | Paia | Small residential enclave just past Paia town | Mama's Fish House, Ho'okipa access |
| AREA-0018 | peahi | Peahi | Haiku | Agricultural cliffside area home to the famous "Jaws" surf break | Big wave surfing, rural estates |
| **Upcountry** |
| AREA-0019 | ulupalakua | Ulupalakua | Kula | Historic ranch land at the southern end of Upcountry | Maui Wine, elk burgers, ranch history |
| AREA-0020 | keokea | Keokea | Kula | Charming, quiet village with coffee shops and grand views | Grandma's Coffee House, Thompson Ranch |
| AREA-0021 | haliimaile | Haliimaile | Makawao | Pineapple plantation village with a famous general store | Hali'imaile General Store, pineapple tours |
| **East Maui** |
| AREA-0022 | nahiku | Nahiku | Hana | Lush tropical jungle community off the Hana Highway | Dense rainforest, waterfalls, fruit stands |
| AREA-0023 | keanae | Keanae | Hana | Traditional taro farming peninsula with a rugged coastline | Taro patches, Auntie Sandy's Banana Bread, crashing waves |
| AREA-0024 | kipahulu | Kipahulu | Hana | Remote district past Hana, part of Haleakalā National Park | Seven Sacred Pools, Pipiwai Trail, Lindbergh's grave |
| AREA-0025 | kaupo | Kaupo | Hana | Dry, rugged backside of Haleakalā with stark landscapes | Kaupo Store, unpaved road adventure |

## Points of Interest (examples)
| poi_id | poi_name | poi_type | area | known_for |
|--------|----------|----------|------|-----------|
| POI-010001 | Kaanapali Beach | beach | Kaanapali | Black Rock, beach walk, snorkeling |
| POI-010002 | Whaler's Village | shop | Kaanapali | Shopping, dining, whale museum |
| POI-010003 | Napili Bay | beach | Napili | Calm snorkeling, sea turtles |
| POI-010004 | Kapalua Bay | beach | Kapalua | Protected bay, snorkeling |
| POI-010005 | Big Beach (Makena) | beach | Makena | Large golden sand beach, bodyboarding |
| POI-010006 | Mama's Fish House | restaurant | Kuau | Famous fresh fish, oceanfront dining |
| POI-010007 | Gazebo Restaurant | restaurant | Napili | Macadamia nut pancakes, ocean views |
| POI-010008 | Hali'imaile General Store | restaurant | Haliimaile | Upscale Hawaiian regional cuisine |
| POI-010009 | Maui Ocean Center | attraction | Maalaea | Aquarium, shark exhibit |
| POI-010010 | Kahului Airport (OGG) | airport | Kahului | Main airport |
| POI-010011 | Trilogy Excursions | activity | Lahaina Town | Snorkel tours, Lanai trips |
| POI-010012 | Ho'okipa Beach Park | beach | Kuau | World-class windsurfing, sea turtles |

---

# KEY USAGE PATTERNS

## 1. Get All Areas for a Zone
```sql
SELECT a.area_name, c.city_name
FROM geo.areas a
JOIN geo.cities c ON a.city_id = c.id
JOIN geo.zones z ON c.zone_id = z.id
WHERE z.zone_code = 'MAUI'
ORDER BY c.city_name, a.area_name;
```

## 2. Find Restaurants Near a Property
```sql
SELECT p.poi_name, p.cuisine_type, p.price_level,
       -- Distance calculation
       ST_Distance(
         ST_MakePoint(p.longitude, p.latitude)::geography,
         ST_MakePoint(prop.longitude, prop.latitude)::geography
       ) / 1609.34 AS distance_miles
FROM geo.points_of_interest p
JOIN property.properties prop ON p.area_id = prop.area_id
WHERE p.poi_type = 'restaurant'
  AND p.is_active = true
  AND prop.property_id = 'PRP-MLVR-010001'
ORDER BY distance_miles
LIMIT 10;
```

## 3. Get All POI for Itinerary Building
```sql
SELECT poi_id, poi_name, poi_type, poi_category,
       latitude, longitude, duration_minutes, price_level
FROM geo.points_of_interest
WHERE area_id IN (
  SELECT id FROM geo.areas 
  WHERE city_id = (SELECT city_id FROM geo.areas WHERE area_id = 'AREA-0001')
)
AND is_active = true
ORDER BY poi_type, sort_order;
```

## 4. Full Hierarchy Lookup
```sql
SELECT 
    z.zone_name,
    c.city_name,
    a.area_name,
    p.poi_name,
    p.poi_type
FROM geo.points_of_interest p
JOIN geo.areas a ON p.area_id = a.id
JOIN geo.cities c ON a.city_id = c.id
JOIN geo.zones z ON c.zone_id = z.id
WHERE z.zone_code = 'MAUI'
ORDER BY c.city_name, a.area_name, p.poi_type, p.poi_name;
```

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-09  
**UUIDv7 Migration:** V4.1 Schema Specification  
**Total Tables:** 4
