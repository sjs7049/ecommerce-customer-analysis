SELECT 
    invoice,
    invoice_date,
    description,
    customer_id,
    quantity,
    unit_price,
    quantity * unit_price AS line_amount
FROM transactions
WHERE stock_code = '23843'
ORDER BY invoice_date, invoice;

