# Getting Started with Homey Apps SDK

> Source: https://apps.developer.homey.app/the-basics/getting-started

## Overview

Homey is a smart home platform that connects devices from various brands & technologies in one unified experience. The Homey Apps SDK enables developers to create apps that run on Homey.

## Key Concepts

- **Apps run locally** on Homey, similar to iPhone/Android apps
- **Node.js bundles** distributed through the Homey App Store or installed via Homey CLI
- Apps can extend Homey by adding new **Devices** and **Flow cards**
- Apps can transmit/receive wireless signals: **Wi-Fi, Zigbee, Z-Wave, 433 MHz, Bluetooth LE, Infrared**

## Prerequisites

1. Install Node.js (v22 recommended for latest Homey versions)
2. Install Homey CLI globally: `npm install -g homey`
3. A Homey device for testing (Pro or Cloud)

## Creating Your First App

```bash
# Login to Homey CLI
homey login

# Create a new app
homey app create

# Run the app in development mode
homey app run
```

## App Structure

```
my-app/
├── .homeycompose/           # Compose files (optional)
├── app.js                   # Main app entry point
├── app.json                 # App manifest
├── assets/                  # App images and icons
├── drivers/                 # Device drivers
│   └── my-driver/
│       ├── driver.js        # Driver class
│       ├── device.js        # Device class
│       └── driver.compose.json
├── locales/                 # Translations
│   └── en.json
└── package.json             # NPM dependencies
```

## SDK Version

- **SDK v3** is the current version (use `"sdk": 3` in manifest)
- SDK v3 uses **async/await** (no callbacks)
- Minimum compatibility: `>=5.0.0`

## Resources

- [Homey CLI Documentation](./homey-cli.md)
- [Apps SDK Reference](https://apps-sdk-v3.developer.homey.app/)
- [Web API](https://api.developer.homey.app/)
