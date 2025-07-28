# Data Catalog for Gold Layer

## Overview
The Gold Layer represents the business-ready analytical data model, structured using a star schema for performance, clarity, and reporting. It includes **dimension views** (for descriptive attributes) and **fact views** (for measurable events).

---

### 1. **olist_gold.dim_customers**
- **Purpose:** Stores customer-level data with geographic identifiers.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_sk     | INT           | Surrogate key for the customer dimension.               |
| customer_id      | NVARCHAR(50)  | Raw source system identifier for each customer.                                       |
| customer_unique_id | NVARCHAR(50) | Global unique ID representing the individual customer across orders.         |
| customer_zip_code_prefix | NVARCHAR(10) | Partial postal code used for geographic analysis.                                         |
| customer_city    | NVARCHAR(50)  | City where the customer resides.                                                     |
| customer_state          | NVARCHAR(10)  | State/region of the customer's address.                               |

---

### 2. **olist_gold.dim_products**
- **Purpose:** Describes product specifications and associated categories.
- **Columns:**

| Column Name         | Data Type     | Description                                                                                   |
|---------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_sk        | INT           | Surrogate key for the product dimension.        |
| product_id          | NVARCHAR(50)           | Unique product ID from the source system.            |
| product_category_name | NVARCHAR(100)  | Product category in English (with translations applied). |
| product_weight       | INT  | Weight of the product in grams. |

---

### 3. **olist_gold.dim_sellers**
- **Purpose:** Contains seller location and identifier data.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| seller_sk   | INT  | 	Surrogate key for the seller dimension.                      |
| seller_id   | NVARCHAR(50)          | Original seller ID from the transactional system.                               |
| seller_zip_code_prefix    | NVARCHAR(10)          | Postal code prefix of the seller's location.                              |
| seller_city      | NVARCHAR(50)          | City where the seller operates from.                                                          |
| seller_state   | NVARCHAR(50)          | State or region where the seller is located.                                          |

---

### 3. **olist_gold.dim_dates**
- **Purpose:** Provides a reusable calendar dimension for time-based analysis.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| date_sk   | INT  | 	Surrogate key representing a calendar date.                      |
| calendar_date   | DATE          | Full calendar date (YYYY-MM-DD).                               |
| year    | INT          | Calendar year of the date.                              |
| month      | INT          | Numeric month of the date (1–12).                                                          |
| day   | INT         | Day of the month (1–31).                                          |
| weekday_name | NVARCHAR(50) | Day name (e.g., Monday, Tuesday). |

---

### 3. **olist_gold.fact_order_summary**
- **Purpose:** Captures enriched order-level transactions across product, seller, customer, and time.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_id   | NVARCHAR(50) | 	Order identifier from the transactional system.                      |
| order_item_id   | NVARCHAR(50)          | Line item identifier within the order.                               |
| customer_sk   | INT          | Foreign key to `dim_customers`.                              |
| product_sk      | INT          | Foreign key to `dim_products`.                                                          |
| seller_sk   | INT         | Foreign key to `dim_sellers`.                                          |
| date_sk | INT | Foreign key to `dim_dates`(based on order purchase date). |
| order_status | NVARCHAR(50) | Current status of the order (e.g., delivered, shipped, canceled). |
| order_purchase_timestamp | DATETIME | Timestamp when the order was placed. |
| order_approved_at | DATETIME | Timestamp when the order was approved. |
| order_delivery_carrier_date | DATETIME | Timestamp when the item was handed to carrier. |
| order_delivery_customer_date | DATETIME | Timestamp when the customer received the product. |
| order_estimated_delivery_date | DATETIME | The system’s estimated delivery date. |
| shipping_limit_date | DATETIME | Deadline by which the seller had to ship the item. |
| price | DECIMAL(10,2) | Price of the product line item. |
| freight_value | DECIMAL(10,2) | Freight (shipping) cost associated with the order line. |
| payment_type | NVARCHAR(50) | Method of payment used (e.g., credit_card, voucher). |
| payment_installments | INT | Number of installments used for the payment. |
| payment_value | DECIMAL(10,2) | Total value paid (across installments). |
| review_score | INT | Customer review score (1–5). |
