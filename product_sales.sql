-- Total cost per product_name (would recommend for categories if possible)
SELECT 
CASE
	WHEN p.product_base_name ='none' THEN 'n/a'
	ELSE product_base_name
	END AS product_name,
    SUM(f.cost) AS total_cost,
	CONCAT(ROUND ( CAST(SUM(f.cost) AS FLOAT)*100 / SUM(SUM(f.cost)) OVER(),2),' %') AS percentage
FROM gold.fact_stocking f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_base_name

	