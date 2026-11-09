WITH line_amount_rank AS (
    SELECT 
        stock_code,
        SUM(line_amount) AS sales_gbp,
        ROW_NUMBER() OVER (ORDER BY SUM(line_amount) DESC, stock_code) AS rnk
    FROM product_sales
    GROUP BY stock_code
),
cumulative_total_line_amount AS (
    SELECT 
        stock_code,
        rnk,
        SUM(sales_gbp) OVER (
            ORDER BY rnk
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_sales_gbp
    FROM line_amount_rank
)
SELECT 
    rnk AS top_n,
    ROUND(cumulative_sales_gbp, 2) AS top_sales_gbp,
    ROUND(
        100.0 * (cumulative_sales_gbp / (SELECT SUM(line_amount) FROM product_sales)),
        2
    ) AS sales_share_pct
FROM cumulative_total_line_amount
WHERE rnk IN (5, 10, 20)
ORDER BY top_n;