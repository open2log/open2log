# 3. Use DuckDB for Data Processing

Date: 2026-01-21

## Status

Accepted

## Context

Need to crawl grocery store websites, process product data, and store it efficiently. Options:
- Traditional ETL with Python/Pandas
- Apache Spark
- DuckDB with custom extensions

## Decision

Use DuckDB with community extensions (duckdb-crawler, duckdb-weather, duckdb-valhalla-routing) for all data processing.

## Consequences

- Single tool for crawling, transforming, and querying
- SQL-based pipelines are readable and maintainable
- Parquet output integrates with DuckLake for storage
- Custom extensions provide specialized functionality
- May need to contribute fixes/features to extension repos
- Learning curve for DuckDB-specific SQL features
