SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;

SELECT customer_id,
       COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


SELECT
COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulls,
COUNT(*) FILTER (WHERE customer_city IS NULL) AS city_nulls,
COUNT(*) FILTER (WHERE customer_state IS NULL) AS state_nulls
FROM customers;
