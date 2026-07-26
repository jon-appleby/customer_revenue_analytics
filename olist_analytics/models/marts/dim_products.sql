SELECT
    product_id,
    category_name,
    category_name_pt,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    product_photos_qty
FROM {{ ref('stg_products') }}