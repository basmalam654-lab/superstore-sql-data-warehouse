-- =====================================================
-- 01 - Database & Bronze layer
-- Creates the database, the raw staging table, and bulk-loads the CSV.
-- =====================================================

--Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Central_Superstore_DW')
BEGIN
    CREATE DATABASE Central_Superstore_DW;
END;
GO
USE Central_Superstore_DW;
GO
-- Bronze Layer
-- 1. Staging table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Staging_Superstore') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Staging_Superstore (
    RowID           INT             NOT NULL,
    OrderID         VARCHAR(20)     NOT NULL,
    OrderDate       DATE            NOT NULL,
    ShipDate        DATE            NOT NULL,
    ShipMode        VARCHAR(30)     NOT NULL,
    CustomerID      VARCHAR(20)     NOT NULL,
    CustomerName    VARCHAR(100)    NOT NULL,
    Segment         VARCHAR(30)     NOT NULL,
    Country         VARCHAR(50)     NOT NULL,
    City            VARCHAR(50)     NOT NULL,
    State           VARCHAR(50)     NOT NULL,
    PostalCode      VARCHAR(10)     NOT NULL,
    Region          VARCHAR(20)     NOT NULL,
    ProductID       VARCHAR(30)     NOT NULL,
    Category        VARCHAR(30)     NOT NULL,
    SubCategory     VARCHAR(30)     NOT NULL,
    ProductName     VARCHAR(255)    NOT NULL,
    Sales           DECIMAL(10,4)   NOT NULL,
    Quantity        INT             NOT NULL,
    Discount        DECIMAL(4,2)    NOT NULL,
    Profit          DECIMAL(10,4)   NOT NULL,
    CONSTRAINT pk_Staging_Superstore PRIMARY KEY (RowID)
);
END;
GO

TRUNCATE TABLE dbo.Staging_Superstore;
GO
BULK INSERT dbo.Staging_Superstore
FROM 'C:\path\to\Central_Superstore.csv'  -- <-- change to your local path (see data/README.md)
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO
