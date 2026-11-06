/*
===============================================================================
Performance Analysis (Year-over-Year)
===============================================================================
Purpose:
    - Compare annual product sales with each product's average annual sales.
    - Compare each year's product sales with the previous year.
    - Show the sales difference and percentage change.

Tables Used:
    - gold.fact_sales
    - gold.dim_products

SQL Functions Used:
    - AVG() OVER()
    - LAG()
    - CASE
===============================================================================
*/

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_key,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_key,
        p.product_name
),
product_performance AS (
    SELECT
        order_year,
        product_key,
        product_name,
        current_sales,
        AVG(CAST(current_sales AS DECIMAL(18, 2))) OVER (
            PARTITION BY product_key
        ) AS average_annual_sales,
        LAG(current_sales) OVER (
            PARTITION BY product_key
            ORDER BY order_year
        ) AS previous_year_sales
    FROM yearly_product_sales
)
SELECT
    order_year,
    product_key,
    product_name,
    current_sales,
    average_annual_sales,
    current_sales - average_annual_sales AS difference_from_average,
    CASE
        WHEN current_sales > average_annual_sales THEN 'Above Average'
        WHEN current_sales < average_annual_sales THEN 'Below Average'
        ELSE 'Average'
    END AS average_sales_performance,
    previous_year_sales,
    current_sales - previous_year_sales AS year_over_year_difference,
    CAST(
        100.0 * (current_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0)
        AS DECIMAL(10, 2)
    ) AS year_over_year_percentage_change,
    CASE
        WHEN previous_year_sales IS NULL THEN 'No Previous Year'
        WHEN current_sales > previous_year_sales THEN 'Increase'
        WHEN current_sales < previous_year_sales THEN 'Decrease'
        ELSE 'No Change'
    END AS year_over_year_trend
FROM product_performance
ORDER BY
    product_name,
    order_year;
GO
