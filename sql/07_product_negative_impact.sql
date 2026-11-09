WITH product_sales_with_negative AS (
    SELECT
        stock_code,
        SUM(CASE WHEN quantity > 0 THEN quantity * unit_price ELSE 0 END) AS positive_amount_gbp,
        SUM(CASE WHEN quantity < 0 THEN quantity * unit_price ELSE 0 END) AS negative_amount_gbp,
        SUM(quantity * unit_price) AS signed_total_gbp
    FROM transactions
    WHERE item_type = 'product'
        and unit_price > 0
    GROUP BY stock_code
    ORDER BY positive_amount_gbp DESC, stock_code
    LIMIT 20
)
SELECT 
    stock_code,
    ROUND(positive_amount_gbp, 2) AS positive_amount_gbp,
    ROUND(negative_amount_gbp, 2) AS negative_amount_gbp,
    ROUND(signed_total_gbp, 2) AS signed_total_gbp,
    ROUND(100.0 * (ABS(negative_amount_gbp) / NULLIF(positive_amount_gbp, 0)), 2) AS negative_to_positive_pct
FROM product_sales_with_negative
ORDER BY ABS(negative_amount_gbp) DESC, stock_code;
