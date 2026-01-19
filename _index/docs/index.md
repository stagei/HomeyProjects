# Homey Apps SDK Documentation Index

> This documentation is organized from the official Homey Apps SDK at https://apps.developer.homey.app/

## Quick Links

| Topic | Description |
|-------|-------------|
| [Getting Started](./the-basics/getting-started/index.md) | First steps with Homey app development |
| [Drivers & Devices](./the-basics/devices.md) | Creating device drivers |
| [Flow Cards](./the-basics/flow.md) | Automations and triggers |
| [Widgets](./the-basics/widgets.md) | Dashboard components |
| [SDK v3 API Reference](./api-reference/index.md) | All managers and classes |

## Documentation Structure

```
_index/docs/
├── index.md                              # This file
│
├── the-basics/
│   ├── getting-started/
│   │   ├── index.md                      # Getting Started guide
│   │   └── homey-cli.md                  # CLI commands
│   ├── app/
│   │   ├── index.md                      # App class
│   │   ├── manifest.md                   # app.json reference
│   │   ├── permissions.md                # Permissions system
│   │   ├── persistent-storage.md         # Data persistence
│   │   └── internationalization.md       # Translations (i18n)
│   ├── devices/
│   │   ├── pairing.md                    # Device pairing flows
│   │   └── settings.md                   # Device settings
│   ├── devices.md                        # Drivers & Devices
│   ├── flow/
│   │   └── arguments.md                  # Flow card arguments
│   ├── flow.md                           # Flow cards
│   └── widgets.md                        # Dashboard widgets
│
├── wireless/
│   ├── index.md                          # Wireless overview
│   ├── wifi.md                           # Wi-Fi / HTTP
│   ├── zigbee.md                         # Zigbee protocol
│   ├── zwave.md                          # Z-Wave protocol
│   ├── bluetooth-le.md                   # Bluetooth LE
│   ├── matter.md                         # Matter protocol
│   ├── 433mhz.md                         # 433 MHz RF
│   └── infrared.md                       # Infrared (IR)
│
├── cloud/
│   ├── index.md                          # Cloud integration
│   ├── oauth2.md                         # OAuth2 authentication
│   └── webhooks.md                       # Webhook handling
│
├── advanced/
│   ├── web-api.md                        # HTTP API endpoints
│   ├── typescript.md                     # TypeScript setup
│   ├── images.md                         # Image handling
│   ├── homey-compose.md                  # Homey Compose files
│   └── custom-views/
│       ├── index.md                      # Custom views overview
│       ├── app-settings.md               # App settings view
│       └── pairing-views.md              # Custom pairing views
│
├── app-store/
│   ├── index.md                          # App Store overview
│   ├── publishing.md                     # Publishing apps
│   ├── guidelines.md                     # Store guidelines
│   ├── verified-developer.md             # Verified status
│   └── updating.md                       # Updating apps
│
├── upgrade-guides/
│   ├── index.md                          # Upgrade overview
│   ├── sdk-v3.md                         # SDK v3 migration
│   └── nodejs-22.md                      # Node.js 22 upgrade
│
├── api-reference/
│   └── index.md                          # SDK v3 API (managers & classes)
│
└── guides/
    └── (additional guides)
```

## Key Concepts for Scripting

### App Lifecycle
1. `onInit()` - App starts, register listeners
2. `onUninit()` - App stops, cleanup resources

### Device Lifecycle  
1. `onInit()` - Device initialized
2. `onAdded()` - Device added by user
3. `onSettings()` - Settings changed
4. `onDeleted()` - Device removed

### Core Classes
- `Homey.App` - Main app entry point
- `Homey.Driver` - Device driver (pairing, discovery)
- `Homey.Device` - Device instance (capabilities, state)

### Common Patterns

```javascript
// Access Homey APIs
this.homey.settings.get('key');
this.homey.flow.getActionCard('id');

// Device capabilities
await this.setCapabilityValue('onoff', true);
this.registerCapabilityListener('onoff', handler);

// Persistent storage
await this.setStoreValue('token', value);
const token = this.getStoreValue('token');
```

## Platform Support

| Feature | Homey Pro | Homey Cloud |
|---------|-----------|-------------|
| Drivers & Devices | ✅ | ✅ |
| Flow Cards | ✅ | ✅ |
| Web API | ✅ | ❌ |
| Widgets | ✅ | ❌ |
| Z-Wave/Zigbee | ✅ | ❌ |
| Bluetooth LE | ✅ | ❌ |
| 433 MHz/IR | ✅ | ❌ |

## External Resources

- [Apps SDK Reference](https://apps-sdk-v3.developer.homey.app/)
- [Web API Reference](https://api.developer.homey.app/)
- [Developer Tools](https://developer.athom.com/)
- [Community Forum](https://community.homey.app/)

## Driver Libraries

| Library | Documentation | Description |
|---------|---------------|-------------|
| Homey Z-Wave Driver | [athombv.github.io/node-homey-zwavedriver](https://athombv.github.io/node-homey-zwavedriver/) | Z-Wave device driver library |
| Homey Zigbee Driver | [athombv.github.io/node-homey-zigbeedriver](https://athombv.github.io/node-homey-zigbeedriver/) | Zigbee device driver library |
| Homey RF Driver | [github.com/athombv/node-homey-rfdriver](https://github.com/athombv/node-homey-rfdriver/) | 433 MHz / 868 MHz RF driver library |
| Homey OAuth2 App | [github.com/athombv/node-homey-oauth2app](https://github.com/athombv/node-homey-oauth2app/) | OAuth2 authentication helper |
| Homey Log | [github.com/athombv/node-homey-log](https://github.com/athombv/node-homey-log) | Sentry error logging integration |
