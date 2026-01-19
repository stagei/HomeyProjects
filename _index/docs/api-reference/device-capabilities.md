# Device Capabilities

> Source: https://apps-sdk-v3.developer.homey.app/tutorial-device-capabilities.html

## Overview

Capabilities define what a device can do. They are the interface between Homey and your device.

## Capability Types

| Type | Description | Example |
|------|-------------|---------|
| `boolean` | True/false state | `onoff`, `alarm_motion` |
| `number` | Numeric value | `dim`, `measure_temperature` |
| `string` | Text value | `speaker_artist` |
| `enum` | Predefined values | `thermostat_mode` |

## Built-in Capabilities

### On/Off & Dimming

| Capability | Type | Range | Description |
|------------|------|-------|-------------|
| `onoff` | boolean | - | On/off state |
| `dim` | number | 0-1 | Brightness level |

### Light Control

| Capability | Type | Range | Description |
|------------|------|-------|-------------|
| `light_hue` | number | 0-1 | Color hue |
| `light_saturation` | number | 0-1 | Color saturation |
| `light_temperature` | number | 0-1 | Color temperature (warm-cool) |
| `light_mode` | enum | color/temperature | Light mode |

### Measurements

| Capability | Type | Units | Description |
|------------|------|-------|-------------|
| `measure_temperature` | number | °C | Temperature |
| `measure_humidity` | number | % | Humidity |
| `measure_pressure` | number | mbar | Pressure |
| `measure_luminance` | number | lux | Light level |
| `measure_co2` | number | ppm | CO2 level |
| `measure_pm25` | number | µg/m³ | PM2.5 particles |
| `measure_noise` | number | dB | Noise level |
| `measure_rain` | number | mm | Rainfall |
| `measure_wind_strength` | number | km/h | Wind speed |
| `measure_wind_angle` | number | ° | Wind direction |
| `measure_gust_strength` | number | km/h | Wind gust |
| `measure_ultraviolet` | number | - | UV index |

### Power & Energy

| Capability | Type | Units | Description |
|------------|------|-------|-------------|
| `measure_power` | number | W | Current power usage |
| `meter_power` | number | kWh | Total energy consumed |
| `measure_voltage` | number | V | Voltage |
| `measure_current` | number | A | Current |

### Battery

| Capability | Type | Range | Description |
|------------|------|-------|-------------|
| `measure_battery` | number | 0-100 | Battery percentage |
| `alarm_battery` | boolean | - | Low battery alarm |

### Alarms

| Capability | Type | Description |
|------------|------|-------------|
| `alarm_motion` | boolean | Motion detected |
| `alarm_contact` | boolean | Door/window open |
| `alarm_smoke` | boolean | Smoke detected |
| `alarm_co` | boolean | CO detected |
| `alarm_water` | boolean | Water leak detected |
| `alarm_fire` | boolean | Fire detected |
| `alarm_heat` | boolean | Heat alarm |
| `alarm_tamper` | boolean | Device tampered |
| `alarm_generic` | boolean | Generic alarm |

### Thermostat

| Capability | Type | Description |
|------------|------|-------------|
| `target_temperature` | number | Target temperature (°C) |
| `thermostat_mode` | enum | off/heat/cool/auto |

### Lock

| Capability | Type | Description |
|------------|------|-------------|
| `locked` | boolean | Lock state |
| `lock_mode` | enum | Lock mode |

### Buttons

| Capability | Type | Description |
|------------|------|-------------|
| `button` | boolean | Button press |

### Speaker

| Capability | Type | Description |
|------------|------|-------------|
| `volume_set` | number | Volume level (0-1) |
| `volume_up` | boolean | Increase volume |
| `volume_down` | boolean | Decrease volume |
| `volume_mute` | boolean | Mute state |
| `speaker_playing` | boolean | Playing state |
| `speaker_next` | boolean | Next track |
| `speaker_prev` | boolean | Previous track |
| `speaker_shuffle` | boolean | Shuffle mode |
| `speaker_repeat` | enum | Repeat mode |
| `speaker_artist` | string | Current artist |
| `speaker_album` | string | Current album |
| `speaker_track` | string | Current track |
| `speaker_duration` | number | Track duration |
| `speaker_position` | number | Track position |

