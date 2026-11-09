WITH customer_first_purchase AS (
    SELECT
        customer_id,
        MIN(SUBSTR(invoice_date, 1, 7)) AS first_purchase_month
    FROM customer_product_sales
    GROUP BY customer_id
),
customer_purchase_month AS (
    SELECT DISTINCT
        customer_id,
        SUBSTR(invoice_date, 1, 7) AS purchase_month
    FROM customer_product_sales
    WHERE SUBSTR(invoice_date, 1, 7) < '2011-12'
),
cal_elapsed_month AS (
    SELECT
        m.customer_id,
        first_purchase_month,
        purchase_month,
        (CAST(STRFTIME('%Y', purchase_month || '-01') AS INTEGER) 
        - CAST(STRFTIME('%Y', first_purchase_month || '-01') AS INTEGER)) * 12 
        + CAST(STRFTIME('%m', purchase_month || '-01') AS INTEGER) 
        - CAST(STRFTIME('%m', first_purchase_month || '-01') AS INTEGER) AS elapsed_month
    FROM customer_purchase_month m
    JOIN customer_first_purchase f
        ON m.customer_id = f.customer_id
),
cohort_size AS (
    SELECT
        first_purchase_month AS cohort_month,
        COUNT(*) AS cohort_customers
    FROM customer_first_purchase
    WHERE first_purchase_month < '2011-12'
    GROUP BY first_purchase_month
),
cohort_activity AS (
    SELECT
        first_purchase_month AS cohort_month,
        elapsed_month AS month_index,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cal_elapsed_month
    GROUP BY first_purchase_month, elapsed_month
)
SELECT 
    a.cohort_month,
    a.month_index,
    s.cohort_customers,
    a.active_customers,
    ROUND(
        100.0 * a.active_customers / s.cohort_customers,
        2
    ) AS retention_pct
FROM cohort_activity a
JOIN cohort_size s
    ON a.cohort_month = s.cohort_month
ORDER BY a.cohort_month, a.month_index;