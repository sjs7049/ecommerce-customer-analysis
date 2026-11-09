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
monthly_new_existing_sales AS (
    SELECT
        month,
        SUM(CASE WHEN customer_type = 'new' THEN line_amount ELSE 0 END) AS new_sales_gbp,
        SUM(CASE WHEN customer_type = 'existing' THEN line_amount ELSE 0 END) AS existing_sales_gbp,
        SUM(line_amount) AS total_sales_gbp
    FROM new_existing_customers
    WHERE month < '2011-12'
    GROUP BY month
)
SELECT
    month,
    ROUND(new_sales_gbp, 2) AS new_sales_gbp,
    ROUND(existing_sales_gbp, 2) AS existing_sales_gbp,
    ROUND(total_sales_gbp, 2) AS total_sales_gbp,
    ROUND (
        100.0 * existing_sales_gbp / total_sales_gbp,
        2
    ) AS existing_sales_share_pct
FROM monthly_new_existing_sales
ORDER BY month;