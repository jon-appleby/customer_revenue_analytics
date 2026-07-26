WITH customers AS (
    SELECT * FROM {{ ref('stg_customers')}}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders')}}
),

customer_locations AS (
    SELECT
        c.customer_id,
        c.customer_city,
        c.customer_state,
        c.customer_zip_code_prefix,
        row_number() over (
            partition BY c.customer_id
            ORDER BY o.order_purchase_timestamp DESC
        ) AS recency_rank
    FROM customers c
    INNER JOIN orders o
        ON c.customer_order_id = o.customer_order_id
),

latest_location AS (
    SELECT
        customer_id,
        customer_city,
        customer_state,
        customer_zip_code_prefix
    FROM customer_locations
    WHERE recency_rank = 1
),

customer_orders AS (
    SELECT * FROM {{ ref('int_customer_orders') }}
)

SELECT
    l.customer_id,
    l.customer_city,
    l.customer_state,
    l.customer_zip_code_prefix,
    co.order_count,
    co.total_revenue,
    co.avg_order_value,
    co.first_order_date,
    co.last_order_date,
    CASE WHEN co.order_count > 1 THEN TRUE ELSE FALSE END AS is_repeat_customer
FROM latest_location l
LEFT JOIN customer_orders co ON l.customer_id = co.customer_id