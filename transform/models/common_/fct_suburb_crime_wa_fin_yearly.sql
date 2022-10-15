WITH

prep_suburb_crime_wa AS (
    SELECT
        *
    FROM {{ ref('prep_suburb_crime_wa') }}
),

base AS (
    SELECT
		--Primary key
         suburb_crime_wa_sk AS suburb_crime_wa_pk

        --Foreign Keys
        ,dim_suburb_sk
		,dim_date_sk
		 
        --Information
        ,offence
        ,total_annual_count AS offence_count
    FROM prep_suburb_crime_wa
)

SELECT * FROM base	