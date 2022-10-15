WITH

fct_suburb_crime_wa_fin_yearly AS (
    SELECT
        *
    FROM {{ ref('fct_suburb_crime_wa_fin_yearly') }}
),

dim_suburb_geography AS (
    SELECT
        *
    FROM {{ ref('dim_suburb_geography') }}
),

dim_date AS (
    SELECT
        *
    FROM {{ ref('dim_date') }}
),

base AS (
    SELECT
         CRIME.dim_date_sk
        ,GEO.suburb_id
--      ,GEO.suburb_state_id
        ,GEO.suburb
--      ,GEO.state
--      ,GEO.postcode
--      ,GEO.longitude
--      ,GEO.latitude
        ,CRIME.offence
        ,CRIME.offence_count
    FROM fct_suburb_crime_wa_fin_yearly CRIME
    LEFT JOIN dim_suburb_geography GEO on GEO.dim_suburb_sk = CRIME.dim_suburb_sk
    LEFT JOIN dim_date DATE on DATE.dim_date_sk = CRIME.dim_date_sk

ORDER BY dim_date_sk ASC
)

SELECT * FROM base	