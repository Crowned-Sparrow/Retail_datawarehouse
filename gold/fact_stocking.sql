CREATE OR ALTER VIEW gold.fact_stocking AS 
  SELECT
  	invoice_no,
  	invoice_date,
  	pr.product_key,
  	cu.customer_key AS customer_key,
  	quantity,
  	unit_price,
  	quantity* unit_price AS cost,
  	description
  FROM silver.retail main
  LEFT JOIN gold.dim_customers cu
  ON main.customer_id = main.customer_id
  LEFT JOIN gold.dim_products pr
  ON pr.product_id = main.stock_code
