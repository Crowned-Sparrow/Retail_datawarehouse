IF OBJECT_ID('bronze.retail','U') IS NOT NULL
    DROP TABLE bronze.retail;
GO

CREATE TABLE bronze.retail (
	invoice_no   VARCHAR(50),
	stock_code   VARCHAR(50),
	descript     VARCHAR(255),
	quantity     INT,
	invoice_date DATETIME,
	unit_price   DECIMAL(10,2),
	customer_id  DECIMAL(10,0),
	country      VARCHAR(100)
);
GO
