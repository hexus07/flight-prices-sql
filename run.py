"""Run every query in queries/ against the flight dataset and save the results.

Usage:
    python run.py            # run all queries
    python run.py 03         # run only queries whose file name starts with 03
"""
import sys
from pathlib import Path

import duckdb

HERE = Path(__file__).parent
DATA = HERE / "data" / "flights_clean.parquet"

con = duckdb.connect()
con.sql("SET memory_limit = '2GB'")
con.sql(f"CREATE VIEW flights AS SELECT * FROM read_parquet('{DATA.as_posix()}')")

con.sql("DESCRIBE flights").show()

prefix = sys.argv[1] if len(sys.argv) > 1 else ""
for path in sorted((HERE / "queries").glob(f"{prefix}*.sql")):
    print(f"\n=== {path.name}")
    df = con.sql(path.read_text(encoding="utf-8")).df()
    print(df.to_string(index=False, max_rows=30))
    out = HERE / "results" / f"{path.stem}.md"
    out.write_text(df.to_markdown(index=False), encoding="utf-8")
