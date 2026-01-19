# Cloud Integration

> Source: https://apps.developer.homey.app/cloud/

## Overview

Homey apps can integrate with cloud services for authentication, real-time updates, and external API access.

## Cloud Features

| Feature | Description |
|---------|-------------|
| [OAuth2](./oauth2.md) | Authenticate with third-party services |
| [Webhooks](./webhooks.md) | Receive real-time HTTP notifications |

## Homey Cloud vs Homey Pro

### What is Homey Cloud?

Homey Cloud is the cloud-hosted version of Homey that doesn't require Homey Pro hardware.

### Limitations on Homey Cloud

Apps running on Homey Cloud cannot use:

- Web API endpoints
- Widgets
- Wireless protocols (Z-Wave, Zigbee, BLE, 433 MHz, IR)
- LED ring control
- `homey:manager:api` permission

### Platform Detection

```javascript
async onInit() {
  if (this.homey.platform === 'local') {
    // Running on Homey Pro
    this.setupLocalFeatures();
  } else if (this.homey.platform === 'cloud') {
    // Running on Homey Cloud
    this.setupCloudFeatures();
  }
}
```

### Multi-Platform Apps

To support both platforms:

```json
{
  "platforms": ["local", "cloud"],
  "permissions": []
}
```

Avoid cloud-blocking permissions:
- `homey:manager:api`
- `homey:manager:ledring`
- `homey:wireless:*`

## Environment Variables

Store sensitive configuration in `env.json`:

```json
{
  "API_KEY": "your-api-key",
  "API_SECRET": "your-api-secret",
  "WEBHOOK_ID": "webhook-id",
  "WEBHOOK_SECRET": "webhook-secret"
}
```

Access in code:

```javascript
const apiKey = Homey.env.API_KEY;
const apiSecret = Homey.env.API_SECRET;
```

Reference in manifest:

```json
{
  "oauth2": {
    "clientId": "$API_KEY",
    "clientSecret": "$API_SECRET"
  }
}
```

**Note:** `env.json` is git-ignored by default and not included in published apps.

## Best Practices

1. **Support both platforms** - When possible, make apps work on Cloud and Pro
2. **Graceful degradation** - Disable features not available on Cloud
3. **Secure secrets** - Use env.json for API keys and secrets
4. **Handle offline** - Cloud services may be temporarily unavailable
