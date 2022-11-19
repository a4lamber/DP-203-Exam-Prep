# Lab: connect with you azure storage account and sql database

In this lab, you will connect storage account and sql database resources you just created and 
create a table within the database.

## Getting started

Azure storage account offers
- blob
- file

We are gonna use the blob service since image is stored as blob in azure storage account. We 
are going to upload the images to the storage account with the following steps:
- create a container (for blob storage, u have to create a container first)
- upload images to it (available in the following files)


## Instruction
- Open data studio (i don't have SMSS) 
- connect to your database (有几种authtification method, admin, azure active directory and 
both)
- create a table with `1_create_table.sql`
- insert rows into the table with `2_insert_data.sql`
- query it!

