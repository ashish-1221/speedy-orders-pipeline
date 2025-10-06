-- create a storage integration object
use role accountadmin;
create or replace storage integration SPEEDY_INTEGRATION
    type = EXTERNAL_STAGE
    storage_provider = 'S3'
    storage_aws_role_arn = 'arn:aws:iam::820344675011:role/snowflake-new-developer'
    enabled = TRUE
    STORAGE_ALLOWED_LOCATIONS = ('s3://amazon-products-dataset-2309/speedy_service_files/');

DESCRIBE INTEGRATION SPEEDY_INTEGRATION;

--------------------------------------------------------------------------------------------------------------------
-- create an external stage
--------------------------------------------------------------------------------------------------------------------


use role sysadmin;
use database bakery_db;
create schema delivery_orders;
use schema delivery_orders;

create stage bakery_db.delivery_orders.speedy_stage
    storage_integration = SPEEDY_INTEGRATION
    url = 's3://amazon-products-dataset-2309/speedy_service_files/'
    file_format = (type = json);

list @speedy_stage;

select
    $1:"Order id",
    $1:"Order dateime",
    $1:"items"
from
    @speedy_stage;

create or replace table speedy_orders_raw_stg (
    order_id varchar,
    order_date timestamp,
    items variant,
    source_file_name varchar,
    load_ts timestamp
);
-------------------------------------------------------------------------------------------------------
-- creating a notification integration
-------------------------------------------------------------------------------------------------------
use role accountadmin;
CREATE OR REPLACE NOTIFICATION INTEGRATION SPEEDY_QUEUE_INTEGRATION
  ENABLED = TRUE
  TYPE = QUEUE
  DIRECTION = OUTBOUND
  NOTIFICATION_PROVIDER = 'AWS_SQS'
  AWS_SQS_ARN = 'arn:aws:sqs:us-east-1:820344675011:speedyordersqueue'
  AWS_SQS_ROLE_ARN = 'arn:aws:iam::820344675011:role/snowflake-new-developer';
