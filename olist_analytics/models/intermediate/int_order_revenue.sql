WITH orders AS (
    SELECT * FROM {{ ref('stg_order_items')}}
)

SELECT
    order_id,
    SUM(price)                      AS merch_revenue,
    SUM(freight_value)              AS freight_revenue,
    SUM(price) + SUM(freight_value) AS order_total_revenue,
    COUNT(*)
FROM orders
GROUP BY 1