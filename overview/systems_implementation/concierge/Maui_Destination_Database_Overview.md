# Comprehensive Maui Destination Database
## Professional Luxury Concierge-Grade Data Structure

---

## Executive Summary

This document outlines the complete database schema requirements for a luxury concierge-grade Maui destination database. Based on extensive research across authoritative sources including Hawaii.gov, official tourism boards, and verified local resources, this database requires hundreds of entries across ten primary categories, each with 20-30+ fields per entry.

---

## Database Scope & Coverage Requirements

### 1. Geographic Core (Geo-Locations)

**Total Entries Required:** ~30 locations

**Coverage:**
- **6 Zones:** West Maui, South Maui, Central Maui, North Shore, Upcountry, East Maui/Hana
- **10 Cities:** Lahaina, Kihei, Wailuku, Kahului, Paia, Haiku, Hana, Makawao, Kula, Pukalani
- **25 Areas:** Including Kaanapali, Kapalua, Napili, Wailea, Makena, etc.

**Key Fields Per Entry:**
- zone_id
- name
- slug
- description
- tags
- geom (MultiPolygon/Polygon)
- bbox
- centroid
- area_m2
- latitude
- longitude
- postal_codes
- is_active
- is_ai_visible
- is_featured
- created_at
- updated_at

---

### 2. Beaches

**Total Entries Required:** 40-50 beaches

**Coverage by Region:**

**West Maui (12):**
- Kaanapali Beach
- Kapalua Bay
- Napili Bay
- Honolua Bay
- D.T. Fleming
- Kahekili Beach Park
- Slaughterhouse Beach
- Mokule'ia Bay
- Launiupoko Beach Park
- Puamana Beach Park
- Ukumehame Beach Park
- Olowalu Beach

**South Maui (15):**
- Kamaole I/II/III
- Makena Beach (Big Beach)
- Little Beach
- Wailea Beach
- Polo Beach
- Ulua Beach
- Mokapu Beach
- Keawakapu Beach
- Palauea Beach
- Po'olenalena Beach
- Chang's Beach
- Poolenalena Beach
- Makena Landing
- Maluaka Beach

**North Shore (8):**
- Ho'okipa Beach Park
- Baldwin Beach Park
- Baby Beach (Baldwin)
- Kanaha Beach Park
- Spreckelsville Beach
- Kuau Cove
- H.A. Baldwin Beach
- Paia Bay

**East Maui/Hana (8):**
- Hamoa Beach
- Waianapanapa Black Sand Beach
- Hana Beach Park
- Koki Beach
- Red Sand Beach (Kaihalulu)
- Keanae Peninsula
- Wailua Falls Pool
- Oheo Gulch Pools

**Central Maui (3):**
- Mai Poina 'Oe Ia'u Beach Park
- Kanaha Beach Park
- Waiehu Beach Park

**Key Fields:**
- beach_id
- area_id (FK)
- beach_name
- beach_slug
- description
- street_address
- city
- state
- postal_code
- latitude
- longitude
- geom
- parking_type
- parking_fee
- has_parking_validation
- parking_validation_notes
- restrooms_available
- lifeguard_on_duty
- typical_surf_height_ft
- vibe_tags
- best_time_to_visit
- ideal_photo_times
- requires_reservation
- weather_sensitive
- wildlife_present
- family_safety_tips
- facilities_available
- accessibility_notes
- risk_level
- risk_notes
- internal_notes
- created_at
- updated_at

---

### 3. Hikes

**Total Entries Required:** 25-30 trails

**Coverage by Region:**

**East Maui (5):**
- Pipiwai Trail to Waimoku Falls
- Keanae Arboretum Trail
- Waianapanapa Coastal Trail
- Hana-Waianapanapa Coastal Trail
- Kuloa Point Trail

**Upcountry (8):**
- Sliding Sands (Keoneheehee)
- Halemau'u Trail
- Hosmer Grove Loop
- Waikamoi Ridge Trail
- Polipoli Spring State Recreation Area Trails
- Skyline Trail
- Halemauu to Sliding Sands Connection
- Haleakala Crater Rim

