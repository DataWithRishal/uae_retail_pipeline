{{ config(
    materialized='view'
) }}

WITH silver_clean AS (
    SELECT * FROM {{ ref('clean_retail_transactions') }}
)

SELECT 
    transaction_day,
    store_location,
    order_type,
    COUNT(transaction_id) AS total_transactions
FROM silver_clean
GROUP BY 
    transaction_day,
    store_location,
    order_type