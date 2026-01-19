# Z-Wave

> Source: https://apps.developer.homey.app/wireless/z-wave

## Overview

Z-Wave is a wireless protocol for smart home devices. Homey Pro has a built-in Z-Wave radio.

## Requirements

- Homey Pro (not available on Homey Cloud)
- Permission: `homey:wireless:zwave`
- Package: `homey-zwavedriver`

```bash
npm install homey-zwavedriver
```

**Documentation:** [athombv.github.io/node-homey-zwavedriver](https://athombv.github.io/node-homey-zwavedriver/)

## Driver Manifest

```json
{
  "id": "my-zwave-device",
  "class": "socket",
  "capabilities": ["onoff", "measure_power"],
  "zwave": {
    "manufacturerId": 134,
    "productTypeId": [3],
    "productId": [116],
    "wakeUpInterval": 0,
    "learnmode": {
      "instruction": { "en": "Press the button 3 times" }
    },
    "associationGroups": [1],
    "associationGroupsOptions": {
      "1": { "hint": { "en": "Lifeline" } }
    }
  }
}
```

## Z-Wave Device Class

```javascript
'use strict';

const { ZwaveDevice } = require('homey-zwavedriver');

class MyZwaveDevice extends ZwaveDevice {
  
  async onNodeInit() {
    // Register capabilities
    this.registerCapability('onoff', 'SWITCH_BINARY');
    this.registerCapability('measure_power', 'METER');
    
    // Register reports
    this.registerReportListener('METER', 'METER_REPORT', (report) => {
      this.log('Meter report:', report);
    });
  }
}

module.exports = MyZwaveDevice;
```

## Common Command Classes

| Command Class | Purpose |
|--------------|---------|
| `SWITCH_BINARY` | On/off control |
| `SWITCH_MULTILEVEL` | Dimming |
| `METER` | Power/energy measurement |
| `SENSOR_MULTILEVEL` | Temperature, humidity, etc. |
| `NOTIFICATION` | Alerts and events |
| `BATTERY` | Battery level |
| `CONFIGURATION` | Device settings |
| `WAKE_UP` | Sleep management |

## Capability Registration

```javascript
// Basic capability
this.registerCapability('onoff', 'SWITCH_BINARY');

// With options
this.registerCapability('dim', 'SWITCH_MULTILEVEL', {
  get: 'SWITCH_MULTILEVEL_GET',
  set: 'SWITCH_MULTILEVEL_SET',
  setParser: (value) => ({
    Value: Math.round(value * 99),
    'Dimming Duration': 'Default'
  }),
  report: 'SWITCH_MULTILEVEL_REPORT',
  reportParser: (report) => report.Value / 99
});
```

## Configuration Parameters

```javascript
// Get configuration
const value = await this.configurationGet({ index: 1 });

// Set configuration
await this.configurationSet({
  index: 1,
  size: 1,
  value: 10
});
```

Define in manifest:

```json
{
  "settings": [
    {
      "id": "led_indicator",
      "zwave": {
        "index": 1,
        "size": 1
      },
      "type": "dropdown",
      "label": { "en": "LED Indicator" },
      "value": "0",
      "values": [
        { "id": "0", "label": { "en": "Always off" } },
        { "id": "1", "label": { "en": "Always on" } }
      ]
    }
  ]
}
```

## Secure Communication

For S0/S2 security:

```json
{
  "zwave": {
    "security": ["S2_ACCESS_CONTROL", "S2_AUTHENTICATED"]
  }
}
```

## Association Groups

```json
{
  "zwave": {
    "associationGroups": [1, 2],
    "associationGroupsOptions": {
      "1": {
        "hint": { "en": "Lifeline - reports device status" }
      },
      "2": {
        "hint": { "en": "On/Off - controls associated devices" }
      }
    }
  }
}
```

## Multichannel (Multi-endpoint)

```javascript
// Access specific endpoint
this.registerCapability('onoff', 'SWITCH_BINARY', {
  multiChannelNodeId: 2
});
```

## Battery Devices

```json
{
  "zwave": {
    "wakeUpInterval": 3600
  }
}
```

```javascript
// Queue commands for sleeping devices
this.registerCapability('measure_battery', 'BATTERY', {
  getOnStart: true
});
```

## Best Practices

1. **Test inclusion** - Verify pairing instructions work
2. **Handle sleeping devices** - Commands are queued
3. **Use associations** - For device-to-device control
4. **Configure security** - Use S2 when supported
5. **Set appropriate wake-up** - Balance responsiveness and battery
