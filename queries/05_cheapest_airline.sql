-- Cheapest airline on the 10 busiest routes, by median price.

WITH top_routes AS (
    SELECT src, dst, COUNT(DISTINCT itinerary_id) as n_flights
    FROM flights
    GROUP BY src, dst 
    ORDER BY n_flights DESC
    LIMIT 10
),
airline_prices AS (
    SELECT f.src, f.dst, f.airline_name, MEDIAN(f.price) as median_price
    FROM flights f
    JOIN top_routes t ON f.src = t.src AND f.dst = t.dst
    GROUP BY f.src, f.dst, f.airline_name
    HAVING COUNT(DISTINCT f.itinerary_id) >= 30
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY src, dst ORDER BY median_price) AS rnk,
        LEAD(airline_name) OVER (PARTITION BY src, dst ORDER BY median_price) AS second_airline,
        LEAD(median_price) OVER (PARTITION BY src, dst ORDER BY median_price) AS second_price
    FROM airline_prices
)
SELECT
    src, dst,
    airline_name AS cheapest_airline,
    median_price,
    second_airline,
    second_price,
    ROUND((second_price - median_price) * 100.0 / second_price, 1) AS pct_cheaper
FROM ranked
WHERE rnk = 1
ORDER BY pct_cheaper DESC;
