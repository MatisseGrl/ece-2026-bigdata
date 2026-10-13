-- Exercice 1 : Moyenne des commandes par utilisateur
-- et quantité moyenne par commande
SELECT
    round(
        (SELECT count(*) FROM orders) * 1.0 /
        (SELECT count(*) FROM users), 2
    ) AS avg_orders_per_user,
    round(avg(quantity), 2) AS avg_quantity_per_order
FROM orders;

-- Exercice 2 : Première et dernière commande par utilisateur
SELECT
    u.username,
    min(o.date) AS first_order,
    max(o.date) AS last_order,
    date_diff('day', min(o.date), max(o.date)) AS days_between
FROM users u
JOIN orders o ON u.uuid = o.user_uuid
GROUP BY u.uuid, u.username
ORDER BY u.username;

-- Exercice 3 : Heure avec la plus grande quantité vendue
SELECT
    hour(date) AS order_hour,
    sum(quantity) AS total_quantity
FROM orders
GROUP BY order_hour
ORDER BY total_quantity DESC
LIMIT 1;

-- Exercice 4 : Variation mensuelle par produit
WITH monthly AS (
    SELECT
        product,
        strftime(date, '%Y-%m') AS month,
        sum(quantity) AS quantity
    FROM orders
    GROUP BY product, month
),
variations AS (
    SELECT
        product,
        month,
        quantity,
        lag(quantity) OVER (
            PARTITION BY product ORDER BY month
        ) AS previous_quantity
    FROM monthly
)
SELECT
    product,
    month,
    quantity,
    previous_quantity,
    round(
        100.0 * (quantity - previous_quantity)
        / nullif(previous_quantity, 0), 2
    ) AS variation_pct
FROM variations
ORDER BY product, month;

-- Exercice 5 : Utilisateurs ayant commandé tous les produits
SELECT
    u.username,
    u.name,
    count(DISTINCT o.product) AS products_ordered
FROM users u
JOIN orders o ON o.user_uuid = u.uuid
GROUP BY u.uuid, u.username, u.name
HAVING count(DISTINCT o.product) = (
    SELECT count(DISTINCT product) FROM orders
)
ORDER BY u.username;
