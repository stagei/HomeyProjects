# Device Settings

> Source: https://apps.developer.homey.app/the-basics/devices/settings

## Overview

Device settings allow users to configure device-specific options through the Homey app.

## Defining Settings

In driver manifest:

```json
{
  "id": "my-driver",
  "settings": [
    {
      "id": "ip_address",
      "type": "text",
      "label": { "en": "IP Address" },
      "value": "",
      "hint": { "en": "The device's IP address" }
    },
    {
      "id": "poll_interval",
      "type": "number",
      "label": { "en": "Poll Interval" },
      "value": 60,
      "min": 10,
      "max": 3600,
      "units": { "en": "seconds" }
    }
  ]
}
```

## Setting Types

### Text

```json
{
  "id": "hostname",
  "type": "text",
  "label": { "en": "Hostname" },
  "value": ""
}
```

### Password

```json
{
  "id": "password",
  "type": "password",
  "label": { "en": "Password" },
  "value": ""
}
```

### Number

```json
{
  "id": "timeout",
  "type": "number",
  "label": { "en": "Timeout" },
  "value": 30,
  "min": 1,
  "max": 120,
  "step": 1,
  "units": { "en": "seconds" }
}
```

### Checkbox

```json
{
  "id": "enabled",
  "type": "checkbox",
  "label": { "en": "Enable Feature" },
  "value": true
}
```

### Dropdown

```json
{
  "id": "mode",
  "type": "dropdown",
  "label": { "en": "Mode" },
  "value": "auto",
  "values": [
    { "id": "auto", "label": { "en": "Automatic" } },
    { "id": "manual", "label": { "en": "Manual" } },
    { "id": "eco", "label": { "en": "Eco Mode" } }
  ]
}
```

### Radio

```json
{
  "id": "color",
  "type": "radio",
  "label": { "en": "Color Theme" },
  "value": "blue",
  "values": [
    { "id": "blue", "label": { "en": "Blue" } },
    { "id": "green", "label": { "en": "Green" } },
    { "id": "red", "label": { "en": "Red" } }
  ]
}
```

### Textarea

```json
{
  "id": "notes",
  "type": "textarea",
  "label": { "en": "Notes" },
  "value": ""
}
```

### Label (Read-only)

```json
{
  "id": "firmware",
  "type": "label",
  "label": { "en": "Firmware Version" },
  "value": "Unknown"
}
```

## Grouping Settings

```json
{
  "settings": [
    {
      "type": "group",
      "label": { "en": "Connection" },
      "children": [
        { "id": "ip", "type": "text", "label": { "en": "IP" } },
        { "id": "port", "type": "number", "label": { "en": "Port" } }
      ]
    },
    {
      "type": "group",
      "label": { "en": "Advanced" },
      "children": [
        { "id": "debug", "type": "checkbox", "label": { "en": "Debug" } }
      ]
    }
  ]
}
```

## Accessing Settings

```javascript
class MyDevice extends Homey.Device {
  
  async onInit() {
    // Get a setting
    const pollInterval = this.getSetting('poll_interval');
    
    // Start polling
    this.pollTimer = setInterval(() => this.poll(), pollInterval * 1000);
  }
  
  // Handle setting changes
  async onSettings({ oldSettings, newSettings, changedKeys }) {
    // Check what changed
    if (changedKeys.includes('poll_interval')) {
      // Restart polling with new interval
      clearInterval(this.pollTimer);
      this.pollTimer = setInterval(
        () => this.poll(),
        newSettings.poll_interval * 1000
      );
    }
    
    if (changedKeys.includes('ip_address')) {
      // Reconnect with new IP
      await this.reconnect(newSettings.ip_address);
    }
  }
}
```

## Setting Settings Programmatically

```javascript
// Set multiple settings
await this.setSettings({
  firmware: 'v1.2.3',
  last_seen: new Date().toISOString()
});
```

## Z-Wave/Zigbee Settings

For wireless devices, settings can sync with device parameters:

### Z-Wave

```json
{
  "id": "led_mode",
  "type": "dropdown",
  "label": { "en": "LED Mode" },
  "zwave": {
    "index": 1,
    "size": 1
  },
  "values": [
    { "id": "0", "label": { "en": "Off" } },
    { "id": "1", "label": { "en": "On" } }
  ]
}
```

### Zigbee

```json
{
  "id": "power_on_state",
  "type": "dropdown",
  "label": { "en": "Power-on State" },
  "zigbee": {
    "endpoint": 1,
    "cluster": "genOnOff",
    "attribute": "startUpOnOff"
  }
}
```

## Best Practices

1. **Sensible defaults** - Provide good default values
2. **Clear labels** - Descriptive, translated labels
3. **Add hints** - Explain what settings do
4. **Validate changes** - In `onSettings()` handler
5. **Handle errors** - Throw on invalid settings
