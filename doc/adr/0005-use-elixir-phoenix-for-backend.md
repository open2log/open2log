# 5. Use Elixir/Phoenix for Backend

Date: 2026-01-21

## Status

Accepted

## Context

Need a backend to serve product data, handle user auth, and provide API for mobile apps. Options:
- Node.js/Express
- Python/FastAPI
- Rust/Axum
- Elixir/Phoenix

## Decision

Use Elixir/Phoenix with ecto_duckdb adapter.

## Consequences

- Excellent concurrency model (Erlang VM)
- Real-time features built-in (LiveView, Channels)
- Phoenix is batteries-included
- ecto_duckdb enables direct DuckDB integration
- Good performance for API workloads
- Smaller talent pool than Node/Python
- Learning curve for Elixir syntax
