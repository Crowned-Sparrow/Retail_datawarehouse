IF OBJECT_ID ('bronze.retail','U') IS NOT NULL
	DROP TABLE bronze.retail;

CREATE TABLE bronze.retail (
	invoice VARCHAR(20),
	stock_code VARCHAR(20),
	description NVARCHAR(100),
	quantity INT,
	inv_dt DATETIME2,
	price DECIMAL(10, 2),
	cus_id INT,
	cnty NVARCHAR(50)
)

BULK INSERT bronze.retail
FROM 'D:\AAA\Project\Data_warehouse\clean_retail.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
)
