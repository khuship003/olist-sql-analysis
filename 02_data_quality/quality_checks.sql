SELECT order_status, COUNT(*) AS orders,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

SELECT order_status, COUNT(*) AS total,
       SUM(order_delivered_customer_date IS NULL) AS missing_delivery
FROM orders
GROUP BY order_status;

SELECT COUNT(*) AS bad_dates
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

SELECT COUNT(*) AS no_category FROM products WHERE product_category_name IS NULL;

SELECT COUNT(DISTINCT p.product_category_name) AS untranslated_categories
FROM products p
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL;

SELECT COUNT(*) AS customer_ids, COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;