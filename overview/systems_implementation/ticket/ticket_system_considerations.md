Here’s a consolidated brain-dump of **all the major considerations** we used to shape this ticket structure (single ticket table + join tables + projects + recurring + time/finance/inventory/etc.).

I’ll group them so it’s easier to scan.

---

## 1. Core Modeling Philosophy

* **Single ticket table, not per-domain tables**

  * We explicitly chose **one canonical `team.tickets` table** for *all* ticket types (property care, reservations, accounting, admin).
  * Reason: avoid schema sprawl, avoid complex cross-ticket reporting, make it easy for AI agents and dashboards to work with a single source of truth.

* **Use join tables for relationships and nuance**

  * Instead of adding more ticket tables, we hung context off tickets using **`X ↔ ticket` join tables** (shifts, time entries, inspections, cleans, inventory events, transactions, photos, recurring rules, projects, etc.).
  * Reason: keep `team.tickets` clean and generic, and keep relationships flexible, many-to-many, and metadata-rich.

* **Tickets are “work objects”, not domain objects**

  * Properties, reservations, inspections, transactions, inventory, etc. are **domain facts**.
  * Tickets sit on top as “we need to do something about those facts”.
  * Reason: keeps domain data stable and tickets focused on workflow.

---

## 2. Ticket Context & Business Rules

* **Property & reservation as primary context**

  * `property_id` and `reservation_id` live directly on `team.tickets` so you can quickly answer:

    * “All tickets for Property X”
    * “All tickets for Reservation Y”
  * Reason: these are the most common filters and reporting axes.

* **Allow `property_id` / `reservation_id` to be nullable depending on `ticket_type`**

  * For **property-care** tickets → `property_id` should be required.
  * For **reservation** tickets → `reservation_id` should be required.
  * For **admin** tickets → it’s valid to have **no property**.
  * For **accounting** tickets → property can be optional depending on subtype.
  * Reason: enforce discipline where it matters, but still allow global/system tickets.

* **One property per operational ticket**

  * For **day-to-day work** (repairs, field work, cleans, inspections), we decided:

    * **1 ticket = 1 property**.
  * If multiple properties are impacted, either:

    * Create multiple tickets **or**
    * Use projects + property checklists.
  * Reason: avoids double-counting time/cost and keeps metrics per property clean.

* **Handling multi-property scenarios**

  * For admin / portfolio / system work (“update X for all units in Resort Y”):

    * One admin ticket + `ticket_properties` or **project + project_properties** for the property checklist.
  * Multi-property tickets are **allowed** for admin/system contexts via join tables, but not used for operational field work.

* **Homeowner vs property vs homeowner_property**

  * Tickets **anchor on `property_id`** for operations and finance.
  * `homeowner_id` on `team.tickets` is for a primary owner contact (often the requestor).
  * `homeowner_property` (ownership join) remains in the property/finance domain, not duplicated on tickets unless necessary.
  * Reason: financial/ownership details live in the correct domain; tickets just reference them when needed.

---

## 3. Participants, Notifications, & Roles

* **Separate participants model (`ticket_participants`)**

  * Instead of encoding notifications/CC in columns on tickets, we created:

    * `team.ticket_participants (ticket_id, contact_id, role, notify)`
  * Roles: `requestor`, `owner`, `guest`, `vendor`, `internal_cc`, etc.
  * Reason: flexible and supports multiple people linked to one ticket with explicit notification control.

* **Decoupling ownership from notifications**

  * Not every owner or stakeholder automatically gets notification.
  * `homeowner_properties.receives_notifications` (in property domain) + `ticket_participants.notify` together decide who gets notified.
  * Reason: control communication granularity per owner / per ticket.

---

## 4. Join Table Strategy (All the “X ↔ Ticket” Joins)

* **Use join tables whenever:**

  * Relationships can be **many-to-many** (a time entry for multiple tickets; a ticket linked to multiple inventory events).
  * We need **relationship-specific metadata** (role, quantity_used, allocated_seconds, relationship type).
  * The association may evolve or take on extra meaning over time.

* **Specific joins we intentionally modeled:**

  * `ticket_shifts` – which shifts worked a ticket and in what role.
  * `ticket_time_entries` – how much of a time entry is allocated to a ticket.
  * `shift_time_entries` & `inspection_time_entries` – relate time entries to shifts and inspections.
  * `ticket_inspections` – how a ticket and inspection relate (found_by, followup, verification).
  * `ticket_cleans` – relationship to cleans (found during clean, caused reclean).
  * `ticket_inventory_events` – which inventory actions are part of a ticket and their cost/quantity.
  * `ticket_transactions` – which finance transactions (expenses, refunds, owner charges) are associated.
  * `ticket_photos` – files/photos attached to a ticket and the type (before, after, damage, receipt).
  * `ticket_recurring` – which tickets were spawned by which recurring rule.
  * `ticket_properties`, `ticket_homeowners`, `ticket_vendors` – multi-entity context beyond the primary direct FKs.

* **Rule of thumb we followed:**

  * **Domain data** (inspection details, transaction amounts, inventory item details) stay in their domain tables.
  * **Relationship meaning** (role, allocation, type of connection) live in the join tables.

---

## 5. Time & Cost Tracking

* **Time entries as a central “fact”**

  * `team.time_entries` = “member X worked from A to B”.
  * This is one canonical record of time — not duplicated across tickets, inspections, shifts.

