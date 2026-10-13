-- 1. Explorer les fichiers CSV
SELECT '=== STRUCTURE ORDERS ===' AS etape;
DESCRIBE FROM read_csv(getvariable('bucket') || '/bronze/orders.csv');

-- 2. Charger les données dans DuckDB
CREATE OR REPLACE TABLE users AS
FROM read_csv(getvariable('bucket') || '/bronze/users.csv');

CREATE OR REPLACE TABLE orders AS
FROM read_csv(getvariable('bucket') || '/bronze/orders.csv');

-- 3. Compter les lignes
SELECT
    (SELECT count(*) FROM users) AS users,
    (SELECT count(*) FROM orders) AS orders;

-- 4. Contrôler la qualité
SELECT count(*) AS orphan_orders
FROM orders o
ANTI JOIN users u ON o.user_uuid = u.uuid;

SELECT count(*) AS inactive_users
FROM users u
ANTI JOIN orders o ON o.user_uuid = u.uuid;

SELECT uuid, count(*) AS occurrences
FROM orders
GROUP BY uuid
HAVING count(*) > 1;

-- 5. Quantités vendues par produit
SELECT
    product,
    count(*) AS orders,
    sum(quantity) AS quantity,
    round(100 * sum(quantity) / sum(sum(quantity)) OVER (), 1) AS share_pct
FROM orders
GROUP BY product
ORDER BY quantity DESC;

-- 6. Commandes par mois
SELECT
    date_trunc('month', date) AS month,
    count(*) AS orders,
    sum(quantity) AS quantity
FROM orders
GROUP BY month
ORDER BY month;

-- 7. Top 5 clients
SELECT
    u.username,
    u.name,
    count(*) AS orders,
    sum(o.quantity) AS quantity
FROM orders o
JOIN users u ON o.user_uuid = u.uuid
GROUP BY ALL
ORDER BY quantity DESC
LIMIT 5;
