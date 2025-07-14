/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================

Script Purpose:
    This script creates all tables in the 'olist_silver' schema, dropping
    existing tables if they already exist.

    The following Constraints are applied:
        - Primary Key constraints to uniquely identify rows.
        - Foreign Key constraints to ensure referential integrity between
          related tables.
        - CHECK constraints to enforce domain-specific business rules
          (e.g. valid ranges of numeric values).
        - NOT NULL constraints where data is mandatory.
        - Named constraints for easier maintenance and clarity.

Usage:
    Run this script whenever you need to rebuild the Silver schema structure.
    Be aware that running it will drop existing tables and recreate them,
    removing any existing data.
================================================================================
*/


USE olist_datawarehouse;
GO

IF OBJECT_ID('olist_silver.customers', 'U') IS NOT NULL
    DROP TABLE olist_silver.customers;
GO

CREATE TABLE olist_silver.customers (
		customer_id NVARCHAR(50) NOT NULL,
		customer_unique_id NVARCHAR(50) NOT NULL,
		customer_zip_code_prefix NVARCHAR(10) NOT NULL,
		customer_city NVARCHAR(50) NOT NULL,
		customer_state NVARCHAR(10) NOT NULL,

		CONSTRAINT PK_customers PRIMARY KEY(customer_id)
);
GO

IF OBJECT_ID('olist_silver.geolocation', 'U') IS NOT NULL
	DROP TABLE olist_silver.geolocation;
GO

CREATE TABLE olist_silver.geolocation (
		geolocation_zip_code_prefix NVARCHAR(10) NOT NULL,
		geolocation_lat DECIMAL(9,6) NOT NULL,
		geolocation_lng DECIMAL(9,6) NOT NULL,
		geolocation_city NVARCHAR(50) NOT NULL,
		geolocation_state NVARCHAR(10) NOT NULL
);
GO

IF OBJECT_ID('olist_silver.orders', 'U') IS NOT NULL
	DROP TABLE olist_silver.orders;
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

		CONSTRAINT PK_orders PRIMARY KEY(order_id),

		CONSTRAINT FK_orders_customers
			FOREIGN KEY(customer_id)
			REFERENCES olist_silver.customers(customer_id)
);
GO

IF OBJECT_ID('olist_silver.product_category_name_translation', 'U') IS NOT NULL
	DROP TABLE olist_silver.product_category_name_translation;
GO

CREATE TABLE olist_silver.product_category_name_translation (
		product_category_name NVARCHAR(100) NOT NULL,
		product_category_name_english NVARCHAR(100) NOT NULL,

		CONSTRAINT PK_product_category_name_translation PRIMARY KEY(product_category_name)
);
GO

IF OBJECT_ID('olist_silver.products', 'U') IS NOT NULL
	DROP TABLE olist_silver.products;
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

		CONSTRAINT PK_products PRIMARY KEY(product_id),

		CONSTRAINT FK_products_name_translation
			FOREIGN KEY(product_category_name)
			REFERENCES olist_silver.product_category_name_translation(product_category_name)
);
GO

IF OBJECT_ID('olist_silver.sellers', 'U') IS NOT NULL
	DROP TABLE olist_silver.sellers;
GO

CREATE TABLE olist_silver.sellers (
		seller_id NVARCHAR(50) NOT NULL,
		seller_zip_code_prefix NVARCHAR(10) NOT NULL,
		seller_city NVARCHAR(100) NOT NULL,
		seller_state NVARCHAR(10) NOT NULL,

		CONSTRAINT PK_sellers PRIMARY KEY(seller_id)
);
GO

IF OBJECT_ID('olist_silver.order_items', 'U') IS NOT NULL
	DROP TABLE olist_silver.order_items;
GO

CREATE TABLE olist_silver.order_items (
		order_id NVARCHAR(50) NOT NULL,
		order_item_id INT NOT NULL,
		product_id NVARCHAR(50) NOT NULL,
		seller_id NVARCHAR(50) NOT NULL,
		shipping_limit_date DATETIME NOT NULL,
		price DECIMAL(10,2) NOT NULL,
		freight_value DECIMAL(10,2) NOT NULL,

		CONSTRAINT PK_order_items PRIMARY KEY(order_id, order_item_id),

		CONSTRAINT FK_order_items_orders
			FOREIGN KEY(order_id)
			REFERENCES olist_silver.orders(order_id),

		CONSTRAINT FK_order_items_products
			FOREIGN KEY(product_id)
			REFERENCES olist_silver.products(product_id),

		CONSTRAINT FK_order_items_sellers
			FOREIGN KEY(seller_id)
			REFERENCES olist_silver.sellers(seller_id),

		CONSTRAINT CK_order_items_price_non_negative CHECK (price >= 0),

		CONSTRAINT CK_order_items_freight_non_negative CHECK (freight_value >= 0)
);
GO

IF OBJECT_ID('olist_silver.order_payments', 'U') IS NOT NULL
	DROP TABLE olist_silver.order_payments;
GO

CREATE TABLE olist_silver.order_payments (
		order_id NVARCHAR(50) NOT NULL,
		payment_sequential INT NOT NULL,
		payment_type NVARCHAR(50) NOT NULL,
		payment_installments INT NOT NULL,
		payment_value DECIMAL(10,2) NOT NULL,

		CONSTRAINT PK_order_payments PRIMARY KEY(order_id, payment_sequential),

		CONSTRAINT FK_order_payments_orders
			FOREIGN KEY(order_id)
			REFERENCES olist_silver.orders(order_id),

		CONSTRAINT CK_payment_value_non_negative CHECK (payment_value >= 0)
);
GO

IF OBJECT_ID('olist_silver.order_reviews', 'U') IS NOT NULL
	DROP TABLE olist_silver.order_reviews;
GO

CREATE TABLE olist_silver.order_reviews (
		review_id NVARCHAR(50) NOT NULL,
		order_id NVARCHAR(50) NOT NULL,
		review_score INT NOT NULL,
		review_comment_title NVARCHAR(255) NULL,
		review_comment_message NVARCHAR(1000) NULL,
		review_creation_date DATETIME NOT NULL,
		review_answer_timestamp DATETIME NULL,

		CONSTRAINT PK_order_reviews PRIMARY KEY(review_id),

		CONSTRAINT FK_order_reviews_orders
			FOREIGN KEY(order_id)
			REFERENCES olist_silver.orders(order_id),

		CONSTRAINT CK_review_score_range CHECK (review_score BETWEEN 1 AND 5)
);
GO
