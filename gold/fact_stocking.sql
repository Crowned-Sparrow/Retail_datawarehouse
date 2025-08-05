CREATE OR ALTER VIEW gold.fact_stocking AS
SELECT
	invoice_no,
	invoice_date,
	cu.customer_key AS customer_key,
	pr.product_key	AS product_key,
	quantity,
	unit_price,
	unit_price*quantity AS cost
 FROM silver.retail main
 LEFT JOIN gold.dim_customers cu
 ON main.customer_id = cu.customer_id
 LEFT JOIN gold.dim_products pr
 ON main.stock_code = pr.product_id
