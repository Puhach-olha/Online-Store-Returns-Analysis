
-- 1. Data quality: duplicate orders
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS unique_orders FROM orders;

-- 2. Data quality: NULL amounts
SELECT COUNT(*) AS rows_without_amount FROM orders WHERE amount IS NULL;


-- Clean layer: no duplicates, customer city added via JOIN
CREATE OR REPLACE VIEW clean AS
SELECT DISTINCT ON (o.order_id)
       o.order_id, o.order_date, o.category, o.carrier, o.amount, o.status, c.city
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- 3. Return rate by month
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(*) AS orders_n,
       ROUND(100.0 * SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct
FROM clean
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- 4. Where is the problem? Return rate by carrier
SELECT carrier,
       COUNT(*) AS orders_n,
       ROUND(100.0 * SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct
FROM clean
GROUP BY carrier
ORDER BY return_rate_pct DESC;
 
-- 5. When did it start? Carrier x month
SELECT carrier,
       TO_CHAR(order_date, 'YYYY-MM') AS month,
       ROUND(100.0 * SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct
FROM clean
GROUP BY carrier, TO_CHAR(order_date, 'YYYY-MM')
ORDER BY carrier, month;
 
-- 6. Rule out other causes: city and category (excluding FastShip)
SELECT 'city' AS dimension, city AS value,
       ROUND(100.0 * SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct
FROM clean WHERE carrier <> 'FastShip' GROUP BY city
UNION ALL
SELECT 'category', category,
       ROUND(100.0 * SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) / COUNT(*), 1)
FROM clean WHERE carrier <> 'FastShip' GROUP BY category;
 