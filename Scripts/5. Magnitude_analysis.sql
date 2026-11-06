/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - Measure customer, product, and sales distribution across dimensions.
    - Compare sales, quantities, and product costs across categories and regions.
    - Include dimension members even when they have no matching sales.

Tables Used:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales

SQL Functions Used:
    - SUM()
    - COUNT()
    - AVG()
    - GROUP BY
    - ORDER BY
===============================================================================
*/

-- =============================================================================
-- 1. CUSTOMER COUNTS BY COUNTRY
-- =============================================================================

SELECT
    COALESCE(country, 'Unknown') AS country,
    COUNT(*) AS total_customers
FROM gold.dim_customers
GROUP BY COALESCE(country, 'Unknown')
ORDER BY total_customers DESC, country;
GO


-- =============================================================================
-- 2. CUSTOMER COUNTS BY GENDER
-- =============================================================================

SELECT
    COALESCE(gender, 'Unknown') AS gender,
    COUNT(*) AS total_customers
FROM gold.dim_customers
GROUP BY COALESCE(gender, 'Unknown')
ORDER BY total_customers DESC, gender;
GO


-- =============================================================================
-- 3. PRODUCT COUNTS BY CATEGORY
-- =============================================================================

SELECT
    COALESCE(category, 'Unknown') AS category,
    COUNT(*) AS total_products
FROM gold.dim_products
GROUP BY COALESCE(category, 'Unknown')
ORDER BY total_products DESC, category;
GO


-- =============================================================================
-- 4. AVERAGE PRODUCT COST BY CATEGORY
-- =============================================================================

SELECT
    COALESCE(category, 'Unknown') AS category,
    AVG(CAST(cost AS DECIMAL(18, 2))) AS average_cost,
    MIN(cost) AS lowest_cost,
    MAX(cost) AS highest_cost,
    COUNT(*) AS total_products
FROM gold.dim_products
GROUP BY COALESCE(category, 'Unknown')
ORDER BY average_cost DESC, category;
GO


-- =============================================================================
-- 5. SALES AND QUANTITY BY CATEGORY
-- =============================================================================

SELECT
    COALESCE(p.category, 'Unknown') AS category,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.dim_products p
LEFT JOIN gold.fact_sales f
    ON p.product_key = f.product_key
GROUP BY COALESCE(p.category, 'Unknown')
ORDER BY total_sales DESC, category;
GO


-- =============================================================================
-- 6. SALES BY PRODUCT
-- =============================================================================

SELECT
    p.product_key,
    p.product_name,
    COALESCE(p.category, 'Unknown') AS category,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.dim_products p
LEFT JOIN gold.fact_sales f
    ON p.product_key = f.product_key
GROUP BY
    p.product_key,
    p.product_name,
    COALESCE(p.category, 'Unknown')
ORDER BY total_sales DESC, p.product_name;
GO


-- =============================================================================
-- 7. CUSTOMER SALES
-- =============================================================================

SELECT
    c.customer_key,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COALESCE(c.country, 'Unknown') AS country,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales f
    ON c.customer_key = f.customer_key
GROUP BY
    c.customer_key,
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(c.country, 'Unknown')
ORDER BY total_sales DESC, customer_name;
GO


-- =============================================================================
-- 8. SALES AND QUANTITY BY COUNTRY
-- =============================================================================

SELECT
    COALESCE(c.country, 'Unknown') AS country,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.order_number) AS total_orders,
    COUNT(DISTINCT f.customer_key) AS customers_with_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY COALESCE(c.country, 'Unknown')
ORDER BY total_sales DESC, country;
GO


-- =============================================================================
-- 9. SALES BY MARITAL STATUS
-- =============================================================================

SELECT
    COALESCE(c.marital_status, 'Unknown') AS marital_status,
    COUNT(DISTINCT c.customer_key) AS total_customers,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales f
    ON c.customer_key = f.customer_key
GROUP BY COALESCE(c.marital_status, 'Unknown')
ORDER BY total_sales DESC, marital_status;
GO
