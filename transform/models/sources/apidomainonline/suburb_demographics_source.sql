with demographics as (
    SELECT
        SPLIT_PART("file_name", '_', 0) AS "api_endpoint"
        ,SPLIT_PART("file_name", '_', 3) AS "state"
        ,SPLIT_PART("file_name", '_', 4) AS "suburb"
        ,SPLIT_PART("file_name", '_', 5) AS "postcode"
        ,SPLIT_PART(SPLIT_PART("file_name", '_', 7), '.', 1) AS "api_response_code"
        ,"payload":demographics.year::varchar AS "year"
        ,"payload":demographics.type::varchar AS "type"
        ,"payload":demographics.total::varchar AS "total"
        ,f1.value:composition::varchar  as "composition"
        ,f1.value:label::varchar as "label"
        ,f1.value:value::number  as "value"
    FROM {{source('apidomainonline', 'raw_apidomainonline')}} p
        ,lateral flatten(input => p."payload", path => 'demographics') f
        ,lateral flatten(input => f.value) f1
    WHERE "file_name" ILIKE '%demographics%'
)

select * from demographics