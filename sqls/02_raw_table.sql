use role sysadmin;
use database bakery_db;
create schema delivery_orders;
use schema delivery_orders;

create or replace table speedy_orders_raw_stg (
    order_id varchar,
    order_date timestamp,
    items variant,
    source_file_name varchar,
    load_ts timestamp
);

select
    $1:"Order id",
    $1:"Order datetime",
    $1:"Items"
from
    @speedy_stage;
