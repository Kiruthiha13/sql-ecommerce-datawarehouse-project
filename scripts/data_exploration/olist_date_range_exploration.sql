/*
===============================================================================
Date Range Exploration
===============================================================================
Purpose:
    - To determine the time span and freshness of available data in the Gold layer.
    - Understand temporal coverage of orders, payments, reviews, and shipping.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

USE olist_datawarehouse;
GO

-- =============================================================================
-- Explore order purchase date range
-- =============================================================================
SELECT 
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) AS order_range_months
FROM olist_gold.dim_orders;

-- =============================================================================
-- Explore delivery date range
-- =============================================================================
SELECT 
    MIN(order_delivered_customer_date) AS first_delivery_date,
    MAX(order_delivered_customer_date) AS last_delivery_date,
    DATEDIFF(DAY, MIN(order_delivered_customer_date), MAX(order_delivered_customer_date)) AS delivery_span_days
FROM olist_gold.dim_orders;

-- =============================================================================
-- Explore product shipping time window (shipping_limit_date)
-- =============================================================================
SELECT 
    MIN(shipping_limit_date) AS earliest_shipping_limit,
    MAX(shipping_limit_date) AS latest_shipping_limit,
    DATEDIFF(DAY, MIN(shipping_limit_date), MAX(shipping_limit_date)) AS shipping_window_days
FROM olist_gold.fact_order_items;
