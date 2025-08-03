USE olist_datawarehouse;
GO

/*
===============================================================================
Product & Category Risk Report
===============================================================================
Purpose:
    - Consolidates product- and category-level quality and return risk indicators 
      to surface items that may hurt profitability or customer experience.

Highlights:
    1. Identifies problematic products with frequent cancellations or very low reviews 
       (filters to those with >=5 issues). 
    2. Summarizes category-level return trends:
       - total issues per category
       - number of affected products
    3. Analyzes category review performance (requires >=50 orders):
       - average review score
       - total orders
       - cancellation volume
       - average freight cost
    4. Derives risk signals:
       - flags categories with low average review scores
       - flags products with especially high issue counts
    5. Combines product and category context in one unified view for easier triage 
       and downstream scoring or alerting.
===============================================================================
*/
CREATE VIEW olist_gold.report_products AS
WITH product_issues AS (
    SELECT 
        p.product_category_name,
        p.product_id,
        COUNT(*) AS issue_count,
        CAST(ROUND(AVG(f.price), 2) AS DECIMAL(10,2)) AS avg_price,
        ROUND(AVG(p.product_weight), 2) AS avg_weight,
        COUNT(CASE WHEN f.order_status = 'canceled' THEN 1 END) AS cancellations,
        COUNT(CASE WHEN f.review_score <= 2 THEN 1 END) AS low_reviews
    FROM olist_gold.fact_order_summary f
    JOIN olist_gold.dim_products p 
        ON f.product_sk = p.product_sk
    WHERE f.order_status = 'canceled'
       OR f.review_score <= 2
    GROUP BY p.product_category_name, p.product_id
    HAVING COUNT(*) >= 5
),
category_return_trends AS (
    SELECT 
        p.product_category_name,
        COUNT(*) AS category_total_issues,
        COUNT(DISTINCT p.product_id) AS category_affected_products
    FROM olist_gold.fact_order_summary f
    JOIN olist_gold.dim_products p 
        ON f.product_sk = p.product_sk
    WHERE f.order_status = 'canceled'
       OR f.review_score <= 2
    GROUP BY p.product_category_name
),
category_review AS (
    SELECT 
        p.product_category_name,
        COUNT(f.order_id) AS category_total_orders,
        ROUND(AVG(f.review_score), 2) AS category_avg_review_score,
        COUNT(CASE WHEN f.order_status = 'canceled' THEN 1 END) AS category_cancellations,
        CAST(ROUND(AVG(f.freight_value), 2) AS DECIMAL(10,2)) AS category_avg_freight_cost
    FROM olist_gold.fact_order_summary f
    JOIN olist_gold.dim_products p 
        ON f.product_sk = p.product_sk
    WHERE f.review_score IS NOT NULL
    GROUP BY p.product_category_name
    HAVING COUNT(f.order_id) >= 50
)
SELECT 
    pi.product_category_name,
    pi.product_id,
    pi.issue_count,
    pi.avg_price,
    pi.avg_weight,
    pi.cancellations,
    pi.low_reviews,

    crt.category_total_issues,
    crt.category_affected_products,

    cr.category_total_orders,
    cr.category_avg_review_score,
    cr.category_cancellations,
    cr.category_avg_freight_cost,

    CASE 
        WHEN cr.category_avg_review_score <= 3.5 THEN 1 ELSE 0 
    END AS low_review_category_flag,
    CASE 
        WHEN pi.issue_count >= 10 THEN 1 ELSE 0 
    END AS high_issue_product_flag
FROM product_issues pi
LEFT JOIN category_return_trends crt
    ON pi.product_category_name = crt.product_category_name
LEFT JOIN category_review cr
    ON pi.product_category_name = cr.product_category_name;