### Window Coverings

| Capability | Type | Description |
|------------|------|-------------|
| `windowcoverings_state` | enum | up/idle/down |
| `windowcoverings_set` | number | Position (0-1) |
| `windowcoverings_tilt_set` | number | Tilt angle (0-1) |

### Vacuum

| Capability | Type | Description |
|------------|------|-------------|
| `vacuumcleaner_state` | enum | cleaning/spot_cleaning/docked/charging/stopped |

### Garagedoor

| Capability | Type | Description |
|------------|------|-------------|
| `garagedoor_closed` | boolean | Door closed state |

## Using Capabilities

### Define in Driver Manifest

```json
{
  "id": "my-driver",
  "capabilities": ["onoff", "dim", "measure_power"]
}
```

### Register Listeners

```javascript
async onInit() {
  // Handle capability changes
  this.registerCapabilityListener('onoff', async (value) => {
    await this.setDeviceState(value);
  });
  
  this.registerCapabilityListener('dim', async (value) => {
    await this.setDeviceBrightness(value);
  });
}
```

### Set Capability Values

```javascript
// Set current state
await this.setCapabilityValue('onoff', true);
await this.setCapabilityValue('dim', 0.75);
await this.setCapabilityValue('measure_power', 42.5);

// Get current value
const isOn = this.getCapabilityValue('onoff');
```

### Multiple Capability Listeners

```javascript
this.registerMultipleCapabilityListener(
  ['onoff', 'dim'],
  async (values) => {
    const { onoff, dim } = values;
    await this.setDeviceState(onoff, dim);
  },
  500 // debounce ms
);
```

## Custom Capabilities

Define in `.homeycompose/capabilities/`:

`my_custom_cap.json`:
```json
{
  "type": "number",
  "title": {
    "en": "My Measurement"
  },
  "getable": true,
  "setable": false,
  "uiComponent": "sensor",
  "icon": "/assets/my_icon.svg",
  "units": {
    "en": "units"
  },
  "min": 0,
  "max": 100,
  "step": 1,
  "insights": true
}
```

### Custom Capability Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | string | boolean/number/string/enum |
| `title` | object | Localized display name |
| `getable` | boolean | Can be read |
| `setable` | boolean | Can be written |
| `uiComponent` | string | UI component type |
| `icon` | string | Icon path |
| `units` | object | Unit label |
| `min` | number | Minimum value |
| `max` | number | Maximum value |
| `step` | number | Step increment |
| `values` | array | Enum values |
| `insights` | boolean | Show in Insights |

### UI Components

| Component | Description |
|-----------|-------------|
| `sensor` | Read-only sensor display |
| `toggle` | On/off toggle |
| `slider` | Numeric slider |
| `picker` | Color picker |
| `thermostat` | Thermostat dial |
| `media` | Media controls |
| `battery` | Battery indicator |
| `button` | Pressable button |
| `ternary` | Three-state control |

## Capability Options

Override capability behavior per device:

```json
{
  "capabilitiesOptions": {
    "dim": {
      "min": 0.1,
      "max": 1,
      "step": 0.1
    },
    "measure_temperature": {
      "title": { "en": "Outside Temperature" }
    }
  }
}
```

## Best Practices

1. **Use built-in capabilities** - When possible, use standard capabilities
2. **Meaningful values** - Ensure capability values are accurate
3. **Update promptly** - Set capability values when device state changes
4. **Handle errors** - Catch errors in capability listeners
5. **Debounce rapid changes** - Use `registerMultipleCapabilityListener`
