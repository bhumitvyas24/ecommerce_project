SELECT ROUND(SUM(payment_value),2) AS total_revenue
FROM order_payments;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT
ROUND(
SUM(payment_value) /
COUNT(DISTINCT order_id),
2
) AS average_order_value
FROM order_payments;

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(op.payment_value), 2) AS revenue
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;


SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY month;


SELECT
    c.customer_state,
    ROUND(SUM(op.payment_value),2) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

SELECT
    cust.customer_id,
    ROUND(SUM(pay.payment_value), 2) AS total_revenue
FROM customers AS cust
JOIN orders AS ord
    ON cust.customer_id = ord.customer_id
JOIN order_payments AS pay
    ON ord.order_id = pay.order_id
GROUP BY cust.customer_id
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    cust.customer_id,
    ROUND(SUM(pay.payment_value), 2) AS customer_lifetime_value
FROM customers AS cust
JOIN orders AS ord
    ON cust.customer_id = ord.customer_id
JOIN order_payments AS pay
    ON ord.order_id = pay.order_id
GROUP BY cust.customer_id
ORDER BY customer_lifetime_value DESC;

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS repeat_orders;

WITH rfm AS (
    SELECT
        ord.customer_id,
        MAX(ord.order_purchase_timestamp) AS last_purchase,
        COUNT(ord.order_id) AS frequency,
        ROUND(SUM(pay.payment_value),2) AS monetary
    FROM orders AS ord
    JOIN order_payments AS pay
        ON ord.order_id = pay.order_id
    GROUP BY ord.customer_id
)

SELECT
    customer_id,
    CURRENT_DATE - last_purchase::DATE AS recency_days,
    frequency,
    monetary
FROM rfm
ORDER BY monetary DESC;

SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT c.customer_unique_id
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
) t;

WITH max_date AS (
    SELECT MAX(order_purchase_timestamp) AS latest_date
    FROM orders
),
rfm AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_purchase,
        COUNT(o.order_id) AS frequency,
        SUM(p.payment_value) AS monetary
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    r.customer_unique_id,
    (SELECT latest_date FROM max_date)::date - r.last_purchase::date AS recency_days,
    r.frequency,
    ROUND(r.monetary,2) AS monetary
FROM rfm r;

SELECT
    COALESCE(ct.product_category_name_english, 'Unknown') AS category,
    ROUND(SUM(oi.price),2) AS revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
GROUP BY COALESCE(ct.product_category_name_english, 'Unknown')
ORDER BY revenue DESC;

SELECT
    oi.product_id,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items AS oi
GROUP BY oi.product_id
ORDER BY revenue DESC
LIMIT 10;

SELECT
    COALESCE(ct.product_category_name_english, 'Unknown') AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        100.0 * SUM(oi.price) /
        SUM(SUM(oi.price)) OVER (),
        2
    ) AS revenue_percentage
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
GROUP BY COALESCE(ct.product_category_name_english, 'Unknown')
ORDER BY revenue DESC;

SELECT
    COALESCE(ct.product_category_name_english, 'Unknown') AS category,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS average_rating
FROM order_reviews AS r
JOIN order_items AS oi
    ON r.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS ct
    ON p.product_category_name = ct.product_category_name
GROUP BY COALESCE(ct.product_category_name_english, 'Unknown')
HAVING COUNT(r.review_id) >= 50
ORDER BY average_rating DESC, total_reviews DESC;

SELECT
    ROUND(
        AVG(order_delivered_customer_date::DATE -
            order_purchase_timestamp::DATE),
        2
    ) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

SELECT
    COUNT(*) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date;


SELECT
    c.customer_state,
    ROUND(
        AVG(
            o.order_delivered_customer_date::DATE -
            o.order_purchase_timestamp::DATE
        ),
        2
    ) AS avg_delivery_days
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

SELECT
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        ROUND(SUM(op.payment_value),2) AS revenue
    FROM orders o
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)

SELECT
    month,
    revenue,
    LAG(revenue) OVER(ORDER BY month) AS previous_month_revenue,
    ROUND(
        (
            (revenue - LAG(revenue) OVER(ORDER BY month))
            /
            LAG(revenue) OVER(ORDER BY month)
        ) * 100,
        2
    ) AS growth_percentage
FROM monthly_revenue
ORDER BY month;

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        ROUND(SUM(op.payment_value),2) AS revenue
    FROM orders o
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)

SELECT
    month,
    revenue,
    ROUND(
        SUM(revenue) OVER(
            ORDER BY month
        ),
        2
    ) AS running_revenue
FROM monthly_revenue
ORDER BY month;
