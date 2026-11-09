WITH rfm_customer AS (
    SELECT
        customer_id,
        CAST(JULIANDAY('2011-12-10') 
        - JULIANDAY(DATE(MAX(invoice_date))) AS INTEGER) AS recency_days,
        COUNT(DISTINCT invoice) AS frequency,
        SUM(line_amount) AS monetary_gbp
    FROM customer_product_sales
    GROUP BY customer_id
),
negative_amount AS (
    SELECT
        customer_id,
        SUM(CASE WHEN quantity < 0 THEN quantity * unit_price END) AS negative_amount_gbp
    FROM transactions
    WHERE item_type = 'product'
        AND unit_price > 0
        AND TRIM(customer_id) <> ''
    GROUP BY customer_id
),
rfm_customer_negative_amount AS (
    SELECT
        r.customer_id,
        recency_days,
        frequency,
        monetary_gbp,
        COALESCE(n.negative_amount_gbp, 0) AS negative_amount_gbp
    FROM rfm_customer r
    LEFT JOIN negative_amount n
        ON r.customer_id = n.customer_id   
)
SELECT  
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary_gbp, 2) AS monetary_gbp,
    ROUND(negative_amount_gbp, 2) AS negative_amount_gbp,
    ROUND(monetary_gbp + negative_amount_gbp, 2) AS signed_total_gbp,
    ROUND(
        100.0 * ABS(negative_amount_gbp) / monetary_gbp,
        2
    ) AS negative_to_positive_pct
FROM rfm_customer_negative_amount
ORDER BY negative_to_positive_pct DESC, customer_id;