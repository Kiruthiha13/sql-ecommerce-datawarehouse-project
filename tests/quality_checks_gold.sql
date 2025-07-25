/*
===============================================================================
Quality Checks for Gold Layer Views
===============================================================================
Script Purpose:
    This script validates the integrity, consistency, and accuracy of the
    Gold Layer views in the olist_gold schema. It ensures:
    
    - No NULLs in primary key columns of dimension and fact views.
    - Uniqueness of keys in dimension and fact tables.
    - Referential integrity between facts and corresponding dimensions.
    - Logical correctness of business rules (e.g., valid dates, non-negative amounts).

Usage Notes:
    - Run after views are created and data is populated.
    - Investigate and address any counts > 0 reported by these queries.
===============================================================================
*/

USE olist_datawarehouse;
GO

-- =============================================================================
-- NULL Checks for Primary Keys
-- =============================================================================
-- Customers
SELECT COUNT(*) AS null_customer_id FROM olist_gold.dim_customers WHERE customer_id IS NULL;

-- Products
SELECT COUNT(*) AS null_product_id FROM olist_gold.dim_products WHERE product_id IS NULL;

-- Orders
SELECT COUNT(*) AS null_order_id FROM olist_gold.dim_orders WHERE order_id IS NULL;

-- Sellers
SELECT COUNT(*) AS null_seller_id FROM olist_gold.dim_sellers WHERE seller_id IS NULL;

-- Reviews
SELECT COUNT(*) AS null_review_id FROM olist_gold.dim_reviews WHERE review_id IS NULL;

-- Order Items (composite PK)
SELECT COUNT(*) AS null_fact_order_items_key
FROM olist_gold.fact_order_items
WHERE order_id IS NULL OR order_item_id IS NULL;

-- =============================================================================
-- Uniqueness Checks
-- =============================================================================
-- Customers
SELECT customer_id, COUNT(*) AS cnt
FROM olist_gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Products
SELECT product_id, COUNT(*) AS cnt
FROM olist_gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Orders
SELECT order_id, COUNT(*) AS cnt
FROM olist_gold.dim_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Sellers
SELECT seller_id, COUNT(*) AS cnt
FROM olist_gold.dim_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Reviews
SELECT review_id, COUNT(*) AS cnt
FROM olist_gold.dim_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

-- Order Items
SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM olist_gold.fact_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- =============================================================================
-- Referential Integrity Checks
-- =============================================================================

-- Fact Order Items: Product
SELECT COUNT(*) AS missing_product_fk
FROM olist_gold.fact_order_items f
LEFT JOIN olist_gold.dim_products d ON f.product_id = d.product_id
WHERE d.product_id IS NULL;

-- Fact Order Items: Seller
SELECT COUNT(*) AS missing_seller_fk
FROM olist_gold.fact_order_items f
LEFT JOIN olist_gold.dim_sellers d ON f.seller_id = d.seller_id
WHERE d.seller_id IS NULL;

-- Fact Order Items: Order
SELECT COUNT(*) AS missing_order_fk
FROM olist_gold.fact_order_items f
LEFT JOIN olist_gold.dim_orders d ON f.order_id = d.order_id
WHERE d.order_id IS NULL;

-- Orders: Customer
SELECT COUNT(*) AS missing_customer_fk
FROM olist_gold.dim_orders o
LEFT JOIN olist_gold.dim_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Payments: Order
SELECT COUNT(*) AS missing_order_fk_in_payments
FROM olist_gold.dim_payments p
LEFT JOIN olist_gold.dim_orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Reviews: Order
SELECT COUNT(*) AS missing_order_fk_in_reviews
FROM olist_gold.dim_reviews r
LEFT JOIN olist_gold.dim_orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- =============================================================================
-- Data Consistency Checks
-- =============================================================================

-- Orders: Validate delivery dates
SELECT COUNT(*) AS invalid_delivery_dates
FROM olist_gold.dim_orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- Payments: Negative values
SELECT COUNT(*) AS negative_payment_value
FROM olist_gold.dim_payments
WHERE payment_value < 0;

-- Order Items: Invalid prices
SELECT COUNT(*) AS invalid_price
FROM olist_gold.fact_order_items
WHERE price <= 0 OR freight_value < 0;

-- Reviews: Out-of-range scores
SELECT COUNT(*) AS invalid_review_scores
FROM olist_gold.dim_reviews
WHERE review_score NOT BETWEEN 1 AND 5;
