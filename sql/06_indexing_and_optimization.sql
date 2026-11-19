-- =====================================================
-- 06 - Indexing & query optimization
-- Baseline IO -> create indexes -> re-measure IO.
-- =====================================================

-- Baseline (before indexes)

SET STATISTICS IO ON;
SELECT l.Region, p.Category, SUM(f.Sales) AS TotalSales
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Product  p ON f.ProductKey  = p.ProductKey
JOIN dbo.Dim_Location l ON f.LocationKey = l.LocationKey
GROUP BY l.Region, p.Category;
SET STATISTICS IO OFF;
GO
-- Indexing and query-optimization

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_FactSales_CustomerKey' AND object_id = OBJECT_ID('dbo.Fact_Sales'))
    EXEC('CREATE NONCLUSTERED INDEX ix_FactSales_CustomerKey ON dbo.Fact_Sales (CustomerKey);');

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_FactSales_ProductKey' AND object_id = OBJECT_ID('dbo.Fact_Sales'))
    EXEC('CREATE NONCLUSTERED INDEX ix_FactSales_ProductKey ON dbo.Fact_Sales (ProductKey);');

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_FactSales_LocationKey' AND object_id = OBJECT_ID('dbo.Fact_Sales'))
    EXEC('CREATE NONCLUSTERED INDEX ix_FactSales_LocationKey ON dbo.Fact_Sales (LocationKey);');

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_FactSales_ShipModeKey' AND object_id = OBJECT_ID('dbo.Fact_Sales'))
    EXEC('CREATE NONCLUSTERED INDEX ix_FactSales_ShipModeKey ON dbo.Fact_Sales (ShipModeKey);');

-- OrderDateKey is the most heavily used FK
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_FactSales_OrderDateKey' AND object_id = OBJECT_ID('dbo.Fact_Sales'))
    EXEC('CREATE NONCLUSTERED INDEX ix_FactSales_OrderDateKey ON dbo.Fact_Sales (OrderDateKey) INCLUDE (Sales, Profit, Quantity);');
GO

-- Confirm the optimizer (after)
SET STATISTICS IO ON;
SELECT l.Region, p.Category, SUM(f.Sales) AS TotalSales
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Product  p ON f.ProductKey  = p.ProductKey
JOIN dbo.Dim_Location l ON f.LocationKey = l.LocationKey
GROUP BY l.Region, p.Category;
SET STATISTICS IO OFF;
GO