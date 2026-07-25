WITH source AS (
    SELECT * FROM {{ source('raw', 'customers')}}
)

SELECT
    customer_id AS customer_order_id,
    customer_unique_id AS customer_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM source