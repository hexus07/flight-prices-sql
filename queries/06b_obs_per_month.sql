-- Observations and collection days per month.

SELECT
    date_trunc('month', price_datetime) as month,
    COUNT(*) AS observations,
    COUNT(DISTINCT CAST(price_datetime as DATE)) as collection_days
FROM flights
GROUP BY month
ORDER BY month;
