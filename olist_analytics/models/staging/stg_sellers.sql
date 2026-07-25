WITH source AS (
    SELECT * FROM {{ source('raw', 'sellers')}}
)

SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM source