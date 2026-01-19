# Persistent Storage

> Source: https://apps.developer.homey.app/the-basics/app/persistent-storage

## Overview

Homey provides several ways to persist data across app restarts.

## App Settings (ManagerSettings)

For app-wide configuration and settings:

```javascript
// Set a value
this.homey.settings.set('myKey', 'myValue');

// Get a value
const value = this.homey.settings.get('myKey');

// Get all settings
const allSettings = this.homey.settings.getKeys();

// Remove a value
this.homey.settings.unset('myKey');

// Listen for changes
this.homey.settings.on('set', (key) => {
  this.log(`Setting changed: ${key}`);
});
```

**Important:** Values must be JSON-serializable (strings, numbers, booleans, arrays, objects).

## Device Store

For per-device persistent data:

```javascript
// In device.js
class MyDevice extends Homey.Device {
  
  async onInit() {
    // Get stored value
    const token = this.getStoreValue('accessToken');
    
    // Set value (persisted across restarts)
    await this.setStoreValue('accessToken', 'abc123');
    
    // Remove value
    await this.unsetStoreValue('accessToken');
  }
}
```

## Device Settings

User-configurable device settings (shown in device settings UI):

```javascript
// Get a setting
const pollInterval = this.getSetting('poll_interval');

// Set a setting
await this.setSettings({
  poll_interval: 30
});

// React to setting changes
async onSettings({ oldSettings, newSettings, changedKeys }) {
  if (changedKeys.includes('poll_interval')) {
    this.log('Poll interval changed to:', newSettings.poll_interval);
  }
}
```

Define settings in driver manifest:

```json
{
  "settings": [
    {
      "id": "poll_interval",
      "type": "number",
      "label": { "en": "Poll Interval (seconds)" },
      "value": 60,
      "min": 10,
      "max": 3600
    }
  ]
}
```

## Userdata Folder

For storing files (non-JSON data):

```javascript
const fs = require('fs').promises;
const path = require('path');

// Get userdata path
const userDataPath = this.homey.app.getPath('userdata');

// Write a file
const filePath = path.join(userDataPath, 'data.txt');
await fs.writeFile(filePath, 'Hello World');

// Read a file
const content = await fs.readFile(filePath, 'utf-8');
```

## Security Considerations

1. **Use unique filenames** - Avoid predictable names for sensitive data
2. **Validate input** - Always validate data before storing
3. **Encrypt sensitive data** - Consider encryption for tokens, passwords
4. **Clean up** - Remove old/unused data in `onUninit()`

## Best Practices

| Use Case | Storage Method |
|----------|----------------|
| App configuration | `homey.settings` |
| Device tokens/credentials | `Device.setStoreValue()` |
| User-configurable options | Device Settings |
| Large files, binary data | Userdata folder |
