-- This singular test ensures that no transaction has a negative or zero amount.
-- If this query returns any rows, the dbt test will fail and alert the Data Engineering team.

with silver_transactions as (
    select * from {{ ref('clean_retail_transactions') }}
)

select
    transaction_id,
    amount_aed
from silver_transactions
where amount_aed <= 0