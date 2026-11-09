WITH customer_orders AS (
    SELECT 
        customer_id,
        invoice,
        MIN(invoice_date) AS purchase_date
    FROM customer_product_sales
    GROUP BY customer_id, invoice
),
customer_order_number AS (
    SELECT 
        customer_id,
        invoice,
        purchase_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY purchase_date, invoice
        ) AS order_number
    FROM customer_orders
),
first_to_second_purchase AS (
    SELECT 
        customer_id,
        MAX(CASE WHEN order_number = 1 THEN purchase_date END) AS first_purchase_date,
        MAX(CASE WHEN order_number = 2 THEN purchase_date END) AS second_purchase_date
    FROM customer_order_number
    GROUP BY customer_id
)
SELECT 
    customer_id,
    first_purchase_date,
    second_purchase_date,
    ROUND(
        JULIANDAY(second_purchase_date) - JULIANDAY(first_purchase_date),
        2
    ) AS days_to_second_purchase
FROM first_to_second_purchase
ORDER BY customer_id