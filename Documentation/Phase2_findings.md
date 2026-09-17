# Phase 2: Data Cleaning

Converted raw text-only columns into usable numeric and date fields, using Python (pandas), while preserving the reason behind every value that couldn't be converted, rather than silently discarding it.

## What changed

- **Weight (Kilograms) → `weight_kg_clean`**: genuine numeric values converted; non-numeric entries preserved in a separate `weight_status` column (`cross_referenced`, `captured_separately`, `missing`)
- **Freight Cost (USD) → `freight_usd_clean`**: same pattern, `freight_status` tracks `cross_referenced`, `bundled_in_commodity`, `invoiced_separately`, `missing`
- **Scheduled Delivery Date → `scheduled_delivery_clean`**: parsed as a real date (format: `DD-Mon-YY`), fully clean, no placeholder text found
- **PO Sent to Vendor Date → `po_sent_clean`**: parsed as a real date (format: `MM/DD/YY`); `po_sent_status` tracks `na_from_rdc`, `not_captured`, `real_date`

## Verification

Every category count after cleaning was cross-checked against Phase 1's manual SQL audit and matched exactly, confirming no rows were silently dropped or miscategorized during conversion.

## A note on password handling

The MySQL connection string uses `urllib.parse.quote_plus` to safely encode the database password before building the connection URI. This matters because SQLAlchemy connection strings are parsed as URLs, special characters in a raw password (`@`, `#`, `/`, etc.) can otherwise be misread as part of the URL structure itself rather than the password, silently breaking the connection or, worse, connecting to the wrong place. `quote_plus` escapes those characters safely.

## Output

- `shipments_clean.csv`, the cleaned file
- `clean_shipments` table loaded into MySQL, sitting alongside the untouched `raw_shipments` table
