WITH top_20_positive_amount_customer AS (
    SELECT customer_id
    FROM customer_product_sales
    GROUP BY customer_id
    ORDER BY SUM(line_amount) DESC, customer_id
    LIMIT 20
),
customer_negative AS (
    SELECT  
        customer_id,
        SUM(CASE WHEN quantity > 0 THEN quantity * unit_price ELSE 0 END) AS positive_amount_gbp,
        SUM(CASE WHEN quantity < 0 THEN quantity * unit_price ELSE 0 END) AS negative_amount_gbp,
        SUM(quantity * unit_price) AS signed_total_gbp
    FROM transactions
    WHERE item_type = 'product'
        AND unit_price > 0
        AND customer_id IS NOT NULL
        AND TRIM(customer_id) <> ''
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    ROUND(positive_amount_gbp, 2) AS positive_amount_gbp,
    ROUND(negative_amount_gbp, 2) AS negative_amount_gbp,
    ROUND(signed_total_gbp, 2) AS signed_total_gbp,
    ROUND(
        100.0 * ABS(negative_amount_gbp / NULLIF(positive_amount_gbp, 0)),
        2
    ) AS negative_to_positive_pct
FROM top_20_positive_amount_customer t
JOIN customer_negative c
    ON t.customer_id = c.customer_id
ORDER BY ABS(negative_amount_gbp) DESC, c.customer_id;
