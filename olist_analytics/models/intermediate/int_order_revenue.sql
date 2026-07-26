WITH orders AS (
    SELECT * FROM {{ ref('stg_order_items')}}
)

SELECT
    order_id,
    SUM(price)                      AS merchandise_revenue,
    SUM(freight_value)              AS freight_revenue,
    SUM(price) + SUM(freight_value) AS order_total_revenue,
    COUNT(*)                        AS item_count
FROM orders
GROUP BY 1