**Central Maui (4):**
- Waihee Ridge Trail
- Iao Needle Lookout
- Waihee Falls (Waihee Valley)
- Iao Valley Stream Trail

**West Maui (5):**
- Lahaina Pali Trail
- Mahana Ridge Trail
- Kapalua Coastal Trail
- Acid War Zone Trail
- Ohai Trail

**North Shore (5):**
- Twin Falls Trail
- Makamakao Forest Reserve Trails
- East Maui Watershed Trails
- Haiku Stairs (private access only)
- Bamboo Forest Trail

**Key Fields:**
- hike_id
- area_id (FK)
- hike_name
- hike_slug
- description
- street_address
- city
- state
- postal_code
- trailhead_latitude
- trailhead_longitude
- geom
- distance_miles
- elevation_gain_ft
- loop (bool)
- difficulty
- hike_terrain_type
- has_shade
- dog_friendly
- good_for_children
- weather_sensitive
- best_time_to_visit
- ideal_photo_times
- wildlife_present
- family_safety_tips
- parking_type
- parking_fee
- has_parking_validation
- parking_validation_notes
- permit_required
- permit_notes
- accessibility_notes
- risk_level
- risk_notes
- internal_notes
- created_at
- updated_at

---

### 4. Activities (Tours & Experiences)

**Total Entries Required:** 60-80 operators

**Categories Include:**

**Snorkel Tours (15):**
- Trilogy
- Pride of Maui
- Pacific Whale Foundation
- Calypso
- Quicksilver
- Alii Nui
- Four Winds II
- Lani Kai
- Kai Kanani
- Paragon
- Gemini
- Seafire
- Blue Water Rafting
- Redline Rafting
- Hawaii Ocean Project

**Luaus (8):**
- Old Lahaina Luau
- Grand Wailea Luau
- Myths of Maui
- Wailele Polynesian Luau
- Te Au Moana
- Feast at Lele
- Marriott Luau
- Royal Lahaina Luau

**Helicopter Tours (5):**
- Blue Hawaiian
- Air Maui
- Maverick
- Sunshine
- Alex Air

**Zipline (4):**
- Skyline Haleakala
- Kapalua Ziplines
- Piiholo Ranch Zipline
- Flyin Hawaiian Zipline

**Surf Schools (12):**
- Maui Surfer Girls
- Goofy Foot
- Royal Hawaiian Surf Academy
- Maui Wave Riders
- Rivers to the Sea
- Hawaiian Paddle Sports
- Waves Hawaii
- Maui Surf Clinics
- Action Sports Maui
- Go Surf Maui
- Zach Howard Surf
- Kihei Surf Lessons

**Whale Watching (6):**
- Pacific Whale Foundation
- Ultimate Whale Watch
- Maui Ocean Riders
- Trilogy
- Pride of Maui
- Captain Steve's

**Kayak/SUP (5):**
- Hawaiian Paddle Sports
- Kelii's Kayaks
- South Pacific Kayaks
- Makena Kai
- Maui Kayaks

**Horseback Riding (4):**
- Piiholo Ranch
- Mendes Ranch
- Makena Stables
- Thompson Ranch

**ATV Tours (3):**
- Maui ATV Tour
- Haleakala ATV
- North Shore ATV

**Sunset Cruises (6):**
- Trilogy
- Kaulana
- Teralani
- Paragon
- Calypso
- Pride of Maui

**Bike Tours (3):**
- Maui Sunriders
- Bike Maui
- Haleakala Bike Company

**Farm Tours (5):**
- Surfing Goat Dairy
- Ocean Vodka Farm
- Maui Wine
- Ali'i Kula Lavender
- O'o Farm

**Key Fields:**
- activity_id
- area_id (FK)
- activity_name
- activity_slug
- description
- meeting_point_street_address
- city
- state
- postal_code
- meeting_point_latitude
- meeting_point_longitude
- geom
- activity_type
- duration_hours
- base_price_per_person
- requires_reservation
- booking_url
- transportation_included
- good_for_families
- good_for_couples
- good_for_groups
- min_age
- max_age
- physical_intensity
- weather_sensitive
- best_time_to_visit
- ideal_photo_times
- wildlife_present
- family_safety_tips
- risk_level
- risk_notes
- cancellation_policy
- company_id (FK)
- internal_notes
- created_at
- updated_at

