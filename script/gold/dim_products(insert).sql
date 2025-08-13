DROP VIEW IF EXISTS gold.dim_products;
DROP TABLE IF EXISTS temp_dim_products;

-- Create the temp table
CREATE TABLE temp_dim_products (
    product_key         VARCHAR(50),
    product_id          VARCHAR(50),
    product_group_id    VARCHAR(50),
    variant_id          VARCHAR(50),
    product_base_name   VARCHAR(50),
    variant_name        VARCHAR(50)
);

-- Bulk insert CSV 
BULK INSERT dbo.temp_dim_products
FROM 'D:\AAA\Project\Data_warehouse\Online_retail\dim_products.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,             
    FIELDTERMINATOR = ',',   
    ROWTERMINATOR = '\n',     
    TABLOCK
);

-- Create view in gold schema
CREATE VIEW gold.dim_products AS
SELECT *
FROM dbo.temp_dim_products;

-- Drop temp table
DROP TABLE dbo.temp_dim_products
