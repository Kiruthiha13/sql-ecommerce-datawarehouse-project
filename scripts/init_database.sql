/*
=======================================================
Create Database and Schemas
=======================================================
Script Purpose:
	The script checks for the existence of a database named 'olist_datawarehouse' and recreates it if it already exists. 
	It then sets up three schemas within the database: 'bronze', 'silver', and 'gold'.
Warning:
	When executed, the script drops the 'olist_datawarehouse' database if it exists, permanently deleting all its contents.
	Proceed only after verifying that reliable backups are available.
*/

USE master;
GO

-- Drop and recreate the database 'olist_datawarehouse'

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'olist_datawarehouse')
BEGIN 
	ALTER DATABASE olist_datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE olist_datawarehouse;
END;
GO


-- Create Database 'olist_datawarehouse'

CREATE DATABASE olist_datawarehouse;
GO

USE olist_datawarehouse;
GO

-- Create Schemas

CREATE SCHEMA olist_bronze;
GO
CREATE SCHEMA olist_silver;
GO
CREATE SCHEMA olist_gold;
GO
