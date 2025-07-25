/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG(), DISTINCT
===============================================================================
*/

USE olist_datawarehouse;
GO

-- =============================================================================
-- Total Revenue (Price + Freight)
-- =============================================================================
SELECT 
    SUM(price + freight_value) AS total_revenue 
FROM olist_gold.fact_order_items;

-- =============================================================================
-- Total Number of Orders
-- =============================================================================
SELECT 
    COUNT(DISTINCT order_id) AS total_orders 
FROM olist_gold.fact_order_items;

-- =============================================================================
-- Total Number of Products
-- =============================================================================
SELECT 
    COUNT(DISTINCT product_id) AS total_products 
FROM olist_gold.dim_products;

-- =============================================================================
-- Total Number of Sellers
-- =============================================================================
SELECT 
    COUNT(DISTINCT seller_id) AS total_sellers 
FROM olist_gold.dim_sellers;

-- =============================================================================
-- Total Number of Customers
-- =============================================================================
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers 
FROM olist_gold.dim_customers;

-- =============================================================================
-- Average Review Score
-- =============================================================================
SELECT 
    ROUND(AVG(review_score * 1.0), 2) AS avg_review_score 
FROM olist_gold.dim_reviews;

-- =============================================================================
-- Count by Payment Category
-- =============================================================================
SELECT 
    payment_category, 
    COUNT(*) AS payment_count 
FROM olist_gold.dim_payments
GROUP BY payment_category;

-- =============================================================================
-- Business Summary Report (All Key Metrics)
-- =============================================================================

SELECT 'Total Revenue' AS metric, CAST(SUM(price + freight_value) AS DECIMAL(12, 2)) AS value FROM olist_gold.fact_order_items
UNION ALL
SELECT 'Total Orders', CAST(COUNT(DISTINCT order_id) AS INT) FROM olist_gold.fact_order_items
UNION ALL
SELECT 'Total Products', CAST(COUNT(DISTINCT product_id) AS INT) FROM olist_gold.dim_products
UNION ALL
SELECT 'Total Sellers', CAST(COUNT(DISTINCT seller_id) AS INT) FROM olist_gold.dim_sellers
UNION ALL
SELECT 'Total Customers', CAST(COUNT(DISTINCT customer_id) AS INT) FROM olist_gold.dim_customers
UNION ALL
SELECT 'Average Review Score', CAST(ROUND(AVG(review_score * 1.0), 2) AS DECIMAL(4, 2)) FROM olist_gold.dim_reviews;
