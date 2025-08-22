# Olist Data Warehouse and Analytics Portfolio Project

Welcome to the **Olist Data Warehouse and Analytics portfolio project!**

This end-to-end data warehousing and analytics solution demonstrates how to turn raw e-commerce data into structured, insightful reporting using SQL-based engineering and analytical workflows.

## ℹ️ Dataset Information

🔗 **Source:** [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

**Modifications:**
1. Original dataset dates were shifted to recent years to maintain recency for analysis purposes.
2. No other structural or value modifications were made except for date adjustments.
3. All business insights and metrics are still consistent with the original data.

**Note:** This dataset is used for educational and analytical purposes only. Please refer to the original Kaggle license for usage rights.

## 🧱 Data Architecture: Medallion Model

This project implements a modern data architecture using the Medallion Architecture, composed of three layers:

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

1. Customer behavior & experience analysis
2. Sales analysis
3. Revenue analysis
4. Product performance analysis

## 📈 Revenue Dashboard (Tableau)

The Revenue Dashboard provides a comprehensive view of sales performance and profitability across years, product categories, and key financial metrics, enabling decision-makers to identify growth opportunities and track revenue contribution trends.

[Olist Revenue Dashboard](https://public.tableau.com/app/profile/kiruthiha.s/viz/OlistRevenueDashboard_17548006795020/RevenueDashboard)

🧑‍💻 About Me

Hi there! I'm Kiruthiha. I’m an IT professional working extensively with data to drive insights, support decision-making, and improve business outcomes. I’m passionate about turning raw data into meaningful stories through analysis and visualization.

Let’s connect and discuss how data can power better business outcomes! 🚀
