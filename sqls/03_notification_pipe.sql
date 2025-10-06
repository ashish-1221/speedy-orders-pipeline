use role accountadmin;
CREATE OR REPLACE NOTIFICATION INTEGRATION SPEEDY_QUEUE_INTEGRATION
  ENABLED = TRUE
  TYPE = QUEUE
  DIRECTION = OUTBOUND
  NOTIFICATION_PROVIDER = AWS_SNS
  AWS_SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:820344675011:speedyorderstopic'
  AWS_SNS_ROLE_ARN = 'arn:aws:iam::820344675011:role/snowflake-new-developer';

describe notification integration speedy_queue_integration;

GRANT USAGE ON INTEGRATION SPEEDY_QUEUE_INTEGRATION TO ROLE sysadmin;

use role sysadmin;
create or replace pipe speedy_pipe
    auto_ingest = true
    aws_sns_topic = '<sns-topic-arn>'
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

-- check the status of the pipe
select system$pipe_status('speedy_pipe');
