# Device Classes

> Source: https://apps-sdk-v3.developer.homey.app/tutorial-device-classes.html

## Overview

Device classes define the type of device and determine its icon, behavior, and available capabilities in Homey.

## Available Device Classes

### Lighting

| Class | Icon | Description |
|-------|------|-------------|
| `light` | 💡 | Generic light |
| `amplifier` | 🔊 | Audio amplifier |

### Climate

| Class | Icon | Description |
|-------|------|-------------|
| `thermostat` | 🌡️ | Thermostat |
| `heater` | ♨️ | Space heater |
| `fan` | 🌀 | Fan |
| `airconditioning` | ❄️ | Air conditioning |

### Sensors

| Class | Icon | Description |
|-------|------|-------------|
| `sensor` | 📊 | Generic sensor |
| `doorbell` | 🔔 | Doorbell |
| `button` | 🔘 | Button/remote |

### Security

| Class | Icon | Description |
|-------|------|-------------|
| `lock` | 🔒 | Door lock |
| `alarm` | 🚨 | Alarm system |
| `homealarm` | 🏠 | Home alarm panel |

### Switches & Plugs

| Class | Icon | Description |
|-------|------|-------------|
| `socket` | 🔌 | Power socket/plug |
| `switch` | ⚡ | Wall switch |
| `relay` | ⚡ | Relay module |

### Covers

| Class | Icon | Description |
|-------|------|-------------|
| `blinds` | 🪟 | Window blinds |
| `curtain` | 🪟 | Curtains |
| `sunshade` | ☂️ | Sun shade/awning |
| `windowcoverings` | 🪟 | Generic window covering |

### Doors & Garage

| Class | Icon | Description |
|-------|------|-------------|
| `garagedoor` | 🚗 | Garage door |
| `gate` | 🚧 | Gate |

### Entertainment

| Class | Icon | Description |
|-------|------|-------------|
| `tv` | 📺 | Television |
| `speaker` | 🔈 | Speaker |
| `camera` | 📷 | Camera |

### Appliances

| Class | Icon | Description |
|-------|------|-------------|
| `coffeemachine` | ☕ | Coffee machine |
| `kettle` | 🫖 | Kettle |
| `vacuumcleaner` | 🧹 | Vacuum cleaner |

### Other

| Class | Icon | Description |
|-------|------|-------------|
| `remote` | 🎮 | Remote control |
| `other` | ❓ | Other/unknown |
| `homey` | 🏠 | Homey device |

## Setting Device Class

### In Driver Manifest

```json
{
  "id": "my-driver",
  "class": "light",
  "capabilities": ["onoff", "dim"]
}
```

### Virtual Device Class

For devices that can be multiple types:

```json
{
  "id": "multi-device",
  "class": "socket",
  "virtualClass": "fan"
}
```

Users can change the virtual class in device settings.

## Device Class Defaults

Each class has default capabilities and UI:

### Light

```json
{
  "class": "light",
  "capabilities": ["onoff", "dim", "light_hue", "light_saturation"]
}
```

### Socket

```json
{
  "class": "socket",
  "capabilities": ["onoff", "measure_power", "meter_power"]
}
```

### Thermostat

```json
{
  "class": "thermostat",
  "capabilities": ["target_temperature", "measure_temperature", "thermostat_mode"]
}
```

### Sensor

```json
{
  "class": "sensor",
  "capabilities": ["measure_temperature", "measure_humidity", "alarm_motion"]
}
```

### Lock

```json
{
  "class": "lock",
  "capabilities": ["locked", "alarm_tamper", "measure_battery"]
}
```

### Camera

```json
{
  "class": "camera",
  "capabilities": ["onoff", "alarm_motion"]
}
```

## Energy Configuration

Define energy usage for devices:

```json
{
  "class": "light",
  "energy": {
    "approximation": {
      "usageOn": 10,
      "usageOff": 0.5
    }
  }
}
```

### Energy Properties

| Property | Type | Description |
|----------|------|-------------|
| `usageOn` | number | Watts when on |
| `usageOff` | number | Watts when off (standby) |
| `usageConstant` | number | Constant wattage |

### With Capabilities

```json
{
  "class": "light",
  "capabilities": ["onoff", "dim", "measure_power"],
  "energy": {
    "approximation": {
      "usageOn": 60,
      "usageOff": 0.5
    },
    "cumpiations": {
      "dim": {
        "0.5": 30
      }
    }
  }
}
```

## Dynamic Device Class

Set device class during pairing:

```javascript
async onPairListDevices() {
  const devices = await this.discoverDevices();
  
  return devices.map(device => ({
    name: device.name,
    data: { id: device.id },
    class: device.type === 'dimmer' ? 'light' : 'socket'
  }));
}
```

## Changing Device Class

Devices can change class at runtime (rare):

```javascript
await this.setClass('fan');
```

## Sub-devices

For devices with multiple functions:

```json
{
  "id": "multi-socket",
  "class": "socket",
  "capabilities": ["onoff"],
  "zigbee": {
    "endpoints": { "1": {} },
    "subDevices": [
      {
        "id": "socket-2",
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

1. **Choose accurate class** - Helps users understand the device
2. **Match capabilities** - Class should match device capabilities
3. **Consider UI** - Class affects how device appears in app
4. **Energy data** - Provide energy estimates when possible
5. **Use virtual class** - For multi-function devices
