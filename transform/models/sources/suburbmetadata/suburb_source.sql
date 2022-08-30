with suburb as (
    SELECT
          "payload":id::varchar AS suburb_id
		 ,"payload":locality::varchar AS suburb
		 ,"payload":postcode::varchar AS postcode
		 ,"payload":state::varchar AS state
		 ,"payload":long::varchar AS longitude
		 ,"payload":lat::varchar AS latitude
		 ,"payload":Lat_precise::varchar AS latitude_precise
		 ,"payload":Long_precise::varchar AS longitude_precise	 
		 ,"payload":dc::varchar AS dc
		 ,"payload":type::varchar AS type
		 ,"payload":status::varchar AS status
		 ,"payload":sa3::varchar AS sa3
		 ,"payload":sa3name::varchar AS saname
		 ,"payload":sa4	::varchar AS sa4
		 ,"payload":sa4name::varchar AS sa4name
		 ,"payload":region::varchar AS region
		 ,"payload":SA1_MAINCODE_2011::varchar AS sa1_maincode_2011
		 ,"payload":SA1_MAINCODE_2016::varchar AS sa1_maincode_2016
		 ,"payload":SA2_MAINCODE_2016::varchar AS sa2_maincode_2016
		 ,"payload":SA2_NAME_2016::varchar AS sa2_name_2016
		 ,"payload":SA3_CODE_2016::varchar AS sa3_code_2016
		 ,"payload":SA3_NAME_2016::varchar AS sa3_name_2016
		 ,"payload":SA4_CODE_2016::varchar AS sa4_code_2016
		 ,"payload":SA4_NAME_2016::varchar AS sa4_name_2016
		 ,"payload":RA_2011::varchar AS ra_2011
		 ,"payload":RA_2016::varchar AS ra_2016
		 ,"payload":MMM_2015::varchar AS mmm_2015
		 ,"payload":MMM_2019::varchar AS mmm_2019
		 ,"payload":ced::varchar AS ced
		 ,"payload":altitude::varchar AS altitude
		 ,"payload":chargezone::varchar AS charge_zone
		 ,"payload":phn_code::varchar AS phn_code
		 ,"payload":phn_name::varchar AS phn_name
		 ,"payload":lgaregion::varchar AS lga_region
		 ,"payload":electorate::varchar AS electorate
		 ,"payload":electoraterating::varchar AS electorate_rating
    FROM {{source('suburbmetadata', 'raw_suburbmetadata')}}
)

select * from suburb