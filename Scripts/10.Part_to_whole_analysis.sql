/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - Measure each product category's contribution to overall sales.
    - Show category sales, total sales, and percentage of total.

Tables Used:
    - gold.fact_sales
    - gold.dim_products

SQL Functions Used:
    - SUM()
    - SUM() OVER()
    - NULLIF()
===============================================================================
*/

WITH category_sales AS (
    SELECT
        COALESCE(p.category, 'Unknown') AS category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    GROUP BY COALESCE(p.category, 'Unknown')
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CAST(
        100.0 * total_sales / NULLIF(SUM(total_sales) OVER (), 0)
        AS DECIMAL(10, 2)
    ) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC, category;
GO


-- =============================================================================
-- Sales contribution by country
-- =============================================================================

WITH country_sales AS (
    SELECT
        COALESCE(c.country, 'Unknown') AS country,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY COALESCE(c.country, 'Unknown')
)
SELECT
    country,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CAST(
        100.0 * total_sales / NULLIF(SUM(total_sales) OVER (), 0)
        AS DECIMAL(10, 2)
    ) AS percentage_of_total
FROM country_sales
ORDER BY total_sales DESC, country;
GO
