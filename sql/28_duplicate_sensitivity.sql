WITH baseline_cte AS (
    SELECT 
        'baseline' AS scenario,
        COUNT(*) AS product_rows,
        COUNT(DISTINCT invoice) AS orders,
        SUM(line_amount) AS sales_gbp,
        SUM(line_amount) / COUNT(DISTINCT invoice) AS avg_order_value_gbp
    FROM product_sales
),
deduplicated_cte AS (
    SELECT
        invoice,
        line_amount,
        ROW_NUMBER() OVER (
            PARTITION BY source_sheet, invoice, stock_code, description, 
                        quantity, invoice_date, unit_price, customer_id, country
            ORDER BY record_id
        ) AS num
    FROM product_sales
)
SELECT 
    scenario,
    product_rows,
    orders,
    ROUND(sales_gbp, 2) AS sales_gbp,
    ROUND(avg_order_value_gbp, 2) AS avg_order_value_gbp
FROM baseline_cte

UNION ALL

SELECT 
    'deduplicated' AS scenario,
    COUNT(*) AS product_rows,
    COUNT(DISTINCT invoice) AS orders,
    ROUND(SUM(line_amount), 2) AS sales_gbp,
    ROUND(SUM(line_amount) / COUNT(DISTINCT invoice), 2) AS avg_order_value_gbp
FROM deduplicated_cte
WHERE num = 1;