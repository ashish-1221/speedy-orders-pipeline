-- create a storage integration object
use role accountadmin;
create or replace storage integration SPEEDY_INTEGRATION
    type = EXTERNAL_STAGE
    storage_provider = 'S3'
    storage_aws_role_arn = '<aws-iam-role-arn>'
    enabled = TRUE
    STORAGE_ALLOWED_LOCATIONS = ('<path-to-s3-folder-bucket>');

DESCRIBE INTEGRATION SPEEDY_INTEGRATION;
