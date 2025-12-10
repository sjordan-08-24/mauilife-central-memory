# Inventory Schema — Complete Table Map v4.1

**Date:** 2025-12-09  
**Schema:** inventory  
**Tables:** 15  
**Primary Key Standard:** UUIDv7 (time-ordered, globally unique)

---

## Schema Overview

The inventory schema tracks all physical items across four distinct contexts: guest rooms (room_inventory), owner personal property (owner_inventory), company equipment (company_inventory), and warehouse stock (storage_inventory). All inventory references a universal product catalog (inventory_items) with type codes from ref.inventory_item_types.

A dedicated linen subsystem handles the specialized needs of linen tracking including par levels, deliveries, counts, issues, and orders.

---

## Foreign Key Relationship Matrix

```
inventory.inventory_items ──────────────────────────────────────────────────────┐
    │                                                                           │
    ├── inventory.room_inventory ───────────────────────────────────────────────┤
    │       ├── → property.rooms                                                │
    │       └── → property.inspections                                          │
    │                                                                           │
    ├── inventory.owner_inventory ──────────────────────────────────────────────┤
    │       ├── → directory.homeowners                                          │
    │       └── → property.properties                                           │
    │                                                                           │
    ├── inventory.company_inventory ────────────────────────────────────────────┤
    │       ├── → team.team_directory (assigned_to)                             │
    │       └── → property.properties (current_location)                        │
    │                                                                           │
    ├── inventory.storage_inventory ────────────────────────────────────────────┤
    │       ├── → inventory.storage_locations                                   │
    │       └── → team.team_directory (last_counted_by)                         │
    │                                                                           │
    ├── inventory.inventory_purchases ──────────────────────────────────────────┤
    │       ├── → directory.companies (supplier)                                │
    │       ├── → property.properties (destination)                             │
    │       └── → team.team_directory (ordered_by)                              │
    │                                                                           │
    └── inventory.inventory_events ─────────────────────────────────────────────┤
            ├── → property.properties                                           │
            └── → team.team_directory (performed_by)                            │
                                                                                │
inventory.storage_locations (self-reference: parent_location_id) ───────────────┤
                                                                                │
inventory.linen_types ──────────────────────────────────────────────────────────┤
    │                                                                           │
    ├── inventory.linen_items ──────────────────────────────────────────────────┤
    │       └── → inventory.linen_issues                                        │
    │                                                                           │
    ├── inventory.linen_pars ───────────────────────────────────────────────────┤
    │       ├── → property.properties                                           │
    │       └── → property.rooms                                                │
    │                                                                           │
    └── inventory.linen_orders ─────────────────────────────────────────────────┤
            └── → directory.companies (supplier)                                │
                                                                                │
inventory.linen_deliveries ─────────────────────────────────────────────────────┤
    ├── → property.properties                                                   │
    └── → directory.companies (linen_service)                                   │
                                                                                │
inventory.linen_counts ─────────────────────────────────────────────────────────┤
    ├── → property.properties                                                   │
    └── → team.team_directory (counted_by)                                      │
                                                                                │
inventory.linen_issues ─────────────────────────────────────────────────────────┘
    ├── → inventory.linen_items
    └── → property.properties

ref.inventory_item_types ← inventory.inventory_items (type_code FK)
```

---

## Business ID Cross-Reference

| Table | Business ID Format | Example | Sequence Start |
|-------|-------------------|---------|----------------|
| inventory_items | INV-{type}-NNNNNN | INV-TWLB-010001 | 10001 |
| room_inventory | RINV-NNNNNN | RINV-010001 | 10001 |
| owner_inventory | OINV-NNNNNN | OINV-010001 | 10001 |
| company_inventory | CINV-NNNNNN | CINV-010001 | 10001 |
| storage_inventory | SINV-NNNNNN | SINV-010001 | 10001 |
| storage_locations | LOC-NNNN | LOC-0001 | 0001 |
| inventory_purchases | INVPO-NNNNNN | INVPO-010001 | 10001 |
| inventory_events | INVEV-NNNNNN | INVEV-010001 | 10001 |
| linen_types | LNT-NNNN | LNT-0001 | 0001 |
| linen_items | LNI-NNNNNN | LNI-010001 | 10001 |
| linen_pars | LNP-NNNNNN | LNP-010001 | 10001 |
| linen_deliveries | LND-NNNNNN | LND-010001 | 10001 |
| linen_counts | LNC-NNNNNN | LNC-010001 | 10001 |
| linen_issues | LNIS-NNNNNN | LNIS-010001 | 10001 |
| linen_orders | LNPO-NNNNNN | LNPO-010001 | 10001 |

---

## Index Coverage Summary

