WITH source AS (
    SELECT * FROM {{ source('raw', 'order_payments')}}
)

SELECT
    order_id,
    CAST(payment_sequential AS INTEGER)     AS payment_sequential,
    payment_type,
    CAST(payment_installments AS INTEGER)   AS payment_installments,
    CAST(payment_value AS DECIMAL(12, 2))   AS payment_value
FROM source