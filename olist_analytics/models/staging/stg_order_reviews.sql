WITH source AS (
    SELECT * FROM {{ source('raw', 'order_reviews')}}
)

-- deduplicate to one overall review score per order
SELECT
    order_id,
    AVG(CAST(review_score AS INTEGER))  AS review_score,
    COUNT(*)                            AS review_count
FROM source
GROUP BY 1