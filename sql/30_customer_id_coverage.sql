WITH customer_status AS (
    SELECT 
        CASE 
            WHEN customer_id IS NULL OR TRIM(customer_id) = '' THEN 'missing' 
            ELSE 'identified' 
        END AS customer_id_status,
        line_amount
    FROM product_sales
)
SELECT 
    customer_id_status,
    COUNT(*) AS product_rows,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer_status),
        2
    ) AS row_share_pct,
    ROUND(SUM(line_amount), 2) AS sales_gbp,
    ROUND(
        100.0 * SUM(line_amount) / (SELECT SUM(line_amount) FROM customer_status),
        2
    ) AS sales_share_pct
FROM customer_status
GROUP BY customer_id_status