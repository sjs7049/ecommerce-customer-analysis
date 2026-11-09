-- WITH check_stock_code_23843 AS (
--     SELECT
--         stock_code,
--         ROUND(SUM(CASE WHEN quantity > 0 THEN quantity * unit_price ELSE 0 END), 2) AS positive_amount_gbp,
--         ROUND(SUM(CASE WHEN quantity < 0 THEN quantity * unit_price ELSE 0 END), 2) AS negative_amount_gbp,
--         ROUND(SUM(quantity * unit_price), 2) AS signed_total_gbp
--     FROM transactions
--     WHERE item_type = 'product'
--         and unit_price > 0
--     GROUP BY stock_code
--     ORDER BY stock_code
-- )
-- SELECT * FROM check_stock_code_23843 WHERE stock_code = '23843';

SELECT
    stock_code,
    ROUND(SUM(CASE WHEN quantity > 0 THEN quantity * unit_price ELSE 0 END), 2) AS positive_amount_gbp,
    ROUND(SUM(CASE WHEN quantity < 0 THEN quantity * unit_price ELSE 0 END), 2) AS negative_amount_gbp,
    ROUND(SUM(quantity * unit_price), 2) AS signed_total_gbp
FROM transactions
WHERE item_type = 'product'
    and unit_price > 0
GROUP BY stock_code
ORDER BY signed_total_gbp DESC, stock_code
LIMIT 20;