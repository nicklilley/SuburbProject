WITH suburb AS (
    SELECT
          f.value:id::varchar AS suburb_id
		 ,initcap(f.value:locality::varchar) AS suburb
		 ,f.value:postcode::varchar AS postcode
		 ,f.value:state::varchar AS state
		 ,f.value:long::varchar AS longitude
		 ,f.value:lat::varchar AS latitude
		 ,f.value:Lat_precise::varchar AS latitude_precise
		 ,f.value:Long_precise::varchar AS longitude_precise	 
		 ,f.value:dc::varchar AS dc
		 ,f.value:type::varchar AS type
		 ,f.value:status::varchar AS status
		 ,f.value:sa3::varchar AS sa3
		 ,f.value:sa3name::varchar AS saname
		 ,f.value:sa4	::varchar AS sa4
		 ,f.value:sa4name::varchar AS sa4name
		 ,f.value:region::varchar AS region
		 ,f.value:SA1_MAINCODE_2011::varchar AS sa1_maincode_2011
		 ,f.value:SA1_MAINCODE_2016::varchar AS sa1_maincode_2016
		 ,f.value:SA2_MAINCODE_2016::varchar AS sa2_maincode_2016
		 ,f.value:SA2_NAME_2016::varchar AS sa2_name_2016
		 ,f.value:SA3_CODE_2016::varchar AS sa3_code_2016
		 ,f.value:SA3_NAME_2016::varchar AS sa3_name_2016
		 ,f.value:SA4_CODE_2016::varchar AS sa4_code_2016
		 ,f.value:SA4_NAME_2016::varchar AS sa4_name_2016
		 ,f.value:RA_2011::varchar AS ra_2011
		 ,f.value:RA_2016::varchar AS ra_2016
		 ,f.value:MMM_2015::varchar AS mmm_2015
		 ,f.value:MMM_2019::varchar AS mmm_2019
		 ,f.value:ced::varchar AS ced
		 ,f.value:altitude::varchar AS altitude
		 ,f.value:chargezone::varchar AS charge_zone
		 ,f.value:phn_code::varchar AS phn_code
		 ,f.value:phn_name::varchar AS phn_name
		 ,f.value:lgaregion::varchar AS lga_region
		 ,f.value:electorate::varchar AS electorate
		 ,f.value:electoraterating::varchar AS electorate_rating
    FROM {{source('suburbmetadata', 'raw_suburbmetadata')}} 
    ,lateral flatten(input => payload) f
)

SELECT * FROM suburb