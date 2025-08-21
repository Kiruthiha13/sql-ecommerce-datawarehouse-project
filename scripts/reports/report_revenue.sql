USE olist_datawarehouse;
GO

/*
===============================================================================
Revenue Report
===============================================================================
Purpose:
    - This view consolidates high-level KPIs from olist data with the 
      ability to filter and drill down by product category, year, and season.

Highlights:
    1. Aggregates core business metrics:
       - Total Orders
       - Total Revenue
       - Total Profit Margin
    2. Breaks down results by:
       - Year
       - Month
       - Season
       - Product Category
    3. Enables flexible dashboards for executives and analysts:
       - High-level KPIs for overall performance
       - Drill-down to specific product categories and time periods
    4. Provides a unified dataset for use across multiple Tableau visualizations.

Note:
    - Average Profit Margin is expected to be calculated in Tableau as:
      [total_profit_margin] / [total_orders]

Outputs:
    - Ready-to-use dataset for Tableau with filters:
        - Year
        - Season
        - Product Category
    - Suitable for both management overviews and detailed category analysis.
===============================================================================
*/

IF OBJECT_ID('olist_gold.report_revenue', 'V') IS NOT NULL
    DROP VIEW olist_gold.report_revenue;
GO

CREATE VIEW olist_gold.report_revenue AS
SELECT 
    dp.product_category_name,
    d.year,
    d.month,
    -- Derive season inline
    CASE 
        WHEN d.month IN (12, 1, 2) THEN 'Winter'
        WHEN d.month IN (3, 4, 5) THEN 'Spring'
        WHEN d.month IN (6, 7, 8) THEN 'Summer'
        WHEN d.month IN (9, 10, 11) THEN 'Fall'
    END AS season,
    
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.price), 2) AS total_revenue,
    ROUND(SUM(f.freight_value), 2) AS total_freight,
    ROUND(SUM(f.price - f.freight_value), 2) AS total_profit_margin

FROM olist_gold.fact_order_summary f
JOIN olist_gold.dim_products dp 
    ON f.product_sk = dp.product_sk
JOIN olist_gold.dim_dates d 
    ON f.date_sk = d.date_sk
WHERE f.price IS NOT NULL AND f.freight_value IS NOT NULL
GROUP BY 
    dp.product_category_name,
    d.year,
    d.month,
    CASE 
        WHEN d.month IN (12, 1, 2) THEN 'Winter'
        WHEN d.month IN (3, 4, 5) THEN 'Spring'
        WHEN d.month IN (6, 7, 8) THEN 'Summer'
        WHEN d.month IN (9, 10, 11) THEN 'Fall'
    END;
GO

