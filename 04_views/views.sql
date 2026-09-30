CREATE OR REPLACE VIEW vw_order_details AS
SELECT o.order_id, o.order_status, o.order_purchase_timestamp,
       o.order_delivered_customer_date, o.order_estimated_delivery_date,
       c.customer_unique_id, c.customer_state, c.customer_city,
       oi.order_item_id, oi.product_id, oi.seller_id, oi.price, oi.freight_value,
       COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
FROM orders o
JOIN customers c   ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p    ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name;

CREATE OR REPLACE VIEW vw_seller_performance AS
SELECT s.seller_id, s.seller_state,
       r.orders, r.revenue,
       sc.avg_review_score,
       r.pct_late
FROM sellers s
JOIN (
  SELECT oi.seller_id,
         COUNT(DISTINCT oi.order_id) AS orders,
         ROUND(SUM(oi.price), 2) AS revenue,
         ROUND(100 * AVG(o.order_delivered_customer_date > o.order_estimated_delivery_date), 1) AS pct_late
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY oi.seller_id
) r ON s.seller_id = r.seller_id
LEFT JOIN (
  SELECT x.seller_id, ROUND(AVG(rv.review_score), 2) AS avg_review_score
  FROM (SELECT DISTINCT order_id, seller_id FROM order_items) x
  JOIN order_reviews rv ON x.order_id = rv.order_id
  GROUP BY x.seller_id
) sc ON s.seller_id = sc.seller_id;