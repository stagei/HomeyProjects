# Device Pairing

> Source: https://apps.developer.homey.app/the-basics/devices/pairing

## Overview

Pairing is the process of adding new devices to Homey. Define pairing flows in your driver manifest.

## Built-in Templates

### List Devices

Shows devices returned by `onPairListDevices()`:

```json
{
  "pair": [
    { "id": "list_devices", "template": "list_devices" },
    { "id": "add_devices", "template": "add_devices" }
  ]
}
```

```javascript
class MyDriver extends Homey.Driver {
  async onPairListDevices() {
    const devices = await this.discoverDevices();
    
    return devices.map(device => ({
      name: device.name,
      data: { id: device.uniqueId },
      settings: { ip: device.ip }
    }));
  }
}
```

### Login Credentials

For apps requiring authentication:

```json
{
  "pair": [
    { 
      "id": "login_credentials",
      "template": "login_credentials",
      "options": {
        "usernameLabel": { "en": "Email" },
        "passwordLabel": { "en": "Password" }
      }
    },
    { "id": "list_devices", "template": "list_devices" },
    { "id": "add_devices", "template": "add_devices" }
  ]
}
```

```javascript
async onPair(session) {
  let credentials = null;
  
  session.setHandler('login', async (data) => {
    const token = await this.authenticate(data.username, data.password);
    credentials = { token };
    return true;
  });
  
  session.setHandler('list_devices', async () => {
    return this.fetchDevices(credentials.token);
  });
}
```

### Login OAuth2

For OAuth authentication:

```json
{
  "pair": [
    { "id": "login_oauth2", "template": "login_oauth2" },
    { "id": "list_devices", "template": "list_devices" },
    { "id": "add_devices", "template": "add_devices" }
  ]
}
```

## Custom Pairing Views

For complex pairing flows:

```json
{
  "pair": [
    { "id": "start", "template": "start" },
    { 
      "id": "configure",
      "navigation": {
        "prev": "start",
        "next": "list_devices"
      }
    },
    { "id": "list_devices", "template": "list_devices" },
    { "id": "add_devices", "template": "add_devices" }
  ]
}
```

Create `/drivers/my-driver/pair/configure.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Configure</title>
</head>
<body>
  <h2>Device Configuration</h2>
  <input type="text" id="config" />
  <button id="next">Next</button>
  
  <script>
    function onHomeyReady(Homey) {
      Homey.ready();
      
      document.getElementById('next').addEventListener('click', async () => {
        const config = document.getElementById('config').value;
        await Homey.emit('configure', { config });
        Homey.nextView();
      });
    }
  </script>
  <script src="/homey.js" data-origin="pair"></script>
</body>
</html>
```

## Pairing Session Handlers

```javascript
async onPair(session) {
  // Handle custom events
  session.setHandler('configure', async (data) => {
    this.config = data.config;
  });
  
  // Override list_devices
  session.setHandler('list_devices', async () => {
    return this.findDevices(this.config);
  });
  
  // Validate before adding
  session.setHandler('add_device', async (device) => {
    // Validate device before adding
    await this.validateDevice(device);
  });
}
```

## Device Object Structure

```javascript
{
  name: 'Device Name',
  data: {
    id: 'unique-identifier'  // MUST be unique and unchanging
  },
  settings: {
    ip: '192.168.1.100'  // User-configurable
  },
  store: {
    token: 'auth-token'  // Hidden from user
  },
  capabilities: ['onoff', 'dim'],  // Override driver capabilities
  capabilitiesOptions: {
    dim: { min: 0, max: 100 }
  }
}
```

## Pairing Events

```javascript
async onPair(session) {
  session.setHandler('showView', async (viewId) => {
    this.log('Showing view:', viewId);
  });
  
  session.setHandler('list_devices', async () => {
    // Called when list_devices view is shown
  });
  
  session.setHandler('add_device', async (device) => {
    // Called when device is being added
  });
}
```

## Navigation

```javascript
// In custom pairing view
Homey.nextView();     // Go to next
Homey.prevView();     // Go to previous
Homey.showView('id'); // Go to specific view
Homey.done();         // Complete pairing
```

## Best Practices

1. **Unique data.id** - Must be unique and never change
2. **User-friendly names** - Pre-populate device names
3. **Validate connectivity** - Before showing device as available
4. **Store sensitive data** - Use `store`, not `settings`
5. **Handle errors** - Show clear error messages
