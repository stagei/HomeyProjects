# Zigbee

> Source: https://apps.developer.homey.app/wireless/zigbee

## Overview

Zigbee is a low-power mesh networking protocol. Homey Pro has a built-in Zigbee radio.

## Requirements

- Homey Pro (not available on Homey Cloud)
- Permission: `homey:wireless:zigbee`
- Package: `homey-zigbeedriver`

```bash
npm install homey-zigbeedriver
```

**Documentation:** [athombv.github.io/node-homey-zigbeedriver](https://athombv.github.io/node-homey-zigbeedriver/)

## Driver Manifest

```json
{
  "id": "my-zigbee-device",
  "class": "light",
  "capabilities": ["onoff", "dim"],
  "zigbee": {
    "manufacturerName": ["_TZ3000_manufacturer"],
    "productId": ["TS0001"],
    "endpoints": {
      "1": {
        "clusters": [0, 6, 8],
        "bindings": [6, 8]
      }
    }
  }
}
```

## Zigbee Device Class

```javascript
'use strict';

const { ZigBeeDevice } = require('homey-zigbeedriver');
const { CLUSTER } = require('zigbee-clusters');

class MyZigbeeDevice extends ZigBeeDevice {
  
  async onNodeInit({ zclNode }) {
    // Register capabilities
    this.registerCapability('onoff', CLUSTER.ON_OFF);
    this.registerCapability('dim', CLUSTER.LEVEL_CONTROL);
    
    // Optional: custom attribute reporting
    if (this.isFirstInit()) {
      await this.configureAttributeReporting([
        {
          endpointId: 1,
          cluster: CLUSTER.ON_OFF,
          attributeName: 'onOff',
          minInterval: 0,
          maxInterval: 300,
          minChange: 1
        }
      ]);
    }
  }
  
  // Handle attribute reports
  onOnOffAttributeReport(value) {
    this.log('onOff reported:', value);
  }
}

module.exports = MyZigbeeDevice;
```

## Common Clusters

| Cluster | ID | Purpose |
|---------|-----|---------|
| Basic | 0 | Device info |
| On/Off | 6 | Switch control |
| Level Control | 8 | Dimming |
| Color Control | 768 | Color/temperature |
| Temperature | 1026 | Temperature sensing |
| Humidity | 1029 | Humidity sensing |
| IAS Zone | 1280 | Security sensors |

## Capability Mapping

```javascript
// Map capability to cluster
this.registerCapability('onoff', CLUSTER.ON_OFF, {
  set: 'onWithTimedOff',
  setParser: (value) => ({
    onOffControl: value ? 1 : 0,
    onTime: 0,
    offWaitTime: 0
  }),
  get: 'onOff',
  report: 'onOff',
  reportParser: (value) => value === 1
});
```

## Attribute Reporting

```javascript
async onNodeInit({ zclNode }) {
  // Configure what attributes to report
  if (this.isFirstInit()) {
    await this.configureAttributeReporting([
      {
        endpointId: 1,
        cluster: CLUSTER.METERING,
        attributeName: 'currentSummationDelivered',
        minInterval: 10,
        maxInterval: 600,
        minChange: 1
      }
    ]);
  }
}
```

## Multiple Endpoints

```json
{
  "zigbee": {
    "endpoints": {
      "1": {
        "clusters": [0, 6]
      },
      "2": {
        "clusters": [0, 6]
      }
    }
  }
}
```

```javascript
// Access specific endpoint
const endpoint2 = zclNode.endpoints[2];
await endpoint2.clusters.onOff.toggle();
```

## Sub-devices

For devices with multiple switches/endpoints:

```json
{
  "id": "multi-switch",
  "zigbee": {
    "endpoints": { "1": {} },
    "subDevices": [
      {
        "id": "switch-2",
        "class": "socket",
        "capabilities": ["onoff"],
        "zigbee": {
          "endpoints": { "2": {} }
        }
      }
    ]
  }
}
```

## Best Practices

1. **Use `isFirstInit()`** - Only configure once per pairing
2. **Handle sleeping devices** - Battery devices may not respond immediately
3. **Configure reporting** - Set appropriate intervals for attributes
4. **Test thoroughly** - Zigbee behavior varies by manufacturer
