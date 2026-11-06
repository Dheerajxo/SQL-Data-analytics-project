/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - Create a customer-level view of sales activity and customer metrics.
    - Include customers with no orders.
    - Calculate age group, customer segment, recency, average order value,
      and average monthly spend.

View Created:
    - gold.report_customers

Tables Used:
    - gold.dim_customers
    - gold.fact_sales
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
WITH customer_activity AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.customer_number,
        c.first_name,
        c.last_name,
        c.birthdate,
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales f
        ON c.customer_key = f.customer_key
),
customer_aggregation AS (
    SELECT
        customer_key,
        customer_id,
        customer_number,
        first_name,
        last_name,
        birthdate,
        COUNT(DISTINCT order_number) AS total_orders,
        COALESCE(SUM(sales_amount), 0) AS total_sales,
        COALESCE(SUM(quantity), 0) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        CASE
            WHEN MIN(order_date) IS NULL THEN NULL
            ELSE DATEDIFF(MONTH, MIN(order_date), MAX(order_date))
        END AS purchase_history_months
    FROM customer_activity
    GROUP BY
        customer_key,
        customer_id,
        customer_number,
        first_name,
        last_name,
        birthdate
),
customer_metrics AS (
    SELECT
        customer_key,
        customer_id,
        customer_number,
        first_name,
        last_name,
        birthdate,
        CASE
            WHEN birthdate IS NULL OR birthdate > CAST(GETDATE() AS DATE) THEN NULL
            ELSE DATEDIFF(YEAR, birthdate, CAST(GETDATE() AS DATE))
                 - CASE
                       WHEN DATEADD(
                           YEAR,
                           DATEDIFF(YEAR, birthdate, CAST(GETDATE() AS DATE)),
                           birthdate
                       ) > CAST(GETDATE() AS DATE)
                       THEN 1
                       ELSE 0
                   END
        END AS age,
        total_orders,
        total_sales,
        total_quantity,
        total_products,
        first_order_date,
        last_order_date,
        purchase_history_months,
        CASE
            WHEN last_order_date IS NULL THEN NULL
            ELSE DATEDIFF(MONTH, last_order_date, CAST(GETDATE() AS DATE))
        END AS recency_months
    FROM customer_aggregation
)
SELECT
    customer_key,
    customer_id,
    customer_number,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    age,
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age < 30 THEN '20-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE
        WHEN total_orders = 0 THEN 'No Purchases'
        WHEN purchase_history_months >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN purchase_history_months >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    first_order_date,
    last_order_date,
    recency_months,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    purchase_history_months,
    CAST(
        total_sales / NULLIF(CAST(total_orders AS DECIMAL(18, 2)), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value,
    CAST(
        total_sales / NULLIF(CAST(
            CASE
                WHEN purchase_history_months IS NULL OR purchase_history_months = 0
                    THEN 1
                ELSE purchase_history_months
            END AS DECIMAL(18, 2)
        ), 0)
        AS DECIMAL(18, 2)
    ) AS average_monthly_spend
FROM customer_metrics;
GO
