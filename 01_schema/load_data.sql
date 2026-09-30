USE olist;
SET GLOBAL local_infile = 1;

TRUNCATE TABLE category_translation;
TRUNCATE TABLE customers;
TRUNCATE TABLE sellers;
TRUNCATE TABLE products;
TRUNCATE TABLE orders;
TRUNCATE TABLE order_items;
TRUNCATE TABLE order_payments;
TRUNCATE TABLE order_reviews;
TRUNCATE TABLE geolocation;

LOAD DATA LOCAL INFILE '/path/to/archive/product_category_name_translation.csv'
INTO TABLE category_translation CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/archive/olist_customers_dataset.csv'
INTO TABLE customers CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/archive/olist_sellers_dataset.csv'
INTO TABLE sellers CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/archive/olist_products_dataset.csv'
INTO TABLE products CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS
(product_id, @cat, @a, @b, @c, @d, @e, @f, @g)
SET product_category_name = NULLIF(@cat,''),
    product_name_lenght = NULLIF(@a,''),
    product_description_lenght = NULLIF(@b,''),
    product_photos_qty = NULLIF(@c,''),
    product_weight_g = NULLIF(@d,''),
    product_length_cm = NULLIF(@e,''),
    product_height_cm = NULLIF(@f,''),
    product_width_cm = NULLIF(@g,'');

LOAD DATA LOCAL INFILE '/path/to/archive/olist_orders_dataset.csv'
INTO TABLE orders CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS
(order_id, customer_id, order_status, order_purchase_timestamp,
 @approved, @carrier, @delivered, order_estimated_delivery_date)
SET order_approved_at = NULLIF(@approved,''),
    order_delivered_carrier_date = NULLIF(@carrier,''),
    order_delivered_customer_date = NULLIF(@delivered,'');

LOAD DATA LOCAL INFILE '/path/to/archive/olist_order_items_dataset.csv'
INTO TABLE order_items CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/archive/olist_order_payments_dataset.csv'
INTO TABLE order_payments CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/archive/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS
(review_id, order_id, review_score, @title, @msg, @created, @answered)
SET review_comment_title = NULLIF(@title,''),
    review_comment_message = NULLIF(@msg,''),
    review_creation_date = NULLIF(@created,''),
    review_answer_timestamp = NULLIF(@answered,'');

LOAD DATA LOCAL INFILE '/path/to/archive/olist_geolocation_dataset.csv'
INTO TABLE geolocation CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

SELECT 'customers' AS tbl, COUNT(*) AS n FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation;