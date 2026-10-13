COPY (
    WITH u AS (SELECT list(uuid) AS uuids FROM users)
    SELECT
        uuid() AS uuid,
        uuids[1 + floor(random() * len(uuids))::INTEGER] AS user_uuid,
        TIMESTAMP '2020-01-01' + i * INTERVAL '1 hour' AS date,
        1 + floor(random() * 5)::INTEGER AS quantity,
        ['bread', 'brioche', 'cookie', 'croissant', 'donut', 'drink']
            [1 + floor(random() * 6)::INTEGER] AS product
    FROM generate_series(0, 999489) AS t(i), u
)
TO 'orders_large.csv'
(FORMAT CSV, HEADER true);
