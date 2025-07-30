/*
============================================================================
SALES PERFORMANCE ANALYSIS:
This script evaluates product-level profitability, identifies monthly 
sales trends by category, and analyzes seasonal profitability patterns 
to uncover high-performing time periods and top-margin products.
============================================================================
*/

USE olist_datawarehouse;
GO

-- =============================================================================
-- 1. Product Margin Analysis
-- Identifies high-margin products and their performance by category.
-- =============================================================================

SELECT 
    dp.product_category_name,
    f.product_sk,
    COUNT(*) AS total_orders,
    ROUND(SUM(f.price - f.freight_value), 2) AS total_profit_margin,
    CAST(ROUND(AVG(f.price - f.freight_value), 2) AS DECIMAL(10,2)) AS avg_profit_margin
FROM olist_gold.fact_order_summary f
JOIN olist_gold.dim_products dp 
    ON f.product_sk = dp.product_sk
WHERE f.price IS NOT NULL AND f.freight_value IS NOT NULL
GROUP BY dp.product_category_name, f.product_sk
ORDER BY total_profit_margin DESC;

-- =============================================================================
-- 2. Monthly Category Sales Trend
-- Shows sales volume over time by product category.
-- =============================================================================

SELECT 
    d.year,
    d.month,
    p.product_category_name,
    COUNT(*) AS total_orders,
    ROUND(SUM(f.price), 2) AS total_sales
FROM olist_gold.fact_order_summary f
JOIN olist_gold.dim_products p 
    ON f.product_sk = p.product_sk
JOIN olist_gold.dim_dates d 
    ON f.date_sk = d.date_sk
WHERE f.price IS NOT NULL
GROUP BY d.year, d.month, p.product_category_name
ORDER BY p.product_category_name, d.year, d.month;

-- ============================================================================
-- 3. Seasonal Profitability Analysis
-- Groups data by seasons to identify high-performing time periods
-- ============================================================================

SELECT 
    CASE 
        WHEN d.month IN (12, 1, 2) THEN 'Winter'
        WHEN d.month IN (3, 4, 5) THEN 'Spring'
        WHEN d.month IN (6, 7, 8) THEN 'Summer'
        WHEN d.month IN (9, 10, 11) THEN 'Fall'
    END AS season,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.price), 2) AS total_revenue,
    ROUND(SUM(f.price - f.freight_value), 2) AS total_profit_margin,
    CAST(ROUND(AVG(f.price - f.freight_value), 2) AS DECIMAL(10,2)) AS avg_profit_margin
FROM olist_gold.fact_order_summary f
JOIN olist_gold.dim_dates d 
    ON f.date_sk = d.date_sk
WHERE f.price IS NOT NULL AND f.freight_value IS NOT NULL
GROUP BY 
    CASE 
        WHEN d.month IN (12, 1, 2) THEN 'Winter'
        WHEN d.month IN (3, 4, 5) THEN 'Spring'
        WHEN d.month IN (6, 7, 8) THEN 'Summer'
        WHEN d.month IN (9, 10, 11) THEN 'Fall'
    END
ORDER BY season;