* **Allocated time per ticket / inspection / shift via joins**

  * `ticket_time_entries` allocates portions of a time entry to tickets.
  * `inspection_time_entries` allocates to inspections.
  * `shift_time_entries` allocates to shifts.
  * Reason: same time entry can be viewed simultaneously as:

    * Part of a ticket,
    * Part of a shift,
    * Part of an inspection.

* **Labor cost derived from time entries**

  * `hourly_rate_cents` on `time_entries`, combined with durations and allocations, can compute:

    * Cost per ticket.
    * Cost per property.
    * Cost per project.
  * Reason: track all labor costs against tickets/properties without repeating amount fields on tickets.

---

## 6. Inventory, Finance, and Physical Work

* **Inventory tracked in property domain, linked via joins**

  * `property.inventory_actions` represent “real inventory events”.
  * `ticket_inventory_events` connects those events to tickets and adds quantity_used, unit_cost, etc.
  * Reason: inventory remains the source of truth while providing ticket-level visibility.

* **Finance tracked in finance domain, linked via joins**

  * `finance.transactions` hold amounts, types, and property/reservation context.
  * `ticket_transactions` connect those transactions to tickets with a role (`expense`, `owner_charge`, `refund`, etc.).
  * Reason: precise, auditable financial records stay in finance; tickets reference but don’t own the money.

* **Inspections & cleans as domain facts**

  * `property.inspections` and `property.cleans` hold the inspection/clean details.
  * Tickets relate via `ticket_inspections` and `ticket_cleans`.
  * Reason: one inspection/clean may relate to multiple tickets, and tickets can be opened before or after those events.

---

## 7. Projects & Portfolio-Level Work

* **Projects as umbrella tasks**

  * `team.projects` represent “do this thing across many entities”:

    * Add labels to all listings in a resort.
    * Swap a standard item in all properties.
    * Apply a new policy property-wide.

* **Per-property checklist**

  * `project_properties` tracks progress per property (`status`, `completed_at`, `notes`).
  * Works even when no ticket is needed (simple tasks).

* **Tickets per property for deeper tracking**

  * `project_tickets` links **tickets to projects** when we need full ticket-level tracking per property.
  * Reason: you can choose whether a project is:

    * Just a checklist, or
    * A set of fully managed tickets, or
    * A combination.

---

## 8. Recurring Work (Per Property, Per Reservation, etc.)

* **Separate recurring rule definition**

  * `recurring_rules` defines cadence (monthly, quarterly, per reservation) and scope_type (property, resort, reservation, portfolio).
  * `recurring_rule_targets` defines which properties/resorts/reservations each rule applies to.

* **Tickets generated and annotated**

  * When a recurring rule fires, it creates tickets in `team.tickets` and records them in `ticket_recurring`.
  * Reason: supports:

    * “One recurring ticket per property per quarter”
    * “One ticket per reservation”
    * “Portfolio-level recurring work”, all still within the single tickets table.

---

## 9. Handling “No Property” Cases

* **We intentionally allowed propertyless tickets for certain types**

  * Particularly:

    * Admin / system tickets (e.g. “fix PMS integration”, “update pricing rules engine”).
    * Some accounting tickets (e.g. trust account reconciliation, global portfolio adjustments).

* **We kept the rules strict by type, not loose everywhere**

  * Even with one table, we designed it so `ticket_type` can drive constraints:

    * `property_care` ⇒ must have `property_id`.
    * `reservation` ⇒ must have `reservation_id`.
    * `admin` & some `accounting` ⇒ allowed to have `property_id` NULL.
  * Reason: avoid sloppy data while still supporting global/system work.

---

## 10. Usability, Permissions, and Agent Behavior

* **Single table is simpler for AI and BI**

  * One `team.tickets` table to query for:

    * “All open tickets”
    * “Tickets by type, by property, by owner, by agent, by project, by SLA”
  * Reason: easier query patterns, less complexity for agents and dashboards.

* **Join tables make permissions clear**

  * Permissions can be applied by:

    * Ticket type
    * Property/reservation context
    * Project membership
  * And join tables (e.g. `ticket_participants`, `ticket_properties`) drive who is allowed to see what.

* **Keeping domain tables separate**

  * Inspections, cleans, inventory, reservations, transactions, etc. stay in their own schemas.
  * Tickets reference them, but the business logic and data integrity for those domains doesn’t depend on the ticket system.
  * Reason: allows domains to evolve without constantly reshaping tickets.

---

## 11. Future-Proofing & Extensibility

* **Adding new ticket types is cheap**

  * To support a new type (e.g. `compliance`, `IT_support`), you typically only:

    * Add a new `ticket_type` value.
    * Add a new join table if there’s a new relationship type (e.g. `ticket_compliance_items`).
  * No new core ticket tables needed.

* **Supports more metrics and analytics later**

  * With this structure you can add:

    * SLAs (`ticket_slas`, `ticket_sla_events`).
    * Ticket events (`ticket_events`) for status changes, comments, reassignments.
    * Labeling/tagging (`ticket_labels`) for AI and triage.
  * All without changing the single `team.tickets` model.

---

If you want, I can next turn this into a concise **“Design Principles” section** that you drop at the top of the ticketing spec, so anyone reading the schema understands *why* it looks the way it does, not just *what* the tables are.
