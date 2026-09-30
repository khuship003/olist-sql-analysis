# Olist E-Commerce SQL Analysis

Analysis of 100k Brazilian e-commerce orders (2016-2018) across 9 relational tables,
answering 20 business questions with MySQL (joins, CTEs, window functions).

## Dataset
[Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle).
Tables: customers, orders, order_items, order_payments, order_reviews, products,
sellers, geolocation, category_translation.

![ER diagram](images/er_diagram.png)

## Tools
MySQL 8.0, MySQL Workbench, Excel (charts)

## Data quality findings
- 97.02% of orders are delivered; revenue analysis uses delivered orders only
- 8 delivered orders lack a delivery date; 0 orders delivered before purchase
- 2 product categories have no English translation (handled with COALESCE)
- 99,441 customer_ids map to 96,096 real customers, so customer_unique_id is used for retention
- Zero-value dates in order_reviews were converted to NULL; no orphan records

## Key findings
1. **Growth:** revenue grew through 2017 via order volume, peaking at Black Friday
   (Nov 2017: 7,289 orders, R$987,765). Average order value stayed flat at R$125-150.
   ![Monthly trend](images/monthly_revenue_trend.png)
2. **Category concentration:** top 10 categories generate ~62% of revenue.
   ![Top categories](images/top_categories.png)
3. **Geography:** SP alone is ~38% of revenue; SP, RJ, MG together ~63%.
   ![Revenue by state](images/revenue_by_state.png)
4. **Delivery:** X% of orders arrive late; late orders average a review score of X vs Y on time.
   ![Late vs reviews](images/late_vs_review_score.png)
5. **Sellers:** the top 10% of sellers generate X% of revenue.
   ![Seller Pareto](images/seller_pareto.png)
6. **Retention:** only X% of customers buy again; monthly cohort retention is ~0.3-0.6%.
   ![Cohort retention](images/cohort_retention.png)
7. **RFM:** [one line about the largest segment and revenue share].
   ![RFM](images/rfm_segments.png)

## Recommendations
- Improve delivery reliability (SLA monitoring for slow seller-state routes)
- Launch post-purchase retention campaigns, since repeat rate is very low
- Plan inventory and seller capacity ahead of November
- Reduce dependence on the southeast via seller recruitment in other regions

## Caveats
Revenue = item price excluding freight, delivered orders only. Aug-Oct 2018 data is incomplete.

## How to reproduce
1. Download the dataset from Kaggle
2. Run `01_schema/create_tables.sql`
3. Edit the file paths in `01_schema/load_data.sql`, then run it from the mysql client with `--local-infile=1`
4. Run the scripts in `02_data_quality/`, `03_analysis/`, `04_views/`