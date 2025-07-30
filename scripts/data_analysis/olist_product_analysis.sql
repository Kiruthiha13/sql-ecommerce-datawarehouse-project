/*
=============================================================================
PRODUCT ANALYSIS:
This section focuses on evaluating product-level and category-level performance.
It identifies frequently returned or poorly rated products, trends in customer
satisfaction, and highlights product risks that may impact profitability and
customer experience.
-- =============================================================================
*/

USE olist_datawarehouse;
GO

-- =============================================================================
-- 1. Product Return Risk
-- Identifies frequently returned or low-rated products and trends by category.
-- =============================================================================

-- Product-level risk indicators
SELECT 
    p.product_category_name,
    p.product_id,
    COUNT(*) AS issue_count,
    CAST(ROUND(AVG(f.price), 2) AS DECIMAL(10,2)) AS avg_price,
    ROUND(AVG(p.product_weight), 2) AS avg_weight,
    COUNT(CASE WHEN f.order_status = 'canceled' THEN 1 END) AS cancellations,
    COUNT(CASE WHEN f.review_score <= 2 THEN 1 END) AS low_reviews
FROM olist_gold.fact_order_summary f
JOIN olist_gold.dim_products p ON f.product_sk = p.product_sk
WHERE f.order_status = 'canceled'
   OR f.review_score <= 2
GROUP BY p.product_category_name, p.product_id
HAVING COUNT(*) >= 5  -- Filter for frequently problematic products
ORDER BY issue_count DESC;

-- Category-level return trends
SELECT 
    p.product_category_name,
    COUNT(*) AS total_issues,
    COUNT(DISTINCT p.product_id) AS affected_products
FROM olist_gold.fact_order_summary f
JOIN olist_gold.dim_products p ON f.product_sk = p.product_sk
WHERE f.order_status = 'canceled'
   OR f.review_score <= 2
GROUP BY p.product_category_name
ORDER BY total_issues DESC;

-- ============================================================================
-- 2. Product Category Review Analysis
-- Analyzes review trends by category and highlights potential drivers.
-- ============================================================================

SELECT 
    p.product_category_name,
    COUNT(f.order_id) AS total_orders,
    ROUND(AVG(f.review_score), 2) AS avg_review_score,
    COUNT(CASE WHEN f.order_status = 'canceled' THEN 1 END) AS total_cancellations,
    CAST(ROUND(AVG(f.freight_value), 2) AS DECIMAL(10,2)) AS avg_freight_cost
FROM olist_gold.fact_order_summary f
JOIN olist_gold.dim_products p ON f.product_sk = p.product_sk
WHERE f.review_score IS NOT NULL
GROUP BY p.product_category_name
HAVING COUNT(f.order_id) >= 50  -- Filter out categories with very few orders
ORDER BY avg_review_score ASC;  -- Sort to find low-rated categories easily
