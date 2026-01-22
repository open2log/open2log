-- Product catalog schema for DuckLake
-- This schema is used for the SQLite file that is replicated via Litestream

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ean VARCHAR UNIQUE,
    sku VARCHAR,
    name VARCHAR NOT NULL,
    brand VARCHAR,
    description TEXT,
    category VARCHAR,
    unit_size DOUBLE,
    unit_type VARCHAR CHECK (unit_type IN ('g', 'kg', 'ml', 'l', 'pcs')),
    image_url VARCHAR,
    source VARCHAR NOT NULL CHECK (source IN ('crawled', 'user_submitted')),
    source_url VARCHAR,
    match_confidence DOUBLE,
    vote_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT current_timestamp,
    updated_at TIMESTAMP DEFAULT current_timestamp
);

-- Index for barcode lookups
CREATE INDEX IF NOT EXISTS idx_products_ean ON products(ean);

-- Index for search
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand);

-- Shops table
CREATE TABLE IF NOT EXISTS shops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gers_id VARCHAR UNIQUE,  -- Overture Maps GERS ID
    name VARCHAR NOT NULL,
    chain VARCHAR NOT NULL CHECK (chain IN ('lidl', 's_kaupat', 'k_market', 'tokmanni', 'prisma', 'other')),
    address VARCHAR,
    city VARCHAR,
    postal_code VARCHAR,
    country VARCHAR DEFAULT 'FI',
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    h3_index VARCHAR,  -- H3 geospatial index
    opening_hours JSON,
    created_at TIMESTAMP DEFAULT current_timestamp,
    updated_at TIMESTAMP DEFAULT current_timestamp
);

-- Spatial index via H3
CREATE INDEX IF NOT EXISTS idx_shops_h3 ON shops(h3_index);
CREATE INDEX IF NOT EXISTS idx_shops_chain ON shops(chain);
CREATE INDEX IF NOT EXISTS idx_shops_city ON shops(city);

-- Prices table
CREATE TABLE IF NOT EXISTS prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    shop_id UUID REFERENCES shops(id),
    user_id UUID,  -- References users table (may be in separate system)
    price_cents INTEGER NOT NULL,
    currency VARCHAR DEFAULT 'EUR',
    unit_price_cents INTEGER,
    comparison_unit VARCHAR CHECK (comparison_unit IN ('kg', 'l', 'pcs')),
    source VARCHAR NOT NULL CHECK (source IN ('crawled', 'user_scanned')),
    scanned_at TIMESTAMP,
    barcode_image_url VARCHAR,
    price_image_url VARCHAR,
    valid_from TIMESTAMP DEFAULT current_timestamp,
    valid_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT current_timestamp
);

CREATE INDEX IF NOT EXISTS idx_prices_product ON prices(product_id);
CREATE INDEX IF NOT EXISTS idx_prices_shop ON prices(shop_id);
CREATE INDEX IF NOT EXISTS idx_prices_valid FROM prices(valid_from);

-- Product matches table for user voting
CREATE TABLE IF NOT EXISTS product_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    physical_product_id UUID NOT NULL REFERENCES products(id),
    online_product_id UUID NOT NULL REFERENCES products(id),
    user_id UUID NOT NULL,
    vote VARCHAR NOT NULL CHECK (vote IN ('match', 'not_match')),
    confidence DOUBLE,
    created_at TIMESTAMP DEFAULT current_timestamp,
    UNIQUE (physical_product_id, online_product_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_matches_physical ON product_matches(physical_product_id);
CREATE INDEX IF NOT EXISTS idx_matches_online ON product_matches(online_product_id);
