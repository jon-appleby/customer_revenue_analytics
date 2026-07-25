WITH source AS (
    SELECT * FROM {{ source('raw', 'products')}}
),

translation AS (
    SELECT * FROM {{ source('raw', 'product_category_name_translation')}}
)

SELECT
    s.product_id,
    s.product_category_name                         AS category_name_pt,
    COALESCE(t.product_category_name, 'unknown')    AS category_name,
    s.product_name_lenght,
    s.product_description_lenght,
    CAST(s.product_photos_qty AS INTEGER)           AS product_photos_qty,
    CAST(s.product_weight_g AS DECIMAL(12, 2))      AS product_weight_g,
    CAST(s.product_length_cm AS DECIMAL(12, 2))     AS product_length_cm,
    CAST(s.product_height_cm AS DECIMAL(12, 2))     AS product_height_cm,
    CAST(s.product_width_cm AS DECIMAL(12, 2))      AS product_width_cm
FROM source s
LEFT JOIN translation t
    ON s.product_category_name = t.product_category_name