WITH customer_first_purchase_month AS (
    SELECT 
        customer_id,
        SUBSTR(MIN(invoice_date), 1, 7) AS first_month
    FROM customer_product_sales
    GROUP BY customer_id
),
new_existing_customers AS (
    SELECT 
        s.customer_id,
        invoice,
        SUBSTR(s.invoice_date, 1, 7) AS month,
        first_month,
        CASE 
            WHEN SUBSTR(s.invoice_date, 1, 7) = m.first_month THEN 'new'
            WHEN SUBSTR(s.invoice_date, 1, 7) > m.first_month THEN 'existing'
        END AS customer_type,
        line_amount
    FROM customer_first_purchase_month m
    JOIN customer_product_sales s
        ON m.customer_id = s.customer_id
),
monthly_customer_group AS (
    SELECT
        month,
        customer_type,
        COUNT(DISTINCT customer_id) AS customers,
        COUNT(DISTINCT invoice) AS orders,
        SUM(line_amount) AS sales_gbp
    FROM new_existing_customers
    WHERE month < '2011-12'
    GROUP BY month, customer_type
)
SELECT 
    month,
    customer_type,
    customers,
    orders,
    ROUND(sales_gbp, 2) AS sales_gbp,
    ROUND(CAST(orders AS REAL) / CAST(customers AS REAL), 2) AS orders_per_customer,
    ROUND(sales_gbp / orders, 2) AS avg_order_value_gbp,
    ROUND(sales_gbp / customers, 2) AS sales_per_customer_gbp
FROM monthly_customer_group
ORDER BY month, 
    CASE WHEN customer_type = 'new' THEN 1 ELSE 2 END