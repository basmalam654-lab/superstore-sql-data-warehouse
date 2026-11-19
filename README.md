# Superstore Sales Data Warehouse (SQL Server)

A star-schema data warehouse for the Central-region Superstore orders, built in T-SQL with a **Bronze → Silver → Gold** layered design, followed by 15 analytical queries and an indexing/optimization step.

**Tools:** SQL Server · T-SQL (views, stored procedures, CTEs, window functions)

## Architecture

| Layer | Purpose | Objects |
|---|---|---|
| **Bronze** | Raw load of the CSV | `Staging_Superstore` |
| **Silver** | Cleaned, modelled star schema | `Fact_Sales`, `Dim_Customer`, `Dim_Product`, `Dim_Location`, `Dim_ShipMode`, `Dim_Date` |
| **Gold** | Business-ready KPIs | `vw_KPI_Category_Year`, `sp_GetKPIByDateRange` |

All create/load scripts are re-runnable (`IF NOT EXISTS` guards).

## Run order

Run the scripts in `sql/` in order (SQL Server Management Studio or Azure Data Studio):

| # | Script | What it does |
|---|---|---|
| 1 | `01_create_database_and_bronze.sql` | Creates the database and staging table, bulk-loads the CSV (update the file path first) |
| 2 | `02_silver_schema.sql` | Creates the dimension and fact tables |
| 3 | `03_silver_load.sql` | Populates dimensions and fact from staging |
| 4 | `04_gold_views_and_procedures.sql` | KPI view and stored procedure |
| 5 | `05_analysis_queries.sql` | 15 analysis queries with observations and insights |
| 6 | `06_indexing_and_optimization.sql` | Baseline IO, create indexes, re-measure |

Dataset instructions: [`data/README.md`](data/README.md).

## SQL skills demonstrated

- **Joins:** inner joins across the full star schema
- **Subqueries:** non-correlated, correlated, derived table, scalar
- **CTEs:** chained CTEs for monthly ranking and customer spend
- **Window functions:** `RANK()`, `LAG()` for month-over-month growth
- **Conditional logic:** `CASE` for profit tiers and customer types
- **Performance:** nonclustered indexes on fact foreign keys, with `SET STATISTICS IO` before/after comparison

## Analysis questions

| Area | Queries |
|---|---|
| Joins | Q1-Q3: full-star join, sales/profit by region and category, profitability tiers |
| Subqueries | Q4-Q7: above-average sales lines, customers above segment-average profit, top 5 products, orders per customer |
| CTEs | Q8-Q9: top months by sales, top 10 customers |
| Business analytics | Q10-Q15: margin by sub-category, discount vs loss, one-time vs repeat customers, segment AOV, yearly trend, MoM growth |

## Selected findings (from the author's run)

- Furniture has comparable revenue to Technology but is loss-making in this region: 317 loss-making order lines vs 113 healthy ones.
- Seven sub-categories are loss-making, including Furnishings, Appliances, Tables and Bookcases.
- 284 of 629 customers (about 45%) bought only once.
- Consumer is the largest segment by total sales; Corporate orders are worth more per order.

Each query in `05_analysis_queries.sql` has its own Observation/Insight comment.

## Files

```
superstore-sql-data-warehouse/
├── sql/
│   ├── 01_create_database_and_bronze.sql
│   ├── 02_silver_schema.sql
│   ├── 03_silver_load.sql
│   ├── 04_gold_views_and_procedures.sql
│   ├── 05_analysis_queries.sql
│   └── 06_indexing_and_optimization.sql
└── data/            # dataset
```
