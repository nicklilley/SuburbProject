WITH realty_performance as (
    SELECT
         SPLIT_PART(file_name, '_', 6)::varchar AS api_endpoint
        ,SPLIT_PART(file_name, '_', 0)::varchar AS state
        ,SPLIT_PART(file_name, '_', 2)::varchar AS suburb
        ,SPLIT_PART(file_name, '_', 3)::varchar AS postcode
        ,SPLIT_PART(SPLIT_PART(file_name, '_', 5), '.', 1)::varchar AS api_response_code
        ,f.value:year::varchar AS year
        ,f.value:month::varchar AS month
        ,SPLIT_PART(SPLIT_PART(file_name, '_', 7), '.', 1)::varchar AS property_type
        ,CASE
            WHEN f1.key = 'lowestSaleListingPrice' THEN 'Lowest Listing Price'
            WHEN f1.key = '5thPercentileSoldPrice' THEN '5th Percentile Sold Price'
            WHEN f1.key = 'medianSoldPrice' THEN 'Median Sold Price'
            WHEN f1.key = 'lowestSoldPrice' THEN 'Lowest Sold Price'
            WHEN f1.key = 'numberSaleListing' THEN 'Number of Listings'
            WHEN f1.key = 'auctionNumberAuctioned' THEN 'Number Auctioned'
            WHEN f1.key = 'medianRentListingPrice' THEN 'Median Rent '
            WHEN f1.key = 'daysOnMarket' THEN 'Days on Market'
            WHEN f1.key = '95thPercentileSoldPrice' THEN '95th Percentile Sold Price'
            WHEN f1.key = 'highestRentListingPrice' THEN 'Highest Rent'
            WHEN f1.key = 'numberRentListing' THEN 'Number of Rent Listings'
            WHEN f1.key = '25thPercentileSoldPrice' THEN '25th Percentile Sold Price'
            WHEN f1.key = 'lowestRentListingPrice' THEN 'Lowest Rent'
            WHEN f1.key = 'auctionNumberSold' THEN 'Number of Sold Auctions'
            WHEN f1.key = 'discountPercentage' THEN 'Discount Percentage (Listing Price/Sold Price)'
            WHEN f1.key = 'highestSoldPrice' THEN 'Highest Sold Price'
            WHEN f1.key = '75thPercentileSoldPrice' THEN '75th Percentile Sold Price'
            WHEN f1.key = 'highestSaleListingPrice' THEN 'Highest Listing Price'
            WHEN f1.key = 'medianSaleListingPrice' THEN 'Median Listing Price'
            WHEN f1.key = 'numberSold' THEN 'Number Sold'
            ELSE f1.key
            END::varchar AS metric
        ,f1.value::number(38,0) AS value
    FROM {{source('apidomainonline', 'raw_apidomainonline')}} p
        ,lateral flatten(input => p.payload, path => 'series', outer => true) f
        ,lateral flatten(input => f.value:values) f1
    WHERE file_name ILIKE '%suburbPerformanceStatistics%'
)

SELECT * FROM realty_performance