SELECT
    order_id,
    order_total_revenue
FROM {{ ref('fct_orders')}}
WHERE order_total_revenue < 0