### Inventory Schema Indexes

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| inventory.inventory_items | idx_inv_items_id | item_id (UNIQUE) | Business ID lookup |
| | idx_inv_items_type | type_code | Filter by item type |
| | idx_inv_items_supplier | supplier_company_id | Supplier lookup |
| | idx_inv_items_sku | sku WHERE sku IS NOT NULL | SKU lookup |
| | idx_inv_items_replacement | replacement_item_id WHERE replacement_item_id IS NOT NULL | Find replacements |
| inventory.room_inventory | idx_room_inv_id | room_inventory_id (UNIQUE) | Business ID lookup |
| | idx_room_inv_room | room_id | Room items |
| | idx_room_inv_item | item_id | Item locations |
| | idx_room_inv_inspection | last_inspection_id | Inspection tracking |
| | idx_room_inv_status | status WHERE status != 'good' | Problem items queue |
| inventory.owner_inventory | idx_owner_inv_id | owner_inventory_id (UNIQUE) | Business ID lookup |
| | idx_owner_inv_owner | homeowner_id | Owner items |
| | idx_owner_inv_property | property_id | Property items |
| | idx_owner_inv_item | item_id | Item lookup |
| inventory.company_inventory | idx_company_inv_id | company_inventory_id (UNIQUE) | Business ID lookup |
| | idx_company_inv_item | item_id | Item lookup |
| | idx_company_inv_assigned | assigned_to_id WHERE assigned_to_id IS NOT NULL | Assigned equipment |
| | idx_company_inv_location | current_property_id WHERE current_property_id IS NOT NULL | Equipment by property |
| inventory.storage_inventory | idx_storage_inv_id | storage_inventory_id (UNIQUE) | Business ID lookup |
| | idx_storage_inv_item | item_id | Item stock lookup |
| | idx_storage_inv_location | location_id | Location stock |
| | idx_storage_inv_reorder | quantity_on_hand WHERE quantity_on_hand <= reorder_point | Reorder queue |
| inventory.storage_locations | idx_storage_loc_id | location_id (UNIQUE) | Business ID lookup |
| | idx_storage_loc_parent | parent_location_id | Hierarchy navigation |
| | idx_storage_loc_code | location_code (UNIQUE) | Code lookup |
| inventory.inventory_purchases | idx_inv_purch_id | purchase_id (UNIQUE) | Business ID lookup |
| | idx_inv_purch_item | item_id | Item purchases |
| | idx_inv_purch_supplier | supplier_company_id | Supplier orders |
| | idx_inv_purch_status | status WHERE status NOT IN ('delivered', 'cancelled') | Active orders |
| | idx_inv_purch_destination | destination_property_id | Property deliveries |
| inventory.inventory_events | idx_inv_events_id | event_id (UNIQUE) | Business ID lookup |
| | idx_inv_events_item | item_id | Item history |
| | idx_inv_events_property | property_id WHERE property_id IS NOT NULL | Property movements |
| | idx_inv_events_date | event_timestamp | Chronological |
| | idx_inv_events_type | event_type | Filter by type |
| inventory.linen_types | idx_linen_types_id | linen_type_id (UNIQUE) | Business ID lookup |
| | idx_linen_types_code | type_code (UNIQUE) | Code lookup |
| inventory.linen_items | idx_linen_items_id | linen_item_id (UNIQUE) | Business ID lookup |
| | idx_linen_items_type | linen_type_id | Type lookup |
| | idx_linen_items_status | status WHERE status != 'in_service' | Problem linens |
| | idx_linen_items_barcode | barcode WHERE barcode IS NOT NULL (UNIQUE) | Barcode scan |
| inventory.linen_pars | idx_linen_pars_id | linen_par_id (UNIQUE) | Business ID lookup |
| | idx_linen_pars_property | property_id | Property pars |
| | idx_linen_pars_room | room_id WHERE room_id IS NOT NULL | Room-specific pars |
| | idx_linen_pars_type | linen_type_id | Type pars |
| | idx_linen_pars_unique | property_id, room_id, linen_type_id (UNIQUE) | One par per combo |
| inventory.linen_deliveries | idx_linen_del_id | delivery_id (UNIQUE) | Business ID lookup |
| | idx_linen_del_property | property_id | Property deliveries |
| | idx_linen_del_company | linen_service_company_id | Service provider |
| | idx_linen_del_date | delivery_date | Chronological |
| inventory.linen_counts | idx_linen_counts_id | count_id (UNIQUE) | Business ID lookup |
| | idx_linen_counts_property | property_id | Property counts |
| | idx_linen_counts_date | count_date | Chronological |
| | idx_linen_counts_counter | counted_by_id | Counter lookup |
| inventory.linen_issues | idx_linen_issues_id | issue_id (UNIQUE) | Business ID lookup |
| | idx_linen_issues_item | linen_item_id | Item issues |
| | idx_linen_issues_property | property_id WHERE property_id IS NOT NULL | Property issues |
| | idx_linen_issues_status | status WHERE status = 'open' | Open issues queue |
| inventory.linen_orders | idx_linen_orders_id | order_id (UNIQUE) | Business ID lookup |
| | idx_linen_orders_type | linen_type_id | Type orders |
| | idx_linen_orders_supplier | supplier_company_id | Supplier orders |
| | idx_linen_orders_status | status WHERE status NOT IN ('received', 'cancelled') | Active orders |

---

# TABLE SPECIFICATIONS

---

## 1. inventory.inventory_items

