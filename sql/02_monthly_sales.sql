SELECT
    SUBSTR(invoice_date, 1, 7) AS `month`,
    COUNT(DISTINCT invoice) AS orders,
    ROUND(SUM(line_amount), 2) AS sales_gbp,
    ROUND(
        SUM(line_amount) / COUNT(DISTINCT invoice), 
        2
    ) AS avg_order_value_gbp
FROM product_sales
GROUP BY SUBSTR(invoice_date, 1, 7)
ORDER BY `month`;