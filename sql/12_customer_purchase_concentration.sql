WITH customer_line_amount_rank AS (
    SELECT 
        customer_id,
        SUM(line_amount) AS sales_gbp,
        ROW_NUMBER() OVER (ORDER BY SUM(line_amount) DESC, customer_id) AS rnk
    FROM customer_product_sales
    GROUP BY customer_id
),
cumulative_customer_total_line_amount AS (
    SELECT 
        customer_id,
        rnk,
        SUM(sales_gbp) OVER (
            ORDER BY rnk
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_sales_gbp
    FROM customer_line_amount_rank
)
SELECT 
    rnk AS top_n,
    ROUND(cumulative_sales_gbp, 2) AS top_purchase_amount_gbp,
    ROUND(
        100.0 * cumulative_sales_gbp / (SELECT SUM(line_amount) FROM customer_product_sales),
        2
    ) AS purchase_share_pct
FROM cumulative_customer_total_line_amount
WHERE rnk IN (5, 10, 20)
ORDER BY top_n;