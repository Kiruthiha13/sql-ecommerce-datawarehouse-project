/* 
============================================================================
CUSTOMER BEHAVIOR & EXPERIENCE ANALYSIS:
This script analyzes customer behavior patterns using RFM segmentation,
evaluates the impact of installment plans on order value and returns,
explores how delivery and shipping factors influence satisfaction,
and identifies churned vs active customers based on recent activity.
============================================================================
*/

-- =====================================================
-- 1. RFM-Based Segmentation: Repeat vs One-Time Buyers
-- =====================================================

WITH customer_orders AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT f.order_id) AS frequency,
        MAX(f.order_purchase_timestamp) AS last_purchase_date,
        SUM(f.price + f.freight_value) AS monetary
    FROM olist_gold.fact_order_summary f
    JOIN olist_gold.dim_customers c ON f.customer_sk = c.customer_sk
    GROUP BY c.customer_id
),

rfm_features AS (
    SELECT
        customer_id,
        frequency,
        DATEDIFF(DAY, last_purchase_date, MAX(last_purchase_date) OVER ()) AS recency,
        monetary,
        CASE 
            WHEN frequency = 1 THEN 'One-Time Buyer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM customer_orders
)

SELECT 
    customer_type,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 1) AS avg_orders,
    CAST(ROUND(AVG(monetary), 2) AS DECIMAL(10,2)) AS avg_spend
FROM rfm_features
GROUP BY customer_type
ORDER BY customer_type;

-- ====================================================
-- 2. Installment Plan Impact on Order Value & Returns
-- ====================================================

SELECT 
    f.payment_installments,
    COUNT(DISTINCT f.order_id) AS total_orders,
    CAST(ROUND(AVG(f.price), 2) AS DECIMAL(10,2)) AS avg_order_value,
    COUNT(CASE WHEN f.order_status = 'canceled' THEN 1 END) AS total_cancellations,
    COUNT(CASE WHEN f.review_score <= 2 THEN 1 END) AS low_review_count
FROM olist_gold.fact_order_summary f
WHERE f.payment_installments IS NOT NULL
GROUP BY f.payment_installments
ORDER BY f.payment_installments;

-- ==================================================
-- 3. Delivery Speed & Shipping Cost vs Review Score
-- ==================================================

SELECT 
    f.review_score,
    COUNT(*) AS total_orders,
    ROUND(AVG(DATEDIFF(DAY, f.order_purchase_timestamp, f.order_delivered_customer_date)), 1) AS avg_delivery_days,
    CAST(ROUND(AVG(f.freight_value), 2) AS DECIMAL(10,2)) AS avg_shipping_cost
FROM olist_gold.fact_order_summary f
WHERE f.review_score IS NOT NULL
  AND f.order_delivered_customer_date IS NOT NULL
  AND f.freight_value IS NOT NULL
GROUP BY f.review_score
ORDER BY f.review_score DESC;

-- ================================================
-- 4. Customer Churn Analysis
-- ================================================

WITH customer_activity AS (
    SELECT 
        c.customer_id,
        MAX(CAST(f.order_purchase_timestamp AS DATE)) AS last_order_date
    FROM olist_gold.fact_order_summary f
    JOIN olist_gold.dim_customers c ON f.customer_sk = c.customer_sk
    GROUP BY c.customer_id
),

churned_flagged AS (
    SELECT 
        customer_id,
        last_order_date,
        CASE 
            WHEN DATEDIFF(DAY, last_order_date, GETDATE()) > 365 THEN 'Churned'
            ELSE 'Active'
        END AS customer_status
    FROM customer_activity
)

SELECT 
    customer_status,
    COUNT(*) AS customer_count,
    CAST(ROUND(100.0 * COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (), 2) AS DECIMAL(10,2)) AS percentage
FROM churned_flagged
GROUP BY customer_status
ORDER BY customer_status;
