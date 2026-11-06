/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - Track sales, order, customer, and quantity trends over time.
    - Compare monthly and yearly performance.
    - Calculate period-over-period changes.

Table Used:
    - gold.fact_sales

SQL Functions Used:
    - DATEFROMPARTS()
    - YEAR()
    - MONTH()
    - SUM()
    - COUNT()
    - LAG()
===============================================================================
*/

-- =============================================================================
-- 1. MONTHLY SALES, CUSTOMERS, ORDERS, AND QUANTITY
-- =============================================================================

SELECT
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY order_month;
GO


-- =============================================================================
-- 2. YEARLY SALES, CUSTOMERS, ORDERS, AND QUANTITY
-- =============================================================================

SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;
GO


-- =============================================================================
-- 3. MONTH-OF-YEAR SALES COMPARISON
-- =============================================================================

SELECT
    MONTH(order_date) AS month_number,
    DATENAME(MONTH, order_date) AS month_name,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    MONTH(order_date),
    DATENAME(MONTH, order_date)
ORDER BY month_number;
GO


-- =============================================================================
-- 4. MONTHLY SALES CHANGE FROM THE PREVIOUS MONTH
-- =============================================================================

WITH monthly_sales AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
),
monthly_comparison AS (
    SELECT
        order_month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY order_month) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    order_month,
    total_sales,
    previous_month_sales,
    total_sales - previous_month_sales AS sales_change,
    CAST(
        100.0 * (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0)
        AS DECIMAL(10, 2)
    ) AS percentage_change
FROM monthly_comparison
ORDER BY order_month;
GO
