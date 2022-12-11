WITH

prep_suburb_demographics AS (
    SELECT
        *
    FROM {{ ref('prep_suburb_demographics') }}
),

base AS (
    SELECT
		--Primary key
         suburb_demographics_sk AS suburb_demographics_pk

        --Foreign Keys
        ,dim_suburb_sk
		,dim_date_sk
		 
        --Information
--        ,suburb
--        ,postcode
--        ,state
--        ,year
        ,demographic_type
        ,composition
        ,response_option
        ,total
        ,value
    FROM prep_suburb_demographics
)

SELECT * FROM base	