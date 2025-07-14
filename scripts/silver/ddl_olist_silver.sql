/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================

Script Purpose:
    This script creates all tables in the 'olist_silver' schema.
    It identifies and drops all foreign key constraints from tables
    within the 'olist_silver' schema. It uses dynamic SQL to generate and
    execute ALTER TABLE statements for each constraint found.

Usage:
    Run this script before performing operations that require foreign key
    constraints to be dropped in the Silver layer. Be aware that dropping
    foreign keys removes referential integrity enforcement between tables
    until constraints are recreated.

    IMPORTANT:
        - Always back up existing constraints or generate scripts to recreate
          them after dropping.
        - Dynamic SQL is used in this script to automate the generation of
          ALTER TABLE statements based on system metadata.

================================================================================
*/

USE olist_datawarehouse;
GO

PRINT '===============================';
PRINT 'STEP 1 - Drop Foreign Keys';
PRINT '===============================';

DECLARE @DropFKS NVARCHAR(MAX) = N'';

SELECT @DropFKS += N'
ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + fk.name + '];'
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'olist_silver';

IF LEN(@DropFKS) > 0
BEGIN
    EXEC sp_executesql @DropFKS;
    PRINT 'Foreign keys dropped.';
END
ELSE
    PRINT 'No foreign keys found.';
GO

PRINT '===============================';
PRINT 'STEP 2 - Drop Tables';
PRINT '===============================';

DECLARE @DropTables NVARCHAR(MAX) = N'';

SELECT @DropTables += '
IF OBJECT_ID(''' + s.name + '.' + t.name + ''', ''U'') IS NOT NULL
    DROP TABLE [' + s.name + '].[' + t.name + '];'
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'olist_silver';

IF LEN(@DropTables) > 0
BEGIN
    EXEC sp_executesql @DropTables;
    PRINT 'Tables dropped.';
END
ELSE
    PRINT 'No tables found.';
GO

PRINT '===============================';
PRINT 'STEP 3 - Recreate Tables';
PRINT '===============================';

CREATE TABLE olist_silver.customers (
    customer_id NVARCHAR(50) NOT NULL,
    customer_unique_id NVARCHAR(50) NOT NULL,
    customer_zip_code_prefix NVARCHAR(10) NOT NULL,
    customer_city NVARCHAR(50) NOT NULL,
    customer_state NVARCHAR(10) NOT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_customers PRIMARY KEY(customer_id)
);
GO

CREATE TABLE olist_silver.geolocation (
    geolocation_zip_code_prefix NVARCHAR(10) NOT NULL,
    geolocation_lat DECIMAL(9,6) NOT NULL,
    geolocation_lng DECIMAL(9,6) NOT NULL,
    geolocation_city NVARCHAR(50) NOT NULL,
    geolocation_state NVARCHAR(10) NOT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

CREATE TABLE olist_silver.orders (
    order_id NVARCHAR(50) NOT NULL,
    customer_id NVARCHAR(50) NOT NULL,
    order_status NVARCHAR(25) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NOT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_orders PRIMARY KEY(order_id)
);
GO

CREATE TABLE olist_silver.product_category_name_translation (
    product_category_name NVARCHAR(100) NOT NULL,
    product_category_name_english NVARCHAR(100) NOT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_product_category_name_translation PRIMARY KEY(product_category_name)
);
GO

CREATE TABLE olist_silver.products (
    product_id NVARCHAR(50) NOT NULL,
    product_category_name NVARCHAR(100) NULL,
    product_name_length INT NULL,
    product_description_length INT NULL,
    product_photos_qty INT NULL,
    product_weight_g INT NULL,
    product_length_cm INT NULL,
    product_height_cm INT NULL,
    product_width_cm INT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_products PRIMARY KEY(product_id)
);
GO

CREATE TABLE olist_silver.sellers (
    seller_id NVARCHAR(50) NOT NULL,
    seller_zip_code_prefix NVARCHAR(10) NOT NULL,
    seller_city NVARCHAR(100) NOT NULL,
    seller_state NVARCHAR(10) NOT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_sellers PRIMARY KEY(seller_id)
);
GO

CREATE TABLE olist_silver.order_items (
    order_id NVARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id NVARCHAR(50) NOT NULL,
    seller_id NVARCHAR(50) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    freight_value DECIMAL(10,2) NOT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_order_items PRIMARY KEY(order_id, order_item_id),
    CONSTRAINT CK_order_items_price_non_negative CHECK (price >= 0),
    CONSTRAINT CK_order_items_freight_non_negative CHECK (freight_value >= 0)
);
GO

CREATE TABLE olist_silver.order_payments (
    order_id NVARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type NVARCHAR(50) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10,2) NOT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_order_payments PRIMARY KEY(order_id, payment_sequential),
    CONSTRAINT CK_payment_value_non_negative CHECK (payment_value >= 0)
);
GO

CREATE TABLE olist_silver.order_reviews (
    review_id NVARCHAR(50) NOT NULL,
    order_id NVARCHAR(50) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title NVARCHAR(255) NULL,
    review_comment_message NVARCHAR(1000) NULL,
    review_creation_date DATETIME NOT NULL,
    review_answer_timestamp DATETIME NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_order_reviews PRIMARY KEY(review_id),
    CONSTRAINT CK_review_score_range CHECK (review_score BETWEEN 1 AND 5)
);
GO

PRINT '===============================';
PRINT 'STEP 4 - Recreate Foreign Keys';
PRINT '===============================';

ALTER TABLE olist_silver.orders
    ADD CONSTRAINT FK_orders_customers
    FOREIGN KEY(customer_id)
    REFERENCES olist_silver.customers(customer_id);
GO

ALTER TABLE olist_silver.products
    ADD CONSTRAINT FK_products_name_translation
    FOREIGN KEY(product_category_name)
    REFERENCES olist_silver.product_category_name_translation(product_category_name);
GO

ALTER TABLE olist_silver.order_items
    ADD CONSTRAINT FK_order_items_orders
    FOREIGN KEY(order_id)
    REFERENCES olist_silver.orders(order_id);
GO

ALTER TABLE olist_silver.order_items
    ADD CONSTRAINT FK_order_items_products
    FOREIGN KEY(product_id)
    REFERENCES olist_silver.products(product_id);
GO

ALTER TABLE olist_silver.order_items
    ADD CONSTRAINT FK_order_items_sellers
    FOREIGN KEY(seller_id)
    REFERENCES olist_silver.sellers(seller_id);
GO

ALTER TABLE olist_silver.order_payments
    ADD CONSTRAINT FK_order_payments_orders
    FOREIGN KEY(order_id)
    REFERENCES olist_silver.orders(order_id);
GO

ALTER TABLE olist_silver.order_reviews
    ADD CONSTRAINT FK_order_reviews_orders
    FOREIGN KEY(order_id)
    REFERENCES olist_silver.orders(order_id);
GO

PRINT 'All tables and constraints successfully recreated!';
