WITH order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

orders AS (
    SELECT * FROM {{ ref('fct_orders') }}  -- use fct rather than re-derive logic
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

products AS (
    SELECT * FROM {{ ref('stg_products') }}
)

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    o.customer_order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_date_key,
    o.delivery_days,
    o.is_on_time_delivery,
    o.review_score,
    o.customer_order_type,
    p.category_name,
    c.customer_state,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS item_total_revenue
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN customers c ON o.customer_order_id = c.customer_order_id
LEFT JOIN products p ON oi.product_id = p.product_id