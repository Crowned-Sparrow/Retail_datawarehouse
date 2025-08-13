CREATE TABLE silver.products (
    product_key         VARCHAR(50),
    product_id          VARCHAR(50),
    product_group_id    VARCHAR(50),
    variant_id          VARCHAR(50),
    product_base_name   VARCHAR(50),
    variant_name        VARCHAR(50)
);

-- Bulk insert CSV 
BULK INSERT silver.products
FROM 'D:\AAA\Project\Data_warehouse\Online_retail\dim_products.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,             
    FIELDTERMINATOR = ',',   
    ROWTERMINATOR = '\n',     
    TABLOCK
);
