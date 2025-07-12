/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from CSV files to bronze tables.

Parameters: 
	  None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC olist_bronze.load_olist_bronze;
===============================================================================
*/
USE olist_datawarehouse;
GO

CREATE OR ALTER PROCEDURE olist_bronze.load_olist_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '=============================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=============================================';

        PRINT '=============================================';
        PRINT 'Loading Customers Table';
        PRINT '=============================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.customers';
        TRUNCATE TABLE olist_bronze.customers;

        PRINT '>> Inserting Data into: olist_bronze.customers';
        BULK INSERT olist_bronze.customers
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\customers.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        PRINT '=============================================';
        PRINT 'Loading Geolocation Table';
        PRINT '=============================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.geolocation';
        TRUNCATE TABLE olist_bronze.geolocation;

        PRINT '>> Inserting Data into: olist_bronze.geolocation';
        BULK INSERT olist_bronze.geolocation
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\geolocation.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        PRINT '=============================================';
        PRINT 'Loading Order Items Table';
        PRINT '=============================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.order_items';
        TRUNCATE TABLE olist_bronze.order_items;

        PRINT '>> Inserting Data into: olist_bronze.order_items';
        BULK INSERT olist_bronze.order_items
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\order_items.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        PRINT '=============================================';
        PRINT 'Loading Order Payments Table';
        PRINT '=============================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.order_payments';
        TRUNCATE TABLE olist_bronze.order_payments;

        PRINT '>> Inserting Data into: olist_bronze.order_payments';
        BULK INSERT olist_bronze.order_payments
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\order_payments.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        PRINT '=============================================';
        PRINT 'Loading Order Reviews Table';
        PRINT '=============================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.order_reviews';
        TRUNCATE TABLE olist_bronze.order_reviews;

        PRINT '>> Inserting Data into: olist_bronze.order_reviews';
        BULK INSERT olist_bronze.order_reviews
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\order_reviews.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        PRINT '=============================================';
        PRINT 'Loading Orders Table';
        PRINT '=============================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.orders';
        TRUNCATE TABLE olist_bronze.orders;

        PRINT '>> Inserting Data into: olist_bronze.orders';
        BULK INSERT olist_bronze.orders
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\orders.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        PRINT '=============================================';
        PRINT 'Loading Products Table';
        PRINT '=============================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.products';
        TRUNCATE TABLE olist_bronze.products;

        PRINT '>> Inserting Data into: olist_bronze.products';
        BULK INSERT olist_bronze.products
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\products.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        PRINT '=============================================';
        PRINT 'Loading Sellers Table';
        PRINT '=============================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.sellers';
        TRUNCATE TABLE olist_bronze.sellers;

        PRINT '>> Inserting Data into: olist_bronze.sellers';
        BULK INSERT olist_bronze.sellers
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\sellers.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        PRINT '=================================================';
        PRINT 'Loading Product Category Name Translation Table';
        PRINT '=================================================';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: olist_bronze.product_category_name_translation';
        TRUNCATE TABLE olist_bronze.product_category_name_translation;

        PRINT '>> Inserting Data into: olist_bronze.product_category_name_translation';
        BULK INSERT olist_bronze.product_category_name_translation
        FROM 'C:\olist_dwh_project\olist_ecommerce\datasets\product_category_name_translation.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------';

        SET @batch_end_time = GETDATE();
        PRINT '===============================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '===============================================';
        PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'Error Occurred in Loading Bronze Layer';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
        THROW;
    END CATCH
END
