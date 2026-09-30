WITH monthly AS (
  SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
         SUM(oi.price) AS revenue
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
  GROUP BY month
)
SELECT month, ROUND(revenue, 2) AS revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;

WITH prod_rev AS (
  SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
         oi.product_id,
         SUM(oi.price) AS revenue
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  JOIN products p ON oi.product_id = p.product_id
  LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
  WHERE o.order_status = 'delivered'
  GROUP BY category, oi.product_id
),
ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
  FROM prod_rev
)
SELECT category, product_id, ROUND(revenue, 2) AS revenue, rn
FROM ranked
WHERE rn <= 3
ORDER BY category, rn;

WITH monthly AS (
  SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
         SUM(oi.price) AS revenue
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
  GROUP BY month
)
SELECT month, ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total
FROM monthly
ORDER BY month;

WITH cust AS (
  SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS orders
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT COUNT(*) AS customers,
       SUM(orders > 1) AS repeat_customers,
       ROUND(100 * SUM(orders > 1) / COUNT(*), 2) AS pct_repeat
FROM cust;

WITH cust_orders AS (
  SELECT c.customer_unique_id,
         CAST(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS DATE) AS order_month
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
),
cohort AS (
  SELECT customer_unique_id, MIN(order_month) AS cohort_month
  FROM cust_orders
  GROUP BY customer_unique_id
)
SELECT DATE_FORMAT(ch.cohort_month, '%Y-%m') AS cohort,
       COUNT(DISTINCT ch.customer_unique_id) AS cohort_size,
       COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, ch.cohort_month, co.order_month) = 1
                           THEN ch.customer_unique_id END) AS m1,
       COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, ch.cohort_month, co.order_month) = 2
                           THEN ch.customer_unique_id END) AS m2,
       COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, ch.cohort_month, co.order_month) = 3
                           THEN ch.customer_unique_id END) AS m3
FROM cohort ch
JOIN cust_orders co ON ch.customer_unique_id = co.customer_unique_id
WHERE ch.cohort_month BETWEEN '2017-01-01' AND '2018-05-01'
GROUP BY ch.cohort_month
ORDER BY ch.cohort_month;

WITH cust AS (
  SELECT c.customer_unique_id,
         MAX(o.order_purchase_timestamp) AS last_order,
         COUNT(DISTINCT o.order_id) AS frequency,
         SUM(oi.price) AS monetary
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
),
scored AS (
  SELECT *,
         NTILE(5) OVER (ORDER BY last_order) AS r,   -- 5 = most recent
         CASE WHEN frequency = 1 THEN 1
              WHEN frequency = 2 THEN 3
              ELSE 5 END AS f,
         NTILE(5) OVER (ORDER BY monetary) AS m      -- 5 = highest spend
  FROM cust
)
SELECT CASE WHEN f >= 3 AND r >= 4 THEN 'Champions'
            WHEN f >= 3 THEN 'Loyal / At risk'
            WHEN r >= 4 AND m >= 4 THEN 'Recent big spenders'
            WHEN r >= 4 THEN 'New customers'
            WHEN m >= 4 THEN 'Lapsed big spenders'
            ELSE 'Low value / lapsed' END AS segment,
       COUNT(*) AS customers,
       ROUND(SUM(monetary), 2) AS revenue,
       ROUND(AVG(monetary), 2) AS avg_spend
FROM scored
GROUP BY segment
ORDER BY revenue DESC;

WITH ranked AS (
  SELECT c.customer_unique_id,
         o.order_purchase_timestamp AS ts,
         ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id
                            ORDER BY o.order_purchase_timestamp) AS rn
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
)
SELECT COUNT(*) AS repeat_customers,
       ROUND(AVG(DATEDIFF(s.ts, f.ts)), 1) AS avg_days_to_second_order,
       SUM(DATEDIFF(s.ts, f.ts) <= 30) AS within_30_days
FROM ranked f
JOIN ranked s ON f.customer_unique_id = s.customer_unique_id
WHERE f.rn = 1 AND s.rn = 2;

WITH cat_month AS (
  SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
         DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
         SUM(oi.price) AS revenue
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  JOIN products p ON oi.product_id = p.product_id
  LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
  WHERE o.order_status = 'delivered'
  GROUP BY category, month
)
SELECT category, month, ROUND(revenue, 2) AS revenue,
       ROUND(AVG(revenue) OVER (PARTITION BY category ORDER BY month
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM cat_month
WHERE category IN ('health_beauty', 'watches_gifts', 'bed_bath_table')
  AND month BETWEEN '2017-01' AND '2018-08'
ORDER BY category, month;

SELECT s.seller_state, c.customer_state,
       COUNT(*) AS orders,
       ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days,
       ROUND(100 * AVG(o.order_delivered_customer_date > o.order_estimated_delivery_date), 1) AS pct_late
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN (SELECT DISTINCT order_id, seller_id FROM order_items) oi ON o.order_id = oi.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_state, c.customer_state
HAVING COUNT(*) >= 100
ORDER BY avg_delivery_days DESC
LIMIT 10;