WITH customer_last_purchase AS (
    SELECT
        customer_id,
        MAX(invoice_date) AS last_purchase_date,
        CAST(JULIANDAY('2011-12-10') 
        - JULIANDAY(DATE(MAX(invoice_date))) AS INTEGER) AS recency_days,
        COUNT(DISTINCT invoice) AS frequency,
        SUM(line_amount) AS monetary_gbp
    FROM customer_product_sales
    GROUP BY customer_id
)
SELECT
    customer_id,
    last_purchase_date,
    recency_days,
    frequency,
    ROUND(monetary_gbp, 2) AS monetary_gbp
FROM customer_last_purchase
ORDER BY customer_id;