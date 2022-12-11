WITH
prep_suburb_demographics AS (
    SELECT
        *
    FROM {{ ref('prep_suburb_demographics') }}
),

dim_date AS (
    SELECT
        distinct year_start_date
    FROM {{ ref('dim_date') }} 
),

base AS (
    SELECT
		--Primary key
         suburb_demographics_sk AS suburb_demographics_pk

        --Foreign Keys
        ,DEMO.dim_suburb_sk
		,DT.year_start_date as dim_date_sk

		 
        --Information
        ,dim_date_sk as census_date
        ,census_valid_from
        ,census_valid_to
        ,demographic_type
        ,composition
        ,response_option
        ,total
        ,value
    FROM prep_suburb_demographics DEMO
    FULL OUTER JOIN dim_date DT -- Explode out all rows
        WHERE DT.year_start_date BETWEEN census_valid_from AND census_valid_to -- Filter rows to be at 1 per metric per suburb a year
)

SELECT * FROM base	