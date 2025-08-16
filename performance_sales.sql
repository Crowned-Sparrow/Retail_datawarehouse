--Performace of products
SELECT 
    CONCAT(YEAR(invoice_date), '-Q', DATEPART(QUARTER, invoice_date)) AS period,
    COALESCE(p.product_base_name, 'n/a') AS product_name,
    SUM(f.cost) AS total_cost,
    ROUND(
        AVG(SUM(f.cost)) OVER (PARTITION BY p.product_base_name), 
        2
    ) AS avg_quarterly,
    SUM(f.cost) - AVG(SUM(f.cost)) OVER (PARTITION BY p.product_base_name) AS avg_diff,
    CASE 
        WHEN SUM(f.cost) > AVG(SUM(f.cost)) OVER (PARTITION BY p.product_base_name)
            THEN 'Above Avg'
        WHEN SUM(f.cost) < AVG(SUM(f.cost)) OVER (PARTITION BY p.product_base_name)
            THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
	CASE 
		WHEN LAG(SUM(f.cost)) OVER (PARTITION BY p.product_base_name ORDER BY YEAR(invoice_date),DATEPART(QUARTER, invoice_date)) IS NULL THEN 'First quarter'
		WHEN LAG(SUM(f.cost)) OVER (PARTITION BY p.product_base_name ORDER BY YEAR(invoice_date),DATEPART(QUARTER, invoice_date)) > SUM(f.cost) THEN 'Decreased'
		WHEN LAG(SUM(f.cost)) OVER (PARTITION BY p.product_base_name ORDER BY YEAR(invoice_date),DATEPART(QUARTER, invoice_date)) < SUM(f.cost) THEN 'Increased'
		ELSE 'Equal'
	END AS sale_performance
FROM gold.fact_stocking f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_base_name,
    YEAR(invoice_date),
    DATEPART(QUARTER, invoice_date)
ORDER BY
    product_name,
    period;