**PURPOSE:** Universal product catalog for all trackable items. Master reference for room inventory, owner inventory, company inventory, and storage inventory. Items are categorized by type_code from ref.inventory_item_types. Supports replacement tracking for discontinued items.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| item_id | text | NOT NULL, UNIQUE | Business ID: INV-{type}-NNNNNN | N/A |
| type_code | text | FK → ref.inventory_item_types(type_code), NOT NULL | Item type code (TWLB, VACU, etc.) | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| supplier_company_id | uuid | FK → directory.companies(id) | Primary supplier | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| replacement_item_id | uuid | FK → inventory.inventory_items(id) | Replacement when discontinued | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| item_name | text | NOT NULL | Display name |
| description | text | | Detailed description |
| sku | text | | Supplier SKU |
| upc | text | | Universal product code |
| brand | text | | Brand name |
| model | text | | Model number |
| unit_of_measure | text | NOT NULL, DEFAULT 'each' | each, pack, case, set |
| units_per_pack | integer | DEFAULT 1 | Units in standard pack |
| standard_cost | numeric(10,2) | | Standard unit cost |
| last_cost | numeric(10,2) | | Most recent purchase cost |
| list_price | numeric(10,2) | | MSRP/list price |
| weight_lbs | numeric(8,2) | | Weight in pounds |
| dimensions | text | | L x W x H |
| is_consumable | boolean | DEFAULT false | Used up vs. durable |
| is_trackable | boolean | DEFAULT true | Individual item tracking |
| requires_inspection | boolean | DEFAULT false | Check during inspections |
| typical_lifespan_months | integer | | Expected useful life |
| warranty_months | integer | | Warranty period |
| reorder_point | integer | | Stock level to trigger reorder |
| reorder_quantity | integer | | Standard order quantity |
| is_discontinued | boolean | DEFAULT false | No longer available |
| discontinued_date | date | | When discontinued |
| notes | text | | Internal notes |
| status | text | DEFAULT 'active' | active, inactive, discontinued |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_inv_items_id: item_id (UNIQUE)
- idx_inv_items_type: type_code
- idx_inv_items_supplier: supplier_company_id
- idx_inv_items_sku: sku WHERE sku IS NOT NULL
- idx_inv_items_replacement: replacement_item_id WHERE replacement_item_id IS NOT NULL

---

## 2. inventory.room_inventory

**PURPOSE:** Tracks items placed in guest rooms. Each record represents one item instance in one room. Links to inspections for condition tracking. Supports expected_quantity for par-level enforcement.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| room_inventory_id | text | NOT NULL, UNIQUE | Business ID: RINV-NNNNNN | N/A |
| room_id | uuid | FK → property.rooms(id), NOT NULL | Room containing item | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| item_id | uuid | FK → inventory.inventory_items(id), NOT NULL | Item type | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| last_inspection_id | uuid | FK → property.inspections(id) | Last inspection checked | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| quantity | integer | NOT NULL, DEFAULT 1 | Current quantity |
| expected_quantity | integer | DEFAULT 1 | Par level for room |
| status | text | DEFAULT 'good' | good, damaged, missing, replaced |
| condition | text | | new, good, fair, poor |
| condition_notes | text | | Condition details |
| location_in_room | text | | Specific placement |
| serial_number | text | | If trackable |
| purchase_date | date | | When acquired |
| purchase_cost | numeric(10,2) | | Actual cost paid |
| warranty_expiry | date | | Warranty end date |
| last_inspected_at | timestamptz | | Last inspection date |
| last_replaced_at | timestamptz | | Last replacement date |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**UNIQUE CONSTRAINT:** (room_id, item_id, location_in_room) — One item per location per room

**INDEXES:**
- idx_room_inv_id: room_inventory_id (UNIQUE)
- idx_room_inv_room: room_id
- idx_room_inv_item: item_id
- idx_room_inv_inspection: last_inspection_id
- idx_room_inv_status: status WHERE status != 'good'

---

## 3. inventory.owner_inventory

**PURPOSE:** Tracks owner personal property stored at rental properties. Items belong to homeowner but may be located at specific property. Important for insurance, move-out, and damage claims.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| owner_inventory_id | text | NOT NULL, UNIQUE | Business ID: OINV-NNNNNN | N/A |
| homeowner_id | uuid | FK → directory.homeowners(id), NOT NULL | Owner of item | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| property_id | uuid | FK → property.properties(id) | Current location | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| item_id | uuid | FK → inventory.inventory_items(id) | Catalog item (if standard) | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| item_name | text | NOT NULL | Item description |
| category | text | | furniture, electronics, art, decor, other |
| quantity | integer | NOT NULL, DEFAULT 1 | Count |
| estimated_value | numeric(12,2) | | Estimated replacement value |
| purchase_date | date | | When owner acquired |
| purchase_price | numeric(12,2) | | Original cost |
| serial_number | text | | For valuables |
| condition | text | | excellent, good, fair, poor |
| condition_notes | text | | Condition details |
| location_description | text | | Where in property |
| photo_urls | text[] | | Documentation photos |
| is_insured | boolean | DEFAULT false | Covered by owner insurance |
| insurance_value | numeric(12,2) | | Insured amount |
| do_not_move | boolean | DEFAULT false | Must stay in place |
| special_instructions | text | | Handling instructions |
| notes | text | | Internal notes |
| status | text | DEFAULT 'at_property' | at_property, in_storage, removed, damaged, lost |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_owner_inv_id: owner_inventory_id (UNIQUE)
- idx_owner_inv_owner: homeowner_id
- idx_owner_inv_property: property_id
- idx_owner_inv_item: item_id

