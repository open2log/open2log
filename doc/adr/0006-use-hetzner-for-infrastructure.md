# 6. Use Hetzner for Infrastructure

Date: 2026-01-21

## Status

Accepted

## Context

Need cost-effective hosting for server and storage. Options:
- AWS/GCP/Azure (expensive)
- DigitalOcean/Linode
- Hetzner

## Decision

Use Hetzner for:
- Auction server (dedicated, cost-effective)
- Storage Box BX11 (1TB, cheap storage for parquet files)

## Consequences

- Significantly cheaper than cloud providers
- Good network performance in Europe
- Storage box supports WebDAV, SSH, SFTP
- Auction servers are unpredictable availability
- European data residency
- Less managed services than AWS
- Need custom hrobot provider for Terraform
