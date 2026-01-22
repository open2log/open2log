# DuckDB Crawling Pipelines

This directory contains DuckDB SQL scripts for crawling grocery store websites.

## Extensions Required

- `duckdb-crawler`: For web crawling and data extraction
- `httpfs`: For writing parquet files to remote storage
- `parquet`: For parquet file operations

## Directory Structure

```
pipelines/
├── crawl_s_kaupat.sql     # S-kaupat.fi (SOK grocery chain)
├── crawl_tokmanni.sql     # Tokmanni.fi
├── crawl_lidl_fi.sql      # Lidl Finland
├── crawl_lidl_eu.sql      # Lidl all European TLDs
├── extract_products.sql    # Common product extraction
└── consolidate.sql         # Consolidate all sources
```

## Usage

Run pipelines with the `duckdb` command:

```bash
# Run single pipeline
duckdb -f pipelines/crawl_s_kaupat.sql

# Run all pipelines
for f in pipelines/crawl_*.sql; do duckdb -f "$f"; done
```

## Output

All pipelines output to parquet files in the `output/` directory:
- `products.parquet` - Product catalog
- `prices.parquet` - Current prices
- `shops.parquet` - Shop locations
