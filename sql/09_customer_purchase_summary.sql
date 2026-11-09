SELECT
    customer_id,
    COUNT(DISTINCT invoice) AS orders,
    SUM(quantity) AS quantity_purchased,
    ROUND(SUM(line_amount), 2) AS purchase_amount_gbp,
    ROUND(SUM(line_amount) / COUNT(DISTINCT invoice), 2) AS avg_order_value_gbp,
    MIN(invoice_date) AS first_purchase_date,
    MAX(invoice_date) AS last_purchase_date
FROM customer_product_sales
GROUP BY customer_id
ORDER BY SUM(line_amount) DESC, customer_id
LIMIT 20;