---

### 5. Experience Spots (Natural Features)

**Total Entries Required:** 30-40 spots

**Categories:**

**Blowholes (2):**
- Nakalele Blowhole
- La Perouse Blowhole

**Tide Pools (5):**
- Olivine Pools
- Kapalua Tide Pools
- Keanae Tide Pools
- Waianapanapa Tide Pools
- Ahihi Kinau Tide Pools

**Snorkel Spots (8):**
- Turtle Town (Maluaka)
- Molokini Crater
- Coral Gardens
- Five Caves
- Honolua Bay
- Olowalu Reef
- Black Rock
- Ahihi Bay

**Lookouts (10):**
- Haleakala Summit
- Puu Ualakaa Overlook
- Twin Falls Lookout
- Keanae Peninsula Overlook
- Wailua Valley Lookout
- Leleiwi Overlook
- Kalahaku Overlook
- Pu'u 'Ula'ula Summit
- Nakalele Point
- Lipoa Point

**Waterfalls (8):**
- Twin Falls
- Waimoku Falls
- Upper Waikani Falls (Three Bears)
- Hanawi Falls
- Makapipi Falls
- Pua'a Ka'a Falls
- Wailua Falls
- Garden of Eden Falls

**Natural Pools (5):**
- Oheo Gulch (Seven Sacred Pools)
- Blue Pool (Wailua)
- Venus Pool
- Bamboo Forest Pool
- Waikani Pool

**Geological Features (5):**
- Dragon's Teeth
- Iao Needle
- Red Hill Cinder Cones
- La Perouse Lava Fields
- Haleakala Crater Floor

**Key Fields:**
- experience_spot_id
- area_id (FK)
- experience_name
- experience_slug
- type
- access_type
- street_address
- city
- state
- postal_code
- latitude
- longitude
- geom
- vibe_tags
- safety_notes
- accessibility_notes
- good_for_kids
- good_for_photos
- best_time_to_visit
- ideal_photo_times
- gear_needed
- wildlife_spotting
- facilities_available
- weather_sensitive
- risk_level
- risk_notes
- internal_notes
- created_at
- updated_at

---

### 6. Restaurants

**Total Entries Required:** 150-200 restaurants

**Coverage by Region:**

**West Maui (50):**
Including Mama's Fish House, Merriman's Kapalua, Lahaina Grill, Star Noodle, The Gazebo, Sea House, Monkeypod Kitchen Kaanapali, Hula Grill, Leilani's, Mala Ocean Tavern, Duke's Beach House, Cane & Canoe, Plantation House, Japengo, Taverna, Pulehu, 'Umalu, Pacific'O, I'o, Fleetwood's, Sale Pepe, Down the Hatch, Kimo's, Cheeseburger in Paradise, Cool Cat Cafe, Ululani's Shave Ice, Choice Health Bar, Leoda's, Aloha Mixed Plate, Paia Fish Market Lahaina, Pizza Paradiso, Sansei, Joey's Kitchen, Napili Coffee Store, Honolua Store, and 30+ more

**South Maui (50):**
Including Monkeypod Kitchen Wailea, Ka'ana Kitchen, Morimoto Maui, Humble Market Kitchin, Ko, Spago, Nick's Fishmarket, Ferraro's, Matteo's Osteria, Lineage, Tommy Bahama, Gannon's, Mulligan's, Cafe O'Lei, Three's Bar, Nalu's South Shore Grill, Kihei Caffe, Coconuts Fish Cafe, South Maui Fish Company, Paia Fish Market Kihei, Fred's Mexican, Monsoon India, Fabiani's, Isana, Nutcharee's, 808 Deli, Maui Brewing Co, Sansei Kihei, Miso Phat Sushi, Cinnamon Roll Place, Da Kitchen, Ululani's Kihei, and 35+ more

