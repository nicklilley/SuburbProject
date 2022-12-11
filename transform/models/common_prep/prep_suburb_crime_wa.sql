WITH 

suburb_crime_wa AS (
    SELECT
        *
    FROM {{ ref('suburb_crime_wa_source') }}
),

base AS (
    SELECT
        --Surrogate Key
         {{ dbt_utils.surrogate_key(['offence','suburb','postcode','financial_year'])}} AS suburb_crime_wa_sk

        --Foreign Keys
        ,{{ dbt_utils.surrogate_key(['suburb','postcode','state'])}} AS dim_suburb_sk
        ,to_date(LEFT(financial_year,4), 'YYYY') AS dim_date_sk 

        --Information
        ,suburb
        ,postcode
        ,state
        ,financial_year
        ,offence
        ,total_annual_count
        ,january_count
        ,february_count
        ,march_count
        ,april_count
        ,may_count
        ,june_count
        ,july_count
        ,august_count
        ,september_count
        ,october_count
        ,november_count
        ,december_count
    FROM suburb_crime_wa
    WHERE
         year(DIM_DATE_SK) < year (current_date) -- Remove values from current year, as crime data only present in the following year
)

SELECT * FROM base