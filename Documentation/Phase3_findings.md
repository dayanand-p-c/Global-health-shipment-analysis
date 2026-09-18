# Phase 3: The RDC Cost-Visibility Tradeoff

## Why this question

Phase 1's data quality audit found that 52.3% of `PO Sent to Vendor Date` values
were tagged `"N/A - From RDC"`, not random missingness, a named, specific reason.
This phase tests whether that data gap is structurally connected to how shipments
are routed, rather than treating it as noise to clean past.

## The confirmed connection

Every shipment routed `"From RDC"` (Regional Distribution Center) carries the
missing PO-date flag: 100%, no exceptions, across 5,404 shipments. This is not
a coincidence. It's a structural signature: RDC routing itself creates a
procurement-documentation gap, likely because a shipment consolidated at a
regional hub loses its direct, traceable link back to a single vendor PO.

## The cost side, and a correction worth documenting

The first attempt to compare cost efficiency, averaging each shipment's
individual freight-cost-per-kilogram, showed RDC shipments costing 54% more
per kg than Direct Drop. That number is wrong, and the reason is instructive:
averaging per-shipment ratios lets small shipments distort the result regardless
of how much actual freight volume they represent. Investigating outliers (very
low weight, very high cost-per-kg values) confirmed some data entry errors, but
excluding them barely changed the number, revealing the averaging *method*
itself, not just a few bad rows, was the real problem.

The corrected approach uses a weighted rate: total freight cost divided by
total weight, across each group. This reversed the finding entirely:

| Fulfill Via | Shipments | Total Freight Cost | Total Weight (kg) | Blended Cost/kg |
|---|---|---|---|---|
| Direct Drop | 2,982 | $33,913,289 | 7,455,594 | $4.55 |
| From RDC | 3,193 | $34,774,471 | 13,727,598 | $2.53 |

RDC routing is actually **44% cheaper per kilogram**, not more expensive.

## The finding

This is a genuine tradeoff, not a simple good/bad conclusion. Routing shipments
through a Regional Distribution Center is measurably more cost-efficient, and
it comes at the cost of losing procurement-level traceability on every shipment
that passes through it. A program relying more heavily on RDC routing to control
freight costs is, by the same structural mechanism, flying increasingly blind
on where its purchase orders originated.
