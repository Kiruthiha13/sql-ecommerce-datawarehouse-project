# Olist Data Warehouse and Analytics Portfolio Project

Welcome to the **Olist Data Warehouse and Analytics portfolio project!**

This end-to-end data warehousing and analytics solution demonstrates how to turn raw e-commerce data into structured, insightful reporting using SQL-based engineering and analytical workflows.

## 🧱 Data Architecture: Medallion Model

This project implements a modern data architecture using the Medallion (Lakehouse) Architecture, composed of three layers:

🔹 **Bronze Layer**

1. Ingests raw data from Olist-provided CSV files.
2. Data is stored as-is with no transformations.
3. Serves as the single source of truth for raw historical data.

🔸 **Silver Layer**

1. Performs data cleaning, transformation, and standardization.
2. Joins and enriches datasets (e.g., decoding category names, formatting dates).
3. Provides clean and transformed data.

⭐ **Gold Layer**

1. Delivers a Star Schema model with dimension and fact views.
2. Optimized for business reporting, analytics, and dashboarding.

## 📌 Project Objectives

This project covers the full lifecycle of a modern analytics pipeline:

🔧 **Data Engineering**

1. Design a scalable warehouse using Medallion architecture.
2. Create ETL pipelines to ingest and transform raw Olist data.
3. Model star schema using SQL views.
4. Validate data quality, check nulls, handle outliers, and define business rules.

📊 **Data Analysis**

1. Explore and document the database schema, column types, and relationships.
2. Analyze key business entities like customers, orders, products, sellers, and payments.
   
## 🔍 Analytical Focus Areas

1. Customer Behavior: Repeat purchases, spend, geographic distribution, and segmentation
2. Product Performance: Top-selling categories, freight cost impacts, average prices
3. Sales & Operations Trends: Order volume over time, delivery delays, and payment preferences
4. Quality Metrics: Delivery performance, review scores, and return reasons

🧑‍💻 About Me

Hi there! I'm Kiruthiha. I’m an IT professional working extensively with data to drive insights, support decision-making, and improve business outcomes. I’m passionate about turning raw data into meaningful stories through analysis and visualization.

Let’s connect and discuss how data can power better business outcomes! 🚀
