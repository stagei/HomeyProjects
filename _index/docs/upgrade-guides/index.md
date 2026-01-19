# Upgrade Guides

> Source: https://apps.developer.homey.app/upgrade-guides/

## Overview

These guides help you upgrade your apps to newer SDK versions and Homey features.

## Available Guides

| Guide | Description |
|-------|-------------|
| [SDK v3 Upgrade](./sdk-v3.md) | Upgrade from SDK v2 to v3 |
| [Node.js 22](./nodejs-22.md) | Node.js 22 compatibility |

## Quick Upgrade Checklist

### SDK v3

- [ ] Update `"sdk": 3` in app.json
- [ ] Update `"compatibility": ">=5.0.0"`
- [ ] Convert callbacks to async/await
- [ ] Replace `Homey.ManagerX` with `this.homey.x`
- [ ] Update Flow card registration
- [ ] Test all functionality

### Node.js 22

- [ ] Update `"compatibility": ">=12.0.0"` (if using new features)
- [ ] Replace deprecated Node.js APIs
- [ ] Update dependencies
- [ ] Consider ESM migration
- [ ] Test with Node.js 22

## Compatibility Matrix

| Homey Version | Node.js | SDK |
|---------------|---------|-----|
| 12.0.0+ | 22 | 3 |
| 5.0.0+ | 12 | 3 |
| 2.0.0+ | 8 | 2 |

## Version Support

- **SDK v3** - Current, actively supported
- **SDK v2** - Legacy, limited support

We recommend all new apps use SDK v3.
