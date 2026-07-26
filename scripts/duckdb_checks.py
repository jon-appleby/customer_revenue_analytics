import duckdb
from src.paths import DUCK_DB_FILE


queries = [
    """
    SELECT table_schema, table_name, table_type FROM information_schema.tables ORDER BY 1, 2;
    """,
    """
    SELECT COUNT(*) AS customer_count FROM main.dim_customers;
    """,
    """
    SELECT COUNT(*) AS frequency_count FROM main.fct_customer_rfm WHERE frequency = 1;
    """,
    """
    SELECT customer_segment, COUNT(*) AS segment_count, ROUND(SUM(monetary), 2)
    FROM main.fct_customer_rfm
    GROUP BY 1 order by 3 desc;
    """,
    """
    SELECT ROUND(SUM(item_total_revenue), 2) AS revenue FROM main.fct_order_items;
    """,
]

con = duckdb.connect(DUCK_DB_FILE)

for query in queries:
    print(con.execute(query).df().to_string(),'\n')

con.close()