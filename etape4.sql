-- 1. Commandes par tranche d'âge
SELECT
    (date_diff('year', u.birthdate, DATE '2020-01-01') // 20) * 20 AS age_group,
    count(DISTINCT u.uuid) AS users,
    count(*) AS orders,
    round(avg(o.quantity), 2) AS avg_quantity
FROM orders o
JOIN users u ON o.user_uuid = u.uuid
GROUP BY age_group
ORDER BY age_group;

-- 2. Quantités quotidiennes, cumul et moyenne mobile sur 7 jours
WITH daily AS (
    SELECT date::DATE AS day, sum(quantity) AS quantity
    FROM orders
    GROUP BY day
)
SELECT
    day,
    quantity,
    sum(quantity) OVER (ORDER BY day) AS cumulative,
    round(avg(quantity) OVER (
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 1) AS avg_7d
FROM daily
ORDER BY day
LIMIT 10;

-- 3. Produit le plus vendu chaque mois
SELECT
    strftime(date, '%Y-%m') AS month,
    product,
    sum(quantity) AS quantity
FROM orders
GROUP BY month, product
QUALIFY rank() OVER (
    PARTITION BY month
    ORDER BY sum(quantity) DESC
) = 1
ORDER BY month;

-- 4. Tableau croisé dynamique
PIVOT (
    SELECT
        strftime(date, '%Y-%m') AS month,
        product,
        quantity
    FROM orders
)
ON product
USING sum(quantity)
ORDER BY month;
