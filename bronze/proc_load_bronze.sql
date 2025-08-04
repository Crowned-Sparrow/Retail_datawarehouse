CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
		PRINT '>> Truncating bronze.retail'
		TRUNCATE TABLE bronze.retail;
		SET DATEFORMAT mdy;

		PRINT '>> Inserting bronze.retail'

		BULK INSERT bronze.retail
		FROM 'D:\AAA\Project\Data_warehouse\OnlineRetail.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',  -- đã thử  '\n' '\r\n'
			TABLOCK
		)
	END TRY
	BEGIN CATCH
		PRINT	'========================================'
		PRINT	'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT	'Error Message' + ERROR_MESSAGE();
		PRINT	'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT	'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT	'========================================'
	END CATCH
END
