WITH 

suburb_demographics AS (
    SELECT
        *
    FROM {{ ref('suburb_demographics_source') }}
  --To Do (upstream deletes): WHERE is_deleted = FALSE
),

base AS (
    SELECT
        --Surrogate Key
         {{ dbt_utils.surrogate_key(['response_option', 'demographic_type','suburb','postcode','year'])}} AS suburb_demographics_sk

        --Foreign Keys
        ,{{ dbt_utils.surrogate_key(['suburb','postcode','state'])}} AS dim_suburb_sk
        ,to_date(year, 'YYYY') AS dim_date_sk 

        --Information
        ,load_timestamp_tz
        ,to_date(year, 'YYYY') AS census_valid_from 
        ,dateadd(MONTH, 59, census_valid_from) AS census_valid_to
        ,suburb
        ,postcode
        ,state
        ,year
        ,demographic_type
        ,composition
        ,response_option
        ,total
        ,value
    FROM suburb_demographics
),

--Multiple identical files may have been loaded. Deduplicate macro takes the values from the most recently loaded file
dedupe AS (
 {{ dbt_utils.deduplicate(
    relation='base',
    partition_by='suburb_demographics_sk',
    order_by="load_timestamp_tz desc"
   )
}})

SELECT * FROM dedupe