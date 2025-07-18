/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Deletes Silver tables if it already exists.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC olist_silver.load_olist_silver;
===============================================================================
*/

USE olist_datawarehouse;
GO

CREATE OR ALTER PROCEDURE olist_silver.load_olist_silver AS
BEGIN
	DECLARE 
	@start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME,
	@global_anchor_date DATE = '2020-04-09', @reference_date DATE = '2025-07-15';
	DECLARE @global_shift_days INT = DATEDIFF(DAY, @global_anchor_date, @reference_date);
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
    		PRINT 'Loading Silver Layer';
    		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading Customers Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.customers
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.customers';
		DELETE FROM olist_silver.customers;
		PRINT '>> Inserting Data Into: olist_silver.customers';
		INSERT INTO olist_silver.customers (
			customer_id,
			customer_unique_id,
			customer_zip_code_prefix,
			customer_city,
			customer_state
		)
		SELECT
			customer_id,
			customer_unique_id,
			customer_zip_code_prefix,
			-- Normalizing customer city and state
			UPPER(TRIM(customer_city)) AS customer_city, 
			UPPER(TRIM(customer_state)) AS customer_state
		FROM olist_bronze.customers
		WHERE 
			customer_id IS NOT NULL
			AND customer_unique_id IS NOT NULL
			AND customer_zip_code_prefix IS NOT NULL
			AND customer_city IS NOT NULL
			AND customer_state IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading Geolocation Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.geolocation
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.geolocation';
		DELETE FROM olist_silver.geolocation;
		PRINT '>> Inserting Data Into: olist_silver.geolocation';
		INSERT INTO olist_silver.geolocation (
			geolocation_zip_code_prefix,
			geolocation_lat,
			geolocation_lng,
			geolocation_city,
			geolocation_state
		)
		SELECT
			geolocation_zip_code_prefix,
			geolocation_lat,
			geolocation_lng,
			-- Normalizing geolocation city and state
			UPPER(TRIM(geolocation_city)) AS geolocation_city, 
			UPPER(TRIM(geolocation_state)) AS geolocation_state
		FROM olist_bronze.geolocation
		WHERE 
			geolocation_lat BETWEEN -90 AND 90
			AND geolocation_lng BETWEEN -180 AND 180 
			AND geolocation_zip_code_prefix IS NOT NULL
			AND geolocation_lat IS NOT NULL
			AND geolocation_lng IS NOT NULL
			AND geolocation_city IS NOT NULL
			AND geolocation_state IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading Orders Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.orders
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.orders';
		DELETE FROM olist_silver.orders;
		PRINT '>> Inserting Data Into: olist_silver.orders';

		-- Calculate shift for order dates to reflect recent dates
		
		WITH filtered_orders AS (
			SELECT
				o.*
			FROM olist_bronze.orders o
			INNER JOIN olist_bronze.customers c
				ON o.customer_id = c.customer_id
			WHERE
				o.order_id IS NOT NULL
				AND o.customer_id IS NOT NULL
				AND o.order_status IS NOT NULL
				AND o.order_purchase_timestamp IS NOT NULL
				AND o.order_estimated_delivery_date IS NOT NULL
		)
		INSERT INTO olist_silver.orders (
			order_id,
			customer_id,
			order_status,
			order_purchase_timestamp,
			order_approved_at,
			order_delivered_carrier_date,
			order_delivered_customer_date,
			order_estimated_delivery_date,
			issue_type
		)
		SELECT
			order_id,
			customer_id,
			UPPER(TRIM(order_status)) AS order_status, -- Normalizing order_status
			DATEADD(DAY, @global_shift_days, order_purchase_timestamp) AS order_purchase_timestamp,
			CASE
				WHEN order_approved_at IS NULL THEN NULL
				ELSE DATEADD(DAY, @global_shift_days, order_approved_at)
			END AS order_approved_at,
			CASE
				WHEN order_delivered_carrier_date IS NULL THEN NULL
				ELSE DATEADD(DAY, @global_shift_days, order_delivered_carrier_date)
			END AS order_delivered_carrier_date,
			CASE
				WHEN order_delivered_customer_date IS NULL THEN NULL
				ELSE DATEADD(DAY, @global_shift_days, order_delivered_customer_date)
			END AS order_delivered_customer_date,
			DATEADD(DAY, @global_shift_days, order_estimated_delivery_date) AS order_estimated_delivery_date,

			CASE 
			  	-- carrier before approval
			  	WHEN order_delivered_carrier_date IS NOT NULL AND order_approved_at IS NOT NULL 
				   AND order_delivered_carrier_date < order_approved_at 
				   THEN 'carrier_before_approval'
	
			  	-- customer before carrier
			  	WHEN order_delivered_customer_date IS NOT NULL AND order_delivered_carrier_date IS NOT NULL 
				   AND order_delivered_customer_date < order_delivered_carrier_date 
				   THEN 'customer_before_carrier'
	
			  	-- delivered after estimated
			  	WHEN order_delivered_customer_date IS NOT NULL 
				   AND order_delivered_customer_date > order_estimated_delivery_date 
				   THEN 'delivered_after_estimate'
	
			  	-- 5. Approved/shipped/delivered orders must have order_approved_at
			  	WHEN order_status IN ('APPROVED', 'SHIPPED', 'DELIVERED') 
				   AND order_approved_at IS NULL 
				   THEN 'missing_approval'
	
			  	-- Non-delivered orders should not have delivered status
			  	WHEN order_status = 'DELIVERED' 
				   AND order_delivered_customer_date IS NULL 
				   THEN 'invalid_delivery_status'
	
			  	-- General NULL check for important date fields
			  	WHEN order_approved_at IS NULL 
				   OR order_delivered_carrier_date IS NULL 
				   OR order_delivered_customer_date IS NULL 
				   THEN 'not_delivered'
				-- Else it's clean
			  	ELSE 'valid'
			END AS issue_type
		FROM filtered_orders;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading Product_Category_Name_Translation Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.product_category_name_translation
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.product_category_name_translation';
		DELETE FROM olist_silver.product_category_name_translation;
		PRINT '>> Inserting Data Into: olist_silver.product_category_name_translation';
		INSERT INTO olist_silver.product_category_name_translation (
			product_category_name,
			product_category_name_english
		)
		SELECT 
			-- Normalizing category names
			TRIM(product_category_name) as product_category_name ,
			TRIM(product_category_name_english) as product_category_name_english
		FROM olist_bronze.product_category_name_translation
		WHERE 
			product_category_name IS NOT NULL
			AND product_category_name_english IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading Products Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.products
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.products';
		DELETE FROM olist_silver.products;
		PRINT '>> Inserting Data Into: olist_silver.products';
		INSERT INTO olist_silver.products (
			product_id,
			product_category_name,
			product_name_length,
			product_description_length,
			product_photos_qty,
			product_weight_g,
			product_length_cm,
			product_height_cm,
			product_width_cm
		)
		SELECT
			product_id,
			product_category_name,
      		-- Replacing blank values with 0
			ISNULL(product_name_lenght, 0) AS product_name_length,
			ISNULL(product_description_lenght, 0) AS product_description_length,
			ISNULL(product_photos_qty, 0) AS product_photos_qty,
			product_weight_g,
			product_length_cm,
			product_height_cm,
			product_width_cm
		FROM olist_bronze.products
		WHERE
			product_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading Sellers Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.sellers
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.sellers';
		DELETE FROM olist_silver.sellers;
		PRINT '>> Inserting Data Into: olist_silver.sellers';
		INSERT INTO olist_silver.sellers (
			seller_id,
			seller_zip_code_prefix,
			seller_city,
			seller_state
		)
		SELECT
			seller_id,
			seller_zip_code_prefix,
			-- Normalizing seller city and state
			UPPER(TRIM(seller_city)) AS seller_city,
			UPPER(TRIM(seller_state)) AS seller_state
		FROM olist_bronze.sellers
		WHERE
			seller_id IS NOT NULL
			AND seller_zip_code_prefix IS NOT NULL
			AND seller_city IS NOT NULL
			AND seller_state IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading Order Items Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.order_items
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.order_items';
		DELETE FROM olist_silver.order_items;
		PRINT '>> Inserting Data Into: olist_silver.order_items';
		-- Calculate shift for shipping_limit_date to reflect recent dates
		
		INSERT INTO olist_silver.order_items (
			order_id,
			order_item_id,
			product_id,
			seller_id,
			shipping_limit_date,
			price,
			freight_value
		)
		SELECT
			order_id,
			order_item_id,
			product_id,
			seller_id,
			DATEADD(DAY, @global_shift_days, shipping_limit_date) AS shipping_limit_date,
			price,
			freight_value
		FROM olist_bronze.order_items
		WHERE
			price >= 0 
			AND freight_value >= 0
			AND order_id IS NOT NULL
			AND order_item_id IS NOT NULL
			AND product_id IS NOT NULL
			AND seller_id IS NOT NULL
			AND shipping_limit_date IS NOT NULL
			AND price IS NOT NULL
			AND freight_value IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading Order Payments Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.order_payments
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.order_payments';
		DELETE FROM olist_silver.order_payments;
		PRINT '>> Inserting Data Into: olist_silver.order_payments';
		INSERT INTO olist_silver.order_payments (
			order_id,
			payment_sequential,
			payment_type,
			payment_installments,
			payment_value
		)
		SELECT
			order_id,
			payment_sequential,
			UPPER(
				TRIM(
					CASE
						WHEN payment_type = 'boleto' THEN 'bank_slip'
						ELSE payment_type
					END
					)
				 ) AS payment_type, -- Translating payment type and Normalizing
			payment_installments,
			payment_value
		FROM olist_bronze.order_payments
		WHERE
			payment_value >= 0
			AND order_id IS NOT NULL
			AND payment_sequential IS NOT NULL
			AND payment_type IS NOT NULL
			AND payment_installments IS NOT NULL
			AND payment_value IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading Order_Reviews Table';
		PRINT '------------------------------------------------';

		-- Loading olist_silver.order_reviews
		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: olist_silver.order_reviews';
		DELETE FROM olist_silver.order_reviews;
		PRINT '>> Inserting Data Into: olist_silver.order_reviews';
		
		-- Calculate shift for review dates to reflect recent dates
	
		INSERT INTO olist_silver.order_reviews (
			review_id,
			order_id,
			review_score,
			review_comment_title,
			review_comment_message,
			review_creation_date,
			review_answer_timestamp
		)
		SELECT
			review_id,
			order_id,
			review_score,
			-- Replace empty review titles or messages with default text 
			ISNULL(NULLIF(TRIM(review_comment_title), ''), 'No comments'),
			ISNULL(NULLIF(TRIM(review_comment_message), ''), 'No messages'),
			DATEADD(DAY, @global_shift_days, review_creation_date) AS review_creation_date,
			CASE
				WHEN review_answer_timestamp IS NOT NULL THEN
					DATEADD(DAY, @global_shift_days, review_answer_timestamp)
				ELSE NULL
			END AS review_answer_timestamp
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (
					PARTITION BY review_id
					ORDER BY order_id
				) AS rn -- Removing duplicates in review_id
			FROM olist_bronze.order_reviews
		) ranked_reviews
		WHERE
			rn = 1
			AND review_id IS NOT NULL
			AND order_id IS NOT NULL
			AND review_score IS NOT NULL
			AND review_creation_date IS NOT NULL;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
    PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
