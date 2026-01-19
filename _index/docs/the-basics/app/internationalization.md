# Internationalization (i18n)

> Source: https://apps.developer.homey.app/the-basics/app/internationalization

## Overview

Homey supports multiple languages. All user-facing text should be translatable.

## Locale Files

Create JSON files in the `locales/` folder:

```
locales/
├── en.json    # English (required)
├── nl.json    # Dutch
├── de.json    # German
├── fr.json    # French
└── ...
```

## Locale File Structure

```json
{
  "greeting": "Hello!",
  "device": {
    "name": "My Device",
    "settings": {
      "interval": "Update Interval",
      "unit": "seconds"
    }
  },
  "errors": {
    "connection_failed": "Connection failed"
  }
}
```

## Using Translations in Manifest

Reference translations using `__key__` syntax:

```json
{
  "name": {
    "en": "My App",
    "nl": "Mijn App"
  },
  "drivers": [
    {
      "id": "my-driver",
      "name": {
        "en": "Smart Switch",
        "nl": "Slimme Schakelaar"
      }
    }
  ]
}
```

## Using Translations in Code

```javascript
// Simple translation
const greeting = this.homey.__('greeting');

// Nested translation (dot notation)
const deviceName = this.homey.__('device.name');

// With placeholders
// In en.json: "welcome": "Welcome, {{name}}!"
const welcome = this.homey.__('welcome', { name: 'John' });

// Plural forms
// In en.json: "items": { "one": "1 item", "other": "{{count}} items" }
const items = this.homey.__('items', { count: 5 });
```

## Flow Card Translations

```json
{
  "flow": {
    "triggers": {
      "device_turned_on": {
        "title": "Device turned on"
      }
    },
    "conditions": {
      "is_on": {
        "title": "Is on"
      }
    },
    "actions": {
      "turn_on": {
        "title": "Turn on"
      }
    }
  }
}
```

## Best Practices

1. **Always provide English** - `en.json` is required
2. **Use descriptive keys** - `errors.connection_failed` over `err1`
3. **Group related strings** - Use nested objects for organization
4. **Include placeholders** - Use `{{variable}}` for dynamic content
5. **Test all languages** - Verify translations display correctly

## Supported Languages

Homey supports: `en`, `nl`, `de`, `fr`, `it`, `es`, `sv`, `no`, `da`, `ru`, `pl`