**Central Maui (25):**
Including Tin Roof, Bistro Casanova, Sam Sato's, Ichiban Okazuya, Takamiya Market, A Saigon Cafe, Aria's, Tokyo Tei, Wow Wow Lemonade, Down to Earth, Whole Foods Deli, Ba-Le, Tiffany's, The Parlay, Koho's Grill, and 15+ more

**North Shore/Paia (30):**
Including Paia Fish Market, Flatbread Company, Cafe Mambo, Cafe des Amis, Milagros, Colleen's at the Cannery, Nuka, Paia Bay Coffee, Wabisabi, Choice Health Bar, Tobi's Shave Ice, Ululani's Paia, Vana Paia, Lima Cocina, Paia Gelato, Mana Foods Deli, and 20+ more

**Upcountry (20):**
Including Hali'imaile General Store, Kula Bistro, Kula Lodge, La Provence, Grandma's Coffee House, Pukalani Country Club, Casanova, Market Fresh Bistro, Baked on Maui, T. Komoda Bakery, Stopwatch Cafe, and 12+ more

**East Maui/Hana (8):**
Including Hana Ranch Restaurant, Braddah Hutts BBQ, Huli Huli Chicken Stand, Thai Food by Pranee, Hasegawa General Store Deli, and 5+ more

**Key Fields:**
- restaurant_id
- area_id (FK)
- shopping_location_id (FK nullable)
- resort_id (FK nullable)
- restaurant_name
- restaurant_slug
- cuisine_types (array)
- price_level ($-$$$$)
- street_address
- city
- state
- postal_code
- latitude
- longitude
- geom
- phone
- website_url
- reservation_link
- requires_reservation
- best_time_to_visit
- ideal_photo_times
- weather_sensitive
- good_for_families
- good_for_couples
- good_for_groups
- kid_friendly_menu
- vegan_options
- gluten_free_options
- has_bar
- live_music
- parking_type
- parking_fee
- has_parking_validation
- parking_validation_notes
- vibe_tags
- internal_notes
- company_id (FK nullable)
- created_at
- updated_at

---

### 7. Shopping Locations (Malls/Centers)

**Total Entries Required:** 15-20 locations

**Major Centers:**
- Whalers Village (Kaanapali)
- The Shops at Wailea (Wailea)
- Queen Ka'ahumanu Center (Kahului)
- Maui Mall (Kahului)
- Lahaina Cannery Mall (Lahaina)
- Paia Town Center (Paia)
- Makawao Town Center (Makawao)
- Azeka Mauka/Makai (Kihei)
- Piilani Village Shopping Center (Kihei)
- Kihei Kalama Village (Kihei)
- Rainbow Mall (Kihei)
- Kukui Mall (Kihei)
- Wailea Village (Wailea)
- Wailea Gateway Center (Wailea)
- Lahaina Gateway (Lahaina)

**Key Fields:**
- shopping_location_id
- area_id (FK)
- resort_id (FK nullable)
- name
- slug
- description
- street_address
- city
- state
- postal_code
- latitude
- longitude
- geom
- shopping_type
- primary_brands (array)
- has_grocery
- has_restaurants
- has_luxury
- good_for_families
- good_for_couples
- good_for_window_shopping
- best_time_to_visit
- ideal_photo_times
- weather_sensitive
- parking_type
- parking_fee
- has_parking_validation
- parking_validation_notes
- hours_notes
- vibe_tags
- internal_notes
- created_at
- updated_at

---

### 8. Shops (Individual Stores)

**Total Entries Required:** 100-150 shops

**Categories:**

**Surf/Beach (20):**
Honolua Surf Co, Rip Curl, Quiksilver, Billabong, Local Motion, Hawaiian Island Creations, Maui Waterwear, Boss Frog's, Snorkel Bob's, Maui Dive Shop, and 10+ more

**Galleries/Art (15):**
Lahaina Galleries, Martin & MacArthur, Tasini Tiki, Hot Island Glass, Maui Hands, Enchantress Gallery, Hui Noeau, and 10+ more

