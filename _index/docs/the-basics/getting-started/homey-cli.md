# Homey CLI

> Source: https://apps.developer.homey.app/the-basics/getting-started/homey-cli

## Installation

```bash
npm install -g homey
```

## Authentication

```bash
# Login to your Athom account
homey login

# Select which Homey to use
homey select
```

## App Commands

```bash
# Create a new app
homey app create

# Run app in development mode (live reload)
homey app run

# Install app on Homey
homey app install

# Validate app structure and manifest
homey app validate

# Build the app
homey app build

# Publish to App Store
homey app publish

# Version management
homey app version patch  # 1.0.0 -> 1.0.1
homey app version minor  # 1.0.0 -> 1.1.0
homey app version major  # 1.0.0 -> 2.0.0
```

## Driver Commands

```bash
# Create a new driver
homey app driver create

# Compose drivers from .homeycompose folder
homey app compose
```

## Flow Commands

```bash
# Create a new flow card
homey app flow create
```

## Debugging

```bash
# View app logs in real-time
homey app log

# Run with verbose output
homey app run --verbose
```

## Common Options

| Option | Description |
|--------|-------------|
| `--path <path>` | Specify app path |
| `--remote` | Run on remote Homey |
| `--clean` | Clean build before running |

## Environment Variables

- `HOMEY_LOG_LEVEL` - Set log level (debug, info, warn, error)

## Tips

1. Use `homey app run` during development for live reload
2. Always run `homey app validate` before publishing
3. Use `homey app compose` when using Homey Compose files
