-- =====================================================
-- 03 - Silver layer: load
-- Populates dimensions and fact table from staging (re-runnable).
-- =====================================================

-- Step B: Data Transformation & Population

-- 1. Dim_Customer
INSERT INTO dbo.Dim_Customer (CustomerID, CustomerName, Segment)
SELECT DISTINCT CustomerID, CustomerName, Segment
FROM dbo.Staging_Superstore s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Dim_Customer c WHERE c.CustomerID = s.CustomerID
);
GO
-- 2. Dim_Product
INSERT INTO dbo.Dim_Product (ProductID, ProductName, Category, SubCategory)
SELECT DISTINCT ProductID, ProductName, Category, SubCategory
FROM dbo.Staging_Superstore s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Dim_Product p 
    WHERE p.ProductID = s.ProductID 
      AND p.ProductName = s.ProductName 
      AND p.Category = s.Category 
      AND p.SubCategory = s.SubCategory
);
GO
-- 3. Dim_Location
INSERT INTO dbo.Dim_Location (City, State, PostalCode, Region, Country)
SELECT DISTINCT City, State, PostalCode, Region, Country
FROM dbo.Staging_Superstore s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Dim_Location l 
    WHERE l.City = s.City 
      AND l.State = s.State 
      AND l.PostalCode = s.PostalCode 
      AND l.Region = s.Region 
      AND l.Country = s.Country
);
GO
-- 4. Dim_ShipMode
INSERT INTO dbo.Dim_ShipMode (ShipMode)
SELECT DISTINCT ShipMode
FROM dbo.Staging_Superstore s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Dim_ShipMode sm WHERE sm.ShipMode = s.ShipMode
);
GO
-- 5. Dim_Date
INSERT INTO dbo.Dim_Date (DateKey, FullDate, DayNum, MonthNum, MonthName, CalendarQuarter, CalendarYear)
SELECT DISTINCT
    CAST(FORMAT(d, 'yyyyMMdd') AS INT)  AS DateKey,
    d                                   AS FullDate,
    DAY(d)                              AS DayNum,
    MONTH(d)                            AS MonthNum,
    DATENAME(MONTH, d)                  AS MonthName,
    DATEPART(QUARTER, d)                AS CalendarQuarter,
    YEAR(d)                             AS CalendarYear
FROM (
    SELECT OrderDate AS d FROM dbo.Staging_Superstore
    UNION
    SELECT ShipDate AS d FROM dbo.Staging_Superstore
) AS AllDates
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Dim_Date dt WHERE dt.DateKey = CAST(FORMAT(AllDates.d, 'yyyyMMdd') AS INT)
);
GO
-- 6. Fact_Sales (Mapping keys)
INSERT INTO dbo.Fact_Sales
    (SalesKey, OrderID, OrderDateKey, ShipDateKey, CustomerKey, ProductKey,
     LocationKey, ShipModeKey, Sales, Quantity, Discount, Profit)
SELECT
    s.RowID,
    s.OrderID,
    CAST(FORMAT(s.OrderDate, 'yyyyMMdd') AS INT),
    CAST(FORMAT(s.ShipDate, 'yyyyMMdd') AS INT),
    c.CustomerKey,
    p.ProductKey,
    l.LocationKey,
    sm.ShipModeKey,
    s.Sales,
    s.Quantity,
    s.Discount,
    s.Profit
FROM dbo.Staging_Superstore s
JOIN dbo.Dim_Customer  c  ON s.CustomerID = c.CustomerID
JOIN dbo.Dim_Product   p  ON s.ProductID = p.ProductID
                          AND s.ProductName = p.ProductName
                          AND s.Category = p.Category
                          AND s.SubCategory = p.SubCategory
JOIN dbo.Dim_Location  l  ON s.City = l.City
                          AND s.State = l.State
                          AND s.PostalCode = l.PostalCode
                          AND s.Region = l.Region
                          AND s.Country = l.Country
JOIN dbo.Dim_ShipMode  sm ON s.ShipMode = sm.ShipMode
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Fact_Sales f WHERE f.SalesKey = s.RowID
);
GO

