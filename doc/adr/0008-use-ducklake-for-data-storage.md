# 8. Use DuckLake with Litestream for Data Storage

Date: 2026-01-21

## Status

Accepted

## Context

Need to store product catalog, prices, and images. Requirements:
- Cheap storage (potentially TBs of data)
- Queryable from backend
- Accessible from mobile apps for offline use
- Resilient to data loss

## Decision

Use DuckLake (SQLite + Parquet) with:
- SQLite metadata on server, replicated via Litestream to storage box
- Parquet data files on Hetzner Storage Box via WebDAV
- Images on Cloudflare R2 (free egress)

## Consequences

- SQLite is simple and well-understood
- Litestream provides continuous backup
- Parquet files can be read directly by clients
- WebDAV access enables direct reads from mobile
- R2's free egress reduces costs for images
- Complex setup with multiple storage layers
- Need to manage consistency between SQLite and Parquet
- May explore WAL-log-only replication later
