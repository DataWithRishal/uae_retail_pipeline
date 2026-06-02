{{ config(
    materialized='table',
    unique_key='transaction_id'
) }}

WITH source_data AS (
    SELECT * FROM {{ source('retail_bronze', 'raw_retail_transactions') }}
)

SELECT 
    TRIM(transaction_id) AS transaction_id,
    transaction_date,
    DATE(transaction_date) AS transaction_day, 
    TRIM(customer_id) AS customer_id,
    UPPER(TRIM(order_type)) AS order_type,
    UPPER(TRIM(store_location)) AS store_location
FROM source_data

-- Enterprise Deduplication
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY transaction_id 
    ORDER BY transaction_date DESC
) = 1