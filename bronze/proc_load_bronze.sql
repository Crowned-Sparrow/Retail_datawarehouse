TRUNCATE bronze.retail;
SET DATEFORMAT mdy;

BULK INSERT bronze.retail
FROM 'D:\AAA\Project\Data_warehouse\OnlineRetail.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',  -- đã thử  '\n' '\r\n'
	TABLOCK
);
