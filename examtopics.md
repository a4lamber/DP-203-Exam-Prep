# Practice questions on exam topics

247题 in total; 10 topics



To-do out of 48 pages

- page 2 (2022/11/29)

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

- 12: design Synapse dedicated SQL pool with following requirements, 考点主要是slowly changing table 
  
  - Can return an employee record from a given point in time
  - Maintains the latest employee information
  - Minimizes query complexity
  - 问，how should you model the employee data?
  - 这一题udemy稍微接触过一点, alan描述了三种data warehouse的dimension changes. MS learn you module可以复习这一块 [here](https://learn.microsoft.com/en-us/training/modules/populate-slowly-changing-dimensions-azure-synapse-analytics-pipelines/). 
    
    

