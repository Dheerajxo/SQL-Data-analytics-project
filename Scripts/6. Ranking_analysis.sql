/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - Rank products and customers by sales performance.
    - Identify top-performing and lowest-performing products.
    - Find customers with the most and fewest orders.
    - Include products and customers with no sales where relevant.

Tables Used:
    - gold.fact_sales
    - gold.dim_products
    - gold.dim_customers

SQL Functions Used:
    - TOP
    - RANK()
    - DENSE_RANK()
    - ROW_NUMBER()
    - GROUP BY
    - ORDER BY
===============================================================================
*/

-- =============================================================================
-- 1. TOP 5 PRODUCTS BY SALES
-- =============================================================================

SELECT TOP (5)
    p.product_key,
    p.product_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_key,
    p.product_name
ORDER BY
    total_sales DESC,
    p.product_name;
GO


-- =============================================================================
-- 2. TOP 5 PRODUCTS WITH RANKS
-- =============================================================================

WITH product_sales AS (
    SELECT
        p.product_key,
        p.product_name,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    JOIN gold.dim_products p
        ON f.product_key = p.product_key
    GROUP BY
        p.product_key,
        p.product_name
),
ranked_products AS (
    SELECT
        product_key,
        product_name,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM product_sales
)
SELECT
    product_key,
    product_name,
    total_sales,
    sales_rank
FROM ranked_products
WHERE sales_rank <= 5
ORDER BY sales_rank, product_name;
GO


-- =============================================================================
-- 3. 5 LOWEST-SELLING PRODUCTS, INCLUDING PRODUCTS WITH NO SALES
-- =============================================================================

SELECT TOP (5)
    p.product_key,
    p.product_name,
    COALESCE(SUM(f.sales_amount), 0) AS total_sales
FROM gold.dim_products p
LEFT JOIN gold.fact_sales f
    ON p.product_key = f.product_key
GROUP BY
    p.product_key,
    p.product_name
ORDER BY
    total_sales,
    p.product_name;
GO


-- =============================================================================
-- 4. CUSTOMERS RANKED BY TOTAL SALES
-- =============================================================================

WITH customer_sales AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(SUM(f.sales_amount), 0) AS total_sales
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales f
        ON c.customer_key = f.customer_key
    GROUP BY
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_key,
    customer_id,
    first_name,
    last_name,
    total_sales,
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales
ORDER BY sales_rank, last_name, first_name;
GO


-- =============================================================================
-- 5. TOP 10 CUSTOMERS BY TOTAL SALES
-- =============================================================================

WITH customer_sales AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(f.sales_amount) AS total_sales
    FROM gold.dim_customers c
    JOIN gold.fact_sales f
        ON c.customer_key = f.customer_key
    GROUP BY
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name
),
ranked_customers AS (
    SELECT
        customer_key,
        customer_id,
        first_name,
        last_name,
        total_sales,
        ROW_NUMBER() OVER (
            ORDER BY total_sales DESC, customer_key
        ) AS row_num
    FROM customer_sales
)
SELECT
    customer_key,
    customer_id,
    first_name,
    last_name,
    total_sales
FROM ranked_customers
WHERE row_num <= 10
ORDER BY row_num;
GO


-- =============================================================================
-- 6. CUSTOMERS WITH THE FEWEST ORDERS, INCLUDING CUSTOMERS WITH NO ORDERS
-- =============================================================================

WITH customer_orders AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT f.order_number) AS total_orders
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales f
        ON c.customer_key = f.customer_key
    GROUP BY
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name
),
ranked_customers AS (
    SELECT
        customer_key,
        customer_id,
        first_name,
        last_name,
        total_orders,
        RANK() OVER (ORDER BY total_orders ASC) AS order_rank
    FROM customer_orders
)
SELECT
    customer_key,
    customer_id,
    first_name,
    last_name,
    total_orders,
    order_rank
FROM ranked_customers
WHERE order_rank = 1
ORDER BY last_name, first_name;
GO
