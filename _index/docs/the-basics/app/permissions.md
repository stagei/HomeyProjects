# Permissions

> Source: https://apps.developer.homey.app/the-basics/app/permissions

## Overview

Permissions control what your app can access on Homey. Only request permissions you actually need.

## Declaring Permissions

Add permissions to your `app.json`:

```json
{
  "permissions": [
    "homey:manager:speech-input",
    "homey:manager:speech-output",
    "homey:manager:api"
  ]
}
```

## Available Permissions

### Manager Permissions

| Permission | Description | Cloud Support |
|------------|-------------|---------------|
| `homey:manager:api` | Full API access | ❌ No |
| `homey:manager:speech-input` | Speech recognition | ✅ Yes |
| `homey:manager:speech-output` | Text-to-speech | ✅ Yes |
| `homey:manager:ledring` | LED ring control | ❌ No (Pro only) |
| `homey:manager:geolocation` | Location access | ✅ Yes |
| `homey:manager:notifications` | Push notifications | ✅ Yes |

### Wireless Permissions

| Permission | Description |
|------------|-------------|
| `homey:wireless:zwave` | Z-Wave communication |
| `homey:wireless:zigbee` | Zigbee communication |
| `homey:wireless:433` | 433 MHz communication |
| `homey:wireless:868` | 868 MHz communication |
| `homey:wireless:ir` | Infrared communication |
| `homey:wireless:ble` | Bluetooth LE communication |

### App-to-App Permissions

```json
{
  "permissions": [
    "homey:app:com.other.app"
  ]
}
```

## Cloud Restrictions

Some permissions are **not available on Homey Cloud**:

- `homey:manager:api` - Full API access
- `homey:manager:ledring` - LED ring
- Wireless permissions (Z-Wave, Zigbee, etc.)

## Best Practices

1. **Minimal permissions** - Only request what you need
2. **Check platform** - Some permissions disqualify cloud deployment
3. **Document usage** - Explain why each permission is needed in your app description
4. **Runtime checks** - Verify capabilities before using them

```javascript
// Check if running on Homey Pro
if (this.homey.platform === 'local') {
  // Use local-only features
}
```
