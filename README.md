# Olist Data Warehouse and Analytics Portfolio Project

Welcome to the **Olist Data Warehouse and Analytics portfolio project!**

This end-to-end data warehousing and analytics solution demonstrates how to turn raw e-commerce data into structured, insightful reporting using SQL-based engineering and analytical workflows.

## 🧱 Data Architecture: Medallion Model

This project implements a modern data architecture using the Medallion (Lakehouse) Architecture, composed of three layers:

🔹 **Bronze Layer**

Ingests raw data from Olist-provided CSV files.

Data is stored as-is with no transformations.

Serves as the single source of truth for raw historical data.

🔸 **Silver Layer**

Performs data cleaning, transformation, and standardization.

Joins and enriches datasets (e.g., decoding category names, formatting dates).

Provides clean and transformed data.

⭐ **Gold Layer**

Delivers a Star Schema model with dimension and fact views.

Optimized for business reporting, analytics, and dashboarding.

Includes measures like total sales, total orders, customer spend, delivery time, and review score.

## 📌 Project Objectives

This project covers the full lifecycle of a modern analytics pipeline:

🔧 **Data Engineering**
Design a scalable warehouse using Medallion architecture.

Create ETL pipelines to ingest and transform raw Olist data.

Model star schema using SQL views.

Validate data quality, check nulls, handle outliers, and define business rules.

📊 **Data Analysis & Reporting**
Explore and document the database schema, column types, and relationships.

Analyze key business entities like customers, orders, products, sellers, and payments.

Segment customers (repeat vs new), calculate product performance, and measure delivery quality.

Uncover trends and correlations (e.g., impact of delivery time on review score).

Generate metrics like:

Total sales, total orders, average price

Customer spend patterns

Review distributions and delivery delays

## 🔍 Analytical Focus Areas
Customer Behavior
Repeat purchases, spend, geographic distribution, and segmentation

Product Performance
Top-selling categories, freight cost impacts, average prices

Sales & Operations Trends
Order volume over time, delivery delays, and payment preferences

Quality Metrics
Delivery performance, review scores, and return reasons

🧑‍💻 About Me
Hi there! I’m Kiruthiha — an IT professional with a strong focus on data engineering and analytics.
This project is a demonstration of my skills in transforming raw data into clear, business-ready datasets that drive insights, decision-making, and impact.

Let’s connect and discuss how data can power better business outcomes! 🚀
