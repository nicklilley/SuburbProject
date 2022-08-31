WITH

prep_date AS (
    SELECT
        *
    FROM {{ ref('prep_date') }}
),

base AS (
    SELECT
		--Surrogate Key
          dim_date_sk
 
		--Information
		 ,week_of_year
         ,month_of_year
         ,month_name
         ,month_name_short
         ,month_start_date
         ,month_end_date
         ,quarter_of_year
         ,quarter_start_date
         ,quarter_end_date
         ,year_number
         ,year_start_date
         ,year_end_date
    FROM prep_date
)

SELECT * FROM prep_date