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
- `Activity`:
- `pipeline`: logical grouping of Activities from DF
- `Compute`: 无论你只是copy, 或者ETL on any data, ADF都需要有一个板块来做这些事情，也就是compute infrastructure, AKA `Integration Runtime`. fully managed by ADF.



![](https://miro.medium.com/max/1024/1*TASY1GYqydn2gaIlWWbaEg.png)



## Lab copy .csv and parquet

略，和synapse一摸一样的操作方式, 毕竟都是用了同样的`integration runtime` as 





## Lab generate parquet file
