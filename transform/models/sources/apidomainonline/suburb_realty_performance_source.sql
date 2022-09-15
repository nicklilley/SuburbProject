WITH realty_performance as (
    SELECT
         SPLIT_PART(file_name, '_', 6) AS api_endpoint
        ,SPLIT_PART(file_name, '_', 0) AS state
        ,SPLIT_PART(file_name, '_', 2) AS suburb
        ,SPLIT_PART(file_name, '_', 3) AS postcode
        ,SPLIT_PART(SPLIT_PART(file_name, '_', 5), '.', 1) AS api_response_code
        ,f.value:year AS year
        ,f.value:month AS month
        ,SPLIT_PART(SPLIT_PART(file_name, '_', 7), '.', 1) AS property_type
        ,f1.key AS metric
        ,f1.value AS value
    FROM {{source('apidomainonline', 'raw_apidomainonline')}} p
        ,lateral flatten(input => p.payload, path => 'series', outer => true) f
        ,lateral flatten(input => f.value:values) f1
    WHERE file_name ILIKE '%suburbPerformanceStatistics%'
)

SELECT * FROM realty_performance