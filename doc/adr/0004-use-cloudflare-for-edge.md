# 4. Use Cloudflare for Edge Infrastructure

Date: 2026-01-21

## Status

Accepted

## Context

Need CDN, DDoS protection, rate limiting, and edge compute. Server IP must stay hidden. Options:
- Self-managed nginx + firewall
- AWS CloudFront
- Cloudflare

## Decision

Use Cloudflare for:
- DNS and CDN
- Rate limiting (API protection)
- R2 for image storage (free egress)
- D1 for shared shopping lists
- Workers for edge logic (Rust)

## Consequences

- Free egress saves significant costs at scale
- Global edge network for low latency
- Server IP hidden behind proxy
- Rate limiting at edge reduces server load
- Terraform provider available for IaC
- Vendor lock-in for edge features
- D1 is SQLite-compatible, eases potential migration
