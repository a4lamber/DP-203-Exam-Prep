# Microsoft notes

Here are the organized notes from the official website that is available [here](https://learn.microsoft.com/en-us/certifications/exams/dp-203).



Now, let's use a check list to do this

- [ ] Chapter 1
- [ ] Chapter 2
- [ ] Chapter 3
- [ ] Chapter 4
- [ ] Chapter 5
- [ ] Chapter 6
- [ ] Chapter 7
- [ ] Chapter 8
- [x] Chapter 9 Large-Scale Data Processing with ADLS Gen2
- [ ] Chapter 10 

**Table of contents:**

[toc]

# Chapter 1: Azure for the DE x3

some basics.



## Module 1 Understanding the evolving world of data





# Chapter 2: Store data in Azure x5



# Chapter 3: Data integration at scale with ADF or Azure Synapse Pipeline



# Chapter 4: Realize integrated analytical solutions with Azure Synapse Analytics



# Chapter 5: Work with data warehouses using Azure Synapse Analytics



# Chapter 6: Perform data engineering with Azure Synapse Apache Spark Pools



# Chapter 7: Work with Hybrid Transactional and Analytical processing solutions using Azure Synapse Analytics x3



# Chapter 8: Data Engineering with Azure Databricks x5





# Chapter 9: Large-scale Data Processing with ADLS Gen 2 X 3

For better use the insight you could have got from unstructured data 

## Module 1 Introduction to ADLS

In this module

- learn ADLS
- Create an Azure storage account by using Azuring portal
- Compare ALDS Gen 2 and Azure Blob Storage
- Review the use cases for Data Lake Storage



**ADLS Gen2**

- Benefits
  - Hadoop compatible access
    - 和HDFS很相似，直接用Azure Databricks, Azure Synapse Analytics and Azure HDinsight 来处理和分析就可以，不需要moving data between the environment
  - Security
    - Supports access contraol lists (ACLs) and Portable Operating System Interface (POIX) permissions
    - set permissions at a directory or file level.
    - security 可以通过Hive, Spark and Azure storage explorer 来configure
  - Performance
    - organize data with dierarchy of directories (也叫hierarchy namedspace often)
  - Data redundancy
    - with locally redundant storage (LRS) or Geo-redundant storage (GRS)



ADLS 2是基于 blob storage的威力加强版

- supports hierarchy 
- fast I/O

```python
if hierarchical_namespace == "Enabled"
		return "ADLS GEN 2"
else
		return "Azure Blob Storage"
```

ADLS一般是与其它service联合起来运用的, 不同公司的架构，都大同小异，根据业务需求，可以从大数据中挖掘:

- Ingestion
  - **ADF + ADLS Gen 2** for batch movement of data
  - Real-time ingestion of data, **Stream analytics or Apache Kafka for HDinsight  + ALDS Gen 2**
- Store: ADLS Gen2来储存
- Prep and train: Perform data preparation and model tranining and scoring for data science solutions
- Model and serve: 定义为technologies that will present the data to users, 和其它数据库一起such as Synapse, Cosmos DB, Azure SQL Database or Azure analysis service, 然后统一用Power BI来调用



三个azure-based architecture for different companies

- Modern data warehouse
- Advanced analytics on big data
- Real-time analytics



## Module 2 Upload data to ADLS

too ez



## Module 3 Secure your Azure Storage account

In this module

- Explore Azure Data Lake enterprise-class security features
- Undetstand storage account keys
- Understand shared access signatures (SAS)
- Undetstand transport-level encryptions with HTTPS
- Understand Advanced Threat Protection
- Control network access



### Explore Azure Storage features

作为Contoso的DE,  竞争公司有了个data breach, 现在你老板让你检查一遍organization's data security, 你从这五个角度argue Azure的安全性

- Encryption at rest
  - 写入Azure Storage数据库的都有storage service encryption (SSE) with a 256-bit Advanced Encryption Standard (AES) cipher and is **FIPS 140-2 compliant**.
  - 加密解密不收费，而且是强制执行的
  - 对于虚拟机, Azure让你可以对虚拟硬盘 (Virtual hard disks (VHDs)进行加密) 用Azure Disk Encryption
    - for windows images, `Bitlocker`
    - for Linux `dm-crypt`
- Protect the data in transit
- Support browser cross-domain access
- Control who can access data
- Audit storage access
  - 用AZURE的storage analytics services来log every operations in real time



视频的笔记

- secure and auditable to meet bussiness compliance
- 加密通信: encrypyted 256-bit cypher, decypter is automatically
- HTTPS communication protocol (支持加密)
- 三种获得权限的方法level of accesss
  - SAS or key
  - Azure actice directory

- Azure analytics记录发生的一切
  - log every request



### Understanding shared access signature (SAS)

三种数据库权限:

- Account key数据库对于in-house application, 完全放心
- 对于第三方，用SAS, 其实就是一段字符串attached to a URI





### Understand Advanced Threat Protection for Azure Storage

也就是要额外收费的，叫做microsoft defender的一个保护系统，支持

- Blob storage
- azure files
- ADLS Gen 2

可以来检测storage activity anomalies, 同时trigger email to you for warnings!

就在storage account --> security + networking --> Microsoft defender for Cloud

叫这名字也蛮简单的



### Role-based access control (RBAC)

Along with RBAC, 同时也支持access control lists (ACLs) that are POSIX-compliant

> POSIX是什么吊玩意? 



# Chapter 10: Implement a Data Streaming Solution with Azure Streaming Analytics x 3

