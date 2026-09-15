-- Phase 1: Data Quality Audit
-- USAID Supply Chain Shipment Pricing Dataset

-- Confirm true row count after import
SELECT COUNT(*) AS total_rows FROM raw_shipments;

-- Check what non-numeric values exist in the weight column
SELECT DISTINCT `Weight (Kilograms)`
FROM raw_shipments
WHERE `Weight (Kilograms)` NOT REGEXP '^[0-9]'
LIMIT 20;

-- Categorize and count every value in the weight column
SELECT
  CASE
    WHEN `Weight (Kilograms)` REGEXP '^See ASN' THEN 'Cross-referenced to another ASN'
    WHEN `Weight (Kilograms)` = 'Weight Captured Separately' THEN 'Captured separately'
    WHEN `Weight (Kilograms)` REGEXP '^[0-9]' THEN 'Real number'
    ELSE 'Other/blank'
  END AS weight_category,
  COUNT(*) AS row_count
FROM raw_shipments
GROUP BY weight_category;

-- Check what non-numeric values exist in the freight cost column
SELECT DISTINCT `Freight Cost (USD)`
FROM raw_shipments
WHERE `Freight Cost (USD)` NOT REGEXP '^[0-9]'
LIMIT 20;

-- Categorize and count every value in the freight cost column
SELECT
  CASE
    WHEN `Freight Cost (USD)` REGEXP '^See ASN' THEN 'Cross-referenced to another ASN'
    WHEN `Freight Cost (USD)` = 'Freight Included in Commodity Cost' THEN 'Bundled into commodity cost'
    WHEN `Freight Cost (USD)` = 'Invoiced Separately' THEN 'Invoiced separately, not in this data'
    WHEN `Freight Cost (USD)` REGEXP '^[0-9]' THEN 'Real number'
    ELSE 'Other/blank'
  END AS freight_category,
  COUNT(*) AS row_count
FROM raw_shipments
GROUP BY freight_category;

-- Confirm Scheduled Delivery Date is fully clean (no placeholder text found)
SELECT DISTINCT `Scheduled Delivery Date`
FROM raw_shipments
WHERE `Scheduled Delivery Date` LIKE '%N/A%'
   OR `Scheduled Delivery Date` LIKE '%Not Captured%'
   OR `Scheduled Delivery Date` LIKE '%RDC%'
   OR `Scheduled Delivery Date` LIKE '%Truck%';

-- Confirm Delivered to Client Date and Delivery Recorded Date are also clean
SELECT DISTINCT `Delivered to Client Date`
FROM raw_shipments
WHERE `Delivered to Client Date` LIKE '%N/A%'
   OR `Delivered to Client Date` LIKE '%Not Captured%'
   OR `Delivered to Client Date` LIKE '%RDC%'
   OR `Delivered to Client Date` LIKE '%Truck%';

-- Categorize and count PO Sent to Vendor Date, the one contaminated date column
SELECT
  CASE
    WHEN `PO Sent to Vendor Date` = 'Date Not Captured' THEN 'Date not captured'
    WHEN `PO Sent to Vendor Date` = 'N/A - From RDC' THEN 'N/A, from RDC'
    ELSE 'Real date'
  END AS po_date_category,
  COUNT(*) AS row_count
FROM raw_shipments
GROUP BY po_date_category;