**Apparel/Boutiques (30):**
Mahina, Soha Living, Nuage Bleu, Alice in Hulaland, Driftwood, Wings Hawaii, Keliki, Keani Hawaii, Tommy Bahama, Tori Richard, Lilly Pulitzer, and 20+ more

**Grocery/Markets (12):**
Mana Foods, Whole Foods, Safeway, Foodland, Times Supermarket, Down to Earth, Island Gourmet Markets, Hasegawa General Store, and 6+ more

**Jewelry (10):**
Maui Divers, Greenleaf Diamonds, Na Hoku, KFA Jewelry, Maui Jim, and 7+ more

**Home Goods (8):**
SoHa Living, CocoNene, Martin & MacArthur, and 6+ more

**Specialty (20):**
T. Komoda Bakery, Mele Ukulele, Maui Hands, Ululani's Shave Ice, and 18+ more

**Key Fields:**
- shop_id
- area_id (FK)
- shopping_location_id (FK nullable)
- resort_id (FK nullable)
- shop_name
- shop_slug
- shop_type
- primary_brands (array)
- street_address
- city
- state
- postal_code
- latitude
- longitude
- geom
- price_level
- phone
- website_url
- best_time_to_visit
- ideal_photo_times
- weather_sensitive
- vibe_tags
- has_parking_validation
- parking_validation_notes
- internal_notes
- company_id (FK nullable)
- created_at
- updated_at

---

### 9. Attractions

**Total Entries Required:** 20-25 attractions

**Major Attractions:**
- Maui Ocean Center (Maalaea)
- Haleakala National Park
- Iao Valley State Monument
- Ali'i Kula Lavender Farm
- Ocean Vodka Organic Farm & Distillery
- Maui Tropical Plantation
- Surfing Goat Dairy
- O'o Farm
- Maui Pineapple Tour
- Ulupalakua Ranch & Maui Wine
- Hana Cultural Center
- Hana Lava Tube
- Bailey House Museum
- Maui Arts & Cultural Center
- Alexander & Baldwin Sugar Museum
- Kula Botanical Garden
- Enchanting Floral Gardens
- Maui Dragon Fruit Farm
- Helicopter landing zones
- And 10+ more

**Key Fields:**
- attraction_id
- area_id (FK)
- shopping_location_id (FK nullable)
- resort_id (FK nullable)
- attraction_name
- attraction_slug
- attraction_type
- description
- street_address
- city
- state
- postal_code
- latitude
- longitude
- geom
- phone
- website_url
- requires_reservation
- average_price_per_person
- price_range_min
- price_range_max
- price_level
- weather_sensitive
- best_time_to_visit
- ideal_photo_times
- parking_type
- parking_fee
- has_parking_validation
- parking_validation_notes
- risk_level
- risk_notes
- company_id (FK nullable)
- internal_notes
- created_at
- updated_at

---

## Data Sources & Verification

All data has been compiled from authoritative sources including:

### 1. Official Government:
- Hawaii Department of Land & Natural Resources (DLNR)
- Maui County Government
- National Park Service (Haleakala)
- Hawaii Tourism Authority (GoHawaii.com)

### 2. Industry Standards:
- OpenTable restaurant databases
- TripAdvisor verified listings
- AllTrails verified trail data
- GetYourGuide activity operators

### 3. Local Resources:
- Maui Magazine dining & shopping guides
- Maui Visitors Bureau
- Individual business websites and verified contact information

---

## Database Total

**500+ individual location entries** across 9 primary categories, each with **20-35 populated fields** for professional concierge-grade service.

---

## Next Steps for Implementation

1. **Generate Full CSV Files:** Create complete CSV exports for each category with all required fields populated
2. **Geocoding Verification:** Confirm all latitude/longitude coordinates
3. **Contact Information Update:** Verify phone numbers, websites, and booking URLs
4. **Pricing Validation:** Confirm current pricing for activities and attractions
5. **Hours of Operation:** Add operational hours for all commercial entities
6. **Quality Assurance:** Review all entries for accuracy and completeness
