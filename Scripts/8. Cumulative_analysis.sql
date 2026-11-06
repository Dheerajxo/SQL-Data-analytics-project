/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - Calculate running sales totals and moving average prices.
    - Compare cumulative sales within each year and across all years.

Table Used:
    - gold.fact_sales

SQL Functions Used:
    - SUM() OVER()
    - AVG() OVER()
    - DATEFROMPARTS()
===============================================================================
*/

-- =============================================================================
-- 1. MONTHLY SALES WITH A RUNNING TOTAL THAT RESTARTS EACH YEAR
-- =============================================================================

WITH monthly_sales AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER (
        PARTITION BY YEAR(order_month)
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS yearly_running_total_sales
FROM monthly_sales
ORDER BY order_month;
GO


-- =============================================================================
-- 2. YEARLY SALES WITH A RUNNING TOTAL AND CUMULATIVE AVERAGE PRICE
-- =============================================================================

WITH yearly_sales AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), 1, 1) AS order_year,
        SUM(sales_amount) AS total_sales,
        AVG(CAST(price AS DECIMAL(18, 2))) AS average_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT
    order_year,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY order_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales,
    average_price,
    AVG(average_price) OVER (
        ORDER BY order_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_average_price
FROM yearly_sales
ORDER BY order_year;
GO


-- =============================================================================
-- 3. THREE-MONTH MOVING AVERAGE OF MONTHLY SALES
-- =============================================================================

WITH monthly_sales AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    order_month,
    total_sales,
    AVG(CAST(total_sales AS DECIMAL(18, 2))) OVER (
        ORDER BY order_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_moving_average
FROM monthly_sales
ORDER BY order_month;
GO
