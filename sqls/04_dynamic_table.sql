use role sysadmin;
use database bakery_db;
create schema delivery_orders;
use schema delivery_orders;

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