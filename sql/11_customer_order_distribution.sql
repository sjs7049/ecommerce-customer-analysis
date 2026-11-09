WITH count_customer_order AS (
    SELECT
        customer_id,
        CASE 
            WHEN COUNT(DISTINCT invoice) = 1 THEN '1' 
            WHEN COUNT(DISTINCT invoice) = 2 THEN '2'
            WHEN COUNT(DISTINCT invoice) >= 3 AND COUNT(DISTINCT invoice) <= 5 THEN '3-5'
            WHEN COUNT(DISTINCT invoice) >= 6 AND COUNT(DISTINCT invoice) <= 10 THEN '6-10'
            WHEN COUNT(DISTINCT invoice) >= 11 THEN '11+'
        END AS order_count_group
    FROM customer_product_sales
    GROUP BY customer_id
)
SELECT 
    order_count_group,
    COUNT(customer_id) AS customers,
    ROUND(
        100.0 * COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM customer_product_sales),
        2
    ) AS customer_share_pct
FROM count_customer_order
GROUP BY order_count_group
ORDER BY 
    CASE    
        WHEN order_count_group = '1' THEN 1
        WHEN order_count_group = '2' THEN 2
        WHEN order_count_group = '3-5' THEN 3
        WHEN order_count_group = '6-10' THEN 4
        WHEN order_count_group = '11+' THEN 5
    END