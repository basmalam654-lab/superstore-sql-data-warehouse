-- =====================================================
-- 02 - Silver layer: schema
-- Star schema: 5 dimensions + Fact_Sales.
-- =====================================================

-- Silver Layer
-- Step A: Schema Definition

-- Customer dimension
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Dim_Customer') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Dim_Customer (
    CustomerKey     INT IDENTITY(1,1)  PRIMARY KEY,
    CustomerID      VARCHAR(20)        NOT NULL UNIQUE,
    CustomerName    VARCHAR(100)       NOT NULL,
    Segment         VARCHAR(30)        NOT NULL
);
END;
GO

-- Product dimension
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Dim_Product') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Dim_Product (
    ProductKey      INT IDENTITY(1,1)  PRIMARY KEY,
    ProductID       VARCHAR(30)        NOT NULL,
    ProductName     VARCHAR(255)       NOT NULL,
    Category        VARCHAR(30)        NOT NULL,
    SubCategory     VARCHAR(30)        NOT NULL,
    CONSTRAINT uq_Dim_Product UNIQUE (ProductID, ProductName, Category, SubCategory)
);
END;
GO

-- Location dimension
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Dim_Location') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Dim_Location (
    LocationKey     INT IDENTITY(1,1)  PRIMARY KEY,
    City            VARCHAR(50)        NOT NULL,
    State           VARCHAR(50)        NOT NULL,
    PostalCode      VARCHAR(10)        NOT NULL,
    Region          VARCHAR(20)        NOT NULL,
    Country         VARCHAR(50)        NOT NULL,
    CONSTRAINT uq_Dim_Location UNIQUE (City, State, PostalCode, Region, Country)
);
END;
GO

-- Ship mode dimension
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Dim_ShipMode') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Dim_ShipMode (
    ShipModeKey     INT IDENTITY(1,1)  PRIMARY KEY,
    ShipMode        VARCHAR(30)        NOT NULL UNIQUE
);
END;
GO

-- Date dimension
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Dim_Date') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Dim_Date (
    DateKey             INT             PRIMARY KEY,
    FullDate            DATE            NOT NULL UNIQUE,
    DayNum              INT             NOT NULL,
    MonthNum            INT             NOT NULL,
    MonthName           VARCHAR(10)     NOT NULL,
    CalendarQuarter     INT             NOT NULL,
    CalendarYear        INT             NOT NULL
);
END;
GO

-- Fact table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Fact_Sales') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Fact_Sales (
    SalesKey        INT             PRIMARY KEY, 
    OrderID         VARCHAR(20)     NOT NULL,
    OrderDateKey    INT             NOT NULL,
    ShipDateKey     INT             NOT NULL,
    CustomerKey     INT             NOT NULL,
    ProductKey      INT             NOT NULL,
    LocationKey     INT             NOT NULL,
    ShipModeKey     INT             NOT NULL,
    Sales           DECIMAL(10,4)   NOT NULL,
    Quantity        INT             NOT NULL,
    Discount        DECIMAL(4,2)    NOT NULL,
    Profit          DECIMAL(10,4)   NOT NULL,
    CONSTRAINT fk_Fact_OrderDate FOREIGN KEY (OrderDateKey) REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT fk_Fact_ShipDate  FOREIGN KEY (ShipDateKey)  REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT fk_Fact_Customer  FOREIGN KEY (CustomerKey)  REFERENCES dbo.Dim_Customer(CustomerKey),
    CONSTRAINT fk_Fact_Product   FOREIGN KEY (ProductKey)   REFERENCES dbo.Dim_Product(ProductKey),
    CONSTRAINT fk_Fact_Location  FOREIGN KEY (LocationKey)  REFERENCES dbo.Dim_Location(LocationKey),
    CONSTRAINT fk_Fact_ShipMode  FOREIGN KEY (ShipModeKey)  REFERENCES dbo.Dim_ShipMode(ShipModeKey)
);
END;
GO

