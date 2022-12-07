# Section 10 Optimization

[toc]





## Best practice for structuring files



For a well-engineer data lake structure

- normally when designing a data-lake, you might create multiple zones
- the zones can map to separate containers, such as 
  - `RAW Zone`: 
  - `Filtered Zone`: here basic filtering has been carried out. Unnecessary columns removed
  - `Curated Zone`: data you perform analytics on



以下三点要注意

- Hierarchy used for storage
  - \Department\RAW\DataSource\YYYY\MM\DD\File.json

- Compress files
  - use compressed files like Parquet
  - less time is spend on data transfer
  - The MPP architecture of the data warehouse can be used for decompression
- Use multiple sources files
  - one mode for on file



## Storage account: query acceleration



比如.NET project中，你是需要fast query的

- query acceleration feature 
  - 现在只支持Csv, json 





## Azure monitor 



Azure montior service monitor your usage, and you can set up condition to alert you with automation tool such as email alert etcs



