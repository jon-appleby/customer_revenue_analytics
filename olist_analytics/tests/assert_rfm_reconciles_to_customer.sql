WITH expected AS (
    SELECT COUNT(*) AS customer_count
    FROM {{ ref('int_customer_orders')}}
),

actual AS (
    SELECT COUNT(*) AS customer_count
    FROM {{ ref('fct_customer_rfm')}}
)

SELECT
    expected.customer_count AS expected_count,
    actual.customer_count AS actual_count
FROM expected
CROSS JOIN actual
WHERE expected.customer_count != actual.customer_count