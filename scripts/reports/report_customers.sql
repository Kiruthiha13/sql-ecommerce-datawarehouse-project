USE olist_datawarehouse;
GO

/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This view consolidates customer purchase behavior and performance metrics
      to enable customer segmentation, churn analysis, and RFM scoring.

Highlights:
    1. Aggregates order-level data at the customer level.
    2. Captures lifecycle timestamps:
       - first purchase date
       - last purchase date
    3. Summarizes transaction activity:
       - purchase frequency
       - total monetary value (price + freight)
       - number of orders with installments
       - canceled orders count
    4. Calculates valuable KPIs:
       - Recency (days since last purchase)
       - Average review score
       - Customer type (One-Time Buyer vs Repeat Customer)
       - Churn status (Active vs Churned > 365 days)
       - RFM quartiles for Recency, Frequency, and Monetary

Outputs:
    - Segmentation-ready customer dataset for downstream analytics & reporting
===============================================================================
*/

IF OBJECT_ID('olist_gold.report_customers', 'V') IS NOT NULL
    DROP VIEW olist_gold.report_customers;
GO

CREATE OR ALTER VIEW olist_gold.report_customers AS
WITH customer_orders AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT f.order_id) AS frequency,
        MAX(f.order_purchase_timestamp) AS last_purchase_timestamp,
        MIN(f.order_purchase_timestamp) AS first_purchase_timestamp,
        SUM(COALESCE(f.price,0) + COALESCE(f.freight_value,0)) AS total_monetary,
        AVG(f.review_score) AS avg_review_score,
        SUM(CASE WHEN f.payment_installments IS NOT NULL THEN 1 ELSE 0 END) AS installment_order_count,
        COUNT(DISTINCT CASE WHEN f.order_status = 'canceled' THEN f.order_id END) AS canceled_orders
    FROM olist_gold.dim_customers c
    LEFT JOIN olist_gold.fact_order_summary f ON c.customer_sk = f.customer_sk
    GROUP BY c.customer_id
),
recency_calc AS (
    SELECT 
        customer_id,
        frequency,
        DATEDIFF(DAY, last_purchase_timestamp, MAX(last_purchase_timestamp) OVER ()) AS recency_days,
        total_monetary,
        avg_review_score,
        installment_order_count,
        canceled_orders,
        last_purchase_timestamp,
        first_purchase_timestamp
    FROM customer_orders
),
churn_flag AS (
    SELECT
        *,
        CASE 
            WHEN DATEDIFF(DAY, last_purchase_timestamp, GETDATE()) > 365 THEN 'Churned'
            ELSE 'Active'
        END AS churn_status,
        CASE 
            WHEN frequency = 1 THEN 'One-Time Buyer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM recency_calc
),
rfm_buckets AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY recency_days) AS recency_quartile,     -- 1 = most recent
        NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_quartile, -- 1 = highest freq
        NTILE(4) OVER (ORDER BY total_monetary DESC) AS monetary_quartile -- 1 = highest spend
    FROM churn_flag
)
SELECT * FROM rfm_buckets;
