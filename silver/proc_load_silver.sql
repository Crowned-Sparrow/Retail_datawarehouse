CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
		PRINT'>> Truncating silver.retail';
		TRUNCATE TABLE silver.retail;
		PRINT'>> Inserting silver.retail';
WITH MAIN AS (
	SELECT 
		invoice_no, -- C stand for cancelation
		stock_code, -- Added on character of the end is product add on (ex: red table and blue table)
		CASE
			WHEN CHARINDEX('?', description) > 0 
				THEN 'n/a'
			WHEN description COLLATE Latin1_General_BIN = UPPER(description)
			AND description NOT LIKE '%ADJUST%'
			AND description NOT LIKE '%STOCK%'
			AND description NOT LIKE '%DAMAGED%'
			AND description NOT LIKE '%RETURN%'
			AND description NOT LIKE '%BROKEN%'
			AND description NOT LIKE '%CHECK%'
			AND description NOT LIKE '%DOTCOM%'
			AND description NOT LIKE '%ONLINE ORDER%'
				THEN TRIM(REPLACE(REPLACE(description, ';', ','), '"', ''))
			WHEN description COLLATE Latin1_General_BIN LIKE '%[0-9]%' 
				THEN TRIM(REPLACE(REPLACE(description, ';', ','), '"', ''))
			WHEN UPPER(description) COLLATE Latin1_General_BIN LIKE '%NO%'
				THEN TRIM(REPLACE(REPLACE(description, ';', ','), '"', ''))
		  ELSE 'n/a'
		END AS product_name,
		CASE
			-- 1. Null or blank
			WHEN description IS NULL OR TRIM(description) = '' THEN 'n/a'

			-- 2. Contains only a '?'
			WHEN CHARINDEX('?', description) = 1 AND LEN(description) = 1 THEN 'n/a'

			-- 3. Contains '?' with other characters
			WHEN CHARINDEX('?', description) > 0 THEN TRIM(REPLACE(description, '?', ''))

			-- 4. Specific known IDs or codes
			WHEN description LIKE '%20713%' THEN '20713'
			WHEN description LIKE '%84930%' THEN '84930'

			-- 5. Adjustments
			WHEN description LIKE '%adjust%' THEN 'adjustment'

			-- 6. Stock-related
			WHEN description LIKE '%stock%' THEN 'add stock'
			WHEN description LIKE '%found%' THEN 'available'
			WHEN description LIKE '%check%' THEN 'n/a'
			WHEN description LIKE '%put aside%' THEN 'put aside'

			-- 7. Damage and breakage
			WHEN description LIKE '%broken%' 
			   OR description LIKE '%breakage%' 
			   OR description LIKE '%crushed%' 
			   OR description LIKE '%damage%' 
			   OR description LIKE '%dagamed%' 
			   OR description LIKE '%cracked%' 
			   OR description LIKE '%smashed%' 
			   OR description LIKE '%wet%' 
			   OR description LIKE '%rusty%' 
			   OR description LIKE '%destroyed%' THEN 'damaged'

			-- 8. Online/digital sales
			WHEN description LIKE '%dotcom%' THEN 'dotcom sales'
			WHEN description LIKE '%amazone%' THEN 'amazone sales'
			WHEN description LIKE '%online order%' THEN 'online order'

			-- 9. Waste or removal
			WHEN description LIKE '%throw away%' THEN 'thrown away'

			-- 10. Fully uppercase and suspicious (system messages)
			WHEN description COLLATE Latin1_General_BIN NOT LIKE '%[a-z]%' THEN 'n/a'

			-- 11. Clean & return
			ELSE TRIM(REPLACE(REPLACE(description, ';', ','), '"', ''))
		END AS description,
		CASE 
			WHEN customer_id IS NULL THEN 'n/a'
			ELSE customer_id
		END AS customer_id,
		CASE 
			WHEN LEFT(invoice_no,1) ='C' 
			AND	quantity < 0 THEN quantity	-- cancelation has quantity < 0
			ELSE ABS(quantity)				-- other quantity < 0 treated as typing eror, turn into positive
		END AS quantity,
			unit_price,
		CASE
			WHEN UPPER(REPLACE(REPLACE(TRIM(country), CHAR(13), ''), CHAR(10), '')) = 'EIRE' THEN 'Ireland'
			WHEN UPPER(REPLACE(REPLACE(TRIM(country), CHAR(13), ''), CHAR(10), '')) = 'EUROPEAN COMMUNITY' THEN 'Europe'
			WHEN UPPER(REPLACE(REPLACE(TRIM(country), CHAR(13), ''), CHAR(10), '')) = 'CHANNEL ISLANDS' THEN 'United Kingdom'
			WHEN UPPER(REPLACE(REPLACE(TRIM(country), CHAR(13), ''), CHAR(10), '')) = 'RSA' THEN 'Republic of South Africa'
			WHEN UPPER(REPLACE(REPLACE(TRIM(country), CHAR(13), ''), CHAR(10), '')) = 'USA' THEN 'United States'
			ELSE TRIM(REPLACE(REPLACE(country, CHAR(13), ''), CHAR(10), ''))
		END AS country,
		CASE
			WHEN invoice_date > GETDATE() THEN 'NULL'
			ELSE invoice_date
		END AS invoice_date
		FROM bronze.retail_cleaned
),
marked_stock_to_product AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY stock_code
               ORDER BY product_name DESC -- or something else meaningful // i do this bcs UPPERCASE LETTER always top n/a
           ) AS rn
    FROM MAIN
),
stock_to_product AS (
    SELECT
        stock_code,
        product_name
    FROM marked_stock_to_product
    WHERE rn = 1
)
INSERT INTO silver.retail (
			invoice_no	,
			stock_code	,
			product_name,	
			description	,
			customer_id	,
			quantity	,
			unit_price	,
			country		,
			invoice_date	
		)
SELECT
    invoice_no,
    MAIN.stock_code,
    stock_to_product.product_name,
    description,
    customer_id,
    quantity,
    unit_price,
    country,
    invoice_date
FROM MAIN
LEFT JOIN stock_to_product
    ON stock_to_product.stock_code = MAIN.stock_code
END TRY

	BEGIN CATCH
        PRINT '========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '========================================';
    END CATCH
END