---

## 4. inventory.company_inventory

**PURPOSE:** Tracks company-owned equipment and assets. Items may be assigned to team members, located at properties, or in central storage. Supports asset management and depreciation tracking.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| company_inventory_id | text | NOT NULL, UNIQUE | Business ID: CINV-NNNNNN | N/A |
| item_id | uuid | FK → inventory.inventory_items(id), NOT NULL | Catalog item | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| assigned_to_id | uuid | FK → team.team_directory(id) | Assigned team member | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| current_property_id | uuid | FK → property.properties(id) | Current location property | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| asset_tag | text | UNIQUE | Internal asset tag |
| serial_number | text | | Manufacturer serial |
| status | text | DEFAULT 'available' | available, assigned, in_use, maintenance, retired |
| condition | text | | new, good, fair, poor |
| purchase_date | date | | Acquisition date |
| purchase_cost | numeric(10,2) | | Original cost |
| vendor_company_id | uuid | FK → directory.companies(id) | Where purchased | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| warranty_expiry | date | | Warranty end |
| depreciation_method | text | | straight_line, declining_balance |
| useful_life_years | integer | | For depreciation |
| salvage_value | numeric(10,2) | | End-of-life value |
| current_value | numeric(10,2) | | Book value |
| last_maintenance_date | date | | Last service |
| next_maintenance_date | date | | Scheduled service |
| maintenance_notes | text | | Service history |
| location_notes | text | | Current location details |
| notes | text | | General notes |
| retired_date | date | | When retired |
| retirement_reason | text | | Why retired |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_company_inv_id: company_inventory_id (UNIQUE)
- idx_company_inv_item: item_id
- idx_company_inv_assigned: assigned_to_id WHERE assigned_to_id IS NOT NULL
- idx_company_inv_location: current_property_id WHERE current_property_id IS NOT NULL
- idx_company_inv_asset_tag: asset_tag WHERE asset_tag IS NOT NULL (UNIQUE)

---

## 5. inventory.storage_inventory

**PURPOSE:** Tracks bulk inventory stored in warehouse/storage locations. Supports quantity on hand, reorder points, lot tracking, and expiration dates for consumables.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| storage_inventory_id | text | NOT NULL, UNIQUE | Business ID: SINV-NNNNNN | N/A |
| item_id | uuid | FK → inventory.inventory_items(id), NOT NULL | Catalog item | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| location_id | uuid | FK → inventory.storage_locations(id), NOT NULL | Storage location | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| last_counted_by_id | uuid | FK → team.team_directory(id) | Last counter | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| quantity_on_hand | integer | NOT NULL, DEFAULT 0 | Current stock |
| quantity_reserved | integer | DEFAULT 0 | Reserved for orders |
| quantity_available | integer | GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED | Available stock |
| reorder_point | integer | | Location-specific reorder level |
| reorder_quantity | integer | | Location-specific order qty |
| lot_number | text | | Batch/lot tracking |
| expiration_date | date | | For perishables |
| last_count_date | date | | Last physical count |
| last_count_quantity | integer | | Quantity at last count |
| unit_cost | numeric(10,2) | | Current unit cost |
| total_value | numeric(12,2) | GENERATED ALWAYS AS (quantity_on_hand * unit_cost) STORED | Stock value |
| bin_location | text | | Specific bin/shelf |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**UNIQUE CONSTRAINT:** (item_id, location_id, lot_number) — One record per item/location/lot

**INDEXES:**
- idx_storage_inv_id: storage_inventory_id (UNIQUE)
- idx_storage_inv_item: item_id
- idx_storage_inv_location: location_id
- idx_storage_inv_reorder: quantity_on_hand WHERE quantity_on_hand <= reorder_point
- idx_storage_inv_expiry: expiration_date WHERE expiration_date IS NOT NULL

---

## 6. inventory.storage_locations

