WITH

fct_suburb_realty_performance AS (
    SELECT
        *
    FROM {{ ref('fct_suburb_realty_performance') }}
),

dim_suburb_geography AS (
    SELECT
        *
    FROM {{ ref('dim_suburb_geography') }}
),

base AS (
    SELECT
         PERF.dim_date_sk
        ,GEO.suburb_id
--        ,GEO.suburb_state_id
        ,GEO.suburb
--        ,GEO.state
--        ,GEO.postcode
--        ,GEO.longitude
--        ,GEO.latitude
        ,PERF.metric
        ,PERF.metric_type
        ,PERF.property_type
        ,PERF.value
        ,PERF.value_prefix
        ,PERF.value_suffix
        ,PERF.value_conditional_round
    FROM fct_suburb_realty_performance PERF
    LEFT JOIN dim_suburb_geography GEO on GEO.dim_suburb_sk = PERF.dim_suburb_sk
    WHERE metric NOT IN ('5th Percentile Sold Price'
                        ,'25th Percentile Sold Price'
                        ,'75th Percentile Sold Price'
                        ,'95th Percentile Sold Price'
                        )
ORDER BY dim_date_sk ASC
)

SELECT * FROM base	