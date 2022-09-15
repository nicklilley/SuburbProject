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
        ,metric
        ,property_type
        ,value
    FROM prep_suburb_realty_performance
)

SELECT * FROM base	