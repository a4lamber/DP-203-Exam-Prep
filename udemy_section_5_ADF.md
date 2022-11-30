# Section 5 Azure ADF

学习Azure ADF, tool for ETL of batch processing.

[toc]





# ADF Introduction







## ELT vs ETL

老生常谈了



|            | ETL                                 | ELT                             |
| ---------- | ----------------------------------- | ------------------------------- |
| 支持的工具 | ADF, SQL Server Integration Service | ADF, Synapse                    |
| 介绍       | 需要transform engine                | load and tranform in the target |
|            |                                     |                                 |



## what is ADF?

- cloud based ETL tool
- create data-driven workflows which helps orchestrate data movements
- It can also help to transform data



**AZF process:**

- connect to the required data sources
- next step is to ingest the data from the srouce
- transform the data in the pipeline if required
- Publish the data onto a destination - Azure Data Warehouse, Azure SQL Database, Azure Cosmos DB
- montior the pipeline as it is running



## AZF Components

![](https://www.cathrinewilhelmsen.net/images/adf/04-overview-azure-data-factory-components/AzureDataFactoryComponents_Overview.png)

- `Linked Services`:  it is like a connection string. 
- `Datasets`: a named view of the data that is used to reference data in the activities.
- `Activity`: 一些操作
- `pipeline`: logical grouping of Activities from DF
- `Compute`: 无论你只是copy, 或者ETL on any data, ADF都需要有一个板块来做这些事情，也就是compute infrastructure, AKA `Integration Runtime`. fully managed by ADF.



![](https://miro.medium.com/max/1024/1*TASY1GYqydn2gaIlWWbaEg.png)



## Lab copy .csv and parquet

略，和synapse一摸一样的操作方式, 毕竟都是用了同样的`integration runtime` as 





## Lab generate parquet file

内容:

- copy data then map into parquet with a pipeline
- `.csv` to `.parquet`



## Lab using query to transfer data

内容:

- Copy data from **SQL database** (adventureWork) to synpase dedicated SQL pool



在定义source的linked service时，选择query, 把数据弄进去就好



## Mapping data flows

现在我们只用了**copy data tool** for copy for now. 用mapping data flows可以让你transform

- This helps to visualize the data transformations in ADF
- 你不需要写代码就能transformation
  - 实际上非常呆, 就是UI for SQL
- data flow runs on Apache Spark Cluster unlike Azure integration runtime
- 有一个`debug mode`



## Lab mapping the data flow

略，dimensional modelling in ADF, CODE-LESS version罢了

流程：

- 创建Fact table
  - 创建dataflow feature (activity中的一种)
    - 定义data flow名字 这里就叫`dimFactFlow`
    - 定义source, dataset image存在哪，linked service
    - codeless SQL transformation(join, where etc) + null handling + surrogate key
    - manual定义schema, 或者infer schema (不推荐)
    - 定义sink, dataset, linked service
  - 创建pipeline
    - 拖入一个data flow activity, 并选择刚刚创建的那个`dimFactFlow`
    - publish and manual trigger
    - 等待
- 创建dim table (同上)



## Using Cache sink and lookup





## Lab use Cache Sink



## Lab no duplicate rows

略



## Self-hosted Integration Runtime



有些时候你用ADF来做ETL, 你需要把on-prem的数据库移植，这时候你就需要self-hosted integration, 来模拟这种情况，我们看以下的scenario:

- 第一步: set up Nginx webserver in VM

  - Create a VM on the cloud platform (OS: Windows server 2019) 
    - set up **Nginx** webserver
      - Inbound ports `HTTP(80)` (为什么?)
    - Create a virtual net (resource) 
    - Create a subnet (resource)

  - 进入vm, 下载nginx webserver, 并安装

  - run it in command line

  - done

- 第二步: 

  - 建立一个connection: self-hosted integration runtime in data factory
    - 获得key, credential来可以access
  - 在VM中下载integration runtime 并且安装
    - Register with the key for integration runtime
  - 等待，done!



## Lab Copy activity with self-hosted 

很类似，只是连接的source选择filesystem, binary







## Processing JSON Arrays and Objects

略



## Lab Metadata activity

略











