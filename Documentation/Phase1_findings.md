# Phase 1: Data Quality Audit

Raw file: 10,324 shipment records, USAID Supply Chain Shipment Pricing Dataset. Loaded without type inference (every column as text) to preserve original values for inspection before any cleaning.

| Field | Usable value | Structured placeholder | Genuinely missing |
|---|---|---|---|
| Weight (Kilograms) | 61.7% | 19.7% (cross-referenced or captured separately) | 18.7% |
| Freight Cost (USD) | 60.0% | 21.9% (bundled, invoiced separately, or cross-referenced) | 18.7% |
| PO Sent to Vendor Date | 44.5% | 52.3% ("N/A - From RDC") | 3.2% |

Roughly half of PO date values are tagged "N/A - From RDC," suggesting shipments routed through a Regional Distribution Center don't carry a clean single vendor purchase order date, a real operational pattern in how this program distributes goods, not a random data gap. Weight and freight cost show similar structure: bundled pricing and cross-referenced records account for most of what looks missing at first glance, rather than pure data loss.

Two date columns use different formats internally: `Scheduled Delivery Date` as day-month-year (`2-Jun-06`), `PO Sent to Vendor Date` as month/day/year (`11/13/06`), requiring separate parsing logic in Phase 2.

`Scheduled Delivery Date`, `Delivered to Client Date`, and `Delivery Recorded Date` were confirmed fully clean, no placeholder text found in any of the three.
