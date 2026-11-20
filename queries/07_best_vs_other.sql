-- Are Google "Best" flights cheaper than others on the same route and day?

WITH avg_group AS (
    SELECT price, is_best,
    AVG(price) OVER (PARTITION BY src, dst, CAST(price_datetime AS DATE)) as avg_price,
    SUM(is_best) OVER (PARTITION BY src, dst, CAST(price_datetime AS DATE)) AS n_best,
    COUNT(*) OVER (PARTITION BY src, dst, CAST(price_datetime AS DATE)) AS n_total 
    FROM flights
),
rel_diff AS (
    SELECT ((price-avg_price)/avg_price*100.0) AS pct_diff, is_best
    FROM avg_group
    WHERE n_best > 0 AND n_best < n_total
)
SELECT 
    is_best,
    ROUND(AVG(pct_diff), 1)    AS avg_pct_diff,
    ROUND(MEDIAN(pct_diff), 1) AS median_pct_diff,
    COUNT(*)                   AS observations
FROM rel_diff
GROUP BY is_best;
