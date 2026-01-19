# Homey App Structure

> Source: https://apps.developer.homey.app/the-basics/app

## Overview

A Homey App is a Node.js application that runs on Homey. It extends Homey's functionality by adding devices, flow cards, and other features.

## App Class

The main app class extends `Homey.App`:

```javascript
'use strict';

const Homey = require('homey');

class MyApp extends Homey.App {
  
  async onInit() {
    this.log('MyApp has been initialized');
    
    // Register flow cards, listeners, etc.
  }
  
  async onUninit() {
    // Cleanup when app is uninstalled
  }
}

module.exports = MyApp;
```

## Accessing Homey APIs

All Homey managers are accessed through `this.homey`:

```javascript
// Access settings
const value = this.homey.settings.get('myKey');
this.homey.settings.set('myKey', 'myValue');

// Access the API
const devices = await this.homey.api.devices.getDevices();

// Access notifications
await this.homey.notifications.createNotification({
  excerpt: 'Something happened!'
});

// Access flow
this.homey.flow.getConditionCard('my-condition');
```

## App Lifecycle

1. **onInit()** - Called when the app starts
2. **onUninit()** - Called when the app is uninstalled or updated

## Key Components

| Component | Description |
|-----------|-------------|
| `app.json` | App manifest with metadata and configuration |
| `app.js` | Main app class |
| `drivers/` | Device drivers |
| `locales/` | Translation files |
| `assets/` | Images and icons |

## Best Practices

- Use `async/await` for all asynchronous operations
- Keep global scope minimal; store logic in the App class
- Use proper error handling with try/catch
- Log important events using `this.log()`, `this.error()`
