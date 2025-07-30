/*
============================================================================
REVENUE ANALYSIS: 
This script provides insights into revenue drivers by analyzing payment 
method performance, monthly revenue trends, shipping cost impact by order 
size, and seller contribution concentration (Pareto analysis). It helps 
uncover which payment types, time periods, and seller segments drive the 
most value and how profit margins are affected by shipping costs.
============================================================================
*/

USE olist_datawarehouse;
GO

-- ===============================================================
-- 1. Payment Method Performance: Order Value & Cancellation Rate
-- ===============================================================

SELECT 
    f.payment_type,
    COUNT(DISTINCT f.order_id) AS total_orders,
    CAST(ROUND(AVG(f.price), 2) AS DECIMAL(10,2)) AS avg_order_value,
    COUNT(CASE WHEN f.order_status = 'canceled' THEN 1 END) AS total_cancellations,
    CAST(ROUND(100.0 * COUNT(CASE WHEN f.order_status = 'canceled' THEN 1 END) / COUNT(*), 2) AS DECIMAL(5,2)) AS cancellation_rate_pct
FROM olist_gold.fact_order_summary f
WHERE f.payment_type IS NOT NULL
GROUP BY f.payment_type
ORDER BY avg_order_value DESC;

-- ===============================================================
-- 2. Monthly Revenue, AOV, and Order Volume Trend Analysis
-- ===============================================================

SELECT 
    d.year,
    d.month,
    COUNT(DISTINCT f.order_id) AS order_volume,
    CAST(ROUND(SUM(f.price + f.freight_value), 2) AS DECIMAL(12,2)) AS total_revenue,
    CAST(ROUND(AVG(f.price + f.freight_value), 2) AS DECIMAL(10,2)) AS avg_order_value
FROM olist_gold.fact_order_summary f
JOIN olist_gold.dim_dates d ON f.date_sk = d.date_sk
WHERE f.price IS NOT NULL AND f.freight_value IS NOT NULL
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- =============================================
-- 3. Shipping Cost vs Profit Margin by Order Size
-- =============================================

SELECT 
    CASE 
        WHEN f.price < 50 THEN 'Low'
        WHEN f.price BETWEEN 50 AND 150 THEN 'Medium'
        ELSE 'High'
    END AS order_size_bucket,
    COUNT(*) AS order_count,
    CAST(ROUND(AVG(f.price), 2) AS DECIMAL(10,2)) AS avg_price,
    CAST(ROUND(AVG(f.freight_value), 2) AS DECIMAL(10,2)) AS avg_shipping_cost,
    CAST(ROUND(AVG(f.price - f.freight_value), 2) AS DECIMAL(10,2)) AS avg_profit_margin
FROM olist_gold.fact_order_summary f
WHERE f.price IS NOT NULL AND f.freight_value IS NOT NULL
GROUP BY 
    CASE 
        WHEN f.price < 50 THEN 'Low'
        WHEN f.price BETWEEN 50 AND 150 THEN 'Medium'
        ELSE 'High'
    END
ORDER BY order_size_bucket;

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