**PURPOSE:** Hierarchical warehouse location structure. Supports nested locations (warehouse → aisle → shelf → bin). Self-referencing for parent-child relationships.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| location_id | text | NOT NULL, UNIQUE | Business ID: LOC-NNNN | N/A |
| parent_location_id | uuid | FK → inventory.storage_locations(id) | Parent location | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| location_code | text | NOT NULL, UNIQUE | Short code (WH1, WH1-A1, WH1-A1-S1) |
| location_name | text | NOT NULL | Display name |
| location_type | text | NOT NULL | warehouse, area, aisle, shelf, bin |
| description | text | | Location details |
| address | text | | Physical address (for warehouses) |
| capacity_units | integer | | Max units capacity |
| capacity_volume_cuft | numeric(10,2) | | Volume capacity |
| is_climate_controlled | boolean | DEFAULT false | Temperature controlled |
| temperature_range | text | | Min-max temp |
| is_secure | boolean | DEFAULT false | Locked/secured |
| access_notes | text | | How to access |
| sort_order | integer | | Display ordering |
| is_active | boolean | DEFAULT true | Currently in use |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_storage_loc_id: location_id (UNIQUE)
- idx_storage_loc_parent: parent_location_id
- idx_storage_loc_code: location_code (UNIQUE)
- idx_storage_loc_type: location_type

---

## 7. inventory.inventory_purchases

**PURPOSE:** Tracks purchase orders for inventory items. Links items to suppliers, destinations, and who ordered. Supports order lifecycle from created through delivered.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| purchase_id | text | NOT NULL, UNIQUE | Business ID: INVPO-NNNNNN | N/A |
| item_id | uuid | FK → inventory.inventory_items(id), NOT NULL | Item ordered | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| supplier_company_id | uuid | FK → directory.companies(id), NOT NULL | Supplier | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| destination_property_id | uuid | FK → property.properties(id) | Delivery destination | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| destination_location_id | uuid | FK → inventory.storage_locations(id) | Storage destination | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| ordered_by_id | uuid | FK → team.team_directory(id) | Who placed order | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| po_number | text | | External PO number |
| order_date | date | NOT NULL | Date ordered |
| quantity_ordered | integer | NOT NULL | Units ordered |
| unit_cost | numeric(10,2) | NOT NULL | Cost per unit |
| total_cost | numeric(12,2) | GENERATED ALWAYS AS (quantity_ordered * unit_cost) STORED | Order total |
| shipping_cost | numeric(10,2) | DEFAULT 0 | Shipping charges |
| tax_amount | numeric(10,2) | DEFAULT 0 | Tax charged |
| grand_total | numeric(12,2) | GENERATED ALWAYS AS (quantity_ordered * unit_cost + COALESCE(shipping_cost, 0) + COALESCE(tax_amount, 0)) STORED | All-in cost |
| expected_delivery_date | date | | Estimated arrival |
| actual_delivery_date | date | | When received |
| quantity_received | integer | | Units actually received |
| status | text | DEFAULT 'pending' | pending, ordered, shipped, delivered, cancelled, partial |
| tracking_number | text | | Shipment tracking |
| carrier | text | | Shipping carrier |
| invoice_number | text | | Supplier invoice |
| notes | text | | Order notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_inv_purch_id: purchase_id (UNIQUE)
- idx_inv_purch_item: item_id
- idx_inv_purch_supplier: supplier_company_id
- idx_inv_purch_status: status WHERE status NOT IN ('delivered', 'cancelled')
- idx_inv_purch_destination: destination_property_id
- idx_inv_purch_po: po_number WHERE po_number IS NOT NULL

---

## 8. inventory.inventory_events

**PURPOSE:** Audit log of all inventory movements and changes. Tracks additions, removals, transfers, adjustments, and counts. Provides full traceability for inventory.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| event_id | text | NOT NULL, UNIQUE | Business ID: INVEV-NNNNNN | N/A |
| item_id | uuid | FK → inventory.inventory_items(id), NOT NULL | Item affected | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| property_id | uuid | FK → property.properties(id) | Related property | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| performed_by_id | uuid | FK → team.team_directory(id) | Who performed | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| from_location_id | uuid | FK → inventory.storage_locations(id) | Source location | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| to_location_id | uuid | FK → inventory.storage_locations(id) | Destination location | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| from_room_id | uuid | FK → property.rooms(id) | Source room | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| to_room_id | uuid | FK → property.rooms(id) | Destination room | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| event_type | text | NOT NULL | received, issued, transferred, adjusted, counted, damaged, disposed, returned |
| event_timestamp | timestamptz | NOT NULL, DEFAULT now() | When occurred |
| quantity | integer | NOT NULL | Units affected (positive/negative) |
| quantity_before | integer | | Stock before event |
| quantity_after | integer | | Stock after event |
| unit_cost | numeric(10,2) | | Cost at event time |
| total_value | numeric(12,2) | | Value of movement |
| reference_type | text | | purchase, ticket, inspection, adjustment, count |
| reference_id | uuid | | Related record ID |
| reference_number | text | | Human-readable reference |
| reason | text | | Why event occurred |
| notes | text | | Additional details |
| created_at | timestamptz | DEFAULT now() | Record creation |

**INDEXES:**
- idx_inv_events_id: event_id (UNIQUE)
- idx_inv_events_item: item_id
- idx_inv_events_property: property_id WHERE property_id IS NOT NULL
- idx_inv_events_date: event_timestamp
- idx_inv_events_type: event_type
- idx_inv_events_ref: reference_type, reference_id WHERE reference_id IS NOT NULL

---

## 9. inventory.linen_types

