WITH two_month AS (
    SELECT
        SUBSTR(invoice_date, 1, 7) AS month,
        invoice,
        stock_code,
        line_amount
    FROM product_sales
    WHERE SUBSTR(invoice_date, 1, 7) IN ('2011-01', '2011-12')
)
SELECT
    month,
    'baseline' AS scenario,
    COUNT(DISTINCT invoice) AS orders,
    ROUND(SUM(line_amount), 2) AS sales_gbp,
    ROUND(SUM(line_amount) / COUNT(DISTINCT invoice), 2) AS avg_order_value_gbp
FROM two_month
GROUP BY month

UNION ALL

SELECT
    month,
    'adjusted' AS scenario,
    COUNT(DISTINCT invoice) AS orders,
    ROUND(SUM(line_amount), 2) AS sales_gbp,
    ROUND(SUM(line_amount) / COUNT(DISTINCT invoice), 2) AS avg_order_value_gbp
FROM two_month    
WHERE (invoice, stock_code) NOT IN (
    VALUES (541431, 23166), (581483, 23843)
)
GROUP BY month;