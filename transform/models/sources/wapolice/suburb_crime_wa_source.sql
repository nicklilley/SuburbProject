WITH crime_wa AS (   
    SELECT 
        f.VALUE:Id::varchar as id
        ,SPLIT_PART(SPLIT_PART(file_name, '_', 5), '.', 1)::varchar AS api_endpoint
        ,SPLIT_PART(file_name, '_', 0)::varchar AS state
        ,INITCAP(replace(f.VALUE:Locality,'\"',''))::varchar as suburb
        ,SPLIT_PART(file_name, '_', 3)::varchar AS postcode
        ,replace(f.VALUE:Offence,'\"','')::varchar as offence
        ,replace(f.VALUE:FinancialYear,'\"','') as financial_year
        ,f.VALUE:TotalAnnual::number(38,0) as total_annual_count
        ,f.VALUE:January::number(38,0) as january_count
        ,f.VALUE:February::number(38,0) as february_count
        ,f.VALUE:March::number(38,0) as march_count
        ,f.VALUE:April::number(38,0) as april_count
        ,f.VALUE:May::number(38,0) as may_count
        ,f.VALUE:June::number(38,0) as june_count
        ,f.VALUE:July::number(38,0) as july_count
        ,f.VALUE:August::number(38,0) as august_count      
        ,f.VALUE:September::number(38,0) as september_count  
        ,f.VALUE:October::number(38,0) as october_count
        ,f.VALUE:November::number(38,0) as november_count
        ,f.VALUE:December::number(38,0) as december_count
        FROM {{source('wapolice', 'raw_wapolice')}} 
        ,lateral flatten(input => payload) f
    )
SELECT * FROM crime_wa