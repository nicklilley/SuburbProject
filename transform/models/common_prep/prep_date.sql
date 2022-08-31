WITH

date AS (
{{ dbt_date.get_date_dimension("2006-01-01", "2030-12-31") }}
),

base as (
    SELECT
    date_day AS dim_date_sk
    ,*
    FROM date
)

SELECT * FROM base