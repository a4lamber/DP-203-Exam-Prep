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









