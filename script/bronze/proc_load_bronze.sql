CREATE OR ALTER PROCEDURE bronze.load_bronze
    @file_path NVARCHAR(4000) = 'D:\AAA\Project\Data_warehouse\OnlineRetail.csv'
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    BEGIN TRY
        PRINT '>> Truncating bronze.retail';
        TRUNCATE TABLE bronze.retail;

        SET DATEFORMAT mdy;

        PRINT '>> Inserting into bronze.retail from: ' + @file_path;

        DECLARE @bulk_sql NVARCHAR(MAX) = '
            BULK INSERT bronze.retail
            FROM ''' + @file_path + '''
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''0x0a'',
                TABLOCK
            );
        ';

        EXEC sp_executesql @bulk_sql;

        PRINT '>> Truncating bronze.retail_cleaned';
        TRUNCATE TABLE bronze.retail_cleaned;

        PRINT '>> Inserting into bronze.retail_cleaned';

        WITH CTE_Duplicates AS (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY invoice_no, stock_code, UPPER(REPLACE(REPLACE(TRIM(descript), CHAR(13), ''), CHAR(10), '')), quantity, invoice_date, unit_price, customer_id, country
                       ORDER BY (SELECT NULL)
                   ) AS rn
            FROM bronze.retail
        )
        INSERT INTO bronze.retail_cleaned (
            invoice_no,
            stock_code,
            customer_id,
            quantity,
            unit_price,
            invoice_date,
            country,
            description
        )
        SELECT
            invoice_no,
            stock_code,
            customer_id,
            quantity,
            unit_price,
            invoice_date,
            country,
            REPLACE(REPLACE(TRIM(descript), CHAR(13), ''), CHAR(10), '') AS description
        FROM CTE_Duplicates
        WHERE rn = 1;

        PRINT '>> Load completed successfully.';
    END TRY
    BEGIN CATCH
        PRINT '========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '========================================';
    END CATCH
END;
