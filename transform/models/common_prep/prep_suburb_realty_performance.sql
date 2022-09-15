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
        ,suburb
        ,postcode
        ,state
        ,year
        ,month
        ,property_type
        ,metric
        ,value
    FROM suburb_realty_performance
)

SELECT * FROM base