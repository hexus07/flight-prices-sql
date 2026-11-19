-- CTE: 1. days until departures, 2. buckets for dtp

WITH price_with_dtp AS (
    SELECT 
        price, date_diff('day', price_datetime, departure_date) AS dtp
    FROM flights
),
bucketed AS (
    SELECT
        price,
        CASE
            WHEN dtp >= 90 THEN '90+'
            WHEN dtp >= 60 THEN '60-89'
            WHEN dtp >= 30 THEN '30-59'
            WHEN dtp >= 14 THEN '14-29'
            WHEN dtp >= 0 THEN '0-13'
        END AS bucket
    FROM price_with_dtp
) 
SELECT bucket, ROUND(AVG(price), 2) AS avg_price
FROM bucketed
WHERE bucket IS NOT NULL
GROUP BY bucket;