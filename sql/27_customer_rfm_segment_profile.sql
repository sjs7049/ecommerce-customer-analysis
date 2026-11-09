WITH customer_rfm AS (
    SELECT
        customer_id,
        CAST(JULIANDAY('2011-12-10') 
        - JULIANDAY(DATE(MAX(invoice_date))) AS INTEGER) AS recency_days,
        COUNT(DISTINCT invoice) AS frequency,
        SUM(line_amount) AS monetary_gbp
    FROM customer_product_sales
    GROUP BY customer_id
),
rf_customer AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        NTILE(5) OVER (ORDER BY recency_days DESC, customer_id) AS r_score,
        NTILE(5) OVER (ORDER BY frequency, customer_id) AS f_score
    FROM customer_rfm
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
customer_negative_amount AS (
    SELECT
        r.customer_id,
        r.monetary_gbp + COALESCE(n.negative_amount_gbp, 0) AS signed_total_gbp
    FROM customer_rfm r
    LEFT JOIN negative_amount n
        ON r.customer_id = n.customer_id   
),
m_customer AS (
    SELECT  
        customer_id,
        signed_total_gbp,
        NTILE(5) OVER (ORDER BY signed_total_gbp, customer_id) AS adjusted_m_score
    FROM customer_negative_amount
),
customer_rfm_segment AS (
    SELECT
        r.customer_id,
        r.recency_days,
        r.frequency,
        m.signed_total_gbp,
        CASE 
            WHEN r.r_score >= 4 AND r.f_score >= 4 AND m.adjusted_m_score >= 4 THEN '핵심 고객 후보'
            WHEN r.r_score <= 2 AND r.f_score >= 4 AND m.adjusted_m_score >= 4 THEN '재활성화 후보'
            WHEN r.r_score >= 4 AND r.f_score <= 2 THEN '최근 저빈도 고객'
            ELSE '나머지 고객'
        END AS rfm_segment
    FROM rf_customer r
    JOIN m_customer m
        ON r.customer_id = m.customer_id
)
SELECT 
    rfm_segment,
    COUNT(*) AS customers,
    ROUND(AVG(recency_days), 2) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(signed_total_gbp), 2) AS avg_signed_total_gbp
FROM customer_rfm_segment
GROUP BY rfm_segment;