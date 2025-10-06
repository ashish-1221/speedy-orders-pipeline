# Speedy Orders ETL pipeline in Snowflake + AWS SNS

## Overview
This repository contains a modular, production-ready ETL pipeline using Snowflake's features and integrations with AWS S3 and SNS. The use case demonstrates how to automate ingestion, transformation, and analytics processing for bakery order data stored as JSON files in Amazon S3.

## Folder Structure
---
```
speedy-orders-pipeline
├─ data
│  ├─ raw_files
│  │  ├─ Orders_2023-09-04_12-30-00_12345.json
│  │  ├─ Orders_2023-09-04_12-30-00_12346.json
│  │  └─ Orders_2023-09-04_12-45-00_12347.json
│  └─ results
│     ├─ speedy_orders.csv
│     ├─ speedy_pipe_error_1
│     ├─ speedy_pipe_status
│     └─ storage_integration
├─ README.md
└─ sqls
   ├─ 00_preparation.sql
   ├─ 01_stage_setup.sql
   ├─ 02_raw_table.sql
   ├─ 03_notification_pipe.sql
   ├─ 04_dynamic_table.sql
   └─ raw.sql

```

## Steps for setting up Amazon SNS
1. Open Amazon SNS service from AWS console
2. Click on Create Topic in the Amazon SNS console.
3. In Type select *Standard*, and give the topic a name
4. Click on **Create Topic** button.
5. After the topic is created,Click on the **Edit** Button
6. In the *Access Policy* section,clear the present policy, and attach the following policy, with modifications
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "<SNOWFLAKE_AWS_IAM_USER_ARN>"
      },
      "Action": "SNS:Subscribe",
      "Resource": "<SNS_TOPIC_ARN>"
    },
    {
      "Sid": "AllowSNSTopicPublishFromS3",
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
      "Action": "SNS:Publish",
      "Resource": "<SNS_TOPIC_ARN>",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "<BUCKET_OWNER_ACCOUNT_ID>"
        },
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:s3:::<BUCKET_NAME>"
        }
      }
    }
  ]
}


```
7. Click on *Save Changes*.
8. After the topic is created, click on Subscriptions on the overview panel, to create an subscriber to subscribe to the created topic.
9. Click on *Create Subscription*.
10. Select the topic ARN, that has just been created.
11. I am creating a Email notification, hence in *protocol* select **Email**.
12. In the endpoint give the *email id* you want to receive notification in.
12. Click on **Create Subscription**.
13. After this you will get a confirm subscription in the specified email. Please confirm it to continue..

## Configuring S3 bucket for SQS notifications
1. Open the AWS S3 console.
2. In the *Properties* tab search for **Event Notifications**.
3. Click on *Create Event notification*.
4. Provide *event name*.
5. In event types select appropiate events you want to receive notifications for.
6. In *Destination*, select **SNS Topic**, and select the topic you just created.

For testing, upload a file in S3 bucket and open the queue from the SQS console.
If you are receiving a message then all is good.

## Architecture

### Data Flow

1. AWS S3 stores incoming JSON order files.
2. Snowflake Storage Integration securely connects Snowflake to S3.
3. An external stage references the S3 bucket for file access.
4. A pipe and notification integration utilize AWS SNS to auto-ingest new files.
5. Raw data is loaded into a staging table.
6. A dynamic table flattens and transforms item records for analysis.

## Setup

1. Clone this repository.
2. Run each SQL file in order using Snowflake Worksheets or an automation tool:
    - 00_preparation.sql - Set up integrations/roles.
    - 01_stage_setup.sql - Create schema, stage, and files listing.
    - 02_raw_table.sql - Create and explore raw ingestion table.
    - 03_notification_pipe.sql - Notification setup and pipe for auto-ingestion.
    - 04_dynamic_table_transform.sql - Data flattening/transformation.
3. Check the pipe status and output:

```sql
SELECT SYSTEM$PIPE_STATUS('SPEEDY_PIPE');
```
4. Query transformed orders:

```sql
SELECT * FROM SPEEDY_ORDERS;
```


## Author

Ashish Prasad Maharana | [maharanaashish72@gmail.com/https://github.com/ashish-1221]