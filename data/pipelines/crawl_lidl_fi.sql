-- Lidl Finland crawling pipeline
-- Uses duckdb-crawler extension

.timer on

INSTALL crawler FROM community;
LOAD crawler;

-- Lidl Finland configuration
CREATE OR REPLACE TABLE crawl_config AS
SELECT
    'lidl.fi' as source,
    'https://www.lidl.fi' as base_url,
    current_timestamp as crawl_started;

SELECT "Discovering Lidl.fi products..." as status;

-- Discover sitemap
CREATE OR REPLACE TABLE lidl_fi_sitemap AS
SELECT * FROM discover('https://www.lidl.fi/sitemap.xml');

-- Filter product pages
CREATE OR REPLACE TABLE lidl_fi_product_urls AS
SELECT url
FROM lidl_fi_sitemap
WHERE url LIKE '%/p/%'
   OR url LIKE '%/tuotteet/%';

SELECT count(*) || ' product URLs found' as status FROM lidl_fi_product_urls;

-- Crawl product pages
-- Lidl uses JavaScript heavily, crawler extension should handle this
CREATE OR REPLACE TABLE lidl_fi_raw AS
SELECT
    url,
    -- Lidl stores product data in a JavaScript variable
    extract_js_var(html, 'window.__PRELOADED_STATE__') as preloaded_state,
    extract_json_ld(html, 'Product') as product_json,
    extract_meta(html, 'og:image') as image_url,
    crawled_at
FROM crawl(
    SELECT url FROM lidl_fi_product_urls LIMIT 1000
);

-- Transform to standard product schema
CREATE OR REPLACE TABLE lidl_fi_products AS
SELECT
    md5(url) as id,
    COALESCE(
        json_extract_string(product_json, '$.gtin13'),
        json_extract_string(preloaded_state, '$.product.ean')
    ) as ean,
    json_extract_string(preloaded_state, '$.product.code') as sku,
    COALESCE(
        json_extract_string(product_json, '$.name'),
        json_extract_string(preloaded_state, '$.product.name')
    ) as name,
    json_extract_string(preloaded_state, '$.product.brand') as brand,
    json_extract_string(product_json, '$.description') as description,
    json_extract_string(preloaded_state, '$.product.category') as category,
    -- Parse unit info
    json_extract(preloaded_state, '$.product.unit.size')::DOUBLE as unit_size,
    json_extract_string(preloaded_state, '$.product.unit.type') as unit_type,
    COALESCE(image_url, json_extract_string(preloaded_state, '$.product.image')) as image_url,
    'crawled' as source,
    url as source_url,
    crawled_at as created_at
FROM lidl_fi_raw
WHERE product_json IS NOT NULL OR preloaded_state IS NOT NULL;

-- Extract prices
CREATE OR REPLACE TABLE lidl_fi_prices AS
SELECT
    gen_random_uuid() as id,
    md5(url) as product_id,
    NULL as shop_id,
    COALESCE(
        CAST(json_extract(product_json, '$.offers.price') * 100 AS INTEGER),
        CAST(json_extract(preloaded_state, '$.product.price.value') * 100 AS INTEGER)
    ) as price_cents,
    'EUR' as currency,
    -- Unit price for comparison
    CAST(json_extract(preloaded_state, '$.product.price.unitPrice') * 100 AS INTEGER) as unit_price_cents,
    json_extract_string(preloaded_state, '$.product.price.unitPriceUnit') as comparison_unit,
    'crawled' as source,
    crawled_at as scanned_at,
    crawled_at as valid_from,
    NULL::TIMESTAMP as valid_until
FROM lidl_fi_raw
WHERE (product_json IS NOT NULL OR preloaded_state IS NOT NULL)
  AND (
    json_extract(product_json, '$.offers.price') IS NOT NULL
    OR json_extract(preloaded_state, '$.product.price.value') IS NOT NULL
  );

-- Export to parquet
COPY lidl_fi_products TO 'output/lidl_fi_products.parquet' (FORMAT PARQUET);
COPY lidl_fi_prices TO 'output/lidl_fi_prices.parquet' (FORMAT PARQUET);

SELECT 'Lidl.fi crawl complete' as status;
SELECT count(*) || ' products exported' as products FROM lidl_fi_products;
SELECT count(*) || ' prices exported' as prices FROM lidl_fi_prices;
