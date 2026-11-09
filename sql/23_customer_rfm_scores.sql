WITH customer_rfm AS (
    SELECT
        customer_id,
        CAST(JULIANDAY('2011-12-10') 
        - JULIANDAY(DATE(MAX(invoice_date))) AS INTEGER) AS recency_days,
        COUNT(DISTINCT invoice) AS frequency,
        SUM(line_amount) AS monetary_gbp
    FROM customer_product_sales
    GROUP BY customer_id
)
SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary_gbp, 2) AS monetary_gbp,
    NTILE(5) OVER (ORDER BY recency_days DESC, customer_id) AS r_score,
    NTILE(5) OVER (ORDER BY frequency, customer_id) AS f_score,
    NTILE(5) OVER (ORDER BY monetary_gbp, customer_id) AS m_score
FROM customer_rfm
ORDER BY customer_id;