# Matter

> Source: https://apps.developer.homey.app/wireless/matter

## Overview

Matter is a unified smart home protocol that works across ecosystems. Homey Pro supports Matter devices natively.

## Requirements

- Homey Pro v10.0.0+
- No special permissions required
- `"platforms": ["local"]`

## Driver Manifest

```json
{
  "id": "my-matter-device",
  "class": "light",
  "capabilities": ["onoff", "dim"],
  "platforms": ["local"],
  "connectivity": ["matter"],
  "matter": {
    "vendorId": 4448,
    "productId": 1234,
    "deviceTypes": ["dimmableLight"]
  }
}
```

## Matter Device Types

| Device Type | Description |
|-------------|-------------|
| `onOffLight` | Simple on/off light |
| `dimmableLight` | Dimmable light |
| `colorTemperatureLight` | Light with color temperature |
| `extendedColorLight` | Full color light |
| `onOffPluginUnit` | Smart plug |
| `dimmablePluginUnit` | Dimmable outlet |
| `doorLock` | Smart lock |
| `thermostat` | HVAC thermostat |
| `contactSensor` | Door/window sensor |
| `motionSensor` | Motion detector |
| `temperatureSensor` | Temperature sensor |

## Matter Device Class

```javascript
'use strict';

const Homey = require('homey');

class MyMatterDevice extends Homey.Device {
  
  async onInit() {
    this.log('Matter device initialized');
    
    // Register capability listeners
    this.registerCapabilityListener('onoff', this.onCapabilityOnoff.bind(this));
    this.registerCapabilityListener('dim', this.onCapabilityDim.bind(this));
  }
  
  async onCapabilityOnoff(value) {
    // Matter handles the communication
    this.log('Setting onoff:', value);
  }
  
  async onCapabilityDim(value) {
    this.log('Setting dim:', value);
  }
}

module.exports = MyMatterDevice;
```

## Bridged Devices

Homey can bridge non-Matter devices to Matter:

```json
{
  "matter": {
    "bridge": true
  }
}
```

## Vendor and Product IDs

- `vendorId`: Your company's Matter Vendor ID (assigned by CSA)
- `productId`: Your product's ID within your vendor namespace

For development, you can use test IDs.

## Pairing Matter Devices

Matter devices are paired using:
1. QR code scanning
2. Manual pairing code entry

The pairing process is handled by Homey's Matter controller.

## Capabilities Mapping

Matter clusters map to Homey capabilities:

| Matter Cluster | Homey Capability |
|----------------|------------------|
| On/Off | `onoff` |
| Level Control | `dim` |
| Color Control | `light_hue`, `light_saturation` |
| Color Temperature | `light_temperature` |
| Temperature Measurement | `measure_temperature` |
| Relative Humidity | `measure_humidity` |

## Limitations

- Matter is only available on Homey Pro (local platform)
- Some Matter features may not be fully supported
- Device icons cannot be customized for bridged devices
- Store values have limitations for bridged devices

## Best Practices

1. **Use correct device types** - Match your device's functionality
2. **Handle offline devices** - Matter devices can go offline
3. **Test thoroughly** - Matter behavior may vary
4. **Keep firmware updated** - Matter is evolving
