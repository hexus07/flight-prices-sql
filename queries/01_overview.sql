-- Dataset overview: size, period, price range.

SELECT 
    COUNT(*) as observations,
    COUNT(DISTINCT itinerary_id) as flights,
    COUNT(DISTINCT(src, dst)) as routes,
    COUNT(DISTINCT airline_name) as airlines,
    date_trunc('day', MIN(price_datetime)) as observations_from,
    date_trunc('day', MAX(price_datetime)) as observations_to,
    date_diff('day', observations_from, observations_to) as observation_lenght,
    MIN(price)    AS min_price,
    MEDIAN(price) AS median_price,
    MAX(price)    AS max_price
    FROM flights; 
