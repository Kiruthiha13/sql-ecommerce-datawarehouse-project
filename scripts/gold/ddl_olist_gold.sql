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

-- =============================================================================
-- Create Dimension: olist_gold.dim_customers
-- Captures customer demographic and geographic details.
-- =============================================================================

USE olist_datawarehouse;
GO

IF OBJECT_ID('olist_gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_customers;
GO

CREATE VIEW olist_gold.dim_customers AS
SELECT  
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM olist_silver.customers;
GO

-- =============================================================================
-- Create Dimension: olist_gold.dim_products
-- Provides product categories and basic product attributes.
-- =============================================================================

IF OBJECT_ID('olist_gold.dim_products', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_products;
GO

CREATE VIEW olist_gold.dim_products AS
SELECT
    p.product_id,
    COALESCE(pt.product_category_name_english, 'Unknown') AS product_category_name,
    product_weight_g AS product_weight
FROM olist_silver.products p
LEFT JOIN olist_silver.product_category_name_translation pt 
    ON p.product_category_name = pt.product_category_name
GROUP BY
    p.product_id,
    product_weight_g,
    pt.product_category_name_english;
GO

-- =============================================================================
-- Create Dimension: olist_gold.dim_orders
-- Tracks order lifecycle and timestamps.
-- =============================================================================

IF OBJECT_ID('olist_gold.dim_orders', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_orders;
GO

CREATE VIEW olist_gold.dim_orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    issue_type 
FROM olist_silver.orders;
GO

-- =============================================================================
-- Create Dimension: olist_gold.dim_payments
-- Describes payment method and installment structure.
-- =============================================================================

IF OBJECT_ID('olist_gold.dim_payments', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_payments;
GO

CREATE VIEW olist_gold.dim_payments AS
SELECT
    order_id,
    payment_type,
    payment_sequential,
    payment_installments,
    payment_value,
    CASE 
        WHEN payment_type IN ('CREDIT_CARD', 'DEBIT_CARD') THEN 'Digital'
        WHEN payment_type IN ('VOUCHER', 'BANK_SLIP') THEN 'Non-Digital'
        ELSE 'Unknown'
    END AS payment_category
FROM olist_silver.order_payments;
GO

-- =============================================================================
-- Create Dimension: olist_gold.dim_sellers
-- Basic seller location information.
-- =============================================================================

IF OBJECT_ID('olist_gold.dim_sellers', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_sellers;
GO

CREATE VIEW olist_gold.dim_sellers AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM olist_silver.sellers;
GO

-- =============================================================================
-- Create Dimension: olist_gold.dim_reviews
-- Captures review scores associated with orders.
-- =============================================================================

IF OBJECT_ID('olist_gold.dim_reviews', 'V') IS NOT NULL
    DROP VIEW olist_gold.dim_reviews;
GO

CREATE VIEW olist_gold.dim_reviews AS
SELECT
    review_id,
    order_id,
    review_score
FROM olist_silver.order_reviews;
GO

-- =============================================================================
-- Create Fact: olist_gold.fact_order_items
-- Line-level facts including prices, freight, and items per order.
-- =============================================================================

IF OBJECT_ID('olist_gold.fact_order_items', 'V') IS NOT NULL
    DROP VIEW olist_gold.fact_order_items;
GO

CREATE VIEW olist_gold.fact_order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM olist_silver.order_items;
GO
