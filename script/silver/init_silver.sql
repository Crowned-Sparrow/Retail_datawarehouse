IF OBJECT_ID('silver.retail','U') IS NOT NULL
    DROP TABLE silver.retail;
GO
CREATE TABLE silver.retail (
	invoice_no	VARCHAR(50),
	stock_code	VARCHAR(50),
	product_name	VARCHAR(100),
	description	VARCHAR(50),
	customer_id	VARCHAR(50),
	quantity	INT,
	unit_price	DECIMAL(10,2),
	country		VARCHAR(50),
	invoice_date	DATETIME
)
