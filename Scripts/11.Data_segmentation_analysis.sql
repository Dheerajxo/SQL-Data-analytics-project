/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - Group products into cost ranges.
    - Segment customers by purchase history and total sales.
    - Summarize the number of products and customers in each segment.

Tables Used:
    - gold.dim_products
    - gold.dim_customers
    - gold.fact_sales

SQL Functions Used:
    - CASE
    - GROUP BY
    - SUM()
    - COUNT()
    - MIN()
    - MAX()
    - DATEDIFF()
===============================================================================
*/

-- =============================================================================
-- 1. PRODUCT SEGMENTATION BY COST
-- =============================================================================

WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost IS NULL THEN 'Unknown Cost'
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost < 500 THEN '100-499'
            WHEN cost < 1000 THEN '500-999'
            ELSE '1000 and Above'
        END AS cost_range
    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(*) AS total_products,
    MIN(cost) AS minimum_cost,
    MAX(cost) AS maximum_cost
FROM product_segments
GROUP BY cost_range
ORDER BY
    CASE cost_range
        WHEN 'Below 100' THEN 1
        WHEN '100-499' THEN 2
        WHEN '500-999' THEN 3
        WHEN '1000 and Above' THEN 4
        ELSE 5
    END;
GO


-- =============================================================================
-- 2. CUSTOMER SEGMENTATION BY PURCHASE HISTORY AND SALES
-- =============================================================================

WITH customer_activity AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT f.order_number) AS total_orders,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS most_recent_order_date,
        DATEDIFF(
            MONTH,
            MIN(f.order_date),
            MAX(f.order_date)
        ) AS purchase_history_months
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales f
        ON c.customer_key = f.customer_key
    GROUP BY
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name
),
customer_segments AS (
    SELECT
        customer_key,
        customer_id,
        first_name,
        last_name,
        total_orders,
        COALESCE(total_spending, 0) AS total_spending,
        first_order_date,
        most_recent_order_date,
        COALESCE(purchase_history_months, 0) AS purchase_history_months,
        CASE
            WHEN total_orders IS NULL THEN 'No Purchases'
            WHEN purchase_history_months >= 12
                 AND total_spending > 5000 THEN 'VIP'
            WHEN purchase_history_months >= 12
                 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_activity
)
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    SUM(total_spending) AS segment_sales,
    AVG(CAST(total_spending AS DECIMAL(18, 2))) AS average_customer_spending
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;
GO


-- =============================================================================
-- 3. CUSTOMER SEGMENT DETAILS
-- =============================================================================

WITH customer_activity AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT f.order_number) AS total_orders,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS most_recent_order_date,
        DATEDIFF(
            MONTH,
            MIN(f.order_date),
            MAX(f.order_date)
        ) AS purchase_history_months
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
    total_orders,
    COALESCE(total_spending, 0) AS total_spending,
    first_order_date,
    most_recent_order_date,
    COALESCE(purchase_history_months, 0) AS purchase_history_months,
    CASE
        WHEN total_orders IS NULL THEN 'No Purchases'
        WHEN purchase_history_months >= 12
             AND total_spending > 5000 THEN 'VIP'
        WHEN purchase_history_months >= 12
             AND total_spending <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_activity
ORDER BY
    CASE
        WHEN total_orders IS NULL THEN 4
        WHEN purchase_history_months >= 12 AND total_spending > 5000 THEN 1
        WHEN purchase_history_months >= 12 AND total_spending <= 5000 THEN 2
        ELSE 3
    END,
    total_spending DESC;
GO
