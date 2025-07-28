/*
===============================================================================
Quality Checks for Gold Layer Views
===============================================================================
Script Purpose:
    This script validates the integrity, consistency, and accuracy of the
    Gold Layer views in the olist_gold schema. It ensures:
    
    - No NULLs in primary and foreign key columns.
    - Uniqueness of natural keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Logical correctness of business rules (e.g., valid dates, non-negative amounts).

Usage Notes:
    - Run after views are created and data is populated.
    - Investigate and resolve any reported counts > 0.
===============================================================================
*/

USE olist_datawarehouse;
GO

-- =============================================================================
-- NULL Checks for Natural Keys (Used in Joins)
-- =============================================================================
SELECT COUNT(*) AS null_customer_id FROM olist_gold.dim_customers WHERE customer_id IS NULL;
SELECT COUNT(*) AS null_product_id FROM olist_gold.dim_products WHERE product_id IS NULL;
SELECT COUNT(*) AS null_seller_id FROM olist_gold.dim_sellers WHERE seller_id IS NULL;
SELECT COUNT(*) AS null_calendar_date FROM olist_gold.dim_dates WHERE calendar_date IS NULL;
SELECT COUNT(*) AS null_order_id FROM olist_gold.fact_order_summary WHERE order_id IS NULL;

-- =============================================================================
-- Uniqueness Checks on Natural Keys
-- =============================================================================
SELECT customer_id, COUNT(*) AS cnt
FROM olist_gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS cnt
FROM olist_gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT seller_id, COUNT(*) AS cnt
FROM olist_gold.dim_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT calendar_date, COUNT(*) AS cnt
FROM olist_gold.dim_dates
GROUP BY calendar_date
HAVING COUNT(*) > 1;

SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM olist_gold.fact_order_summary
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- =============================================================================
-- Surrogate Key NULL Checks in Fact
-- =============================================================================
SELECT COUNT(*) AS null_customer_sk FROM olist_gold.fact_order_summary WHERE customer_sk IS NULL;
SELECT COUNT(*) AS null_product_sk FROM olist_gold.fact_order_summary WHERE product_sk IS NULL;
SELECT COUNT(*) AS null_seller_sk FROM olist_gold.fact_order_summary WHERE seller_sk IS NULL;
SELECT COUNT(*) AS null_date_sk FROM olist_gold.fact_order_summary WHERE date_sk IS NULL;

-- =============================================================================
-- Referential Integrity Checks (Join back to Dimension)
-- =============================================================================
SELECT COUNT(*) AS invalid_customer_fk
FROM olist_gold.fact_order_summary f
LEFT JOIN olist_gold.dim_customers d ON f.customer_sk = d.customer_sk
WHERE d.customer_sk IS NULL;

SELECT COUNT(*) AS invalid_product_fk
FROM olist_gold.fact_order_summary f
LEFT JOIN olist_gold.dim_products d ON f.product_sk = d.product_sk
WHERE d.product_sk IS NULL;

SELECT COUNT(*) AS invalid_seller_fk
FROM olist_gold.fact_order_summary f
LEFT JOIN olist_gold.dim_sellers d ON f.seller_sk = d.seller_sk
WHERE d.seller_sk IS NULL;

SELECT COUNT(*) AS invalid_date_fk
FROM olist_gold.fact_order_summary f
LEFT JOIN olist_gold.dim_dates d ON f.date_sk = d.date_sk
WHERE d.date_sk IS NULL;

-- =============================================================================
-- Business Rule Validations
-- =============================================================================

-- Invalid delivery timeline
SELECT COUNT(*) AS invalid_delivery_dates
FROM olist_gold.fact_order_summary
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- Shipping deadline earlier than purchase
SELECT COUNT(*) AS invalid_shipping_limit
FROM olist_gold.fact_order_summary
WHERE shipping_limit_date < order_purchase_timestamp;

-- Price or freight issues
SELECT COUNT(*) AS negative_price_or_freight
FROM olist_gold.fact_order_summary
WHERE price < 0 OR freight_value < 0;

-- Payment issues (if payment_value is optional)
SELECT COUNT(*) AS negative_payment
FROM olist_gold.fact_order_summary
WHERE payment_value < 0;

-- Review scores out of bounds
SELECT COUNT(*) AS invalid_review_scores
FROM olist_gold.fact_order_summary
WHERE review_score IS NOT NULL AND (review_score < 1 OR review_score > 5);
