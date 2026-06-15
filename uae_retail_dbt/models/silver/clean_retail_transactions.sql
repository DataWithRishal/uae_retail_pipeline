/*
=============================================================================
PROJECT      : UAE Retail Analytics Pipeline
ARCHITECT    : Data With RISHAL
LAYER        : Silver (Conformed & Cleaned)
MODEL        : clean_retail_transactions
DESCRIPTION  : 
    This model cleans raw POS/E-com data from the Bronze layer. It applies
    UAE domain logic by joining static Emirate reference data to append 
    regional tax rates. It also calculates the base revenue (VAT exclusive) 
    using a custom dbt macro.
=============================================================================
*/

{{ config(
    materialized='table',
    unique_key='transaction_id'
) }}

WITH source_data AS (
    -- 1. Extract immutable raw data directly from the Bronze source
    SELECT * FROM {{ source('retail_bronze', 'raw_retail_transactions') }}
),

emirates_reference AS (
    -- 2. Extract static regional reference data
    SELECT * FROM {{ ref('uae_emirates') }}
),

clean_and_enriched AS (
    -- 3. Apply standardizations, casting, and domain logic
    SELECT 
        TRIM(s.transaction_id) AS transaction_id,
        DATE(s.transaction_date) AS transaction_day,
        TRIM(s.customer_id) AS customer_id,
        UPPER(TRIM(s.order_type)) AS order_type,
        UPPER(TRIM(s.store_location)) AS store_location,
        
        -- Portfolio Mock: Simulating an amount column for financial transformations
        CAST(150.00 AS DECIMAL(10,2)) AS amount_aed,
        
        e.region_code,
        e.tax_rate,
        
        -- Apply UAE 5% VAT extraction macro
        {{ calc_vat_exclusive('150.00', 'e.tax_rate') }} AS vat_exclusive_amount_aed

    FROM source_data s
    LEFT JOIN emirates_reference e 
        ON UPPER(TRIM(s.store_location)) = UPPER(e.emirate)
)

-- 4. Enterprise Deduplication using Window Functions
SELECT * FROM clean_and_enriched
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY transaction_id 
    ORDER BY transaction_day DESC
) = 1