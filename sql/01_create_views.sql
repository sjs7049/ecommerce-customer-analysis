CREATE VIEW IF NOT EXISTS product_sales AS
SELECT 
    *,
    quantity * unit_price AS line_amount
FROM transactions
WHERE UPPER(TRIM(invoice)) NOT LIKE 'C%'
    AND quantity > 0
    AND unit_price > 0
    AND item_type = 'product';

CREATE VIEW IF NOT EXISTS customer_product_sales AS
SELECT *
FROM product_sales
WHERE customer_id IS NOT NULL
    AND TRIM(customer_id) <> '';