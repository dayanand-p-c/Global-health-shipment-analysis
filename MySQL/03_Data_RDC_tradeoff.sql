-- Phase 3: RDC vs Direct Drop, cost-efficiency analysis
-- Investigates whether fulfillment route is associated with differences
-- in shipment volume, freight cost, shipment weight, and cost per kg.

-- Confirm the fulfillment paths and their shipment volume
SELECT DISTINCT
  `Fulfill Via`,
  COUNT(*) AS shipment_count
FROM clean_shipments
GROUP BY `Fulfill Via`
ORDER BY shipment_count DESC;

-- Test whether the PO-date gap is structurally tied to fulfillment route
SELECT
  `Fulfill Via`,
  po_sent_status,
  COUNT(*) AS shipment_count
FROM clean_shipments
GROUP BY `Fulfill Via`, po_sent_status
ORDER BY `Fulfill Via`, shipment_count DESC;

-- First attempt at cost comparison:
-- average of individual shipment-level cost-per-kg ratios
SELECT
  `Fulfill Via`,
  COUNT(*) AS shipment_count,
  ROUND(AVG(freight_usd_clean), 2) AS avg_freight_cost,
  ROUND(AVG(freight_usd_clean / NULLIF(weight_kg_clean, 0)), 2) AS avg_cost_per_kg
FROM clean_shipments
WHERE freight_status = 'real_number'
  AND weight_status = 'real_number'
GROUP BY `Fulfill Via`;

-- Compare average shipment weight and freight cost by fulfillment route
SELECT
  `Fulfill Via`,
  ROUND(AVG(weight_kg_clean), 1) AS avg_weight_kg,
  ROUND(AVG(freight_usd_clean), 2) AS avg_freight_cost
FROM clean_shipments
WHERE weight_status = 'real_number'
  AND freight_status = 'real_number'
GROUP BY `Fulfill Via`;

-- Diagnostic: inspect very low-weight shipments with extreme cost-per-kg
SELECT
  `Fulfill Via`,
  weight_kg_clean,
  freight_usd_clean,
  ROUND(freight_usd_clean / weight_kg_clean, 2) AS cost_per_kg
FROM clean_shipments
WHERE weight_status = 'real_number'
  AND freight_status = 'real_number'
  AND weight_kg_clean < 5
ORDER BY cost_per_kg DESC
LIMIT 20;

-- Sensitivity check: exclude shipments below 1 kg
SELECT
  `Fulfill Via`,
  COUNT(*) AS shipment_count,
  ROUND(AVG(freight_usd_clean), 2) AS avg_freight_cost,
  ROUND(AVG(freight_usd_clean / weight_kg_clean), 2) AS avg_cost_per_kg
FROM clean_shipments
WHERE freight_status = 'real_number'
  AND weight_status = 'real_number'
  AND weight_kg_clean >= 1
GROUP BY `Fulfill Via`;

-- Quantify low-weight observations in the valid cost dataset
SELECT
  COUNT(*) AS total_valid_rows,
  SUM(CASE WHEN weight_kg_clean < 10 THEN 1 ELSE 0 END) AS excluded_low_weight
FROM clean_shipments
WHERE freight_status = 'real_number'
  AND weight_status = 'real_number';

-- Corrected comparison: weighted/blended cost per kg
-- Total freight cost / total shipment weight
SELECT
  `Fulfill Via`,
  COUNT(*) AS shipment_count,
  ROUND(SUM(freight_usd_clean), 2) AS total_freight_cost,
  ROUND(SUM(weight_kg_clean), 2) AS total_weight_kg,
  ROUND(SUM(freight_usd_clean) / SUM(weight_kg_clean), 2) AS blended_cost_per_kg
FROM clean_shipments
WHERE freight_status = 'real_number'
  AND weight_status = 'real_number'
GROUP BY `Fulfill Via`;
