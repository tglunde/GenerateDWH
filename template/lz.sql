create or replace file format tfm_csv
  type = 'csv'
  field_delimiter = '\t'
  compression = gzip
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

create or replace stage tfm 
 storage_integration = DV01_TAP_DWH_S3_01
 url = 's3://tuid-dv01-s3-tap-dwh-staging-01/DV01_DB_STAGING/TFM_LZ/'
  FILE_FORMAT = tfm_csv;
  
create or replace external table SPOT_ITEMS_LZ 
  with location=@tfm/spot_items.csv.gz
  file_format = ( format_name = 'tfm_csv' );