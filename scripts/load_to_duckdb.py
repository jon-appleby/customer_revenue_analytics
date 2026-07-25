import duckdb
import shutil

from src.paths import RAW_DATA_DIR, DUCK_DB_DIR, DBT_DIR

con = duckdb.connect(DUCK_DB_DIR)
con.execute('CREATE SCHEMA IF NOT EXISTS raw')

tables = {
    'customers': 'olist_customers_dataset.csv',
    'geolocation': 'olist_geolocation_dataset.csv',
    'order_items': 'olist_order_items_dataset.csv',
    'order_payments': 'olist_order_payments_dataset.csv',
    'order_reviews': 'olist_order_reviews_dataset.csv',
    'orders': 'olist_orders_dataset.csv',
    'products': 'olist_products_dataset.csv',
    'sellers': 'olist_sellers_dataset.csv',
}

for name, file in tables.items():
    con.execute(
        f"""
            CREATE OR REPLACE TABLE raw.{name} AS
            SELECT *
            FROM read_csv_auto('{RAW_DATA_DIR / file}', header=True)
        """)

    print(f'Loaded raw.{name}')

print(con.execute(
    f"""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'raw'
        ORDER BY table_name
    """).fetchall())
