/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs necessary transformations and enrichments on data from 
    the Silver layer to make it business-ready for reporting and analysis.

Usage:
    - These views can be queried directly for analytics, KPIs, dashboards, etc.
===============================================================================
*/

USE olist_datawarehouse;
GO

-- ============================================================================
-- Create Dimension: olist_gold.dim_customers
-- Captures customer demographic and geographic details.
-- ============================================================================
IF OBJECT_ID('olist_gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_customers;
GO

CREATE VIEW olist_gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_sk,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM olist_silver.customers;
GO

-- ============================================================================
-- Create Dimension: olist_gold.dim_products
-- Provides product categories and basic product attributes.
-- ============================================================================
IF OBJECT_ID('olist_gold.dim_products', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_products;
GO

CREATE VIEW olist_gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY p.product_id) AS product_sk,
    p.product_id,
    COALESCE(t.product_category_name_english, 'Unknown') AS product_category_name,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM olist_silver.products p
LEFT JOIN olist_silver.product_category_name_translation t 
    ON p.product_category_name = t.product_category_name;
GO

-- ============================================================================
-- Create Dimension: olist_gold.dim_sellers
-- Basic seller location information.
-- ============================================================================
IF OBJECT_ID('olist_gold.dim_sellers', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_sellers;
GO

CREATE VIEW olist_gold.dim_sellers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_sk,
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM olist_silver.sellers;
GO

-- ============================================================================
-- Create Dimension: dim_dates
-- Calendar dimension providing derived attributes (year, month, day, weekday)
-- from order purchase timestamps to support time-based analysis.
-- ============================================================================
IF OBJECT_ID('olist_gold.dim_dates', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_dates;
GO

CREATE VIEW olist_gold.dim_dates AS
WITH distinct_dates AS (
    SELECT DISTINCT
        CAST(order_purchase_timestamp AS DATE) AS calendar_date
    FROM olist_silver.orders
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY calendar_date) AS date_sk,
    calendar_date,
    DATEPART(YEAR, calendar_date) AS year,
    DATEPART(MONTH, calendar_date) AS month,
    DATEPART(DAY, calendar_date) AS day,
    DATENAME(WEEKDAY, calendar_date) AS weekday_name
FROM distinct_dates;
GO

-- ==================================================================================
-- Create FACT: fact_order_summary
-- Central fact view representing individual order items enriched with customer,
-- product, seller, payment, review, and date surrogate keys for analytical queries.
-- ==================================================================================
IF OBJECT_ID('olist_gold.fact_order_summary', 'V') IS NOT NULL
    DROP VIEW olist_gold.fact_order_summary;
GO

CREATE VIEW olist_gold.fact_order_summary AS
-- Aggregate payments
WITH payments_agg AS (
    SELECT 
        order_id,
        MAX(payment_type) AS payment_type,
        MAX(payment_installments) AS payment_installments,
        SUM(payment_value) AS payment_value
    FROM olist_silver.order_payments
    GROUP BY order_id
),

-- Aggregate reviews
reviews_agg AS (
    SELECT 
        order_id,
        MAX(review_score) AS review_score
    FROM olist_silver.order_reviews
    GROUP BY order_id
)

-- Now join these to the fact
SELECT
    oi.order_id,
    oi.order_item_id,
    dc.customer_sk,
    dp.product_sk,
    ds.seller_sk,
    dd.date_sk,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.shipping_limit_date,
    oi.price,
    oi.freight_value,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    r.review_score
FROM olist_silver.order_items oi
JOIN olist_silver.orders o ON oi.order_id = o.order_id
JOIN olist_gold.dim_customers dc ON o.customer_id = dc.customer_id
JOIN olist_gold.dim_products dp ON oi.product_id = dp.product_id
JOIN olist_gold.dim_sellers ds ON oi.seller_id = ds.seller_id
JOIN olist_gold.dim_dates dd ON CAST(o.order_purchase_timestamp AS DATE) = dd.calendar_date
LEFT JOIN payments_agg p ON oi.order_id = p.order_id
LEFT JOIN reviews_agg r ON oi.order_id = r.order_id;
