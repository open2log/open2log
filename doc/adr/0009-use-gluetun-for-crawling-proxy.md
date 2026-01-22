# 9. Use Gluetun for Crawling Proxy

Date: 2026-01-21

## Status

Accepted

## Context

Need to crawl grocery store websites without exposing server IP. Options:
- Direct crawling (exposes IP, risk of blocking)
- Rotating proxy services (expensive)
- Self-managed VPN container

## Decision

Use Gluetun container as HTTP proxy for all crawling operations.

## Consequences

- Server IP stays hidden during crawling
- Single point of configuration for VPN
- Supports multiple VPN providers
- HTTP proxy interface for DuckDB crawler
- Need VPN subscription (Mullvad, ProtonVPN, etc.)
- Adds latency to crawling operations
- VPN provider must allow web scraping
- Container orchestration complexity
