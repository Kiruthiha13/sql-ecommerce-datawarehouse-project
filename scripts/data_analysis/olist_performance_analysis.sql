-- =============================================================================
-- Products, Sellers and Sales Performance Analysis 
-- =============================================================================

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

-- =============================================================================
-- 3. Product Return Risk
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

-- =============================================================================
-- 4. Seller Revenue Distribution (Pareto Analysis)
-- Analyzes contribution of top 10% sellers to total revenue.
-- =============================================================================

WITH seller_revenue AS (
    SELECT 
        s.seller_id,
        SUM(f.price + f.freight_value) AS total_revenue
    FROM olist_gold.fact_order_summary f
    JOIN olist_gold.dim_sellers s ON f.seller_sk = s.seller_sk
    GROUP BY s.seller_id
),
ranked_sellers AS (
    SELECT 
        seller_id,
        total_revenue,
        NTILE(10) OVER (ORDER BY total_revenue DESC) AS decile
    FROM seller_revenue
),
top_10_percent AS (
    SELECT *
    FROM ranked_sellers
    WHERE decile = 1
),
total_summary AS (
    SELECT 
        (SELECT SUM(total_revenue) FROM top_10_percent) AS top_10_revenue,
        (SELECT SUM(total_revenue) FROM seller_revenue) AS total_revenue
)
SELECT 
    t.seller_id,
    t.total_revenue AS seller_revenue,
    s.top_10_revenue,
    s.total_revenue,
    CAST(ROUND(100.0 * t.total_revenue / s.total_revenue, 2) AS DECIMAL(10,2)) AS seller_contribution_pct,
    CAST(ROUND(100.0 * s.top_10_revenue / s.total_revenue, 2) AS DECIMAL(10,2)) AS top_10_contribution_pct
FROM top_10_percent t
CROSS JOIN total_summary s
ORDER BY t.total_revenue DESC;
