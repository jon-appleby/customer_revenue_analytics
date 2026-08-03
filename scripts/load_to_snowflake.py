import os

import snowflake.connector
from cryptography.hazmat.primitives import serialization

from src.paths import RAW_DATA_DIR

FILES = {
    'olist_customers_dataset.csv': 'CUSTOMERS',
    'olist_geolocation_dataset.csv': 'GEOLOCATION',
    'olist_order_items_dataset.csv': 'ORDER_ITEMS',
    'olist_order_payments_dataset.csv': 'ORDER_PAYMENTS',
    'olist_order_reviews_dataset.csv': 'ORDER_REVIEWS',
    'olist_orders_dataset.csv': 'ORDERS',
    'olist_products_dataset.csv': 'PRODUCTS',
    'olist_sellers_dataset.csv': 'SELLERS',
}

def get_sf_connection():
    key_path = os.getenv('SNOWFLAKE_PRIVATE_KEY_PATH')

    if not key_path:
        raise ValueError('SNOWFLAKE_PRIVATE_KEY_PATH not set')

    with open(key_path, 'rb') as f:
        private_key = serialization.load_pem_private_key(f.read(), password=None)

    private_key_der = private_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )

    return snowflake.connector.connect(
        account=os.getenv('SNOWFLAKE_ACCOUNT'),
        user=os.getenv('SNOWFLAKE_USER'),
        private_key=private_key_der,
        role='DBT_DEV_ROLE',
        warehouse='DBT_WH_XS',
        database='OLIST_ANALYTICS',
        schema='RAW'
    )

def main():
    conn = get_sf_connection()
    cur = conn.cursor()

    # create file format for olist_csv
    cur.execute("""
        CREATE OR REPLACE FILE FORMAT olist_csv_format
            TYPE = CSV
            PARSE_HEADER = TRUE
            FIELD_OPTIONALLY_ENCLOSED_BY = '"'
            NULL_IF = ('', 'NULL')
            TRIM_SPACE = TRUE
            EMPTY_FIELD_AS_NULL = TRUE
    """)
    print('Created olist_csv_format file format')

    # create stage for olist csv loads
    cur.execute("""
        CREATE STAGE IF NOT EXISTS olist_raw_stage
            FILE_FORMAT = (
                FORMAT_NAME = 'olist_csv_format'
            )
            COMMENT = 'Stage for olist raw CSV loads'
    """)
    print('Created olist_raw_stage')

    for filename in FILES:
        file_path = (RAW_DATA_DIR / filename).resolve().as_posix()

        cur.execute(
            f"""
            PUT 'file://{file_path}' @olist_raw_stage 
            AUTO_COMPRESS = TRUE
            OVERWRITE = TRUE
            """
        )

    for filename, table_name in FILES.items():
        staged = f'{filename}.gz'

        # use template
        cur.execute(f"""
            CREATE OR REPLACE TABLE RAW.{table_name}
            USING TEMPLATE (
                SELECT ARRAY_AGG(
                    OBJECT_CONSTRUCT(
                        'COLUMN_NAME', UPPER(COLUMN_NAME),
                        'TYPE', TYPE,
                        'NULLABLE', NULLABLE
                    )
                ) WITHIN GROUP (ORDER BY ORDER_ID)
                FROM TABLE(
                    INFER_SCHEMA(
                        LOCATION => '@olist_raw_stage/{staged}',
                        FILE_FORMAT => 'olist_csv_format'
                    )
                )
            )
        """)

        cur.execute(f"""
                    COPY INTO RAW.{table_name}
                    FROM @olist_raw_stage/{staged}
                    FILE_FORMAT = (
                        FORMAT_NAME = olist_csv_format
                    )
                    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
                    ON_ERROR = 'ABORT_STATEMENT'
                """)

        row_count = cur.execute(
            f'SELECT count(*) FROM RAW.{table_name}'
        ).fetchone()[0]
        print(f'{table_name}: {row_count:,} rows')

    cur.close()
    conn.close()


if __name__ == '__main__':
    main()