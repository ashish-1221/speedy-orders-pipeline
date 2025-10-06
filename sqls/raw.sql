-- create a storage integration object
use role accountadmin;
create or replace storage integration SPEEDY_INTEGRATION
    type = EXTERNAL_STAGE
    storage_provider = 'S3'
    storage_aws_role_arn = '<aws-iam-arn>'
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
    $1:"Order datetime",
    $1:"Items"
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
  NOTIFICATION_PROVIDER = AWS_SNS
  AWS_SNS_TOPIC_ARN = '<aws-sns-topic-arn>'
  AWS_SNS_ROLE_ARN = '<aws-iam-role-arn>';

describe notification integration speedy_queue_integration;

-- grant usage of the notification integration to the sysadmin,
-- using which we will create the snowpipe
use role accountadmin;
GRANT USAGE ON INTEGRATION SPEEDY_QUEUE_INTEGRATION TO ROLE sysadmin;


----------------------------------------------------------------------------------------------
-- Creating a pipe object
----------------------------------------------------------------------------------------------
use role sysadmin;
create or replace pipe speedy_pipe
    auto_ingest = true
    aws_sns_topic = '<aws-sns-topic-arn>'
    as
    copy into bakery_db.delivery_orders.speedy_orders_raw_stg
    from (
        select
            $1:"Order id",
            $1:"Order datetime",
            $1:"Items",
            metadata$filename,
            current_timestamp()
        from @speedy_stage
    );


alter pipe speedy_pipe refresh;

select * from bakery_db.delivery_orders.speedy_orders_raw_stg;

list @speedy_stage;

-- check the status of the pipe
select system$pipe_status('speedy_pipe');


---------------------------------------------------------------------------------------------
-- Transforming Data with Dynamic Tables
---------------------------------------------------------------------------------------------
create dynamic table speedy_orders
    target_lag = '1 minute'
    warehouse = BAKERY_WH
    as
    select
        order_id,
        order_date,
        value:"Item"::varchar as baked_good_type,
        value:"Quantity"::number as quantity,
        source_file_name,
        load_ts
    from bakery_db.delivery_orders.speedy_orders_raw_stg,
    lateral flatten (input => items);

select * from speedy_orders;