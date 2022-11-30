# Section 6 Streaming with event hub



之前的几章讲了batching processing的实现:

- **Data storage**: ADLS gen2
- **Batch processing**: Spark 
- **Analytical Data Store**: Azure Synapse
- **Reporting**: Power BI
- **Orchestration**: Azure Data Factory





但现在需要做real-time processing:

- Real-time message ingestion: (ingestion后可以先存起来或者直接stream processing)
  - Apache Kafka
  - Azure Event hubs
- Data storage:
  - ADLS 2
  - blob
- Stream processing
  - Azure stream Analytics
  - Storm
  - Spark stream (sparkstream处理streaming data 实际上是near-real time 实际上是很小很小的batch processing而不是datagram实时处理, but good)
- Analytical data store
  - Azure Synapse
  - Spark, Hive, HBase
- Reporting
  - PowerBI



## What are Azure Event Hubs

Event hubs:

- a big data streaming platform (PaaS)
- 处理millions of events per second 



![](https://learn.microsoft.com/en-us/azure/event-hubs/media/event-hubs-about/event_hubs_architecture.png)

几个main components:

- **Event Producer**: producer通过不同的传输协议，传到event hub中
- **Partitions**: 
- **Consumer groups**: 不只是一个人需要access到你的streaming data, 所以是一个Event Receiver
- Throughput
- **Event Receiver**: 在这门课程里, event receiver为Azure Stream Analytics



## Lab send and receive event hub

c# setup is a pain in the ass.







 

## Azure Stream Analytics

