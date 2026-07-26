WITH order_grain AS (
    SELECT ROUND(SUM(order_total_revenue), 2) AS total
    FROM {{ ref('fct_orders')}}
    WHERE order_total_revenue IS NOT NULL
),

item_grain AS (
    SELECT ROUND(SUM(item_total_revenue), 2) AS total
    FROM {{ ref('fct_order_items')}}
)

SELECT
    order_grain.total AS order_grain_total,
    item_grain.total AS item_grain_total
FROM order_grain
CROSS JOIN item_grain
WHERE ABS(order_grain.total - item_grain.total) > 0.05