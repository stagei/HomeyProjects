# Wireless Protocols

> Source: https://apps.developer.homey.app/wireless/

## Overview

Homey supports multiple wireless protocols for device communication. Each protocol requires specific permissions and has different capabilities.

## Supported Protocols

| Protocol | Permission | Package |
|----------|------------|---------|
| [Wi-Fi](./wifi.md) | (none required) | Native HTTP/TCP |
| [Zigbee](./zigbee.md) | `homey:wireless:zigbee` | `homey-zigbeedriver` |
| [Z-Wave](./zwave.md) | `homey:wireless:zwave` | `homey-zwavedriver` |
| [Bluetooth LE](./bluetooth-le.md) | `homey:wireless:ble` | Native BLE API |
| [433 MHz](./433mhz.md) | `homey:wireless:433` | Native RF API |
| [Infrared](./infrared.md) | `homey:wireless:ir` | Native IR API |
| [Matter](./matter.md) | (none required) | Native Matter API |

## Platform Support

| Protocol | Homey Pro | Homey Cloud |
|----------|-----------|-------------|
| Wi-Fi | ✅ | ✅ |
| Zigbee | ✅ | ❌ |
| Z-Wave | ✅ | ❌ |
| Bluetooth LE | ✅ | ❌ |
| 433 MHz | ✅ | ❌ |
| Infrared | ✅ | ❌ |
| Matter | ✅ | ❌ |

## Common Patterns

### Discovery

Most protocols support device discovery:

```javascript
// Wi-Fi: mDNS-SD, SSDP, MAC
// Zigbee: Automatic pairing
// Z-Wave: Inclusion mode
// BLE: Scanning
```

### Driver Libraries

For Zigbee and Z-Wave, use official driver libraries:

```bash
npm install homey-zigbeedriver
npm install homey-zwavedriver
npm install homey-rfdriver      # For 433/868 MHz
npm install homey-oauth2app     # For OAuth2 cloud APIs
npm install homey-log           # For Sentry error logging
```

| Library | Documentation |
|---------|---------------|
| `homey-zwavedriver` | [athombv.github.io/node-homey-zwavedriver](https://athombv.github.io/node-homey-zwavedriver/) |
| `homey-zigbeedriver` | [athombv.github.io/node-homey-zigbeedriver](https://athombv.github.io/node-homey-zigbeedriver/) |
| `homey-rfdriver` | [github.com/athombv/node-homey-rfdriver](https://github.com/athombv/node-homey-rfdriver/) |
| `homey-oauth2app` | [github.com/athombv/node-homey-oauth2app](https://github.com/athombv/node-homey-oauth2app/) |
| `homey-log` | [github.com/athombv/node-homey-log](https://github.com/athombv/node-homey-log) |

These provide:
- Base classes for drivers/devices
- Protocol-specific utilities
- Capability mapping
- Signal handling
