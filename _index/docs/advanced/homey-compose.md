# Homey Compose

> Source: https://apps.developer.homey.app/advanced/homey-compose

## Overview

Homey Compose splits your `app.json` into smaller, manageable files that are merged at build time.

## Benefits

- Easier to maintain large apps
- Better organization of drivers, flows, etc.
- Cleaner git diffs
- Reusable components

## Folder Structure

```
my-app/
├── .homeycompose/
│   ├── app.json              # Base app manifest
│   ├── capabilities/
│   │   └── my_capability.json
│   ├── flow/
│   │   ├── triggers/
│   │   │   └── my_trigger.json
│   │   ├── conditions/
│   │   │   └── my_condition.json
│   │   └── actions/
│   │       └── my_action.json
│   └── signals/
│       └── 433/
│           └── my_signal.json
├── drivers/
│   └── my-driver/
│       ├── driver.js
│       ├── device.js
│       └── driver.compose.json  # Driver-specific manifest
├── widgets/
│   └── my-widget/
│       ├── widget.compose.json
│       └── public/
│           └── index.html
└── app.json                  # Generated (do not edit)
```

## Base App Manifest

`.homeycompose/app.json`:

```json
{
  "id": "com.example.myapp",
  "version": "1.0.0",
  "compatibility": ">=5.0.0",
  "sdk": 3,
  "platforms": ["local"],
  "name": { "en": "My App" },
  "description": { "en": "My awesome app" },
  "category": ["tools"],
  "brandColor": "#3498db"
}
```

## Driver Compose

`drivers/my-driver/driver.compose.json`:

```json
{
  "name": { "en": "My Device" },
  "class": "socket",
  "capabilities": ["onoff", "measure_power"],
  "images": {
    "small": "/drivers/my-driver/assets/images/small.png",
    "large": "/drivers/my-driver/assets/images/large.png"
  },
  "pair": [
    { "id": "list_devices", "template": "list_devices" },
    { "id": "add_devices", "template": "add_devices" }
  ]
}
```

## Custom Capabilities

`.homeycompose/capabilities/my_custom_cap.json`:

```json
{
  "type": "number",
  "title": { "en": "My Custom Measurement" },
  "getable": true,
  "setable": false,
  "units": { "en": "units" },
  "min": 0,
  "max": 100,
  "step": 1
}
```

Reference in driver:

```json
{
  "capabilities": ["onoff", "my_custom_cap"]
}
```

## Flow Cards

### Trigger

`.homeycompose/flow/triggers/device_activated.json`:

```json
{
  "id": "device_activated",
  "title": { "en": "Device was activated" },
  "args": [
    {
      "name": "device",
      "type": "device",
      "filter": "driver_id=my-driver"
    }
  ],
  "tokens": [
    {
      "name": "level",
      "type": "number",
      "title": { "en": "Level" }
    }
  ]
}
```

### Condition

`.homeycompose/flow/conditions/is_active.json`:

```json
{
  "id": "is_active",
  "title": { "en": "Device is active" },
  "args": [
    {
      "name": "device",
      "type": "device",
      "filter": "driver_id=my-driver"
    }
  ]
}
```

### Action

`.homeycompose/flow/actions/set_level.json`:

```json
{
  "id": "set_level",
  "title": { "en": "Set level" },
  "titleFormatted": { "en": "Set level to [[level]]" },
  "args": [
    {
      "name": "device",
      "type": "device",
      "filter": "driver_id=my-driver"
    },
    {
      "name": "level",
      "type": "number",
      "min": 0,
      "max": 100
    }
  ]
}
```

## Signals

`.homeycompose/signals/433/my_signal.json`:

```json
{
  "sof": [250],
  "eof": [250],
  "words": [
    [250, 750],
    [750, 250]
  ],
  "interval": 10000,
  "repetitions": 10,
  "sensitivity": 0.7,
  "minimalLength": 24,
  "maximalLength": 24
}
```

## Building

Compose files into `app.json`:

```bash
homey app compose
```

This generates the final `app.json` from all compose files.

## Running

```bash
# Compose and run
homey app run

# Just compose
homey app compose
```

## Best Practices

1. **Don't edit generated app.json** - Edit compose files instead
2. **Use meaningful file names** - Match IDs to file names
3. **Group related files** - Keep related flows together
4. **Version control compose files** - They're the source of truth
5. **Run compose before publish** - Ensure app.json is up to date
