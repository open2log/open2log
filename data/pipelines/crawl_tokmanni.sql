-- Tokmanni.fi crawling pipeline
-- Uses duckdb-crawler extension

.timer on

INSTALL crawler FROM community;
LOAD crawler;

CREATE OR REPLACE TABLE crawl_config AS
SELECT
    'tokmanni.fi' as source,
    'https://www.tokmanni.fi' as base_url,
    current_timestamp as crawl_started;

SELECT "Discovering Tokmanni.fi products..." as status;

-- Discover sitemap
CREATE OR REPLACE TABLE tokmanni_sitemap AS
SELECT * FROM discover('https://www.tokmanni.fi/sitemap.xml');

-- Filter product pages
CREATE OR REPLACE TABLE tokmanni_product_urls AS
SELECT url
FROM tokmanni_sitemap
WHERE url LIKE '%/tuote/%'
   OR url LIKE '%/product/%'
   OR url ~ '/[0-9]+$';  -- Product IDs in URL

SELECT count(*) || ' product URLs found' as status FROM tokmanni_product_urls;

-- Crawl product pages
CREATE OR REPLACE TABLE tokmanni_raw AS
SELECT
    url,
    extract_json_ld(html, 'Product') as product_json,
    extract_meta(html, 'og:image') as image_url,
    extract_meta(html, 'product:price:amount') as price_meta,
    extract_meta(html, 'product:price:currency') as currency_meta,
    crawled_at
FROM crawl(
    SELECT url FROM tokmanni_product_urls LIMIT 1000
);

-- Transform to standard product schema
CREATE OR REPLACE TABLE tokmanni_products AS
SELECT
    md5(url) as id,
    json_extract_string(product_json, '$.gtin13') as ean,
    json_extract_string(product_json, '$.sku') as sku,
    json_extract_string(product_json, '$.name') as name,
    json_extract_string(product_json, '$.brand.name') as brand,
    json_extract_string(product_json, '$.description') as description,
    json_extract_string(product_json, '$.category') as category,
    NULL::DOUBLE as unit_size,
    NULL::VARCHAR as unit_type,
    image_url,
    'crawled' as source,
    url as source_url,
    crawled_at as created_at
FROM tokmanni_raw
WHERE product_json IS NOT NULL;

-- Extract prices
CREATE OR REPLACE TABLE tokmanni_prices AS
SELECT
    gen_random_uuid() as id,
    md5(url) as product_id,
    NULL as shop_id,
    COALESCE(
        CAST(json_extract(product_json, '$.offers.price') * 100 AS INTEGER),
        CAST(TRY_CAST(price_meta AS DOUBLE) * 100 AS INTEGER)
    ) as price_cents,
    COALESCE(
        json_extract_string(product_json, '$.offers.priceCurrency'),
        currency_meta,
        'EUR'
    ) as currency,
    'crawled' as source,
    crawled_at as scanned_at,
    crawled_at as valid_from,
    NULL::TIMESTAMP as valid_until
FROM tokmanni_raw
WHERE product_json IS NOT NULL OR price_meta IS NOT NULL;

-- Export to parquet
COPY tokmanni_products TO 'output/tokmanni_products.parquet' (FORMAT PARQUET);
COPY tokmanni_prices TO 'output/tokmanni_prices.parquet' (FORMAT PARQUET);

SELECT 'Tokmanni crawl complete' as status;
SELECT count(*) || ' products exported' as products FROM tokmanni_products;
SELECT count(*) || ' prices exported' as prices FROM tokmanni_prices;
