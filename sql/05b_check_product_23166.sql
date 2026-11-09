SELECT 
    invoice,
    invoice_date,
    description,
    customer_id,
    quantity,
    unit_price,
    quantity * unit_price AS line_amount
FROM transactions
WHERE stock_code = '23166'
ORDER BY ABS(quantity * unit_price) DESC, invoice
LIMIT 20;

