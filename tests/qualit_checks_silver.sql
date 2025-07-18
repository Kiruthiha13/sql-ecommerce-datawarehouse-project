/*
===============================================================================
  Silver Layer Data Validation
===============================================================================

  PURPOSE:
  --------
  This script performs data quality and validation checks on the Silver layer
  tables The Silver layer contains cleaned and transformed data derived from the raw (Bronze) layer. 
  This validation ensures that the data is:
    - Accurate
    - Consistent
    - Well-structured
    - Ready for analytical consumption in the Gold layer

  SCOPE OF VALIDATIONS:
  ---------------------
  The following categories of checks are applied to each Silver table:
    1. Duplicate primary key detection
    2. Null checks on mandatory fields
    3. Referential integrity across related tables (checked for Parent table)
    4. Text normalization
    5. Logical consistency

Usage Notes:
    - Run these checks after loading data into Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
Note: 
    - No result must be returned for the below queries.
    - If any rows are returned, they indicate failed validations that must be reviewed.

===============================================================================
*/

USE olist_datawarehouse;
GO

PRINT ' SILVER LAYER TABLES VALIDATION';

-- =====================================
-- Customer Table Validation
-- =====================================

-- Duplicate primary key detection
SELECT 
    customer_id,
    COUNT(*) 
FROM olist_silver.customers
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL;

-- Null checks on mandatory fields
SELECT * 
FROM olist_silver.customers
WHERE 
   customer_id IS NULL 
   OR customer_unique_id IS NULL 
   OR customer_zip_code_prefix IS NULL
   OR customer_city IS NULL
   OR customer_state IS NULL;

-- Text normalization
SELECT
    customer_city,
    customer_state
FROM olist_silver.customers
WHERE 
   TRIM(customer_city) != customer_city 
   OR TRIM(customer_state) != customer_state;

-- Referential integrity across related tables
SELECT 
    c.customer_id 
FROM olist_silver.customers c
LEFT JOIN olist_silver.orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- Logical consistency
SELECT 
    customer_unique_id
FROM olist_silver.customers
GROUP BY customer_unique_id
HAVING COUNT(customer_id) = 0;

-- =====================================
-- Geolocation Table Validation
-- =====================================

-- Null checks on mandatory fields
SELECT * 
FROM olist_silver.geolocation
WHERE 
    geolocation_zip_code_prefix IS NULL
    OR geolocation_lng IS NULL
    OR geolocation_lat IS NULL
    OR geolocation_city IS NULL
    OR geolocation_state IS NULL;

-- Text normalization
SELECT 
    geolocation_city,
    geolocation_state
FROM olist_silver.geolocation
WHERE 
   TRIM(geolocation_city) != geolocation_city 
   OR TRIM(geolocation_state) != geolocation_state;

-- =====================================
-- Orders Table Validation
-- =====================================

-- Duplicate primary key detection
SELECT
    order_id,
    COUNT(*)
FROM olist_silver.orders
GROUP BY order_id
HAVING COUNT(*) > 1 OR order_id IS NULL;

-- Null checks on mandatory fields
SELECT * 
FROM olist_silver.orders
WHERE 
    order_id IS NULL
    OR customer_id IS NULL
    OR order_status IS NULL
    OR order_purchase_timestamp IS NULL
    OR order_estimated_delivery_date IS NULL;

-- Text normalization
SELECT 
    order_status
FROM olist_silver.orders
WHERE TRIM(order_status) != order_status;

-- Referential integrity across related tables
SELECT 
    i.order_id
FROM olist_silver.order_items i
LEFT JOIN olist_silver.orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT 
    op.order_id
FROM olist_silver.order_payments op
LEFT JOIN olist_silver.orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT 
    r.order_id
FROM olist_silver.order_reviews r 
LEFT JOIN olist_silver.orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Logical Consistency
SELECT 
    order_id
FROM olist_silver.orders
WHERE 
    order_purchase_timestamp > GETDATE()
    OR order_approved_at < order_purchase_timestamp
    OR (order_delivered_customer_date IS NOT NULL
    AND order_delivered_customer_date < order_purchase_timestamp); -- Ensures the chronological order of order processing

