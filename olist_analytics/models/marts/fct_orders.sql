WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

revenue AS (
    SELECT * FROM {{ ref('int_order_revenue') }}
),

reviews AS (
    SELECT * FROM {{ ref('stg_order_reviews') }}
),

joined AS (
    SELECT
        o.order_id,
        c.customer_id,
        o.customer_order_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        -- Days from purchase to delivery. Null where undelivered.
        datediff('day', o.order_purchase_timestamp, o.order_delivered_customer_date)
            AS delivery_days,

        -- Days early (positive) or late (negative) against the estimate.
        datediff('day', o.order_delivered_customer_date, o.order_estimated_delivery_date)
            AS delivery_vs_estimate_days,

        CASE
            WHEN o.order_delivered_customer_date IS NULL THEN NULL
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN TRUE
            ELSE FALSE
        END AS is_on_time_delivery,

        r.order_total_revenue,
        r.merchandise_revenue,
        r.freight_revenue,
        r.item_count,
        rv.review_score
    FROM orders o
    INNER JOIN customers c ON o.customer_order_id = c.customer_order_id
    LEFT JOIN revenue r ON o.order_id = r.order_id
    LEFT JOIN reviews rv ON o.order_id = rv.order_id
),

sequenced AS (
    SELECT
        *,
        row_number() over (
            partition BY customer_id
            ORDER BY order_purchase_timestamp
        ) AS customer_order_sequence
    FROM joined
)

SELECT
    *,
    CASE WHEN customer_order_sequence = 1 THEN 'New' ELSE 'Returning' END
        AS customer_order_type
FROM sequenced