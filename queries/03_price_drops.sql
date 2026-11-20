-- Share of flights that got cheaper after first seen, and by how much (3+ observations).

WITH per_flight AS (
SELECT
    itinerary_id,
    arg_min(price, price_datetime) AS first_price,  
    MIN(price) AS min_price,
    COUNT(*) AS n_obs
FROM flights
GROUP BY itinerary_id
HAVING COUNT(*) >= 3 
)
SELECT ROUND(100 * AVG(CASE WHEN first_price > min_price THEN 1 ELSE 0 END), 1) AS pct_flights_dropped,
    ROUND(100.0 * AVG((first_price - min_price) / first_price)
          FILTER (WHERE min_price < first_price), 1)                           AS avg_drop_pct
FROM per_flight;