**PURPOSE:** Reference table defining linen categories. Master list of linen types with size, material, and color specifications. Used for par levels and ordering.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| linen_type_id | text | NOT NULL, UNIQUE | Business ID: LNT-NNNN | N/A |
| type_code | text | NOT NULL, UNIQUE | Short code: BATH_TOWEL, KING_SHEET, etc. |
| type_name | text | NOT NULL | Display name |
| category | text | NOT NULL | towels, sheets, blankets, pillows, other |
| size | text | | king, queen, full, twin, standard, bath, hand, wash |
| material | text | | cotton, microfiber, bamboo, blend |
| thread_count | integer | | For sheets |
| gsm | integer | | Grams per square meter (towels) |
| color | text | | Standard color |
| description | text | | Full description |
| standard_cost | numeric(10,2) | | Typical cost |
| replacement_frequency_months | integer | | Expected lifespan |
| is_premium | boolean | DEFAULT false | Premium/luxury item |
| sort_order | integer | | Display ordering |
| is_active | boolean | DEFAULT true | Currently in use |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_linen_types_id: linen_type_id (UNIQUE)
- idx_linen_types_code: type_code (UNIQUE)
- idx_linen_types_category: category

---

## 10. inventory.linen_items

**PURPOSE:** Individual linen tracking with barcode support. Each physical linen piece can be tracked through its lifecycle. Links to linen_types for categorization.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| linen_item_id | text | NOT NULL, UNIQUE | Business ID: LNI-NNNNNN | N/A |
| linen_type_id | uuid | FK → inventory.linen_types(id), NOT NULL | Linen type | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| barcode | text | UNIQUE | Barcode/RFID tag |
| status | text | DEFAULT 'in_service' | in_service, damaged, retired, lost, at_laundry |
| condition | text | DEFAULT 'good' | new, good, fair, poor |
| purchase_date | date | | When acquired |
| purchase_cost | numeric(10,2) | | Actual cost |
| first_use_date | date | | When put in service |
| wash_count | integer | DEFAULT 0 | Total washes |
| last_washed_at | timestamptz | | Last laundry |
| current_location | text | | property, laundry, storage |
| current_property_id | uuid | FK → property.properties(id) | Current property | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| retired_date | date | | When retired |
| retirement_reason | text | | Why retired |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_linen_items_id: linen_item_id (UNIQUE)
- idx_linen_items_type: linen_type_id
- idx_linen_items_status: status WHERE status != 'in_service'
- idx_linen_items_barcode: barcode WHERE barcode IS NOT NULL (UNIQUE)
- idx_linen_items_property: current_property_id WHERE current_property_id IS NOT NULL

---

## 11. inventory.linen_pars

**PURPOSE:** Par levels defining required linen quantities per property and optionally per room. Supports property-wide defaults with room-specific overrides.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| linen_par_id | text | NOT NULL, UNIQUE | Business ID: LNP-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| room_id | uuid | FK → property.rooms(id) | Specific room (NULL = property default) | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| linen_type_id | uuid | FK → inventory.linen_types(id), NOT NULL | Linen type | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| par_quantity | integer | NOT NULL | Required quantity |
| min_quantity | integer | | Minimum acceptable |
| max_quantity | integer | | Maximum to stock |
| notes | text | | Special instructions |
| is_active | boolean | DEFAULT true | Currently enforced |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**UNIQUE CONSTRAINT:** (property_id, room_id, linen_type_id) — One par per property/room/type combo

**INDEXES:**
- idx_linen_pars_id: linen_par_id (UNIQUE)
- idx_linen_pars_property: property_id
- idx_linen_pars_room: room_id WHERE room_id IS NOT NULL
- idx_linen_pars_type: linen_type_id

---

## 12. inventory.linen_deliveries

**PURPOSE:** Tracks linen deliveries from linen service providers. Records what was delivered, when, and by whom. Supports both exchange service and purchase deliveries.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| delivery_id | text | NOT NULL, UNIQUE | Business ID: LND-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Delivery destination | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| linen_service_company_id | uuid | FK → directory.companies(id), NOT NULL | Linen service provider | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| delivery_date | date | NOT NULL | When delivered |
| delivery_time | time | | Delivery time |
| delivery_type | text | DEFAULT 'exchange' | exchange, purchase, rental |
| delivered_by | text | | Driver name |
| received_by_id | uuid | FK → team.team_directory(id) | Who received | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| items_delivered | jsonb | | {type_code: quantity} delivered |
| items_picked_up | jsonb | | {type_code: quantity} picked up |
| delivery_notes | text | | Delivery notes |
| condition_notes | text | | Condition observations |
| invoice_number | text | | Service invoice |
| invoice_amount | numeric(10,2) | | Invoice total |
| status | text | DEFAULT 'completed' | scheduled, in_transit, completed, cancelled |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_linen_del_id: delivery_id (UNIQUE)
- idx_linen_del_property: property_id
- idx_linen_del_company: linen_service_company_id
- idx_linen_del_date: delivery_date

---

## 13. inventory.linen_counts

