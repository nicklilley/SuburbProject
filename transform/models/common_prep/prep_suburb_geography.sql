WITH

suburb_geography AS (
    SELECT
        *
    FROM {{ ref('suburb_geography_source') }}
),

base AS (
    SELECT
		--Surrogate Key
          {{ dbt_utils.surrogate_key(['suburb','postcode','state'])}} as dim_suburb_sk

		--Natural key
		 ,suburb || '-' || postcode || '-' || state as suburb_id

		--Bad key - To Do: Clean data so that suburb + state is a viable natural key
		 ,suburb || '-' || state as suburb_state_id
		 
		--Information
		 --,suburb_id
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
    FROM suburb_geography
),

--Type 1: Only take the latest record
type1 AS (
    SELECT 
        row_number() OVER (PARTITION BY dim_suburb_sk ORDER BY status_date DESC) AS rn
        ,*
    FROM base
),

--Junk postcodes cleanup
type1_no_junk AS (
	SELECT
	*
	FROM type1
	WHERE 
	rn = 1 -- Only take latest record
	and type <> 'Post Office Boxes' -- Junk postcodes
	and postcode not like '69%' -- Junk postcodes
	and postcode not like '68%' -- Junk postcodes
	and suburb_id not in ('Trigwell-6393-WA','Stake Hill-6210-WA','Pinjar-6065-WA','Parklands-6180-WA','Melaleuca-6065-WA','Mariginiup-6065-WA','Little Italy-6355-WA','Lexia-6065-WA','Lakelands-6210-WA','Jandabup-6065-WA','Herron-6210-WA','Gnangara-6065-WA','Furnissdale-6210-WA','Dawesville-6210-WA','Crowea-6258-WA','Carani-6569-WA','Bunjil-6620-WA','Bouvard-6210-WA','Barragup-6210-WA') -- WA junk postcodes

)

SELECT * FROM type1_no_junk