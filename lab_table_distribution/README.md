# Readme
In this lab, you will learn how to design your table based on the specific application scenerio
- the amount of data you have and you will append in your datawarehouse in the forseable future
- what's the common queries BI team requested

You will need to perform the following subtask
- [x] Create Round-robin(default) distributed tables and examine its performance
- [x] Create Hash distributed tables
- [x] Create replicated tables
- [x] 比较`join`性能between fact and dimension tables





## Query Round-robin

Round-robin是default的distribution, 现在对做the query below

```sql
SELECT 
    [CustomerID],
    COUNT([CustomerID]) as COUNT
FROM 
    [dbo].[SalesFact]
GROUP BY [CustomerID]
ORDER BY [CustomerID]
```

由于rows是按照round-robin distributed在不同nodes上的，如果你在monitor hub in synapse 看一下，或者看下面的`xml`文件，看一看到有很多操作



```xml
<?xml version="1.0" encoding="utf-8"?>
<dsql_query number_nodes="1" number_distributions="60" number_distributions_per_node="60">
  <sql>SELECT [CustomerID], COUNT([CustomerID]) as COUNT FROM [dbo].[SalesFact]
GROUP BY [CustomerID]
ORDER BY [CustomerID]</sql>
  <dsql_operations total_cost="0.00288" total_number_operations="4">
    <dsql_operation operation_type="ON">
      <location permanent="false" distribution="Control" />
      <sql_operations>
        <sql_operation type="statement">CREATE TABLE [tempdb].[QTables].[QTable_6d45a0a97f5e44ffa75db226efacdea1] ([CustomerID] INT N$
      </sql_operations>
    </dsql_operation>
    <dsql_operation operation_type="PARTITION_MOVE">
      <operation_cost cost="0.00288" accumulative_cost="0.00288" average_rowsize="12" output_rows="1" GroupNumber="12" />
      <location distribution="AllDistributions" />
      <source_statement>SELECT [T1_1].[CustomerID] AS [CustomerID], [T1_1].[col] AS [col] FROM (SELECT COUNT_BIG(CAST ((0) AS INT)) A$
OPTION (MAXDOP 1, MIN_GRANT_PERCENT = [MIN_GRANT], DISTRIBUTED_MOVE(N''))</source_statement>
      <destination>Control</destination>
      <destination_table>[QTable_6d45a0a97f5e44ffa75db226efacdea1]</destination_table>
    </dsql_operation>
    <dsql_operation operation_type="RETURN">
      <location distribution="Control" />
      <select>SELECT [T1_1].[CustomerID] AS [CustomerID], [T1_1].[col] AS [col] FROM (SELECT CONVERT (INT, [T2_1].[col], 0) AS [col],$
OPTION (MAXDOP 1, MIN_GRANT_PERCENT = [MIN_GRANT])</select>
    </dsql_operation>
    <dsql_operation operation_type="ON">
      <location permanent="false" distribution="Control" />
      <sql_operations>
        <sql_operation type="statement">DROP TABLE [tempdb].[QTables].[QTable_6d45a0a97f5e44ffa75db226efacdea1]</sql_operation>
      </sql_operations>
```



## Create Hash distributed tables



```sql
-- Now we want to create a hash-distributed table and set the hash-based column as the Customer ID

CREATE TABLE [dbo].[SalesFact](
	[ProductID] [int] NOT NULL,
	[SalesOrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[OrderQty] [smallint] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[OrderDate] [datetime] NULL,
	[TaxAmt] [money] NULL
)
WITH  
(   
    DISTRIBUTION = HASH (CustomerID)
)
-- 用customerID作为hash value, allow speed-up for JOIN and GROUP BY operation with hash value (In this case, CustomerID)
```



你可以看一下，`QID6017.xml` 是记录monitor operation type的

```xml

<?xml version="1.0" encoding="utf-8"?>
<dsql_query number_nodes="1" number_distributions="60" number_distributions_per_node="60">
  <sql>SELECT [CustomerID], COUNT([CustomerID]) as COUNT FROM [dbo].[SalesFact]
GROUP BY [CustomerID]
ORDER BY [CustomerID]</sql>
  <dsql_operations total_cost="0" total_number_operations="1">
    <dsql_operation operation_type="RETURN">
      <location distribution="AllDistributions" />
      <select>SELECT [T1_1].[CustomerID] AS [CustomerID], [T1_1].[col] AS [col] FROM (SELECT COUNT(CAST ((0) AS INT)) AS [col], [T2_1$
OPTION (MAXDOP 1)</select>
    </dsql_operation>
  </dsql_operations>
</dsql_query>
      

```

`Total_number_of_operations = "1"`而且operation type只是return

## Create Replicated table

```sql
-- Lab - Creating Replicated Tables

-- Let's drop the existing table

DROP TABLE [dbo].[SalesFact]

-- Now we want to create a hash-distributed table and set the hash-based column as the Customer ID

CREATE TABLE [dbo].[SalesFact](
	[ProductID] [int] NOT NULL,
	[SalesOrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[OrderQty] [smallint] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[OrderDate] [datetime] NULL,
	[TaxAmt] [money] NULL
)
WITH  
(   
    DISTRIBUTION = REPLICATE
)

-- To see the distribution on the table
DBCC PDW_SHOWSPACEUSED('[dbo].[SalesFact]')

-- If you execute the below query
SELECT [CustomerID], COUNT([CustomerID]) as COUNT FROM [dbo].[SalesFact]
GROUP BY [CustomerID]
ORDER BY [CustomerID]
```

记住，never create replicate for fact type. 这个script只是告诉你怎么设置罢了。You usually use **hash distribution for fact table** while use replicated table for dimension tar, if you using star schema for dimensional modelling.



## 比较`Join`性能 in star schema

这个section, 你需要比较the efficiency of `join` operation between fact and dimension tables in order to understand the process of `data shuffling` and understand why it's so expensive.

| -     | fact table | dimension table | data shuffling? |      |
| ----- | ---------- | --------------- | --------------- | ---- |
| 实验1 | Hash       | Round-robin     | Yes             |      |
| 实验2 | Hash       | replicated      | No              |      |

The query command is shown below:

```sql
SELECT
		ft.[ProductID],
		pd.[ProductName]
FROM
		[dbo].[SalesFact] AS ft JOIN [dbo].[DimProduct] pd
ON ft.[ProductID] = pd.[ProductID]
```

