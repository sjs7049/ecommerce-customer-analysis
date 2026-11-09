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
        END AS customer_type
    FROM customer_first_purchase_month m
    JOIN customer_product_sales s
        ON m.customer_id = s.customer_id
),
count_new_existing_customers AS (
    SELECT
        month,
        COUNT(DISTINCT CASE WHEN customer_type = 'new' THEN customer_id END) AS new_customers,
        COUNT(DISTINCT CASE WHEN customer_type = 'existing' THEN customer_id END) AS existing_customers,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM new_existing_customers
    WHERE month < '2011-12'
    GROUP BY month
)
SELECT
    month,
    new_customers,
    existing_customers,
    total_customers,
    ROUND (
        100.0 * existing_customers / total_customers,
        2
    ) AS existing_customer_share_pct
FROM count_new_existing_customers
ORDER BY month;