-- S-kaupat.fi (SOK grocery chain) crawling pipeline
-- Uses duckdb-crawler extension

.timer on

-- Install and load required extensions
INSTALL crawler FROM community;
LOAD crawler;

-- Create output directory
CREATE OR REPLACE TABLE crawl_config AS
SELECT
    's-kaupat.fi' as source,
    'https://www.s-kaupat.fi' as base_url,
    current_timestamp as crawl_started;

-- Discover sitemap and product pages
-- The crawler extension should auto-discover sitemap.xml
SELECT "Discovering sitemap..." as status;

CREATE OR REPLACE TABLE skaupat_sitemap AS
SELECT * FROM discover('https://www.s-kaupat.fi/sitemap.xml');

-- Filter product pages
CREATE OR REPLACE TABLE skaupat_product_urls AS
SELECT url
FROM skaupat_sitemap
WHERE url LIKE '%/tuote/%'
   OR url LIKE '%/product/%';

SELECT count(*) || ' product URLs found' as status FROM skaupat_product_urls;

-- Crawl product pages and extract structured data
-- The crawler extension extracts JSON-LD and meta tags automatically
CREATE OR REPLACE TABLE skaupat_raw_products AS
SELECT
    url,
    extract_json_ld(html, 'Product') as product_json,
    extract_meta(html, 'og:image') as image_url,
    crawled_at
FROM crawl(
    SELECT url FROM skaupat_product_urls LIMIT 1000  -- Start with 1000 for testing
);

-- Transform to standard product schema
CREATE OR REPLACE TABLE skaupat_products AS
SELECT
    md5(url) as id,
    json_extract_string(product_json, '$.gtin13') as ean,
    json_extract_string(product_json, '$.sku') as sku,
    json_extract_string(product_json, '$.name') as name,
    json_extract_string(product_json, '$.brand.name') as brand,
    json_extract_string(product_json, '$.description') as description,
    json_extract_string(product_json, '$.category') as category,
    -- Parse unit info from name if available
    NULL::DOUBLE as unit_size,
    NULL::VARCHAR as unit_type,
    image_url,
    'crawled' as source,
    url as source_url,
    crawled_at as created_at
FROM skaupat_raw_products
WHERE product_json IS NOT NULL;

-- Extract prices
CREATE OR REPLACE TABLE skaupat_prices AS
SELECT
    gen_random_uuid() as id,
    md5(url) as product_id,
    NULL as shop_id,  -- S-kaupat is online-only for now
    CAST(json_extract(product_json, '$.offers.price') * 100 AS INTEGER) as price_cents,
    json_extract_string(product_json, '$.offers.priceCurrency') as currency,
    'crawled' as source,
    crawled_at as scanned_at,
    crawled_at as valid_from,
    NULL::TIMESTAMP as valid_until
FROM skaupat_raw_products
WHERE product_json IS NOT NULL
  AND json_extract(product_json, '$.offers.price') IS NOT NULL;

-- Export to parquet
COPY skaupat_products TO 'output/skaupat_products.parquet' (FORMAT PARQUET);
COPY skaupat_prices TO 'output/skaupat_prices.parquet' (FORMAT PARQUET);

SELECT 'S-kaupat crawl complete' as status;
SELECT count(*) || ' products exported' as products FROM skaupat_products;
SELECT count(*) || ' prices exported' as prices FROM skaupat_prices;
