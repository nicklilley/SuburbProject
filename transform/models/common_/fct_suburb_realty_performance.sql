WITH

prep_suburb_realty_performance AS (
    SELECT
        *
    FROM {{ ref('prep_suburb_realty_performance') }}
),

base AS (
    SELECT
		--Primary key
         suburb_realty_performance_sk AS suburb_realty_performance_pk

        --Foreign Keys
        ,dim_suburb_sk
		,dim_date_sk
		 
        --Information
        ,suburb
        ,metric_type
        ,metric
        ,type_and_metric
        ,property_type
        ,value
        ,value_prefix
        ,value_suffix
        ,value_conditional_round
    FROM prep_suburb_realty_performance
)

SELECT * FROM base	