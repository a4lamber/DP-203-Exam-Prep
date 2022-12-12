# Section 9 Security



[toc]







## Azure key vault

Key vault用来存:

- Certificate
- Encryption key
- Secrets
  - 比如存database password，这样不用存在application里了，可以直接问key vault要





## ADF Encryption - customer-managed key

要么microsoft-managed key, 但你也可以有customer-managed keys, 由于不同公司的数据安全的policy可能会不同

- ADF already encripts data at rest which also includes entity definitoins and any data that is cached
- The encryption is carried out with **Microsoft-managed keys**
- You can also define your own key (**customer-managed keys**) using Azure key vault services, 操作步骤如下
  - 建立一个新的ADF (确保里面没有任何resoruces like linked service)
  - 在Azure key vault中grant access给ADF permissions
    - unwrap key
    - wrap key
- 在azure key vault中定义一个key, copy一下
- 在ADF - **customer managed key**中, paste一下



## Encryption of synapse workspace



Procedures:

- create a key in **Azure key vault**
- Create a synpase workspace
  - 设置的security这一栏，有一项workspace encryption, 你可以直接调用刚创造的key



## Dedicated SQL pool transparent 





- 点开dedicate sql pool
- enable transparent data encryption (TDE)就可以了



Course instructor考到一题, reference [here](https://learn.microsoft.com/en-us/azure/azure-sql/database/transparent-data-encryption-byok-configure?tabs=azure-powershell&view=azuresql)





## Lab: data masking in synapse



- data masking
  - 隐藏部分信息from users or limit data exposure to non-privileged users
  - 有许多masking rules 
    - creadit card masking rule
      - xxxx-xxxx-xxxx-1234
    - email
      - axxx@xxxx.com
    - Default value
      - 0, xxxx, 01-01-1900
    - Custom string
      - Exposed prefix + padding string + exposed suffix
      - if 2 + 2 + 2 then 123456 --> 12**56
    - random number
- 操作细节:
  - in synpase, integrate, copy data tool
    - bulk insert
  - search your sql pool
    - Under security
    - dynamic data masking 里做选择 (admin excluded from)



做以下实验

```sql
-- create a user called UserA
CREATE USER UserA WITHOUT LOGIN;

-- give UserA access
GRANT SELECT ON [PERSON].[EmailAddress] TO UserA;

EXECUTE AS USER = 'UserA';

SELECT * FROM [PERSON].[EmailAddress];

-- Revert back to admin
REVERT;
```



## Lab Azure synapse Audit

- Enable auditing for an Azure SQL Pool in Synapse, 可以用来track database events and writes them to an audit log.
- Audit的用意是, regulatory compliance, gain insight on any anomalies
- Auditing can be enabled at server level and database level.



步骤:

- 创造一个Log Analytics Workspace
- Synapse workspace中
  - AZURE SQL Auditing中选择刚创造的log analytics, 可以把数据传输过去
- 在log analytics workspace中打开 (SQL)
- 你可以define rule for alert in here





## Data discovery and classification

- This feature provides capabilities for discovering, classifying, labelling and reporting the sesitive data in your database
  - **data discovery**: scan the database and identify columns that contains sensitive data.
  - Apply sensitivity label on column



步骤:

- new pool
- data discovery & classification





## Azure AD 介绍

- Azure AD
  - define users, managed group 
  - Role based access control (RABC)
  - 通过RABC grant access to me



## Lab - creating a user

这个lab主要教你怎么用AD创造user,然后根据RBAC来给用户不同的数据库的权限. User + permission = access to database.

步骤:

- create a user in AD called `sqlusrB`

- Log in your dedicated SQL pool, 写如下的query



```sql
-- Lab - Azure Synapse - Azure AD Authentication - Creating a user

-- pre-req: 在Azure AD中创建一个user,用户名和邮箱为
-- user id: sqlusrb
-- email: techsup1000gmail.onmicrosoft.com

-- Step1: 创造一个USER with EXTERNAL PROVIDER clause (refers to AD)
CREATE USER [sqlusrb@techsup1000gmail.onmicrosoft.com]
FROM EXTERNAL PROVIDER -- in this case, external provider is AD
WITH DEFAULT_SCHEMA = dbo;

-- Step2: 创造一个role
CREATE ROLE [readrole]

-- Step3: Grant permission to this role
GRANT SELECT ON SCHEMA::[dbo] TO [readrole]

-- Step4: Execute stored procedure, assign user to the particular role
EXEC sp_addrolemember N'readrole', N'newsql@techsup1000gmail.onmicrosoft.com'

-- Step5: login as sqlusrb
```

Now you need to 

- log in as `sqlusrb`
- 在additional connection string中定义`database = newpool` 
  - 这一步是因为你只给了newpool access, 没有给system database的权限

```sql
SELECT * FROM [dbo].[DimCustomer]
```



## Lab: synapse row-level security





```sql
-- Lab - Azure Synapse - Row-Level Security

-- 创建一个table
CREATE TABLE [dbo].[Orders] 
(  
    OrderID int,  
    Agent varchar(50),  
    Course varchar(50),  
    Quantity int  
);  

-- Insert rows into the table

INSERT INTO [dbo].[Orders] VALUES(1,'AgentA','AZ-900',5);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentA','DP-203',4);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentB','AZ-104',5);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentB','AZ-303',6);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentA','AZ-304',7);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentB','DP-900',8);


-- Create three database users
/*
你现在创建的这三个用户，你希望:
Supervisor: 可以access到所有信息
AgentA: 可以access到，where Agent = 'AgentA'的数据，就是只可以看到自己的业绩
同理for AgentB
*/

CREATE USER Supervisor WITHOUT LOGIN;  
CREATE USER AgentA WITHOUT LOGIN;  
CREATE USER AgentB WITHOUT LOGIN;  


-- Grant access to the tables for the users
-- 这一步给所有的权限

GRANT SELECT ON [dbo].[Orders] TO Supervisor; 
GRANT SELECT ON [dbo].[Orders] TO AgentA; 
GRANT SELECT ON [dbo].[Orders] TO AgentB; 

-- Create a new schema for the security function

CREATE SCHEMA Security;  

-- Create an inline table function
-- The function returns 1 when a row in the Agentcolumn is the same as the user executing the query 
-- (@Agent = USER_NAME()) or if the user executing the query is the Manager user (USER_NAME() = 'Supervisor').

CREATE FUNCTION Security.securitypredicate(@Agent AS nvarchar(50))  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS securitypredicate_result
WHERE @Agent = USER_NAME() OR USER_NAME() = 'Supervisor';  
-- @Agent代表Agent column


-- Create a security policy adding the function as a filter predicate. The state must be set to ON to enable the policy.

CREATE SECURITY POLICY Filter  
ADD FILTER PREDICATE Security.securitypredicate(Agent)
ON [dbo].[Orders] 
WITH (STATE = ON);  
GO

-- Lab - Azure Synapse - Row-Level Security

-- Allow SELECT permissions to the function

GRANT SELECT ON Security.securitypredicate TO Supervisor;
GRANT SELECT ON Security.securitypredicate TO AgentA;  
GRANT SELECT ON Security.securitypredicate TO AgentB;  

-- Test is for the different users

EXECUTE AS USER = 'AgentA';  
SELECT * FROM [dbo].[Orders];
REVERT;  
  
EXECUTE AS USER = 'AgentB';  
SELECT * FROM [dbo].[Orders];
REVERT;  
  
EXECUTE AS USER = 'Supervisor';  
SELECT * FROM [dbo].[Orders];
REVERT; 

-- Drop all of the artefacts

DROP USER Supervisor;
DROP USER AgentA;
DROP USER AgentB;

DROP SECURITY POLICY Filter;
DROP TABLE [dbo].[Orders];
DROP FUNCTION Security.securitypredicate;
DROP SCHEMA Security;


```





## Lab: column-level security



在上一个lab, 我们需要做一下clean up

```sql
DROP USER Supervisor;
DROP USER Agent A;
DROP USER Agent B;

DROP SECURITY POLICY FILTER;
DROP TABLE [dbo].[Orders];
DROP FUNCTION Security.securitypredicate;
DROP SCHEMA Security;
```









```sql
-- Lab - Azure Synapse - Column-Level Security

CREATE TABLE [dbo].[Orders] 
(  
    OrderID int,  
    Agent varchar(50),  
    Course varchar(50),  
    Quantity int  
);  

-- Insert rows into the table

INSERT INTO [dbo].[Orders] VALUES(1,'AgentA','AZ-900',5);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentA','DP-203',4);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentB','AZ-104',5);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentB','AZ-303',6);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentA','AZ-304',7);
INSERT INTO [dbo].[Orders] VALUES(1,'AgentB','DP-900',8);

-- Create three database users

CREATE USER Supervisor WITHOUT LOGIN;  
CREATE USER UserA WITHOUT LOGIN;  

-- Grant access to the tables for the users
-- 只给其中三列的权限，column-based security要简单多了
GRANT SELECT ON [dbo].[Orders] TO Supervisor; 
GRANT SELECT ON [dbo].[Orders](OrderID,Course,Quantity) TO UserA; 


-- Test is for the different users

EXECUTE AS USER = 'UserA';  
SELECT * FROM [dbo].[Orders];
SELECT OrderID,Course,Quantity FROM [dbo].[Orders];
REVERT;  
  
 
EXECUTE AS USER = 'Supervisor';  
SELECT * FROM [dbo].[Orders];
REVERT; 

-- Drop all of the artefacts

DROP USER Supervisor;
DROP USER UserA;

DROP TABLE [dbo].[Orders];
```









## Lab: ADLS Role based access control

看看Azure RBAC documentation. User + permission = access to data



步骤:

- create a user
- go to ADLS, access control, grant reader access to the user just created
- 现在user有了access to storage account, 但对里面的数据container, blob etc并没有权限





## Lab: ADLS Access Control Lists

ACL is part of the ADLS. 因为ADLS是hierarchy named space

- 直接在storage account中, 右键点击，创造ACL
  - grant access to container
  - grant access to folder





Summary:

- Azure AD + SQL Pool 的安全协议
  - 方法1: 
    - 创建user in AD 
    - in sql pool, Access control (RBAC) 给读取或者write权限
  - 方法2:
    - write in query in dedicated SQL pool
    - 给row level和column level的权限
- Azure AD + ADLS Gen 2 的安全协议
  - 创建user in AD
  - grant access to storage account
  - grant access in ADLS by ACLs 





## Lab: Synpase, external table authorization via managed identity



之前我们学习了synapse中创建external table的方法

- master key
- create scoped credential sastoken
- external data source
- external file format
- external table

但在代码中直接expose你的access key会暴露，不安全。



```sql
-- Lab - Azure Synapse - External Tables Authorization via Managed Identity

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P@ssw0rd@123';

-- Here we are now using the managed identity

CREATE DATABASE SCOPED CREDENTIAL AzureManaged
WITH IDENTITY = 'Managed Identity'

-- In the SQL pool, we can use Hadoop drivers to mention the source

CREATE EXTERNAL DATA SOURCE log_data_managed
WITH (    LOCATION   = 'abfss://data@datalake2000.dfs.core.windows.net',
          CREDENTIAL = AzureManaged,
          TYPE = HADOOP
)


CREATE EXTERNAL FILE FORMAT TextFileFormatManaged WITH (  
      FORMAT_TYPE = DELIMITEDTEXT,  
    FORMAT_OPTIONS (  
        FIELD_TERMINATOR = ',',
        FIRST_ROW = 2))


CREATE EXTERNAL TABLE logdatamanaged
(
    [Id] [int] NULL,
	[Correlationid] [varchar](200) NULL,
	[Operationname] [varchar](200) NULL,
	[Status] [varchar](100) NULL,
	[Eventcategory] [varchar](100) NULL,
	[Level] [varchar](100) NULL,
	[Time] [datetime] NULL,
	[Subscription] [varchar](200) NULL,
	[Eventinitiatedby] [varchar](1000) NULL,
	[Resourcetype] [varchar](1000) NULL,
	[Resourcegroup] [varchar](1000) NULL
)
WITH (
 LOCATION = 'cleaned/Log.csv',
    DATA_SOURCE = log_data_managed,  
    FILE_FORMAT = TextFileFormatManaged
)



SELECT * FROM logdatamanaged

-- If you want to clean up your resources

DROP EXTERNAL TABLE logdatamanaged
DROP EXTERNAL FILE FORMAT TextFileFormatManaged
DROP EXTERNAL DATA SOURCE log_data_managed
DROP DATABASE SCOPED CREDENTIAL AzureManaged
```







## Lab: Synpase, external table authorization via Azure AD Authentication



- Access (role based)
- shared access signature
- managed identity



实际上你给用户权限了，只要用它的账号login, 就能直接操作了

```sql


-- Here we want to create an external table based on the Azure AD user credentials.

CREATE EXTERNAL DATA SOURCE log_dataAD
WITH (    LOCATION   = 'abfss://data@datalake2000.dfs.core.windows.net',
          TYPE = HADOOP
)


CREATE EXTERNAL TABLE [logdata]
(
        [Id] [int] NULL,
	[Correlationid] [varchar](200) NULL,
	[Operationname] [varchar](200) NULL,
	[Status] [varchar](100) NULL,
	[Eventcategory] [varchar](100) NULL,
	[Level] [varchar](100) NULL,
	[Time] [datetime] NULL,
	[Subscription] [varchar](200) NULL,
	[Eventinitiatedby] [varchar](1000) NULL,
	[Resourcetype] [varchar](1000) NULL,
	[Resourcegroup] [varchar](1000) NULL
)
WITH (
 LOCATION = 'cleaned/Log.csv',
    DATA_SOURCE = log_dataAD,  
    FILE_FORMAT = TextFileFormat
)



SELECT * FROM logdata
```





## Lab: Synaspe Firewall



有两个功能：

- 限制访问的ip address
  - allow all
  - client ip only
- 允许其它azure product like data factory to access synapse





### Lab: ADLS and data factory via managed identity

- Access control中，可以创造一个data











