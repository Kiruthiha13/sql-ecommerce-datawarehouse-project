/*
===============================================================================
Database Exploration - Gold Layer
===============================================================================
Purpose:
    - Explore the database schema by listing all tables and views.
    - Inspect column metadata for each Gold layer view.

Tables Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

USE olist_datawarehouse;
GO

-- =============================================================================
-- Step 1: List all tables and views in the database
-- =============================================================================
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'olist_gold';  -- filters to only Gold layer views

-- =============================================================================
-- Step 2: Explore column metadata for each view in Gold layer
-- =============================================================================
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'dim_customers' 
    OR TABLE_NAME = 'dim_orders'
    OR TABLE_NAME = 'dim_payments'
    OR TABLE_NAME = 'dim_products'
    OR TABLE_NAME = 'dim_reviews'
    OR TABLE_NAME = 'dim_sellers'
    OR TABLE_NAME = 'fact_order_items';
