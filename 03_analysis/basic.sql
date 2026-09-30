SELECT (SELECT COUNT(*) FROM orders) AS orders,
       (SELECT COUNT(DISTINCT customer_unique_id) FROM customers) AS customers,
       (SELECT COUNT(*) FROM sellers) AS sellers,
       (SELECT COUNT(*) FROM products) AS products,
       (SELECT MIN(order_purchase_timestamp) FROM orders) AS first_order,
       (SELECT MAX(order_purchase_timestamp) FROM orders) AS last_order;

SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       COUNT(DISTINCT oi.order_id) AS orders,
       ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;

SELECT c.customer_state,
       COUNT(DISTINCT c.customer_unique_id) AS customers,
       ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;

SELECT payment_type, COUNT(*) AS payments,
       ROUND(AVG(payment_installments), 2) AS avg_installments,
       ROUND(SUM(payment_value), 2) AS total_value
FROM order_payments
GROUP BY payment_type
ORDER BY payments DESC;