**PURPOSE:** Periodic linen counts for inventory verification. Compares actual counts against par levels. Identifies discrepancies for investigation.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| count_id | text | NOT NULL, UNIQUE | Business ID: LNC-NNNNNN | N/A |
| property_id | uuid | FK → property.properties(id), NOT NULL | Property counted | ON DELETE: CASCADE, ON UPDATE: CASCADE |
| counted_by_id | uuid | FK → team.team_directory(id), NOT NULL | Who counted | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| count_date | date | NOT NULL | Date of count |
| count_type | text | DEFAULT 'routine' | routine, spot_check, audit, turnover |
| counts | jsonb | NOT NULL | {type_code: {counted, expected, variance}} |
| total_items_counted | integer | | Total pieces counted |
| total_discrepancies | integer | | Items with variance |
| discrepancy_value | numeric(10,2) | | Estimated value of discrepancies |
| notes | text | | Count observations |
| verified_by_id | uuid | FK → team.team_directory(id) | Supervisor verification | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| verified_at | timestamptz | | When verified |
| status | text | DEFAULT 'completed' | in_progress, completed, verified |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_linen_counts_id: count_id (UNIQUE)
- idx_linen_counts_property: property_id
- idx_linen_counts_date: count_date
- idx_linen_counts_counter: counted_by_id

---

## 14. inventory.linen_issues

**PURPOSE:** Tracks linen damage, stains, loss, and quality issues. Links to specific linen items when tracked individually. Supports investigation and replacement workflow.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| issue_id | text | NOT NULL, UNIQUE | Business ID: LNIS-NNNNNN | N/A |
| linen_item_id | uuid | FK → inventory.linen_items(id) | Specific item (if tracked) | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| linen_type_id | uuid | FK → inventory.linen_types(id), NOT NULL | Linen type | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| property_id | uuid | FK → property.properties(id) | Where discovered | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| reported_by_id | uuid | FK → team.team_directory(id) | Who reported | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| reservation_id | uuid | FK → reservations.reservations(id) | Related reservation | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| issue_type | text | NOT NULL | damage, stain, missing, wear, quality |
| issue_date | date | NOT NULL | When discovered |
| quantity | integer | DEFAULT 1 | Number affected |
| description | text | | Issue details |
| photo_urls | text[] | | Documentation photos |
| estimated_value | numeric(10,2) | | Replacement cost |
| cause | text | | guest, wear, laundry, unknown |
| is_billable | boolean | DEFAULT false | Charge to guest |
| status | text | DEFAULT 'open' | open, investigating, resolved, written_off |
| resolution | text | | How resolved |
| resolved_by_id | uuid | FK → team.team_directory(id) | Who resolved | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| resolved_at | timestamptz | | When resolved |
| notes | text | | Internal notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_linen_issues_id: issue_id (UNIQUE)
- idx_linen_issues_item: linen_item_id
- idx_linen_issues_property: property_id WHERE property_id IS NOT NULL
- idx_linen_issues_status: status WHERE status = 'open'
- idx_linen_issues_reservation: reservation_id WHERE reservation_id IS NOT NULL

---

## 15. inventory.linen_orders

**PURPOSE:** Purchase orders for new linens. Tracks orders from suppliers with quantities by linen type. Supports order lifecycle from placed through received.

| Column | Type | Constraints | Description | FK Actions |
|--------|------|-------------|-------------|------------|
| id | uuid | PK, NOT NULL, DEFAULT generate_uuid_v7() | UUIDv7 primary key | N/A |
| order_id | text | NOT NULL, UNIQUE | Business ID: LNPO-NNNNNN | N/A |
| linen_type_id | uuid | FK → inventory.linen_types(id), NOT NULL | Linen type ordered | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| supplier_company_id | uuid | FK → directory.companies(id), NOT NULL | Supplier | ON DELETE: RESTRICT, ON UPDATE: CASCADE |
| ordered_by_id | uuid | FK → team.team_directory(id) | Who placed order | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| destination_property_id | uuid | FK → property.properties(id) | Delivery destination | ON DELETE: SET NULL, ON UPDATE: CASCADE |
| po_number | text | | External PO number |
| order_date | date | NOT NULL | Date ordered |
| quantity_ordered | integer | NOT NULL | Units ordered |
| unit_cost | numeric(10,2) | NOT NULL | Cost per unit |
| total_cost | numeric(12,2) | GENERATED ALWAYS AS (quantity_ordered * unit_cost) STORED | Order total |
| shipping_cost | numeric(10,2) | DEFAULT 0 | Shipping charges |
| expected_delivery_date | date | | Estimated arrival |
| actual_delivery_date | date | | When received |
| quantity_received | integer | | Units actually received |
| status | text | DEFAULT 'pending' | pending, ordered, shipped, received, cancelled, partial |
| tracking_number | text | | Shipment tracking |
| invoice_number | text | | Supplier invoice |
| notes | text | | Order notes |
| created_at | timestamptz | DEFAULT now() | Record creation |
| updated_at | timestamptz | DEFAULT now() | Last update |

