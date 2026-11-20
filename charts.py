"""Make the charts used in README. Run: python3 charts.py"""
from pathlib import Path

import duckdb
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

HERE = Path(__file__).parent
DATA = HERE / "data" / "flights_clean.parquet"
FIG = HERE / "figures"
FIG.mkdir(exist_ok=True)

BLUE, GRAY, TEXT, MUTED = "#2a78d6", "#b9b8b3", "#0b0b0b", "#52514e"
ORDER = ["90+", "60-89", "30-59", "14-29", "0-13"]  # far from departure -> close

plt.rcParams.update({
    "font.size": 11, "axes.spines.top": False, "axes.spines.right": False,
    "axes.edgecolor": GRAY, "axes.labelcolor": MUTED, "xtick.color": MUTED,
    "ytick.color": MUTED, "axes.titlesize": 13, "axes.titleweight": "bold",
    "axes.titlelocation": "left", "axes.titlecolor": TEXT,
})

con = duckdb.connect()
con.sql("SET memory_limit = '2GB'")
con.sql(f"CREATE VIEW flights AS SELECT * FROM read_parquet('{DATA.as_posix()}')")


def run(name):
    return con.sql((HERE / "queries" / name).read_text(encoding="utf-8")).df()


def finish(ax, path):
    ax.grid(axis="y", color="#e6e5e0", linewidth=0.8)
    ax.set_axisbelow(True)
    ax.tick_params(length=0)
    plt.tight_layout()
    plt.savefig(FIG / path, dpi=150)
    plt.close()
    print("saved", FIG / path)


# 1. Median price by days before departure
df = run("02_price_by_days_left.sql").set_index("bucket").loc[ORDER].reset_index()
fig, ax = plt.subplots(figsize=(7, 4))
bars = ax.bar(df["bucket"], df["median_price"], color=BLUE, width=0.6)
for b, v in zip(bars, df["median_price"]):
    ax.text(b.get_x() + b.get_width() / 2, v + 4, f"{v:.0f}", ha="center", color=TEXT)
ax.set_title("Median ticket price by days before departure")
ax.set_xlabel("Days before departure")
ax.set_ylabel("Median price")
finish(ax, "02_price_by_days_left.png")

# 2. When does the lowest price appear vs. where our observations are
df = run("04_when_lowest_price.sql").set_index("bucket").loc[ORDER].reset_index()
x = range(len(df))
w = 0.38
fig, ax = plt.subplots(figsize=(7, 4))
ax.bar([i - w / 2 for i in x], df["pct_obs"], w, color=GRAY, label="All observations")
ax.bar([i + w / 2 for i in x], df["pct_lowest"], w, color=BLUE, label="Lowest price of the flight")
ax.set_xticks(list(x), df["bucket"])
ax.set_title("When does a flight reach its lowest price?")
ax.set_xlabel("Days before departure")
ax.set_ylabel("% of total")
ax.legend(frameon=False, loc="upper right")
finish(ax, "04_when_lowest_price.png")

# 3. How much data the scraper collected each month
df = run("06b_obs_per_month.sql").set_index("month")
all_months = pd.date_range(df.index.min(), df.index.max(), freq="MS")
df = df.reindex(all_months, fill_value=0)  # show months with no data as empty
fig, ax = plt.subplots(figsize=(8, 3.6))
ax.bar(df.index.strftime("%b %y"), df["observations"] / 1e6, color=BLUE, width=0.7)
for i, v in enumerate(df["observations"]):
    if v == 0:
        ax.text(i, 0.05, "no data", rotation=90, ha="center", va="bottom", color=MUTED, fontsize=9)
ax.set_title("Observations collected per month")
ax.set_ylabel("Millions")
plt.xticks(rotation=45, ha="right")
finish(ax, "06b_obs_per_month.png")
