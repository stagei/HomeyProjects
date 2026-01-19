# Drivers & Devices

> Source: https://apps.developer.homey.app/the-basics/devices

## Overview

Drivers define how to communicate with a type of device. Devices are instances of a driver that represent physical or virtual devices.

## Driver Structure

```
drivers/
└── my-driver/
    ├── driver.js           # Driver class
    ├── device.js           # Device class
    ├── driver.compose.json # Driver manifest (if using Compose)
    └── assets/
        └── icon.svg        # Device icon
```

## Driver Class

```javascript
'use strict';

const Homey = require('homey');

class MyDriver extends Homey.Driver {
  
  async onInit() {
    this.log('MyDriver has been initialized');
  }
  
  async onPairListDevices() {
    // Return list of devices found during pairing
    return [
      {
        name: 'Device Name',
        data: {
          id: 'unique-device-id'
        },
        settings: {
          ip: '192.168.1.100'
        }
      }
    ];
  }
}

module.exports = MyDriver;
```

## Device Class

```javascript
'use strict';

const Homey = require('homey');

class MyDevice extends Homey.Device {
  
  async onInit() {
    this.log('MyDevice has been initialized');
    
    // Register capability listeners
    this.registerCapabilityListener('onoff', this.onCapabilityOnoff.bind(this));
  }
  
  async onCapabilityOnoff(value, opts) {
    // Handle on/off capability change
    this.log('Turning', value ? 'on' : 'off');
    
    // Send command to physical device
    await this.sendCommand(value);
  }
  
  async onAdded() {
    this.log('MyDevice has been added');
  }
  
  async onDeleted() {
    this.log('MyDevice has been deleted');
  }
  
  async onSettings({ oldSettings, newSettings, changedKeys }) {
    this.log('Settings changed:', changedKeys);
  }
}

module.exports = MyDevice;
```

## Capabilities

Capabilities define what a device can do:

```json
{
  "capabilities": [
    "onoff",
    "dim",
    "light_temperature",
    "measure_power"
  ]
}
```

### Common Capabilities

| Capability | Type | Description |
|------------|------|-------------|
| `onoff` | boolean | On/off state |
| `dim` | number (0-1) | Dim level |
| `light_temperature` | number (0-1) | Color temperature |
| `light_hue` | number (0-1) | Color hue |
| `light_saturation` | number (0-1) | Color saturation |
| `measure_power` | number | Power usage (W) |
| `measure_temperature` | number | Temperature (°C) |
| `measure_humidity` | number | Humidity (%) |
| `alarm_motion` | boolean | Motion detected |
| `alarm_contact` | boolean | Door/window open |

### Setting Capability Values

```javascript
// Set capability value
await this.setCapabilityValue('onoff', true);
await this.setCapabilityValue('dim', 0.5);

// Get capability value
const isOn = this.getCapabilityValue('onoff');
```

## Device Availability

```javascript
// Mark device as unavailable
await this.setUnavailable('Device is offline');

// Mark device as available
await this.setAvailable();
```

## Device Data vs Settings

| Property | Purpose | Changeable |
|----------|---------|------------|
| `data` | Unique device identifier | No |
| `settings` | User-configurable options | Yes |
| `store` | App-internal persistent data | Yes |

## Pairing

Pairing is the process of adding a new device:

```javascript
async onPairListDevices() {
  const devices = await this.discoverDevices();
  
  return devices.map(device => ({
    name: device.name,
    data: { id: device.id },
    settings: { ip: device.ip }
  }));
}
```

## Wireless Protocols

Drivers can use various protocols:

| Protocol | Package |
|----------|---------|
| Zigbee | `homey-zigbeedriver` |
| Z-Wave | `homey-zwavedriver` |
| Wi-Fi | Native HTTP/TCP |
| Bluetooth LE | `homey-ble` |

## Best Practices

1. **Unique data.id** - Ensure each device has a unique identifier
2. **Handle offline** - Use `setUnavailable()` when device is unreachable
3. **Debounce updates** - Don't flood capability updates
4. **Clean up** - Remove listeners in `onDeleted()`
