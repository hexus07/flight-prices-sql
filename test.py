import duckdb as db
from pathlib import Path

file = Path(__file__).parent / "data" / "flights_clean.parquet"
con = db.connect()

con.sql(f"CREATE VIEW flights AS SELECT * FROM read_parquet('{file.as_posix()}')")
con.sql("DESCRIBE flights").show()
con.sql("SELECT COUNT(*) FROM flights").show()