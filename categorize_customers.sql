WITH customer_metrics AS (
    SELECT
        c.customer_key,
        SUM(f.cost) AS total_spending,
        DATEDIFF(MONTH, MIN(f.invoice_Date), MAX(f.invoice_date)) AS lifespan
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_stocking f
        ON c.customer_key = f.customer_key
    GROUP BY
        c.customer_key
),
customer_segment_categorized AS (
    SELECT
        customer_key,
        total_spending,
        lifespan,
        CASE
            WHEN total_spending >= 50000 AND lifespan > 5 THEN 'VIP'
            WHEN total_spending <= 50000 AND lifespan > 5 THEN 'Regular'
            WHEN lifespan >= 3 AND lifespan < 5 THEN 'New'
            ELSE 'Browser'
        END AS customer_segment
    FROM customer_metrics
)
SELECT
    customer_segment,
    COUNT(customer_key) AS number_of_customers
FROM customer_segment_categorized
GROUP BY
    customer_segment
ORDER BY
    customer_segment;