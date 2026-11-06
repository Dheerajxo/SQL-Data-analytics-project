/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - Explore the structure and contents of the customer and product dimensions.
    - Review distinct values, row counts, and basic data quality.

Tables Used:
    - gold.dim_customers
    - gold.dim_products

SQL Functions Used:
    - COUNT
    - DISTINCT
    - GROUP BY
    - ORDER BY
===============================================================================
*/

-- =============================================================================
-- 1. CUSTOMER DIMENSION
-- =============================================================================

-- Count customer records
SELECT
    COUNT(*) AS total_customer_rows,
    COUNT(DISTINCT customer_key) AS unique_customer_keys,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM gold.dim_customers;
GO

-- Retrieve unique customer countries
SELECT DISTINCT
    country
FROM gold.dim_customers
ORDER BY country;
GO

-- Count customers by country
SELECT
    country,
    COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY country
ORDER BY customer_count DESC, country;
GO

-- Review distinct marital status and gender values
SELECT DISTINCT
    marital_status,
    gender
FROM gold.dim_customers
ORDER BY marital_status, gender;
GO

-- Check for missing customer dimension values
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_ids,
    SUM(CASE WHEN first_name IS NULL OR TRIM(first_name) = '' THEN 1 ELSE 0 END) AS missing_first_names,
    SUM(CASE WHEN last_name IS NULL OR TRIM(last_name) = '' THEN 1 ELSE 0 END) AS missing_last_names,
    SUM(CASE WHEN country IS NULL OR TRIM(country) = '' THEN 1 ELSE 0 END) AS missing_countries
FROM gold.dim_customers;
GO

-- Check for duplicate customer keys
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
GO


-- =============================================================================
-- 2. PRODUCT DIMENSION
-- =============================================================================

-- Count product records
SELECT
    COUNT(*) AS total_product_rows,
    COUNT(DISTINCT product_key) AS unique_product_keys,
    COUNT(DISTINCT product_id) AS unique_product_ids
FROM gold.dim_products;
GO

-- Retrieve unique categories, subcategories, and products
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
GO

-- Count products by category and subcategory
SELECT
    category,
    subcategory,
    COUNT(*) AS product_count
FROM gold.dim_products
GROUP BY
    category,
    subcategory
ORDER BY
    category,
    product_count DESC,
    subcategory;
GO

-- Review distinct product lines and maintenance values
SELECT DISTINCT
    product_line,
    maintenance
FROM gold.dim_products
ORDER BY product_line, maintenance;
GO

-- Check for missing product dimension values
SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_ids,
    SUM(CASE WHEN product_name IS NULL OR TRIM(product_name) = '' THEN 1 ELSE 0 END) AS missing_product_names,
    SUM(CASE WHEN category IS NULL OR TRIM(category) = '' THEN 1 ELSE 0 END) AS missing_categories,
    SUM(CASE WHEN cost IS NULL THEN 1 ELSE 0 END) AS missing_costs
FROM gold.dim_products;
GO

-- Check for duplicate product keys
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
GO
