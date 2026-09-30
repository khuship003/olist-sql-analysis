SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.price), 2) AS revenue,
       ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

SELECT COUNT(*) AS delivered_orders,
       SUM(order_delivered_customer_date > order_estimated_delivery_date) AS late_orders,
       ROUND(100 * SUM(order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*), 2) AS pct_late,
       ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) AS avg_delivery_days,
       ROUND(AVG(DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp)), 1) AS avg_estimated_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

WITH order_score AS (
  SELECT order_id, AVG(review_score) AS score
  FROM order_reviews
  GROUP BY order_id
)
SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*) AS orders,
       ROUND(AVG(s.score), 2) AS avg_review_score
FROM orders o
JOIN order_score s ON o.order_id = s.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

WITH seller_rev AS (
  SELECT oi.seller_id,
         COUNT(DISTINCT oi.order_id) AS orders,
         SUM(oi.price) AS revenue
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY oi.seller_id
),
seller_score AS (
  SELECT x.seller_id, AVG(r.review_score) AS avg_score
  FROM (SELECT DISTINCT order_id, seller_id FROM order_items) x
  JOIN order_reviews r ON x.order_id = r.order_id
  GROUP BY x.seller_id
)
SELECT sr.seller_id, s.seller_state, sr.orders,
       ROUND(sr.revenue, 2) AS revenue,
       ROUND(sc.avg_score, 2) AS avg_review_score
FROM seller_rev sr
JOIN seller_score sc ON sr.seller_id = sc.seller_id
JOIN sellers s ON sr.seller_id = s.seller_id
WHERE sr.orders >= 50
ORDER BY sc.avg_score ASC
LIMIT 10;

WITH seller_rev AS (
  SELECT oi.seller_id, SUM(oi.price) AS revenue
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY oi.seller_id
),
ranked AS (
  SELECT seller_id, revenue,
         NTILE(10) OVER (ORDER BY revenue DESC) AS decile
  FROM seller_rev
)
SELECT decile,
       COUNT(*) AS sellers,
       ROUND(SUM(revenue), 2) AS revenue,
       ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS pct_of_revenue
FROM ranked
GROUP BY decile
ORDER BY decile;