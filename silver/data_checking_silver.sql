-- Check duplicae --> have duplicate
SELECT
    invoice_no,
    stock_code,
    descript,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country,
	COUNT(*)
FROM
    bronze.retail
GROUP BY
    invoice_no,
    stock_code,
    descript,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country
HAVING COUNT(*) !=1
-- Check quantity 
  --<= 0 -->there are < 0
SELECT 
	*
FROM 
	bronze.retail
WHERE quantity IS NULL OR quantity <= 0
-- Check unit_price 
  -- <=0 -->there are =0 and <0
SELECT 
	*
FROM 
	bronze.retail
WHERE unit_price IS NULL OR unit_price <= 0
  -- Check description of 0 unit_price
SELECT DISTINCT
	descript
FROM 
	bronze.retail
WHERE unit_price = 0
  -- Check description --> containing both product_name and description of product
