-- To Do (Null values don't currently result in a row being created)
WITH 

suburb_realty_performance AS (
    SELECT
        *
    FROM {{ ref('suburb_realty_performance_source') }}
  --To Do (upstream deletes): WHERE is_deleted = FALSE
),

base AS (
    SELECT
        --Surrogate Key
         {{ dbt_utils.surrogate_key(['metric','suburb','postcode','year','month'])}} AS suburb_realty_performance_sk

        --Foreign Keys
        ,{{ dbt_utils.surrogate_key(['suburb','postcode','state'])}} AS dim_suburb_sk
        ,to_date((year||'-'||month),'YYYY-MM') AS dim_date_sk -- To Do (Should all date SKs be at same grain, e.g. year, day, yearmonth)

        --Information
        ,load_timestamp_tz
        ,suburb
        ,postcode
        ,state
        ,year
        ,month
        ,CASE   
            WHEN property_type = 'house' THEN 'House'
            WHEN property_type = 'unit' THEN 'Unit'
            ELSE property_type
            END AS property_type
        ,CASE
            WHEN metric = 'Lowest Listing Price' THEN 'Buy'
            WHEN metric = '5th Percentile Sold Price' THEN 'Buy'
            WHEN metric = 'Median Sold Price' THEN 'Buy'
            WHEN metric = 'Lowest Sold Price' THEN 'Buy'
            WHEN metric = 'Number of Listings' THEN 'Buy'
            WHEN metric = 'Number of Sold Auctions' THEN 'Buy'
            WHEN metric = 'Median Rent' THEN 'Rent'
            WHEN metric = 'Days on Market' THEN 'Buy'
            WHEN metric = '95th Percentile Sold Price' THEN 'Buy'
            WHEN metric = 'Highest Rent' THEN 'Rent'
            WHEN metric = 'Number of Rent Listings' THEN 'Rent'
            WHEN metric = '25th Percentile Sold Price' THEN 'Buy'
            WHEN metric = 'Lowest Rent' THEN 'Rent'
            WHEN metric = 'Number Auctioned' THEN 'Buy'
            WHEN metric = 'Discount Percentage (Listing Price/Sold Price)' THEN 'Buy'
            WHEN metric = 'Highest Sold Price' THEN 'Buy'
            WHEN metric = '75th Percentile Sold Price' THEN 'Buy'
            WHEN metric = 'Highest Listing Price' THEN 'Buy'
            WHEN metric = 'Median Listing Price' THEN 'Buy'
            WHEN metric = 'Number Sold' THEN 'Buy'
            ELSE 'No category'
            END AS metric_type
        ,metric
        ,metric_type || ' - ' || metric as type_and_metric
        ,value
                ,CASE
            WHEN metric = 'Lowest Listing Price' THEN '$'
            WHEN metric = '5th Percentile Sold Price' THEN '$'
            WHEN metric = 'Median Sold Price' THEN '$'
            WHEN metric = 'Lowest Sold Price' THEN '$'
            WHEN metric = 'Number of Listings' THEN ''
            WHEN metric = 'Number Auctioned' THEN ''
            WHEN metric = 'Median Rent' THEN '$'
            WHEN metric = 'Days on Market' THEN ''
            WHEN metric = '95th Percentile Sold Price' THEN '$'
            WHEN metric = 'Highest Rent' THEN '$'
            WHEN metric = 'Rent Listings' THEN ''
            WHEN metric = '25th Percentile Sold Price' THEN '$'
            WHEN metric = 'Lowest Rent' THEN '$'
            WHEN metric = 'Number of Sold Auctions' THEN ''
            WHEN metric = 'Discount Percentage (Listing Price/Sold Price)' THEN ''
            WHEN metric = 'Highest Sold Price' THEN '$'
            WHEN metric = '75th Percentile Sold Price' THEN '$'
            WHEN metric = 'Highest Listing Price' THEN '$'
            WHEN metric = 'Median Listing Price' THEN '$'
            WHEN metric = 'Number Sold' THEN ''
            ELSE ''
            END AS value_prefix
        ,CASE 
            WHEN metric = 'Lowest Listing Price' THEN 'K'
            WHEN metric = '5th Percentile Sold Price' THEN 'K'
            WHEN metric = 'Median Sold Price' THEN 'K'
            WHEN metric = 'Lowest Sold Price' THEN 'K'
            WHEN metric = 'Number of Listings' THEN ' listings'
            WHEN metric = 'Number Auctioned ' THEN ' auctioned'
            WHEN metric = 'Median Rent' THEN ''
            WHEN metric = 'Days on Market' THEN ' days'
            WHEN metric = '95th Percentile Sold Price' THEN 'K'
            WHEN metric = 'Highest Rent' THEN ''
            WHEN metric = 'Rent Listings' THEN ' listings'
            WHEN metric = '25th Percentile Sold Price' THEN 'K'
            WHEN metric = 'Lowest Rent' THEN ''
            WHEN metric = 'Number of Sold Auctions' THEN ' auctions'
            WHEN metric = 'Discount Percentage (Listing Price/Sold Price)' THEN '%'
            WHEN metric = 'Highest Sold Price' THEN 'K'
            WHEN metric = '75th Percentile Sold Price' THEN 'K'
            WHEN metric = 'Highest Listing Price' THEN 'K'
            WHEN metric = 'Median Listing Price' THEN 'K'
            WHEN metric = 'Number Sold' THEN ' sold'
            ELSE ''
            END::varchar AS value_suffix
        ,CASE 
            WHEN value_suffix = 'K' THEN value/1000
            ELSE value
            END::number(38,0) AS value_conditional_round
    FROM suburb_realty_performance
),

--Each file contains many years of year. Deduplicate macro takes the values from the most recently loaded file
dedupe AS (
 {{ dbt_utils.deduplicate(
    relation='base',
    partition_by='suburb_realty_performance_sk, property_type',
    order_by="load_timestamp_tz desc"
   )
}})

SELECT * FROM dedupe

