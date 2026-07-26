WITH orders AS (
    SELECT * FROM {{ ref('stg_orders')}}
    WHERE order_status NOT IN ('canceled', 'unavailable')
),

customers AS (
    SELECT * FROM {{ ref('stg_customers')}}
),

revenue AS (
    SELECT * FROM {{ ref('int_order_revenue')}}
)

SELECT
    c.customer_id,
    COUNT(DISTINCT o.order_id)      AS order_count,
    SUM(r.order_total_revenue)      AS total_revenue,
    AVG(r.order_total_revenue)      AS avg_order_value,
    MIN(o.order_purchase_timestamp) AS first_order_date,
    MAX(o.order_purchase_timestamp) AS last_order_date
FROM orders o
INNER JOIN customers c ON o.customer_order_id = c.customer_order_id
INNER JOIN revenue r ON o.order_id = r.order_id
GROUP BY 1
