from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
RAW_DATA_DIR = PROJECT_ROOT / 'data' / 'raw'
DUCK_DB_FILE = PROJECT_ROOT / 'dev.duckdb'
DBT_DIR = PROJECT_ROOT / 'olist_analytics'
