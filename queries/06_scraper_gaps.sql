-- Days when the scraper collected no data.

WITH scraper_days AS (
    SELECT DISTINCT CAST(price_datetime as DATE) AS day
    FROM flights
),
with_prev AS (
    SELECT day, LAG(day) OVER (ORDER by day) prev_day
    FROM scraper_days
)
SELECT 
    prev_day AS day_before_gap,
    day AS day_after_gap,
    day - prev_day AS gap
FROM with_prev
WHERE gap > 1
ORDER by gap DESC
LIMIT 15;
