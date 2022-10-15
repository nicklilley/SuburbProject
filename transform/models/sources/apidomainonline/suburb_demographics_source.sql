WITH demographics as (
    SELECT
         SPLIT_PART(file_name, '_', 6)::varchar AS api_endpoint
        ,SPLIT_PART(file_name, '_', 0)::varchar AS state
        ,SPLIT_PART(file_name, '_', 2)::varchar AS suburb
        ,SPLIT_PART(file_name, '_', 3)::varchar AS postcode
        ,SPLIT_PART(SPLIT_PART(file_name, '_', 5), '.', 1)::varchar AS api_response_code
        ,payload:demographics.year::varchar AS year
        ,payload:demographics.total::varchar AS total
        ,payload:demographics.type::varchar AS type
        ,f1.value:composition::varchar  as composition
        ,f1.value:label::varchar as response_option
        ,f1.value:value::number  as value
    FROM {{source('apidomainonline', 'raw_apidomainonline')}} p
        ,lateral flatten(input => p.payload, path => 'demographics') f
        ,lateral flatten(input => f.value) f1
    WHERE file_name ILIKE '%demographics%'
)

SELECT * FROM demographics