**INDEXES:**
- idx_linen_orders_id: order_id (UNIQUE)
- idx_linen_orders_type: linen_type_id
- idx_linen_orders_supplier: supplier_company_id
- idx_linen_orders_status: status WHERE status NOT IN ('received', 'cancelled')
- idx_linen_orders_destination: destination_property_id WHERE destination_property_id IS NOT NULL

---

# REF TABLES REQUIRED

## ref.inventory_item_types

**PURPOSE:** Master list of inventory item type codes used in inventory_items.item_id business ID generation. Each code represents a category of items.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| type_code | text | PK | Short code: TWLB, VACU, LPTP, etc. |
| type_name | text | NOT NULL | Display name |
| category | text | NOT NULL | cleaning, linens, electronics, furniture, kitchen, outdoor, safety, office |
| description | text | | Full description |
| is_consumable | boolean | DEFAULT false | Used up vs. durable |
| typical_lifespan_months | integer | | Expected useful life |
| sort_order | integer | | Display ordering |
| is_active | boolean | DEFAULT true | Currently in use |

**SAMPLE DATA:**
| type_code | type_name | category |
|-----------|-----------|----------|
| TWLB | Bath Towel | linens |
| TWLH | Hand Towel | linens |
| TWLW | Washcloth | linens |
| SHTS | Sheet Set | linens |
| VACU | Vacuum | cleaning |
| LPTP | Laptop | electronics |
| TLET | Television | electronics |
| COFF | Coffee Maker | kitchen |
| DISH | Dishes | kitchen |
| FRNT | Furniture | furniture |
| SMOK | Smoke Detector | safety |
| CMON | CO Monitor | safety |
| FEXT | Fire Extinguisher | safety |
| DECO | Decor | furniture |
| OUTD | Outdoor Furniture | outdoor |
| POOL | Pool Equipment | outdoor |

---

# CROSS-SCHEMA DEPENDENCIES

## Inventory → Other Schemas

| This Table | References | Target Schema.Table |
|------------|------------|---------------------|
| inventory_items | supplier_company_id | directory.companies |
| inventory_items | type_code | ref.inventory_item_types |
| room_inventory | room_id | property.rooms |
| room_inventory | last_inspection_id | property.inspections |
| owner_inventory | homeowner_id | directory.homeowners |
| owner_inventory | property_id | property.properties |
| company_inventory | assigned_to_id | team.team_directory |
| company_inventory | current_property_id | property.properties |
| company_inventory | vendor_company_id | directory.companies |
| storage_inventory | last_counted_by_id | team.team_directory |
| inventory_purchases | supplier_company_id | directory.companies |
| inventory_purchases | destination_property_id | property.properties |
| inventory_purchases | ordered_by_id | team.team_directory |
| inventory_events | property_id | property.properties |
| inventory_events | performed_by_id | team.team_directory |
| inventory_events | from_room_id, to_room_id | property.rooms |
| linen_deliveries | property_id | property.properties |
| linen_deliveries | linen_service_company_id | directory.companies |
| linen_deliveries | received_by_id | team.team_directory |
| linen_counts | property_id | property.properties |
| linen_counts | counted_by_id, verified_by_id | team.team_directory |
| linen_issues | property_id | property.properties |
| linen_issues | reported_by_id, resolved_by_id | team.team_directory |
| linen_issues | reservation_id | reservations.reservations |
| linen_orders | supplier_company_id | directory.companies |
| linen_orders | ordered_by_id | team.team_directory |
| linen_orders | destination_property_id | property.properties |
| linen_items | current_property_id | property.properties |

## Other Schemas → Inventory

| Source Schema.Table | References | This Table |
|---------------------|------------|------------|
| property.inspection_question_inventory_links | item_id | inventory.inventory_items |

---

# KEY WORKFLOWS

## 1. Item Lifecycle

```
1. Item created in inventory_items (catalog entry)
2. Purchase order created (inventory_purchases)
3. Item received → inventory_event logged (type: received)
4. Item placed in storage (storage_inventory) or room (room_inventory)
5. Item transferred → inventory_event logged (type: transferred)
6. Item damaged/retired → inventory_event logged (type: disposed)
```

## 2. Room Inventory Check (During Inspection)

```
1. Inspection created for property
2. Inspector checks room_inventory for each room
3. Compare actual vs expected_quantity
4. Log discrepancies (status: missing, damaged)
5. Create service ticket if action needed
6. Update last_inspection_id on room_inventory
```

## 3. Linen Par Enforcement

```
1. linen_pars define required quantities per property/room
2. linen_counts record actual counts
3. Compare counts.counted vs pars.par_quantity
4. If shortage: create linen_orders
5. When delivered: log in linen_deliveries
6. Update linen_items status
```

## 4. Owner Inventory Documentation

```
1. New property onboarding
2. Walk-through documents owner_inventory items
3. Photos captured and linked
4. Values estimated for insurance
5. Changes logged during inspections
6. Move-out reconciliation against original inventory
```

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-09  
**UUIDv7 Migration:** V4.1 Schema Specification  
**Total Tables:** 15 (8 core + 7 linen-specific)  
**Ref Tables Required:** 1 (ref.inventory_item_types)
