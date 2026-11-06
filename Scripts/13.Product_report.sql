/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - Create a product-level view of sales activity and product metrics.
    - Include products with no sales.
    - Segment products by total sales.
    - Calculate sales recency, average order revenue, and average monthly revenue.

View Created:
    - gold.report_products

Tables Used:
    - gold.dim_products
    - gold.fact_sales
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH product_activity AS (
    SELECT
        p.product_key,
        p.product_id,
        p.product_number,
        p.product_name,
        p.category_id,
        p.category,
        p.subcategory,
        p.maintenance,
        p.cost,
        p.product_line,
        p.start_date,
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity
    FROM gold.dim_products p
    LEFT JOIN gold.fact_sales f
        ON p.product_key = f.product_key
),
product_aggregations AS (
    SELECT
        product_key,
        product_id,
        product_number,
        product_name,
        category_id,
        category,
        subcategory,
        maintenance,
        cost,
        product_line,
        start_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        COALESCE(SUM(sales_amount), 0) AS total_sales,
        COALESCE(SUM(quantity), 0) AS total_quantity,
        MIN(order_date) AS first_sale_date,
        MAX(order_date) AS last_sale_date,
        CASE
            WHEN MIN(order_date) IS NULL THEN NULL
            ELSE DATEDIFF(MONTH, MIN(order_date), MAX(order_date))
        END AS sales_history_months
    FROM product_activity
    GROUP BY
        product_key,
        product_id,
        product_number,
        product_name,
        category_id,
        category,
        subcategory,
        maintenance,
        cost,
        product_line,
        start_date
)
SELECT
    product_key,
    product_id,
    product_number,
    product_name,
    category_id,
    category,
    subcategory,
    maintenance,
    cost,
    product_line,
    start_date,
    first_sale_date,
    last_sale_date,
    CASE
        WHEN last_sale_date IS NULL THEN NULL
        ELSE DATEDIFF(MONTH, last_sale_date, CAST(GETDATE() AS DATE))
    END AS recency_in_months,
    CASE
        WHEN total_orders = 0 THEN 'No Sales'
        WHEN total_sales > 50000 THEN 'High Performer'
        WHEN total_sales >= 10000 THEN 'Mid Range'
        ELSE 'Low Performer'
    END AS product_segment,
    sales_history_months,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    CAST(
        total_sales / NULLIF(CAST(total_quantity AS DECIMAL(18, 2)), 0)
        AS DECIMAL(18, 2)
    ) AS average_selling_price,
    CAST(
        total_sales / NULLIF(CAST(total_orders AS DECIMAL(18, 2)), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_revenue,
    CAST(
        total_sales / NULLIF(
            CAST(
                CASE
                    WHEN sales_history_months IS NULL OR sales_history_months = 0
                        THEN 1
                    ELSE sales_history_months
                END
                AS DECIMAL(18, 2)
            ),
            0
        )
        AS DECIMAL(18, 2)
    ) AS average_monthly_revenue
FROM product_aggregations;
GO
