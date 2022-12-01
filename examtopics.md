# Practice questions on exam topics

247题 in total; 10 topics



To-do out of 48 pages

- Page (2/48), 第10题 (10/247)  (2022/11/29)
- Page (5/48), 第10题 (25/247)  (2022/11/30)

[toc]





## Topic 1: Question Set 1



- 1: C
  - `smallint` in sql ony supports up to 32767, 所以排除掉

- 2: A

- 3: `SalesFact` table 需要删掉older than 36 months的stale data, as quickly as possible.你的任务是将它保存为一个只有三个步骤的常规stored procedure:
  - Create an empty table named `SalesFact_Work` that has the same schema as `SalesFact`
  - Switch the partition containing the stale data from `SalesFact` to `SalesFact_Work`
  - Drop the `SalesFact_Work` table
  - 笔记: datawarehouse中清理stale data的`DELETE` operation, 由于数据量PB，太大了，做row filtering super expensive, 所以一般是按照某个key对table进行PARTITIONING, 之后统一删除; 
- 4: T-SQL query, 如果你用Azure synapse的serverless SL pool, 定义external table的路径为`LOCATION = '/topfolder'`
  - [Synapse SQL CREATE EXTERNAL TABLE](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables?tabs=hadoop#arguments-create-external-table) 和[T-SQL](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-external-table-transact-sql?view=sql-server-ver15&tabs=dedicated#location--folder_or_filepath) 两个documentation有些不一样啊，主要分歧点在于会不会recursively return. 但可以统一的是无论T-SQL, Synapse SQL中create hadoop or native external table的路径，都会忽略隐藏文件和文件夹begins with a `_` or a perios `.` such as `/.hiddenfolder/` and `_hidden.txt` 
  - 在serverless SQL pool中create external table, 要分类讨论
    - `LOCATION = '/topfolder'` and native external table 则正常return
    - `LOCATION = '/topfolder/**'` and native external table 则recursively return
    - `LOCATION = '/topfolder'` and haoop external table 则recursivey return

![](https://www.examtopics.com/assets/media/exam-media/04259/0002000001.png)

- 5: 
  - for report 1, `Parquet`: column-oriented binary file
  - for report 2, `Avro`: row based format,and also has logical timestamp support

>  小知识: 还有`TSV` FORMAT for table separated value. 

- 6: 设计folder structure for an ADLS Gen2 container
  - 设计需求:
    - User query data from Azure DB and Synapse serverless SQL pool
    - Most queries will include data from the **current year** or **current month**
    - data will be secured by subject area
  - Answer: D `/{SubjectArea}/{DataSource}/{YYYY}/{MM}/{DD}/{FileData}_{YYYY}_{MM}_{DD}.csv`
  - 分析:
    - 为了减少以后随着时间增加的subfolders数量, 同时方便grant security for permission
    - 学习[Azure ADLS Gen 2的best practice](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-best-practices#batch-jobs-structure)
- 7: 
  - Columnar format: Parquet
  - JSON with a timestamp: Avro

![](https://www.examtopics.com/assets/media/exam-media/04259/0002500001.png)

- 8:

  - ADF 的copy activity来把分公司的数据 (10 small json files, same data attributes)ingest ADLS Gen2去, 设计需求是:
    - Provide the fastest possible query times
    - Automatically infer the schema from the underlying files

  

  ![](https://www.examtopics.com/assets/media/exam-media/04259/0002800001.png)

  - 答案Merge files, parquet (10个小文件，且数据格式相同，直接merge吧)

- 9: 一道考table distribution的题目，几个条件:

  - fact table 6TB, dimension tables < 2GB after compression,
  - dimension tables will be relatively static with very few data inserts and updates

  ![](https://www.examtopics.com/assets/media/exam-media/04259/0003000001.png)



答案:

| Table name         | distribution | Note |
| ------------------ | ------------ | ---- |
| Dim_customer       | Replicate    |      |
| Dim_employee       | replicate    |      |
| Dim_Time           | replicate    |      |
| Fact_Dailybookings | Hash         |      |

- Note:
  - `Fact`: Use hash-distribution with clustered columnstore index. Performance improves when two hash tables are joined on the same distribution column.
  - `Dimension`: Use replicated for smaller tables. If tables are too large to store on each Compute node, use hash-distributed.
  - `Staging`: 记得synapse中做load, 需要一个staging table吗? Use round-robin for the staging table. The load with CTAS is fast. Once the data is in the staging table, use INSERT...SELECT to move the data to production tables.

| **Table category** | **Recommended distribution option**                          |
| :----------------- | :----------------------------------------------------------- |
| Fact               | Use hash-distribution with clustered columnstore index. Performance improves when two hash tables are joined on the same distribution column. |
| Dimension          | Use replicated for smaller tables. If tables are too large to store on each Compute node, use hash-distributed. |
| Staging            | Use round-robin for the staging table. The load with CTAS is fast. Once the data is in the staging table, use INSERT...SELECT to move the data to production tables.<br/>synapse中做load, 需要一个staging table, ETL 常见操作 |

- 10: ADLS Gen 2 access tier类型问题, 几个需求, 这题比较简单了
  - 答案:
    - 5-years old: cool
    - 7-year old: archive (need rejuvenate)

- 11: 设计data warehouse题, 熟悉下syntax就行
  - `PARTITION ( partition_column_name RANGE [ LEFT | RIGHT ] FOR VALUES ( [ boundary_value [,...n] ] ))`
  - `DISTRIBUTION = HASH ( distribution_column_name )`

```sql
CREATE TABLE table1
(
  ID INTEGER,
  col1 VARCHAR(10),
  col2 VARCHAR(10)
)WITH
(
  DISTRIBUTION = HASH(ID),
  PARTITION (ID RANGE LEFT FOR VALUES (1,1000000,2000000))
);
```

- 12: design Synapse dedicated SQL pool with following requirements, 考点主要是**slowly changing table** 
  - Can return an employee record from a given point in time
  - Maintains the latest employee information
  - Minimizes query complexity
  - 问，how should you model the employee data?
  - 这一题udemy稍微接触过一点, alan描述了三种data warehouse的dimension changes. MS learn you module可以复习这一块 [here](https://learn.microsoft.com/en-us/training/modules/populate-slowly-changing-dimensions-azure-synapse-analytics-pipelines/). 
- ❤️13: ADLS 和synapse pool. 有一组sales team要access sql pool中的数据
  - [Securely load data using Synapse](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/quickstart-bulk-load-copy-tsql-examples)
- ❤️14: data masking问题,  masking function和其效果, user 1 the only one have access to unmasked data.
  - `default()`
  - `email()` 
  - 答案:
    - user 2 queies, will see--------- 0
    - user1 queries ---------------the values in the database

  - 学习:
    - [dynamic data masking in Azure](https://learn.microsoft.com/en-us/azure/azure-sql/database/dynamic-data-masking-overview?view=azuresql)


- 15: create external table问题, 你在synapse里创造了一个external table by query parquet files stored in ADLS Gen2, 你的external table有三行，但他却有4行，你该咋办?

  ```sql
  DROP EXTERNAL TABLE [Ext].[Items]
  CREATE EXTERNAL TABLE [Ext].[Items]
  ([ItemID] [int] NULL,
   [ItemName] nvarchar(50) NULL,
   [ItemType] nvarchar(20) NULL,
   [ItemDescription] nvarchar(250)
  )
  WITH
  (
    LOCATION= `/Items/`.
    DATA_SOURCE = AzureDataLakeStore,
    File_FORMAT = PARQUET,
    REJECT_TYPE = VALUE,
    REJUST_VALUE = 0
  );
  ```

- 16: Azure DF copy数据between two storage account问题,  有以下需求

  -  数据类型Apache Parquet
  - folder structure is preserved
  - 答案:
    - parquet for source data type, PreserveHierarchy for Copy behavior
  - Note:
    - 比较值得学习的是，如果选择binary type, copy速度会提升 

- 17: Azure geo-redundant问题

  - [Azure storage redundancy](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy#geo-redundant-storage)
  - 答案: RA-GRS

- ❤️18: GRS


  - region redundancy:

    - Locally redundant storage (LRS)
    - Zone-redundant storage (ZRS)

  - Geo redundancy

    - geo-redundant storage (GRS) : data in seconday region is only available if fail over.
    - Geo-zone-redundant storage (GZRS): data in seconday region is only available if fail over.
    - Read-access geo redundant storage (RA-GRS)
    - Read-access geo-zone redundant storage (RA-GZRS)

- 19: Load data from Azure blob storage to SQL pool in Synapse. 怎么设计staging table to minimize how long it takes to load the data to the staging table. 


  - 条件: 

    - The table will be truncated before each daily load.
    - minimize how long it takes to load to the staging table
    - daily 1 million rows of data

  - 答案:

    - round-robin distribution
    - Heap
    - None

  - [复习怎么设计](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-tables-distribute)

-  ❤️20: 设计fact table in dedicate SQL pool, 数据库条件如下，如何设计数据库可以minimize query times


  - 1 millions rows will be added per day
  - contain three years of data

  - 日常执行的sql query如下

  ```sql
  SELECT
  		SupplierKey,
  		StockItemKey,
  		IsOrderFinalized,
  		Count(*)
  FROM
  		Factpurchase
  WHERE DateKey >= 20210101 AND DateKey <= 20210131
  GROUP BY SupplierKey, StockItemKey, IsOrderFinalized
  ```


  - 答案:

    - A: replicated

    - B: hash-distributed on PurchaseKey

    - C: Round-robin

    - D: hash-distributed on isOrderFinalized

    - 我选了D, 是❌, 正确答案是B

    - 我错误的逻辑是IsOrderFinalized在`group by` 里，而hash 可以提速hash value所在的`group by`和`join`. 但实际上，你选择hash value, 那个值不能result太多太少distribution (high cardinality: columns with values that are very unique), 不然就没意义了, 因为**IsOrderFinalized** 是boolean, 就分了两堆很没意义.

    - 所以正确答案是B 

  - Note: [Read here for database cardinality](https://dzone.com/articles/what-is-high-cardinality)

- ❤️21: Star schema, dimension table设计问题, 讨论方案设计4个table方便querying, 你所有的数据schema如下，你咋设计?


  - 设计的table分别是

    - FactEvents
    - DimEvent
    - DimDate
    - DimChannel


  | Name              | Sample data         |
  | ----------------- | ------------------- |
  | Date              | 15 Jan 2021         |
  | EventCategory     | Videos              |
  | EventAction       | Play                |
  | EventLabel        | Contoso Promotional |
  | ChannelGrouping   | Social              |
  | TotalEvents       | 150                 |
  | UniqueEvents      | 120                 |
  | SessionWithEvents | 99                  |


  - 将下面features放在, 我的答案中:

    - EventCategory: DimEvent
    - ChannelGrouping: DimChannel
    - TotalEvents: DimEvent❌ 应该放到FactEvent中去

  - 复习: [Understand star schema and the importance for Power BI](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema)


- ❤️22: 是非题:
  - 100GB files need to be copied dfrom azure storage to enterprise data warehouse in Synapse. File contain rows of text and numerical values, 75% of the rows contain description data that has an average length of 1.1MB.
  - Does convert data to compressed delimited text files meet to goal of copying quickly?
  - 答案: No  ❌
    - 答案为Yes yes
  - Note: [Increasing PolyBase Row width limitation in Azure SQL DataWarehouse](https://azure.microsoft.com/en-gb/blog/increasing-polybase-row-width-limitation-in-azure-sql-data-warehouse/)

- 23: 是非题
  - 问你copy the file to a table that has a colunstore index能不能提速?
  - 答案与分析: 不能，它的意思就是staging table, 要用heap index with Round-robin distribution for speed
- 24: 是非题 ：
  - You specify the files to ensure that each row is more than 1MB. Does this meet the goal of copying quickly?
  - 答案: 不能, 
  - 分析:
    - 因为PolyBase can't load rows that have more than 1,000,000 bytes of data (1MB 是限制). When you put data into the text files in Azure Blob storage or Azure Data Lake Store, they must have fewer than 1,000,000 bytes of data. This byte limitation is true regardless of the table schema. 每行数据量别超过这个数
- ❤️25: query performance tuning 的问题
  - 知识: dedicated SQL pool有两种features for performance tuning for queries
    - `cached result`: result set caching is used for getting high concurrency and fast response from repetitive queries against static data.
    - `Materialized views` : allow data changes in the base tables. Data in materialized views can be applied to a piece of query. This support allows the same materialized views to be used by different queries that share some computation for faster performance.
  - 答案B, materialzed view, [看这里](https://techdifferences.com/difference-between-view-and-materialized-view.html) and [SQL View on SQLShack](https://www.sqlshack.com/sql-view-a-complete-introduction-and-walk-through/)

![](https://techdifferences.com/wp-content/uploads/2016/12/View-Vs-Materialized-View.jpg)

| BASIS FOR COMPARISON |                             VIEW                             |                      MATERIALIZED VIEW                       |
| :------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|        Basic         |       A View is **never stored it is only displayed**.       |          A Materialized View is stored on the disk.          |
|        Define        | View is the virtual table formed from one or more base tables or views. | Materialized view is a **physical copy of the base table**.  |
|        Update        | View is updated each time the virtual table (View) is used.  | Materialized View has to be updated manually or using triggers. |
|        Speed         |                       Slow processing.                       |                       Fast processing.                       |
|     Memory usage     |              View do not require memory space.               |           Materialized View utilizes memory space.           |
|        Syntax        |                      `Create View V As`                      | `Create Materialized View V Build [clause] Refresh [clause] On [Trigger] As` |

总之:

- VIEW就是把复杂SQL代码储存下来，你直接跑就行了，不占内存，你每次run这个view, 都需要compute your pre-stored query
- Materialized view就是physical copy of your base data。 A materialized view persists the data returned from the view definition query and automatically gets upadted as data changes in the underlying table.[Create materialzed view in T-SQL aooly to Synapse](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-materialized-view-as-select-transact-sql?view=azure-sqldw-latest)













## Dynamic time masking

- Dynamic time masking支持:
  - Azure SQL database
  - Azure SQL Managed instance
  - Azure Synapse Analytics
- Dynamic data masking policy
  - **SQL users excluded from masking**
    - Azure AD identities; admin privilege (数据库中的天龙人)
- Masking functions

| Masking function | Masking logic                                                |
| ---------------- | ------------------------------------------------------------ |
| Default          | Full masking according to the data types of the desginated fields. 见下图 |
| Credit card      | `XXXX-XXXX-XXXX-1234`                                        |
| Email            | expose first letter and replace the domain with `X` example `aXX@XXXX.com` |
| Random number    | generate a random number based on the range you specify      |
| Custom text      |                                                              |

见下面 for default

| data type                                | Effect                                                       |
| ---------------------------------------- | ------------------------------------------------------------ |
| nchar, ntext, nvarchar                   | XXXX or fewer Xs if the size of the field < 4 characters for any string type |
| Int, money, decimal, float等一切数字相关 | User a zero for numeric data types                           |
| data time types                          | `01-01-1900`                                                 |
| for XML the document                     | `<masked/>`                                                  |
|                                          |                                                              |
|                                          |                                                              |
|                                          |                                                              |



## Best practices for loading data into a dedicated SQL pool in Synapse

- 复习资料看[here](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/data-loading-best-practices)
- 





## Materialized view for performance tuning

### Case A

 This example shows how Synapse SQL optimizer automatically uses materialized views to execute a query for better performance even when the query uses functions unsupported in CREATE MATERIALIZED VIEW, such as `COUNT(DISTINCT expression)`. A query used to take multiple seconds to complete now finishes in sub-second without any change in the user query.

```sql
-- Create a table with ~536 million rows
create table t(a int not null, b int not null, c int not null) with (distribution=hash(a), clustered columnstore index);

insert into t values(1,1,1);

declare @p int =1;
while (@P < 30)
    begin
    insert into t select a+1,b+2,c+3 from t;  
    select @p +=1;
end

-- A SELECT query with COUNT_BIG (DISTINCT expression) took multiple seconds to complete and it reads data directly from the base table a. 
select a, count_big(distinct b) from t group by a;

-- Create two materialized views, not using COUNT_BIG(DISTINCT expression).
create materialized view V1 with(distribution=hash(a)) as select a, b from dbo.t group by a, b;

-- Clear all cache.

DBCC DROPCLEANBUFFERS;
DBCC freeproccache;

-- Check the estimated execution plan in SQL Server Management Studio.  It shows the SELECT query is first step (GET operator) is to read data from the materialized view V1, not from base table a.
select a, count_big(distinct b) from t group by a;

-- Now execute this SELECT query.  This time it took sub-second to complete because Synapse SQL engine automatically matches the query with materialized view V1 and uses it for faster query execution.  There was no change in the user query.

DECLARE @timerstart datetime2, @timerend datetime2;
SET @timerstart = sysdatetime();

select a, count_big(distinct b) from t group by a;

SET @timerend = sysdatetime()
select DATEDIFF(ms,@timerstart,@timerend);
```

### Case B

In this example, User2 creates a materialized view on tables owned by User1. The materialized view is owned by User1.

```sql
/****************************************************************
Setup:
SchemaX owner = DBO
SchemaX.T1 owner = User1
SchemaX.T2 owner = User1
SchemaY owner = User1
*****************************************************************/
CREATE USER User1 WITHOUT LOGIN ;
CREATE USER User2 WITHOUT LOGIN ;
GO
CREATE SCHEMA SchemaX;
GO
CREATE SCHEMA SchemaY AUTHORIZATION User1;
GO
CREATE TABLE [SchemaX].[T1] (    [vendorID] [varchar](255) Not NULL, [totalAmount] [float] Not NULL,    [puYear] [int] NULL );
CREATE TABLE [SchemaX].[T2] (    [vendorID] [varchar](255) Not NULL,    [totalAmount] [float] Not NULL,    [puYear] [int] NULL);
GO
ALTER AUTHORIZATION ON OBJECT::SchemaX.[T1] TO User1;
ALTER AUTHORIZATION ON OBJECT::SchemaX.[T2] TO User1;

/*****************************************************************************
For user2 to create a MV in SchemaY on SchemaX.T1 and SchemaX.T2, user2 needs:
1. CREATE VIEW permission in the database
2. REFERENCES permission on the schema1
3. SELECT permission on base table T1, T2  
4. ALTER permission on SchemaY
******************************************************************************/
GRANT CREATE VIEW to User2;
GRANT REFERENCES ON SCHEMA::SchemaX to User2;  
GRANT SELECT ON OBJECT::SchemaX.T1 to User2; 
GRANT SELECT ON OBJECT::SchemaX.T2 to User2;
GRANT ALTER ON SCHEMA::SchemaY to User2; 
GO
EXECUTE AS USER = 'User2';  
GO
CREATE materialized VIEW [SchemaY].MV_by_User2 with(distribution=round_robin) 
as 
        select A.vendorID, sum(A.totalamount) as S, Count_Big(*) as T 
        from [SchemaX].[T1] A
        inner join [SchemaX].[T2] B on A.vendorID = B.vendorID group by A.vendorID ;
GO
revert;
GO
```

