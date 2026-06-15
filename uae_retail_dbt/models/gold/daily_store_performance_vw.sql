/*
=============================================================================
PROJECT      : UAE Retail Analytics Pipeline
ARCHITECT    : Data With RISHAL
LAYER        : Gold (Business Intelligence & Aggregation)
MODEL        : daily_store_performance_vw
DESCRIPTION  : 
    This model aggregates cleaned Silver data into a business-ready 
    data mart. It calculates daily KPI metrics per store location, 
    focusing on VAT-exclusive revenue for accurate financial reporting.
=============================================================================
*/

{{ config(
    materialized='view'
) }}

WITH silver_clean AS (
    -- 1. Ingest conformed data from the Silver layer
    SELECT * FROM {{ ref('clean_retail_transactions') }}
),

daily_aggregation AS (
    -- 2. Calculate core business KPIs
    SELECT 
        transaction_day,
        store_location,
        order_type,
        COUNT(transaction_id) AS total_transactions,
        SUM(amount_aed) AS gross_revenue_aed,
        SUM(vat_exclusive_amount_aed) AS net_revenue_aed
    FROM silver_clean
    GROUP BY 
        transaction_day,
        store_location,
        order_type
)

-- 3. Expose the finalized data mart
SELECT * FROM daily_aggregation