-- How many times each flight was observed.

WITH obs_per_flight AS(
    SELECT itinerary_id, COUNT(*) as n
    FROM flights
    GROUP BY itinerary_id
)
SELECT
    MEDIAN(n)                      AS median_obs_per_flight,
    AVG(n)                        AS avg_obs_per_flight,
    COUNT(*) FILTER (WHERE n = 1)  AS flights_seen_once
FROM obs_per_flight;
