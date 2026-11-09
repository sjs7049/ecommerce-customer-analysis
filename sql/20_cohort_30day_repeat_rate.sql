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
),
eligible_30d_customer AS (
    SELECT
        customer_id,
        first_purchase_date,
        second_purchase_date
    FROM first_to_second_purchase
    WHERE DATETIME(first_purchase_date, '+30 days') <= (SELECT MAX(invoice_date) FROM transactions)
),
repeat_within_30d_customer AS (
    SELECT 
        SUBSTR(first_purchase_date, 1, 7) AS cohort_month,
        COUNT(customer_id) AS eligible_customers,
        COUNT(
            CASE 
                WHEN JULIANDAY(second_purchase_date) 
                    - JULIANDAY(first_purchase_date) >= 0
                AND JULIANDAY(second_purchase_date)
                    - JULIANDAY(first_purchase_date) < 30
                THEN customer_id
            END
        ) AS repeat_within_30d_customers
    FROM eligible_30d_customer
    GROUP BY SUBSTR(first_purchase_date, 1, 7)
)
SELECT
    cohort_month,
    eligible_customers,
    repeat_within_30d_customers,
    ROUND(
        100.0 * repeat_within_30d_customers / eligible_customers,
        2
    ) AS repeat_within_30d_pct
FROM repeat_within_30d_customer
ORDER BY cohort_month