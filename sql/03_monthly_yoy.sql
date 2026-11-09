WITH monthly AS (
    SELECT
        SUBSTR(invoice_date, 1, 7) AS month,
        COUNT(DISTINCT invoice) AS orders,
        SUM(line_amount) AS sales_gbp,
        SUM(line_amount) / COUNT(DISTINCT invoice) AS avg_order_value_gbp
    FROM product_sales  
    GROUP BY SUBSTR(invoice_date, 1, 7)
)
SELECT 
    curr.month,
    curr.orders,
    ROUND(curr.sales_gbp, 2) AS sales_gbp,
    ROUND(curr.avg_order_value_gbp, 2) AS avg_order_value_gbp,
    ROUND(prev.sales_gbp, 2) AS previous_year_sales_gbp,
    ROUND(
        100.0 * (curr.sales_gbp / NULLIF(prev.sales_gbp, 0) - 1),
        2
    ) AS sales_yoy_pct,
    ROUND(
        100.0 * curr.orders / NULLIF(prev.orders, 0) - 100,
        2
    ) AS orders_yoy_pct,
    ROUND(
        100.0 * (curr.avg_order_value_gbp / NULLIF(prev.avg_order_value_gbp, 0) - 1),
        2
    ) AS aov_yoy_pct
FROM monthly AS curr
JOIN monthly AS `prev`
    ON prev.month = STRFTIME('%Y-%m', curr.month || '-01', '-1 year')
WHERE curr.month < '2011-12'
order by curr.month