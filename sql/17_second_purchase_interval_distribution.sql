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
second_purchase_interval AS (
    SELECT 
        customer_id,
        JULIANDAY(second_purchase_date) - JULIANDAY(first_purchase_date) AS days_to_second_purchase
    FROM first_to_second_purchase
),
second_purchase_interval_distribution AS (
    SELECT 
        customer_id,
        CASE 
            WHEN days_to_second_purchase >= 0 AND days_to_second_purchase < 7 THEN '0-7일 미만'
            WHEN days_to_second_purchase >= 7 AND days_to_second_purchase < 30 THEN '7-30일 미만'
            WHEN days_to_second_purchase >= 30 AND days_to_second_purchase < 90 THEN '30-90일 미만'
            WHEN days_to_second_purchase >= 90 AND days_to_second_purchase < 180 THEN '90-180일 미만'
            WHEN days_to_second_purchase >= 180 THEN '180일 이상'
        END AS interval_group
    FROM second_purchase_interval
    WHERE days_to_second_purchase IS NOT NULL
)
SELECT 
    interval_group,
    COUNT(customer_id) AS customers,
    ROUND(
        100.0 * COUNT(customer_id) / (
            SELECT COUNT(customer_id) 
            FROM second_purchase_interval 
            WHERE days_to_second_purchase IS NOT NULL
        ),
        2
    ) AS customer_share_pct
FROM second_purchase_interval_distribution
GROUP BY interval_group
ORDER BY 
    CASE 
        WHEN interval_group = '0-7일 미만' THEN 1
        WHEN interval_group = '7-30일 미만' THEN 2
        WHEN interval_group = '30-90일 미만' THEN 3
        WHEN interval_group = '90-180일 미만' THEN 4
        WHEN interval_group = '180일 이상' THEN 5
    END
;


