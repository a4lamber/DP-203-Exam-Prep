# Practice questions on exam topics

247题 in total; 10 topics



To-do out of 48 pages

- Page (2/48), 第10题 (10/247)  (2022/11/29)
- Page (5/48), 第25题 (25/247)  (2022/11/30)
- Page(10/48), 第50题 (50/247)  (2022/12/01)
- Page(15/48) (2022/12/06)

[toc]







## Topic 1 1-67



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
    - 因为PolyBase can't load **rows** that have more than 1,000,000 bytes of data (1MB每行是限制). When you put data into the text files in Azure Blob storage or Azure Data Lake Store, they must have fewer than 1,000,000 bytes of data. This byte limitation is true regardless of the table schema. 每行数据量别超过这个数
- ❤️25: query performance tuning 的问题
  - 知识: dedicated SQL pool有两种features for performance tuning for queries
    - `cached result`: result set caching is used for getting high concurrency and fast response from repetitive queries against static data. [Performance tuning with result set caching](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/performance-tuning-result-set-caching)
    - `Materialized views` : allow data changes in the base tables. Data in materialized views can be applied to a piece of query. This support allows the same materialized views to be used by different queries that share some computation for faster performance.[看这里](https://techdifferences.com/difference-between-view-and-materialized-view.html) and [SQL View on SQLShack](https://www.sqlshack.com/sql-view-a-complete-introduction-and-walk-through/)
  - 答案B, materialzed view, 详情见附录
- ❤️26: Synapse 中用Apache Spark pool named `Pool1`, 你现在需要建一个database named `DB1` in `Pool1`, You need to ensure that when tables are created in DB1, the tables are available automatically as external tables to built-in serverless SQL pool.
  - My Answer: `Parquet` 遇事不觉选parquet
  - 分析: For each spark external table based on **Parquet or csv** and located in Azure storage, an external table is craeted in a serverless SQL pool. 注意: Serverless SQL pool可以自动同步metadata from Apache Spark. 这个features这样设计的原因是spark pool shut down后，你仍然能access from serverless SQL pool. 但只支持parquet or csv (parquet faster since it's column-oriented) 
  - [Synchronize Apache Spark external table and serverless SQL pool](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/develop-storage-files-spark-tables)
- ❤️27: You are planning a solution to aggregate streaming data that originates in Apache Kafka and is output to Azure Data Lake Storage Gen2. The developers who will implement the stream processing solution use Java. **Which service should you recommend using to process the streaming data?**
  - Attempted: Azure stream analytics ❌
  - 答案: Azure Databricks
  - 分析: 考的是Azure生态中，语言支持度的问题, 支持java的Azure DB。同时也可以是排除法，排除Azure stream analytics由于它只能接受event hub, iot hub和blob as input
- ❤️28: You plan to implement an Azure Data Lake Storage Gen2 container that will contain CSV files. The size of the files will vary based on the number of events that occur per hour.
  File sizes range from 4 KB to 5 GB.
  You need to ensure that the files stored in the container are optimized for batch processing.
  What should you do?
  - Attempted: Convert the files for Avro
  - 答案：绝大多数人vote `merge the file` , 少部分人vote `Avro`
  - 分析: 
  - In [best practice for ADLS](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-best-practices#file-size), ADLS支持的file format和file size的讨论如下
    - 对于file size, larger files lead to better **performance** and **reduced cost**.
      -  你最好把你的数据分成 256MB - 100GB in size for better performance. 超过100GB不太好处理。太多零碎的小文件也会导致性能变慢
      - 对于transcation, 是按照4MB为梯度收费，你文件全都是如果只有几KB,  那都会按4MB一个收费，那就贵了
    - 对于file format的选择
      - Consider `Avro` in cases your I/O patterns are more write heavy or query patterns favor retrieving multiple rows of records.
      - Consider `Parquet` and`ORC` when you I/O patterns are more read heaby or query patterns are focused on a subset of columns.
- 29 考点是用`json`表达acess tier。You store files in an Azure Data Lake Storage Gen2 container. The container has the storage policy shown in the following exhibit.
  - Attempted: 
    - The files are [answer choice] after 30 days: Moved to cool storage
    - The storage policy apllies to [answer choice]: `container1/contoso.csv` 

- 30: You are designing a financial transactions table in an Azure Synapse Analytics **dedicated SQL poo**l. The table will have a **clustered columnstore index** and will include the following columns:
  ✑ TransactionType: 40 million rows per transaction type
  ✑ CustomerSegment: 4 million per customer segment
  ✑ TransactionMonth: 65 million rows per month
  AccountType: 500 million per account type
  You have the following query requirements:
  ✑ Analysts will most commonly analyze transactions for a given month.
  ✑ Transactions analysis will typically summarize transactions by transaction type, customer segment, and/or account type
  You need to recommend a partition strategy for the table to **minimize query times.**
  On which column should you recommend partitioning the table?

  - A. CustomerSegment
  - B. AccountType
  - C. TransactionType
  - D. TransactionMonth

- Attempted: D 正确了！

  - 思路: 我的思路是根据query requirement的第一条，总是会query monthly data, 这样的话，我自然prefer partitioning with month.
  - 看过讨论之后的思路是: 根据第二条, transcation type, customer segment and account type 是分析的column, 也会perform aggregate statistics,也就是需要用很多`group by` and `join`,  最后用month in `where` for row filtering. 前者需求由distribution负责，后者用where
  - Note: 见到clustered columnstore tables, 至少需要1million rows per distribution and partition is needed.

- 31: You have an Azure Data Lake Storage Gen2 account named account1 that stores logs as shown in the following table.

  ![](https://www.examtopics.com/assets/media/exam-media/04259/0006800003.png)

- **You do not expect that the logs will be accessed during the retention periods.**
  You need to recommend a solution for account1 that meets the following requirements:
  ✑ Automatically deletes the logs at the end of each retention period
  ✑ Minimizes storage costs
  What should you include in the recommendation? To answer, select the appropriate options in the answer area.
  NOTE: Each correct selection is worth one point.

  ![](https://www.examtopics.com/assets/media/exam-media/04259/0006900003.png)

  - Attempted answer:
    - Store logs in Archive access tier❌
    - For automaticaly deleting logs: 盲猜一个Azure Blob storage lifecycle management rules
  - 考点: 错了一个，蒙对了一个。答案是infrastructure to cool, application to archive.原因在于**early deletion fee**. 详情见附录.

- ❤️32: You plan to ingest **streaming social media data** by using **Azure Stream Analytics.** The data will be stored in files in **Azure Data Lake Storage**, and then consumed by using Azure Databricks and PolyBase in Azure Synapse Analytics.
  **You need to recommend a Stream Analytics data output format to ensure that the queries from Databricks and PolyBase against the files encounter the fewest possible errors.** The solution must ensure that the files can be queried quickly and that the data type information is retained.
  What should you recommend from (JSON, Parquet, CSV, Avro)

  - Attempted: avro❌
  - 我的思路: 从要求和service两个方面出发
    - 有两个要求, query quickly and data type information is retained.
      - query quickly则 avro or parquet (parquet quicker) 但是没有specify到底是什么样的query, `where` based avro, `group by` and `join` based parquet
      - data type informaiton is retained 换句话说就是data output format能够储存schema信息，那么`csv`肯定不是 
    - 从service出发，Azure stream analytics方便serialization的output 只有avro了
  - 思路: 想多了，现在stream analytics支持avro了，databrick和synapse都是spark as engine, 那自然parquet更快

- ❤️33: You have an **Azure Synapse Analytics dedicated SQL pool** named Pool1. Pool1 contains a partitioned fact table named **dbo.Sales** and a staging table named **stg.Sales** that has the matching table and partition definitions.
  You need to overwrite the content of the first partition in dbo.Sales with the content of the same partition in stg.Sales. **The solution must minimize load times**.
  What should you do?

  - Attempted: switch the first partition from dbo.Sales to stg.Sales❌
  - 思路: partition 就是为了优化bulk update, deletion, row filetering operation 存在的, 肯定选这个
  - 答案: 正确的操作for overwriting operations: switches the first partition from stg.Sales to dbo.Sales
  - 分析思路:  SQL command for this is `SWITCH [source] TO [target]`, 那自然是这个逻辑[Best practice for dediacate SQL pool](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/best-practices-dedicated-sql-pool)

  看下面这行for example[example of Azure on medium](https://medium.com/@cocci.g/switch-partitions-in-azure-synapse-sql-dw-1e0e32309872)

  ```sql
  ALTER TABLE stg.Sales SWITCH PARTITION 1 TO dbo.FactSales PARTITION 1;
  ```

- 34: You are designing a slowly changing dimension (SCD) for supplier data in an Azure Synapse Analytics dedicated SQL pool.
  **You plan to keep a record of changes to the available fields.**
  The supplier data contains the following columns.

  ![](https://www.examtopics.com/assets/media/exam-media/04259/0007200001.png)

- Which **three additional columns** should you **add to the data** to create a Type 2 SCD? Each correct answer presents part of the solution.

  - A: surrogate primary key
  - B. effective start date
  - C. business key
  - D. last modified date
  - E. effective end date
  - F. foreign key

- 我的答案: A, B, E (community的答案majority支持ABE)

  - 巧记 slowly changing dimension (SCD) type [SCD learning module](https://learn.microsoft.com/en-us/training/modules/populate-slowly-changing-dimensions-azure-synapse-analytics-pipelines/3-choose-between-dimension-types)
    - Type1: overwrite with modified date, 这样不保存过去的信息
    - Type2: 在有surrogate key的情况下，加一行数据, 再加几列audit column such as `StartDate` ,`EndDate` and `IsCurrent`
    - Type3: 1行存俩名，practically speaking很少用，因为不好用

- ❤️35:You have a **Microsoft SQL Server database that uses a third normal form schema.**
  You plan to migrate the data in the database to a star schema in an Azure Synapse Analytics dedicated SQL pool.
  You need to design the dimension tables. **The solution must optimize read operations.** (没跑了，read I/O pattern from multiple `join`, 一定是denormalize你的fact tables)
  What should you include in the solution? To answer, select the appropriate options in the answer area.
  NOTE: Each correct selection is worth one point.

  ![](https://www.examtopics.com/assets/media/exam-media/04259/0007400001.png)

  - Attempted answer: maintain 3 normal form, New identity column❌
  - 我的思路: third normal什么意思? 我只知道normalization和denormalization
  - 答案: denormalization to a second normal form, new identity key

- You plan to develop a dataset named Purchases by using **Azure Databricks**. Purchases will contain the following columns:
  ✑ ProductID
  ✑ ItemPrice
  ✑ LineTotal
  ✑ Quantity
  ✑ StoreID
  ✑ Minute
  ✑ Month
  ✑ Hour
  ✑ Day
  You need to store the data to support hourly incremental load pipelines that will vary for each Store ID. **The solution must minimize storage costs.**
  How should you complete the code? To answer, select the appropriate options in the answer area.
  NOTE: Each correct selection is worth one point.

- Attempted solution: `df.write.partitionBy("StoreID","Year","Month","Day","Hour").parquet("/Purchase")`

  - 几个有意思的trick
    - `df.write.partitionBy("y","m","d").mode(SaveMode.Append).parquet("/data/hive/warehouse/db_name.db/" + tableName)`
    - `df.write.mode(SaveMode.Overwrite).parquet("/data/hive/warehouse/db_name.db/" + tableName + "/y=" + year + "/m=" + month + "/d=" + day)`

- ❤️37: You are designing a partition strategy for a fact table in an Azure Synapse Analytics dedicated SQL pool. The table has the following specifications:

  - Contain sales data for 20,000 products.
  - Use hash distribution on a column named ProductID.
  - Contain 2.4 billion records for the years 2019 and 2020.

- Which number of partition ranges provides optimal compression and performance for the clustered columnstore index? (40,240,400,2400)

  - Attempted: 2400❌
  - 我的思路： For columnstore index to be efficient, 至少每个partition需要1 million record, 2.4 billion/1million = 2400
  - 答案:40, 因为dedicated SQL pool 一上来自动先把table分20

- 38: You are creating dimensions for a data warehouse in an Azure Synapse Analytics dedicated SQL pool.
  You create a table by using the Transact-SQL statement shown in the following exhibit.

  ![](https://www.examtopics.com/assets/media/exam-media/04259/0007900001.png)

- Use the drop-down menus to select the answer choice that completes each statement based on the information presented in the graphic.

  - Attempted answer:
    - SCD: Type 2
    - ProductKey column is: a surrogate key 
    - 知识: 答案没问题但涉及到以下两点:
      - **surrogate key** in synpase could be set by `IDENTITY` [怎么用点这里](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-tables-identity).每当数据库插入`Insert`新数据的时候，`IDENTITY`就会自动assign 1 number.
      - 知道了一个新概念: **business key** is an index which identifies uniqueness of a row that have business value. 不仅满足unique identifier for row, 还不是randomly generate indexing column, 必须有business意义, 比如US-NY-KLM4567这个作为`business key`,国家-州号-车牌号, 还满足unique identifies
        - [比较business key with surrogate key](https://vertabelo.com/blog/natural-key/)

- 39:

  - Attemped answer: hash-distributed with Purchasekey
  - 我的思路: 数据量很大1million per day, 3 years of data in fact table. 排除不是hash-distribued的答案，再比较`datekey` and `purchasekey` as hash value, 前者的cardinality太高，没有意义.

- ❤️40: You are implementing a batch dataset in the **Parquet format**.
  Data files will be produced be using Azure Data Factory and stored in Azure Data Lake Storage Gen2. The files will be consumed by an Azure Synapse Analytics serverless SQL pool.
  **You need to minimize storage costs for the solution.**
  What should you do?

  - A. Use Snappy compression for the files.
  - B. Use OPENROWSET to query the Parquet files.
  - C. Create an external table that contains a subset of columns from the Parquet files.
  - D. Store all data as string in the Parquet files.
  - 我的答案:  A (snappy compression)
  - 我的思路: C,D不可能。A,B蒙一个,
  - 反馈:  蒙对了，snappy, google 开源的一个codec

- 41: You need to build a solution to ensure that users can query specific files in an Azure Data Lake Storage Gen2 account from an Azure Synapse Analytics serverless SQL pool.
  **Which three actions should you perform in sequence?** To answer, move the appropriate actions from the list of actions to the answer area and arrange them in the correct order.
  NOTE: More than one order of answer choices is correct. You will receive credit for any of the correct orders you select.

![](https://www.examtopics.com/assets/media/exam-media/04259/0008400001.jpg)



- Attempted solution: 
  - Create an external data source 
  - Create an external file format object
  - Create an external table
- ❤️42: 
  - Attempted answer: ❌
    - A: a dimension table for EmployeeTransaction
    - D: a fact table for Employee

  - 分析:
    - 这题问题很大，在dimenstional modeling
      - Dimension table contains attribute that might change but usually changes infrequently.
      - Fact table contains quantitative data that are commonly generated in a transactional system, and loaded into the dedicated SQL pool.

- 43 考点slowly changing dimension
  - Attempted answer: Type 2

- 44
  - attempted answer:
    - Create a database scoped credential that uses Azure Active Directory and a Service Principal Key
    - Create an external data source that uses the abds location
    - Create an external file format and set the `First_Row` option
    - Create an external table

  - 知识点:
    - 再复习一遍create external table的顺序 with [polybase](https://learn.microsoft.com/en-us/sql/relational-databases/polybase/polybase-t-sql-objects?view=sql-server-ver16) in T-SQL, 正常是四步骤, 但如果考试考只问三个，则忽略需要密钥这一点
    - 注意: 还有一个方法是CETAS, see [here](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-cetas)

-  45: Youare building an Azure Synapse Analytics dedicated SQL pool that will contain a fact table for transactions from the first half of the year 2020.
  You need to ensure that the table meets the following requirements:
  - Minimizes the processing time to delete data that is older than 10 years
  - Minimizes the I/O for queries that use year-to-date values

- How should you complete the Transact-SQL statement? To answer, select the appropriate options in the answer area.
  NOTE: Each correct selection is worth one point.
- Attempted answer:

```sql
-- T-SQL solution
CREATE TABLE [dbo].[FactTransaction]
(
  [TransactionTypeID] int NOT NULL,
  [TransactionDate] int NOT NULL,
  [CustomerID] int NOT NULL,
  [RecepientID] int NOT NULL,
  [Amount] money NOT NULL
)
WITH
(
  PARTITION ([TransactionID] RANGE RIGHT FOR VALUES (20200101,20200201,20200301,20200401,20200501,20200601))
)

```

- 46 You are performing exploratory analysis of the bus fare data in an Azure Data Lake Storage Gen2 account by using an Azure Synapse Analytics serverless SQL pool.
  You execute the Transact-SQL query shown in the following exhibit.

```sql
SELECT
		payment_type,
		SUM(fare_amount) AS fare_total
FROM OPENROWSET(
				BULK 'csv/busfare/tripdata_2020*.csv',
  			DATA_SOURCE = 'BusData',
  			FORMAT = '.CSV', PARSER_VERSION = '2.0',
  			FIRSTROW = 2
	)
	WITH (
  		payment_type INT 10,
      fare_amount FLOAT 11
  ) AS nyc
GROUP BY payment_type
ORDER BY payment_type

```

- Attempted solution:
  - D: Only CSV that have file names that beginning with `tripdata_2020`
  - 思路: `BULK 'csv/busfare/tripdata_2020*.csv'`里面的`*` is wildcard character for any number of characters.
- ❤️❤️47: You use PySpark in Azure DB to parse the following json input.

```json
{
  "person":[
    {
      "names":"keith",
      "age": 30,
      "dogs":["Fido","Fluffy"]
    },
    {
      "names":"Donna",
      "age": 46,
      "dogs":["Spot"]
    }
  ]
}
```

Yout need to output the following table, how to write in pyspark

| Owner | age  | dog    |
| ----- | ---- | ------ |
| Keith | 30   | Fido   |
| Keith | 30   | Fluffy |
| Donna | 46   | Spot   |

```python
# right solution
dbutils.fs.put("/tmp/source.json",source_json,True)
source_df = spark.read.option("multiline","true").json("/tmp/source.json")

persons = source_df.select(explode("persons").alias("persons"))
persons_dogs = persons.select(col("persons.name").alias("owner"),col("persons.age").alias("age"),explode("perosns.dogs").alias("dog"))
```

这一题要在azure db上过一遍!

- 48:
  - Answer:
    - HOT
    - COOL
    - COOL
  - 思路，唯一有歧义的是最后一条，由于有acessible within minutes的约束，所以cool

![](https://www.examtopics.com/assets/media/exam-media/04259/0009900001.jpg)

- 49 You have an Azure Synapse Analytics Apache Spark pool named Pool1.
  You plan to load JSON files from an Azure Data Lake Storage Gen2 container into the tables in Pool1. The structure and data types vary by file.
  You need to load the files into the tables. The solution must maintain the source data types.
  What should you do?
  - Answer: D load the data by using pyspark
- ❤️50: You have an Azure Databricks workspace named workspace1 in the Standard pricing tier. Workspace1 contains an all-purpose cluster named cluster1.
  You need to reduce the time it takes for cluster1 to start and scale up. The solution must minimize costs.
  What should you do first?
  - Attempted Answer: C❌
  - Answer should be D: create a pool in workspace1
  - 分析: Databrickes Pools, **a managed cache of virtual machine instance**s that enables clusters to start and scale 4 times faster [Use DB pool](https://www.databricks.com/blog/2019/11/11/databricks-pools-speed-up-data-pipelines.html)
    - Apache spark进行大数据的计算需要VMs, in Azure databricks, 但你start your cluster, spark会向cloud provider asks for VMs instances to deploy and then run on top of it. 这个init overhead可能会很大，很耗时。所以推出的服务databrick pools也就是和cloud provider预约一部分idle VMs, 等我需要的时候，你直接给我，不需要provision了, 提升启动速度。
      - databrick pool的idle instances不消耗算力 (DWU)那也就不收钱，但你的cloud provider会收钱，因为他们等于预留着装着vm的机子给你



- ❤️51
  - Attempted answer:
    - Path pattern: product.csv❌
    - Date format: YYYY/MM/DD
    - 对于path pattern, this required property is used to locate your blobs wihtin the specified container. Within the path, you might choose to specify one or more instances of the variables {date} and {time}.
      - Example 1: products/{date}/{time}/product-list.csv
      - Example2: product/{date}/product-list.csv
      - Example 3: product-list.csv
    - [Use reference data for lookups in Stream Analytics](https://learn.microsoft.com/en-us/azure/stream-analytics/stream-analytics-use-reference-data)
- ❤️❤️52 You have the following Azure Stream Analytics query

```sql
step1 AS (SELECT *
         FROM input1
         PARTITION BY StateID
         INTO 10),
step2 AS (SELECT *
         FROM input2
         PARTITION BY StateID
         INTO 10)
SELECT *
INTO output
FROM step1
PARTITION BY StateID
UNION
SELECT * INTO output FROM step2 PARTITION BY StateID
```



![](https://www.examtopics.com/assets/media/exam-media/04259/0010800001.jpg)

- Attempted answer:
  - YES
  - YES
  - NO
- 答案有分歧, 需要仔细研读

- ❤️53: You are building a database in an Azure Synapse Analytics serverless SQL pool.
  You have data stored in Parquet files in an Azure Data Lake Storege Gen2 container.
  Records are structured as shown in the following sample.

  ```json
  {
  "id": 123,
  "address_housenumber": "19c",
  "address_line": "Memory Lane",
  "applicant1_name": "Jane",
  "applicant2_name": "Dev"
  }
  ```

  The records contain two applicants at most.
  You need to build a table that includes only the address fields.
  How should you complete the Transact-SQL statement? To answer, select the appropriate options in the answer area.
  NOTE: Each correct selection is worth one point.

![](https://www.examtopics.com/assets/media/exam-media/04259/0011000001.jpg)



- Attempted answer: 
  - `Create External Table`
  - `OPENJSON` ❌
- 正确答案,  `OPENROWSET`
- ❤️54: 

![](https://www.examtopics.com/assets/media/exam-media/04259/0011200001.jpg)

- 我的答案:
  - blob ❌
  - `TYPE = HADOOP`

记住这张[table](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables?tabs=hadoop)

LOCATION = `'<prefix>://<path>'` - Provides the connectivity protocol and path to the external data source. The following patterns can be used in location:

| External Data Source        | Location prefix | Location path                                                |
| :-------------------------- | :-------------- | :----------------------------------------------------------- |
| Azure Blob Storage          | `wasb[s]`       | `<container>@<storage_account>.blob.core.windows.net`        |
| Azure Blob Storage          | `http[s]`       | `<storage_account>.blob.core.windows.net/<container>/subfolders` |
| Azure Data Lake Store Gen 1 | `http[s]`       | `<storage_account>.azuredatalakestore.net/webhdfs/v1`        |
| Azure Data Lake Store Gen 2 | `http[s]`       | `<storage_account>.dfs.core.windows.net/<container>/subfolders` |

`https:` prefix enables you to use subfolder in the path.

由docs中的上表可以得到, if ADLS Gen 2则df2, 如果是Azure blob则blob



- 55: data format问题
  - 我的答案: parquet
- 56
  - 我的答案
    - `hash`
    - `OrderDateKey`
- 57
  - 我的答案
    - mobe to cool storage
    - delete the blob ❌ 有争议，也可以选archive
- ❤️58
  - 我的答案
    - Zone-redundant storage (ZRS) 
    - Failover automatically initiated by an Azure automation job❌
    - 分析: 
      - 有争议, 但data center fails后，你还希望可以write access, 那么就只能是这个了.
      - 关键句[failover](https://learn.microsoft.com/en-us/azure/storage/common/storage-disaster-recovery-guidance?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json%20https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fanswers%2Fquestions%2F32583%2Fazure-data-lake-gen2-disaster-recoverystorage-acco.html)
- ❤️59
  - TYPE 3 SCD
    - BE
- 60
  - 我的答案: 
    - Common.Data: Replicated
    - Marketing.Web.Sessions: Hash
    - Staging.Web.Sessions: Round-robin
- 61
  - 我的答案
    - CLUSTERED COLUMNSTORE INDEX
    - `HASH([ProductKey])`
- ❤️62
  - 我的答案
    - Create a partition once per month.❌
    - 思路: 30 million data each month推出30 million x 12 = 360 million per year, dedicate SQL pool default parition = 60, 则新一年的数据总量，如果不partition 则360/60 = 6 million rows per distribution.  需求至少1 million, 如果按月分，则6 million/12 = 0.5 million row per distribution per partition是不达标的
- ❤️63 Apache Spark SQL
  - MERGE
  - 分析: 看一下type 2 SCD的scala代码就知道了, [here](https://www.projectpro.io/recipes/what-is-slowly-changing-data-scd-type-2-operation-delta-table-databricks)
- 64
  - 我的答案:
    - Parquet, D
- 65
  - 我的答案
    - YES
  - 思路: 有争议，但考点是用polybase load data, 每行不超过1MB
- 66
  - replicated

- 67
  - C







## Topic 2: 1- (68)

https://www.examtopics.com/exams/microsoft/dp-203/view/14/

这一个topic,是从14页开始



- 1:  You plan to create a real-time monitoring app that alerts users when a device travels more than 200 meters away from a designated location.
  You need to design an Azure Stream Analytics job to process the data for the planned app. The solution must minimize the amount of code developed and the number of technologies used.
  What should you include in the Stream Analytics job? To answer, select the appropriate options in the answer area.
  NOTE: Each correct selection is worth one point.

![](https://www.examtopics.com/assets/media/exam-media/04259/0014700001.jpg)



- My answer:
  - stream
  - windowing❌
- 分析: 用户设备200米外报警，数据类型是geospatial, 怎么判断什么functions则要看Azure stream analytics的一种SQL变种(Stream analytics Query language)有什么built-in function了. 如下

Azure Stream Analytics provides some built-in functions. The categories of built-in functions are:

| Function Category                                            | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| [Aggregate Functions](https://learn.microsoft.com/en-us/stream-analytics-query/aggregate-functions-azure-stream-analytics) | Operate on a collection of values but return a single, summarizing value. |
| [Analytic Functions](https://learn.microsoft.com/en-us/stream-analytics-query/analytic-functions-azure-stream-analytics) | Return a value based on defined constraints.                 |
| [Array Functions](https://learn.microsoft.com/en-us/stream-analytics-query/array-functions-stream-analytics) | Returns information from an array.                           |
| [GeoSpatial Functions](https://learn.microsoft.com/en-us/stream-analytics-query/geospatial-functions) | Perform specialized GeoSpatial functions.                    |
| [Input Metadata Functions](https://learn.microsoft.com/en-us/stream-analytics-query/input-metadata-functions) | Query the metadata of property in the data input.            |
| [Record Functions](https://learn.microsoft.com/en-us/stream-analytics-query/record-functions-azure-stream-analytics) | Returns record properties or values.                         |
| [Windowing Functions](https://learn.microsoft.com/en-us/stream-analytics-query/windowing-azure-stream-analytics) | Perform operations on events within a time window.           |
| [Scalar Functions](https://learn.microsoft.com/en-us/stream-analytics-query/built-in-functions-azure-stream-analytics#BKMK_ScalarFunctions) | Operate on a single value and then return a single value. Scalar functions can be used wherever an expression is valid. |

- Reference:
  -  [Process real-time IoT data stream](https://learn.microsoft.com/en-us/azure/stream-analytics/stream-analytics-get-started-with-azure-stream-analytics-to-process-data-from-iot-devices)
  - [Stream Analytics Query Language](https://learn.microsoft.com/en-us/stream-analytics-query/geospatial-functions)





- ❤️2: A company has a real-time data analysis solution that is hosted on Microsoft Azure. The solution uses Azure Event Hub to ingest data and an Azure Stream
  Analytics cloud job to analyze the data. **The cloud job is configured to use 120 Streaming Units (SU).**
  You need to **optimize performance for the Azure Stream Analytics job.**
  Which two actions should you perform? Each correct answer presents part of the solution.
  NOTE: Each correct selection is worth one point.
- A. Implement event ordering.
- B. Implement Azure Stream Analytics user-defined functions (UDF).
- C. Implement query parallelization by partitioning the data output.
- D. Scale the SU count for the job up.
- E. Scale the SU count for the job down.
- F. Implement query parallelization by partitioning the data input.
- My answer:
  - 不知道
  - 分析: 考optimization of stream analytics了，分值比较小



- ❤️3
  - eventhub❌
  - 正确答案: event grid
  - Event-driven architecture (EDA) 是一个很常见的data integration pattern
- 4: You plan to perform batch processing in Azure Databricks once daily.
  Which type of Databricks cluster should you use?
  - databricks
  - 我的答案: high concurrency❌
  - 正确答案: automated
  - 分析: Databricks中有两种cluster: interactive and automated
    - **Interactice cluster** : analyze data collaboratively with interactice notebooks (concurrency比较好)
    - **automated cluster**: run fast and robust automated jobs
  - For batch processing of daily data, 自然是automated比较好
- ❤️5 高速收费站的每10分钟数据的收集
  - MAX, TumblingWindow, DATEDIFF
  - 分析: here for one of the stream analytics [common query patterns](https://learn.microsoft.com/en-us/azure/stream-analytics/stream-analytics-stream-analytics-query-patterns#return-the-last-event-in-a-window)
  - query还有些没看懂, stream analytics中的`TIMESTAMP` 

- ❤️6
  - 完全不会
  - 分析: 看懂
  - 文献:
    - [Dependencies in ADF](https://www.sqlshack.com/dependencies-in-azure-data-factory/)


![](https://www.sqlshack.com/wp-content/uploads/2020/12/pipeline-with-dependencies.png)

ADF 中data pipeline逻辑链, 实际上是sequential running of activity

- success: only run if successful
- failure: only run if previous activity failed
- completion: 只要前面activity完成了, 就会run, 不管成功与否
- skipped: run if the previous activity is skipped or not executed

![](https://www.sqlshack.com/wp-content/uploads/2020/12/activities-dependencies.png)



- 7: 

  - My answer:
    - ingest: Azure Data Factory
    - store: ADLS
    - Prepare and train: HDInsight Apache Storm Cluster❌ databrick是答案
    - model and serve: Synapse

- 8: SQL题目: calculte the employee_type value based on the hire_date value.

  ![](https://www.examtopics.com/assets/media/exam-media/04259/0016100001.png)

```sql
SELECT
		*,
		CASE
		WHEN hire_date >= '2019-01-01' THEN 'New'
		ELSE 'Standard'
		END AS employee_type
FROM
		employees
```

- 9 ADLS中存了json, 用synapse进行读取，考SQL
  - 考试trick: 一共考三个function. `OPENROWSET` for load, `json_value()` and `openjaon()` for parse. 其中如果`json_value() ` parse, 需要每一列parse一下，也就是有multiple `json_value()` 如果代码中没有n个`json_value()` 则openjson
- 10: 

```sql
SELECT
		*
FROM
(
  	SELECT
  			YEAR(Date) Year,
  			Month(Date) Month,
  			Temp
  	FROM
  			temperatures
  	WHERE
  			date between Date '2019-01-01' AND Date '2021-08-31'
)
-- rotate table-valued expression by turning the unique values from one column in the expression into multiple columns in the output. And PIVOT runs aggregation where they're required on any remaining column values that are wanted in the final output.
PIVOT (
AVG (CAST(Temp AS DECIMAL(4,1)))
FOR Month in
	(
  1 JAN, 2 FEB, 3 MAR, 4 APR, 5 MAY, 6 JUN,
  7 JUL, 8 AUG, 9 SEP, 10 OCT, 11 NOV, 12 DEC
	)
)
ORDER BY Year ASC
```

- 我的答案:
  - `PIVOT` and `CAST`
- 分析



- 11: ADF中有10 pipelines. 你需要label each pipeline (E OR T OR L) and it must be available for grouping and filtering when using monitoring service. What should you add to each pipeline?
  - 我的答案:  an annotation
  - 分析: udemy course section 10 optimization中有谈到
- ❤️12:
  - 正确答案: cluster UI changed!!!!这题略过吧
    - YES
    - NO
    - YES
- 13:
  - 我的答案: B, Azure DB
- 14:
  - 我的答案: `LEFT`❌ and `20100101,20110101,20120201`
  - 分析:
    - PARTITION LEFT和RIGHT代表哪个是开区间:
      - **left**: 左开右闭
      - **Right**: 左闭右开
- 15: 
  - 我的答案: BE
- 16
  - 我的答案: Yes (A)
  - 分析: 
    - 按理说hopping window with same window size and hop size is equivalent to tumbling window. 
- 17
  - 我的答案: No
- 18
  - 考点Stream Analytics 的SQL, 计算duraiton between the start and end event. 

```sql
SELECT
		[user],
		feature,
		DATEDIFF(
    		second,
    		LAST(Time) OVER (PARTITION BY [user], feature LIMIT DURATION(hour,1) WHEN Event = 'start')),
    		Time) AS duration
FROM
		input TIMESTAMP BY Time
WHERE
		Event = 'end'
```

- `DATEDIFF(unit,startdate,enddate)`

- `LAST(column_name)`: return last value in a specified column
- 19
  - 我的答案: AB
  - 复习一下ADF流程:
    - sink
    - source
- 20
  - 看不懂 ADF 中的mapped data flow这个语言, 其中conditional split transformation

```
CleanData
		split(
				dept == 'ecommerce',dept=='retail',dept =='wholesale',
				disjoint:true
		) ~> SplitByDept @ (ecommerce, retail, wholesale, all)
```

- 看[ADF conditional split transformation in mapping dataflow](https://learn.microsoft.com/en-us/azure/data-factory/data-flow-conditional-split)
- 分析:
  - disjoint还是没有看懂

- 21
  - copy json files to synapse with azure DB, 需要5 steps
    - mount the data lake storage to DBFS
    - read the file into a data frame
    - perform transformation on the dataframe
    - write the result to a table in Azure synapse❌ specify a temporary folder to stage the data
    - drop the dataframe❌ write to azure synapse
- 22: 
  - 我的答案:
    - **TYPE:** schedule
    - **ADDITIONAL PROPERTIES:** Recurrence: 30 minutes, Start time: 2021-01-01T00:00, Dealy: 2 minutes
  - https://learn.microsoft.com/en-us/azure/data-factory/how-to-create-tumbling-window-trigger?tabs=data-factory%2Cazure-powershell
  - 分析几种ADF trigger types:
    - event trigger
      - storage event trigger (event grid)
    - tumbling window trigger
    - schedule trigger
- 23:
  - 我的答案:
    - input type: Azure event hub
    - output type: Power BI
    - aggregation query location: stream analytics
- 24:















# 附录

这里都是根据考试的题目，整理的知识点。





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





## SQL performance tuning





### Materialized view for performance tuning

View和Materialize view的区别

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

下面看两个案例

#### Case A

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

#### Case B

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

### Performance tuning with result set caching

result set caching是一个功能，可以turn on and off, 一旦turn on, 所有有权限的用户的query到的信息都会存在cache里，直到cache满了 (1 TB per database)

#### When cached results are used

Cached result set is reused for a query if **all of the following requirements** are met:

- The user who's running the query has access to all the tables referenced in the query.
- There is an exact match between the new query and the previous query that generated the result set cache.
- There is **no data or schema changes in the tables where the cached result set was generated from.**

要求太严苛了，base table data and schema不能变，datawarehouse中虽然是slowly changing dimension，但也是在变的





## Best practices for dedicated SQL pools in Azure Synapse Analytics

[MS doc reference](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/best-practices-dedicated-sql-pool)



### DO NOT OVER-PARTITION

Decidate SQL pools automatically partition your data into 60 databases. Avoid high granularity partitioning strategy! 通常partition和index连用，columnstore index需要每个partition至少1 million for good performance, 那样的话一个table就需要至少60 million (auto-partition by 60 in dedicated SQL pool)





## Streaming solution in Azure

Streaming solution in Azure 分以下这几类:

- Azure Stream Analytics
- HDInsight with Spark Streaming
- Apache Spark in Azure Databricks
- HDInsight with Storm
- Azure Functions
- Azure App service Webjobs
- Apache kafka streams API

### General Capbility

| Capability           | Azure Stream Analytics                                       | HDInsight with Spark Streaming                               | Apache Spark in Azure Databricks                             | HDInsight with Storm | Azure Functions                                 | Azure App Service WebJobs      |
| :------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :------------------- | :---------------------------------------------- | :----------------------------- |
| Programmability      | SQL, JavaScript                                              | [C#/F#](https://github.com/dotnet/spark), Java, Python, Scala | [C#/F#](https://github.com/dotnet/spark), Java, Python, R, Scala | C#, Java             | C#, F#, Java, Node.js, Python                   | C#, Java, Node.js, PHP, Python |
| Programming paradigm | Declarative                                                  | Mixture of declarative and imperative                        | Mixture of declarative and imperative                        | Imperative           | Imperative                                      | Imperative                     |
| Pricing model        | [Streaming units](https://azure.microsoft.com/pricing/details/stream-analytics/) | Per cluster hour                                             | [Databricks units](https://azure.microsoft.com/pricing/details/databricks) | Per cluster hour     | Per function execution and resource consumption | Per app service plan hour      |



### Integration capabilities

| Capability | Azure Stream Analytics                                       | HDInsight with Spark Streaming                               | Apache Spark in Azure Databricks                             | HDInsight with Storm                                      | Azure Functions                                              | Azure App Service WebJobs                                    |
| :--------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :-------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| Inputs     | Azure Event Hubs, Azure IoT Hub, Azure Blob storage          | Event Hubs, IoT Hub, Kafka, HDFS, Storage Blobs, Azure Data Lake Store | Event Hubs, IoT Hub, Kafka, HDFS, Storage Blobs, Azure Data Lake Store | Event Hubs, IoT Hub, Storage Blobs, Azure Data Lake Store | [Supported bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings#supported-bindings) | Service Bus, Storage Queues, Storage Blobs, Event Hubs, WebHooks, Azure Cosmos DB, Files |
| Sinks      | Azure Data Lake Store, Azure SQL Database, Storage Blobs, Event Hubs, Power BI, Table Storage, Service Bus Queues, Service Bus Topics, Azure Cosmos DB, Azure Functions | HDFS, Kafka, Storage Blobs, Azure Data Lake Store, Azure Cosmos DB | HDFS, Kafka, Storage Blobs, Azure Data Lake Store, Azure Cosmos DB | Event Hubs, Service Bus, Kafka                            | [Supported bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings#supported-bindings) | Service Bus, Storage Queues, Storage Blobs, Event Hubs, WebHooks, Azure Cosmos DB, Files |

### Processing capabilities

| Capability                                           | Azure Stream Analytics                                       | HDInsight with Spark Streaming | Apache Spark in Azure Databricks                  | HDInsight with Storm         | Azure Functions                                         | Azure App Service WebJobs            |
| :--------------------------------------------------- | :----------------------------------------------------------- | :----------------------------- | :------------------------------------------------ | :--------------------------- | :------------------------------------------------------ | :----------------------------------- |
| Built-in temporal/windowing support                  | Yes                                                          | Yes                            | Yes                                               | Yes                          | No                                                      | No                                   |
| Input data formats                                   | Avro, JSON or CSV, UTF-8 encoded                             | Any format using custom code   | Any format using custom code                      | Any format using custom code | Any format using custom code                            | Any format using custom code         |
| Scalability                                          | [Query partitions](https://learn.microsoft.com/en-us/azure/stream-analytics/stream-analytics-parallelization) | Bounded by cluster size        | Bounded by Databricks cluster scale configuration | Bounded by cluster size      | Up to 200 function app instances processing in parallel | Bounded by app service plan capacity |
| Late arrival and out of order event handling support | Yes                                                          | Yes                            | Yes                                               | Yes                          | No                                                      | No                                   |

需要注意的是以下几点:

- 不同streaming solution的语言支持度不同
- 考的最多的几个平台会是Azure Stream Analytics, Azure Databricks
- Azure stream analytics
  - 只支持declarative language like SQL and javascript, 
  - output format只支持`Avro`,`JSON`,`CSV` and `UTF-8` encoded. 不支持`.parquet` ❌, 看了一下这，是支持的[here](https://learn.microsoft.com/en-us/azure/stream-analytics/stream-analytics-define-outputs) and [here](https://azure.microsoft.com/en-ca/updates/stream-analytics-offers-native-support-for-parquet-format/). 要去Azure验证一下了(maybe not)
  - input 只支持Azure event hub, azure IOT hub, blob storage (不支持kafka,)之前学stream时候遇到过, 可以用排除法
  - Sink支持最多了, 而且优点是可以用Ms全家桶，直接到PowerBI
- Azure Databricks
  - 支持java, python, scala,R and C#/F#
  - input 支持: Event Hubs, IoT Hub, Storage Blobs, **Kafka, HDFS, Azure Data Lake Store**



[Choose a streaming processing in Azure](https://learn.microsoft.com/en-us/azure/architecture/data-guide/technology-choices/stream-processing#integration-capabilities)















## Batch processing best practice

https://learn.microsoft.com/en-us/azure/architecture/data-guide/technology-choices/batch-processing



## Indexing

还是没搞懂columnstore index和例题30



## Access tier

### Storagin Billing

Access tier的细节考点:

- **Hot tier** - An online tier optimized for storing data that is accessed or modified frequently. The hot tier has the highest storage costs, but the lowest access costs.
- **Cool tier** - An online tier optimized for storing data that is infrequently accessed or modified. **Data in the cool tier should be stored for a minimum of 30 days.** The cool tier has lower storage costs and higher access costs compared to the hot tier.(30 - x where x is the # of days stored in cool tier)
- **Archive tier** - An offline tier optimized for storing data that is rarely accessed, and that has flexible latency requirements, on the order of hours. **Data in the archive tier should be stored for a minimum of 180 days.** 不然要收early deletion penalty (180 - x for archive tier). 



### Billing for Changing a blob's access tier

Keep in mind the following billing impacts when changing a blob's tier:

- When a blob is uploaded or moved between tiers, it's charged at the corresponding rate immediately upon upload or tier change.
- When a blob is moved to **a cooler tier,** **the operation is billed as a write operation to the destination tier**, where the write operation (per 10,000) and data write (per GB) charges of the destination tier apply.
- When a blob is moved to a **warmer tier, the operation is billed as a read from the source** tier, where the read operation (per 10,000) and data retrieval (per GB) charges of the source tier apply. Early deletion charges for any blob moved out of the cool or archive tier may apply as well.
- While a blob is being rehydrated from the archive tier, that blob's data is billed as archived data until the data is restored and the blob's tier changes to hot or cool.

The following table summarizes how tier changes are billed.

|                             | **Write charges (operation + access)**                   | **Read charges (operation + access)**                    |
| :-------------------------- | :------------------------------------------------------- | :------------------------------------------------------- |
| **Set Blob Tier** operation | Hot to cool;<br /> Hot to archive;<br /> Cool to archive | Archive to cool;<br /> Archive to hot:<br /> cool to hot |



### Blob lifecycle mangement

For periodically and automaticaaly manage, delete your blob.

 

## Paritioning table in dedicated SQL pool

如果你需要更新数据数据:

- update, delete很慢
- partition switch 很快!

```sql
ALTER TABLE FactInternetSales SWITCH PARTITION 2 TO FactInternetSales_20000101 PARTITION 2;

ALTER TABLE FactInternetSales SPLIT RANGE (20010101);
```





## Dimensional modeling (normalization form)

**Normalization** is the method of arranging the data in the database efficiently. There are 6 defined normal forms: 1NF, 2NF, 3NF, BCNF, 4NF, and 5NF. Normalization should eliminate redundancy but not at the cost of integrity.

**Denormalization** is the process of transforming higher normal forms to lower normal forms via storing the join of higher normal form relations as a base relation.

Denormalization increases the performance in data retrieval at cost of bringing update anomalies to a database. [Explore the Role of Normal Forms in Dimensional Modeling (based on Kimball's book)](https://www.mssqltips.com/sqlservertip/5614/explore-the-role-of-normal-forms-in-dimensional-modeling/)



举个例子，下面是adventureWorks database, 

![](https://www.mssqltips.com/tipimages2/7114_implement-dimension-denormalization-synapse-mapping-data-flow.001.png)

如果你需要query很多product model and category information alongside product details, you need to join them if you are using the above schema. But if you denomarlize your schema to the figure below, no more join is needed.

![](https://www.mssqltips.com/tipimages2/7114_implement-dimension-denormalization-synapse-mapping-data-flow.002.png)

直接上结论:

- Normalization is used when faster insertion, deletion and update anomalies and data consistency are necessarily required. (write heavy I/O)
- Denormalization is used when faster searchs is required. (read heavy I/O pattern)



## Parquet压缩指南

for more details, [refer here](https://learn.microsoft.com/en-us/azure/data-factory/format-parquet)

### Dataset propserties

For a full list of sections and properties available for defining datasets, see the [Datasets](https://learn.microsoft.com/en-us/azure/data-factory/concepts-datasets-linked-services) article. This section provides a list of properties supported by the Parquet dataset.

| Property         | Description                                                  | Required |
| :--------------- | :----------------------------------------------------------- | :------- |
| type             | The type property of the dataset must be set to **Parquet**. | Yes      |
| location         | Location settings of the file(s). Each file-based connector has its own location type and supported properties under `location`. **See details in connector article -> Dataset properties section**. | Yes      |
| compressionCodec | The compression codec to use when writing to Parquet files. When reading from Parquet files, Data Factories automatically determine the compression codec based on the file metadata. Supported types are "**none**", "**gzip**", "**snappy**" (default), and "**lzo**". Note currently Copy activity doesn't support LZO when read/write Parquet files. | No       |

下面是定义type, `snappy`是默认的codec written in google and open sourced in 2011.

```json
{
    "name": "ParquetDataset",
    "properties": {
        "type": "Parquet",
        "linkedServiceName": {
            "referenceName": "<Azure Blob Storage linked service name>",
            "type": "LinkedServiceReference"
        },
        "schema": [ < physical schema, optional, retrievable during authoring > ],
        "typeProperties": {
            "location": {
                "type": "AzureBlobStorageLocation",
                "container": "containername",
                "folderPath": "folder/subfolder",
            },
            "compressionCodec": "snappy"
        }
    }
}
```



## 创建external tables in synpase SQL

Reference please see [here](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables?tabs=hadoop)

有两种external tables:

- **Hadoop external tables**
  - read and export in various formats including `csv`,`parquet` and `ORC`
  - Availabile in dedicated sql pool
- **Native external tables**
  - read and export data in various formats such as `csv` and `parquet`
  - available in serverless SQL pool



比较两种external table

| External table type                                          | Hadoop                                                       | Native                                                       |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| Dedicated SQL pool                                           | Available                                                    | Only Parquet tables are available in **public preview**.     |
| Serverless SQL pool                                          | Not available                                                | Available                                                    |
| Supported formats                                            | Delimited/CSV, Parquet, ORC, Hive RC, and RC                 | Serverless SQL pool: Delimited/CSV, Parquet, and [Delta Lake](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/query-delta-lake-format) Dedicated SQL pool: Parquet (preview) |
| [Folder partition elimination](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables?tabs=hadoop#folder-partition-elimination) | No                                                           | Partition elimination is available only in the partitioned tables created on Parquet or CSV formats that are synchronized from Apache Spark pools. You might create external tables on Parquet partitioned folders, but the partitioning columns will be inaccessible and ignored, while the partition elimination will not be applied. Do not create [external tables on Delta Lake folders](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/create-use-external-tables#delta-tables-on-partitioned-folders) because they are not supported. Use [Delta partitioned views](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/create-use-views#delta-lake-partitioned-views) if you need to query partitioned Delta Lake data. |
| [File elimination](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables?tabs=hadoop#file-elimination) (predicate pushdown) | No                                                           | Yes in serverless SQL pool. For the string pushdown, you need to use `Latin1_General_100_BIN2_UTF8` collation on the `VARCHAR` columns to enable pushdown. |
| Custom format for location                                   | No                                                           | Yes, using wildcards like `/year=*/month=*/day=*` for Parquet or CSV formats. Custom folder paths are not available in Delta Lake. In the serverless SQL pool you can also use recursive wildcards `/logs/**` to reference Parquet or CSV files in any sub-folder beneath the referenced folder. |
| Recursive folder scan                                        | Yes                                                          | Yes. In serverless SQL pools must be specified `/**` at the end of the location path. In Dedicated pool the folders are always scanned recursively. |
| Storage authentication                                       | Storage Access Key(SAK), AAD passthrough, Managed identity, Custom application Azure AD identity | [Shared Access Signature(SAS)](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-storage-files-storage-access-control?tabs=shared-access-signature), [AAD passthrough](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-storage-files-storage-access-control?tabs=user-identity), [Managed identity](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-storage-files-storage-access-control?tabs=managed-identity), [Custom application Azure AD identity](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-storage-files-storage-access-control?tabs=service-principal). |
| Column mapping                                               | Ordinal - the columns in the external table definition are mapped to the columns in the underlying Parquet files by position. | Serverless pool: by name. The columns in the external table definition are mapped to the columns in the underlying Parquet files by column name matching. Dedicated pool: ordinal matching. The columns in the external table definition are mapped to the columns in the underlying Parquet files by position. |
| CETAS (exporting/transformation)                             | Yes                                                          | CETAS with the native tables as a target works only in the serverless SQL pool. You cannot use the dedicated SQL pools to export data using native tables. |



## Disaster recovery and failover

https://learn.microsoft.com/en-us/azure/storage/common/storage-disaster-recovery-guidance?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json%20https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fanswers%2Fquestions%2F32583%2Fazure-data-lake-gen2-disaster-recoverystorage-acco.html





## load files in Synapse

在synapse中, 用SQL读取三种文件的读取方法:

- csv
- parquet
- json
  - [Query JSON files using serverlesss SQL pool in Synapse](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/query-json-files)
  - [medium article working with Azure Synapse SQL and JSON](https://medium.com/codex/working-with-azure-synapse-sql-and-json-b052edc94180)
  - [stackoverflow openrowset field delimiter](https://stackoverflow.com/questions/70803261/azure-synapse-query-json-using-openrowset-fieldterminator-value-0x0b)



​	
