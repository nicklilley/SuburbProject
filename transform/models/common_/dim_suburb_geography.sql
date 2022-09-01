WITH

prep_suburb_geography AS (
    SELECT
        *
    FROM {{ ref('prep_suburb_geography') }}
),

base AS (
    SELECT
		--Surrogate Key
         dim_suburb_sk

		--Natural key
		 ,suburb_id
		 
		--Information
		 ,suburb
		 ,postcode
		 ,state
		 ,longitude
		 ,latitude
		 ,latitude_precise
		 ,longitude_precise	 
		 ,dc
		 ,type
		 ,status
		 ,status_date
		 ,sa3
		 ,saname
		 ,sa4
		 ,sa4name
		 ,region
		 ,sa1_maincode_2011
		 ,sa1_maincode_2016
		 ,sa2_maincode_2016
		 ,sa2_name_2016
		 ,sa3_code_2016
		 ,sa3_name_2016
		 ,sa4_code_2016
		 ,sa4_name_2016
		 ,ra_2011
		 ,ra_2016
		 ,mmm_2015
		 ,mmm_2019
		 ,ced
		 ,altitude
		 ,charge_zone
		 ,phn_code
		 ,phn_name
		 ,lga_region
		 ,electorate
		 ,electorate_rating
    FROM prep_suburb_geography
)

SELECT * FROM base