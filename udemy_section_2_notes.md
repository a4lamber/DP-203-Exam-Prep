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



## Interaction with SQL Server

