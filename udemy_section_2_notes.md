# Section 2 Design and implement data storage



**Table of contents**

[toc]



## Azure Storage account

In this section, you will understand

- what's a Azure storage account?
- What does it offer?



**Azure storage account**分成两个tier,提供如下的服务, for [more](https://www.dremio.com/subsurface/azure-data-lake-services/). 

| -             | standard tier        | Premium tier                                                 |
| ------------- | -------------------- | ------------------------------------------------------------ |
| Blob storage  | ✅                    | ✅                                                            |
| Table storage | ✅                    | ✅                                                            |
| Queue storage | ✅                    | ✅                                                            |
| File storage  | ✅                    | ✅                                                            |
| Difference    | 机械硬盘for the win! | data storage on SSD for better I/O performance (only for blob) |



![](https://www.dremio.com/wp-content/uploads/2021/12/adls-chart.png)



In azure, 

- Azure storage account offers the following servieces
  - Blob service
    - 储存video, image etc
  - Table service
  - File service
  - DL



官方reference, [请看这里](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview).

## Host a SQL database in Azure

Outline:

- how to create a `SQL server` and `SQL database` in Azure

![Screenshot 2022-11-19 at 10.42.21](/Users/yixiangzhang/Documents/DP_203/assets/figure-1-sql-server.png)



正常步骤 for hosting a SQL database

1. Create a virtual machine
2. Install the database software
3. Create your database, tables and store your data
4. Admin tasks - backup, high availability

当这些deployment都handled by azure时，就很方便.



### DTU 

DTU concept 是耦合了memory, cpu, I/O的一个标准，计算用户用了多少计算资源, 这样来方便收费. Azure收费标准是按照DTU + disk storage (GB) 来收费的

![](https://www.spotlightcloud.io/hs-fs/hubfs/DTUBlogImage1.png?width=524&name=DTUBlogImage1.png)





### SQL Data Studio vs SQL Server Management Studio (SSMS)

在这门课里，用的是SSMS来管理和access database, 但SSMS不支持Mac OS, 那么只能用SQL Data Studio来管理了

|              | SQL Data Studio | SSMS |
| ------------ | --------------- | ---- |
| supported OS |                 |      |

login界面很相似，不需要担心



## **Lab** connect SQL database

For more details, please see the lab directory `./lab_connection_azure_storage_and_sql_db` for more detailed info.





## File formats

**Outline:**

- the history of evolution of data types for storing data



### csv file

- Advantage
  - ez to parse
  - ez to read
  - Ez to make sense of 
- Disadvantage
  - The data types of elements has to be inferred
  - Parsing becomes tricky when data contains commas
  - Column names may or may not be there



### relational table

To conquer this problem of inferring types we encounter in `csv`, we start to add schema (datatype for each column), thereby relational table.

- Advantage
  - Data is fully typed
  - Data fits in a table
- Disadvantage
  - Data has to be flat
  - Data is stored in a database, and data definition will be different for each database



### json file

> javascript object notation (json): it's an object with key-value pairs stored in it.



- Advantage

  - data can take any form (arrays, nested elements)
  - JSON is a widely accepted format on the web

- Disadvantage

  - Data has no schema enforcing

  - JSON objects can be really large with repeated keys

    

### Arva file

Arva is define by a schema (schema是json写的), row-based

- Advantages
  - data is fully typed
  - data is compressed automatically (less CPU usage)
  - schema (defined using JSON) comes along with the data
  - Schema can evolve over time, in a safe manner
- Disadvantage
  - Arvo support for some languages may be lacking
  - Can't "display" the data without the arvo (cuz it's compressed and serialized)



### Parquet file

Column-based storage format. 这个在OLAP的data warehouse里面很常用，原因有以下几点：

- OLAP系统中，数据动辄几百列，而BI Analyst只需要拿出其中的几列，在传统row-oriented database中，你为了提取这几列做aggregate, 你需要load几百行数据，然后parse and filter. Column-based database就不要提取那么多数据，所以像parquet这种file format，在OLAP的application很占优
- 在大数据时代，数据能否被压缩很重要，由于每一列数据，有很多重复项(举个例子全世界8 billion人填写自己的信息，那么国家这一栏只有200多个options, 性别只有两个options), 那你就可以利用这个重复项，进行一些encoding, 来节省空间。



上述几种file formats优缺点如下:

![](https://qph.cf2.quoracdn.net/main-qimg-e07fb018e63e4e41e06c8c4c4d5f5eb9-pjlq)

### File formats for big data

截止于2022年，比较流行的几种适合大数据的数据类型是avro, [protocol buffers](https://developers.google.com/protocol-buffers/), parquet and ORC. 

大数据时代需要考虑的重点是:

- 可压缩性 (节省空间不然动辄petabyte data)
- 分析时比较在意提取速度



For more reading, please refer [here](https://towardsdatascience.com/big-data-file-formats-explained-dfaabe9e8b33).





## **LAB** Create a Azure Data Lake Storage Gen 2 (ADLS)

For more details, please refer to the lab directory.



> Note: ADLS2 is built on top of storage account service. Create a storage account as usual and click [hierarchical namespace](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-namespace) in advanced setting. That's it! 





## POWER BI for viewing data







## Access Key

Outline:

- download Microsoft Azure Storage Explorer
- Access your datalake or account via 
  - subscription
  - account



You can navigate your self to the figure below via

- click the storage account which you enabled ADLS2
- click access key at side bar
- you will have **storage account name** and **key**. You could use these two as credentials to access your data

![Screenshot 2022-11-20 at 09.19.25](/Users/yixiangzhang/Documents/DP_203/assets/accesskey.png)







## Shared Access Signature



Shared Access Signature (SAS) is another way to give access to other uses to access your data lake. 你如果想有权限到某个数据湖或者数据库，你可以通过登陆subscription，来获得所有databases under the subscriptions的权限，或者你可以直接连某个数据库，通过一下的三种方式(如下图)



![Screenshot 2022-11-20 at 11.05.01](/Users/yixiangzhang/Documents/DP_203/assets/sas.png)

通过不同方式连接的数据库的括号内，例如`datalake0329`你可以看到后面的括号里，是一些对这个数据库的描述 `datalake0329(SAS, ADLS Gen2)` 就是指connected via SAS.

![Screenshot 2022-11-20 at 11.06.22](/Users/yixiangzhang/Documents/DP_203/assets/sas-connected-lake.png)



## Redundancy, Access Tier, Lifecycle policy and Costing

这一章主要讲redundancy, access tier, lifecycle policy and costing for azure storage account service.



### Redundancy

- Locally-redundant storage
  - 在同一个data center, 做三个copy
  - 预防：protect against server rack or driver failures
- Zone-redundant storage
  - 数据 is replicated synchronously across three Azure availability zones
  - 预防: data-center failure
- Geo-redundant storage
  - 包括了locally-redundant storage服务，顺便再另一个region做一个replication. (比如你prime location在central US, 那么East US 2). 传输用LRS
  - Cost分两部分: 你数据量x2, 以及传输的费用
- Read-access geo-redundant storage
  - 区别是，前者只有在primary center failure, 才能access到备份，但read-access任何时候都能access.
- Geo-zone-redudant storage
- Read access geo-zone redundant storage





### Access Tier

> Under `advanced setting`, 是一个blob level的功能，选择Hot or Cool or Archive



Access tier:

- Hot
- Cool (30)
- Archive (180)



而收费标准分这样几块

- $$ per GB for different access tiers
- $$ for operations such as read, write

这个概念和定期存款很像，90-day, 180-day, 360-day, 没到固定日期，那就要交额外的钱 (early deletion fee)。



### Lifecycle Policy

对于大型公司来说，有millions of files, 由于access tier是file or blob level, 人工来做或者自己写script来把不常用的blob, based on last accessed day, change to archive or cool tier.这时候你可以用lifecycle management来处理这个事情.

Lifecycle management is just an automated way of changing files for one access tier to another.



 


### Costing

可以点击subscription然后做cost analysis and management, 可以设置budget来提醒你目前的收费标准



## Reference

- [azure data lake storage gen 2 ms learning documentation](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction)

- 
- 



