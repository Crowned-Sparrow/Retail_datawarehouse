CREATE OR ALTER VIEW gold.dim_product AS(
SELECT
	ROW_NUMBER() OVER (ORDER BY stock_code) AS product_key,
	stock_code AS base_id,
	product_name,

	LEFT(stock_code,5) AS product_group_id,
CASE 
	WHEN LEN(stock_code) > 5
		THEN SUBSTRING(stock_code,6,LEN(stock_code)) 
		ELSE 'none'
	END AS  varient
FROM silver.retail
GROUP BY 
stock_code,
LEFT(stock_code,5),
product_name,
SUBSTRING(stock_code,6,LEN(stock_code))
)
