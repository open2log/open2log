-- Consolidate all crawled data into unified tables
-- Run this after all individual crawl pipelines

.timer on

SELECT 'Consolidating product data from all sources...' as status;

-- Combine all products into a single table
CREATE OR REPLACE TABLE all_products AS
SELECT
    id,
    ean,
    sku,
    name,
    brand,
    description,
    category,
    unit_size,
    unit_type,
    image_url,
    source,
    source_url,
    created_at,
    'skaupat' as chain
FROM read_parquet('output/skaupat_products.parquet')
UNION ALL
SELECT
    id,
    ean,
    sku,
    name,
    brand,
    description,
    category,
    unit_size,
    unit_type,
    image_url,
    source,
    source_url,
    created_at,
    'lidl' as chain
FROM read_parquet('output/lidl_fi_products.parquet')
UNION ALL
SELECT
    id,
    ean,
    sku,
    name,
    brand,
    description,
    category,
    unit_size,
    unit_type,
    image_url,
    source,
    source_url,
    created_at,
    'tokmanni' as chain
FROM read_parquet('output/tokmanni_products.parquet');

SELECT count(*) || ' total products from all sources' as status FROM all_products;

-- Deduplicate products by EAN where available
-- Products with same EAN from different chains are the same product
CREATE OR REPLACE TABLE deduplicated_products AS
WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY COALESCE(ean, id)
            ORDER BY created_at DESC
        ) as rn
    FROM all_products
)
SELECT * EXCLUDE (rn)
FROM ranked
WHERE rn = 1;

SELECT count(*) || ' unique products after deduplication' as status FROM deduplicated_products;

-- Combine all prices
CREATE OR REPLACE TABLE all_prices AS
SELECT
    id,
    product_id,
    NULL::UUID as shop_id,
    price_cents,
    currency,
    NULL::INTEGER as unit_price_cents,
    NULL::VARCHAR as comparison_unit,
    source,
    scanned_at,
    valid_from,
    valid_until,
    'skaupat' as chain
FROM read_parquet('output/skaupat_prices.parquet')
UNION ALL
SELECT
    id,
    product_id,
    NULL::UUID as shop_id,
    price_cents,
    currency,
    unit_price_cents,
    comparison_unit,
    source,
    scanned_at,
    valid_from,
    valid_until,
    'lidl' as chain
FROM read_parquet('output/lidl_fi_prices.parquet')
UNION ALL
SELECT
    id,
    product_id,
    NULL::UUID as shop_id,
    price_cents,
    currency,
    NULL::INTEGER as unit_price_cents,
    NULL::VARCHAR as comparison_unit,
    source,
    scanned_at,
    valid_from,
    valid_until,
    'tokmanni' as chain
FROM read_parquet('output/tokmanni_prices.parquet');

SELECT count(*) || ' total prices from all sources' as status FROM all_prices;

-- Create price comparison view
CREATE OR REPLACE VIEW price_comparison AS
SELECT
    p.name,
    p.brand,
    p.ean,
    pr.chain,
    pr.price_cents / 100.0 as price_eur,
    pr.unit_price_cents / 100.0 as unit_price_eur,
    pr.comparison_unit,
    pr.valid_from
FROM deduplicated_products p
JOIN all_prices pr ON p.id = pr.product_id
WHERE pr.price_cents IS NOT NULL
ORDER BY p.ean, pr.price_cents;

-- Export consolidated data
COPY deduplicated_products TO 'output/consolidated_products.parquet' (FORMAT PARQUET);
COPY all_prices TO 'output/consolidated_prices.parquet' (FORMAT PARQUET);

-- Create a summary report
CREATE OR REPLACE TABLE crawl_summary AS
SELECT
    chain,
    count(DISTINCT id) as product_count,
    count(DISTINCT ean) FILTER (WHERE ean IS NOT NULL) as products_with_ean,
    avg(price_cents) / 100.0 as avg_price_eur,
    min(valid_from) as earliest_price,
    max(valid_from) as latest_price
FROM all_prices
JOIN all_products USING (product_id)
GROUP BY chain;

SELECT 'Consolidation complete!' as status;
SELECT * FROM crawl_summary;
