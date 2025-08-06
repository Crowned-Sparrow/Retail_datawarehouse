CREATE OR ALTER VIEW gold.dim_customers AS(
SELECT
	ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
	customer_id,
	country
FROM silver.retail
WHERE customer_id != 'n/a'
GROUP BY 
	customer_id,
	country
)
