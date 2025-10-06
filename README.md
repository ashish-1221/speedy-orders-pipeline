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


## Author

Ashish Prasad Maharana | [maharanaashish72@gmail.com/https://github.com/ashish-1221]