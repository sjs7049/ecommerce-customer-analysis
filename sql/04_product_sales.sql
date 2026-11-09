SELECT
    stock_code,
    SUM(quantity) AS quantity_sold,
    COUNT(DISTINCT invoice) AS orders,
    ROUND(SUM(line_amount), 2) AS sales_gbp,
    ROUND(
        100.0 * (SUM(line_amount) / (SELECT SUM(line_amount) FROM product_sales)),
        2
    ) AS sales_share_pct
FROM product_sales
GROUP BY stock_code
ORDER BY SUM(line_amount) DESC, stock_code
LIMIT 20;