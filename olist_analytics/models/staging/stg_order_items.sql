WITH source AS (
    SELECT * FROM {{ source('raw', 'order_items')}}
)

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    TRY_CAST(shipping_limit_date AS TIMESTAMP)  AS shipping_limit_date,
    CAST(price AS DECIMAL(12, 2))               AS price,
    CAST(freight_value AS DECIMAL(12, 2))       AS freight_value
FROM source