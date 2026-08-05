CREATE OR REPLACE VIEW vw_executive_dashboard AS
SELECT
    o.order_id,
    o.order_purchase_timestamp,
    c.customer_id,
    c.customer_unique_id,
    c.customer_state,
    op.payment_type,
    op.payment_installments,
    op.payment_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id;

CREATE OR REPLACE VIEW vw_customer_product_dashboard AS
SELECT
    c.customer_unique_id,
    c.customer_state,
    o.order_id,
    o.order_purchase_timestamp,
    oi.product_id,
    p.product_category_name,
    ct.product_category_name_english,
    oi.price,
    oi.freight_value,
    r.review_score
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN order_reviews r
    ON o.order_id = r.order_id;

CREATE OR REPLACE VIEW vw_operations_dashboard AS
SELECT
    o.order_id,
    c.customer_state,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    (
        o.order_delivered_customer_date::DATE -
        o.order_purchase_timestamp::DATE
    ) AS delivery_days,
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    r.review_score
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_reviews r
    ON o.order_id = r.order_id;


SELECT * FROM vw_executive_dashboard LIMIT 5;

SELECT * FROM vw_customer_product_dashboard LIMIT 5;

SELECT * FROM vw_operations_dashboard LIMIT 5;