-- ===================================================
-- Product Category Name Translation Table Validation
-- ===================================================

-- Null checks on mandatory fields
SELECT *
FROM olist_silver.product_category_name_translation
WHERE 
    product_category_name IS NULL
    OR product_category_name_english IS NULL;

-- Text normalization
SELECT *
FROM olist_silver.product_category_name_translation
WHERE 
    TRIM(product_category_name) != product_category_name
    OR TRIM(product_category_name_english) != product_category_name_english;

-- =====================================
-- Products Table Validation
-- =====================================

-- Duplicate primary key detection
SELECT
    product_id,
    COUNT(*)
FROM olist_silver.products
GROUP BY product_id
HAVING COUNT(*) > 1 OR product_id IS NULL;

-- Null checks on mandatory fields
SELECT 
    product_id
FROM olist_silver.products
WHERE product_id IS NULL;

-- Referential integrity across related tables
SELECT 
    i.product_id 
FROM olist_silver.order_items i
LEFT JOIN olist_silver.products p ON i.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Text normalization
SELECT 
    product_category_name
FROM olist_silver.products
WHERE TRIM(product_category_name) != product_category_name;

-- =====================================
-- Sellers Table Validation
-- =====================================

-- Duplicate primary key detection
SELECT
    seller_id,
    COUNT(*)
FROM olist_silver.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1 OR seller_id IS NULL;

-- Referential integrity across related tables
SELECT 
    i.seller_id
FROM olist_silver.order_items i
LEFT JOIN olist_silver.sellers s ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Text normalization
SELECT 
    seller_city,
    seller_state
FROM olist_silver.sellers
WHERE 
   TRIM(seller_city) != seller_city 
   OR TRIM(seller_state) != seller_state;

-- =====================================
-- Order Items Table Validation
-- =====================================

-- Duplicate primary key detection
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS cnt
FROM olist_silver.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Null checks on mandatory fields
SELECT * 
FROM olist_silver.order_items
WHERE 
    order_id IS NULL
    OR order_item_id IS NULL
    OR product_id IS NULL
    OR seller_id IS NULL
    OR shipping_limit_date IS NULL
    OR price IS NULL
    OR freight_value IS NULL;

-- Logical Consistency
SELECT 
    price,
    freight_value
FROM olist_silver.order_items
WHERE 
    price < 0 
    OR freight_value < 0;

SELECT i.*
FROM olist_silver.order_items i
JOIN olist_silver.orders o ON i.order_id = o.order_id
WHERE i.shipping_limit_date < o.order_purchase_timestamp; -- Ensures shipping limit date is not earlier than purchase date

-- =====================================
-- Order Payments Table Validation
-- =====================================

-- Duplicate primary key detection
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS cnt
FROM olist_silver.order_payments
GROUP BY order_id,payment_sequential
HAVING COUNT(*) > 1;

-- Null checks on mandatory fields
SELECT * 
FROM olist_silver.order_payments
WHERE 
    order_id IS NULL
    OR payment_sequential IS NULL
    OR payment_type IS NULL
    OR payment_installments IS NULL
    OR payment_value IS NULL;

-- Text normalization
SELECT 
    payment_type
FROM olist_silver.order_payments
WHERE TRIM(payment_type) != payment_type;

-- Logical Consistency
SELECT 
    payment_value
FROM olist_silver.order_payments
WHERE 
    payment_value < 0;

-- =====================================
-- Order Reviews Table Validation
-- =====================================

-- Duplicate primary key detection
SELECT
    review_id,
    COUNT(*) AS cnt
FROM olist_silver.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

-- Null checks on mandatory fields
SELECT * 
FROM olist_silver.order_reviews
WHERE 
    review_id IS NULL
    OR order_id IS NULL
    OR review_score IS NULL;
    
-- Text normalization
SELECT 
    review_comment_title, 
    review_comment_message
FROM olist_silver.order_reviews
WHERE TRIM(review_comment_title) != review_comment_title
      OR TRIM(review_comment_message) != review_comment_message;

-- Logical Consistency
SELECT 
    review_score
FROM olist_silver.order_reviews
WHERE 
    review_score < 0
    OR review_score > 5;

PRINT 'Validation Passed: No rows returned which is expected';
