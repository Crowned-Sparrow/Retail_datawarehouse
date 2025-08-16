--Changes over time
SELECT
	YEAR(f.invoice_date)	AS order_date,
	MONTH(f.invoice_date)	AS order_month,
	COUNT(c.customer_key)	AS total_customer,
	COUNT(p.product_key)	AS total_product,
	SUM(f.quantity)			AS total_quantity,
	COUNT(f.invoice_no)		AS total_purchase
FROM gold.fact_stocking				f
LEFT JOIN gold.dim_customers		c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products			p
ON f.product_key = p.product_key
GROUP BY
	YEAR(f.invoice_date),
	MONTH(f.invoice_date)
ORDER BY
	YEAR(f.invoice_date),
	MONTH(f.invoice_date)
