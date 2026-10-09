COPY (
    SELECT
        uuid() AS uuid,
        (
            SELECT uuid
            FROM users
            ORDER BY random()
            LIMIT 1
        ) AS user_uuid,
        TIMESTAMP '2020-01-01'
            + i * INTERVAL '1 hour' AS date,
        1 + (random() * 4)::INTEGER AS quantity,
        CASE (i % 6)
            WHEN 0 THEN 'bread'
            WHEN 1 THEN 'brioche'
            WHEN 2 THEN 'cookie'
            WHEN 3 THEN 'croissant'
            WHEN 4 THEN 'donut'
            ELSE 'drink'
        END AS product
    FROM generate_series(0, 999489) AS t(i)
)
TO 'orders_large.csv'
(FORMAT CSV, HEADER true);
