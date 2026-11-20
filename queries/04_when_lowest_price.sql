-- How many days before departure the lowest price appears (3+ observations).

WITH price_dtp AS (
    SELECT 
        price, date_diff('day', price_datetime, departure_date) AS dtp, COUNT(*) OVER (PARTITION BY itinerary_id) AS n_obs,
        ROW_NUMBER() OVER (PARTITION BY itinerary_id ORDER BY price, price_datetime) AS rn
    FROM flights
),
bucketed AS (
    SELECT 
        rn = 1 AS is_lowest,
        CASE
            WHEN dtp >= 90 THEN '90+'
            WHEN dtp >= 60 THEN '60-89'
            WHEN dtp >= 30 THEN '30-59'
            WHEN dtp >= 14 THEN '14-29'
            WHEN dtp >= 0 THEN '0-13'
        END AS bucket
    FROM price_dtp
    WHERE n_obs >= 3
) 
SELECT bucket, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as pct_obs, ROUND(COUNT(*) FILTER (WHERE is_lowest) * 100.0 / SUM(COUNT(*) FILTER (WHERE is_lowest)) OVER (), 1) as pct_lowest
FROM bucketed
GROUP BY bucket
ORDER BY bucket;
