-- =====================================================
-- 04 - Gold layer
-- KPI view and date-range KPI stored procedure.
-- =====================================================

-- Gold Layer
-- view and stored procedure

IF OBJECT_ID('dbo.vw_KPI_Category_Year', 'V') IS NOT NULL
    DROP VIEW dbo.vw_KPI_Category_Year;
GO

CREATE VIEW dbo.vw_KPI_Category_Year AS
SELECT
    p.Category,
    d.CalendarYear,
    COUNT(DISTINCT f.OrderID)                        AS TotalOrders,
    SUM(f.Quantity)                                   AS TotalUnitsSold,
    SUM(f.Sales)                                     AS TotalSales,
    SUM(f.Profit)                                    AS TotalProfit,
    ROUND(100.0 * SUM(f.Profit) / SUM(f.Sales), 2)  AS ProfitMarginPct,
    ROUND(AVG(f.Discount), 3)                        AS AvgDiscount
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Product p ON f.ProductKey  = p.ProductKey
JOIN dbo.Dim_Date    d ON f.OrderDateKey = d.DateKey
GROUP BY p.Category, d.CalendarYear;
GO

-- STORED PROCEDURE
IF OBJECT_ID('dbo.sp_GetKPIByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetKPIByDateRange;
GO

CREATE PROCEDURE dbo.sp_GetKPIByDateRange
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @StartDate                                       AS PeriodStart,
        @EndDate                                         AS PeriodEnd,
        COUNT(DISTINCT f.OrderID)                        AS TotalOrders,
        COUNT(DISTINCT f.CustomerKey)                    AS TotalCustomers,
        SUM(f.Sales)                                     AS TotalSales,
        SUM(f.Profit)                                    AS TotalProfit,
        ROUND(100.0 * SUM(f.Profit) / SUM(f.Sales), 2)   AS ProfitMarginPct,
        ROUND(SUM(f.Sales) / COUNT(DISTINCT f.OrderID), 2) AS AvgOrderValue
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Date d ON f.OrderDateKey = d.DateKey
    WHERE d.FullDate BETWEEN @StartDate AND @EndDate;
END;
GO

