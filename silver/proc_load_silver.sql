WITH CTE_Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY invoice_no, stock_code, descript, quantity, invoice_date, unit_price, customer_id, country
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM bronze.retail
),
CTE_Cleaned AS (
    SELECT 
        invoice_no,
        stock_code,
        CASE
            WHEN quantity <= 0 THEN ABS(quantity)
            ELSE quantity
        END AS quantity,
        CASE
            WHEN invoice_date > GETDATE() THEN NULL
            ELSE invoice_date
        END AS invoice_date,
        CASE
            WHEN unit_price <= 0 THEN ABS(unit_price)
            ELSE unit_price
        END AS unit_price,
        CASE
            WHEN CHARINDEX('?', descript) > 0 AND LEN(descript) != CHARINDEX('?', descript) THEN TRIM(REPLACE(descript, '?', ''))
            WHEN CHARINDEX('?', descript) > 0 AND LEN(descript) = CHARINDEX('?', descript) THEN NULL
            WHEN CHARINDEX('20713', descript) > 0 THEN '20713'
            WHEN CHARINDEX('adjust', descript) > 0 THEN 'adjustment'
            WHEN TRIM(descript) = '' THEN NULL 
            WHEN CHARINDEX('stock', descript) > 0 THEN 'add stock'
            WHEN CHARINDEX('AMAZONE', TRIM(UPPER(descript))) > 0 THEN 'amazone sales'
            WHEN CHARINDEX('BROKEN', TRIM(UPPER(descript))) > 0 
              OR CHARINDEX('BREAKAGE', TRIM(UPPER(descript))) > 0
              OR CHARINDEX('CRUSHED', TRIM(UPPER(descript))) > 0
              OR CHARINDEX('DAMAGE', TRIM(UPPER(descript))) > 0
              OR CHARINDEX('DAGAMED', TRIM(UPPER(descript))) > 0
              OR CHARINDEX('CRACKED', TRIM(UPPER(descript))) > 0
              OR CHARINDEX('SMASHED', TRIM(UPPER(descript))) > 0
              OR CHARINDEX('WET', TRIM(UPPER(descript))) > 0
              OR CHARINDEX('RUSTY', TRIM(UPPER(descript))) > 0
			  OR CHARINDEX('DESTROYED', TRIM(UPPER(descript))) > 0
              THEN 'Damaged'
            WHEN CHARINDEX('DOTCOM', TRIM(UPPER(descript))) > 0 THEN 'dotcom sales'
            WHEN CHARINDEX('FOUND', TRIM(UPPER(descript))) > 0 THEN 'available'
            WHEN CHARINDEX('CHECK', TRIM(UPPER(descript))) > 0 THEN NULL
            WHEN CHARINDEX('84930', TRIM(UPPER(descript))) > 0 THEN '84930'
            WHEN CHARINDEX('ONLINE ORDER', TRIM(UPPER(descript))) > 0 THEN 'online order'
            WHEN CHARINDEX('PUT ASIDE', TRIM(UPPER(descript))) > 0 THEN 'put aside'
            WHEN CHARINDEX('THROW AWAY', TRIM(UPPER(descript))) > 0 THEN 'thrown away'
            ELSE TRIM(REPLACE(REPLACE(descript, ';', ','), '"', ''))
        END AS description
    FROM CTE_Duplicates
    WHERE rn = 1
)
SELECT *
FROM CTE_Cleaned
WHERE description IS NOT NULL
	AND unit_price = 0
ORDER BY quantity DESC;
