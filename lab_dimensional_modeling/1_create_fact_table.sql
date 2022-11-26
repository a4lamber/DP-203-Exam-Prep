/*
Lab: 创造一个FACT TABLE
Step 1 : first create a view
Step 2: create the Sales Fact table from the view
*/

-- Step 1: creata a view by centering two tables
CREATE VIEW [Sales_Fact_View]
AS
SELECT 
    sod.[ProductID],
    sod.[SalesOrderID],
    sod.[OrderQty],
    sod.[UnitPrice],
    soh.[OrderDate],
    soh.[CustomerID],
    soh.[TaxAmt]
FROM [Sales].[SalesOrderDetail] AS sod
LEFT JOIN [Sales].[SalesOrderHeader] AS soh
ON sod.[SalesOrderID] = soh.[SalesOrderID]

-- Step 2: Create table from view
SELECT
    a.[ProductID],
    a.SalesOrderID,
    a.OrderQty,
    a.UnitPrice,
    a.OrderDate,
    a.CustomerID,
    a.TaxAmt
Into
    SalesFact
FROM
    Sales_Fact_View AS a
