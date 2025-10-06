

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
