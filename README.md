# open2log

open2log is non-profit project by open2roam MTÜ to track prices in grocery shops physically by crowdsourcing the data and by searching it online.

Our goal is to save more time for everyone so that people who are more clever than us can focus on moonshots like cold fusion, quantum computing, affordable healthcare and just be more present with their families to raise the next generation of people with moral principles and willingness to help each other. Let's spend our time wisely, eventually we will all be dead.

Contributions and sponsorships are welcome. We mainly use Claude Code to build this service.

## Project Structure

```
open2log/
├── apps/
│   ├── web/open2log/    # Elixir/Phoenix backend API
│   ├── ios/             # Swift iOS app
│   └── android/         # Kotlin Android app (planned)
├── data/
│   ├── pipelines/       # DuckDB crawling SQL scripts
│   └── schemas/         # Database schemas
├── doc/
│   └── adr/             # Architecture Decision Records
├── infra/               # OpenTofu infrastructure code
├── server/
│   ├── configuration/   # NixOS flake for server
│   └── modules/         # NixOS modules
├── workers/             # Cloudflare Workers (Rust)
│   ├── image-upload/    # R2 presigned URL generator
│   └── shopping-lists/  # D1-backed shopping lists API
└── secrets/             # SOPS-encrypted secrets
```

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [devenv](https://devenv.sh/) for development environment

## Getting Started

```bash
# Enter development environment
devenv shell

# Setup Phoenix app
web setup

# Start Phoenix server
web server

# Run DuckDB crawlers
crawl all

# Deploy infrastructure (requires credentials)
infra plan
infra apply
```

## Available Commands

| Command | Description |
|---------|-------------|
| `infra <cmd>` | Run OpenTofu commands with secrets |
| `web <cmd>` | Phoenix app management |
| `crawl <target>` | Run DuckDB crawling pipelines |
| `deploy <ip>` | Deploy NixOS to server |
| `worker <cmd> <name>` | Manage Cloudflare Workers |

## Architecture

- **Backend**: Elixir/Phoenix with ecto_duckdb
- **Data**: DuckDB for processing, DuckLake for storage
- **Edge**: Cloudflare (R2, D1, Workers, CDN)
- **Server**: NixOS on Hetzner auction server
- **Storage**: Hetzner Storage Box (parquet files)
- **Mobile**: Native Swift (iOS), Kotlin (Android planned)

## License
AGPLv3 Open2Roam MTÜ ©