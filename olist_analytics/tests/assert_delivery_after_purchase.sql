SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM {{ ref('fct_orders')}}
WHERE order_delivered_customer_date < order_purchase_timestamp