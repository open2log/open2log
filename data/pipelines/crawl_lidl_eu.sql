-- Lidl European crawling pipeline
-- Crawls Lidl websites across all European countries

.timer on

INSTALL crawler FROM community;
LOAD crawler;

-- All known Lidl European domains
-- Some may not exist or have different URL structures
CREATE OR REPLACE TABLE lidl_domains (
    country VARCHAR,
    domain VARCHAR,
    currency VARCHAR
);

INSERT INTO lidl_domains VALUES
    ('Austria', 'lidl.at', 'EUR'),
    ('Belgium', 'lidl.be', 'EUR'),
    ('Bulgaria', 'lidl.bg', 'BGN'),
    ('Croatia', 'lidl.hr', 'EUR'),
    ('Cyprus', 'lidl.com.cy', 'EUR'),
    ('Czech Republic', 'lidl.cz', 'CZK'),
    ('Denmark', 'lidl.dk', 'DKK'),
    ('Estonia', 'lidl.ee', 'EUR'),
    ('Finland', 'lidl.fi', 'EUR'),
    ('France', 'lidl.fr', 'EUR'),
    ('Germany', 'lidl.de', 'EUR'),
    ('Greece', 'lidl.gr', 'EUR'),
    ('Hungary', 'lidl.hu', 'HUF'),
    ('Ireland', 'lidl.ie', 'EUR'),
    ('Italy', 'lidl.it', 'EUR'),
    ('Latvia', 'lidl.lv', 'EUR'),
    ('Lithuania', 'lidl.lt', 'EUR'),
    ('Luxembourg', 'lidl.lu', 'EUR'),
    ('Malta', 'lidl.com.mt', 'EUR'),
    ('Netherlands', 'lidl.nl', 'EUR'),
    ('Poland', 'lidl.pl', 'PLN'),
    ('Portugal', 'lidl.pt', 'EUR'),
    ('Romania', 'lidl.ro', 'RON'),
    ('Slovakia', 'lidl.sk', 'EUR'),
    ('Slovenia', 'lidl.si', 'EUR'),
    ('Spain', 'lidl.es', 'EUR'),
    ('Sweden', 'lidl.se', 'SEK'),
    ('Switzerland', 'lidl.ch', 'CHF'),
    ('United Kingdom', 'lidl.co.uk', 'GBP');

SELECT 'Crawling ' || count(*) || ' Lidl domains' as status FROM lidl_domains;

-- Create consolidated tables
CREATE OR REPLACE TABLE lidl_eu_products (
    id VARCHAR,
    country VARCHAR,
    ean VARCHAR,
    sku VARCHAR,
    name VARCHAR,
    brand VARCHAR,
    description VARCHAR,
    category VARCHAR,
    unit_size DOUBLE,
    unit_type VARCHAR,
    image_url VARCHAR,
    source VARCHAR,
    source_url VARCHAR,
    created_at TIMESTAMP
);

CREATE OR REPLACE TABLE lidl_eu_prices (
    id UUID,
    product_id VARCHAR,
    country VARCHAR,
    price_cents INTEGER,
    currency VARCHAR,
    unit_price_cents INTEGER,
    comparison_unit VARCHAR,
    source VARCHAR,
    scanned_at TIMESTAMP,
    valid_from TIMESTAMP,
    valid_until TIMESTAMP
);

-- Function to crawl a single Lidl domain
-- Note: In actual implementation, this would use a macro or stored procedure
-- For now, we'll use a pattern that can be adapted

-- Crawl each domain
-- This is a template - the actual crawler extension may have different syntax
-- for iterating over domains

-- For each domain, discover and crawl products
-- This would typically be done in a loop or parallel execution

-- Example for a single domain (template):
/*
WITH domain_config AS (
    SELECT * FROM lidl_domains WHERE domain = 'lidl.de'
),
sitemap AS (
    SELECT * FROM discover('https://www.' || (SELECT domain FROM domain_config) || '/sitemap.xml')
),
product_urls AS (
    SELECT url FROM sitemap WHERE url LIKE '%/p/%'
),
raw_products AS (
    SELECT
        (SELECT country FROM domain_config) as country,
        (SELECT currency FROM domain_config) as currency,
        url,
        extract_js_var(html, 'window.__PRELOADED_STATE__') as preloaded_state,
        extract_json_ld(html, 'Product') as product_json,
        crawled_at
    FROM crawl(SELECT url FROM product_urls LIMIT 500)
)
INSERT INTO lidl_eu_products
SELECT
    md5(url) as id,
    country,
    json_extract_string(preloaded_state, '$.product.ean') as ean,
    json_extract_string(preloaded_state, '$.product.code') as sku,
    json_extract_string(product_json, '$.name') as name,
    json_extract_string(preloaded_state, '$.product.brand') as brand,
    json_extract_string(product_json, '$.description') as description,
    json_extract_string(preloaded_state, '$.product.category') as category,
    json_extract(preloaded_state, '$.product.unit.size')::DOUBLE as unit_size,
    json_extract_string(preloaded_state, '$.product.unit.type') as unit_type,
    json_extract_string(preloaded_state, '$.product.image') as image_url,
    'crawled' as source,
    url as source_url,
    crawled_at as created_at
FROM raw_products;
*/

-- Export placeholder - actual data would come from the loop above
COPY lidl_eu_products TO 'output/lidl_eu_products.parquet' (FORMAT PARQUET);
COPY lidl_eu_prices TO 'output/lidl_eu_prices.parquet' (FORMAT PARQUET);

SELECT 'Lidl EU crawl template created' as status;
SELECT count(DISTINCT domain) || ' domains configured' as domains FROM lidl_domains;
