# Data


Place `Central_Superstore.csv` (the Central-region extract of the Superstore orders data, 21 columns, header row) anywhere on the machine running SQL Server, then update the path in `sql/01_create_database_and_bronze.sql`:

```sql
BULK INSERT dbo.Staging_Superstore
FROM 'C:\path\to\Central_Superstore.csv'
```
