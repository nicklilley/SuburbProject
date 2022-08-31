WITH 

suburb_demographics AS (
    SELECT
        *
    FROM {{ ref('suburb_demographics_source') }}
  --To Do (upstream deletes): WHERE is_deleted = FALSE
),

base AS (
    SELECT
        --Primary Key
      --  {{ dbt_utils.surrogate_key(['response_option', 'type','suburb','postcode','year'])}} AS suburb_demographics_pk
        {{ dbt_utils.surrogate_key(['suburb','postcode'])}} AS suburb_demographics_pk

        --Foreign Keys
        {{ dbt_utils.surrogate_key(['suburb', 'postcode'])}} AS dim_suburb_sk

        --Information
        ,suburb
        ,postcode
        ,state
        ,year
        ,type
        ,composition
        ,response_option
        ,total
        ,value
    FROM suburb_demographics
)

SELECT * FROM base