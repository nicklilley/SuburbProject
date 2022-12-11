WITH

fct_suburb_demographics_yearly AS (
    SELECT
        *
    FROM {{ ref('fct_suburb_demographics_yearly') }}
    WHERE 1=1
    --AND DIM_SUBURB_SK in ('446da009063e4fe2e8ac4ea3aa8f352a','33e5e42232299693867fac3731e06571')
    AND demographic_type = 'GeographicalPopulation' -- Limit demographic data to just population
    AND DIM_DATE_SK BETWEEN '2012-01-01' AND '2021-01-01' -- Crime data doesnt exist prior to 2021, filter removes null demographic records from appearing
    
),

fct_suburb_crime_wa_fin_yearly AS (
    SELECT
         dim_date_sk
        ,dim_suburb_sk
        ,sum(offence_count) AS offence_count
    FROM {{ ref('fct_suburb_crime_wa_fin_yearly') }}
    --WHERE DIM_SUBURB_SK in ('446da009063e4fe2e8ac4ea3aa8f352a','33e5e42232299693867fac3731e06571')
    WHERE DIM_DATE_SK BETWEEN '2012-01-01' AND '2021-01-01'
    GROUP BY dim_date_sk, dim_suburb_sk
),

dim_suburb_geography AS (
    SELECT
        *
    FROM {{ ref('dim_suburb_geography') }}
),

base AS (
    SELECT 
       --  DEMO.dim_date_sk
--         GEO.suburb_id
        CRIME.dim_date_sk
        --,GEO.dim_datde_sk as geo_date
        ,DEMO.dim_date_sk as demo_date
        ,GEO.suburb
        ,GEO2.suburb as suburb2
        ,DEMO.DIM_SUBURB_SK
       -- ,CRIME.offence
        ,CRIME.offence_count
        ,DEMO.census_date
        ,DEMO.total as population
        ,DIV0(CRIME.offence_count, DEMO.total) * 100 as crime_rate_per_100_people
--        ,GEO.state
--        ,GEO.postcode
--        ,GEO.longitude
--        ,GEO.latitude
    FROM fct_suburb_demographics_yearly DEMO
    FULL OUTER JOIN fct_suburb_crime_wa_fin_yearly CRIME -- Explode all rows, this will give nulls if either Crime or Demographic data is missing
         ON CRIME.dim_date_sk = DEMO.dim_date_sk
         AND CRIME.dim_suburb_sk = DEMO.dim_suburb_sk
    LEFT JOIN dim_suburb_geography GEO ON GEO.dim_suburb_sk = CRIME.dim_suburb_sk -- Get Suburb Dimensions, this should probably be joined to join Crime and Demographic data and coalesced 
    LEFT JOIN dim_suburb_geography GEO2 ON GEO2.dim_suburb_sk = DEMO.dim_suburb_sk
)

SELECT * FROM base
    WHERE population is not null
	