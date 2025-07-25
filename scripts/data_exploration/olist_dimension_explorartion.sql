/*
===============================================================================
Dimensions Exploration 
===============================================================================
Purpose:
    - To explore the structure and diversity of data in dimension tables.
    - Understand the range and distinct values for categorical attributes.

SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

USE olist_datawarehouse;
GO

-- =============================================================================
-- Customers: Explore unique customer states and cities
-- =============================================================================
SELECT DISTINCT 
    customer_state, 
    customer_city
FROM olist_gold.dim_customers
ORDER BY customer_state, customer_city;

-- =============================================================================
-- Products: Explore unique product categories
-- =============================================================================
SELECT DISTINCT 
    product_category_name
FROM olist_gold.dim_products
ORDER BY product_category_name;

-- =============================================================================
-- Orders: Explore unique order status and delivery issues
-- =============================================================================
SELECT DISTINCT 
    order_status
FROM olist_gold.dim_orders
ORDER BY order_status;

SELECT DISTINCT 
    issue_type
FROM olist_gold.dim_orders
ORDER BY issue_type;

-- =============================================================================
-- Payments: Explore unique payment types and categories
-- =============================================================================
SELECT DISTINCT 
    payment_type, 
    payment_category
FROM olist_gold.dim_payments
ORDER BY payment_category, payment_type;

-- =============================================================================
-- Reviews: Explore unique review scores
-- =============================================================================
SELECT DISTINCT 
    review_score
FROM olist_gold.dim_reviews
ORDER BY review_score;

-- =============================================================================
-- Sellers: Explore unique seller states and cities
-- =============================================================================
SELECT DISTINCT 
    seller_state, 
    seller_city
FROM olist_gold.dim_sellers
ORDER BY seller_state, seller_city;
