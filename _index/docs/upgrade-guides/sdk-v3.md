# Upgrading to SDK v3

> Source: https://apps.developer.homey.app/upgrade-guides/upgrading-to-sdk-v3

## Overview

SDK v3 introduced significant changes from SDK v2. This guide covers the key differences.

## Manifest Changes

### SDK Version

```json
{
  "sdk": 3,
  "compatibility": ">=5.0.0"
}
```

### Platforms

```json
{
  "platforms": ["local"]
}
```

Or for multi-platform:

```json
{
  "platforms": ["local", "cloud"]
}
```

## Async/Await

### SDK v2 (Callbacks)

```javascript
// OLD - Don't use
onInit(callback) {
  this.initializeDevice((err) => {
    if (err) return callback(err);
    callback();
  });
}
```

### SDK v3 (Promises)

```javascript
// NEW - Use this
async onInit() {
  await this.initializeDevice();
}
```

## Manager Access

### SDK v2

```javascript
// OLD
const Homey = require('homey');
Homey.ManagerSettings.get('key');
Homey.ManagerFlow.getActionCard('id');
```

### SDK v3

```javascript
// NEW
this.homey.settings.get('key');
this.homey.flow.getActionCard('id');
```

## Lifecycle Methods

All lifecycle methods are now async:

```javascript
class MyDevice extends Homey.Device {
  
  async onInit() {
    // Device initialized
  }
  
  async onAdded() {
    // Device added
  }
  
  async onSettings({ oldSettings, newSettings, changedKeys }) {
    // Settings changed
  }
  
  async onDeleted() {
    // Device deleted
  }
}
```

## Flow Cards

### SDK v2

```javascript
new Homey.FlowCardAction('my_action')
  .register()
  .registerRunListener((args, state, callback) => {
    callback(null, true);
  });
```

### SDK v3

```javascript
this.homey.flow.getActionCard('my_action')
  .registerRunListener(async (args, state) => {
    return true;
  });
```

## Device Capabilities

### SDK v2

```javascript
this.registerCapabilityListener('onoff', (value, opts, callback) => {
  callback(null);
});
```

### SDK v3

```javascript
this.registerCapabilityListener('onoff', async (value, opts) => {
  await this.setDeviceState(value);
});
```

## Settings

### SDK v2

```javascript
Homey.ManagerSettings.set('key', value);
const val = Homey.ManagerSettings.get('key');
```

### SDK v3

```javascript
this.homey.settings.set('key', value);
const val = this.homey.settings.get('key');
```

## Signals (RF/IR)

### SDK v2

```javascript
const signal = new Homey.Signal433('my-signal');
```

### SDK v3

```javascript
const signal = this.homey.rf.getSignal433('my-signal');
```

## Images

### SDK v2

```javascript
const image = new Homey.Image();
```

### SDK v3

```javascript
const image = await this.homey.images.createImage();
```

## Timezone Handling

SDK v3 uses the Homey timezone:

```javascript
// Get current time in Homey's timezone
const now = new Date();

// Timezone info
const timezone = this.homey.clock.getTimezone();
```

## Deprecated APIs

Remove usage of:

- `Homey.ManagerX` - Use `this.homey.x` instead
- Callback-based APIs - Use async/await
- `Homey.app` in devices - Use `this.homey.app`

## Migration Steps

1. Update `app.json`:
   ```json
   { "sdk": 3, "compatibility": ">=5.0.0" }
   ```

2. Convert callbacks to async/await

3. Replace `Homey.ManagerX` with `this.homey.x`

4. Update Flow card registration

5. Test thoroughly

## Breaking Changes Summary

| SDK v2 | SDK v3 |
|--------|--------|
| Callbacks | async/await |
| `Homey.ManagerSettings` | `this.homey.settings` |
| `new Homey.FlowCardAction()` | `this.homey.flow.getActionCard()` |
| `new Homey.Signal433()` | `this.homey.rf.getSignal433()` |
| `new Homey.Image()` | `this.homey.images.createImage()` |
