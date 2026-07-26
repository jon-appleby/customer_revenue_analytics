WITH customer_orders AS (
    SELECT * FROM {{ ref('int_customer_orders') }}
),

reference_date AS (
    SELECT MAX(last_order_date) AS max_date
    FROM customer_orders
),

rfm_base AS (
    SELECT
        co.customer_id,
        co.order_count AS frequency,
        co.total_revenue AS monetary,
        datediff('day', co.last_order_date, rd.max_date) AS recency_days
    FROM customer_orders co
    CROSS JOIN reference_date rd
),

rfm_scored AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,

        ntile(4) over (ORDER BY recency_days DESC) AS recency_score,   -- 4 = most recent
        ntile(4) over (ORDER BY monetary ASC) AS monetary_score,  -- 4 = highest spend

        CASE
            WHEN frequency >= 4 THEN 4
            WHEN frequency  = 3 THEN 3
            WHEN frequency  = 2 THEN 2
            ELSE 1
        END AS frequency_score
    FROM rfm_base
)

SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score + frequency_score + monetary_score as rfm_total,

    CASE
        WHEN recency_score >= 3 AND frequency_score >= 2 AND monetary_score >= 3
            THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score = 1 AND monetary_score >= 3
            THEN 'High-Value New'
        WHEN recency_score >= 3 AND frequency_score = 1
            THEN 'New / Promising'
        WHEN recency_score <= 2 AND frequency_score >= 2 AND monetary_score >= 3
            THEN 'At Risk (High Value)'
        WHEN recency_score <= 2 AND monetary_score >= 3
            THEN 'At Risk'
        when recency_score <= 2 and monetary_score <= 2
            then 'Lost / Low Value'
        ELSE 'Needs Attention'
    END AS customer_segment
FROM rfm_scored