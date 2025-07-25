/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
  This script defines the tables within the 'bronze' schema, 
	dropping any existing ones if they are already present.
	Execute this script to reset the DDL structure of the 'bronze' tables.
===============================================================================
*/
USE olist_datawarehouse;
GO

IF OBJECT_ID('olist_bronze.customers', 'U') IS NOT NULL
    DROP TABLE olist_bronze.customers;
GO

CREATE TABLE olist_bronze.customers (
		customer_id NVARCHAR(50),
		customer_unique_id NVARCHAR(50),
		customer_zip_code_prefix NVARCHAR(100),
		customer_city NVARCHAR(100),
		customer_state NVARCHAR(10)
);
GO

IF OBJECT_ID('olist_bronze.geolocation', 'U') IS NOT NULL
	DROP TABLE olist_bronze.geolocation;
GO

CREATE TABLE olist_bronze.geolocation (
		geolocation_zip_code_prefix NVARCHAR(100),
		geolocation_lat DECIMAL(9,6),
		geolocation_lng DECIMAL(9,6),
		geolocation_city NVARCHAR(100),
		geolocation_state NVARCHAR(10)
);
GO

IF OBJECT_ID('olist_bronze.order_items', 'U') IS NOT NULL
	DROP TABLE olist_bronze.order_items;
GO

CREATE TABLE olist_bronze.order_items (
		order_id NVARCHAR(50),
		order_item_id INT,
		product_id NVARCHAR(50),
		seller_id NVARCHAR(50),
		shipping_limit_date DATETIME,
		price DECIMAL(10,2),
		freight_value DECIMAL(10,2)
);
GO

IF OBJECT_ID('olist_bronze.order_payments', 'U') IS NOT NULL
	DROP TABLE olist_bronze.order_payments;
GO

CREATE TABLE olist_bronze.order_payments (
		order_id NVARCHAR(50),
		payment_sequential INT,
		payment_type NVARCHAR(50),
		payment_installments INT,
		payment_value DECIMAL(10,2)
);
GO

IF OBJECT_ID('olist_bronze.order_reviews', 'U') IS NOT NULL
	DROP TABLE olist_bronze.order_reviews;
GO

CREATE TABLE olist_bronze.order_reviews (
		review_id NVARCHAR(50),
		order_id NVARCHAR(50),
		review_score INT,
		review_comment_title NVARCHAR(255),
		review_comment_message NVARCHAR(2000),
		review_creation_date DATETIME,
		review_answer_timestamp DATETIME
);
GO

IF OBJECT_ID('olist_bronze.orders', 'U') IS NOT NULL
	DROP TABLE olist_bronze.orders;
GO

CREATE TABLE olist_bronze.orders (
		order_id NVARCHAR(50),
		customer_id NVARCHAR(50),
		order_status NVARCHAR(50),
		order_purchase_timestamp DATETIME,
		order_approved_at DATETIME,
		order_delivered_carrier_date DATETIME,
		order_delivered_customer_date DATETIME,
		order_estimated_delivery_date DATETIME
);
GO

IF OBJECT_ID('olist_bronze.products', 'U') IS NOT NULL
	DROP TABLE olist_bronze.products;
GO

CREATE TABLE olist_bronze.products (
		product_id NVARCHAR(50),
		product_category_name NVARCHAR(100),
		product_name_lenght INT,
		product_description_lenght INT,
		product_photos_qty INT,
		product_weight_g INT,
		product_length_cm INT,
		product_height_cm INT,
		product_width_cm INT
);
GO

IF OBJECT_ID('olist_bronze.sellers', 'U') IS NOT NULL
	DROP TABLE olist_bronze.sellers;
GO

CREATE TABLE olist_bronze.sellers (
		seller_id NVARCHAR(50),
		seller_zip_code_prefix NVARCHAR(100),
		seller_city NVARCHAR(100),
		seller_state NVARCHAR(10)
);
GO

IF OBJECT_ID('olist_bronze.product_category_name_translation', 'U') IS NOT NULL
	DROP TABLE olist_bronze.product_category_name_translation;
GO

CREATE TABLE olist_bronze.product_category_name_translation (
		product_category_name NVARCHAR(100),
		product_category_name_english NVARCHAR(100)
);
GO
