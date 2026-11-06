/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - Calculate key business metrics for sales, products, and customers.
    - Compare total records with distinct entities.
    - Provide a consolidated overview of the business.

Tables Used:
    - gold.fact_sales
    - gold.dim_products
    - gold.dim_customers

SQL Functions Used:
    - COUNT()
    - SUM()
    - AVG()
    - MIN()
    - MAX()
===============================================================================
*/

-- =============================================================================
-- 1. SALES METRICS
-- =============================================================================

SELECT
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    AVG(CAST(price AS DECIMAL(18, 2))) AS average_selling_price,
    MIN(price) AS lowest_price,
    MAX(price) AS highest_price,
    COUNT(*) AS total_sales_rows,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;
GO


-- =============================================================================
-- 2. PRODUCT METRICS
-- =============================================================================

SELECT
    COUNT(*) AS total_product_rows,
    COUNT(DISTINCT product_key) AS unique_products,
    COUNT(DISTINCT category) AS product_categories,
    AVG(CAST(cost AS DECIMAL(18, 2))) AS average_product_cost,
    MIN(cost) AS lowest_product_cost,
    MAX(cost) AS highest_product_cost
FROM gold.dim_products;
GO


-- =============================================================================
-- 3. CUSTOMER METRICS
-- =============================================================================

SELECT
    COUNT(*) AS total_customer_rows,
    COUNT(DISTINCT customer_key) AS unique_customers,
    COUNT(DISTINCT country) AS countries_represented
FROM gold.dim_customers;
GO


-- =============================================================================
-- 4. CUSTOMERS WITH SALES
-- =============================================================================

SELECT
    COUNT(DISTINCT customer_key) AS customers_with_sales
FROM gold.fact_sales
WHERE customer_key IS NOT NULL;
GO


-- =============================================================================
-- 5. CONSOLIDATED BUSINESS METRICS
-- =============================================================================

SELECT
    'Total Sales' AS measure_name,
    CAST(SUM(sales_amount) AS DECIMAL(18, 2)) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Quantity Sold',
    CAST(SUM(quantity) AS DECIMAL(18, 2))
FROM gold.fact_sales

UNION ALL

SELECT
    'Average Selling Price',
    CAST(AVG(CAST(price AS DECIMAL(18, 2))) AS DECIMAL(18, 2))
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Orders',
    CAST(COUNT(DISTINCT order_number) AS DECIMAL(18, 2))
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Products',
    CAST(COUNT(DISTINCT product_key) AS DECIMAL(18, 2))
FROM gold.dim_products

UNION ALL

SELECT
    'Total Customers',
    CAST(COUNT(DISTINCT customer_key) AS DECIMAL(18, 2))
FROM gold.dim_customers

UNION ALL

SELECT
    'Customers With Sales',
    CAST(COUNT(DISTINCT customer_key) AS DECIMAL(18, 2))
FROM gold.fact_sales
WHERE customer_key IS NOT NULL;
GO


-- =============================================================================
-- 6. SALES DATE COVERAGE
-- =============================================================================

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS latest_order_date
FROM gold.fact_sales
WHERE order_date IS NOT NULL;
GO
