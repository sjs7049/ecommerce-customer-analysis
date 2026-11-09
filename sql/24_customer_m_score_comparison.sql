WITH rfm_customer AS (
    SELECT
        customer_id,
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
        monetary_gbp,
        COALESCE(n.negative_amount_gbp, 0) AS negative_amount_gbp,
        r.monetary_gbp + COALESCE(n.negative_amount_gbp, 0) AS signed_total_gbp
    FROM rfm_customer r
    LEFT JOIN negative_amount n
        ON r.customer_id = n.customer_id   
),
rfm_customer_amount AS (
    SELECT  
        customer_id,
        monetary_gbp,
        signed_total_gbp,
        NTILE(5) OVER (ORDER BY monetary_gbp, customer_id) AS m_score,
        NTILE(5) OVER (ORDER BY signed_total_gbp, customer_id) AS adjusted_m_score
    FROM rfm_customer_negative_amount
)
SELECT  
    customer_id,
    ROUND(monetary_gbp, 2) AS monetary_gbp,
    ROUND(signed_total_gbp, 2) AS signed_total_gbp,
    m_score,
    adjusted_m_score,
    adjusted_m_score - m_score AS m_score_change
FROM rfm_customer_amount
ORDER BY customer_id;